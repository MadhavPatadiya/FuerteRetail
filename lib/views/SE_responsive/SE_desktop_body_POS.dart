import 'dart:math';

import 'package:billingsphere/data/repository/item_repository.dart';
import 'package:beep_player/beep_player.dart';
import 'package:billingsphere/views/SE_widgets/SE_desktop_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/models/item/item_model.dart';
import '../../data/models/measurementLimit/measurement_limit_model.dart';
import '../../data/models/salesPos/sales_pos_model.dart';
import '../../data/models/taxCategory/tax_category_model.dart';
import '../../data/repository/barcode_repository.dart';
import '../../data/repository/measurement_limit_repository.dart';
import '../../data/repository/sales_pos_repository.dart';
import '../../data/repository/tax_category_repository.dart';
import '../sumit_screen/sumit_responsive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'SE_master_POS.dart';

class SalesReturn extends StatefulWidget {
  const SalesReturn({super.key});

  @override
  State<SalesReturn> createState() => _SalesReturnState();
}

class _SalesReturnState extends State<SalesReturn> {
  static const BeepFile _beepFile = BeepFile(
    'assets/audio/beep.mp3',
    package: 'package1',
  );
  late TextEditingController _controller;
  String _selectedState = 'Gujarat';
  String? selectedItemId;
  String? selectedItemName;
  String selectedType = "Cash";
  late bool visible;
  bool isLoading = false;
  List<Item> itemList = [];
  List<TaxRate> taxLists = [];
  late List<TableRow> tables = [];
  // Give me a map to save the values
  List<Map<String, dynamic>> values = [];
  List<MeasurementLimit> measurement = [];
  ItemsService itemsService = ItemsService();
  TaxRateService taxRateService = TaxRateService();
  MeasurementLimitService measurementService = MeasurementLimitService();
  BarcodeRepository barcodeService = BarcodeRepository();
  SalesPosRepository salesPosRepository = SalesPosRepository();

  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _discPerController = TextEditingController();
  final TextEditingController _discRsController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _netAmountController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController? _remarkController = TextEditingController();
  final TextEditingController _additionController =
      TextEditingController(text: "0.00");
  final TextEditingController _lessController =
      TextEditingController(text: "0.00");
  final TextEditingController _roundOffController =
      TextEditingController(text: "0.00");
  // final TextEditingController _rewardDiscController =
  //     TextEditingController(text: "0.00");
  final TextEditingController _netTotalDiscController =
      TextEditingController(text: "0.00");

  Future<void> fetchItems() async {
    final items = await itemsService.fetchItems();
    items.removeWhere((element) => element.maximumStock == 0);
    setState(() {
      itemList = items;
    });
  }

