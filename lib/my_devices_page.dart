import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'individual_device.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDevicesPage extends StatefulWidget {
  @override
  _MyDevicesPageState createState() => _MyDevicesPageState();
}

class _MyDevicesPageState extends State<MyDevicesPage> {
  List<Map<String, String>> devices = [];
  final Color backgroundColor = Color(0xFFE6DFF1);
  final Color accentColor = Colors.white;
  final Color textColor = Colors.black;

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

      if (phone != null && phone.isNotEmpty)
        devices.add({'type': 'phone', 'name': phone});
      if (car != null && car.isNotEmpty)
        devices.add({'type': 'car', 'name': car});
      if (laptop != null && laptop.isNotEmpty)
        devices.add({'type': 'laptop', 'name': laptop});

      List<String>? additionalDevices = prefs.getStringList('additionalDevices');
      if (additionalDevices != null) {
        devices.addAll(
            additionalDevices.map((device) => {'type': 'other', 'name': device}));
      }
    });
  }

  Future<void> _addDevice(String device) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> additionalDevices =
        prefs.getStringList('additionalDevices') ?? [];
    additionalDevices.add(device);
    await prefs.setStringList('additionalDevices', additionalDevices);
    _loadDevices();
  }

  final GeminiApi _gemini = GeminiApi();

  Future<String> _fetchData(String prompt) async {
    try {
      final data = await _gemini.fetchData(prompt);
      if (data == null) {
        throw Exception();
      }
      return data.toString();
    } catch (e) {
      print('Error fetching data: $e');
      return 'Failed to fetch data';
    }
  }

  Future<void> _getScorePage(String title) async {
    String prompt1 = getSingleScoreSingleInputString(title);
    String score = await _fetchData(prompt1);

    String prompt2 = getCategoryPrompt(title);
    String category = await _fetchData(prompt2);
    category = category.trim();

    if (score.isNotEmpty) {
      int? scoreValue = int.tryParse(score.trim());

      if (scoreValue != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualDevice(
              title: title,
              score: scoreValue,
              category: category,
            ),
          ),
        );
      } else {
        print("Error: The fetched score is not a valid integer.");
      }
    } else {
      print("Error: Fetched score is empty.");
    }
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newDevice = '';
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Add a device',
            style: GoogleFonts.lato(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            onChanged: (value) {
              newDevice = value;
            },
            decoration: InputDecoration(
              hintText: "Enter device name",
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              filled: true,
              fillColor: accentColor.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: textColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: GoogleFonts.lato(
                    color: textColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (newDevice.isNotEmpty) {
                  _addDevice(newDevice);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Scrollbar(
        thumbVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  'My Devices',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // List of Devices
              Column(
                children: devices.map((device) {
                  IconData iconData;
                  switch (device['type']) {
                    case 'phone':
                      iconData = Icons.smartphone;
                    case 'car':
                      iconData = Icons.directions_car;
                    case 'laptop':
                      iconData = Icons.laptop;
                    default:
                      iconData = Icons.devices;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          device['name']!,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        leading: Icon(iconData, size: 30, color: textColor),
                        contentPadding: EdgeInsets.all(16),
                        onTap: () {
                          String title = device['name']!;
                          _getScorePage(title);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: textColor,
        foregroundColor: backgroundColor,
        onPressed: _showAddDeviceDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Device',
      ),
    );
  }
}
