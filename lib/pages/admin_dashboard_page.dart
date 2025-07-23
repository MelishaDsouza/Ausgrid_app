import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../widgets/shared_widgets.dart';
import 'home_page.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showWelcome = true;
  bool _dragging = false;
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;

  Timer? _idleTimer;
  Timer? _logoutCountdownTimer;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showWelcome = false;
      });
    });
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _logoutCountdownTimer?.cancel();
    setState(() {
      _countdown = 30;
    });

    _idleTimer = Timer(const Duration(minutes: 1), () {
      _startLogoutCountdown();
    });
  }

  void _startLogoutCountdown() {
    _logoutCountdownTimer?.cancel();
    _logoutCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _logoutUser();
      }
    });
  }

  void _logoutUser() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _logoutCountdownTimer?.cancel();
    super.dispose();
  }

  void _onUserInteraction([_]) {
    _resetIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: _onUserInteraction,
      child: Scaffold(
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
                    if (_countdown < 60)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Inactive! Logging out in $_countdown sec",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),

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

                    Center(
                      child: Wrap(
                        spacing: 20,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _onUserInteraction();
                              _showPasswordPrompt(); // ✅ Password check before upload
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[600], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                            child: const Text("Upload Documents", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _onUserInteraction();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download started...")));
                            },
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
      ),
    );
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
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 9, 27, 236).withOpacity(0.95),
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
                    onPressed: _logoutUser,
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

  // ✅ NEW FUNCTION: password authentication before upload
  void _showPasswordPrompt() {
    String enteredPassword = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 65, 38, 168).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Admin Password", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.deepPurple,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => enteredPassword = value,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[300]),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (enteredPassword == 'admin123') {
                        Navigator.pop(context);
                        _showUploadDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Incorrect password!"),
                          backgroundColor: Colors.redAccent,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
    _onUserInteraction();
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
              DropTarget(
                onDragEntered: (_) {
                  setState(() => _dragging = true);
                  _onUserInteraction();
                },
                onDragExited: (_) {
                  setState(() => _dragging = false);
                  _onUserInteraction();
                },
                onDragDone: (detail) async {
                  if (detail.files.isNotEmpty) {
                    final file = detail.files.first;
                    Uint8List bytes = await file.readAsBytes();
                    setState(() {
                      _selectedFile = PlatformFile(
                        name: file.name,
                        size: bytes.lengthInBytes,
                        path: file.path,
                        bytes: bytes,
                      );
                      _fileBytes = bytes;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Dropped file: ${file.name}"),
                    ));
                    _onUserInteraction();
                  }
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _dragging ? Colors.deepPurpleAccent : const Color.fromARGB(255, 95, 6, 250),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text("Drag and Drop", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8),
                      Text("or", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _browseFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 126, 66, 245),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Browse", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text("Only pdf and docs accepted", style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 89, 3, 237)),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _uploadFile,
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
    _onUserInteraction();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _fileBytes = _selectedFile!.bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Selected file: ${_selectedFile!.name}"),
      ));
    }
  }

  void _uploadFile() {
    _onUserInteraction();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("File uploaded successfully!"),
    ));
  }
}



