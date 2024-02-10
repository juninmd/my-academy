import 'package:flutter/material.dart';

void snackBar(
  BuildContext context,
  message,
) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
    content: Text(message),
    duration: Duration(seconds: 5), // Optional: Set a custom duration
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
