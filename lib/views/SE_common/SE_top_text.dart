import 'package:flutter/material.dart';

class SETopText extends StatelessWidget {
  const SETopText(
      {super.key, this.width, this.height, required this.text, this.padding});
  final width;
  final height;
  final String text;
  final padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: Text(
          text,
          style: const TextStyle(
            color: Color.fromARGB(255, 20, 88, 181),
            fontWeight: FontWeight.bold,
          ),
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
