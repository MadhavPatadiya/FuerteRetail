import 'package:flutter/material.dart';

class NISingleTextField extends StatelessWidget {
  final String labelText;
  final int flex1;
  final int flex2;
  final TextEditingController controller;

  const NISingleTextField({
    super.key,
    required this.labelText,
    required this.flex1,
    required this.flex2,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: flex1,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '$labelText :',
              style: const TextStyle(
                  fontSize: 13, color: Color.fromARGB(255, 14, 63, 147)),
            ),
          ),
        ),
        Expanded(
          flex: flex2,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .055,
              child: TextFormField(
                controller: controller,
                onSaved: (newValue) {
                  controller.text = newValue!;
                },
                style: const TextStyle(fontWeight: FontWeight.bold),
                cursorHeight: 21,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
