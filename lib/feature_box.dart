import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final color;
  final heading;
  final description;
  const FeatureBox({
    super.key,
    required this.color,
    required this.heading,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),

      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10),
            alignment: Alignment.topLeft,
            child: Text(
              heading,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Cera_pro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ).copyWith(bottom: 10, right: 40),
            child: Text(
              description,
              style: TextStyle(fontFamily: 'Cera_pro', color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
