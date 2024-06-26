import 'package:flutter/material.dart';

class PETextFieldsNo extends StatelessWidget {
  const PETextFieldsNo(
      {super.key, this.width, this.height, this.onSaved, this.controller});
  final width;
  final height;
  final onSaved;
  final controller;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(0),
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: TextFormField(
            controller: controller,
            onSaved: onSaved,
            style: const TextStyle(color: Colors.white, height: 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
