import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/audio_recording.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'l10n/app_localizations.dart';
import 'main.dart';
import 'main_page.dart';

class ScreenUnlock extends StatefulWidget {
  @override
  State<ScreenUnlock> createState() => _ScreenUnlockState();
}

class _ScreenUnlockState extends State<ScreenUnlock> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentPlayingPath;
  StreamSubscription? _dummyWaveTimer;
  final List<double> _waveData = [];
  List<FileSystemEntity> _recordings = [];
  bool isLoading = false;

  // Replace with your IP address for API calls
  // final String ip_address = "http://YOUR_API_IP_HERE";

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadRecordings();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
    setState(() => _isRecorderInitialized = true);
  }

  // Future<void> _startRecording() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final prefix = "screenunlock";

  //   final files = dir
  //       .listSync()
  //       .where((f) => f.path.endsWith('.aac') && f.path.contains(prefix))
  //       .toList();

  //   final maxAllowed = 3;

  //   if (files.length >= maxAllowed) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //             "You can only record up to $maxAllowed recordings for Screen Lock"),
  //       ),
  //     );
  //     return;
  //   }

  //   final existingNumbers = files
  //       .map((f) => int.tryParse(
  //           RegExp(r'_(\d+)\.aac').firstMatch(f.path)?.group(1) ?? ''))
  //       .whereType<int>()
  //       .toSet();

  //   int nextNumber = 1;
  //   while (existingNumbers.contains(nextNumber)) {
  //     nextNumber++;
  //   }

  //   final filePath = '${dir.path}/${prefix}_$nextNumber.aac';
  //   await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

  //   _dummyWaveTimer = Stream.periodic(Duration(milliseconds: 100), (_) {
  //     setState(() {
  //       final r = Random();
  //       _waveData.add(10 + r.nextDouble() * 40);
  //       if (_waveData.length > 30) _waveData.removeAt(0);
  //     });
  //   }).listen((_) {});

  //   setState(() => _isRecording = true);
  // }
  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefix = "screenunlock";
    final maxAllowed = 3;

    final files = dir
        .listSync()
        .where((f) =>
            f.path.toLowerCase().endsWith('.aac') &&
            f.path.toLowerCase().contains(prefix))
        .toList();

    if (files.length >= maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "You can only record up to $maxAllowed recordings for Screen Unlock"),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd_hh-mm-ss_a').format(now);
    final fileName = 'ScreenUnlock_$formattedDateTime.aac';
    final filePath = '${dir.path}/$fileName';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

    _dummyWaveTimer = Stream.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        final r = Random();
        _waveData.add(10 + r.nextDouble() * 40);
        if (_waveData.length > 30) _waveData.removeAt(0);
      });
    }).listen((_) {});

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    await _dummyWaveTimer?.cancel();
    setState(() {
      _isRecording = false;
      _waveData.clear();
    });
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefix = "screenunlock";

    final files = dir
        .listSync()
        .where((f) =>
            f.path.toLowerCase().endsWith('.aac') &&
            f.path.toLowerCase().contains(prefix))
        .toList();

    setState(() {
      _recordings = files;
    });
  }

  // Future<void> _loadRecordings() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final prefix = "screenunlock";
  //   final files = dir
  //       .listSync()
  //       .where((f) => f.path.endsWith('.aac') && f.path.contains(prefix))
  //       .toList();
  //   setState(() {
  //     _recordings = files;
  //   });
  // }

  Future<void> _togglePlayback(String path) async {
    if (_isPlaying && _currentPlayingPath == path) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      if (_player.isPlaying) await _player.stopPlayer();
      await _player.startPlayer(
        fromURI: path,
        whenFinished: () {
          setState(() => _isPlaying = false);
        },
      );
      setState(() {
        _currentPlayingPath = path;
        _isPlaying = true;
      });
    }
  }

  Future<void> _deleteRecording(FileSystemEntity file) async {
    await File(file.path).delete();

    final filename = path.basename(file.path);
    final referenceType = filename.replaceAll('.aac', '');

    final uri = Uri.parse('$ip_address/delete-reference/$referenceType');

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print('✅ Deleted $referenceType on server');
      } else {
        print('❌ Server deletion failed: ${response.body}');
      }
    } catch (e) {
      print('❌ API error: $e');
    }

    _loadRecordings();
  }

  Future<void> _setAsReference(File file) async {
    setState(() => isLoading = true);

    final uri = Uri.parse('$ip_address/upload-reference/');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final filename = path.basename(file.path);
    final referenceType = filename.replaceAll('.aac', '');

    request.fields['reference_type'] = referenceType;

    try {
      final response = await request.send();

      final msg = response.statusCode == 200
          ? 'Reference "$referenceType" uploaded!'
          : 'Failed to upload reference "$referenceType"';

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }

    setState(() => isLoading = false);
  }

  Widget _buildWave() {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _waveData.map((h) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _dummyWaveTimer?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  String _formatScreenUnlockFileName(String filePath) {
    final fileName = path.basename(filePath).replaceAll('.aac', '');

    final regex = RegExp(
      r'^ScreenUnlock_(\d{4}-\d{2}-\d{2})_(\d{2})-(\d{2})-(\d{2})_(AM|PM)$',
    );

    final match = regex.firstMatch(fileName);
    if (match != null) {
      final date = match.group(1)!;
      final hour = int.parse(match.group(2)!);
      final minute = int.parse(match.group(3)!);
      final second = int.parse(match.group(4)!);
      final amPm = match.group(5)!;

      int displayHour = hour;
      if (amPm == 'PM' && hour != 12) displayHour += 12;
      if (amPm == 'AM' && hour == 12) displayHour = 0;

      final dateTime = DateTime.parse(date).add(Duration(
        hours: displayHour,
        minutes: minute,
        seconds: second,
      ));

      final formattedDate = DateFormat.yMMMMd().format(dateTime);
      final formattedTime = DateFormat('h:mm:ss a').format(dateTime);

      return 'Screen Unlock – $formattedDate at $formattedTime';
    }

    return fileName.replaceAll('_', ' ');
  }

  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Color(0xff012A4A),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 35),
                child: IconButton(icon: Icon(
                  FontAwesomeIcons.arrowLeft, color:Colors.white,),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MainPage()));
                  },
                ),
              ),
              Positioned(
                top: 160,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  height: 650,
                  width: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      if (_isRecording) _buildWave(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _recordings.length,
                          itemBuilder: (context, index) {
                            final file = _recordings[index];
                            final isCurrent = _currentPlayingPath == file.path;
                            return Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: Text(
                                    _formatScreenUnlockFileName(file.path),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                IconButton(
                                  icon: Icon(
                                    isCurrent && _isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                  onPressed: () => _togglePlayback(file.path),
                                ),
                                IconButton(
                                  icon: Icon(Icons.upload_file),
                                  onPressed: () =>
                                      _setAsReference(File(file.path)),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteRecording(file),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 15,
                right: 10,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      width: 0.5,
                      color: Color(0xff012A4A),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      loc.screenUnlock,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "FontMain",
                          color: Color(0xff012A4A)),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 10,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: _isRecording ? Colors.red : Color(0xff012A4A),
                  ),
                  onPressed: !_isRecorderInitialized
                      ? null
                      : _isRecording
                          ? _stopRecording
                          : _startRecording,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
