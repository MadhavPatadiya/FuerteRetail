import 'package:billingsphere/data/models/purchase/purchase_model.dart';
import 'package:billingsphere/data/repository/purchase_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'RA_D_table_text.dart';
import 'RA_D_table_text_2.dart';

class MyTable extends StatefulWidget {
  MyTable({
    super.key,
    required this.ledgerName,
    required this.ledgerLocation,
    required this.ledgerMobile,
    required this.id,
    required this.updateTotalAmount,
    required this.updateDueAmount,
    required this.paidAmount,
  });

  final String ledgerName;
  final String ledgerLocation;
  final String? ledgerMobile;
  final String? id;
  final void Function(double) updateTotalAmount;
  final void Function(double) updateDueAmount;
  final double paidAmount;

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  late List<bool> _isCheckedList;
  late List<double> _dueAmountList;
  bool isLoading = false;
  double totalAmount = 0;
  double dueAmount = 0;

  List<Purchase> purchase = [];

  PurchaseServices purchaseServices = PurchaseServices();

  Future<void> getPurchase() async {
    setState(() {
      isLoading = true;
    });
    final purchase = await purchaseServices.getPurchase();

    if (widget.id != null) {
      List<Purchase> filteredPurchase = [];
      for (var i = 0; i < purchase.length; i++) {
        if (purchase[i].ledger == widget.id) {
          filteredPurchase.add(purchase[i]);
        }
      }

      setState(() {
        this.purchase = filteredPurchase;
        _isCheckedList = List.generate(purchase.length, (index) => false);
        _dueAmountList = List.generate(purchase.length, (index) => 0);
        isLoading = false;
      });
    } else {
      setState(() {
        this.purchase = purchase;
        _isCheckedList = List.generate(purchase.length, (index) => false);
        _dueAmountList = List.generate(purchase.length, (index) => 0);
        isLoading = false;
      });
    }

    for (var i = 0; i < this.purchase.length; i++) {
      setState(() {
        totalAmount += double.parse(this.purchase[i].totalamount);
        dueAmount += double.parse(this.purchase[i].dueAmount!);
      });
    }

    widget.updateTotalAmount(totalAmount);
    widget.updateDueAmount(dueAmount);
  }

  @override
  void didUpdateWidget(covariant MyTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if paidAmount has changed
    if (widget.paidAmount != oldWidget.paidAmount) {
      // Call your function here
      onPaidAmountChanged();
    }
  }

  void onPaidAmountChanged() {
    double remainingAmount = widget.paidAmount;
    for (var i = 0; i < purchase.length; i++) {
      if (remainingAmount > double.parse(purchase[i].dueAmount!)) {
        setState(() {
          remainingAmount -= double.parse(purchase[i].dueAmount!);
          _dueAmountList[i] = double.parse(purchase[i].dueAmount!);
          // sales[i].dueAmount = '0';

          // Update ONLY due amount in database
        });
      } else {
        setState(() {
          _dueAmountList[i] =
              (double.parse(purchase[i].dueAmount!) - remainingAmount);
          _dueAmountList[i] = remainingAmount;
          remainingAmount = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Text('')
        : Column(
            children: [
              // First row
              Container(
                color: Colors.grey[300],
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.ledgerName} | ${widget.ledgerLocation} | M:${widget.ledgerMobile}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    MyTableText1(
                        text: purchase.map((e) => e.dueAmount!).reduce(
                            (value, element) =>
                                (double.parse(value) + double.parse(element))
                                    .toStringAsFixed(2))),
                    MyTableText1(
                        text: purchase.map((e) => e.totalamount).reduce(
                            (value, element) =>
                                (double.parse(value) + double.parse(element))
                                    .toStringAsFixed(2))),
                    const MyTableText1(text: ''),
                    const MyTableText1(text: ''),
                    const MyTableText1(text: ''),
                    const MyTableText1(text: '0'),
                  ],
                ),
              ),
              // Second row
              for (var i = 0; i < purchase.length; i++)
                Container(
                  color: Colors.grey[300],
                  child: Row(
                    children: [
                      MyTableText2(
                        text: purchase[i].date,
                        textAlign: TextAlign.center,
                      ),
                      const MyTableText2(
                        text: 'Invoice GST',
                        textAlign: TextAlign.start,
                      ),
                      MyTableText2(
                        text: purchase[i].no,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white)),
                          padding: const EdgeInsets.all(2.0),
                          child: Transform.scale(
                            scale: 0.5, // Adjust the scale factor as needed
                            child: Checkbox(
                              value: _isCheckedList[i],
                              onChanged: (bool? value) {
                                setState(() {
                                  _isCheckedList[i] = value ?? false;
                                });
                              },
                              activeColor:
                                  const Color.fromARGB(255, 33, 44, 243),
                            ),
                          ),
                        ),
                      ),
                      MyTableText2(
                        text: _dueAmountList[i].toStringAsFixed(2),
                        textAlign: TextAlign.end,
                      ),
                      MyTableText2(
                        text: double.parse(purchase[i].dueAmount!)
                            .toStringAsFixed(2),
                        textAlign: TextAlign.end,
                      ),
                      MyTableText2(
                        text: double.parse(purchase[i].totalamount)
                            .toStringAsFixed(2),
                        textAlign: TextAlign.end,
                      ),
                      MyTableText2(
                        text: purchase[i].type,
                        textAlign: TextAlign.center,
                      ),
                      MyTableText2(
                        text: purchase[i].date2,
                        textAlign: TextAlign.center,
                      ),
                      MyTableText2(
                        text: double.parse(purchase[i].dueAmount!).isEqual(0)
                            ? '0'
                            : daysBetween(parseDate(purchase[i].date2),
                                    DateTime.now())
                                .toString(),
                        textAlign: TextAlign.center,
                      ),
                      const MyTableText2(
                        text: '0',
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
            ],
          );
  }

  int daysBetween(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate);
    return difference.inDays.abs();
  }

  DateTime parseDate(String dateString) {
    return DateFormat('MM/dd/yyyy').parse(dateString);
  }
}
