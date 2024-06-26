import 'package:billingsphere/views/RV_widgets/cstmTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/receiptVoucher/receipt_voucher_model.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/receipt_voucher_repository.dart';
import '../PEresponsive/PE_desktop_body.dart';
import '../sumit_screen/voucher _entry.dart/voucher_list_widget.dart';
import 'RV_Master.dart';
import 'RV_receipt.dart';

class RVDesktopBody extends StatefulWidget {
  const RVDesktopBody({super.key});

  @override
  State<RVDesktopBody> createState() => _DesktopBodyState();
}

class _DesktopBodyState extends State<RVDesktopBody> {
  String dropdownValue = 'Dr'; // Initial value for the dropdown

  final FocusNode _focusNode = FocusNode();
  Color backgroundColor = Colors.transparent;
  Color textColor = Colors.black; // Initial text color
  bool isLoading = false;
  double totalDebit = 0;
  double totalCredit = 0;
  int debitCount = 0;
  int creditCount = 0;
  double ledgerAmount = 0;
  String ledgerName = '';
  int ledgerMo = 0;
  String ledgerState = '';
  int _generatedNumber = 0;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  DateTime? _selectedDate;
// Define a TextEditingController
  final TextEditingController _totaldebitController = TextEditingController();
  final TextEditingController _totalcreditController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  //ledger
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _debitController = TextEditingController();
  final TextEditingController typecontroller =
      TextEditingController(text: 'Cr');
  //entires 2
  final TextEditingController _type2controller =
      TextEditingController(text: 'Dr');
  final TextEditingController _cashtypecontroller =
      TextEditingController(text: 'Cash In Hand');
  final TextEditingController _remark2Controller = TextEditingController();
  final TextEditingController _debit2Controller = TextEditingController();
  final TextEditingController _credit2Controller = TextEditingController();

  bool isCredit = true;
  bool isDebit = false;
  bool isCredit2 = false;
  bool isDebit2 = true;

// ...

// Fetch
  List<Ledger> suggestionItems5 = [];
  List<ReceiptVoucher> suggestionItems6 = [];
  String? selectedLedgerName;
  ReceiptVoucherService receiptVoucherService = ReceiptVoucherService();
  String? selectedId;

  List<String>? companyCode;
  Future<List<String>?> getCompanyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('companies');
  }

  Future<void> setCompanyCode() async {
    List<String>? code = await getCompanyCode();
    setState(() {
      companyCode = code;
    });
  }

  LedgerService ledgerService = LedgerService();
  Ledger? _ledgers;

  // API Call to fetch ledgers
  Future<void> fetchLedgers2() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<Ledger> ledger = await ledgerService.fetchLedgers();

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        suggestionItems5 =
            ledger.where((element) => element.status == 'Yes').toList();

        selectedLedgerName =
            suggestionItems5.isNotEmpty ? suggestionItems5.first.id : null;
        ledgerAmount = suggestionItems5.first.debitBalance;
        ledgerName = suggestionItems5.first.name;
        ledgerMo = suggestionItems5.first.mobile;
        ledgerState = suggestionItems5.first.state;

        isLoading = false;
      });
    } catch (error) {
      suggestionItems5.isEmpty
          ? ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add Ledger"),
                backgroundColor: Colors.grey,
              ),
            )
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
    }
  }

  Future<void> fetchAllReceipt() async {
    final List<ReceiptVoucher> receipt =
        await receiptVoucherService.fetchReceiptVoucherEntries();

    setState(() {
      suggestionItems6 = receipt;
      _generateRandomNumber();

      if (suggestionItems6.isNotEmpty) {
        selectedId = suggestionItems6[0].id;
      }
    });
  }

