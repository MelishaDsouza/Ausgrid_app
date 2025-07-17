// 
import 'package:flutter/material.dart';
import '../../widgets/shared_widgets.dart';
import 'landing_page.dart'; // ✅ Import LandingPage

class MicrophonePermissionScreen extends StatelessWidget {
  const MicrophonePermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You can customize this depending on current app theme
    ThemeMode themeMode = ThemeMode.light;

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
                permissionBox(
                  text: 'Allow Ausgrid AI to access your microphone?',
                  buttons: [
                    permissionButton(context, 'Allow Always', () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LandingPage(
                            onToggleTheme: () {
                              // You can replace this with real logic
                              print("Theme toggled from Mic screen");
                            },
                            themeMode: themeMode,
                          ),
                        ),
                      );
                    }),
                    permissionButton(context, 'Only While Using the App', () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LandingPage(
                            onToggleTheme: () {
                              print("Theme toggled from Mic screen");
                            },
                            themeMode: themeMode,
                          ),
                        ),
                      );
                    }),
                    permissionButton(context, "Don't Allow", () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LandingPage(
                            onToggleTheme: () {
                              print("Theme toggled from Mic screen");
                            },
                            themeMode: themeMode,
                          ),
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
