import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      if (phone == null || phone!.trim().isEmpty) {
        _moveToNextPage();
      } else if (await _verifyPhoneModel(phone!)) {
        _moveToNextPage();  
      } else {
        _showErrorDialog();
      }
    } else if (_currentPage == 1) {
      if (car == null || car!.trim().isEmpty) {
        _moveToNextPage();
      } else if (await _verifyCarModel(car!)) {
        _moveToNextPage();  
      } else {
        _showErrorDialog();
      }
    } else if (_currentPage == 2) {
      if (laptop == null || laptop!.trim().isEmpty) {
        _submitSurvey();
      } else if (await _verifyLaptopModel(laptop!)) {
        _submitSurvey();
      } else {
        _showErrorDialog();
      }
    } else {
      _moveToNextPage();
    }
  }

void _moveToNextPage() {
  _pageController.nextPage(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

  Future<bool> _verifyLaptopModel(String laptopModel) async {
    final encodedLaptopModel = Uri.encodeComponent(laptopModel.trim());
    final response = await http.post(
      Uri.parse('https://api.techspecs.io/v4/product/search?query=${encodedLaptopModel}&keepCasing=true'),
      headers: {
        'Authorization': dotenv.env['TECHSPEC_API_KEY']!, // env 
      },
      body: jsonEncode({
        'category': 'laptop',
      }),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
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
    final encodedPhoneModel = Uri.encodeComponent(phoneModel.trim());
    final response = await http.post(
      Uri.parse('https://api.techspecs.io/v4/product/search?query=${encodedPhoneModel}&keepCasing=true'),
      headers: {
        'Authorization': dotenv.env['TECHSPEC_API_KEY']!, 
      },
      body: jsonEncode({
        'category': 'smartphone',
      }),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody != null && responseBody['data']['items'] != null && responseBody['data']['items'].isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone', phoneModel);
        return true;
      }
    }
    return false;
  }

  Future<bool> _verifyCarModel(String carInfo) async {
    List<String> infos = carInfo.split(",");

    infos = infos.map((str) => str.trim()).toList();
    if (infos.length < 2) {
      _showErrorDialogWithMessage('Please provide the car make and year.');
      return false;
    }

    final url = Uri.parse(
      'https://mc-api.marketcheck.com/v2/search/car/active?api_key=DKyJAEnhbECh2hCcCNBvaSayelzQOhlH&year=${infos[1]}&make=${infos[0]}');

    final response = await http.get(url);
    print("car response status code is ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("Parsed response body: $responseBody");

      if (responseBody != null &&
          responseBody['listings'] != null &&
          (responseBody['listings'] as List).isNotEmpty) {
        // Save the car model
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('car', carInfo);
        return true;
      }
    }

    return false;
  }

  void _showErrorDialogWithMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  void _showErrorDialog() {
    String content = "";
    if (_currentPage == 0) {
      content = "Phone";
    } else if (_currentPage == 1) {
      content = "Car";
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
            'What is your car model? (Make, Year)',
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
