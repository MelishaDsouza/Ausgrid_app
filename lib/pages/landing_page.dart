import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatSession {
  final String title;
  final List<Map<String, String>> messages;

  ChatSession({required this.title, required this.messages});
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatSession> _sessions = [];
  List<Map<String, String>> _currentChat = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
        _currentChat.add({'sender': 'bot', 'message': 'You said: "$text"'});

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
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
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
          const Divider(color: Colors.white24, thickness: 1),
        ],
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
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.redAccent : Colors.white),
                onPressed: _handleVoiceInput,
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text('Weather'),
              backgroundColor: Colors.deepPurpleAccent,
              labelStyle: TextStyle(color: Colors.white),
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
}

class AusgridDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final VoidCallback onNewChat;
  final Function(int) onSelectSession;

  const AusgridDrawer({super.key, required this.sessions, required this.onNewChat, required this.onSelectSession});

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
            drawerButton('Light mode'),
            drawerButton('Updates & FAQ’s'),
            drawerButton('Log out'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget drawerButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {},
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
