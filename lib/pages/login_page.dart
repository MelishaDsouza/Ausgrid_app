import 'package:flutter/material.dart';
import 'location_permission_page.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loginFailed = false;

  final Map<String, String> validUsers = {
    'aawan': '1234',
    'melisha': '2468',
    'payal': '1357',
    'nupur': '1234',
    'swapnil': '1234',
    'muharika': '12345',
  };

  void _handleLogin() {
    String username = usernameController.text.trim();
    String password = passwordController.text;

    if (validUsers.containsKey(username) && validUsers[username] == password) {
      setState(() {
        _loginFailed = false;
      });
      // ✅ Correctly pass username to next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPermissionScreen(username: username),
        ),
      );
    } else {
      setState(() {
        _loginFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          backgroundImage(),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                headerWithLogo(),
                const Divider(color: Colors.white, thickness: 1),
                const Spacer(),
                Column(
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.indigo[900],
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.indigo[900],
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_loginFailed)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Invalid username or password',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[900],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