  Future<void> fetchAndSetTaxRates() async {
    try {
      final List<TaxRate> taxRates = await taxRateService.fetchTaxRates();

      setState(() {
        taxLists = taxRates;
      });
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  Future<void> fetchMeasurementLimit() async {
    try {
      final List<MeasurementLimit> measurements =
          await measurementService.fetchMeasurementLimits();

      setState(() {
        measurement = measurements;
      });
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  void _saveValues() {
    final newItem = {
      'uniqueKey': UniqueKey().toString(),
      'itemName': selectedItemId,
      'qty': _qtyController.text,
      'unit': _unitController.text,
      'rate': _rateController.text,
      'netAmount': _netAmountController.text,
    };

    // Check if the item already exists in the list
    bool itemExists = false;
    int existingIndex = -1;
    for (int i = 0; i < values.length; i++) {
      if (values[i]['itemName'] == selectedItemId) {
        itemExists = true;
        existingIndex = i;
        break;
      }
    }

    if (itemExists) {
      // Update quantity and calculate net amount
      final qty =
          int.parse(values[existingIndex]['qty']) + int.parse(newItem['qty']!);
      final rate = double.parse(values[existingIndex]['rate']);
      final netAmount = qty * rate;

      // Update values
      values[existingIndex]['qty'] = qty.toString();
      values[existingIndex]['netAmount'] = netAmount.toStringAsFixed(2);
    } else {
      if (newItem['itemName'] != null) {
        // Add new item to the list
        values.add(newItem);
      }
    }
  }

  // Calculate the total amount
  void _calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var value in values) {
      totalAmount += double.parse(value['netAmount']);
    }

    setState(() {
      _netTotalDiscController.text = totalAmount.toStringAsFixed(2);
    });

    print(totalAmount);
  }

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

  Future<void> createPOSEntry() async {
    setState(() {
      isLoading = true;
    });

    final salesPos = SalesPos(
      companyCode: companyCode![0],
      date: _controller.text,
      no: int.parse(_noController.text),
      place: _selectedState,
      type: selectedType,
      entries: values.map((value) {
        return POSEntry(
          itemName: value['itemName'],
          qty: int.parse(value['qty']),
          rate: double.parse(value['rate']),
          unit: value['unit'],
          netAmount: double.parse(value['netAmount']),
        );
      }).toList(),
      accountNo: _customerController.text,
      customer: _customerController.text,
      billedTo: _selectedState,
      remarks: _remarkController?.text ?? 'No Remarks',
      totalAmount: double.parse(_netTotalDiscController.text),
    );

    try {
      await salesPosRepository.createPosEntry(salesPos);
      // If the creation is successful
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'POS Entry created successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        timeInSecForIosWeb: 3,
      );
      clearScreen(); // Clear the form fields
    } catch (error) {
      // If the creation fails
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Failed to create sales entry',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        timeInSecForIosWeb: 3,
      );
    }
  }

  void clearScreen() {
    setState(() {
      _controller.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
      _selectedState = 'Gujarat';
      selectedItemId = null;
      selectedItemName = null;
      _qtyController.text = '';
      _unitController.text = '';
      _rateController.text = '';
      _discPerController.text = '';
      _discRsController.text = '';
      _taxController.text = '';
      _netAmountController.text = '';
      _noController.text = '';
      _customerController.text = '';
      _remarkController?.text = '';
      _additionController.text = '0.00';
      _lessController.text = '0.00';
      _roundOffController.text = '0.00';
      _netTotalDiscController.text = '0.00';
      values.clear();
      tables.clear();
    });
  }

  void _printValues() {
    for (var value in values) {
      print(value);
    }
  }

  // Function to generate random 3 digit number
  void generateRandomNumber() {
    int num = 100 + Random().nextInt(999 - 100);
    _noController.text = num.toString();
  }

