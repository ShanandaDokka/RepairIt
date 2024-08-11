import 'package:flutter/material.dart';
import 'package:namer_app/gemini_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'individual_device.dart';

class MyDevicesPage extends StatefulWidget {
  @override
  _MyDevicesPageState createState() => _MyDevicesPageState();
}

class _MyDevicesPageState extends State<MyDevicesPage> {
  List<Map<String, String>> devices = [];

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

  Future<void> _addDevice(String device) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> additionalDevices = prefs.getStringList('additionalDevices') ?? [];
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
            builder: (context) => IndividualDevice(title: title, score: scoreValue, category: category),
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
          title: Text('Add New Device'),
          content: TextField(
            onChanged: (value) {
              newDevice = value;
            },
            decoration: InputDecoration(hintText: "Enter device name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('My Devices'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Devices',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                IconData iconData;
                switch (devices[index]['type']) {
                  case 'phone':
                    iconData = Icons.smartphone;
                    break;
                  case 'car':
                    iconData = Icons.directions_car;
                    break;
                  case 'laptop':
                    iconData = Icons.laptop;
                    break;
                  default:
                    iconData = Icons.devices;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        devices[index]['name']!,
                        style: TextStyle(fontSize: 18),
                      ),
                      leading: Icon(iconData, size: 30),
                      contentPadding: EdgeInsets.all(16),
                      onTap: () {
                        String title = devices[index]['name']!; 
                        _getScorePage(title);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Device',
      ),
    );
  }
}