import 'package:flutter/material.dart';

Widget buildInfoItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
