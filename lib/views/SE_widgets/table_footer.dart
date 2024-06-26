import 'package:flutter/material.dart';

class NotaTableFooter extends StatefulWidget {
  const NotaTableFooter({
    super.key,
    required this.qty,
    required this.amount,
    required this.sgst,
    required this.cgst,
    required this.igst,
    required this.discount,
    required this.netAmount,
  });

  final double qty;
  final double amount;
  final double sgst;
  final double cgst;
  final double igst;
  final double discount;
  final double netAmount;

  @override
  State<NotaTableFooter> createState() => _NotaTableFooterState();
}

class _NotaTableFooterState extends State<NotaTableFooter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.025,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide())),
            child: const Text(
              'Total',
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
            )),
            child: const Text(
              '',
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              '${widget.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
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
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              widget.amount.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              widget.discount.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.041,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: const Text(
              '',
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
            )),
            child: const Text(
              '',
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
            )),
            child: Text(
              widget.sgst.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              widget.cgst.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.061,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
            )),
            child: Text(
              widget.igst.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.059,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    right: BorderSide())),
            child: Text(
              widget.netAmount.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
