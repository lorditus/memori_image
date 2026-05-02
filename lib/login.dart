import 'package:flutter/material.dart';
import 'package:memori_image/mainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  String? _savedUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSavedLogin();
    });
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _savedUsername = prefs.getString('username');

    print("LOADED USERNAME: $_savedUsername");

    if (_savedUsername != null && _savedUsername!.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(username: _savedUsername!),
        ),
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    String name = _controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', name);

    String? check = prefs.getString('username');
    print("CHECK SETELAH SAVE: $check");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(username: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Memorimage',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Login to continue'),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                floatingLabelStyle: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('LOGIN', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
