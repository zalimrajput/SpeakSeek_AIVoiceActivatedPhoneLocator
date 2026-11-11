import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fyp/audio_recording.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // for filename handling
import 'package:fyp/left_bar.dart';
import 'package:fyp/right_bar.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';
import 'main_page.dart';

// ignore: camel_case_types
class Personalized_Voice extends StatefulWidget {
  const Personalized_Voice({super.key});

  @override
  State<Personalized_Voice> createState() => _Personalized_VoiceState();
}

// ignore: camel_case_types
class _Personalized_VoiceState extends State<Personalized_Voice> {
  String? _selectedVoiceOption;
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

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadSelectedVoiceOption();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
    setState(() => _isRecorderInitialized = true);
  }

  Future<void> _loadSelectedVoiceOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVoiceOption = prefs.getString('voice_option') ?? 'Pass Code';
    });
    _loadRecordings();
  }

  Future<void> _selectVoiceOption(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_option', option);
    setState(() => _selectedVoiceOption = option);
    _loadRecordings();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();

    final prefix = _selectedVoiceOption!.toLowerCase().replaceAll(" ", "_");

    final files = dir
        .listSync()
        .where((f) => f.path.endsWith('.aac') && f.path.contains(prefix))
        .toList();

    final maxAllowed = {
          'pass_code': 3,
          'whistle': 2,//here you can change the allowed 1 clapping whistle passcode k ref kha s bhrny h
          'clapping': 1,
        }[prefix] ??
        3;

    // ❗ Prevent new recording if limit reached
    if (files.length >= maxAllowed) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You can only record up to $maxAllowed recordings for $_selectedVoiceOption",
          ),
        ),
      );
      return;
    }

    // 🕒 Format filename with current date and time
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd_hh-mm-ss_a').format(now);

    final formattedPrefix =
        _selectedVoiceOption!.trim().replaceAll(' ', '_'); // e.g., Pass_Code

    final fileName = '${formattedPrefix}_$formattedDateTime.aac';
    final path = '${dir.path}/$fileName';

    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

    _dummyWaveTimer = Stream.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        final r = Random();
        _waveData.add(10 + r.nextDouble() * 40);
        if (_waveData.length > 30) _waveData.removeAt(0);
      });
    }).listen((_) {});

    setState(() => _isRecording = true);
  }

  // Future<void> _startRecording() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final prefix = _selectedVoiceOption!.toLowerCase().replaceAll(" ", "_");

  //   final files = dir
  //       .listSync()
  //       .where((f) => f.path.endsWith('.aac') && f.path.contains(prefix))
  //       .toList();

  //   final maxAllowed = {
  //         'pass_code': 3,
  //         'whistle': 2,
  //         'clapping': 1,
  //       }[prefix] ??
  //       3;

  //   // ❗ Prevent new recording if limit reached
  //   if (files.length >= maxAllowed) {
  //     // ignore: use_build_context_synchronously
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           "You can only record up to $maxAllowed recordings for $_selectedVoiceOption",
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   // 🟢 Proceed to record
  //   // final nextNumber = files.length + 1;
  //   // 🔄 Find lowest available slot (e.g., if 2 is deleted, reuse 2)
  //   final existingNumbers = files
  //       .map((f) => int.tryParse(
  //           RegExp(r'_(\d+)\.aac').firstMatch(f.path)?.group(1) ?? ''))
  //       .whereType<int>()
  //       .toSet();

  //   int nextNumber = 1;
  //   while (existingNumbers.contains(nextNumber)) {
  //     nextNumber++;
  //   }

  //   final path = '${dir.path}/${prefix}_$nextNumber.aac';

  //   // final path = '${dir.path}/${prefix}_$nextNumber.aac';

  //   await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

  //   _dummyWaveTimer = Stream.periodic(Duration(milliseconds: 100), (_) {
  //     setState(() {
  //       final r = Random();
  //       _waveData.add(10 + r.nextDouble() * 40);
  //       if (_waveData.length > 30) _waveData.removeAt(0);
  //     });
  //   }).listen((_) {});

  //   setState(() => _isRecording = true);
  // }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    await _dummyWaveTimer?.cancel();
    setState(() {
      _isRecording = false;
      _waveData.clear();
    });
    _loadRecordings();
  }

  // Future<void> _loadRecordings() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final prefix = _selectedVoiceOption!.toLowerCase().replaceAll(" ", "_");
  //   final files = dir
  //       .listSync()
  //       .where((f) => f.path.endsWith('.aac') && f.path.contains(prefix))
  //       .toList();
  //   setState(() {
  //     _recordings = files;
  //   });
  // }
  Future<void> _loadRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefix = _selectedVoiceOption!.toLowerCase().replaceAll(" ", "_");

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
    // 1. Delete local file
    await File(file.path).delete();

    // 2. Extract reference type from filename (e.g., pass_code_2.aac → pass_code_2)
    final filename = file.path
        .split('/')
        .last; // or use path.basename(file.path) if using package:path
    final referenceType = filename.replaceAll('.aac', ''); // removes extension

    // 3. Call FastAPI to delete server-side reference
    final uri = Uri.parse('$ip_address/delete-reference/$referenceType');

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print('✅ Deleted $referenceType on server');
      } else {
        print('❌ Server deletion failed: ${response.body}');
      }
    } catch (e) {
      print('❌ API error while deleting $referenceType: $e');
    }

    // 4. Refresh recordings list
    _loadRecordings();
  }

  Future<void> _setAsReference(File file) async {
    setState(() => isLoading = true);

    // final uri = Uri.parse('$ip_address:8000/upload-reference/');
    final uri = Uri.parse('$ip_address/upload-reference/');

    final request = http.MultipartRequest('POST', uri);

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // Extract reference_type from file name (e.g., pass_code_2.aac → pass_code_2)
    final filename =
        path.basename(file.path); // requires `import 'package:path/path.dart';`
    final referenceType = filename.replaceAll('.aac', '');

    // Add reference_type field
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

  Widget _buildVoiceCard(String label, IconData icon) {
    final isSelected = _selectedVoiceOption == label;
    return GestureDetector(
      onTap: () => _selectVoiceOption(label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(blurRadius: 2, spreadRadius: 1, color: Colors.grey),
          ],
        ),
        height: 100,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontFamily: "FontMain",
                color:
                    isSelected ? Colors.blue.shade900 : const Color(0xff012A4A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            FaIcon(icon,
                color:
                    isSelected ? Colors.blue.shade900 : const Color(0xff012A4A),
                size: 20),
          ],
        ),
      ),
    );
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

  String _formatRecordingDisplayName(String filePath) {
    final fileName = path.basename(filePath).replaceAll('.aac', '');

    // Expected format: Pass_Code_2025-06-27_02-45-12_PM
    final regex = RegExp(
      r'^(.+?)_(\d{4}-\d{2}-\d{2})_(\d{2})-(\d{2})-(\d{2})_(AM|PM)$',
    );

    final match = regex.firstMatch(fileName);
    if (match != null) {
      final rawType = match.group(1)!; // e.g., Pass_Code
      final date = match.group(2)!;
      final hour = int.parse(match.group(3)!);
      final minute = int.parse(match.group(4)!);
      final second = int.parse(match.group(5)!);
      final amPm = match.group(6)!;

      // Format type (replace _ with space and capitalize words)
      final formattedType = rawType
          .split('_')
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');

      // Build DateTime
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

      return '$formattedType – $formattedDate at $formattedTime';
    }

    // Fallback if the pattern doesn't match
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
          color: const Color(0xff012A4A),
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

              // ✅ Background bars
              Positioned(top: 240, left: 0, child: LeftBar(barWidth: 40)),
              Positioned(top: 300, left: 0, child: LeftBar(barWidth: 70)),
              Positioned(top: 360, left: 0, child: LeftBar(barWidth: 40)),
              Positioned(top: 460, right: 0, child: RightBar(barWidth: 70)),
              Positioned(top: 520, right: 0, child: RightBar(barWidth: 70)),
              Positioned(top: 620, left: 0, child: LeftBar(barWidth: 70)),

              // ✅ Main content
              Positioned(
                top: 160,
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    height: 650,
                    width: MediaQuery.of(context).size.height * 0.9,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                          SizedBox(
                            height: 180,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildVoiceCard(loc.passCode,
                                    Icons.record_voice_over_outlined),
                                _buildVoiceCard(
                                    loc.whistle, FontAwesomeIcons.person),
                                _buildVoiceCard(
                                    loc.clapping, FontAwesomeIcons.handsClapping),
                              ],
                            ),
                          ),
                        if (_isRecording) _buildWave(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recordings.length,
                            itemBuilder: (context, index) {
                              final file = _recordings[index];
                              final isCurrent =
                                  _currentPlayingPath == file.path;
                              return ListTile(
                                title: Wrap(
                                  spacing: 8,
                                  children: [
                                    SizedBox(
                                      width: 170,
                                      height: 100,
                                      child: Text(_formatRecordingDisplayName(
                                          file.path.split('/').last)),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        isCurrent && _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      onPressed: () =>
                                          _togglePlayback(file.path),
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
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ Title box at top
              Positioned(
                top: 100,
                left: 15,
                right: 10,
                child: Container(
                  height: 100,
                  width: 330,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      width: 0.5,
                      color: const Color(0xff012A4A),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc.voiceEnrollment,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "FontMain",
                              color: Color(0xff012A4A))),
                      Text(loc.reorganization,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "FontMain",
                              color: Color(0xff012A4A))),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 10,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
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
