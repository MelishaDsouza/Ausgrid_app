import 'package:flutter/material.dart';

Widget backgroundImage() {
  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/background.png'), 
        fit: BoxFit.cover,
      ),
    ),
  );
}


Widget headerWithLogo() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      children: [
        Image.asset('assets/logo.png', width: 50, height: 50),
        const SizedBox(width: 10),
        const Text(
          'Ausgrid AI',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget roleButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo[800],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
    ),
  );
}

Widget permissionBox({required String text, required List<Widget> buttons}) {
  return Center(
    child: Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          ...buttons,
        ],
      ),
    ),
  );
}

Widget permissionButton(BuildContext context, String text, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[900],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ),
  );
}
