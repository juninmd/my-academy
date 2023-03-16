import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border:  Border.all(
            color: Colors.grey,
          ) ,
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: value
              ? Icon(
            Icons.check,
            size: 16.0,
            color: Colors.black,
          )
              : Icon(
            Icons.check_box_outline_blank,
            size: 16.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