  // Function to display the dialog box
  void openDialog(int maxStock) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            height: 160,
            width: 590,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        "$selectedItemName",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        CustomTextField(
                          name: "Qty",
                          controller: _qtyController,
                          onchange: (String value) {
                            double qty = double.parse(value);
                            if (qty > maxStock) {
                              _qtyController.text = maxStock.toString();
                              qty = maxStock.toDouble();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Quantity cannot be greater than Maximum Stock',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );

                              // For Net Amount, multiply qty with rate
                              double rate = double.parse(_rateController.text);
                              double netAmount = qty * rate;

                              setState(() {
                                _netAmountController.text =
                                    netAmount.toStringAsFixed(2).toString();
                              });
                            } else {
                              // For Net Amount, multiply qty with rate
                              double rate = double.parse(_rateController.text);
                              double netAmount = qty * rate;

                              setState(() {
                                _netAmountController.text =
                                    netAmount.toStringAsFixed(2).toString();
                              });
                            }
                          },
                        ),
                        CustomTextField(
                          name: "Unit",
                          controller: _unitController,
                          onchange: (String value) {},
                        ),
                        CustomTextField(
                          name: "Rate",
                          controller: _rateController,
                          onchange: (String value) {},
                        ),
                        CustomTextField(
                          name: "Disc.%",
                          controller: _discPerController,
                          onchange: (String value) {},
                        ),
                        CustomTextField(
                          name: "DiscRs",
                          controller: _discRsController,
                          onchange: (String value) {},
                        ),
                        CustomTextField(
                          name: "Tax",
                          controller: _taxController,
                          onchange: (String value) {},
                        ),
                        CustomTextField(
                          name: "Net Amount",
                          controller: _netAmountController,
                          onchange: (String value) {},
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  height: 40,
                  color: Colors.black,
                ),
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      child: Buttons(
                        onTap: () {
                          // Pop
                          Navigator.of(context).pop();

                          _saveValues();
                          _calculateTotalAmount();
                          addTableRow();
                          BeepPlayer.play(_beepFile);
                        },
                        name: "Save",
                        Skey: "[space]",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Buttons(
                        onTap: () => Navigator.pop(context),
                        name: "Cancel",
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      child: Buttons(
                        name: "Delete",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _initializeAllData() async {
    await fetchItems();
    await fetchAndSetTaxRates();
    await fetchMeasurementLimit();
    await setCompanyCode();
    generateRandomNumber();
  }

  // void addTableRow() {
  //   int existingIndex = tables.indexWhere((row) =>
  //       row.children[1] is TableCell &&
  //       (row.children[1] as TableCell).child is Text &&
  //       ((row.children[1] as TableCell).child as Text).data ==
  //           selectedItemName);

  //   if (existingIndex != -1) {
  //     final qty = int.parse(_qtyController.text) +
  //         int.parse(
  //             (tables[existingIndex].children[2] as TableCell).child!.data!);
  //     final rate = double.parse(_rateController.text);
  //     final netAmount = qty * rate;

  //     // Update the TableCell widgets
  //     (tables[existingIndex].children[2] as TableCell).child = Text(
  //       qty.toString(),
  //       style: GoogleFonts.poppins(
  //         fontSize: 14,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black,
  //       ),
  //       textAlign: TextAlign.center,
  //     );

  //     (tables[existingIndex].children[5] as TableCell).child = Text(
  //       netAmount.toStringAsFixed(2),
  //       style: GoogleFonts.poppins(
  //         fontSize: 14,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black,
  //       ),
  //       textAlign: TextAlign.center,
  //     );

  //     setState(() {
  //       tables = tables;
  //     });

  //     return;
  //   }

  //   setState(() {
  //     tables.add(
  //       TableRow(
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //         ),
  //         children: [
  //           // Index
  //           TableCell(
  //             child: Text(
  //               (tables.length + 1).toString(),
  //               style: GoogleFonts.poppins(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.black,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           TableCell(
  //               child: Text(
  //             selectedItemName!,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _qtyController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _unitController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _rateController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           const TableCell(child: Text("")),
  //           TableCell(
  //               child: Text(
  //             _discPerController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _discRsController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _taxController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //           TableCell(
  //               child: Text(
  //             _netAmountController.text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           )),
  //         ],
  //       ),
  //     );
  //   });
  // }

  void addTableRow() {
    int existingIndex = tables.indexWhere((row) =>
        row.children[1] is TableCell &&
        (row.children[1] as TableCell).child is Text &&
        ((row.children[1] as TableCell).child as Text).data ==
            selectedItemName);

    if (existingIndex != -1) {
      final data =
          ((tables[existingIndex].children[2] as TableCell).child as Text).data;
      final qty = int.parse(_qtyController.text) + int.parse(data!.toString());
      final rate = double.parse(_rateController.text);
      final netAmount = qty * rate;

      // Update the TableCell widgets
      tables[existingIndex].children[2] = TableCell(
        child: Text(
          qty.toString(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      );

      tables[existingIndex].children[9] = TableCell(
        child: Text(
          netAmount.toStringAsFixed(2),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      );

      setState(() {
        tables = tables;
      });

      return;
    }

    setState(() {
      tables.add(
        TableRow(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          children: [
            // Index
            TableCell(
              child: Text(
                (tables.length + 1).toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                selectedItemName!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _qtyController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _unitController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _rateController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const TableCell(child: Text("")),
            TableCell(
              child: Text(
                _discPerController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _discRsController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _taxController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                _netAmountController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _additionController.dispose();
    _controller.dispose();
    _customerController.dispose();
    _discPerController.dispose();
    _discRsController.dispose();
    _netAmountController.dispose();
    _netTotalDiscController.dispose();
    _noController.dispose();
    _rateController.dispose();
    _rateController.dispose();
    _remarkController?.dispose();
    _roundOffController.dispose();
    _unitController.dispose();
    _taxController.dispose();
    values.clear();
    tables.clear();
    BeepPlayer.unload(_beepFile);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(DateTime.now()));

    _initializeAllData();
    BeepPlayer.load(_beepFile);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    var selectedValue1 = "No";
    var selectedValue3 = "Cash In Hand";
    var selectedValue4 = "Walk In";

    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Responsive(
              mobile: Container(),
              tablet: Container(),
              desktop: SingleChildScrollView(
                child: VisibilityDetector(
                  onVisibilityChanged: (VisibilityInfo info) {
                    visible = info.visibleFraction > 0;
                  },
                  key: const Key('visible-detector-key'),
                  child: BarcodeKeyboardListener(
                    bufferDuration: const Duration(milliseconds: 200),
                    onBarcodeScanned: (barcode) {
                      if (!visible) return;
                      itemsService
                          .searchItemsByBarcode(barcode)
                          .then((value) => {
                                setState(() {
                                  selectedItemId = value.first.id;
                                  selectedItemName = value.first.itemName;
                                  _qtyController.text = "1";
                                  _rateController.text =
                                      value.first.mrp.toString();
                                  _discPerController.text = "0.00";
                                  _discRsController.text = "0.00";
                                  _netAmountController.text =
                                      (1 * value.first.mrp).toStringAsFixed(2);
                                }),
                                openDialog(12),
                              });
                    },
                    useKeyDownEvent: kIsWeb,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: SEDesktopAppbar(
                            text1: 'Tax Invoice GST',
                            text2: 'SALES ENTRY POS',
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 630,
                              width: w * 0.9,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      width: 1,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                  right: BorderSide(
                                      width: 2,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                  bottom: BorderSide(
                                      width: 1,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 40,
                                      width: w * 0.9,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color: Colors.purple[900] ??
                                                  Colors.purple),
                                          bottom: BorderSide(
                                              width: 1,
                                              color: Colors.purple[900] ??
                                                  Colors.purple),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: w * 0.56,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            "No",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepPurple,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: TextFormField(
                                                            controller:
                                                                _noController,
                                                            readOnly: true,
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors.grey[
                                                                            500] ??
                                                                        Colors
                                                                            .grey,
                                                                    width: 2),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors.grey[
                                                                            500] ??
                                                                        Colors
                                                                            .grey,
                                                                    width: 2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: w * 0.03,
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              "Date",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .deepPurple,
                                                              ),
                                                            )),
                                                        Expanded(
                                                            flex: 2,
                                                            child:
                                                                TextFormField(
                                                              readOnly: true,
                                                              controller:
                                                                  _controller,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            5),
                                                                focusedBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors.grey[500] ??
                                                                            Colors
                                                                                .grey,
                                                                        width:
                                                                            2)),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors.grey[
                                                                              500] ??
                                                                          Colors
                                                                              .grey,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero,
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: w * 0.03,
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              "Place",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .deepPurple,
                                                              ),
                                                            )),
                                                        Expanded(
                                                          flex: 2,
                                                          child:
                                                              DropdownButtonFormField<
                                                                  String>(
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          15),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: Colors
                                                                              .grey[
                                                                          500] ??
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors.grey[
                                                                              500] ??
                                                                          Colors
                                                                              .grey,
                                                                      width:
                                                                          2)),
                                                            ),
                                                            value:
                                                                _selectedState,
                                                            items: <String>[
                                                              'Gujarat',
                                                              'Maharashtra',
                                                              'Karnataka',
                                                              'Tamil Nadu'
                                                            ].map<
                                                                DropdownMenuItem<
                                                                    String>>((String
                                                                value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              0),
                                                                  child: Text(
                                                                      value),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                _selectedState =
                                                                    newValue ??
                                                                        'Gujarat';
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: w * 0.5,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "ItemCode[F8]",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepPurple,
                                                            ),
                                                          )),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.7,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                            .grey[
                                                                        500] ??
                                                                    Colors.grey,
                                                                width: 2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                          child: SearchField<
                                                              String>(
                                                            onSuggestionTap:
                                                                (value) {
                                                              final selectedItem =
                                                                  itemList.firstWhere((item) =>
                                                                      item.itemName ==
                                                                      value
                                                                          .searchKey
                                                                          .toString());

                                                              selectedItemName =
                                                                  selectedItem
                                                                      .itemName;

                                                              selectedItemId =
                                                                  selectedItem
                                                                      .id;

                                                              String newId = '';
                                                              String newId2 =
                                                                  '';

                                                              for (Item item
                                                                  in itemList) {
                                                                if (item.id ==
                                                                    selectedItemId) {
                                                                  newId = item
                                                                      .taxCategory;
                                                                  newId2 = item
                                                                      .measurementUnit;
                                                                }
                                                              }

                                                              for (TaxRate tax
                                                                  in taxLists) {
                                                                if (tax.id ==
                                                                    newId) {
                                                                  setState(() {
                                                                    _taxController
                                                                            .text =
                                                                        '${tax.rate}%';
                                                                  });
                                                                }
                                                              }
                                                              for (MeasurementLimit meu
                                                                  in measurement) {
                                                                if (meu.id ==
                                                                    newId2) {
                                                                  setState(() {
                                                                    _unitController
                                                                            .text =
                                                                        meu.measurement
                                                                            .toString();
                                                                  });
                                                                }
                                                              }

                                                              _qtyController
                                                                  .text = "1";
                                                              _rateController
                                                                      .text =
                                                                  selectedItem
                                                                      .mrp
                                                                      .toString();
                                                              _discPerController
                                                                      .text =
                                                                  "0.00";
                                                              _discRsController
                                                                      .text =
                                                                  "0.00";

                                                              // For Net Amount, multiply qty with rate
                                                              double qty =
                                                                  double.parse(
                                                                      _qtyController
                                                                          .text);
                                                              double rate =
                                                                  double.parse(
                                                                      _rateController
                                                                          .text);

                                                              double netAmount =
                                                                  qty * rate;

                                                              _netAmountController
                                                                      .text =
                                                                  netAmount
                                                                      .toStringAsFixed(
                                                                          2)
                                                                      .toString();

                                                              openDialog(
                                                                  selectedItem
                                                                      .maximumStock);
                                                            },
                                                            suggestions: itemList
                                                                .map((item) =>
                                                                    SearchFieldListItem<
                                                                            String>(
                                                                        item.itemName))
                                                                .toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Text("${name}"),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15, left: 10),
                                      child: Container(
                                        height: 280,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.purple[900] ??
                                                  Colors.purple,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Table(
                                            border: TableBorder.all(
                                                width: 1,
                                                color: Colors.purple[900] ??
                                                    Colors.purple),
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(5),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(3),
                                              4: FlexColumnWidth(2),
                                              5: FlexColumnWidth(2),
                                              7: FlexColumnWidth(2),
                                              8: FlexColumnWidth(2),
                                              9: FlexColumnWidth(2),
                                            },
                                            children: [
                                              TableRow(children: [
                                                TableCell(
                                                    child: Text(
                                                  "Sr",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Item Name(^F8)",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Qty",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Unit",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Rate",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Basic",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Dis%",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Disc",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Tax",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Text(
                                                  "Net.Amt",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                )),
                                              ]),
                                              ...tables,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.purple[900] ??
                                                Colors.purple,
                                            width: 1),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: w * 0.30,
                                                  height: 190,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          "Set Discount",
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.deepPurple,
                                                                          ),
                                                                        )),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: DropdownButtonFormField<
                                                                          String>(
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 10,
                                                                              horizontal: 15),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 2,
                                                                              color: Colors.grey[500] ?? Colors.grey,
                                                                            ),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[500] ?? Colors.grey, width: 2)),
                                                                        ),
                                                                        value:
                                                                            selectedValue1,
                                                                        items: [
                                                                          "No",
                                                                          "Yes",
                                                                        ].map((String
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(value),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            selectedValue1 =
                                                                                value!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: w * 0.03,
                                                              ),
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          "Type",
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.deepPurple,
                                                                          ),
                                                                        )),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: DropdownButtonFormField<
                                                                          String>(
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 10,
                                                                              horizontal: 15),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 2,
                                                                              color: Colors.grey[500] ?? Colors.grey,
                                                                            ),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[500] ?? Colors.grey, width: 2)),
                                                                        ),
                                                                        value:
                                                                            selectedType,
                                                                        items: [
                                                                          "Cash",
                                                                          "Credit",
                                                                          "Multimode",
                                                                          "UPI",
                                                                          "CARD",
                                                                          "PAYMENT",
                                                                          "CHECQUE",
                                                                        ].map((String
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(value),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            selectedType =
                                                                                value!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "A/c",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .deepPurple,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                              flex: 7,
                                                              child:
                                                                  DropdownButtonFormField<
                                                                      String>(
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          15),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                    width: 2,
                                                                    color: Colors.grey[
                                                                            500] ??
                                                                        Colors
                                                                            .grey,
                                                                  )),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2)),
                                                                ),
                                                                value:
                                                                    selectedValue3,
                                                                items: [
                                                                  "Cash In Hand",
                                                                  "Option 2",
                                                                  "Option 3"
                                                                ].map((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    (String?
                                                                        value) {
                                                                  setState(() {
                                                                    selectedValue3 =
                                                                        value!;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Customer/Mob",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 7,
                                                                child:
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: Colors.grey[500] ??
                                                                            Colors.grey,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                  ),
                                                                  value:
                                                                      selectedValue4,
                                                                  items: [
                                                                    "Walk In",
                                                                    "Option 2",
                                                                    "Option 3"
                                                                  ].map((String
                                                                      value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          value) {
                                                                    setState(
                                                                        () {
                                                                      selectedValue4 =
                                                                          value!;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Billed to",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 7,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _customerController,
                                                                  cursorHeight:
                                                                      20,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Remarks",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 7,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _remarkController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: w * 0.35,
                                                  height: 170,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 35),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: w * 0.25,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    " No",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: Colors.grey[500] ??
                                                                            Colors.grey,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                  ),
                                                                  value:
                                                                      selectedType,
                                                                  items: [
                                                                    "Cash",
                                                                    "Credit",
                                                                    "Multimode",
                                                                    "UPI",
                                                                    "CARD",
                                                                    "PAYMENT",
                                                                    "CHECQUE",
                                                                  ].map((String
                                                                      value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          value) {
                                                                    setState(
                                                                        () {
                                                                      selectedType =
                                                                          value!;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: w * 0.25,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Advance",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    TextFormField(
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 100,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Text(
                                                              'Profit Check',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.blue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Colors
                                                                        .blue, // Change underline color
                                                                decorationThickness:
                                                                    2.0, // Change underline thickness
                                                                decorationStyle:
                                                                    TextDecorationStyle
                                                                        .solid, // Change underline style
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 35,
                                                        width: w * 0.2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Addition(F6)",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _additionController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        width: w * 0.2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Less(F7)",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _lessController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        width: w * 0.2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Round off",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _roundOffController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 35,
                                                        width: w * 0.2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Net Total",
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _netTotalDiscController,
                                                                  cursorHeight:
                                                                      20,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            5,
                                                                        horizontal:
                                                                            15),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey[500] ??
                                                                              Colors
                                                                                  .grey,
                                                                          width:
                                                                              2),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.grey[500] ?? Colors.grey,
                                                                            width: 2)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // const SizedBox(
                                                      //   height: 35,
                                                      // ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ]),
                                    ),
                                    Row(
                                      children: [
                                        const Button(
                                          name: "Hold",
                                        ),
                                        const Button(
                                          name: "Hold List",
                                        ),
                                        const Spacer(),
                                        Button(
                                          name: "Save",
                                          Skey: "[F4]",
                                          onTap: createPOSEntry,
                                        ),
                                        const Button(
                                          name: "Cancel",
                                        ),
                                        const Button(
                                          name: "Delete",
                                        ),
                                        const Spacer(),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 630,
                              width: w * 0.1,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      width: 1,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                  right: BorderSide(
                                      width: 1,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                  bottom: BorderSide(
                                      width: 1,
                                      color:
                                          Colors.purple[900] ?? Colors.purple),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    List2(
                                      Skey: "F2",
                                      name: "List",
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) {
                                            return const PosMaster();
                                          },
                                        ));
                                      },
                                    ),
                                    const List2(
                                      Skey: "P",
                                      name: "Print",
                                    ),
                                    const List2(
                                      Skey: "A",
                                      name: "Alt Print",
                                    ),
                                    const List2(
                                      Skey: "F5",
                                      name: "Change Type",
                                    ),
                                    const List2(),
                                    const List2(
                                      Skey: "B",
                                      name: "Prn Barcode",
                                    ),
                                    const List2(),
                                    const List2(
                                      Skey: "N",
                                      name: "Search No",
                                    ),
                                    const List2(
                                      Skey: "M",
                                      name: "Search Item",
                                    ),
                                    const List2(),
                                    const List2(
                                      name: "Discount",
                                      Skey: "F12",
                                    ),
                                    const List2(
                                      Skey: "F12",
                                      name: "Audit Trail",
                                    ),
                                    const List2(
                                      Skey: "Pg Up",
                                      name: "Previous",
                                    ),
                                    const List2(
                                      Skey: "Pg Dn",
                                      name: "Next",
                                    ),
                                    const List2(),
                                    const List2(
                                      Skey: "G",
                                      name: "Attach. Img",
                                    ),
                                    const List2(),
                                    const List2(
                                      Skey: "G",
                                      name: "Vch Setup",
                                    ),
                                    const List2(
                                      Skey: "T",
                                      name: "Print Setup",
                                    ),
                                    const List2(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text("data")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

Widget Values() {
  return AlertDialog(
    content: Container(
      height: 50,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            "No",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          )),
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[500] ?? Colors.grey,
                                    width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[500] ?? Colors.grey,
                                    width: 2),
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

class List2 extends StatelessWidget {
  final String? name;
  final String? Skey;
  final VoidCallback? onTap;
  const List2({super.key, this.name, this.Skey, this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: InkWell(
        splashColor: Colors.grey[350],
        onTap: onTap,
        child: Container(
          height: 32,
          width: w * 0.1,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              right: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              bottom: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Text(
                              Skey ?? "",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        name ?? " ",
                        style: TextStyle(
                            color: Colors.purple[900] ?? Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String? name;
  final String? Skey;
  const Button({super.key, this.name, this.Skey, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: InkWell(
        splashColor: Colors.grey[350],
        onTap: onTap,
        child: Container(
          height: 32,
          width: w * 0.07,
          decoration: BoxDecoration(
              color: Colors.yellow[200],
              border:
                  Border.all(color: const Color.fromARGB(255, 234, 211, 3))),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: Text(
                        name ?? " ",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      Skey ?? "",
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String name;
  final TextEditingController controller;
  final ValueChanged<String>
      onchange; // Changed VoidCallback to ValueChanged<String>

  const CustomTextField({
    required this.name,
    required this.controller,
    Key? key,
    required this.onchange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.purple[900] ?? Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller,
                    onChanged: onchange,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 5),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[500] ?? Colors.grey,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[500] ?? Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  final String? name;
  final String? Skey;
  final VoidCallback? onTap; // Nullable onTap function
  const Buttons({Key? key, this.name, this.Skey, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: InkWell(
        splashColor: Colors.grey[350],
        onTap: onTap, // Use onTap function here
        child: Container(
          height: 32,
          width: w * 0.07,
          decoration: BoxDecoration(
            color: Colors.yellow[200],
            border: Border.all(color: const Color.fromARGB(255, 234, 211, 3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: Text(
                  name ?? " ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                Skey ?? "",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
