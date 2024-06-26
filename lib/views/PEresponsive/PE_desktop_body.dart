// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:billingsphere/auth/providers/onchange_item_provider.dart';
import 'package:billingsphere/data/repository/purchase_repository.dart';
import 'package:billingsphere/utils/controllers/purchase_text_controller.dart';
import 'package:billingsphere/views/PE_widgets/PE_app_bar.dart';
import 'package:billingsphere/views/PE_widgets/PE_text_fields.dart';
import 'package:billingsphere/views/PE_widgets/PE_text_fields_no.dart';
import 'package:billingsphere/views/PEresponsive/PE_receipt_print.dart';
import 'package:billingsphere/views/SE_widgets/sundry_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/item/item_model.dart';
import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/measurementLimit/measurement_limit_model.dart';
import '../../data/models/purchase/purchase_model.dart';
import '../../data/models/taxCategory/tax_category_model.dart';
import '../../data/repository/item_repository.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/measurement_limit_repository.dart';
import '../../data/repository/tax_category_repository.dart';
import '../../utils/controllers/sundry_controller.dart';
import '../LG_responsive/LG_desktop_body.dart';
import '../NI_responsive.dart/NI_desktopBody.dart';
import '../PE_widgets/purchase_table.dart';
import '../SE_variables/SE_variables.dart';
import '../searchable_dropdown.dart';
import '../sumit_screen/voucher _entry.dart/voucher_list_widget.dart';
import 'PE_master.dart';

final formatter = DateFormat('dd/MM/yyyy');

class PEMyDesktopBody extends StatefulWidget {
  const PEMyDesktopBody({super.key});

  @override
  State<PEMyDesktopBody> createState() => _PEMyDesktopBodyState();
}

class _PEMyDesktopBodyState extends State<PEMyDesktopBody> {
  DateTime? _selectedDate;
  DateTime? _pickedDateData;
  List<String> status = ['Cash', 'Debit'];
  String selectedStatus = 'Debit';
  String? selectedState = 'Gujarat';
  final List<PEntries> _newWidget = [];
  final List<SundryRow> _newSundry = [];
  final List<Map<String, dynamic>> _allValues = [];
  final List<Map<String, dynamic>> _allValuesSundry = [];
  List<Purchase> fetchedPurchase = [];
  bool isLoading = false;

  // SUMMATION VALUES
  double Ttotal = 0.00;
  double Tqty = 0.00;
  double Tamount = 0.00;
  double Tdisc = 0.00;
  double Tsgst = 0.00;
  double Tcgst = 0.00;
  double Tigst = 0.00;
  double TnetAmount = 0.00;
  double Tdiscount = 0.00;
  double ledgerAmount = 0;
  double roundedValue = 0.00;
  double roundOff = 0.00;

  late Timer _timer;

  //fetch ledger
  List<Ledger> suggestionItems5 = [];
  List<Item> itemsList = [];
  List<TaxRate> taxLists = [];
  List<MeasurementLimit> measurement = [];
  String? selectedLedgerName;
  LedgerService ledgerService = LedgerService();
  ItemsService itemsService = ItemsService();
  PurchaseServices purchaseServices = PurchaseServices();
  MeasurementLimitService measurementService = MeasurementLimitService();

  TaxRateService taxRateService = TaxRateService();

  // Controllers
  PurchaseFormController purchaseController = PurchaseFormController();
  SundryFormController sundryFormController = SundryFormController();

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

  String? purchaseLength;
  int _currentSundrySerialNumber = 1;

  String registrationTypeDated = '';

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

