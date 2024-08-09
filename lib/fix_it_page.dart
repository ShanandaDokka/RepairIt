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

    String repairSolution = await _fetchData("My $device device has this issue: $issue. I have three options for repair: at-home, independent repair shops, or manufacturer repair. First, list the one you think is best only writing the phrase \"at-home repair\", \"independent business\", or \"manufacturer repair\". Then, in a new paragraph for each, write a small paragraph about the cost/convinience of each option respectively. Make the answers specific to the device and issue.");

    // Simulated response parsing
    setState(() {
      solution = repairSolution ?? 'No solution found.';
      List<String> fetchedSolutions = repairSolution.split("\n");
      fetchedSolutions = fetchedSolutions.map((str) => str.trim()).toList();
      // Simulating parsing of the response into options
      // Replace this with actual parsing logic
      print("SOLUTION $fetchedSolutions ");
      recommendedSolution = fetchedSolutions[0]; // Example of a recommended solution
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
      appBar: AppBar(
        title: Text('Fix It'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Attach the ScrollController
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What device do you need help with?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
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
            if (selectedDevice != null) ...[
              SizedBox(height: 16),
              Text(
                'What\'s wrong with the device?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
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
              if (isCustomProblem) ...[
                SizedBox(height: 8),
                TextField(
                  onChanged: (value) {
                    customProblemDescription = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Describe the problem...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                key: _submitButtonKey, // Key for the submit button
                onPressed: () {
                  if (selectedProblemCategory != null) {
                    String issue = isCustomProblem
                        ? customProblemDescription
                        : selectedProblemCategory!;
                    _getHelpForDevice(selectedDevice!, issue);
                  }
                },
                child: Text('Get Help'),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
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
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'Recommended Solution: \n $recommendedSolution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildRepairOptions(),
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
          title: Text(option),
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
