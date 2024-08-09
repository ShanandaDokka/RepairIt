import 'package:flutter/material.dart';

class IndividualDevice extends StatefulWidget {
  final String title;
  final int score;
  final String category;

  IndividualDevice({required this.title, required this.score, required this.category});

  @override
  _IndividualDevicePageState createState() => _IndividualDevicePageState();
}

class _IndividualDevicePageState extends State<IndividualDevice> {
  bool _isQuestion1Expanded = false;
  bool _isQuestion2Expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Align(
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 2),
              Text(
                'Repairability',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  determineImage(widget.score), 
                  width: MediaQuery.of(context).size.width * 0.6, 
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Score',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This ${determineCategory(widget.category)} score is: ${widget.score}/5 stars',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Why?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This section explains why you received the score mentioned above. Provide detailed reasons here.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Learn More',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                'Question 1',
                'This is the answer to question 1. Provide detailed information here.',
                _isQuestion1Expanded,
                () {
                  setState(() {
                    _isQuestion1Expanded = !_isQuestion1Expanded;
                  });
                },
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                'Question 2',
                'This is the answer to question 2. Provide detailed information here.',
                _isQuestion2Expanded,
                () {
                  setState(() {
                    _isQuestion2Expanded = !_isQuestion2Expanded;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(String question, String answer, bool isExpanded, VoidCallback toggleExpansion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: toggleExpansion,
          child: Row (
            children: [
              Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.black,
              ),
              Text(
                question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              answer,
              style: TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  String determineImage(int score) {
    String image = "";
    switch (score) {
      case 0:
        image = "img/zero_star.png";
      case 1:
        image = "img/one_star.png";
      case 2:
        image = "img/two_star.png";
      case 3:
        image = "img/three_star.png";
      case 4:
        image = "img/four_star.png";
      default:
        image = "img/five_star.png";
    }
    return image;
  }

  String determineCategory(String word) {
    String catg = "";
    switch (word) {
      case "Cars":
        catg = "car's";
      case "Phones":
        catg = "phone's";
      case "Laptops":
        catg = "laptop's";
    }
    return catg;
  }
}
