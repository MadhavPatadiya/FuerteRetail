import 'package:flutter/material.dart';

class RAMButtons extends StatelessWidget {
  final text;
  final width;
  final height;
  final onPressed;
  const RAMButtons(
      {super.key, this.text, this.width, this.height, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 255, 243, 132),
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.0),
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
