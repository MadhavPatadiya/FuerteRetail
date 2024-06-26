// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:billingsphere/data/models/ledger/ledger_model.dart';
import 'package:billingsphere/data/models/payment/payment_model.dart';
import 'package:billingsphere/data/repository/ledger_repository.dart';
import 'package:billingsphere/data/repository/payment_respository.dart';
import 'package:billingsphere/views/PM_widgets/entries.dart';
import 'package:billingsphere/views/PM_widgets/PM_desktopappbar.dart';
import 'package:billingsphere/views/RA_widgets/RA_D_side_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LG_responsive/LG_desktop_body.dart';
import 'payment_home.dart';
import 'payment_receipt.dart';

class PMMyPaymentDesktopBody extends StatefulWidget {
  const PMMyPaymentDesktopBody({super.key});

  @override
  State<PMMyPaymentDesktopBody> createState() => _PMMyPaymentDesktopBodyState();
}

class _PMMyPaymentDesktopBodyState extends State<PMMyPaymentDesktopBody> {
  var items = ['Dr', 'Cr'];
  var items2 = ['Dr', 'Cr'];
  final formatter = DateFormat('dd/MM/yyyy');
  List<Ledger> suggestionItems5 = [];
  String? selectedLedgerName;
  DateTime? _selectedDate;
  // TextControllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController? _narrationController = TextEditingController();

  Random random = Random();
  String formattedDay = '';
  int _generatedNumber = 0;
  double totalDebit = 0;
  double totalCredit = 0;
  int debitCount = 0;
  int creditCount = 0;
  bool isLoading = false;

  final List<Map<String, dynamic>> _allValues = [];
  final List<Entries> _newWidget = [];

  // Services
  LedgerService ledgerService = LedgerService();
  PaymentService paymentService = PaymentService();

