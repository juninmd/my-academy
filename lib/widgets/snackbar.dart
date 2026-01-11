import 'package:flutter/material.dart';

void snackBar(BuildContext context, message) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    content: Text(message),
    duration: const Duration(seconds: 5), // Optional: Set a custom duration
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
