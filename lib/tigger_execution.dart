import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'left_bar.dart';
import 'main.dart';
import 'main_page.dart';
import 'right_bar.dart';

class TiggerExecution extends StatefulWidget {
  @override
  State<TiggerExecution> createState() => _TiggerExecutionState();
}

class _TiggerExecutionState extends State<TiggerExecution> {
  String? _selectedTrigger;
  String? _selectedRingtone;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTrigger = prefs.getString('trigger') ?? '';
      _selectedRingtone = prefs.getString('ringtone') ?? '';
      _isVibrateOn = prefs.getBool('vibrate_on') ?? false;
      _isFlashOn = prefs.getBool('flash_on') ?? false;
    });
  }

  Future<void> _selectTrigger(String trigger) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('trigger', trigger);
    setState(() {
      _selectedTrigger = trigger;
    });
  }

  Future<void> _selectRingtone(String ringtone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ringtone', ringtone);
    setState(() {
      _selectedRingtone = ringtone;
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  bool _isPlaying = false;

  Future<void> _togglePlay(String ringtone) async {
    if (_currentlyPlaying == ringtone && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.stop(); // Stop any previous playback

      // Simulate ringtone playback (you must replace with actual paths later)
      String assetPath = "assets/ringtones/$ringtone.mp3";
      await _audioPlayer.setAsset((assetPath));
      setState(() {
        _currentlyPlaying = ringtone;
        _isPlaying = true;
      });
      await _audioPlayer.play();
      setState(() {
        _currentlyPlaying = null;
        _isPlaying = false;
      });
    }
  }

  final List<String> _ringtones = [
    'Badinerie',
    'Caprice',
    'Crickety',
    'Critter',
    'Dizzy',
    'Entertainer',
    'Espionage',
    'Etude',
    'Fuga',
    'Going Up',
    'Groovy Blue',
    'Hat Dance',
    'Hopping Down',
    'Intro',
    'Jingle Bells',
    'Jumping',
    'Kick',
    'Long Scale',
    'Low',
    'Merry XMas',
    'Minuet',
    'Nokia Tune',
    'Persuasion',
    'Playground',
    'Polska',
    'Raptrap',
    'Ring Ring',
    'Rocket',
    'Rote',
    'Samba',
    'Sity Bird',
    'Spiral',
    'Tap Dance',
    'Tchaikovsky',
    'Technoe',
    'Thats It',
    'Toreador 1',
    'Trio',
    'William Tell',
  ];
  bool _isVibrateOn = false;
  bool _isFlashOn = false;
  Future<void> _toggleVibrate(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrate_on', value);
    setState(() {
      _isVibrateOn = value;
    });
  }

  Future<void> _toggleFlash(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flash_on', value);
    setState(() {
      _isFlashOn = value;
    });
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
      body: Container(
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

            Positioned(
              top: 160,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                height: 650,
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: [
                            _buildTriggerCard(
                                loc.ring, Icons.phonelink_ring_outlined),
                            _buildTriggerCard(
                                loc.vibrate, FontAwesomeIcons.viber),
                            _buildTriggerCard(
                                loc.flash, FontAwesomeIcons.lightbulb),
                          ],
                        ),
                      ),
                      if (_selectedTrigger == "Ring") ...[
                        const SizedBox(height: 20),
                        Text(
                          loc.selectRingtone,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff012A4A)),
                        ),
                        ..._ringtones.map((ringtone) {
                          return ListTile(
                            title: Text(
                              ringtone,
                              style: const TextStyle(fontSize: 14),
                            ),
                            leading: IconButton(
                              icon: Icon(
                                _currentlyPlaying == ringtone && _isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () => _togglePlay(ringtone),
                            ),
                            trailing: _selectedRingtone == ringtone
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () => _selectRingtone(ringtone),
                          );
                        })
                      ],
                      if (_selectedTrigger == "Vibrate") ...[
                        const SizedBox(height: 20),
                        ListTile(
                          title:  Text(
                            loc.vibrateTrigger,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff012A4A),
                            ),
                          ),
                          trailing: Switch(
                            value: _isVibrateOn,
                            onChanged: _toggleVibrate,
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                      if (_selectedTrigger == "Flash") ...[
                        const SizedBox(height: 20),
                        ListTile(
                          title:  Text(
                            loc.flashTrigger,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff012A4A),
                            ),
                          ),
                          trailing: Switch(
                            value: _isFlashOn,
                            onChanged: _toggleFlash,
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 100, left: 15, right: 10),
              child: Positioned(
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
                  child:  Center(
                    child: Text(
                      loc.triggerExecution,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "FontMain",
                        color: Color(0xff012A4A),
                      ),
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

  Widget _buildTriggerCard(String label, IconData icon) {
    bool isSelected = _selectedTrigger == label;

    return GestureDetector(
      onTap: () {
        _selectTrigger(label);
      },
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
            FaIcon(
              icon,
              color:
                  isSelected ? Colors.blue.shade900 : const Color(0xff012A4A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
