// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fyp/security.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:flutter/src/rendering/box.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/alert.dart';
import 'package:fyp/audio_recording.dart';
import 'package:fyp/audio_recording_2.dart';
import 'package:fyp/mobile_tracking.dart';
import 'package:fyp/personalize_voice.dart';
import 'package:fyp/screen_lock.dart';
import 'package:fyp/screen_unlock.dart';
import 'package:fyp/services/lock_screen.dart';
import 'package:fyp/tigger_execution.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart' as audi;

import 'guideline.dart';
import 'intro_page.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

enum VoiceIntent { hello, lock, unlock, none }

class MainPage extends StatefulWidget {



  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, dynamic>> sliderMap = [
    {
      "images":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHA1qM97slzkaIjh0so6FUpyMjVhOpc5kdBwPe1y36u3uY2FWcPoxF5O3i17z9BvV18pU&usqp=CAU",
    },
    {
      "images":
          "https://static.vecteezy.com/system/resources/previews/023/133/977/non_2x/voice-assistant-personal-assistant-and-voice-recognition-technology-concept-microphone-button-with-voice-and-sound-imitation-lines-closeup-smartphone-in-wireframe-hands-illustration-vector.jpg",
    },
    {
      "images":
          "https://img.freepik.com/premium-vector/personal-data-protection-business-concept-cyber-security-fingerprint-with-padlock-icon-private-secure-safety-closeup-smartphone-wireframe-hands-vector-illustration_127544-1719.jpg",
    },
    {
      "images":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7ZzcUXbtWbiv-X2NruBnkQPp_92ZTawdV9w&s",
    },
    {
      "images":
          "https://img.freepik.com/premium-vector/dms-document-management-data-system-corporate-data-management-system-privacy-data-protection-business-internet-technology-concept-closeup-smartphone-wireframe-hand-vector-illustration_127544-2058.jpg",
    },
  ];
  late final PageController pageController;

  final User? user = FirebaseAuth.instance.currentUser;


