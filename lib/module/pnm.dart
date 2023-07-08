import 'dart:math';

import 'package:flutter/material.dart';

class PNMModule extends StatefulWidget {
  const PNMModule({super.key});

  @override
  State<PNMModule> createState() => _PNMModuleState();
}

class _PNMModuleState extends State<PNMModule> {
  double _chanceOfJoining = 1.0;

  Color getGradientColor(double value) {
    if (value < 0.5) {
      return Color.lerp(Colors.red, Colors.yellow, value * 2)!;
    }
    return Color.lerp(Colors.yellow, Colors.green, (value - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {

    
    Color gradeColor = getGradientColor(_chanceOfJoining);
    return GestureDetector(
      onTap: () => setState(() {
        _chanceOfJoining = Random().nextDouble();
      }),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
                image: NetworkImage(
                    "data:image/jpeg;base64,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"),
                fit: BoxFit.cover,
                opacity: 0.50),
            boxShadow: [
              BoxShadow(
                color: gradeColor,
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              children: [
                const Positioned.fill(
                    child: ColoredBox(color: Color.fromARGB(100, 0, 0, 0))),
                Positioned(
                  bottom: 0,
                  left: 10,
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Patrick",
                            style: TextStyle(
                                fontSize: 45,
                                color: gradeColor,
                                fontWeight: FontWeight.bold,
                                height: 1)),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "McGuire",
                          style: TextStyle(
                              fontSize: 40,
                              color: gradeColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 10,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      (_chanceOfJoining * 100).toStringAsFixed(0),
                      style: TextStyle(
                          fontSize: 40,
                          color: gradeColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
