import 'package:flutter/material.dart';

void showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade900),
            const SizedBox(width: 5),
            const Text(
              "Error",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

Future<void> showOk(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.beenhere,
              color: Colors.green.shade900,
            ),
            const SizedBox(width: 5),
            const Text(
              "Éxito",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

void showAdvertence(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.yellowAccent.shade700,
            ),
            const SizedBox(width: 5),
            const Text(
              "Éxito",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

Widget buildFormRow({required String label, required Widget child}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          label,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
      ),
      Expanded(child: child),
    ],
  );
}
