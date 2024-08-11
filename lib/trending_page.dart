import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'constants.dart';
import 'clickable_box.dart';
import 'individual_device.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> with AutomaticKeepAliveClientMixin {
  List<String> trendingCars = [];
  List<String> trendingPhones = [];
  List<String> trendingLaptops = [];

  List<String> carScores = [];
  List<String> phoneScores = [];
  List<String> laptopScores = [];

  bool _isLoading = true;
  bool _hasInitialized = false;
  bool _error = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _hasInitialized = false;
      _error = false;
      _isLoading = true;
    });

    await _loadDevices().then((_) => _getScoreAndImage());
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasInitialized = true;
      });
    }
  }

  final GeminiApi _gemini = GeminiApi();
  Future<String> _fetchData(String prompt) async {
    try {
      final data = await _gemini.fetchData(prompt);
      if (mounted) {
        setState(() {
          _error = false;
        });
      }
      if (data == null) {
        throw Exception();
      }
      return data.toString();
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _error = true;
      });
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

      if (mounted && !_error) {
        setState(() {
          trendingCars = carModels;
          trendingLaptops = laptopModels;
          trendingPhones = phoneModels;
        });
      }
    } catch (e) {
      print('Error loading devices: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

        if (!_hasInitialized && !_error) {
          String scorePhone = await _fetchData(scorePromptPhones);
          String scoreLaptop = await _fetchData(scorePromptLaptops);
          String scoreCar = await _fetchData(scorePromptCars);

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
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        } else {
          return;
        }
      }
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    
    String prompt1 = getSingleScoreSingleInputString(query);
    String score = await _fetchData(prompt1);
    
    String prompt2 = getCategoryPrompt(query);
    String category = await _fetchData(prompt2);
    category = category.trim();

    if (score.isEmpty || !(category == "Phones" || category == "Cars" || category == "Laptops")) {
      setState(() {
        _searchController.text = "Device not found, please try again";
      });
    } else if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualDevice(title: query.trim(), score: int.parse(score.trim()), category: category),
        ),
      );
    }
  }

  List<String> getScoreImage(String title, int index) {
    String image;
    List<String> currentScores;
    if (title == "Phones") {
      currentScores = phoneScores;
    } else if (title == "Cars") {
      currentScores = carScores;
    } else {
      currentScores = laptopScores;
    }
    List<String> retVal = List<String>.empty(growable: true);

    if (currentScores.isEmpty) {
      retVal.add("0");
      retVal.add("img/zero_star.png");
      return retVal;
    }

    if (index < 0 || index >= currentScores.length) {
      retVal.add("0");
      retVal.add("img/zero_star.png");
      return retVal;
    }

    int scoreVal = int.tryParse(currentScores[index]) ?? 0;
    retVal.add("$scoreVal");

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
    }

    retVal.add(image);
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    super.build(context);
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
            SizedBox(height: 2),
            Flexible(
              child: Text(
                trendingPageSubtitle,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error ? 
            Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.red[50], 
                  borderRadius: BorderRadius.circular(8.0), 
                  border: Border.all(color: Colors.red, width: 2.0), 
                ),
                child: Text(
                  resourceOverloadError,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[800], 
                    fontWeight: FontWeight.bold, 
                  ),
                  textAlign: TextAlign.center, 
                ),
              ),
            )
            : Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              radius: Radius.circular(8),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search for a device",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: _search,
                            ),
                          ),
                          onSubmitted: (value) => _search(),
                        ),
                      ),
                    ),
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
              controller: scrollController, 
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

  Widget _buildClickableBox(BuildContext context, String item, int index, String category) {
    List<String> scores = getScoreImage(category, index);
    return ClickableBox(item: item, image: scores[1], score: int.parse(scores[0]), title: category);
  }

  @override
  bool get wantKeepAlive => true;
}
