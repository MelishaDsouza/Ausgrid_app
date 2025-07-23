import 'package:flutter/material.dart';
import 'dart:async';
import 'microphone_permission_page.dart';
import '../../widgets/shared_widgets.dart';
// ignore: unused_import
import '../pages/login_page.dart';


class LocationPermissionScreen extends StatefulWidget {
  final String username;

  const LocationPermissionScreen({super.key, required this.username});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final capitalUsername = capitalize(widget.username);

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
                AnimatedOpacity(
                  opacity: _showWelcome ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '👋 Welcome $capitalUsername to Ausgrid AI!',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Roboto',
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                permissionBox(
                  text: 'Allow Ausgrid AI to access your location?',
                  buttons: [
                    permissionButton(context, 'Allow Always', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MicrophonePermissionScreen(username: widget.username),
                        ),
                      );
                    }),
                    permissionButton(context, 'Only While Using the App', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MicrophonePermissionScreen(username: widget.username),
                        ),
                      );
                    }),
                    permissionButton(context, "Don't Allow", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MicrophonePermissionScreen(username: widget.username),
                        ),
                      );
                    }),
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
