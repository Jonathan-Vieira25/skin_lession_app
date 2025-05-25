

import 'dart:convert';

import 'package:flutter/material.dart';


class BarGraph extends StatelessWidget {
  final String testresult;

  const BarGraph({
    super.key,
    required this.testresult,
  });
  @override
  Widget build(BuildContext context) {
    // Convert to lists for BarGraph
    var testresult2 = testresult.replaceAll("label", "\"label\"");
    testresult2 = testresult2.replaceAll("probability", "\"probability\"");
    testresult2 = testresult2.replaceAll("df", "\"df\"");
    testresult2 = testresult2.replaceAll("nv", "\"nv\"");
    testresult2 = testresult2.replaceAll("akiec", "\"akiec\"");
    testresult2 = testresult2.replaceAll("mel", "\"mel\"");
    testresult2 = testresult2.replaceAll("bcc", "\"bcc\"");
    testresult2 = testresult2.replaceAll("bkl", "\"bkl\"");
    testresult2 = testresult2.replaceAll("vasc", "\"vasc\"");

    final List<dynamic> jsonData = json.decode(testresult2);

    // Convert to lists for BarGraph
    final labels = jsonData.map((item) => item["label"].toString()).toList();
    final values = jsonData
        .map((item) => (item["probability"] as num).toDouble())
        .toList();
    double maxValue = values.reduce((curr, next) => curr > next ? curr : next);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        children: [
          const Text(
            'Classification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                values.length,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (values[index] / maxValue) * 100,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          values[index].toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}