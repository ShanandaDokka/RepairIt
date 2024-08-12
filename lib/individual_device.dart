import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final Map<String, String> _scoreDescriptions = {
    '1 star': 'Hard to repair at home, expensive repair costs',
    '2 star': 'Challenges with home repair, expensive repair costs',
    '3 star': 'Repair at home with effort, moderate repair costs',
    '4 star': 'Relatively easy to repair at home, reasonable repair costs',
    '5 star': 'Generally easily repairable at home, low repair costs',
  };
  String _selectedScoreDescription = "";

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
          child: Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 2),
                Text(
                  'Repairability',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
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
            return Center(child: Text('Error loading data', style: GoogleFonts.lato(fontSize: 16, color: Colors.red)));  
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
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Score',
                style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This ${determineCategory(widget.category)} repairability score: ${widget.score}/5 stars',
                style: GoogleFonts.lato(fontSize: 17),
              ),
              SizedBox(height: 20),
              _buildScoreCategories(),
              SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    color: Colors.black,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why?',
                          style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          whyExplanation,
                          style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Learn More',
                style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildScoreCategories() {
    return Container(
      color: Color.fromARGB(255, 121, 117, 117), 
      padding: const EdgeInsets.all(16.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: _scoreDescriptions.keys.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedScoreDescription = _scoreDescriptions[category]!;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 21, 21, 21),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8),
          _selectedScoreDescription.isNotEmpty ?
            Text(
              _selectedScoreDescription,
              style: GoogleFonts.lato(fontSize: 14, color: Colors.white), 
            ) :  
            Text(
              'Click on a star above',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.white), 
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
              child: Text('View Our Rubric', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
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
                Icons.keyboard_arrow_down,
                size: 24,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                  softWrap: true,  
                  overflow: TextOverflow.visible, 
                ),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.lato(fontSize: 16),
          ),
        ],
        Divider(color: Colors.grey.shade300, thickness: 1), 
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
