import 'package:flutter/material.dart';
import 'package:namer_app/individual_device.dart';

class ClickableBox extends StatefulWidget {
  final String item;
  final String image; 
  final int score;
  final String title; 

  ClickableBox({required this.item, required this.image, required this.score, required this.title});

  @override
  _ClickableBoxState createState() => _ClickableBoxState();
}

class _ClickableBoxState extends State<ClickableBox> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        print('Mouse entered');
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        print('Mouse exited');
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndividualDevice(title: widget.item, score: widget.score, category: widget.title),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE6DFF1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? Colors.red : Colors.transparent, 
              width: 2.0,
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.item,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8), 
              Image.asset(
                widget.image,
                fit: BoxFit.cover,
                height: 15, 
                width: 100,
                color: Color(0xff6750a4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}