// Function to save Receipt Voucher
  Future<void> saveReceiptVoucher() async {
    if (_totaldebitController.text.isEmpty ||
        _totalcreditController.text.isEmpty) {
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
            content: Text('Please Add Amount',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
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
    }
    setState(() {
      isLoading = true;
    });

    final receipt = ReceiptVoucher(
      companyCode: companyCode!.first,
      totaldebitamount: double.tryParse(_totaldebitController.text) ?? 0.0,
      totalcreditamount: double.tryParse(_totalcreditController.text) ?? 0.0,
      no: int.parse(_noController.text),
      date: _dateController.text,
      naration: _narrationController!.text,
      account: typecontroller.text,
      ledger: selectedLedgerName!,
      remark: _remarkController.text,
      debit: double.tryParse(_debitController.text) ?? 0.0,
      credit: double.tryParse(_creditController.text) ?? 0.0,
      cashaccount: _type2controller.text,
      cashtype: _cashtypecontroller.text,
      cashremark: _remark2Controller.text,
      cashdebit: double.tryParse(_debit2Controller.text) ?? 0.0,
      cashcredit: double.tryParse(_credit2Controller.text) ?? 0.0,
      id: '',
    );

    await receiptVoucherService
        .createReciptVoucher(receipt: receipt)
        .then((value) {
      setState(() {
        isLoading = false;
      });

      _dateController.clear();
      _noController.clear();
      _narrationController?.clear();

      // _showToast("Receipt Voucher Created.");
      fetchAllReceipt().then((_) {
        final newReceipt = suggestionItems6.firstWhere(
          (element) => element.no == receipt.no,
          orElse: () => ReceiptVoucher(
            id: '',
            no: 0,
            date: '',
            account: '',
            cashaccount: '',
            cashcredit: 0,
            cashdebit: 0,
            cashremark: '',
            cashtype: '',
            companyCode: '',
            credit: 0,
            debit: 0,
            ledger: '',
            naration: '',
            remark: '',
            totalcreditamount: 0,
            totaldebitamount: 0,
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Print Receipt"),
              content: const Text("Do you want to print the receipt?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ReceiptVoucherPrint(
                          receiptID: newReceipt.id,
                          'Print Receip Voucher',
                        ),
                      ),
                    );
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Add code to handle printing here
                  },
                  child: const Text("No"),
                ),
              ],
            );
          },
        );
      });
   
   
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save payment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _generateRandomNumber() {
    setState(() {
      if (suggestionItems6.isEmpty) {
        _generatedNumber = 1;
      } else {
        // Find the maximum no value in suggestionItems6
        int maxNo = suggestionItems6
            .map((e) => e.no)
            .reduce((value, element) => value > element ? value : element);
        _generatedNumber = maxNo + 1;
      }
      _noController.text = _generatedNumber.toString();
    });
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        print(_dateController.text);
      });
    }
  }

  void _updatedebitTotal() {
    setState(() {
      double field1 = double.tryParse(_debitController.text) ?? 0;
      double field2 = double.tryParse(_debit2Controller.text) ?? 0;
      _totaldebitController.text = (field1 + field2).toString();
    });
  }

  void _updatecreditTotal() {
    setState(() {
      double field1 = double.tryParse(_creditController.text) ?? 0;
      double field2 = double.tryParse(_credit2Controller.text) ?? 0;
      _totalcreditController.text = (field1 + field2).toString();
    });
  }

  void _initializeData() async {
    await setCompanyCode();
    await fetchLedgers2();
    await fetchAllReceipt();
    // _generateRandomNumber();
  }

  void _initializaControllers() {
    _noController.text = _generatedNumber.toString();

    _dateController.text = formatter.format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _generateRandomNumber();
    _initializaControllers();
    _debitController.addListener(_updatedebitTotal);
    _debit2Controller.addListener(_updatedebitTotal);
    _creditController.addListener(_updatecreditTotal);
    _credit2Controller.addListener(_updatecreditTotal);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .06,
              width: MediaQuery.of(context).size.width * 1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 161, 78, 53),
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
                            const Text(
                              'Receipt',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.green[300],
                      child: const Center(
                          child: Text(
                        'Voucher Entry',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: RVCustomTextFieldWidget(
                                    controller: _noController,
                                    labelText: 'No ',
                                    textFieldHeight: 30,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                            .1)),
                            Expanded(
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text(
                                      'Date:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SizedBox(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width *
                                          0.11,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _dateController,
                                              // focusNode: _focusNode,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              cursorHeight: 21,
                                              cursorColor: Colors.white,
                                              cursorWidth: 1,
                                              textAlignVertical:
                                                  TextAlignVertical.top,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: backgroundColor,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.calendar_month),
                                            onPressed: () {
                                              _selectDate(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Expanded(flex: 1, child: Text('wed'))
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
                          height: 45,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Row(children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.06,
                              child: const Text(
                                'Dr/Cr',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.deepPurple),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: const Text('  Ledger Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepPurple)),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: const Text('  Remark',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepPurple)),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: const Text('  Debit',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepPurple)),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: const Text('  Credit',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepPurple)),
                            ),
                          ]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.898,
                          height: 300,
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1)),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      // padding: const EdgeInsets.only(top: 10),
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          String>(
                                                        value:
                                                            typecontroller.text,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            typecontroller
                                                                    .text =
                                                                newValue!;

                                                            if (newValue ==
                                                                'Cr') {
                                                              setState(() {
                                                                isCredit = true;
                                                                isDebit = false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isCredit =
                                                                    false;
                                                                isDebit = true;
                                                              });
                                                            }
                                                          });
                                                        },
                                                        items: <String>[
                                                          'Dr',
                                                          'Cr'
                                                        ].map((String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 4,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      value: selectedLedgerName,
                                                      underline: Container(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedLedgerName =
                                                              newValue!;
                                                          if (selectedLedgerName !=
                                                              null) {
                                                            final selectedLedger =
                                                                suggestionItems5.firstWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        selectedLedgerName);

                                                            ledgerAmount =
                                                                selectedLedger
                                                                    .debitBalance;
                                                            ledgerName =
                                                                selectedLedger
                                                                    .name;
                                                            ledgerMo =
                                                                selectedLedger
                                                                    .mobile;
                                                            ledgerState =
                                                                selectedLedger
                                                                    .state;
                                                          }
                                                        });
                                                      },
                                                      items: suggestionItems5
                                                          .map((Ledger ledger) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: ledger.id,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                ledger.name,
                                                              ),
                                                            ],
                                                          ), // Assuming `name` is the property containing the ledger name
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 4,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    controller:
                                                        _remarkController,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    enabled: isDebit,
                                                    controller:
                                                        _debitController,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*$')), // Allow digits and a single decimal point
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    enabled: isCredit,
                                                    controller:
                                                        _creditController,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*$')), // Allow digits and a single decimal point
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      // padding: const EdgeInsets.only(top: 10),
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          String>(
                                                        value: _type2controller
                                                            .text,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            _type2controller
                                                                    .text =
                                                                newValue!;

                                                            if (newValue ==
                                                                'Cr') {
                                                              setState(() {
                                                                isCredit2 =
                                                                    true;
                                                                isDebit2 =
                                                                    false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isCredit2 =
                                                                    false;
                                                                isDebit2 = true;
                                                              });
                                                            }
                                                          });
                                                        },
                                                        items: <String>[
                                                          'Dr',
                                                          'Cr'
                                                        ].map((String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 4,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      value: _cashtypecontroller
                                                          .text,
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          _cashtypecontroller
                                                              .text = newValue!;
                                                        });
                                                      },
                                                      items: <String>[
                                                        'Cash In Hand',
                                                        'Cheque'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 4,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    controller:
                                                        _remark2Controller,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    enabled: isDebit2,
                                                    controller:
                                                        _debit2Controller,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*$')), // Allow digits and a single decimal point
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: TextFormField(
                                                    cursorHeight: 18,
                                                    enabled: isCredit2,
                                                    controller:
                                                        _credit2Controller,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(14.0),
                                                    ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*$')), // Allow digits and a single decimal point
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
                          ),
                        ),

                        // RVMyRow()
                      ]),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .4,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RVCustomTextFieldWidget(
                                    controller: _narrationController!,
                                    labelText: 'Narration',
                                    textFieldHeight: 50,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width * .3),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .31,
                                    height:
                                        MediaQuery.of(context).size.height * .2,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Column(
                                      children: [
                                        const Text('Ledger Information',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.deepPurple)),
                                        Container(
                                          height: 30,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .31,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  top: BorderSide(
                                                      color: Colors.black),
                                                  bottom: BorderSide(
                                                      color: Colors.black))),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Limit',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Colors.deepPurple),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: const Color.fromARGB(
                                                      255, 161, 78, 53),
                                                  child: const Center(
                                                    child: Text(
                                                      '0.00',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Bal',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Colors.deepPurple),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: const Color.fromARGB(
                                                      255, 161, 78, 53),
                                                  child: Center(
                                                    child: Text(
                                                      ledgerAmount
                                                          .toStringAsFixed(2),
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Cont. Person: $ledgerName',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'M: ${ledgerMo.toString()}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          ledgerState,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .01,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 1),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              border: const Border(
                                                  bottom: BorderSide(width: 3)),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            child: TextFormField(
                                              controller: _totaldebitController,
                                              readOnly: true,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 113, 8, 170),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(14.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 1),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              border: const Border(
                                                  bottom: BorderSide(width: 3)),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextFormField(
                                                readOnly: true,
                                                controller:
                                                    _totalcreditController,
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 113, 8, 170),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(12.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 1),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                'Dr',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 113, 8, 170),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 1),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                'Cr',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 113, 8, 170),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .01,
                                ),
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(
                                            MediaQuery.of(context).size.width *
                                                .1,
                                            25),
                                        shape: const BeveledRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: .3)),
                                        backgroundColor:
                                            Colors.yellow.shade100),
                                    onPressed: saveReceiptVoucher,
                                    child: const Text(
                                      'Save [F4]',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .002,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(
                                            MediaQuery.of(context).size.width *
                                                .1,
                                            25),
                                        shape: const BeveledRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: .3)),
                                        backgroundColor:
                                            Colors.yellow.shade100),
                                    onPressed: () {},
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .002,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(
                                            MediaQuery.of(context).size.width *
                                                .1,
                                            25),
                                        shape: const BeveledRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: .3)),
                                        backgroundColor:
                                            Colors.yellow.shade100),
                                    onPressed: () {},
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Shortcuts(
                  shortcuts: {
                    LogicalKeySet(LogicalKeyboardKey.f3):
                        const ActivateIntent(),
                    LogicalKeySet(LogicalKeyboardKey.f4):
                        const ActivateIntent(),
                  },
                  child: Focus(
                    autofocus: true,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.f2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ReceiptVoucherHome(),
                          ),
                        );
                        return KeyEventResult.handled;
                      } else if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.keyB) {
                      } else if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.keyM) {
                      } else if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.keyL) {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => const LGMyDesktopBody(),
                        //   ),
                        // );
                      } else if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.keyA) {}
                      return KeyEventResult.ignored;
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.099,
                      child: Column(
                        children: [
                          CustomList(
                            Skey: "F2",
                            name: "List",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReceiptVoucherHome(),
                                ),
                              );
                            },
                          ),
                          CustomList(
                            Skey: "P",
                            name: "Print",
                            onTap: () {},
                          ),
                          CustomList(Skey: "P", name: "Print", onTap: () {}),
                          CustomList(
                            Skey: "F5",
                            name: "Payment",
                            onTap: () {},
                          ),
                          CustomList(Skey: "F6", name: "Receipt", onTap: () {}),
                          CustomList(Skey: "", name: "", onTap: () {}),
                          CustomList(Skey: "F7", name: "Journal", onTap: () {}),
                          CustomList(
                            Skey: "F8",
                            name: "Contra",
                            onTap: () {},
                          ),
                          CustomList(Skey: "F5", name: "C/Note", onTap: () {}),
                          CustomList(Skey: "F6", name: "D/Note", onTap: () {}),
                          CustomList(
                            Skey: "F7",
                            name: "GST Exp.",
                            onTap: () {},
                          ),
                          CustomList(Skey: "", name: "", onTap: () {}),
                          CustomList(
                              Skey: "PgUp", name: "Previous", onTap: () {}),
                          CustomList(Skey: "PgDn", name: "Next", onTap: () {}),
                          CustomList(
                              Skey: "F12", name: "Audit Trail", onTap: () {}),
                          CustomList(
                              Skey: "F10", name: "Change Vch.", onTap: () {}),
                          CustomList(
                              Skey: "D", name: "Goto Date", onTap: () {}),
                          CustomList(Skey: "", name: "", onTap: () {}),
                          CustomList(
                              Skey: "G", name: "Attach. Img", onTap: () {}),
                          CustomList(Skey: "", name: "", onTap: () {}),
                          CustomList(
                              Skey: "G", name: "Vch Setup", onTap: () {}),
                          CustomList(
                              Skey: "T", name: "Print Setup", onTap: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
