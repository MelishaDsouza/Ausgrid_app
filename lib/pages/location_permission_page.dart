import 'package:flutter/material.dart';
import 'microphone_permission_page.dart';
import '../../widgets/shared_widgets.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

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
                permissionBox(
                  text: 'Allow Ausgrid AI to access your location?',
                  buttons: [
                    permissionButton(context, 'Allow Always', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrophonePermissionScreen()));
                    }),
                    permissionButton(context, 'Only While Using the App', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrophonePermissionScreen()));
                    }),
                    permissionButton(context, "Don't Allow", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrophonePermissionScreen()));
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
