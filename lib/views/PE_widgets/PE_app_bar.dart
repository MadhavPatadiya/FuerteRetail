// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PECustomAppBar extends StatelessWidget {
  final VoidCallback onPressed;
  const PECustomAppBar({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(
        //     CupertinoIcons.arrow_left,
        //     color: Colors.black,
        //     size: 15,
        //   ),
        // ),
        Expanded(
          flex: 1,
          child: Container(
            height: 30,
            color: const Color(0xff70402a),
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
                Spacer(),
                Text(
                  'Retail Purchase',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            height: 30,
            color: const Color(0xffa07d40),
            child: Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Purchase Entry',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: onPressed,
                    icon: const Icon(
                      CupertinoIcons.refresh_bold,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
