import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For making HTTP requests
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

    String repairSolution = await _fetchData("My $device device has this issue: $issue. I live in this zip-code $zipCode, and have three options for repair: at-home, independent repair shops, or manufacturer repair. First, list the one you think is best only writing the phrase \"at-home repair\", \"independent business\", or \"manufacturer repair\". Then, in a new paragraph for each, write a small paragraph about the cost/convenience of each option respectively. Make the answers specific to the device and issue and zip code.");

    // Simulated response parsing
    setState(() {
      solution = repairSolution ?? 'No solution found.';
      List<String> fetchedSolutions = repairSolution.split("\n");
      fetchedSolutions = fetchedSolutions.map((str) => str.trim()).toList();

      // Example of a recommended solution
      recommendedSolution = fetchedSolutions[0];
      repairOptions = {
        'At Home Repair': fetchedSolutions[2],
        'Independent Repair Shop': fetchedSolutions[4],
        'Manufacturer Repair': fetchedSolutions[6]
      };

      isLoading = false;
    });

    // Scroll down just below the submit button
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
        controller: _scrollController, // Attach the ScrollController
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
                      _getHelpForDevice(selectedDevice!, issue);
                    } else {
                      // Show an error message if zip code is empty
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
          title: Text(option, style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(repairOptions[option] ?? ''),
            ),
          ],
        );
      }).toList(),
    );
  }
}
