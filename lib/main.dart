// import 'package:flutter/material.dart';
// import 'pages/landing_page.dart'; // <--- Import the new landing page
// import 'pages/home_page.dart';


// void main() {
//   runApp(const AusgridAIApp());
// }

// class AusgridAIApp extends StatelessWidget {
//   const AusgridAIApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LandingPage(), // <--- Set landing page as the home screen
//       home: HomePage(),


//     );
//   }
// }
import 'package:flutter/material.dart';
import 'pages/home_page.dart'; 

void main() {
  runApp(const AusgridAIApp());
}

class AusgridAIApp extends StatelessWidget {
  const AusgridAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
