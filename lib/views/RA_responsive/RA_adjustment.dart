import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/amount_provider.dart';
import '../../data/models/ledger/ledger_model.dart';
import '../RA_widgets/RA_D_adjustement_table.dart';

import '../SL_widgets/SL_D_side_buttons.dart';

class RA2MyDesktopBody extends StatefulWidget {
  RA2MyDesktopBody(
      {super.key, required this.location, required this.filteredLedger});

  final String location;
  List<Ledger> filteredLedger = [];

  @override
  State<RA2MyDesktopBody> createState() => _RA2MyDesktopBodyState();
}

class _RA2MyDesktopBodyState extends State<RA2MyDesktopBody> {
  double totalAmount = 0;
  double dueAmount = 0;
  double totalAmountL = 0.00;

  late TextEditingController _ledgerAmountController;

  void updateTotalAmount(double amount) {
    setState(() {
      totalAmount = amount;
    });
  }

  void updateDueAmount(double amount) {
    setState(() {
      dueAmount = amount;
    });
  }

  @override
  void initState() {
    super.initState();
    _ledgerAmountController = TextEditingController();
    // Provider.of<AmountProvider>(context, listen: false).updateAmount(0);
    Future.delayed(Duration.zero, () {
      Provider.of<AmountProvider>(context, listen: false).updateAmount(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 33, 65, 243),
                    ),
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
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45),
                        Text(
                          'RECEIVABLE ADJUSTMENT',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.005,
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.538,
                            child: Text(
                              widget.location.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ),
                          Consumer<AmountProvider>(
                            builder: (context, amountProvider, _) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: Text(
                                  amountProvider.amount.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue[900],
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              );
                            },
                          ),
                          // SLMButtons(
                          //   width: MediaQuery.of(context).size.width * 0.08,
                          //   height: 25.0,
                          //   text: 'Select All',
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Table(
                            border: TableBorder.all(color: Colors.white),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: const [
                              TableRow(
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 33, 82, 243)),
                                children: [
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Voucher',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Rcvd',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Receipt',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Due',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'DC',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Due On',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Due Days',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        'Interest',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: 550,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.00,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            widget.filteredLedger.length,
                            (index) => SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                child: Consumer<AmountProvider>(
                                  builder: (context, amountProvider, _) {
                                    return MyTable(
                                      ledgerName:
                                          widget.filteredLedger[index].name,
                                      ledgerLocation: widget
                                          .filteredLedger[index].region
                                          .toUpperCase(),
                                      ledgerMobile: widget
                                          .filteredLedger[index].mobile
                                          .toString(),
                                      id: widget.filteredLedger[index].id,
                                      updateTotalAmount: updateTotalAmount,
                                      updateDueAmount: updateDueAmount,
                                      paidAmount: amountProvider.amount,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.01,
                            // right: MediaQuery.of(context).size.width * 0.01,
                          ),
                          child: Column(
                            children: [
                              Table(
                                border: TableBorder.all(color: Colors.white),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 33, 82, 243)),
                                    children: [
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 2.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            dueAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            totalAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      const TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '0.00',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    child: const Divider(color: Colors.black),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    child: const Divider(color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: 700,
                child: Column(
                  children: [
                    SLDSideBUtton(
                      onTapped: () {},
                      text: 'P Print',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: 'F2 Report',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {
                        openDialog1(context);
                      },
                      text: 'F5 Make Receipt',
                    ),
                    SLDSideBUtton(
                      onTapped: () {
                        // Ledger Gives Money
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return Align(
                              alignment: Alignment.center,
                              child: AlertDialog(
                                title: const Text('Set Amount'),
                                content: SizedBox(
                                  height: 50.0,
                                  child: TextField(
                                    controller: _ledgerAmountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Amount',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      double enteredAmount = double.parse(
                                          _ledgerAmountController.text);

                                      amountProvider
                                          .updateAmount(enteredAmount);

                                      _ledgerAmountController.clear();

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      text: 'F6 Set Amount',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: 'F8 Send SMS',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: 'S',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    SLDSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openDialog1(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Text('Hello'),
    );
  }
}
