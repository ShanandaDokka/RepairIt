import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:namer_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:namer_app/gemini_api.dart';

class FixItPage extends StatefulWidget {
  @override
  _FixItPageState createState() => _FixItPageState();
}

class _FixItPageState extends State<FixItPage> {
  List<Map<String, String>> devices = [];
  String? selectedDevice;
  String? selectedProblemCategory;
  bool isCustomProblem = false;
  String customProblemDescription = '';
  final GeminiApi _gemini = GeminiApi();
  String zipCode = '';


  final ScrollController _scrollController = ScrollController(); // Scroll controller
  final GlobalKey _submitButtonKey = GlobalKey(); // GlobalKey for the submit button

  Future<String> _fetchData(String prompt) async {
    try {
      final data = await _gemini.fetchData(prompt);
      return data.toString();
    } catch (e) {
      print('Error fetching data: $e');
      return 'Failed to fetch data';
    }
  }

  final List<String> problemCategories = [
    'Battery Issues',
    'Performance Problems',
    'Connectivity Issues',
    'Software Glitches',
    'Hardware Damage',
    'Other'
  ];

  bool isLoading = false; // Tracks if the app is loading the solution
  String solution = ''; // Stores the solution text
  String recommendedSolution = ''; // Stores the recommended solution
  Map<String, String> repairOptions = {}; // Stores repair options
  Map<String, String> repairShopOptions = {}; // stores nearby repair shops

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      devices = [];
      String? phone = prefs.getString('phone');
      String? car = prefs.getString('car');
      String? laptop = prefs.getString('laptop');

      if (phone != null && phone.isNotEmpty) devices.add({'type': 'phone', 'name': phone});
      if (car != null && car.isNotEmpty) devices.add({'type': 'car', 'name': car});
      if (laptop != null && laptop.isNotEmpty) devices.add({'type': 'laptop', 'name': laptop});

      List<String>? additionalDevices = prefs.getStringList('additionalDevices');
      if (additionalDevices != null) {
        devices.addAll(additionalDevices.map((device) => {'type': 'other', 'name': device}));
      }
    });
  }

  Future<void> _getHelpForDevice(String device, String issue) async {
    setState(() {
      isLoading = true;
      solution = '';
      recommendedSolution = '';
      repairOptions = {};
    });

    String repairSolution = await _fetchData(getFixItPrompt(zipCode, device, issue));

    setState(() {
      solution = repairSolution ?? 'No solution found.';
      List<String> fetchedSolutions = repairSolution.split("\n");
      fetchedSolutions = fetchedSolutions.map((str) => str.trim()).toList();

      recommendedSolution = fetchedSolutions[0];
      repairOptions = {
        'At Home Repair': fetchedSolutions[2],
        'Independent Repair Shop': fetchedSolutions[4],
        'Manufacturer Repair': fetchedSolutions[6]
      };

      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox submitButtonBox = _submitButtonKey.currentContext!.findRenderObject() as RenderBox;
      final position = submitButtonBox.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        _scrollController.offset + position + submitButtonBox.size.height,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _getRepairShopsFromZip() async {
    const int radius = 5000;
    String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    String searchQuery = '$selectedDevice repair shops';
    
    final String geoCodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=$zipCode&key=$apiKey';

    try {
      final geoCodingResponse = await http.get(Uri.parse(geoCodingUrl));
      if (geoCodingResponse.statusCode == 200) {
        final geoCodingData = json.decode(geoCodingResponse.body);
        print('Geocoding API Response: ${geoCodingData}'); 
        
        if (geoCodingData['status'] == 'OK') {
          final location = geoCodingData['results'][0]['geometry']['location'];
          final latitude = location['lat'];
          final longitude = location['lng'];
          
          final String locationStr = '$latitude,$longitude';
          final String nearbySearchUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$locationStr&radius=$radius&type=repair&keyword=$searchQuery&key=$apiKey';
          
          final response = await http.get(Uri.parse(nearbySearchUrl));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Nearby Search API Response: ${data}'); 
            
            final results = data['results'] as List;
            Map<String, String> repairShops = {};
            
            int count = 0;
            for (var result in results) {
              final shopName = result['name'];
              final address = result['vicinity'] ?? 'Address not available'; 
              repairShops[shopName] = address;
              count += 1;
              if (count == 5) {
                break;
              }
              print("SHOP NAME: $shopName, ADDRESS: $address");
            }

            setState(() {
              repairShopOptions = repairShops;
            });
          } else {
            print('Failed to load repair shops. Status code: ${response.statusCode}');
          }
        } else {
          print('Failed to get coordinates. Status: ${geoCodingData['status']}');
        }
      } else {
        print('Failed to get coordinates. Status code: ${geoCodingResponse.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _selectProblemCategory(String? newValue) {
    setState(() {
      selectedProblemCategory = newValue;
      isCustomProblem = newValue == 'Other';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        controller: _scrollController, 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fix It',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Enter your zip code:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    zipCode = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter zip code",
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'What device do you need help with?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select a device'),
                value: selectedDevice,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDevice = newValue;
                    selectedProblemCategory = null; // Reset problem category when device changes
                    isCustomProblem = false; // Reset custom problem flag
                  });
                },
                items: devices.map<DropdownMenuItem<String>>((Map<String, String> device) {
                  return DropdownMenuItem<String>(
                    value: device['name'],
                    child: Text(device['name']!),
                  );
                }).toList(),
              ),
            ),
            if (selectedDevice != null) ...[
              SizedBox(height: 20),
              Text(
                'What\'s wrong with the device?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: SizedBox(),
                  hint: Text('Select a problem category'),
                  value: selectedProblemCategory,
                  onChanged: _selectProblemCategory,
                  items: problemCategories.map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              ),
              if (isCustomProblem) ...[
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    customProblemDescription = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Describe the problem...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  key: _submitButtonKey, // Key for the submit button
                  onPressed: () {
                    if (selectedProblemCategory != null && zipCode.isNotEmpty) {
                      String issue = isCustomProblem
                          ? customProblemDescription
                          : selectedProblemCategory!;
                      _getRepairShopsFromZip();
                      _getHelpForDevice(selectedDevice!, issue);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a zip code')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Get Help'),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Fetching solution...'),
                    ],
                  ),
                ),
              if (!isLoading && solution.isNotEmpty) ...[
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recommended Solution: \n $recommendedSolution',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildRepairOptions(),
                    ],
                  ),
                ),
              ],
              
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRepairOptions() {
    return Column(
      children: repairOptions.keys.map((option) {
        return ExpansionTile(
          title: Text(option, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: option == 'Independent Repair Shop'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Near You:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        ...repairShopOptions.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '• ',
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${entry.key} | ${entry.value}',
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 10),
                        Text(
                          (repairOptions[option] ?? '').replaceAll("*", ""),
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ],
                    )
                  : Text(
                      (repairOptions[option] ?? '').replaceAll("*", ""),
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
