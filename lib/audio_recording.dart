import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// const String ip_address = 'https://c927-130-211-205-253.ngrok-free.app';
const String ip_address = 'http://10.164.48.23:8000';
 //'http://192.168.18.31';

class AudioRecording2 extends StatefulWidget {
  const AudioRecording2({super.key});

  @override
  State<AudioRecording2> createState() => _AudioRecording2State();
}

class _AudioRecording2State extends State<AudioRecording2> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription? _dummyWaveTimer;
  final List<double> _waveData = [];
  List<FileSystemEntity> _recordings = [];
  String? _currentPlayingPath;

  @override
  void dispose() {
    _dummyWaveTimer?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _deleteRecording(FileSystemEntity file) async {
    await File(file.path).delete();
    _loadRecordings();
  }

  Future<void> _togglePlayback(String path) async {
    if (_isPlaying && _currentPlayingPath == path) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }
      await _player.startPlayer(
        fromURI: path,
        // codec: Codec.aacADTS, // ✅ Ensure this matches the recording codec
        whenFinished: () {
          setState(() => _isPlaying = false);
        },
      );
      setState(() {
        _isPlaying = true;
        _currentPlayingPath = path;
      });
    }
  }


  Widget _buildDummyWaveBar() {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _waveData.map((height) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: height,
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
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
    setState(() {
      _isRecorderInitialized = true;
    });
    _loadRecordings();
  }

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
  }

  Future<void> _startRecording() async {
    final path = await _getFilePath();
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
    _dummyWaveTimer = Stream.periodic(Duration(milliseconds: 100), (_) {
      final random = Random();
      setState(() {
        _waveData.add(10 + random.nextDouble() * 40);
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
    final files = dir.listSync().where((f) => f.path.endsWith('.aac')).toList();
    setState(() {
      _recordings = files;
    });
  }

  bool isLoading = false;
  Future<void> _setAsReference(File file) async {
    isLoading = true;
    setState(() {});
    final uri = Uri.parse(
        '$ip_address/upload-reference/'); // Replace with your IP
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Reference updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload reference audio")),
      );
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff012A4A),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Column(

          children: [
            const SizedBox(height: 100),
            Container(
              width: MediaQuery.of(context).size.width * 90,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color(0xff012A4A), width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    "Record Your Voice",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: _isRecording
                          ? Colors.redAccent
                          : Colors.green, // record/pause color
                    ),
                    onPressed: !_isRecorderInitialized
                        ? null
                        : _isRecording
                            ? _stopRecording
                            : _startRecording,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  if (_isRecording) _buildDummyWaveBar(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
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
                            title: Text(file.path.split('/').last),
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
                                IconButton(
                                  icon: const Icon(Icons.upload_file),
                                  tooltip: "Set as Reference",
                                  onPressed: () =>
                                      _setAsReference(File(file.path)),
                                ),
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
          ],
        ),
      ),
    );
  }
}
