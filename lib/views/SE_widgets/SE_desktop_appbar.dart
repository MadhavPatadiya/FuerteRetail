// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SEDesktopAppbar extends StatelessWidget {
  String text1;
  String text2;
  SEDesktopAppbar({
    super.key,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 0.5),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 30,
              color: const Color(0xff79442F),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  Text(
                    text1,
                    // 'Tax Invoice GST',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: 30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 13, 23, 33),
                    Color.fromARGB(255, 37, 65, 101),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  text2,
                  // 'Sales Entry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
