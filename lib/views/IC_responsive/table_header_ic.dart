import 'package:flutter/material.dart';

class NotaTable2 extends StatefulWidget {
  const NotaTable2({super.key});

  @override
  State<NotaTable2> createState() => _NotaTableState();
}

class _NotaTableState extends State<NotaTable2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.023,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Sr',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.25,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              '   Item Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Qty',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Unit',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Rate',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide(),
                    right: BorderSide())),
            child: const Text(
              'Net Amt.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