  signout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                IntroPage()));
    // Also sign out from Google to clear cached account
    await GoogleSignIn().signOut();
    // Optionally disconnect to remove permissions
    await GoogleSignIn().disconnect();

  }

  final service = FlutterBackgroundService();

  final FlutterSoundRecorder _recorderA = FlutterSoundRecorder();
  final FlutterSoundRecorder _recorderB = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _useRecorderA = true; // Toggle flag for A/B
  bool _isRecorderAOpen = false;
  bool _isRecorderBOpen = false;

  Future<void> _initRecorders() async {
    await Permission.microphone.request();

    if (!_isRecorderAOpen) {
      await _recorderA.openRecorder();
      _isRecorderAOpen = true;
    }

    if (!_isRecorderBOpen) {
      await _recorderB.openRecorder();
      _isRecorderBOpen = true;
    }
  }

  // Future<void> _initRecorders() async {
  //   await Permission.microphone.request();

  //   await _recorderA.openRecorder();
  //   await _recorderB.openRecorder();
  // }

  void initializeService() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: (value) => onServiceStarted('a', serviceType: value),
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        initialNotificationTitle: 'Voice Recorder Service',
        initialNotificationContent: 'Recording in background...',
        foregroundServiceNotificationId: 888, // Any unique ID
        notificationChannelId: 'voice_recording_channel',
        foregroundServiceTypes: [
          AndroidForegroundType.microphone,
          AndroidForegroundType.dataSync,
        ],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
      ),
    );
    service.invoke("disableBatteryOptimizations");
  }

  void onServiceStarted(String type, {ServiceInstance? serviceType}) {
    // if (service is AndroidServiceInstance) {
    if (type == 'recording') {
      // final recorder = FlutterSoundRecorder();
      // recorder.openRecorder();
      // _startRollingRecording(
      //   voiceType: voiceType(_selectedVoiceOption), // or 'whistle', 'clapping'
      //   expectedPhrase: 'where is my phone',
      // );
      // service.on('stopRecording').listen((event) async {
      //   await recorder.stopRecorder();
      //   await recorder.closeRecorder();
      // });

      _initRecorders().then((_) {
        _startDualRecorderLoop(
          voiceType: voiceType(_selectedVoiceOption),
          expectedPhrase: 'where is my phone',
        );
      });
      // _startDualRecorderLoop(
      //   voiceType: voiceType(_selectedVoiceOption),
      //   expectedPhrase: 'where is my phone',
      // );

      print("Recorder started in background service");
      print("Recorder has been started");
    } else if (type == 'a') {
    } else if (type == 'alert') {
      _startListening();
    }
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );
    _initRecorders();

    _init();

    initializeService();
  }

  Future<void> _startDualRecorderLoop({
    required String voiceType,
    required String expectedPhrase,
  }) async {
    _isRecording = true;
    setState(() {});
    while (_isRecording) {
      final FlutterSoundRecorder activeRecorder =
          _useRecorderA ? _recorderA : _recorderB;

      final chunkPath = await _generateChunkPath();
      print(
          "[DEBUG] Starting recording on ${_useRecorderA ? 'Recorder A' : 'Recorder B'}");

      await activeRecorder.startRecorder(
          toFile: chunkPath, codec: Codec.aacADTS);

      // Wait for 3 seconds while recording
      await Future.delayed(Duration(seconds: 3));

      await activeRecorder.stopRecorder();
      print(
          "[DEBUG] Stopped recording on ${_useRecorderA ? 'Recorder A' : 'Recorder B'}");

      final recordedFile = File(chunkPath);

      // Start the other recorder immediately while sending current file
      final FlutterSoundRecorder nextRecorder =
          _useRecorderA ? _recorderB : _recorderA;
      final nextChunkPath = await _generateChunkPath();

      await nextRecorder.startRecorder(
          toFile: nextChunkPath, codec: Codec.aacADTS);

      // Send current file to server (non-blocking)
      // _sendChunk(recordedFile,
      //     voiceType: voiceType, expectedPhrase: expectedPhrase);

      await _processVoice(recordedFile,
          voiceType: voiceType, expectedPhrase: 'hello');

      // Wait 3 seconds while next recorder is running
      await Future.delayed(Duration(seconds: 3));

      await nextRecorder.stopRecorder();
      print(
          "[DEBUG] Stopped recording on ${_useRecorderA ? 'Recorder B' : 'Recorder A'}");

      final nextRecordedFile = File(nextChunkPath);

      // Swap flag for next loop
      _useRecorderA = !_useRecorderA;

      // Send the second file
      await _processVoice(nextRecordedFile,
          voiceType: voiceType, expectedPhrase: 'hello');
      // _sendChunk(nextRecordedFile,
      //     voiceType: voiceType, expectedPhrase: expectedPhrase);
    }
  }

  void _toggleRecording() async {
    await _loadSelectedVoiceOption();

    if (_isRecording) {
      service.invoke("stop");

      await _stopDualRecording();
      // Fluttertoast.showToast(msg: 'Recording stopped');
      Fluttertoast.showToast(msg: 'Speek Seek has been deactivated');
    } else {
      onServiceStarted('recording');
      // Fluttertoast.showToast(msg: 'Recording started');
      Fluttertoast.showToast(msg: 'Speek Seek has been activated');
    }
  }

  // void _toggleRecording() async {
  //   await _loadSelectedVoiceOption();

  //   if (_isRecording) {
  //     service.invoke("stop");
  //     _stopRollingRecording();
  //     Fluttertoast.showToast(msg: 'Speek Seek has been deactivated');
  //   } else {
  //     onServiceStarted('recording');
  //     Fluttertoast.showToast(msg: 'Speek Seek has been activated');
  //   }
  // }

  Future<void> _stopDualRecording() async {
    _isRecording = false;

    if (_recorderA.isRecording) {
      await _recorderA.stopRecorder();
    }
    if (_recorderB.isRecording) {
      await _recorderB.stopRecorder();
    }

    if (_isRecorderAOpen) {
      await _recorderA.closeRecorder();
      _isRecorderAOpen = false;
    }
    if (_isRecorderBOpen) {
      await _recorderB.closeRecorder();
      _isRecorderBOpen = false;
    }
  }

  // Future<void> _stopDualRecording() async {
  //   _isRecording = false;

  //   if (_recorderA.isRecording) {
  //     await _recorderA.stopRecorder();
  //   }
  //   if (_recorderB.isRecording) {
  //     await _recorderB.stopRecorder();
  //   }

  //   await _recorderA.closeRecorder();
  //   await _recorderB.closeRecorder();
  // }

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription? _dummyWaveTimer;
  String? _filePath;
  Timer? _timer;
  String? _currentChunkPath;

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<String> _generateChunkPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'chunk_${DateTime.now().millisecondsSinceEpoch}.aac';
    return p.join(dir.path, fileName);
  }

  // Future<void> _startRollingRecording(
  //     {required String voiceType, required String expectedPhrase}) async {
  //   _isRecording = true;

  //   while (_isRecording) {
  //     // 1. Record chunk for 3–5 seconds
  //     final chunkPath = await _generateChunkPath();
  //     await _recorder.startRecorder(toFile: chunkPath, codec: Codec.aacADTS);

  //     await Future.delayed(Duration(seconds: 5)); // Record duration

  //     await _recorder.stopRecorder();
  //     // await Permission.microphone.request();
  //     // await _recorder.openRecorder();
  //     print("im recording man HHAHA ${await Permission.microphone.isGranted}");

  //     final recordedFile = File(chunkPath);

  //     if (recordedFile.existsSync()) {
  //       // 2. Immediately start recording the next chunk (in background)
  //       final nextChunkPath = await _generateChunkPath();
  //       _recorder.startRecorder(toFile: nextChunkPath, codec: Codec.aacADTS);

  //       // 3. Send previous chunk (without awaiting next recording)
  //       await _sendChunk(
  //         recordedFile,
  //         voiceType: voiceType,
  //         expectedPhrase: expectedPhrase,
  //       );

  //       await _recorder.stopRecorder(); // Stop next chunk before loop restarts
  //     }
  //   }

  //   setState(() {});
  // }

  AudioPlayer player = AudioPlayer();

  bool _isAlarmPlaying = false;

  Future<void> _triggerAlarmSequence() async {
    if (_isAlarmPlaying) {
      print("[DEBUG] Alarm already playing, ignoring new trigger.");
      return;
    }
    _isAlarmPlaying = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final trigger = prefs.getString('trigger') ?? 'Ring'; // default to Ring
      final ringtone = prefs.getString('ringtone') ?? 'alert'; // default sound

      print("[DEBUG] Trigger selected: $trigger");
      print("[DEBUG] Ringtone selected: $ringtone");

      // Only Vibrate
      if (trigger == 'Vibrate') {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 10000);
        }
      }

      // Only Flash
      if (trigger == 'Flash') {
        if (await TorchLight.isTorchAvailable()) {
          TorchLight.enableTorch();
          await Future.delayed(Duration(seconds: 10));
          TorchLight.disableTorch();
        }
      }

      // Only Ring
      if (trigger == 'Ring') {
        // audi.AudioPlayer players = audi.AudioPlayer();
        // await players.play(audi.AssetSource('ringtones/$ringtone.mp3'));
        await player.setAsset('assets/ringtones/$ringtone.mp3');

        player.play();
        await Future.delayed(Duration(seconds: 10));
        await player.stop();
      }
    } catch (e) {
      print("Alarm error: $e");
    } finally {
      _isAlarmPlaying = false;
    }
  }

  Future<void> _stopRollingRecording() async {
    _isRecording = false;
    _timer?.cancel();
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    setState(() {});
    initializeService();
  }

  Future<void> _sendChunk(File file,
      {required String voiceType, String expectedPhrase = ''}) async {
    try {

      print("voice Type is $voiceType");
      var uri;

      if (voiceType == 'whistle' || voiceType == 'clapping') {
        uri = Uri.parse('$ip_address/verify-voice-resenblyzer/');
      } else {
        uri = Uri.parse('$ip_address/verify-voice/');
      }

      // final uri = Uri.parse('$ip_address/transcribe-voice/');

      // final uri = Uri.parse('$ip_address/verify-voice2/');

      // final uri = Uri.parse('$ip_address:8000/verify-voice-with-whistle/');

      final request = http.MultipartRequest('POST', uri);

      // Attach file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Attach form fields
      request.fields['voice_type'] = voiceType;
      if (voiceType == 'pass_code') {
        request.fields['expected_phrase'] = expectedPhrase;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("results are ${responseBody} voiceType is $voiceType uri is $uri");

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        print("results are $result file.path is ${file.path}");

        final authorized = result['authorized'] ?? false;
        final message = authorized ? "✅ Authorized" : "❌ Not Authorized";

        if (authorized && voiceType == 'screen_lock') {
          LockService.lockScreen();
          return;
        }
        if (authorized && voiceType == 'screen_unlock') {
          LockService.wakeScreen();
          return;
        }
        if (authorized) {
          await _triggerAlarmSequence();

          //  _stopRollingRecording(); // 👈 stop further checks
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: Duration(seconds: 1)),
        );

        if (authorized) {
          LockService.wakeScreen();
          _triggerAlarmSequence();
        } else {
          await _storeUnauthorizedRecording(file);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Server Error")),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<VoiceIntent> _shouldVerifyVoice(File file) async {
    try {
      print('Transcription Response entry');
      final uri = Uri.parse('$ip_address/transcribe-voice/');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Transcription Response: $responseBody");

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        String? transcription = result['transcription'];

        if (transcription == null) return VoiceIntent.none;

        transcription = transcription.toLowerCase();

        // Normalize by removing punctuation
        final cleaned = transcription.replaceAll(RegExp(r'[^\w\s]'), '');
        print("Normalized transcription: $cleaned");

        // Match intents
        if (cleaned.contains("hello")) {
          return VoiceIntent.hello;
        } else if (cleaned.contains("unlock")) {
          return VoiceIntent.unlock;
        } else if (cleaned.contains("lock")) {
          return VoiceIntent.lock;
        } else {
          return VoiceIntent.none;
        }
      } else {
        print("Transcription failed");
        return VoiceIntent.none;
      }
    } catch (e) {
      print("Transcription error: $e");
      return VoiceIntent.none;
    }
  }

  // 1. Transcribe voice and check if it says "hello"
  // Future<bool> _shouldVerifyVoice(File file) async {
  //   try {
  //     print('Transcription Response entry');
  //     final uri = Uri.parse('$ip_address/transcribe-voice/');
  //     final request = http.MultipartRequest('POST', uri);
  //     request.files.add(await http.MultipartFile.fromPath('file', file.path));

  //     final response = await request.send();
  //     final responseBody = await response.stream.bytesToString();

  //     print("Transcription Response: $responseBody");

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(responseBody);
  //       String? transcription = result['transcription'];

  //       if (transcription == null) return false;

  //       transcription = transcription.toLowerCase();

  //       // Normalize by removing punctuation
  //       final cleaned = transcription.replaceAll(RegExp(r'[^\w\s]'), '');

  //       print("Normalized transcription: $cleaned");

  //       // Check if 'hello' is found as a word
  //       return cleaned.split(' ').contains('hello');

  //       // return cleaned.split(' ').contains('hello');
  //     } else {
  //       print("Transcription failed");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Transcription error: $e");
  //     return false;
  //   }
  // }

// 3. Combined flow function
  // Future<void> _processVoice(File file,
  //     {required String voiceType, String expectedPhrase = ''}) async {
  //   final shouldVerify = await _shouldVerifyVoice(file);

  //   if (shouldVerify) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Yes Voice command matched')"),
  //       ),
  //     );
  //     await _sendChunk(file,
  //         voiceType: voiceType, expectedPhrase: expectedPhrase);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("❌ Voice command not matched (expected: 'hello')"),
  //       ),
  //     );
  //     if (file.existsSync()) {
  //       file.deleteSync();
  //     }
  //   }
  // }

  Future<void> _processVoice(File file,
      {required String voiceType, String expectedPhrase = ''}) async {
    if (voiceType == 'pass_code') {
      final intent = await _shouldVerifyVoice(file);

      switch (intent) {
        case VoiceIntent.hello:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Voice command matched: hello")),
          );
          await _sendChunk(file,
              voiceType: voiceType, expectedPhrase: expectedPhrase);
          break;

        case VoiceIntent.lock:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🔒 Lock screen command detected")),
          );
          // LockService.lockScreen(); // You'll need to implement this
          await _sendChunk(file,
              voiceType: 'screen_lock', expectedPhrase: expectedPhrase);
          break;

        case VoiceIntent.unlock:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🔓 Unlock screen command detected")),
          );
          await _sendChunk(file,
              voiceType: 'screen_unlock', expectedPhrase: expectedPhrase);
          // LockService.wakeScreen();
          break;

        case VoiceIntent.none:
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ No valid voice command matched")),
          );
          if (file.existsSync()) {
            file.deleteSync();
          }
      }
    } else {
      await _sendChunk(file,
          voiceType: voiceType, expectedPhrase: expectedPhrase);
    }
  }

  // Future<void> _storeUnauthorizedRecording(File sourceFile) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final folder = Directory('${dir.path}/unauthorized_recordings');

  //     if (!await folder.exists()) {
  //       await folder.create(recursive: true);
  //     }

  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     final fileName = 'unauth_$timestamp.aac';

  //     final newPath = '${folder.path}/$fileName';
  //     final newFile = await sourceFile.copy(newPath);

  //     print('[DEBUG] Unauthorized recording saved to ${newFile.path}');
  //   } catch (e) {
  //     print('[ERROR] Failed to save unauthorized recording: $e');
  //   }
  // }

  Future<void> _storeUnauthorizedRecording(File sourceFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/unauthorized_recordings');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final now = DateTime.now();
      final formattedDateTime = DateFormat('yyyy-MM-dd_hh-mm-ss_a').format(now);
      final fileName = 'Person_$formattedDateTime.aac';

      final newPath = '${folder.path}/$fileName';
      final newFile = await sourceFile.copy(newPath);

      print('[DEBUG] Unauthorized recording saved to ${newFile.path}');
    } catch (e) {
      print('[ERROR] Failed to save unauthorized recording: $e');
    }
  }

  var _selectedVoiceOption = '';
  Future<void> _loadSelectedVoiceOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVoiceOption = prefs.getString('voice_option') ?? 'Pass Code';
    });
    print("_selectedVoiceOption is $_selectedVoiceOption");
  }

  String voiceType(String value) {
    if (value == 'Pass Code') return 'pass_code';
    if (value == 'Whistle') return 'whistle';
    if (value == 'Clapping') return 'clapping';
    return '';
  }

  bool _isActivated = false;
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  DateTime? _lastTriggeredTime;

  void _startListening() async {
    print("sensor has been started");
    _subscription = userAccelerometerEvents.listen((event) async {
      double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      if (acceleration > 1.5) {
        if (_lastTriggeredTime == null ||
            DateTime.now().difference(_lastTriggeredTime!) >
                Duration(seconds: 10)) {
          _lastTriggeredTime = DateTime.now();

          print("[DEBUG] Movement detected! Triggering alarm.");
          await _triggerAlarmSequence(); // prevent overlapping
        } else {
          print("[DEBUG] Movement ignored - cooldown active.");
        }
      }
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
    initializeService();
  }

  void _toggleActivation() {
    setState(() {
      _isActivated = !_isActivated;
      if (_isActivated) {
        onServiceStarted('alert');
      } else {
        _stopListening();
      }
    });
  }

  @override
  void dispose() {
    _dummyWaveTimer?.cancel();
    _recorder.closeRecorder();
    _recorderA.closeRecorder();
    _recorderB.closeRecorder();
    _stopListening();
    super.dispose();
  }

  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    double xOffset = 0;
    double yOffset = 0;
    bool isDrawerOpen = false;

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu_open_rounded,
                color: Color(0xff012A4A),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              height: 100,
              width: 360,
              //color: Color(0xff012A4A),
              color: Colors.white,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      width: 100,
                      margin: EdgeInsets.only(left: 50,right: 10),
                      child: Column(
                        children: [
                          Text(
                            loc.welcome,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: "FontMain",
                                color: Color(0xff012A4A),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            loc.speakSeek,
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "FontMain",
                                color: Color(0xff012A4A)),
                          ),
                        ],
                      )),
                  // Container(
                  //   width: 50,
                  //   margin: EdgeInsets.only(left: 150, bottom: 100, top: 20),
                  //   child: Builder(
                  //     builder: (context) => IconButton(
                  //       icon: Icon(
                  //         Icons.menu_open_rounded,
                  //         color: Color(0xff012A4A),
                  //       ),
                  //       onPressed: () {
                  //         Scaffold.of(context).openDrawer();
                  //       },
                  //     ),
                  //   ),
                  //
                  //   // Scaffold.of(context).openDrawer();
                  // ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              child: Container(
                height: 650,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23)),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Center(
                      //   child: GestureDetector(
                      //     onTap: _toggleRecording,
                      //     child: Container(
                      //       width: 100,
                      //       height: 100,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         gradient: RadialGradient(
                      //           colors: _isRecording
                      //               ? [Colors.red, Colors.red.shade900]
                      //               : [Colors.green, Colors.green.shade900],
                      //         ),
                      //       ),
                      //       child: Icon(
                      //         Icons.power_settings_new,
                      //         color: Colors.white,
                      //         size: 40,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 30,
                      ),
                      // Text(
                      //   "Turn ON to Secure your Phone & Secure your Future",
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //       fontSize: 15,
                      //       fontFamily: "FontMain",
                      //       color: Color(0xff012A4A)),
                      // ),
                      Text(
                        loc.securePhone,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "FontMain",
                            color: Color(0xff012A4A)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: 5,
                          controller: pageController,
                          itemBuilder: (_, index) {
                            return AnimatedBuilder(
                              animation: pageController,
                              builder: (context, child) {
                                return child!;
                              },

                              child: Container(
                                margin: EdgeInsets.all(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    "${sliderMap.elementAt(index)['images']}",
                                    fit: BoxFit.cover,
                                    height: 250,
                                  ),
                                ),
                              ),

                              // child: Container(
                              //   margin: EdgeInsets.only(top: 30,left: 12,right: 12,bottom: 12),
                              //   height: 200,
                              //  // width: 200,
                              //   decoration: BoxDecoration(
                              //     color: Color(0xff012A4A),
                              //     boxShadow:[
                              //       BoxShadow(
                              //         blurRadius: 2,
                              //         spreadRadius: 1,
                              //         color: Colors.grey,
                              //       ),
                              //     ],
                              //     borderRadius: BorderRadius.all(Radius.circular(24)),
                              //     // image: DecorationImage(image: AssetImage("assets/images/voicees.PNG"),
                              //     //         fit:BoxFit.cover,
                              //     // ),
                              //
                              //   ),
                              //
                              // ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Text(
                                loc.categories,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: "FontMain",
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff012A4A)),
                              ),
                              SizedBox(height: 10),
                              Container(
                                  margin: EdgeInsets.only(left: 0),
                                  child: Text(
                                    loc.provide,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "FontMain",
                                        color: Color(0xff012A4A)),
                                  )),
                              Text(
                                loc.unique,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "FontMain",
                                    color: Color(0xff012A4A)),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 5, bottom: 5, left: 12, right: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            color: Colors.white,
                            border: Border.all(width: 0.5, color: Colors.black),
                          ),
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Column(
                                children: [
                                  // Center(
                                  //   child: GestureDetector(
                                  //     onTap: _toggleRecording,
                                  //     child: Container(
                                  //       width: 100,
                                  //       height: 100,
                                  //       decoration: BoxDecoration(
                                  //         shape: BoxShape.circle,
                                  //         gradient: RadialGradient(
                                  //           colors: _isRecording
                                  //               ? [Colors.red, Colors.red.shade900]
                                  //               : [Colors.green, Colors.green.shade900],
                                  //         ),
                                  //       ),
                                  //       child: Icon(
                                  //         Icons.power_settings_new,
                                  //         color: Colors.white,
                                  //         size: 40,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  InkWell(
                                    onTap: _toggleRecording,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 0, bottom: 5, right: 5, top: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          // color: Color(0xff012A4A),
                                          gradient: RadialGradient(
                                            colors: _isRecording
                                                ? [
                                                    Colors.red,
                                                    Colors.red.shade900
                                                  ]
                                                : [
                                                    Colors.green,
                                                    Colors.green.shade900
                                                  ],
                                          ),
                                          border: Border.all(
                                              width: 0.5, color: Colors.black)),
                                      child:
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.power_settings_new,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Text(
                                      _isRecording ? loc.deActive : loc.active,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),



                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Personalized_Voice()));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 0, bottom: 5, right: 5, top: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          color: Color(0xff012A4A),
                                          border: Border.all(
                                              width: 0.5, color: Colors.black)),
                                      child:
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.record_voice_over_outlined,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Text(
                                      loc.personalize,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),



                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TiggerExecution()));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 5, bottom: 5, left: 5, top: 5),
                                      decoration: BoxDecoration(
                                        color: Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.ring_volume_outlined,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    loc.triggerExecution,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: "FontMain",
                                        color: Color(0xff012A4A)),
                                  )
                                ],
                              ),




                              Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScreenLock()));

                                      // LockService.lockScreen();
                                      // await LockService
                                      //     .lockScreen(); // Screen turns off

                                      // await LockService.acquireWakeLock();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 0, bottom: 5, right: 0, top: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        color: Color(0xff012A4A),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                          // Column(
                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                          //   children: [
                                          //
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.screen_lock_portrait_outlined,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      loc.screenLock,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),



                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScreenUnlock()));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 5, bottom: 5, left: 0, top: 5),
                                      decoration: BoxDecoration(
                                        color: Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                      Padding(
                                            padding: const EdgeInsets.all(18),
                                         child: Icon(
                                           FontAwesome.mobile_screen,
                                           color: Colors.white,
                                           size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Text(
                                      loc.screenUnlock,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),




                              Column(
                                children: [
                                  InkWell(
                                    onTap: _toggleActivation,
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: _isActivated
                                            ? Colors.green
                                            : Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    loc.alertSystem,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: "FontMain",
                                        color: Color(0xff012A4A)),
                                  )
                                ],
                              ),




                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AudioRecording()));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 20,
                                          bottom: 5,
                                          left: 15,
                                          top: 5),
                                      decoration: BoxDecoration(
                                        color: Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.multitrack_audio_outlined,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right:3,left :2),
                                    child: Text(
                                      loc.history,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),





                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _toggleLanguage(context);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 0, bottom: 5, right: 5, top: 5),
                                      decoration: BoxDecoration(
                                        color: Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                          Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.switch_access_shortcut_add,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Text(
                                      loc.switchLanguage,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "FontMain",
                                          color: Color(0xff012A4A)),
                                    ),
                                  )
                                ],
                              ),





                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MobileTracking()));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: 5,
                                        bottom: 5,
                                        left: 5,
                                        top: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xff012A4A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        border: Border.all(
                                            width: 0.5, color: Colors.black),
                                      ),
                                      child:
                                      Padding(
                                          padding: const EdgeInsets.all(18),
                                        child: Icon(
                                          CupertinoIcons.location_solid,
                                           color: Colors.white,
                                           size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    loc.mobileLocation,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: "FontMain",
                                      color: Color(0xff012A4A),
                                    ),
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        loc.thankYou,
                         style: TextStyle(
                            fontSize: 18,
                            fontFamily: "FontMain",
                            color: Color(0xff012A4A)
                         ),
                      ),

                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user?.displayName ?? 'Guest'),
                    accountEmail: Text(user?.email ?? 'No email'),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    decoration: BoxDecoration(color:Color(0xff012A4A)),
                  ),
                ]
            ),

            SizedBox(height: 30),

            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainPage()));
              },
              leading: Icon(
                Icons.home,
                color: Color(0xff012A4A),
              ),
              title: Text(loc.home,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A))),
            ),

            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Guideline ()));
              },
              leading: Icon(
                Icons.file_copy_outlined,
                color: Color(0xff012A4A),
              ),
              title: Text(loc.guideLine,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A))),
            ),

            ListTile(
              onTap: signout,
              leading: Icon(
                Icons.logout_outlined,
                color: Color(0xff012A4A),
              ),
              title: Text(loc.logout,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A))),
            ),


            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Security()));
              },
              leading: Icon(
                Icons.security,
                color: Color(0xff012A4A),
              ),
              title: Text(loc.security,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Color(0xff012A4A))),
            ),
          ],
        ),
      ),
    );
  }
}
