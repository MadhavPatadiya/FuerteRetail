import 'dart:async';
import 'dart:math';

import 'package:billingsphere/data/models/purchase/purchase_model.dart';
import 'package:billingsphere/data/repository/purchase_repository.dart';
import 'package:billingsphere/utils/controllers/purchase_text_controller.dart';
import 'package:billingsphere/utils/controllers/sundry_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/repository/item_repository.dart';
import '../../data/repository/ledger_repository.dart';
import '../PE_widgets/PE_app_bar.dart';
import '../PE_widgets/PE_text_fields.dart';
import '../PE_widgets/PE_text_fields_no.dart';
import '../PE_widgets/purchase_table_2.dart';
import '../SE_widgets/sundry_row.dart';
import '../searchable_dropdown.dart';
import 'PE_master.dart';

class PurchaseEditD extends StatefulWidget {
  const PurchaseEditD({super.key, required this.data});

  final String data;

  @override
  State<PurchaseEditD> createState() => _PurchaseEditDState();
}

class _PurchaseEditDState extends State<PurchaseEditD> {
  bool isLoading = false;
  PurchaseFormController purchaseController = PurchaseFormController();
  DateTime? _selectedDate;
  DateTime? _pickedDateData;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final List<PEntries2> _newWidget = [];
  final List<SundryRow> _newSundry = [];
  final List<Map<String, dynamic>> _allValues = [];
  final List<Map<String, dynamic>> _allValuesSundry = [];
  List<String> status = ['Cash', 'Debit'];
  String? selectedStatus = 'Debit';
  String? selectedState = '';
  String? selectedLedgerName;

  int _currentSundrySerialNumber = 1;
  List<Ledger> suggestionItems5 = [];
  LedgerService ledgerService = LedgerService();
  ItemsService itemsService = ItemsService();
  PurchaseServices purchaseServices = PurchaseServices();
  SundryFormController sundryFormController = SundryFormController();
  List<String>? companyCode;

  List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  List<String> header2Titles = ['Sr', 'Sundry Name', 'Amount'];

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

