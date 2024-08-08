import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:namer_app/sign_up_page.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  Future<void> _logIn() async {
    setState(() {
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email cannot be empty';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty';
      });
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _navigateToMainPage();
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-credential') {
            _errorMessage = 'Invalid credentials';
          } else {
            _errorMessage = 'Hi';
          }
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage())
    );
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _logIn,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              child: Text('Log In'),
            ),
            Spacer(),
            Column(
              children: [
                Text(
                  'Not registered with us? Sign up for free!',
                  style: TextStyle(
                    fontSize: 16,
                    backgroundColor: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _navigateToSignUp,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
