import 'package:flutter/material.dart';
import '../../widgets/shared_widgets.dart';
import 'home_page.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showWelcome = true;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showWelcome = false;
      });
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 9, 27, 236)!.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Confirm Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Are you sure you want to log out?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.grey[300]), child: const Text('Cancel')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 154, 105, 238).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Upload Documents", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                 width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 6, 250),
                  borderRadius: BorderRadius.circular(16),
                 
                 
                ),
                child: Column(
                 
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 50, color: Color.fromARGB(255, 255, 255, 255)),
                    const SizedBox(height: 10),
                    const Text("Drag and Drop", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text("or", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _browseFile,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 126, 66, 245), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Browse", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    const Text("Only pdf and docs accepted", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 89, 3, 237)),
                    child: const Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 89, 3, 237)),
                    child: const Text("Upload", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _browseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Selected file: ${_selectedFile!.name}"),
      ));
    }
  }

  void _uploadFile() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("File uploaded successfully!"),
    ));
  }

  Widget buildStatBox(String title, String value, IconData icon) {
    return Container(
      width: 170,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[900]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 255, 255, 255), size: 22),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Color.fromARGB(246, 255, 255, 255), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Image.asset('assets/logo.png', width: 40, height: 40),
                        const SizedBox(width: 8),
                        const Text('Ausgrid AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 8),
                        const Text('Admin Dashboard', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70)),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _confirmLogout(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                          child: const Text('Log out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white, thickness: 1),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('Statistics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        buildStatBox('Chat Sessions', '152', Icons.chat_bubble_outline),
                        buildStatBox('Total Users', '87', Icons.people_outline),
                        buildStatBox('Total Messages', '1390', Icons.message_outlined),
                        buildStatBox('Avg. Session Time', '4m 12s', Icons.timer_outlined),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Buttons Section
                  Center(
                    child: Wrap(
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: _showUploadDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[600], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: const Text("Upload Documents", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download started..."))),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[600], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: const Text("Download Reports", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  AnimatedOpacity(
                    opacity: _showWelcome ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Center(
                      child: Column(
                        children: const [
                          SizedBox(height: 20),
                          Text('Welcome to Admin Dashboard', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('You have successfully logged in as Admin.', style: TextStyle(color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}