  Future<void> fetchSinglePurchase() async {
    final response = await purchaseServices.fetchPurchaseById(widget.data);

    setState(() {
      purchaseController.noController.text = response!.no;
      purchaseController.dateController.text = response.date;
      purchaseController.typeController.text = response.type;
      purchaseController.ledgerController.text = response.ledger;
      purchaseController.placeController.text = response.place;
      purchaseController.billNumberController.text = response.billNumber;
      purchaseController.date2Controller.text = response.date2;
      purchaseController.cashAmountController.text = response.cashAmount ?? '';
      purchaseController.remarksController!.text = response.remarks;

      selectedStatus = response.type;
      selectedState = response.place;
      selectedLedgerName = response.ledger;

      // Add the existing entries to the _allValues list
      for (final entry in response.entries) {
        final entryId = UniqueKey().toString();
        _allValues.add({
          'uniqueKey': entryId,
          'itemName': entry.itemName,
          'qty': entry.qty,
          'rate': entry.rate,
          'unit': entry.unit,
          'amount': entry.amount,
          'tax': entry.tax,
          'sgst': entry.sgst,
          'cgst': entry.cgst,
          'igst': entry.igst,
          'discount': entry.discount,
          'netAmount': entry.netAmount,
          'sellingPrice': entry.sellingPrice,
        });

        // Set the controller
        final itemNameController = TextEditingController(text: entry.itemName);
        final qtyController = TextEditingController(text: entry.qty.toString());
        final rateController =
            TextEditingController(text: entry.rate.toString());
        final unitController = TextEditingController(text: entry.unit);
        final amountController =
            TextEditingController(text: entry.amount.toString());
        final taxController = TextEditingController(text: entry.tax);
        final sgstController =
            TextEditingController(text: entry.sgst.toString());
        final cgstController =
            TextEditingController(text: entry.cgst.toString());
        final igstController =
            TextEditingController(text: entry.igst.toString());
        final netAmountController =
            TextEditingController(text: entry.netAmount.toString());
        final discountController =
            TextEditingController(text: entry.discount.toString());
        final sellingPriceController =
            TextEditingController(text: entry.sellingPrice.toString());

        // Add the existing entries to the _newWidget list
        _newWidget.add(
          PEntries2(
            key: ValueKey(entryId),
            serialNo: _newWidget.length + 1,
            itemNameControllerP: itemNameController,
            qtyControllerP: qtyController,
            rateControllerP: rateController,
            unitControllerP: unitController,
            amountControllerP: amountController,
            taxControllerP: taxController,
            sgstControllerP: sgstController,
            cgstControllerP: cgstController,
            igstControllerP: igstController,
            netAmountControllerP: netAmountController,
            sellingPriceControllerP: sellingPriceController,
            discountControllerP: discountController,
            onSaveValues: saveValues,
            onDelete: (String entryId) {
              setState(
                () {
                  _newWidget
                      .removeWhere((widget) => widget.key == ValueKey(entryId));

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
                  calculateTotal();
                },
              );
            },
            entryId: entryId,
          ),
        );

        // Calculate total in full here
        Tqty += double.parse(entry.qty.toString());
        Tamount += double.parse(entry.amount.toString());
        Tdisc += double.parse(entry.tax.toString());
        Tsgst += double.parse(entry.sgst.toString());
        Tcgst += double.parse(entry.cgst.toString());
        Tigst += double.parse(entry.igst.toString());
        TnetAmount += double.parse(entry.netAmount.toString());
        Tdiscount += double.parse(entry.discount.toString());
      }

      // Add the existing sundry to the _allValuesSundry list
      for (final entry in response.sundry) {
        final entryId = UniqueKey().toString();
        _allValuesSundry.add({
          'uniqueKey': entryId,
          'sundryName': entry?.sundryName ?? '',
          'amount': entry?.amount ?? '',
        });

        // Add the existing sundry to the _newSundry list
        _newSundry.add(
          SundryRow(
            key: ValueKey(entryId),
            serialNumber: _currentSundrySerialNumber++,
            sundryControllerP: sundryFormController.sundryController,
            sundryControllerQ: sundryFormController.amountController,
            onSaveValues: (p0) {},
            onDelete: (String entryId) {
              setState(
                () {
                  _newSundry
                      .removeWhere((widget) => widget.key == ValueKey(entryId));

                  // Find the map in _allValuesSundry that contains the entry with the specified entryId
                  Map<String, dynamic>? entryToRemove;
                  for (final entry in _allValuesSundry) {
                    if (entry['uniqueKey'] == entryId) {
                      entryToRemove = entry;
                      break;
                    }
                  }

                  // Remove the map from _allValuesSundry if found
                  if (entryToRemove != null) {
                    _allValuesSundry.remove(entryToRemove);
                  }
                },
              );
            },
            entryId: entryId,
          ),
        );
      }
    });
  }

