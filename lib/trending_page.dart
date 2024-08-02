import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<String> trendingCars = [];
  List<String> trendingPhones = [];
  List<String> trendingLaptops = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
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

      String phoneData = await _fetchData(geminiTrendingPhones);
      List<String> phoneModels = phoneData.split(', ');

      String laptopData = await _fetchData(geminiTrendingLaptops);
      List<String> laptopModels = laptopData.split(', ');
      
      setState(() {
        trendingCars = carModels.toList();
        trendingLaptops = laptopModels.toList();
        trendingPhones = phoneModels.toList();
      });
    } catch (e) {
      print('Error loading devices: $e');
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.black, // Color of the icon
              size: 30, // Adjust size here
            ),
            SizedBox(width: 8),
            Text(
              'Trending',
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubheading(context, 'Phones', trendingPhones),
            _buildSubheading(context, 'Cars', trendingCars),
            _buildSubheading(context, 'Laptops', trendingLaptops),
          ],
        ),
      ),
    );
  }

  Widget _buildSubheading(BuildContext context, String title, List<String> items) {
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
            height: 100, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildClickableBox(context, items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableBox(BuildContext context, String item) {
    return GestureDetector(
      onTap: () {
        print('Clicked on $item');
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


// TODO-LIST 
// add subtitle
// add scores using gemini
  // five empty stars top right corner based on rating
// click into it
  // have the same main categories ()
