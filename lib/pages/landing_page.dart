import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_page.dart';


class ChatSession {
  final String title;
  final List<Map<String, String>> messages;

  ChatSession({required this.title, required this.messages});
}

class LandingPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const LandingPage({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatSession> _sessions = [];
  List<Map<String, String>> _currentChat = [];
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String? _weatherInfo;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _startNewSession();
  }

  void _startNewSession() {
    setState(() {
      _currentChat = [];
      _sessions.add(ChatSession(title: 'New chat', messages: _currentChat));
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _currentChat.add({'sender': 'user', 'message': text});
        final botReply = 'You said: "$text"';
        _currentChat.add({'sender': 'bot', 'message': botReply});
        _flutterTts.speak(botReply);

        if (_sessions.last.title == 'New chat') {
          final shortTitle = text.length > 20 ? '${text.substring(0, 20)}...' : text;
          _sessions[_sessions.length - 1] = ChatSession(title: shortTitle, messages: _currentChat);
        }
      });
      _controller.clear();
    }
  }

  void _handleVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: ${error.errorMsg}')),
          );
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _controller.clear();
        });

        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                _controller.text = result.recognizedWords;
              });
              _handleSend();
            }
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: false,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 20),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎤 Listening...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🛑 Stopped listening')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getWeather({double? lat, double? lon, String? city}) async {
  const apiKey = 'cba3680db8e8da96324d022078a073c6'; // replace this
  final url = city != null
      ? Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric')
      : Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

  print('Requesting: $url'); // 👈 print full URL

  final response = await http.get(url);
  print('Status Code: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final temp = data['main']['temp'];
    final condition = data['weather'][0]['description'];
    final locationName = data['name'];
    return '$locationName: ${temp.round()}°C, ${condition[0].toUpperCase()}${condition.substring(1)}';
  } else {
    final error = json.decode(response.body);
    throw 'Weather error: ${error['message']}';
  }
}
  void _showWeather() async {
  final controller = TextEditingController();
  String dialogText = 'Fetching weather...';

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent, // No dim background
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 182, 178, 235), // Light purple
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Weather Info',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B076A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogText,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black), // Typed text
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: Colors.black), // Hint text
                  filled: true,
                  fillColor: Color.fromARGB(255, 188, 187, 197),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
            ),
            TextButton(
              onPressed: () async {
                final city = controller.text.trim();
                if (city.isNotEmpty) {
                  try {
                    final cityWeather = await _getWeather(city: city);
                    setState(() => _weatherInfo = cityWeather);
                    setStateDialog(() => dialogText = cityWeather);
                  } catch (e) {
                    setStateDialog(() => dialogText = e.toString());
                  }
                }
              },
              child: const Text('Search', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        ),
      );
    },
  );

  // Fetch and show current location-based weather
  try {
    final pos = await _determinePosition();
    final info = await _getWeather(lat: pos.latitude, lon: pos.longitude);
    setState(() => _weatherInfo = info);

    if (context.mounted) {
      dialogText = info;
    }
  } catch (e) {
    if (context.mounted) {
      dialogText = 'Failed to fetch location weather: ${e.toString()}';
    }
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF6C50A1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E78C6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Yes', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E78C6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('No', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}




  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurpleAccent : Colors.deepPurple.shade700.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade800.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ask anything',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    onSubmitted: (_) => _handleSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: _isListening ? Colors.redAccent : Colors.white,
                ),
                onPressed: _handleVoiceInput,
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _showWeather,
              child: Chip(
                label: const Text('Weather'),
                backgroundColor: Colors.deepPurpleAccent,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (_weatherInfo != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _weatherInfo!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'By messaging Ausgrid AI, you agree to our Terms and have read our Privacy Policy. See Cookie Preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Image.asset('assets/logo.png', height: 30),
                  const SizedBox(width: 8),
                  const Text(
                    'Ausgrid AI',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  widget.themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: widget.onToggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          const Divider(color: Colors.white24, thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: AusgridDrawer(
        sessions: _sessions,
        onNewChat: _startNewSession,
        onSelectSession: (index) {
          setState(() => _currentChat = _sessions[index].messages);
        },
        onLogout: () => _showLogoutDialog(context), // 👈 Pass it here
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: _currentChat.length,
                    itemBuilder: (context, index) {
                      final isUser = _currentChat[index]['sender'] == 'user';
                      final message = _currentChat[index]['message']!;
                      return _buildChatBubble(message, isUser);
                    },
                  ),
                ),
                _buildInputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AusgridDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final VoidCallback onNewChat;
  final Function(int) onSelectSession;
  final VoidCallback onLogout;


  const AusgridDrawer({super.key, required this.sessions, required this.onNewChat, required this.onSelectSession,required this.onLogout,});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E0D4B),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: onNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('New chat', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Divider(color: Colors.white24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('History', style: TextStyle(color: Colors.white70)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () => onSelectSession(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(sessions[index].title, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
            drawerButton('Updates & FAQ’s'),
            drawerButton('Log out', onTap: onLogout),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget drawerButton(String title, {VoidCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    child: ElevatedButton(
      onPressed: onTap ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size.fromHeight(40),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    ),
  );
}

}
