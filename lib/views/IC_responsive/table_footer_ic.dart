import 'package:flutter/material.dart';

class NotaTableFooter2 extends StatefulWidget {
  const NotaTableFooter2({
    super.key,
    required this.qty,
    required this.amount,
    required this.netAmount,
  });

  final double qty;
  final double amount;
  final double netAmount;

  @override
  State<NotaTableFooter2> createState() => _NotaTableFooterState();
}

class _NotaTableFooterState extends State<NotaTableFooter2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.025,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(),
                top: BorderSide(),
                left: BorderSide(),
              ),
            ),
            child: const Text(
              'Total',
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
            )),
            child: const Text(
              '',
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              '${widget.qty}',
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
            )),
            child: const Text(
              '',
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              '${widget.amount}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.148,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    right: BorderSide())),
            child: Text(
              '${widget.netAmount}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
