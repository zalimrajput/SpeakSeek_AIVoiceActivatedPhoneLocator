import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';
import 'main_page.dart';

class AudioRecording extends StatefulWidget {
  @override
  State<AudioRecording> createState() => _AudioRecordingState();
}
//
class _AudioRecordingState extends State<AudioRecording> {
  List<FileSystemEntity> _recordings = [];
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _currentPlayingPath;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
    _player.openPlayer();
  }

  Future<void> _loadRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/unauthorized_recordings');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final files = folder
        .listSync()
        .where((f) => f.path.endsWith('.aac'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    setState(() {
      _recordings = files;
    });
  }

  Future<void> _togglePlayback(String path) async {
    if (_isPlaying && _currentPlayingPath == path) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      await _player.startPlayer(
        fromURI: path,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _currentPlayingPath = null;
          });
        },
      );
      setState(() {
        _isPlaying = true;
        _currentPlayingPath = path;
      });
    }
  }

  Future<void> _deleteRecording(FileSystemEntity file) async {
    try {
      await file.delete();
      _loadRecordings();
    } catch (e) {
      print("Failed to delete: $e");
    }
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  String _formatFileName(String filePath) {
    final fileName = filePath.split('/').last.replaceAll('.aac', '');

    // Example: Person_2025-06-27_02-45-12_PM
    final regex = RegExp(
        r'Person_(\d{4}-\d{2}-\d{2})_(\d{2})-(\d{2})-(\d{2})_(AM|PM)');

    final match = regex.firstMatch(fileName);
    if (match != null) {
      final datePart = match.group(1)!; // 2025-06-27
      final hour = int.parse(match.group(2)!);
      final minute = int.parse(match.group(3)!);
      final second = int.parse(match.group(4)!);
      final period = match.group(5)!; // AM or PM

      // Convert to 24-hour format
      int formattedHour = hour;
      if (period == 'PM' && hour < 12) {
        formattedHour += 12;
      } else if (period == 'AM' && hour == 12) {
        formattedHour = 0;
      }

      final dateTime = DateTime.parse(datePart).add(Duration(
        hours: formattedHour,
        minutes: minute,
        seconds: second,
      ));

      final formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
      final formattedTime = DateFormat('h:mm:ss a').format(dateTime);

      return 'Person – $formattedDate at $formattedTime';
    }

    // Fallback to raw filename if parsing fails
    return fileName;
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
      backgroundColor: const Color(0xff012A4A),
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(22),topRight: Radius.circular(22))
                ),
                height: MediaQuery.of(context).size.height,
                width: 360,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: _recordings.isEmpty
                      ? const Center(child: Text("No recordings yet."))
                      : ListView.builder(
                          itemCount: _recordings.length,
                          itemBuilder: (context, index) {
                            final file = _recordings[index];
                            final isCurrent = _currentPlayingPath == file.path;
                            return ListTile(
                              title: Text(_formatFileName(file.path)),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isCurrent && _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () => _togglePlayback(file.path),
                                  ),
                                  // IconButton(
                                  //     icon: const Icon(Icons.upload_file),
                                  //     tooltip: "Set as Reference",
                                  //     onPressed: () {}),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteRecording(file),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            Positioned(
              top: 100,left: 15,
              child: Container(
                height: 100,
                width: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    width: 0.5,
                    color: const Color(0xff012A4A),
                  ),
                ),
                child: Center(
                  child: Text(
                    loc.history,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
