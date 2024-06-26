import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class PoPUP extends StatelessWidget {
  final Widget listWidget;
  final double totalAmount;
  final VoidCallback onSaveData;
  final Map<String, dynamic> multimodeDetails;

  PoPUP({
    super.key,
    required this.totalAmount,
    required this.listWidget,
    required this.onSaveData,
    required this.multimodeDetails,
  });

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllercash = TextEditingController();
  final TextEditingController _controllerdebit = TextEditingController();
  final TextEditingController _controlleradjustedamount =
      TextEditingController();
  final TextEditingController _controllerpending = TextEditingController();
  final TextEditingController _controllertotal = TextEditingController();

  String defaultValue = "0.00";
  void saveMultiModeValues() {
    double cashValue = double.tryParse(_controllercash.text) ?? 0.0;
    double debitValue = double.tryParse(_controllerdebit.text) ?? 0.0;
    double adjustedamountValue =
        double.tryParse(_controlleradjustedamount.text) ?? 0.0;
    double cashPending = double.tryParse(_controllerpending.text) ?? 0.0;
    double cashFinalAmount = double.tryParse(_controllertotal.text) ?? 0.0;

    multimodeDetails['cash'] = cashValue;
    multimodeDetails['debit'] = debitValue;
    multimodeDetails['adjustedamount'] = adjustedamountValue;
    multimodeDetails['pendingAmount'] = cashPending;
    multimodeDetails['finalAmount'] = cashFinalAmount;
    // print(multimodeDetails);
  }

  void grandtotal() {
    double grandtotal = 0.0;

    grandtotal += double.tryParse(_controllercash.text) ?? 0.0;
    grandtotal += double.tryParse(_controllerdebit.text) ?? 0.0;
    grandtotal -= double.tryParse(_controlleradjustedamount.text) ?? 0.0;

    _controllertotal.text = grandtotal.toStringAsFixed(2);
  }

  void voidpending() {
    double total = double.tryParse(_controllertotal.text) ?? 0.0;
    double pendingAmount = totalAmount - total;

    _controllerpending.text = pendingAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4169E1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Multiple Payment Receipt Details',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 246, 246, 246),
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Total Amount To Receive",
                        style: TextStyle(
                            color: Color.fromRGBO(75, 0, 130, 1),
                            fontWeight: FontWeight.bold),
                      ),
                      20.widthBox,
                      Expanded(
                        child: TextFormField(
                          cursorColor: Colors.black,
                          readOnly: true,
                          controller: _controller
                            ..text = totalAmount.toStringAsFixed(2),
                          textDirection: TextDirection.rtl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                              fontSize: 15.5, fontWeight: FontWeight.w500),
                          onChanged: (value) {
                            print("Total Amount changed: $value");
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 10.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        ).h(25),
                      ),
                    ],
                  ).pOnly(right: 30, left: 5).h(60),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 25,
                        width: 220,
                        child: Text(
                          "Payment Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      1.widthBox,
                      Expanded(
                        child: const SizedBox(
                          height: 25,
                          width: 200,
                          child: Text(
                            "Amount",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ).pOnly(right: 30),
                      ),
                    ],
                  ).pOnly(left: 5),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CurrencyRow(
                                  heading: "Cash",
                                  isTrue: false,
                                  inputController: _controllercash,
                                  onAmountChanged: (newValue) {
                                    grandtotal();
                                    voidpending();
                                    saveMultiModeValues();
                                  },
                                )
                              ],
                            ).pOnly(right: 30, top: 2),
                            Row(
                              children: [
                                CurrencyRow(
                                  heading: "Debit",
                                  isTrue: false,
                                  inputController: _controllerdebit,
                                  onAmountChanged: (newValue) {
                                    grandtotal();
                                    voidpending();
                                    saveMultiModeValues();
                                  },
                                )
                              ],
                            ).pOnly(right: 30, top: 2),
                            Row(
                              children: [
                                CurrencyRow(
                                  heading: "Adjust Amount ",
                                  isTrue: false,
                                  inputController: _controlleradjustedamount,
                                  onAmountChanged: (newValue) {
                                    grandtotal();
                                    voidpending();
                                    saveMultiModeValues();
                                  },
                                )
                              ],
                            ).pOnly(right: 30, top: 2),
                          ],
                        ),
                      ),
                    ).pOnly(right: 30, left: 5),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      // Pending Amount Text Field
                      Row(
                        children: [
                          const SizedBox(
                            height: 25,
                            width: 200,
                            child: Text(
                              "Pending",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          1.widthBox,
                          Expanded(
                            child: SizedBox(
                              width: 65,
                              height: 25,
                              child: TextFormField(
                                readOnly: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                controller: _controllerpending,
                                cursorColor: Colors.black,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).pOnly(right: 30, top: 2),
                      const SizedBox(
                        height: 10,
                      ),

                      // Total Amount Text Field
                      Row(
                        children: [
                          const SizedBox(
                            height: 25,
                            width: 200,
                            child: Text(
                              "Total Amount",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          1.widthBox,
                          Expanded(
                            child: SizedBox(
                              width: 65,
                              height: 25,
                              child: TextFormField(
                                readOnly: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                controller: _controllertotal,
                                cursorColor: Colors.black,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500),
                                onChanged: (value) {
                                  print("object..........$value");
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).pOnly(right: 30, top: 2),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 30,
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              color: const Color.fromARGB(255, 250, 237, 126),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (_controllerpending.text != defaultValue) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Error!',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Text(
                                          'Receipt Amount do not match with Bill Amount.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                } else {
                                  onSaveData();
                                }
                              },
                              child: const Center(
                                child: Text(
                                  "Save[F4]",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          3.widthBox,
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              color: const Color.fromARGB(255, 250, 237, 126),
                            ),
                            height: 30,
                            width: 150,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ).pOnly(right: 30),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ).pOnly(left: 5),
                ],
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(255, 246, 246, 246),
            width: 300,
            height: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 50),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                color: Colors.white,
              ),
              padding: EdgeInsets.zero,
              // child: listWidget,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 145,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          'Group Sales',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4B0082),
                              fontWeight: FontWeight.bold),
                        ).p2(),
                      ),
                      Container(
                        width: 145,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          'Amount',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4B0082),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ).p2(),
                      ),
                    ],
                  ),
                  listWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyRow extends StatelessWidget {
  final String heading;
  final bool isTrue;
  final TextEditingController inputController;
  final Function(double) onAmountChanged;

  CurrencyRow({
    Key? key,
    required this.heading,
    required this.isTrue,
    required this.inputController,
    required this.onAmountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            height: 25,
            width: 200,
            decoration:
                isTrue ? null : BoxDecoration(border: Border.all(width: 1)),
            child: Text(
              heading,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          1.widthBox,
          Expanded(
            child: SizedBox(
              width: 65,
              height: 25,
              child: TextFormField(
                controller: inputController,
                cursorColor: Colors.black,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.end,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                style: GoogleFonts.poppins(
                    fontSize: 15.5, fontWeight: FontWeight.w500),
                onChanged: (_) {
                  final double newValue =
                      double.tryParse(inputController.text) ?? 0.0;

                  onAmountChanged(newValue);
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 10.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
