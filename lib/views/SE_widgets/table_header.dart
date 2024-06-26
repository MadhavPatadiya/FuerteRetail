import 'package:flutter/material.dart';

class NotaTable extends StatefulWidget {
  const NotaTable({super.key});

  @override
  State<NotaTable> createState() => _NotaTableState();
}

class _NotaTableState extends State<NotaTable> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Container(
            height: 20,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.21,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Amount',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Disc.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.041,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'D1%',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Tax%',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'SGST',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'CGST',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'IGST',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
