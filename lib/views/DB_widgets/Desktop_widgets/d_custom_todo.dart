import 'package:flutter/material.dart';

class DToDo extends StatelessWidget {
  const DToDo({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // ToDoList
      width: screenWidth * 0.2,
      height: 274,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
            child: const Text(
              't)  TO DO LIST',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[F9 New, F12 Completed]',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 5, 112),
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.black,
            height: 2,
          ),
          SizedBox(
            width: double.infinity,
            height: 136,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const TextField(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add your\nTodo  List Here !!!',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
