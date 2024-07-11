import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurveyPage extends StatefulWidget {
  final VoidCallback onSurveyCompleted;

  SurveyPage({required this.onSurveyCompleted});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final PageController _pageController = PageController();
  String? phone, car, laptop;
  int _currentPage = 0;

  void _nextPage() async {
    if (_currentPage == 0) {
      if (await _verifyPhoneModel(phone!)) {
        _nextPage();
      } else {
        _showErrorDialog();
      }
    } else if (_currentPage == 2) {
      if (await _verifyLaptopModel(laptop!)) {
        _submitSurvey();
      } else {
        _showErrorDialog();
      }
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _verifyLaptopModel(String laptopModel) async {
    final response = await http.post(
      Uri.parse('https://api.techspecs.io/v4/product/search'),
      headers: {
        'query': laptopModel.trim(),
        'keepCasing': 'true',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImN1c19RUzhLNHFMQjVKcTJKTyIsIm1vZXNpZlByaWNpbmdJZCI6InByaWNlXzFNUXF5dkJESWxQbVVQcE1SWUVWdnlLZSIsImlhdCI6MTcyMDY2OTk1N30.bE4rTfAhAGE-Fc0hEnN5kxMZleqqtW0xaEG6NdfQBC8', 
      },
      body: jsonEncode({
        'category': 'laptop',
      }),
    );
    print("status code is ${response.statusCode}");
    print("response is ${response.body}");
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("parsed response body is $responseBody");
      print("ITEMS IS ${responseBody['data']['items']}");
      if (responseBody != null && responseBody['data']['items'] != null && responseBody['data']['items'].isNotEmpty) {
        // Save the laptop model
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('laptop', laptopModel);
        return true;
      }
    }
    return false;
  }

  Future<bool> _verifyPhoneModel(String phoneModel) async {
    final response = await http.post(
      Uri.parse('https://api.techspecs.io/v4/product/search'),
      headers: {
        'query': phoneModel.trim(),
        'keepCasing': 'true',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImN1c19RUzhLNHFMQjVKcTJKTyIsIm1vZXNpZlByaWNpbmdJZCI6InByaWNlXzFNUXF5dkJESWxQbVVQcE1SWUVWdnlLZSIsImlhdCI6MTcyMDY2OTk1N30.bE4rTfAhAGE-Fc0hEnN5kxMZleqqtW0xaEG6NdfQBC8', 
      },
      body: jsonEncode({
        'category': 'phone',
      }),
    );
    print("status code is ${response.statusCode}");
    print("response is ${response.body}");
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("parsed response body is $responseBody");
      print("ITEMS IS ${responseBody['data']['items']}");
      if (responseBody != null && responseBody['data']['items'] != null && responseBody['data']['items'].isNotEmpty) {
        // Save the laptop model
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone', phoneModel);
        return true;
      }
    }
    return false;
  }

  void _showErrorDialog() {
    String content = "";
    if (_currentPage == 0) {
      content = "Phone";
    } else if (_currentPage == 2) {
      content = "Laptop";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),

          content: Text('$content model not found. Please enter a valid model.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _submitSurvey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('surveyCompleted', true);

    widget.onSurveyCompleted();
  }

  Widget _buildQuestionPage(String question, void Function(String?) onSaved) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your answer here',
            ),
            onChanged: onSaved,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Initial Survey')),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildQuestionPage(
            'What is your phone model?',
            (value) => phone = value,
          ),
          _buildQuestionPage(
            'What is your car model?',
            (value) => car = value,
          ),
          _buildQuestionPage(
            'What is your laptop model?',
            (value) => laptop = value,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: _nextPage,
      ),
    );
  }
}