  Future<String?> getNumberOfPurchase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('purchaseLength');
  }

  Future<void> setPurchaseLength() async {
    String? length = await getNumberOfPurchase();
    setState(() {
      purchaseLength = length;
      purchaseController.noController.text =
          (int.parse(purchaseLength!) + 1).toString();
    });
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

  void _startTimer() {
    const Duration duration = Duration(seconds: 2);
    _timer = Timer.periodic(duration, (Timer timer) {
      calculateTotal();
      calculateSundry();
    });
  }

  Future<void> createPurchase() async {
    if (selectedLedgerName!.isEmpty) {
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
            content: Text('Please select a ledger!',
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
    } else if (_allValues.isEmpty) {
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
            content: Text('Please add an item!',
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
    if (selectedStatus == 'Debit') {
      purchaseController.dueAmountController.text =
          (TnetAmount + Ttotal).toString();
    } else {
      purchaseController.dueAmountController.text = '0';
    }
    final purchase = Purchase(
      companyCode: companyCode!.first,
      id: 'id',
      no: purchaseController.noController.text,
      date: purchaseController.dateController.text,
      date2: purchaseController.date2Controller.text,
      type: purchaseController.typeController.text,
      ledger: selectedLedgerName!,
      place: selectedState!,
      billNumber: purchaseController.billNumberController.text,
      remarks:
          purchaseController.remarksController?.text ?? 'No remark available',
      totalamount: (TnetAmount + Ttotal).toString(),
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
            discount: double.tryParse(entry['discount']) ?? 0);
      }).toList(),
      sundry: _allValuesSundry.map((sundry) {
        return SundryEntry(
          sundryName: sundry['sndryName'] ?? 'ssss',
          amount: double.tryParse(sundry['sundryAmount']) ?? 0,
        );
      }).toList(),
      cashAmount: purchaseController.cashAmountController.text == ''
          ? '0'
          : purchaseController.cashAmountController.text,
      dueAmount: purchaseController.dueAmountController.text == ''
          ? '0'
          : purchaseController.dueAmountController.text,
    );
    await purchaseServices.createPurchase(purchase, context).then((value) {
      clearAll();
      fetchPurchaseEntries().then((_) {
        final newPurchaseEntry =
            fetchedPurchase.firstWhere((element) => element.no == purchase.no,
                orElse: () => Purchase(
                      id: '',
                      companyCode: '',
                      totalamount: '',
                      no: '',
                      date: '',
                      cashAmount: '',
                      dueAmount: '',
                      date2: '',
                      type: '',
                      ledger: '',
                      place: '',
                      billNumber: '',
                      remarks: '',
                      entries: [],
                      sundry: [],
                    ));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'PRINT RECEIPT',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Do you want to print the receipt?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PurchasePrintBigReceipt(
                          'Purchase Receipt',
                          purchaseID: newPurchaseEntry.id,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'YES',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return const PEMasterBody();
                      },
                    ));
                  },
                  child: const Text(
                    'NO',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }).catchError((error) {
      Navigator.of(context).pop();
      print('Failed to create purchase: $error');
    });
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

  void saveSundry(Map<String, dynamic> values) {
    final String uniqueKey = values['uniqueKey'];

    // Check if an entry with the same uniqueKey exists
    final existingEntryIndex =
        _allValuesSundry.indexWhere((entry) => entry['uniqueKey'] == uniqueKey);

    setState(() {
      if (existingEntryIndex != -1) {
        _allValuesSundry.removeAt(existingEntryIndex);
      }

      // Add the latest values
      _allValuesSundry.add(values);
    });
  }

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
  }

  void calculateSundry() {
    double total = 0.00;
    for (var values in _allValuesSundry) {
      total += double.tryParse(values['sundryAmount']) ?? 0;
    }

    setState(() {
      Ttotal = total;
    });
  }

  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();
      setState(() {
        itemsList = items;
      });
    } catch (error) {
      // ignore: avoid_print
      print('Failed to fetch ledger name: $error');
    }
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

  Future<void> fetchLedgers2() async {
    try {
      final List<Ledger> ledger = await ledgerService.fetchLedgers();
      // Add empty data on the 0 index
      ledger.insert(
        0,
        Ledger(
          id: '',
          address: '',
          aliasName: '',
          bankName: '',
          branchName: '',
          date: '',
          ifsc: '',
          accName: '',
          accNo: '',
          bilwiseAccounting: '',
          city: '',
          contactPerson: '',
          creditDays: 0,
          cstDated: '',
          cstNo: '',
          email: '',
          fax: 0,
          gst: '',
          gstDated: '',
          ledgerCode: 0,
          ledgerGroup: '662f97d2a07ec73369c237b0',
          ledgerType: '',
          mobile: 0,
          lstDated: '',
          lstNo: '',
          mailingName: '',
          name: '',
          openingBalance: 0,
          debitBalance: 0,
          panNo: '',
          pincode: 0,
          priceListCategory: '',
          printName: '',
          region: '',
          registrationType: '',
          registrationTypeDated: '',
          remarks: '',
          serviceTaxDated: '',
          serviceTaxNo: '',
          sms: 0,
          state: '',
          status: 'Yes',
          tel: 0,
        ),
      );

      setState(() {
        suggestionItems5 = ledger
            .where((element) =>
                element.status == 'Yes' &&
                element.ledgerGroup == '662f97d2a07ec73369c237b0')
            .toList();

        if (suggestionItems5.isNotEmpty) {
          selectedLedgerName =
              suggestionItems5.isNotEmpty ? suggestionItems5.first.id : null;
          ledgerAmount = suggestionItems5.first.debitBalance;
        }
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  Future<void> fetchPurchaseEntries() async {
    try {
      final List<Purchase> purchase = await purchaseServices.getPurchase();
      setState(() {
        fetchedPurchase = purchase;
      });

      print('Fetched Purchase: $fetchedPurchase');
    } catch (error) {
      print('Failed to fetch purchase name: $error');
    }
  }

  // Clear all the fields and widgets
  void clearAll() {
    setState(() {
      _newWidget.clear();
      _allValues.clear();
      _allValuesSundry.clear();
      Ttotal = 0.00;
      Tqty = 0.00;
      Tamount = 0.00;
      Tdisc = 0.00;
      Tsgst = 0.00;
      Tcgst = 0.00;
      Tigst = 0.00;
      TnetAmount = 0.00;
      purchaseController.noController.clear();
      purchaseController.dateController.clear();
      purchaseController.date2Controller.clear();
      purchaseController.typeController.clear();
      purchaseController.ledgerController.clear();
      purchaseController.placeController.clear();
      purchaseController.billNumberController.clear();
      purchaseController.remarksController?.clear();
      purchaseController.cashAmountController.clear();
      purchaseController.dueAmountController.clear();

      generateBillNumber();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        setCompanyCode(),
        setPurchaseLength(),
        fetchPurchaseEntries(),
        fetchLedgers2(),
        fetchItems(),
        fetchAndSetTaxRates(),
        fetchMeasurementLimit(),
        Future.delayed(const Duration(seconds: 1)),
      ]);
      generateBillNumber();
      purchaseController.typeController.text = selectedStatus;
      purchaseController.date2Controller.text =
          formatter.format(DateTime.now());
      purchaseController.dateController.text = formatter.format(DateTime.now());

      for (int i = 0; i < 10; i++) {
        final entryId = UniqueKey().toString();
        setState(() {
          _newWidget.add(
            PEntries(
              key: ValueKey(entryId),
              entryId: entryId,
              serialNumber: i + 1,
              itemNameControllerP: purchaseController.itemNameController,
              qtyControllerP: purchaseController.qtyController,
              rateControllerP: purchaseController.rateController,
              unitControllerP: purchaseController.unitController,
              amountControllerP: purchaseController.amountController,
              taxControllerP: purchaseController.taxController,
              sgstControllerP: purchaseController.sgstController,
              cgstControllerP: purchaseController.cgstController,
              igstControllerP: purchaseController.igstController,
              netAmountControllerP: purchaseController.netAmountController,
              discountControllerP: purchaseController.discountController,
              sellingPriceControllerP:
                  purchaseController.sellingPriceController,
              onSaveValues: saveValues,
              onDelete: (String entryId) {
                setState(
                  () {
                    _newWidget.removeWhere(
                        (widget) => widget.key == ValueKey(entryId));
                    Map<String, dynamic>? entryToRemove;
                    for (final entry in _allValues) {
                      if (entry['uniqueKey'] == entryId) {
                        entryToRemove = entry;
                        break;
                      }
                    }
                    if (entryToRemove != null) {
                      _allValues.remove(entryToRemove);
                    }
                    calculateTotal();
                  },
                );
              },
              item: itemsList,
              measurementLimit: measurement,
              taxCategory: taxLists,
            ),
          );
        });
      }

      for (int i = 0; i < 4; i++) {
        final entryId = UniqueKey().toString();

        setState(() {
          _newSundry.add(
            SundryRow(
              key: ValueKey(entryId),
              serialNumber: i + 1,
              sundryControllerP: sundryFormController.sundryController,
              sundryControllerQ: sundryFormController.amountController,
              onSaveValues: saveSundry,
              onDelete: (String entryId) {
                setState(
                  () {
                    _newSundry.removeWhere(
                        (widget) => widget.key == ValueKey(entryId));
                    Map<String, dynamic>? entryToRemove;
                    for (final entry in _allValuesSundry) {
                      if (entry['uniqueKey'] == entryId) {
                        entryToRemove = entry;
                        break;
                      }
                    }
                    if (entryToRemove != null) {
                      _allValuesSundry.remove(entryToRemove);
                    }
                    calculateSundry();
                  },
                );
              },
              entryId: entryId,
            ),
          );
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    purchaseController.dispose();
    _newSundry.clear();
    _allValues.clear();
    _allValuesSundry.clear();
    _timer.cancel();
    Provider.of<OnChangeItenProvider>(context, listen: false).clear();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startTimer();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<String> header2Titles = ['Sr', 'Sundry Name', 'Amount'];

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
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                          PETextFieldsNo(
                                            onSaved: (newValue) {
                                              purchaseController.noController
                                                  .text = newValue!;
                                            },
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.07,
                                            height: 30,
                                            controller:
                                                purchaseController.noController,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.00,
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.003),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              child: const Text(
                                                'Date',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, bottom: 14.0),
                                                child: TextFormField(
                                                  controller: purchaseController
                                                      .dateController,
                                                  onSaved: (newValue) {
                                                    purchaseController
                                                        .dateController
                                                        .text = newValue!;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        _selectedDate == null
                                                            ? '12/12/2023'
                                                            : formatter.format(
                                                                _selectedDate!),
                                                    border: InputBorder.none,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            child: IconButton(
                                                onPressed: _presentDatePICKER,
                                                icon: const Icon(
                                                    Icons.calendar_month)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.003,
                                            ),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              child: const Text(
                                                'Type',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                                    purchaseController
                                                        .typeController
                                                        .text = selectedStatus;
                                                    // Set Type
                                                  });
                                                },
                                                items:
                                                    status.map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text(
                                                        value,
                                                        softWrap: true,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              child: const Text(
                                                'Party',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.23,
                                            height: 30,
                                            padding: const EdgeInsets.all(2.0),
                                            child: SearchableDropDown(
                                              controller: purchaseController
                                                  .partyController,
                                              searchController:
                                                  purchaseController
                                                      .partyController,
                                              value: selectedLedgerName,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  if (selectedLedgerName !=
                                                      null) {
                                                    selectedLedgerName =
                                                        newValue;
                                                    purchaseController
                                                            .ledgerController
                                                            .text =
                                                        selectedLedgerName!;

                                                    final selectedLedger =
                                                        suggestionItems5.firstWhere(
                                                            (element) =>
                                                                element.id ==
                                                                selectedLedgerName);

                                                    ledgerAmount =
                                                        selectedLedger
                                                            .debitBalance;
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              searchMatchFn:
                                                  (item, searchValue) {
                                                final peLedger =
                                                    suggestionItems5
                                                        .firstWhere((e) =>
                                                            e.id == item.value)
                                                        .name;
                                                return peLedger
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase());
                                              },
                                            ),
                                            // child: DropdownButtonHideUnderline(
                                            //   child: DropdownButton<String>(
                                            //     value: selectedLedgerName,
                                            //     underline: Container(),
                                            //     onChanged: (String? newValue) {
                                            //       setState(() {
                                            //         if (selectedLedgerName !=
                                            //             null) {
                                            //           selectedLedgerName =
                                            //               newValue;
                                            //           purchaseController
                                            //                   .ledgerController
                                            //                   .text =
                                            //               selectedLedgerName!;

                                            //           final selectedLedger =
                                            //               suggestionItems5
                                            //                   .firstWhere(
                                            //                       (element) =>
                                            //                           element
                                            //                               .id ==
                                            //                           selectedLedgerName);

                                            //           ledgerAmount =
                                            //               selectedLedger
                                            //                   .openingBalance;
                                            //         }
                                            //       });
                                            //     },
                                            //     items: suggestionItems5
                                            //         .map((Ledger ledger) {
                                            //       return DropdownMenuItem<
                                            //           String>(
                                            //         value: ledger.id,
                                            //         child: Row(
                                            //           mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .spaceBetween,
                                            //           children: [
                                            //             Text(
                                            //               ledger.name,
                                            //               softWrap: true,
                                            //               style:
                                            //                   const TextStyle(
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
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.001,
                                            ),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              child: const Text(
                                                'Place',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.23,
                                            height: 30,
                                            padding: const EdgeInsets.all(2.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedState,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    selectedState = newValue;
                                                    purchaseController
                                                        .placeController
                                                        .text = selectedState!;
                                                  });
                                                },
                                                items:
                                                    indianStates.map((state) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: state,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          state,
                                                          softWrap: true,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              child: const Text(
                                                'Bill No',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          PETextFields(
                                            onSaved: (newValue) {
                                              purchaseController
                                                  .billNumberController
                                                  .text = newValue!;
                                            },
                                            controller: purchaseController
                                                .billNumberController,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            height: 30,
                                            readOnly: false,
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              child: const Text(
                                                'Date',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, bottom: 14.0),
                                                child: TextFormField(
                                                  onSaved: (newValue) {
                                                    purchaseController
                                                        .date2Controller
                                                        .text = newValue!;
                                                  },
                                                  controller: purchaseController
                                                      .date2Controller,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1),
                                                  decoration: InputDecoration(
                                                    hintText: _pickedDateData ==
                                                            null
                                                        ? '12/12/2023'
                                                        : formatter.format(
                                                            _pickedDateData!),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            child: IconButton(
                                                onPressed: _showDataPICKER,
                                                icon: const Icon(
                                                    Icons.calendar_month)),
                                          ),
                                          // Visibility(
                                          //   visible: selectedStatus == 'Cash',
                                          //   child: Padding(
                                          //     padding: EdgeInsets.only(
                                          //         left: MediaQuery.of(context)
                                          //                 .size
                                          //                 .width *
                                          //             0.01,
                                          //         top: MediaQuery.of(context)
                                          //                 .size
                                          //                 .width *
                                          //             0.003),
                                          //     child: SizedBox(
                                          //       width: MediaQuery.of(context)
                                          //               .size
                                          //               .width *
                                          //           0.05,
                                          //       child: const Text(
                                          //         'Cash',
                                          //         style: TextStyle(
                                          //             color: Colors.black,
                                          //             fontWeight:
                                          //                 FontWeight.bold),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          // Visibility(
                                          //   visible: selectedStatus == 'Cash',
                                          //   child: Flexible(
                                          //     child: Container(
                                          //       width: MediaQuery.of(context)
                                          //               .size
                                          //               .width *
                                          //           0.07,
                                          //       height: 30,
                                          //       decoration: BoxDecoration(
                                          //         border: Border.all(
                                          //             color: Colors.black),
                                          //         borderRadius:
                                          //             BorderRadius.circular(0),
                                          //       ),
                                          //       child: Padding(
                                          //         padding:
                                          //             const EdgeInsets.all(0.0),
                                          //         child: TextFormField(
                                          //           controller: purchaseController
                                          //               .cashAmountController,
                                          //           onSaved: (newValue) {
                                          //             purchaseController
                                          //                 .cashAmountController
                                          //                 .text = newValue!;
                                          //           },
                                          //           decoration:
                                          //               const InputDecoration(
                                          //             border: InputBorder.none,
                                          //           ),
                                          //           textAlign: TextAlign.start,
                                          //           style: const TextStyle(
                                          //               fontWeight:
                                          //                   FontWeight.bold,
                                          //               color: Colors.black),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),

                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(right: 18.0, bottom: 8.0),
                                //   child: Row(
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     mainAxisAlignment: MainAxisAlignment.end,
                                //     children: [
                                //       Container(
                                //         width: 100,
                                //         height: 25,
                                //         decoration: BoxDecoration(
                                //             border: Border.all(color: Colors.black)),
                                //         child: InkWell(
                                //           onTap: () {
                                //             final entryId = UniqueKey().toString();
                                //             setState(() {
                                //               _newWidget.add(
                                //                 PEntries(
                                //                   key: ValueKey(entryId),
                                //                   serialNumber: _newWidget.length + 1,
                                //                   itemNameControllerP:
                                //                       purchaseController
                                //                           .itemNameController,
                                //                   qtyControllerP: purchaseController
                                //                       .qtyController,
                                //                   rateControllerP: purchaseController
                                //                       .rateController,
                                //                   unitControllerP: purchaseController
                                //                       .unitController,
                                //                   amountControllerP:
                                //                       purchaseController
                                //                           .amountController,
                                //                   taxControllerP: purchaseController
                                //                       .taxController,
                                //                   sgstControllerP: purchaseController
                                //                       .sgstController,
                                //                   cgstControllerP: purchaseController
                                //                       .cgstController,
                                //                   igstControllerP: purchaseController
                                //                       .igstController,
                                //                   netAmountControllerP:
                                //                       purchaseController
                                //                           .netAmountController,
                                //                   sellingPriceControllerP:
                                //                       purchaseController
                                //                           .sellingPriceController,
                                //                   onSaveValues: saveValues,
                                //                   onDelete: (String entryId) {
                                //                     setState(
                                //                       () {
                                //                         _newWidget.removeWhere(
                                //                             (widget) =>
                                //                                 widget.key ==
                                //                                 ValueKey(entryId));

                                //                         // Find the map in _allValues that contains the entry with the specified entryId
                                //                         Map<String, dynamic>?
                                //                             entryToRemove;
                                //                         for (final entry
                                //                             in _allValues) {
                                //                           if (entry['uniqueKey'] ==
                                //                               entryId) {
                                //                             entryToRemove = entry;
                                //                             break;
                                //                           }
                                //                         }

                                //                         // Remove the map from _allValues if found
                                //                         if (entryToRemove != null) {
                                //                           _allValues
                                //                               .remove(entryToRemove);
                                //                         }
                                //                         calculateTotal();
                                //                       },
                                //                     );
                                //                   },
                                //                   entryId: entryId,
                                //                 ),
                                //               );
                                //             });
                                //           },
                                //           child: const Text(
                                //             'Add',
                                //             style: TextStyle(
                                //               color: Colors.black,
                                //               fontWeight: FontWeight.w900,
                                //               fontSize: 15,
                                //             ),
                                //             softWrap: false,
                                //             maxLines: 1,
                                //             overflow: TextOverflow.ellipsis,
                                //             textAlign: TextAlign.center,
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(right: 18.0, bottom: 8.0),
                                //   child: Row(
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     mainAxisAlignment: MainAxisAlignment.end,
                                //     children: [
                                //       Container(
                                //         width: 100,
                                //         height: 25,
                                //         decoration: BoxDecoration(
                                //             border: Border.all(color: Colors.black)),
                                //         child: InkWell(
                                //           onTap: calculateTotal,
                                //           child: const Text(
                                //             'Save all',
                                //             style: TextStyle(
                                //               color: Colors.black,
                                //               fontWeight: FontWeight.w900,
                                //               fontSize: 15,
                                //             ),
                                //             softWrap: false,
                                //             maxLines: 1,
                                //             overflow: TextOverflow.ellipsis,
                                //             textAlign: TextAlign.center,
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                //table header
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.023,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'SR',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          '   Item Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Qty',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Unit',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Rate',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Amount',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Tax%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'SGST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'CGST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'IGST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Disc.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.055,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        child: const Text(
                                          'Net Amt.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.055,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        child: const Text(
                                          'Selling Amt.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.023,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          'Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
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
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
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
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.061,
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
                                            MediaQuery.of(context).size.width *
                                                0.061,
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
                                            MediaQuery.of(context).size.width *
                                                0.061,
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
                                            MediaQuery.of(context).size.width *
                                                0.061,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide())),
                                        child: Text(
                                          Tdiscount.toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      Container(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.055,
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
                                            MediaQuery.of(context).size.width *
                                                0.055,
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.04),
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                          child: const Text(
                                                            'Remarks',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          height: 30,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          height: 170,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  44, 43, 43),
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.4,
                                                                height: 30,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  border:
                                                                      Border(
                                                                    bottom:
                                                                        BorderSide(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          44,
                                                                          43,
                                                                          43),
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Text(
                                                                    'Ledger Information',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          14,
                                                                          63,
                                                                          138),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.3,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.3,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                44,
                                                                                43,
                                                                                43),
                                                                            width:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.5,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Expanded(
                                                                              child: Text(
                                                                                'Limit',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Color.fromARGB(255, 20, 88, 181),
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 2,
                                                                              height: 30,
                                                                              color: const Color.fromARGB(255, 44, 43, 43),
                                                                            ),
                                                                            // Change Ledger Amount
                                                                            Expanded(
                                                                              child: Container(
                                                                                color: const Color(0xff70402a),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    (ledgerAmount + (TnetAmount + Ttotal)).toStringAsFixed(2),
                                                                                    textAlign: TextAlign.center,
                                                                                    style:
                                                                                        // ignore: prefer_const_constructors
                                                                                        TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 2,
                                                                              height: 30,
                                                                              color: const Color.fromARGB(255, 44, 43, 43),
                                                                            ),
                                                                            const Expanded(
                                                                              child: Text('Bal',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    color: Color.fromARGB(255, 20, 88, 181),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 15,
                                                                                  )),
                                                                            ),
                                                                            Container(
                                                                              width: 2,
                                                                              height: 30,
                                                                              color: const Color.fromARGB(255, 44, 43, 43),
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                color: const Color(0xff70402a),
                                                                                child: const Center(
                                                                                  child: Text(
                                                                                    '0.00 Dr',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
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
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Consumer<
                                                                OnChangeItenProvider>(
                                                            builder: (context,
                                                                itemID, _) {
                                                          return Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.4,
                                                            height: 170,
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    44,
                                                                    43,
                                                                    43),
                                                                width: 2,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {},
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(0),
                                                                            ),
                                                                            backgroundColor:
                                                                                const Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              243,
                                                                              132,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Statements',
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15),
                                                                            softWrap:
                                                                                false,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const Expanded(
                                                                      flex: 6,
                                                                      child:
                                                                          Text(
                                                                        'Recent Transaction for the item',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              20,
                                                                              88,
                                                                              181),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {},
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(0),
                                                                            ),
                                                                            backgroundColor: const Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                243,
                                                                                132),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Purchase',
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                // Table Starts Here
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  child: Row(
                                                                    children: List
                                                                        .generate(
                                                                      headerTitles
                                                                          .length,
                                                                      (index) =>
                                                                          Expanded(
                                                                        child:
                                                                            Text(
                                                                          headerTitles[
                                                                              index],
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                13,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                14,
                                                                                63,
                                                                                138),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),

                                                                // Table Body

                                                                Expanded(
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    child:
                                                                        Table(
                                                                      border: TableBorder.all(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              Colors.black),
                                                                      children: [
                                                                        // Iterate over all purchases' entries
                                                                        for (int i =
                                                                                0;
                                                                            i <
                                                                                fetchedPurchase
                                                                                    .length;
                                                                            i++)
                                                                          ...fetchedPurchase[i]
                                                                              .entries
                                                                              .where((entry) => entry.itemName == itemID.itemID)
                                                                              .map((entry) {
                                                                            // Find the corresponding ledger for the current entry
                                                                            String
                                                                                ledgerName =
                                                                                '';
                                                                            if (suggestionItems5.isNotEmpty) {
                                                                              final ledger = suggestionItems5.firstWhere(
                                                                                (ledger) => ledger.id == fetchedPurchase[i].ledger,
                                                                                orElse: () => Ledger(
                                                                                  id: '',
                                                                                  name: '',
                                                                                  printName: '',
                                                                                  aliasName: '',
                                                                                  ledgerGroup: '',
                                                                                  date: '',
                                                                                  bilwiseAccounting: '',
                                                                                  creditDays: 0,
                                                                                  openingBalance: 0,
                                                                                  debitBalance: 0,
                                                                                  ledgerType: '',
                                                                                  priceListCategory: '',
                                                                                  remarks: '',
                                                                                  status: '',
                                                                                  ledgerCode: 0,
                                                                                  mailingName: '',
                                                                                  address: '',
                                                                                  city: '',
                                                                                  region: '',
                                                                                  state: '',
                                                                                  pincode: 0,
                                                                                  tel: 0,
                                                                                  fax: 0,
                                                                                  mobile: 0,
                                                                                  sms: 0,
                                                                                  email: '',
                                                                                  contactPerson: '',
                                                                                  bankName: '',
                                                                                  branchName: '',
                                                                                  ifsc: '',
                                                                                  accName: '',
                                                                                  accNo: '',
                                                                                  panNo: '',
                                                                                  gst: '',
                                                                                  gstDated: '',
                                                                                  cstNo: '',
                                                                                  cstDated: '',
                                                                                  lstNo: '',
                                                                                  lstDated: '',
                                                                                  serviceTaxNo: '',
                                                                                  serviceTaxDated: '',
                                                                                  registrationType: '',
                                                                                  registrationTypeDated: '',
                                                                                ),
                                                                              );
                                                                              ledgerName = ledger.name;
                                                                            }

                                                                            return TableRow(
                                                                              children: [
                                                                                Text(
                                                                                  fetchedPurchase[i].date.toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                Text(
                                                                                  fetchedPurchase[i].billNumber.toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                Text(
                                                                                  ledgerName, // Display the ledger name here
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                Text(
                                                                                  entry.qty.toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                Text(
                                                                                  '${entry.rate}%', // Assuming this should be entry.rate, not entry.qty
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                Text(
                                                                                  entry.netAmount.toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Row(
                                                  children: List.generate(
                                                    header2Titles.length,
                                                    (index) => Expanded(
                                                      child: Text(
                                                        header2Titles[index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: InkWell(
                                                        onTap: calculateSundry,
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          final entryId =
                                                              UniqueKey()
                                                                  .toString();

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
                                                                  onSaveValues:
                                                                      saveSundry,
                                                                  entryId:
                                                                      entryId,
                                                                  onDelete: (String
                                                                      entryId) {
                                                                    setState(
                                                                        () {
                                                                      _newSundry.removeWhere((widget) =>
                                                                          widget
                                                                              .key ==
                                                                          ValueKey(
                                                                              entryId));

                                                                      Map<String,
                                                                              dynamic>?
                                                                          entryToRemove;
                                                                      for (final entry
                                                                          in _allValuesSundry) {
                                                                        if (entry['uniqueKey'] ==
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
                                                                            .remove(entryToRemove);
                                                                      }
                                                                      calculateSundry();
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(
                                                height: 110,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          height: 30,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0,
                                            child: ElevatedButton(
                                              onPressed: createPurchase,
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  const Color.fromARGB(
                                                      255, 255, 243, 132),
                                                ),
                                                shape: MaterialStateProperty
                                                    .all<OutlinedBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.0),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.002,
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          height: 30,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  const Color.fromARGB(
                                                      255, 255, 243, 132),
                                                ),
                                                shape: MaterialStateProperty
                                                    .all<OutlinedBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.0),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.002,
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          height: 30,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0,
                                            child: ElevatedButton(
                                              onPressed: clearAll,
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  const Color.fromARGB(
                                                      255, 255, 243, 132),
                                                ),
                                                shape: MaterialStateProperty
                                                    .all<OutlinedBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.0),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 20,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                child: const Text(
                                                  'Round-Off: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 20,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            width: 2))),
                                                child: Text(
                                                  '- ${roundOff.toStringAsFixed(2)}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 20,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                child: const Text(
                                                  'Amount: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 20,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            width: 2))),
                                                child: Text(
                                                  '$roundedValue',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                        // Container(
                        //   width: MediaQuery.of(context).size.width * 0.1,
                        // ),

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
                                    builder: (context) => const PEMasterBody(),
                                  ),
                                );
                                return KeyEventResult.handled;
                              } else if (event is RawKeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.f4) {
                                final entryId = UniqueKey().toString();
                                setState(() {
                                  _newWidget.add(
                                    PEntries(
                                      key: ValueKey(entryId),
                                      serialNumber: _newWidget.length + 1,
                                      itemNameControllerP:
                                          purchaseController.itemNameController,
                                      qtyControllerP:
                                          purchaseController.qtyController,
                                      rateControllerP:
                                          purchaseController.rateController,
                                      unitControllerP:
                                          purchaseController.unitController,
                                      discountControllerP:
                                          purchaseController.discountController,
                                      amountControllerP:
                                          purchaseController.amountController,
                                      taxControllerP:
                                          purchaseController.taxController,
                                      sgstControllerP:
                                          purchaseController.sgstController,
                                      cgstControllerP:
                                          purchaseController.cgstController,
                                      igstControllerP:
                                          purchaseController.igstController,
                                      netAmountControllerP: purchaseController
                                          .netAmountController,
                                      sellingPriceControllerP:
                                          purchaseController
                                              .sellingPriceController,
                                      onSaveValues: saveValues,
                                      onDelete: (String entryId) {
                                        setState(
                                          () {
                                            _newWidget.removeWhere((widget) =>
                                                widget.key ==
                                                ValueKey(entryId));

                                            // Find the map in _allValues that contains the entry with the specified entryId
                                            Map<String, dynamic>? entryToRemove;
                                            for (final entry in _allValues) {
                                              if (entry['uniqueKey'] ==
                                                  entryId) {
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
                                      item: [],
                                      taxCategory: [],
                                      measurementLimit: [],
                                    ),
                                  );
                                });
                              } else if (event is RawKeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.keyM) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NIMyDesktopBody(),
                                  ),
                                );
                              } else if (event is RawKeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.keyL) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LGMyDesktopBody(),
                                  ),
                                );
                              }
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
                                              const PEMasterBody(),
                                        ),
                                      );
                                    },
                                  ),
                                  CustomList(
                                    Skey: "L",
                                    name: "Create Ledger",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LGMyDesktopBody(),
                                        ),
                                      );
                                    },
                                  ),
                                  CustomList(
                                      Skey: "F5",
                                      name: "Payment",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "F6",
                                      name: "Receipt",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "F7",
                                      name: "Journal",
                                      onTap: () {}),
                                  CustomList(Skey: "", name: "", onTap: () {}),
                                  CustomList(
                                      Skey: "F8", name: "Contra", onTap: () {}),
                                  CustomList(
                                    Skey: "F4",
                                    name: "Create New",
                                    onTap: () {
                                      final entryId = UniqueKey().toString();
                                      setState(() {
                                        _newWidget.add(
                                          PEntries(
                                            key: ValueKey(entryId),
                                            serialNumber: _newWidget.length + 1,
                                            itemNameControllerP:
                                                purchaseController
                                                    .itemNameController,
                                            qtyControllerP: purchaseController
                                                .qtyController,
                                            rateControllerP: purchaseController
                                                .rateController,
                                            unitControllerP: purchaseController
                                                .unitController,
                                            amountControllerP:
                                                purchaseController
                                                    .amountController,
                                            taxControllerP: purchaseController
                                                .taxController,
                                            discountControllerP:
                                                purchaseController
                                                    .discountController,
                                            sgstControllerP: purchaseController
                                                .sgstController,
                                            cgstControllerP: purchaseController
                                                .cgstController,
                                            igstControllerP: purchaseController
                                                .igstController,
                                            netAmountControllerP:
                                                purchaseController
                                                    .netAmountController,
                                            sellingPriceControllerP:
                                                purchaseController
                                                    .sellingPriceController,
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
                                            item: itemsList,
                                            taxCategory: [],
                                            measurementLimit: [],
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                  CustomList(
                                      Skey: "N",
                                      name: "Search No",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "M",
                                      name: "Create Item",
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NIMyDesktopBody(),
                                          ),
                                        );
                                      }),
                                  CustomList(
                                    Skey: "",
                                    name: "",
                                    onTap: () {},
                                  ),
                                  CustomList(
                                      Skey: "F12",
                                      name: "Discount",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "F12",
                                      name: "Audit Trail",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "PgUp",
                                      name: "Previous",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "PgDn", name: "Next", onTap: () {}),
                                  CustomList(Skey: "", name: "", onTap: () {}),
                                  CustomList(
                                      Skey: "G",
                                      name: "Attach. Img",
                                      onTap: () {}),
                                  CustomList(Skey: "", name: "", onTap: () {}),
                                  CustomList(
                                      Skey: "G",
                                      name: "Vch Setup",
                                      onTap: () {}),
                                  CustomList(
                                      Skey: "T",
                                      name: "Print Setup",
                                      onTap: () {}),
                                  CustomList(Skey: "", name: "", onTap: () {}),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
