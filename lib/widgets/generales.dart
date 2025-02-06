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

Widget buildCabeceraItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Column(
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
