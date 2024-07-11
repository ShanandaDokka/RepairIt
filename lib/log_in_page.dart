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

  Future<void> _logIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _navigateToMainPage();
    } catch (e) {
      print(e);
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
        backgroundColor: Colors.blue, // Example background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: _logIn,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Background color
              ),
              child: Text('Sign In'),
            ),
            Spacer(),
            Text(
                'Not registered with us? Sign up for free instead!',
                style: TextStyle(fontSize: 16, backgroundColor: Colors.lightBlue, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToSignUp,
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Background color
                ),
                child: Text('Sign Up'),
              ),
            ),
          ],
        )
      )
    );
  }
}
