import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'constants.dart';
import 'clickable_box.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}


class _TrendingPageState extends State<TrendingPage> {
  List<String> trendingCars = [];
  List<String> trendingPhones = [];
  List<String> trendingLaptops = [];

  List<String> carScores = [];
  List<String> phoneScores = [];
  List<String> laptopScores = [];

  bool _isLoading = true; 
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!_hasInitialized) {
      await _loadDevices().then((_) => _getScoreAndImage());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasInitialized = true; 
        });
      }
    }
  }

  final GeminiApi _gemini = GeminiApi();
  Future<String> _fetchData(String prompt) async {
    try {
      final data = await _gemini.fetchData(prompt);
      return data.toString();
    } catch (e) {
      print('Error fetching data: $e'); 
      return 'Failed to fetch data'; 
    }
  }

  Future<void> _loadDevices() async {
    try {
      String carData = await _fetchData(geminiTrendingCar);
      List<String> carModels = carData.split(', ');
      carModels = carModels.map((str) => str.trim()).toList();

      String phoneData = await _fetchData(geminiTrendingPhones);
      List<String> phoneModels = phoneData.split(', ');
      phoneModels = phoneModels.map((str) => str.trim()).toList();

      String laptopData = await _fetchData(geminiTrendingLaptops);
      List<String> laptopModels = laptopData.split(', ');
      laptopModels = laptopModels.map((str) => str.trim()).toList();
      
      if (mounted) {
        setState(() {
          trendingCars = carModels.toList();
          trendingLaptops = laptopModels.toList();
          trendingPhones = phoneModels.toList();
        });
      }
    } catch (e) {
      print('Error loading devices: $e');
      setState(() {
        _isLoading = false;
      });
    }
  } 

  Future<void> _getScoreAndImage() async {
    const int maxRetries = 3; 
    const Duration retryDelay = Duration(seconds: 2); 

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        String scorePromptPhones = getScoreString(trendingPhones);
        String scorePromptLaptops = getScoreString(trendingLaptops);
        String scorePromptCars = getScoreString(trendingCars);

        String scorePhone;
        String scoreLaptop;
        String scoreCar;
        
        if (!_hasInitialized) {
          scorePhone = await _fetchData(scorePromptPhones);
          scoreLaptop = await _fetchData(scorePromptLaptops);
          scoreCar = await _fetchData(scorePromptCars);

          if ((scorePhone.isEmpty || scoreLaptop.isEmpty || scoreCar.isEmpty)) {
            if (attempt < maxRetries - 1) {
              await Future.delayed(retryDelay);
            }
          } else {
            List<String> fetchedPhoneScores = scorePhone.split(",");
            fetchedPhoneScores = fetchedPhoneScores.map((str) => str.trim()).toList();

            List<String> fetchedCarScores = scoreCar.split(",");
            fetchedCarScores = fetchedCarScores.map((str) => str.trim()).toList();

            List<String> fetchedLaptopScores = scoreLaptop.split(",");
            fetchedLaptopScores = fetchedLaptopScores.map((str) => str.trim()).toList();

            setState(() {
              carScores = fetchedCarScores;
              laptopScores = fetchedLaptopScores;
              phoneScores = fetchedPhoneScores;
              _isLoading = false;
              _hasInitialized = true;
            });
            break;
          }
        }
      } catch (e) {
        print('Error fetching or processing data: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        } else {
          print("Error retrieving scores");
        }
      }
    }
  }

  String getScoreImage(String title, int index) {
    String image;
    List<String> currentScores;
    if (title == "Phones") {
      currentScores = phoneScores;
    } else if (title == "Cars") {
      currentScores = carScores;
    } else {
      currentScores = laptopScores;
    }

    if (currentScores.isEmpty) {
      return "img/zero_star.png";
    }
    
    if (index < 0 || index >= currentScores.length) {
      return "img/zero_star.png"; 
    }

    int scoreVal = int.tryParse(currentScores[index]) ?? 0;

    switch (scoreVal) {
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
        break;
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Colors.black,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  'Trending',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 2), // Space between title and subtitle
            Flexible(
              child: Text(
                trendingPageSubtitle,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                overflow: TextOverflow.visible, // Ensure it doesn’t get cut off
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scrollbar(
          thumbVisibility: true,
          radius: Radius.circular(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubheading(context, 'Phones', trendingPhones),
                _buildSubheading(context, 'Cars', trendingCars),
                _buildSubheading(context, 'Laptops', trendingLaptops),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSubheading(BuildContext context, String title, List<String> items) {
    final ScrollController scrollController = ScrollController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            height: 150, 
            child: Scrollbar(
              thumbVisibility: true, 
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0), 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildClickableBox(context, items[index], index, title);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableBox(BuildContext context, String item, int index, String title) {
    String image = _isLoading ? "img/loading.png" : getScoreImage(title, index);
    return ClickableBox(item: item, image: image);
  }
}
