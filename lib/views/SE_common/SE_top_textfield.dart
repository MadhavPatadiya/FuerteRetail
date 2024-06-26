import 'package:flutter/material.dart';

class SETopTextfield extends StatelessWidget {
  const SETopTextfield(
      {super.key,
      this.width,
      this.height,
      this.padding,
      required this.hintText,
      this.controller,
      this.onSaved});
  final width;
  final height;
  final padding;
  final controller;
  final onSaved;
  final String hintText;

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
          padding: padding,
          child: TextFormField(
            controller: controller,
            onSaved: onSaved,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
            },
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              height: 1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }
}
