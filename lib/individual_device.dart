import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'constants.dart';

class IndividualDevice extends StatefulWidget {
  final String title;
  final int score;
  final String category;

  IndividualDevice({required this.title, required this.score, required this.category});

  @override
  _IndividualDevicePageState createState() => _IndividualDevicePageState();
}

class _IndividualDevicePageState extends State<IndividualDevice> with AutomaticKeepAliveClientMixin {
  bool _isQuestion1Expanded = false;
  bool _isQuestion2Expanded = false;
  bool _isQuestion3Expanded = false; 
  bool _isQuestion4Expanded = false; 
  bool _hasInitialized = false;

  String whyExplanation = "";
  String question1Answer = "";
  String question2Answer = "";
  String question3Answer = "";
  String question4Answer = "";

  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAnswers();  
  }

  final GeminiApi _gemini = GeminiApi();

  Future<void> _loadAnswers() async {
    if (!_hasInitialized) {
      try {
        String carData = await _fetchData(getSingleScoreString(widget.title)) ?? "Sorry, we were unable to fetch an answer for this question.";
        String q1 = await _fetchData(getQuestion1Prompt(widget.category, widget.title)) ?? "Sorry, we were unable to fetch an answer for this question.";
        String q2 = await _fetchData(getQuestion2Prompt(widget.category, widget.title)) ?? "Sorry, we were unable to fetch an answer for this question.";
        String q3 = await _fetchData(getQuestion3Prompt(widget.title)) ?? "Sorry, we were unable to fetch an answer for this question.";
        String q4 = await _fetchData(getQuestion4Prompt(widget.title)) ?? "Sorry, we were unable to fetch an answer for this question.";

        if (mounted) {
          setState(() {
            whyExplanation = carData;
            _hasInitialized = true;
            question1Answer = q1.replaceAll('*', '');
            question2Answer = q2.replaceAll('*', '');
            question3Answer = q3.replaceAll('*', '');
            question4Answer = q4.replaceAll('*', '');
          });
        }
      } catch (e) {
        print('Error loading devices: $e');
      }
    } else {
      return;
    }
  }

  Future<String> _fetchData(String prompt) async {
    try {
      final data = await _gemini.fetchData(prompt);
      return data.toString();
    } catch (e) {
      print('Error fetching data: $e');
      return 'Failed to fetch data';
    }
  }

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
      body: FutureBuilder<void>(
        future: _loadAnswers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));  
          } else {
            return _buildContent(context);  
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          key: PageStorageKey(widget.title),
          controller: _scrollController,
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
                'This ${determineCategory(widget.category)} repairability score: ${widget.score}/5 stars',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 8),
              _buildScoringSystem(),
              SizedBox(height: 20),
              Text(
                'Why?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                whyExplanation,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Learn More',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                getQuestion1(widget.title),
                question1Answer,
                _isQuestion1Expanded,
                () {
                  if (mounted) {
                    setState(() {
                      _isQuestion1Expanded = !_isQuestion1Expanded;
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                getQuestion2(widget.category, widget.title),
                question2Answer,
                _isQuestion2Expanded,
                () {
                  if (mounted) {
                    setState(() {
                      _isQuestion2Expanded = !_isQuestion2Expanded;
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                getQuestion3(widget.title),
                question3Answer,
                _isQuestion3Expanded,
                () {
                  if (mounted) {
                    setState(() {
                      _isQuestion3Expanded = !_isQuestion3Expanded;
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              _buildQuestionSection(
                getQuestion4(widget.title),
                question4Answer,
                _isQuestion4Expanded,
                () {
                  if (mounted) {
                    setState(() {
                      _isQuestion4Expanded = !_isQuestion4Expanded;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoringSystem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scoring System',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '1: Poor - Hard to repair at home, expensive repair costs',
          style: TextStyle(fontSize: 10),
        ),
        Text(
          '2: Fair - Some challenges with home repair, expensive repair costs',
          style: TextStyle(fontSize: 10),
        ),
        Text(
          '3: Good - Can be repaired at home with effort, moderate repair costs',
          style: TextStyle(fontSize: 10),
        ),
        Text(
          '4: Very Good - Relatively easy to repair at home, reasonable repair costs',
          style: TextStyle(fontSize: 10),
        ),
        Text(
          '5: Excellent - Generally easily repairable at home, low repair costs',
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    insetPadding: EdgeInsets.all(10),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 2,
                      child: Image.asset(
                        'img/repairIt_rubric.png', 
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            },
            child: Text('View Our Rubric'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(String question, String answer, bool isExpanded, VoidCallback toggleExpansion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: toggleExpansion,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.black,
              ),
              Expanded( 
                child: Text(
                  question,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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