  Future<void> fetchLedgers2() async {
    try {
      final List<Ledger> ledger = await ledgerService.fetchLedgers();

      setState(() {
        suggestionItems5 = ledger;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

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

  double Ttotal = 0.00;
  double Tqty = 0;
  double Tamount = 0;
  double Tdisc = 0;
  double Tsgst = 0;
  double Tcgst = 0;
  double Tigst = 0;
  double TnetAmount = 0;
  double TsundryAmount = 0;
  double Tdiscount = 0.00;
  double ledgerAmount = 0;
  double roundedValue = 0.00;
  double roundOff = 0.00;
  late Timer _timer;

  void calculateTotal() {
    double qty = 0.00;
    double amount = 0.00;
    double sgst = 0.00;
    double cgst = 0.00;
    double igst = 0.00;
    double netAmount = 0.00;
    double discount = 0.00;

    for (var values in _allValues) {
      qty += double.tryParse(values['qty']) ?? 0;
      amount += double.tryParse(values['amount']) ?? 0;
      sgst += double.tryParse(values['sgst']) ?? 0;
      cgst += double.tryParse(values['cgst']) ?? 0;
      igst += double.tryParse(values['igst']) ?? 0;
      netAmount += double.tryParse(values['netAmount']) ?? 0;
      discount += double.tryParse(values['discount']) ?? 0;
    }
    double totalAmount = netAmount + Ttotal;
    int roundedValue2 = totalAmount.truncate();
    double roundOff2 = totalAmount - roundedValue2;

    setState(() {
      Tqty = qty;
      Tamount = amount;
      Tsgst = sgst;
      Tcgst = cgst;
      Tigst = igst;
      TnetAmount = netAmount;
      roundedValue = roundedValue2.toDouble();
      roundOff = roundOff2;
      Tdiscount = discount;
    });

    Fluttertoast.showToast(
      msg: "Values added to list successfully!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER_RIGHT,
      webPosition: "right",
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void _startTimer() {
    const Duration duration = Duration(seconds: 2);
    _timer = Timer.periodic(duration, (Timer timer) {
      calculateTotal();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    await fetchLedgers2();
    await fetchSinglePurchase();
    await getCompanyCode();

    // Delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startTimer();
  }

  // Write code for update purchase
  Future<void> updatePurchase() async {
    print(_allValues);
    print(_allValuesSundry);
    Purchase purchaseData = Purchase(
        id: widget.data,
        companyCode: companyCode!.first,
        totalamount: (TnetAmount + Ttotal).toString(),
        no: purchaseController.noController.text,
        date: purchaseController.dateController.text,
        cashAmount: purchaseController.cashAmountController.text,
        dueAmount: purchaseController.dueAmountController.text,
        date2: purchaseController.date2Controller.text,
        type: selectedStatus!,
        ledger: selectedLedgerName!,
        place: selectedState!,
        billNumber: purchaseController.billNumberController.text,
        remarks: purchaseController.remarksController!.text,
        entries: _allValues.map((entry) {
          return PurchaseEntry(
            itemName: entry['itemName'] ?? '',
            qty: int.tryParse(entry['qty']) ?? 0,
            rate: double.tryParse(entry['rate']) ?? 0,
            unit: entry['unit'] ?? '',
            amount: double.tryParse(entry['amount']) ?? 0,
            tax: entry['tax'] ?? '',
            sgst: double.tryParse(entry['sgst']) ?? 0,
            cgst: double.tryParse(entry['cgst']) ?? 0,
            igst: double.tryParse(entry['igst']) ?? 0,
            netAmount: double.tryParse(entry['netAmount']) ?? 0,
            sellingPrice: double.tryParse(entry['sellingPrice']) ?? 0,
            discount: double.tryParse(entry['sellingPrice']) ?? 0,
          );
        }).toList(),
        sundry: _allValuesSundry.map((sundry) {
          return SundryEntry(
            sundryName: sundry['sndryName'] ?? '',
            amount: double.tryParse(sundry['sundryAmount']) ?? 0,
          );
        }).toList());

    await purchaseServices.updatePurchase(purchaseData, context).then((value) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PEMasterBody()));
    }).catchError((error) {
      Navigator.of(context).pop();
      print('Failed to create purchase: $error');
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PECustomAppBar(
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Form(
                      // key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.00),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        height: 30,
                                        child: const Text(
                                          'No',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    PETextFieldsNo(
                                      onSaved: (newValue) {
                                        purchaseController.noController.text =
                                            newValue!;
                                      },
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                      height: 30,
                                      controller:
                                          purchaseController.noController,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, bottom: 16.0, top: 16.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        child: const Text(
                                          'Date',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, bottom: 16.0),
                                          child: TextFormField(
                                            controller: purchaseController
                                                .dateController,
                                            onSaved: (newValue) {
                                              purchaseController.dateController
                                                  .text = newValue!;
                                            },
                                            decoration: InputDecoration(
                                              hintText: _selectedDate == null
                                                  ? '12/12/2023'
                                                  : formatter
                                                      .format(_selectedDate!),
                                              border: InputBorder.none,
                                            ),
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03,
                                      child: IconButton(
                                          onPressed: _presentDatePICKER,
                                          icon:
                                              const Icon(Icons.calendar_month)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.003,
                                      ),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        child: const Text(
                                          'Type',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height: 30,
                                      padding: const EdgeInsets.all(2.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedStatus,
                                          underline: Container(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedStatus = newValue!;
                                              purchaseController.typeController
                                                  .text = selectedStatus!;
                                              // Set Type
                                            });
                                          },
                                          items: status.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Text(
                                                  value,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.00,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.00),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        child: const Text(
                                          'Party',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      width: MediaQuery.of(context).size.width *
                                          0.23,
                                      height: 30,
                                      padding: const EdgeInsets.all(2.0),
                                      child: SearchableDropDown(
                                        controller:
                                            purchaseController.partyController,
                                        searchController:
                                            purchaseController.partyController,
                                        value: selectedLedgerName,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            if (selectedLedgerName != null) {
                                              selectedLedgerName = newValue;
                                              purchaseController
                                                  .ledgerController
                                                  .text = selectedLedgerName!;
                                            }
                                          });
                                        },
                                        items: suggestionItems5
                                            .map((Ledger ledger) {
                                          return DropdownMenuItem<String>(
                                            value: ledger.id,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  ledger.name,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        searchMatchFn: (item, searchValue) {
                                          final peLedger = suggestionItems5
                                              .firstWhere(
                                                  (e) => e.id == item.value)
                                              .name;
                                          return peLedger
                                              .toLowerCase()
                                              .contains(
                                                  searchValue.toLowerCase());
                                        },
                                      ),

                                      // child: DropdownButtonHideUnderline(
                                      //   child: DropdownButton<String>(
                                      //     value: selectedLedgerName,
                                      //     underline: Container(),
                                      //     onChanged: (String? newValue) {
                                      //       setState(() {
                                      //         if (selectedLedgerName != null) {
                                      //           selectedLedgerName = newValue;
                                      //           purchaseController
                                      //               .ledgerController
                                      //               .text = selectedLedgerName!;
                                      //         }
                                      //       });
                                      //     },
                                      //     items: suggestionItems5
                                      //         .map((Ledger ledger) {
                                      //       return DropdownMenuItem<String>(
                                      //         value: ledger.id,
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment
                                      //                   .spaceBetween,
                                      //           children: [
                                      //             Text(
                                      //               ledger.name,
                                      //               softWrap: true,
                                      //               style: const TextStyle(
                                      //                 fontSize: 15,
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       );
                                      //     }).toList(),
                                      //   ),
                                      // ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        top: MediaQuery.of(context).size.width *
                                            0.001,
                                      ),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        child: const Text(
                                          'Place',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      width: MediaQuery.of(context).size.width *
                                          0.23,
                                      height: 30,
                                      padding: const EdgeInsets.all(2.0),

                                      child: SearchableDropDown(
                                        controller:
                                            purchaseController.placeController,
                                        searchController:
                                            purchaseController.placeController,
                                        value: selectedState,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedState = newValue;
                                            purchaseController.placeController
                                                .text = selectedState!;
                                          });
                                        },
                                        items: indianStates.map((state) {
                                          return DropdownMenuItem<String>(
                                            value: state,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  state,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        searchMatchFn: (item, searchValue) {
                                          return item.value
                                              .toString()
                                              .toLowerCase()
                                              .contains(
                                                  searchValue.toLowerCase());
                                        },
                                      ),

                                      // child: DropdownButtonHideUnderline(
                                      //   child: DropdownButton<String>(
                                      //     value: selectedState,
                                      //     onChanged: (String? newValue) {
                                      //       setState(() {
                                      //         selectedState = newValue;
                                      //         purchaseController.placeController
                                      //             .text = selectedState!;
                                      //       });
                                      //     },
                                      //     items: indianStates.map((state) {
                                      //       return DropdownMenuItem<String>(
                                      //         value: state,
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment
                                      //                   .spaceBetween,
                                      //           children: [
                                      //             Text(
                                      //               state,
                                      //               softWrap: true,
                                      //               style: const TextStyle(
                                      //                 fontSize: 15,
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       );
                                      //     }).toList(),
                                      //   ),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.00,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.00),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        child: const Text(
                                          'Bill No',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    // TextButton(
                                    //   onPressed: generateBillNumber,
                                    //   child: const Text(
                                    //     'Generate',
                                    //     style: TextStyle(
                                    //       color: Colors.black,
                                    //       fontWeight: FontWeight.bold,
                                    //     ),
                                    //   ),
                                    // ),

                                    PETextFields(
                                      onSaved: (newValue) {
                                        purchaseController.billNumberController
                                            .text = newValue!;
                                      },
                                      controller: purchaseController
                                          .billNumberController,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height: 30,
                                      readOnly: true,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.003),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        child: const Text(
                                          'Date',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, bottom: 16.0),
                                          child: TextFormField(
                                            onSaved: (newValue) {
                                              purchaseController.date2Controller
                                                  .text = newValue!;
                                            },
                                            controller: purchaseController
                                                .date2Controller,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                            decoration: InputDecoration(
                                              hintText: _pickedDateData == null
                                                  ? '12/12/2023'
                                                  : formatter
                                                      .format(_pickedDateData!),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03,
                                      child: IconButton(
                                          onPressed: _showDataPICKER,
                                          icon:
                                              const Icon(Icons.calendar_month)),
                                    ),
                                    Visibility(
                                      visible: selectedStatus == 'Cash',
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.003),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          child: const Text(
                                            'Cash',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedStatus == 'Cash',
                                      child: Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: TextFormField(
                                              controller: purchaseController
                                                  .cashAmountController,
                                              onSaved: (newValue) {
                                                purchaseController
                                                    .cashAmountController
                                                    .text = newValue!;
                                              },
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 18.0, bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)),
                                  child: InkWell(
                                    onTap: () {
                                      final entryId = UniqueKey().toString();
                                      setState(() {
                                        _newWidget.add(
                                          PEntries2(
                                            key: ValueKey(entryId),
                                            serialNo: _newWidget.length + 1,
                                            itemNameControllerP:
                                                TextEditingController(),
                                            qtyControllerP:
                                                TextEditingController(),
                                            rateControllerP:
                                                TextEditingController(),
                                            unitControllerP:
                                                TextEditingController(),
                                            amountControllerP:
                                                TextEditingController(),
                                            taxControllerP:
                                                TextEditingController(),
                                            sgstControllerP:
                                                TextEditingController(),
                                            cgstControllerP:
                                                TextEditingController(),
                                            igstControllerP:
                                                TextEditingController(
                                                    text: '0'),
                                            netAmountControllerP:
                                                TextEditingController(),
                                            discountControllerP:
                                                TextEditingController(),
                                            sellingPriceControllerP:
                                                TextEditingController(),
                                            onSaveValues: saveValues,
                                            onDelete: (String entryId) {
                                              setState(
                                                () {
                                                  _newWidget.removeWhere(
                                                      (widget) =>
                                                          widget.key ==
                                                          ValueKey(entryId));

                                                  // Find the map in _allValues that contains the entry with the specified entryId
                                                  Map<String, dynamic>?
                                                      entryToRemove;
                                                  for (final entry
                                                      in _allValues) {
                                                    if (entry['uniqueKey'] ==
                                                        entryId) {
                                                      entryToRemove = entry;
                                                      break;
                                                    }
                                                  }

                                                  // Remove the map from _allValues if found
                                                  if (entryToRemove != null) {
                                                    _allValues
                                                        .remove(entryToRemove);
                                                  }
                                                  calculateTotal();
                                                },
                                              );
                                            },
                                            entryId: entryId,
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.only(right: 18.0, bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)),
                                  child: InkWell(
                                    // onTap: calculateTotal,
                                    onTap: calculateTotal,
                                    child: const Text(
                                      'Save all',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //table header
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.023,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'SR',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    '   Item Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Qty',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Unit',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Rate',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Amount',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Container(
                                //   height: 20,
                                //   width: MediaQuery.of(context).size.width * 0.061,
                                //   decoration: const BoxDecoration(
                                //       border: Border(
                                //           bottom: BorderSide(),
                                //           top: BorderSide(),
                                //           left: BorderSide())),
                                //   child: const Text(
                                //     'Disc.',
                                //     style: TextStyle(fontWeight: FontWeight.bold),
                                //     textAlign: TextAlign.center,
                                //   ),
                                // ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Tax%',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'SGST',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'CGST',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'IGST',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Disc.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide(),
                                          right: BorderSide())),
                                  child: const Text(
                                    'Net Amt.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide(),
                                          right: BorderSide())),
                                  child: const Text(
                                    'Selling Amt.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //table body
                          Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: _newWidget,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table footer
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.023,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    'Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    '$Tqty',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    Tamount.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Container(
                                //   height: 20,
                                //   width: MediaQuery.of(context).size.width * 0.061,
                                //   decoration: const BoxDecoration(
                                //       border: Border(
                                //           bottom: BorderSide(),
                                //           top: BorderSide(),
                                //           left: BorderSide())),
                                //   child: Text(
                                //     Tdisc.toStringAsFixed(2),
                                //     style:
                                //         const TextStyle(fontWeight: FontWeight.bold),
                                //     textAlign: TextAlign.center,
                                //   ),
                                // ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: const Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    Tsgst.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    Tcgst.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    Tigst.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide())),
                                  child: Text(
                                    Tdiscount.toStringAsFixed(2),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(),
                                          top: BorderSide(),
                                          left: BorderSide(),
                                          right: BorderSide())),
                                  child: Text(
                                    TnetAmount.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width:
                                      MediaQuery.of(context).size.width * 0.061,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(),
                                    top: BorderSide(),
                                    right: BorderSide(),
                                  )),
                                  child: const Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.04),
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                    child: const Text(
                                                      'Remarks',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  PETextFields(
                                                    onSaved: (newValue) {
                                                      purchaseController
                                                          .remarksController!
                                                          .text = newValue!;
                                                    },
                                                    controller:
                                                        purchaseController
                                                            .remarksController,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.67,
                                                    height: 30,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    height: 205,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 44, 43, 43),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Header
                                        Container(
                                          padding: const EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                          ),
                                          child: Row(
                                            children: List.generate(
                                              header2Titles.length,
                                              (index) => Expanded(
                                                child: Text(
                                                  header2Titles[index],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Table Body
                                        //Sundry
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: InkWell(
                                                  // onTap: calculateSundry,
                                                  onTap: () {},
                                                  child: const Text(
                                                    'Save All',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 15,
                                                    ),
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    final entryId =
                                                        UniqueKey().toString();

                                                    setState(() {
                                                      _newSundry.add(
                                                        SundryRow(
                                                            key: ValueKey(
                                                                entryId),
                                                            serialNumber:
                                                                _currentSundrySerialNumber,
                                                            sundryControllerP:
                                                                sundryFormController
                                                                    .sundryController,
                                                            sundryControllerQ:
                                                                sundryFormController
                                                                    .amountController,
                                                            // onSaveValues: saveSundry,
                                                            onSaveValues:
                                                                (p0) {},
                                                            entryId: entryId,
                                                            onDelete: (String
                                                                entryId) {
                                                              setState(() {
                                                                _newSundry.removeWhere(
                                                                    (widget) =>
                                                                        widget
                                                                            .key ==
                                                                        ValueKey(
                                                                            entryId));

                                                                Map<String,
                                                                        dynamic>?
                                                                    entryToRemove;
                                                                for (final entry
                                                                    in _allValuesSundry) {
                                                                  if (entry[
                                                                          'uniqueKey'] ==
                                                                      entryId) {
                                                                    entryToRemove =
                                                                        entry;
                                                                    break;
                                                                  }
                                                                }

                                                                // Remove the map from _allValues if found
                                                                if (entryToRemove !=
                                                                    null) {
                                                                  _allValuesSundry
                                                                      .remove(
                                                                          entryToRemove);
                                                                }
                                                                // calculateSundry();
                                                              });
                                                            }),
                                                      );

                                                      _currentSundrySerialNumber++;
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 15,
                                                    ),
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          height: 110,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: _newSundry,
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
                          //Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.14,
                                    height: 30,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 0,
                                      child: ElevatedButton(
                                        onPressed: updatePurchase,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color.fromARGB(
                                                255, 255, 243, 132),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1.0),
                                              side: const BorderSide(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Save [F4]',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.002,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.14,
                                    height: 30,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color.fromARGB(
                                                255, 255, 243, 132),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1.0),
                                              side: const BorderSide(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.002,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.14,
                                    height: 30,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 0,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color.fromARGB(
                                                255, 255, 243, 132),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1.0),
                                              side: const BorderSide(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          child: const Text(
                                            'Round-Off: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.1,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom:
                                                      BorderSide(width: 2))),
                                          child: Text(
                                            '- ${roundOff.toStringAsFixed(2)}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          child: const Text(
                                            'Amount: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.1,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom:
                                                      BorderSide(width: 2))),
                                          child: Text(
                                            '$roundedValue',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
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
                ],
              ),
            ),
          );
  }

  void _presentDatePICKER() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        purchaseController.dateController.text = formatter.format(pickedDate);
      });
    }
  }

  void _showDataPICKER() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _pickedDateData = pickedDate;
        purchaseController.date2Controller.text = formatter.format(pickedDate);
      });
    }
  }

  void generateBillNumber() {
    // Generate a random number between 100 and 999
    Random random = Random();
    int randomNumber = random.nextInt(9000) + 1000;

    // Get the current month abbreviation
    String monthAbbreviation = _getMonthAbbreviation(DateTime.now().month);

    // Construct the bill number
    String billNumber = 'BIL$randomNumber$monthAbbreviation';

    setState(() {
      purchaseController.billNumberController.text = billNumber;
    });
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'JAN';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'APR';
      case 5:
        return 'MAY';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AUG';
      case 9:
        return 'SEP';
      case 10:
        return 'OCT';
      case 11:
        return 'NOV';
      case 12:
        return 'DEC';
      default:
        return '';
    }
  }
}