  List<String>? companyCode;
  Future<List<String>?> getCompanyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('companies');
  }

  Future<void> setCompanyCode() async {
    List<String>? code = await getCompanyCode();
    setState(() {
      companyCode = code;
      print(companyCode);
    });
  }

  @override
  void initState() {
    super.initState();

    _initializeData();
  }

  // Calculate total debit and credit
  void calculateTotal() {
    totalDebit = 0;
    totalCredit = 0;
    debitCount = 0;
    creditCount = 0;
    for (var values in _allValues) {
      String dropdownValue = values['dropdownValue'];
      double debit = double.tryParse(values['debit']) ?? 0;
      double credit = double.tryParse(values['credit']) ?? 0;

      if (dropdownValue == 'Dr') {
        totalDebit += debit;
        debitCount++;
      } else if (dropdownValue == 'Cr') {
        totalCredit += credit;
        creditCount++;
      }
    }

    setState(() {
      totalDebit = totalDebit;
      totalCredit = totalCredit;
      debitCount = debitCount;
      creditCount = creditCount;
    });

    // Fluttertoast.showToast(
    //   msg: "Values added to list successfully!",
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.CENTER_RIGHT,
    //   webPosition: "right",
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.black,
    //   textColor: Colors.white,
    // );
  }

  // API Call to fetch ledgers
  Future<void> fetchAndSetLedgers() async {
    try {
      final List<Ledger> ledgers = await ledgerService.fetchLedgers();

      setState(() {
        suggestionItems5 = ledgers;
        selectedLedgerName =
            suggestionItems5.isNotEmpty ? suggestionItems5.first.id : null;
        _dateController.text = formatter.format(DateTime.now());
      });

      print('Ledgers: ${suggestionItems5.length}');
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  void _initializeData() async {
    await setCompanyCode();
    await fetchAndSetLedgers();
    _generateRandomNumber();
  }

  Future<void> savePayment() async {
    setState(() {
      isLoading = true;
    });

    // // Debug prints to trace values
    // print('companyCode: $companyCode');
    // print('totalCredit: $totalCredit');
    // print('totalDebit: $totalDebit');
    // print('no: ${_noController.text}');
    // print('date: ${_dateController.text}');
    // print('entries: $_allValues');
    // print('narration: ${_narrationController?.text}');

    if (companyCode == null ||
        _noController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _allValues.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Required fields are missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payment = Payment(
      id: '',
      companyCode: companyCode!.first,
      totalamount: (totalCredit + totalDebit),
      no: _noController.text,
      date: _dateController.text,
      entries: _allValues.map((e) {
        return Entry(
          account: e['dropdownValue'],
          ledger: e['selectedLedgerName'],
          remark: e['remark'],
          debit: double.tryParse(e['debit']) ?? 0,
          credit: double.tryParse(e['credit']) ?? 0,
        );
      }).toList(),
      billwise: [],
      narration: _narrationController?.text ?? 'No Narration',
    );

    print('Payment object created: ${payment.toJson()}');

    await paymentService.createPayment(payment, context).then((value) {
      setState(() {
        isLoading = false;
      });
      // Clear all controllers, values and widgets
      _noController.clear();
      _dateController.clear();
      _narrationController?.clear();
      _allValues.clear();
      _newWidget.clear();
      totalDebit = 0;
      totalCredit = 0;
      debitCount = 0;
      creditCount = 0;
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save payment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // Generate Random Numbers
  void _generateRandomNumber() {
    setState(() {
      _generatedNumber = Random().nextInt(9000) + 100;
      _noController.text = _generatedNumber.toString();
    });
  }

// Function to save values from Entries widget
  void saveValues(Map<String, dynamic> values) {
    final String uniqueKey = values['uniqueKey'];

    // Check if an entry with the same uniqueKey exists
    final existingEntryIndex =
        _allValues.indexWhere((entry) => entry['uniqueKey'] == uniqueKey);

    setState(() {
      if (existingEntryIndex != -1) {
        _allValues.removeAt(existingEntryIndex);
      }

      // Add the latest values
      _allValues.add(values);
    });
  }

  // Date Picker
  void _presentDatePICKER() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final _pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
    );

    if (_pickedDate != null) {
      setState(() {
        _selectedDate = _pickedDate;
        _dateController.text = formatter.format(_pickedDate);
        formattedDay = DateFormat('EEEE').format(_selectedDate!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _noController.dispose();
    _narrationController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Opacity(
          opacity: isLoading ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .06,
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: const Color(0xff79442F),
                        child: Center(
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
                              const SizedBox(
                                width: 80,
                              ),
                              const Text(
                                'Payment',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: const Color.fromARGB(255, 151, 111, 25),
                        child: const Center(
                            child: Text(
                          'Voucher Entry',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        )),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0),
                    child: Container(
                      width: mediaQuery.size.width * 0.901,
                      height: 1000,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,

                          //                   <--- border width here
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.898,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width: 40,
                                                    child: Text(
                                                      'No :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  88, 0, 103),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: mediaQuery.size.width *
                                                      0.05,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    controller: _noController,
                                                    enabled: true,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    cursorHeight: 18,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(10.0),
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      'Date :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  88, 0, 103),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: mediaQuery.size.width *
                                                      0.08,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    controller: _dateController,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 17),
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'Select Date',
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10.0)),
                                                    onTap: () {
                                                      _presentDatePICKER();
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, top: 3),
                                                  child: Text(
                                                    formattedDay,
                                                    style: GoogleFonts.poppins(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 88, 0, 103),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.898,
                                        height: 45,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, top: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                child: Text(
                                                  'Dr/Cr ',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 88, 0, 103),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  '  Ledger Name ',
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 88, 0, 103),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  '  Remark',
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 88, 0, 103),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                child: Text(
                                                  '  Credit',
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 88, 0, 103),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                child: Text(
                                                  '  Debit',
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 88, 0, 103),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.898,
                                        height: 383,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(width: 1)),
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: [
                                              Column(
                                                children: _newWidget,
                                              ),
                                              const SizedBox(height: 10),
                                              _allValues.isEmpty
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'No Entries Added',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ],
                                                    )
                                                  : OutlinedButton(
                                                      onPressed: calculateTotal,
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        side: const BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: Text(
                                                        'Save All Entries',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.898,
                                        height: 180,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.09,
                                                  child: Text('Narration :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  88, 0, 103),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18)),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1, top: 0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.310,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextField(
                                                      controller:
                                                          _narrationController,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 2,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Spacer(), // Use Spacer widget to fill remaining space
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 1),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: const Border(
                                                                bottom:
                                                                    BorderSide(
                                                                        width:
                                                                            3)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5),
                                                            child: Text(
                                                                '\$${totalDebit.toStringAsFixed(2)}', // Total Dr
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: GoogleFonts.poppins(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        88,
                                                                        0,
                                                                        103),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15)),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 1),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: const Border(
                                                                bottom:
                                                                    BorderSide(
                                                                        width:
                                                                            3)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5),
                                                            child: Text(
                                                                '\$${totalCredit.toStringAsFixed(2)}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: GoogleFonts.poppins(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        88,
                                                                        0,
                                                                        103),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 1),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5),
                                                            child: Text(
                                                                '[$debitCount] Dr',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: GoogleFonts.poppins(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        88,
                                                                        0,
                                                                        103),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15)),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 1),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5),
                                                            child: Text(
                                                                '[$creditCount] Cr',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: GoogleFonts.poppins(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        88,
                                                                        0,
                                                                        103),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15)),
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
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.898,
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 0),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 150,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                savePayment,
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                const Color
                                                                    .fromARGB(
                                                                    172,
                                                                    236,
                                                                    226,
                                                                    137),
                                                              ),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      OutlinedBorder>(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              1.0),
                                                                  side:
                                                                      const BorderSide(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            88,
                                                                            81,
                                                                            11),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  'Save [F4]',
                                                                  style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          18)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15),
                                                          child: SizedBox(
                                                            width: 120,
                                                            height: 30,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {},
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all<
                                                                            Color>(
                                                                  const Color
                                                                      .fromARGB(
                                                                      172,
                                                                      236,
                                                                      226,
                                                                      137),
                                                                ),
                                                                shape: MaterialStateProperty
                                                                    .all<
                                                                        OutlinedBorder>(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            1.0),
                                                                    side:
                                                                        const BorderSide(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          88,
                                                                          81,
                                                                          11),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    'Cancel',
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            18)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15),
                                                          child: SizedBox(
                                                            width: 120,
                                                            height: 30,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {},
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all<
                                                                            Color>(
                                                                  const Color
                                                                      .fromARGB(
                                                                      172,
                                                                      236,
                                                                      226,
                                                                      137),
                                                                ),
                                                                shape: MaterialStateProperty
                                                                    .all<
                                                                        OutlinedBorder>(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            1.0),
                                                                    side:
                                                                        const BorderSide(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          88,
                                                                          81,
                                                                          11),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  'Delete',
                                                                  style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                    child: Column(
                      children: [
                        DSideBUtton(
                          onTapped: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const PaymentHome(),
                              ),
                            );
                          },
                          text: 'F2 List',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'P Print',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F5 Payment',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F6 Receipt',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F7 Journal',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F8 Contra',
                        ),
                        DSideBUtton(
                          onTapped: () {
                            if (suggestionItems5.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "No Ledger found! Please add a ledger",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 5,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              ).then((value) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LGMyDesktopBody(),
                                  ),
                                );
                              });
                              return;
                            }
                            final entryId = UniqueKey().toString();
                            setState(() {
                              _newWidget.add(Entries(
                                key: ValueKey(entryId),
                                dropdownItems: items,
                                suggestionItems5: suggestionItems5,
                                dropdownValue: 'Dr',
                                selectedLedgerName: selectedLedgerName,
                                onSaveValues: saveValues,
                                entryId: entryId,
                                onDelete: (String entryId) {
                                  setState(() {
                                    _newWidget.removeWhere((widget) =>
                                        widget.key == ValueKey(entryId));

                                    // Find the map in _allValues that contains the entry with the specified entryId
                                    Map<String, dynamic>? entryToRemove;
                                    for (final entry in _allValues) {
                                      if (entry['uniqueKey'] == entryId) {
                                        entryToRemove = entry;
                                        break;
                                      }
                                    }

                                    // Remove the map from _allValues if found
                                    if (entryToRemove != null) {
                                      _allValues.remove(entryToRemove);
                                    }
                                  });
                                },
                              ));
                            });
                          },
                          text: 'F12 Create New',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'PgUp Previous',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'PgDn Next',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F12 Audit Trail',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'F10 Change Vch.',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'D Goto Date',
                        ),
                        DSideBUtton(
                          onTapped: () {
                            print(_allValues);
                          },
                          text: 'Save Entries',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'G Attach. Img',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'G Vch Setup',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: 'T Print Setup',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                        DSideBUtton(
                          onTapped: () {},
                          text: '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
