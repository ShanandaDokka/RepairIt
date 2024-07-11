import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitSurvey();
    }
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
