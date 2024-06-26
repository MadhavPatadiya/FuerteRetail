import 'package:flutter/material.dart';

class PETextFields extends StatelessWidget {
  const PETextFields(
      {super.key,
      this.width,
      this.height,
      this.controller,
      this.onSaved,
      this.readOnly});
  final width;
  final height;
  final controller;
  final onSaved;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 14.0),
          child: TextFormField(
            readOnly: readOnly ?? false,
            onSaved: onSaved,
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
