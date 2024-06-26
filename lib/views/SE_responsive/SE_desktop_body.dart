// ignore: file_names
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:billingsphere/data/models/item/item_model.dart';
import 'package:billingsphere/data/models/ledger/ledger_model.dart';
import 'package:billingsphere/data/models/salesEntries/sales_entrires_model.dart';
import 'package:billingsphere/data/repository/ledger_repository.dart';
import 'package:billingsphere/data/repository/sales_enteries_repository.dart';
import 'package:billingsphere/utils/controllers/sales_text_controllers.dart';
import 'package:billingsphere/views/LG_responsive/LG_desktop_body.dart';
import 'package:billingsphere/views/SE_common/SE_form_buttons.dart';
import 'package:billingsphere/views/SE_common/SE_top_text.dart';
import 'package:billingsphere/views/SE_common/SE_top_textfield.dart';
import 'package:billingsphere/views/SE_variables/SE_variables.dart';
import 'package:billingsphere/views/SE_widgets/SE_desktop_appbar.dart';
import 'package:billingsphere/views/SE_widgets/sundry_row.dart';
import 'package:billingsphere/views/SE_widgets/table_row.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/onchange_item_provider.dart';
import '../../auth/providers/onchange_ledger_provider.dart';
import '../../data/models/measurementLimit/measurement_limit_model.dart';
import '../../data/models/price/price_category.dart';
import '../../data/models/taxCategory/tax_category_model.dart';
import '../../data/repository/item_repository.dart';
import '../../data/repository/measurement_limit_repository.dart';
import '../../data/repository/price_category_repository.dart';
import '../../data/repository/tax_category_repository.dart';
import '../../utils/controllers/sundry_controller.dart';
import '../Barcode_responsive/barcode_print_desktop_body.dart';
import '../DB_responsive/DB_desktop_body.dart';
import '../NI_responsive.dart/NI_desktopBody.dart';
import '../SE_widgets/dispatch.dart';
import '../SE_widgets/table_footer.dart';
import '../SE_widgets/table_header.dart';
import '../sumit_screen/voucher _entry.dart/voucher_list_widget.dart';
import 'SE_master.dart';
import 'SE_multimode.dart';
import 'SE_receipt_2.dart';

class SEMyDesktopBody extends StatefulWidget {
  const SEMyDesktopBody({super.key});

  @override
  State<SEMyDesktopBody> createState() => _SEMyDesktopBodyState();
}

class _SEMyDesktopBodyState extends State<SEMyDesktopBody> {
  DateTime? _selectedDate;
  DateTime? _pickedDateData;
  List<String> status = ['CASH', 'DEBIT', 'MULTI MODE'];
  String selectedStatus = 'DEBIT';
  String selectedsundry = 'Cash Discount';
  String selectedPlaceState = 'Gujarat';
  bool isLoading = false;
  final bool _isSaving = false;
  final formatter = DateFormat('dd/MM/yyyy');
  int _generatedNumber = 0;
  double ledgerAmount = 0;
  double itemRate = 0.0;
  String? selectedPriceTypeId;
  //fetch ledger
  List<Ledger> suggestionItems5 = [];
  String? selectedLedgerName;
  LedgerService ledgerService = LedgerService();
  Ledger? _ledgers;

  //fetch sales
  List<SalesEntry> suggestionItems6 = [];
  String? selectedSales;
  SalesEntryService salesService = SalesEntryService();
  SalesEntryFormController salesEntryFormController =
      SalesEntryFormController();

  //fetch item
  List<Item> itemsList = [];
  List<PriceCategory> pricecategory = [];
  List<TaxRate> taxLists = [];
  List<MeasurementLimit> measurement = [];
  ItemsService itemsService = ItemsService();
  PriceCategoryRepository pricetypeService = PriceCategoryRepository();
  SundryFormController sundryFormController = SundryFormController();
  TaxRateService taxRateService = TaxRateService();
  MeasurementLimitService measurementService = MeasurementLimitService();
  List<String> ledgerNames = [];

  List<String> placestate = [
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

  final List<SEntries> _newWidget = [];
  final List<SundryRow> _newSundry = [];

  int _currentSerialNumber = 1;
  int _currentSerialNumberSundry = 1;

  final List<Map<String, dynamic>> _allValues = [];
  final List<Map<String, dynamic>> _allValuesSundry = [];

  late Timer _timer;

  void _startTimer() {
    const Duration duration = Duration(seconds: 2);
    _timer = Timer.periodic(duration, (Timer timer) {
      calculateTotal();
      calculateSundry();
    });
  }

  // Dispatch Values
  final Map<String, dynamic> dispacthDetails = {};
  final Map<String, dynamic> moreDetails = {};
  final Map<String, dynamic> multimodeDetails = {};
  final TextEditingController _advpaymentController = TextEditingController();
  final TextEditingController _advpaymentdateController =
      TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _toteldebitamountController =
      TextEditingController();

  void saveMoreDetailsValues() {
    moreDetails['advpayment'] = _advpaymentController.text;
    moreDetails['advpaymentdate'] = _advpaymentdateController.text;
    moreDetails['installment'] = _installmentController.text;
    moreDetails['toteldebitamount'] = _toteldebitamountController.text;

    Navigator.of(context).pop();
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
      salesEntryFormController.noController.text = _generatedNumber.toString();
      salesEntryFormController.dcNoController.text =
          'HN00${_generatedNumber.toString()}';
    });
  }

  Future<void> fetchSales() async {
    try {
      final List<SalesEntry> sales = await salesService.fetchSalesEntries();
      final filteredSalesEntry = sales
          .where((salesentry) => salesentry.companyCode == companyCode!.first)
          .toList();

      setState(() {
        suggestionItems6 = filteredSalesEntry;
        _generateRandomNumber();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchSingleLedger(String id) async {
    try {
      final ledger = await ledgerService.fetchLedgerById(id);

      setState(() {
        _ledgers = ledger;
      });
      String variable = '';
      for (PriceCategory price in pricecategory) {
        if (price.id == _ledgers!.priceListCategory) {
          variable = price.priceCategoryType;

          if (variable == 'SUB DEALER') {
            itemRate = itemsList.first.dealer;
            salesEntryFormController.rateController.text = itemRate.toString();
          } else if (variable == 'DEALER') {
            itemRate = itemsList.first.subDealer;
            salesEntryFormController.rateController.text = itemRate.toString();
          } else if (variable == 'Retailer') {
            itemRate = itemsList.first.retail;
            salesEntryFormController.rateController.text = itemRate.toString();
          } else {
            itemRate = itemsList.first.mrp;
            salesEntryFormController.rateController.text = itemRate.toString();
          }
        }
      }
    } catch (ex) {
      print(ex);
    }
  }

  void _generateBillNumber() {
    // Generate a random number between 100 and 999
    Random random = Random();
    int randomNumber = random.nextInt(9000) + 1000;

    // Get the current month abbreviation
    String monthAbbreviation = _getMonthAbbreviation(DateTime.now().month);

    // Construct the bill number
    String billNumber =
        'HN000000000000000000000000000${salesEntryFormController.noController.text}';

    setState(() {
      // salesEntryFormController.dcNoController.text = billNumber;
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

  Future<void> fetchPriceCategoryType() async {
    try {
      final List<PriceCategory> priceType =
          await pricetypeService.fetchPriceCategories();

      setState(() {
        pricecategory = priceType;
        selectedPriceTypeId =
            pricecategory.isNotEmpty ? pricecategory.first.id : null;
      });

      print(pricecategory);
    } catch (error) {
      print('Failed to fetch Price Type: $error');
    }
  }

  Future<void> createSalesEntry() async {
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
    updateDueAmountController();

    final salesEntry = SalesEntry(
      id: '',
      companyCode: companyCode!.first,
      no: int.parse(salesEntryFormController.noController.text),
      date: salesEntryFormController.dateController1.text,
      type: salesEntryFormController.typeController.text,
      party: selectedLedgerName!,
      place: selectedPlaceState,
      dcNo: salesEntryFormController.dcNoController.text,
      date2: salesEntryFormController.dateController2.text,
      totalamount: (TnetAmount + Ttotal).toString(),
      cashAmount: salesEntryFormController.cashAmountController.text == ''
          ? '0'
          : salesEntryFormController.cashAmountController.text,
      dueAmount: salesEntryFormController.dueAmountController.text == ''
          ? '0'
          : salesEntryFormController.dueAmountController.text,
      entries: _allValues.map((entry) {
        return Entry(
          itemName: entry['itemName'],
          qty: int.tryParse(entry['qty']) ?? 0,
          rate: double.tryParse(entry['rate']) ?? 0,
          unit: entry['unit'],
          amount: double.tryParse(entry['amount']) ?? 0,
          tax: entry['tax'] ?? 0,
          discount: double.tryParse(entry['discount']) ?? 0,
          sgst: double.tryParse(entry['sgst']) ?? 0,
          cgst: double.tryParse(entry['cgst']) ?? 0,
          igst: double.tryParse(entry['igst']) ?? 0,
          netAmount: double.tryParse(entry['netAmount']) ?? 0,
        );
      }).toList(),
      sundry: _allValuesSundry.map((sundry) {
        return Sundry2(
          sundryName: sundry['sndryName'],
          amount: double.tryParse(sundry['sundryAmount']) ?? 0,
        );
      }).toList(),
      remark: salesEntryFormController.remarkController?.text ?? '',
      dispatch: dispacthDetails.isNotEmpty
          ? [
              Dispatch(
                transAgency: dispacthDetails['transAgency'] ?? '',
                docketNo: dispacthDetails['docketNo'] ?? '',
                vehicleNo: dispacthDetails['vehicleNo'] ?? '',
                fromStation: dispacthDetails['fromStation'] ?? '',
                fromDistrict: dispacthDetails['fromDistrict'] ?? '',
                transMode: dispacthDetails['transMode'] ?? '',
                parcel: dispacthDetails['parcel'] ?? '',
                freight: dispacthDetails['freight'] ?? '',
                kms: dispacthDetails['kms'] ?? '',
                toState: dispacthDetails['toState'] ?? '',
                ewayBill: dispacthDetails['ewayBill'] ?? '',
                billingAddress: dispacthDetails['billingAddress'] ?? '',
                shippedTo: dispacthDetails['shippedTo'] ?? 'shippedTo',
                shippingAddress:
                    dispacthDetails['shippingAddress'] ?? 'shippingAddress',
                phoneNo: dispacthDetails['phoneNo'] ?? 'phoneNo',
                gstNo: dispacthDetails['gstNo'] ?? 'gstNo',
                remarks: dispacthDetails['remarks'] ?? 'remarks',
                licenceNo: dispacthDetails['licenceNo'] ?? 'lincenseNo',
                issueState: dispacthDetails['issueState'] ?? 'issueState',
                name: dispacthDetails['name'] ?? 'name ',
                address: dispacthDetails['address'] ?? 'Address',
              )
            ]
          : [],
      multimode: multimodeDetails.isNotEmpty
          ? [
              Multimode(
                cash: multimodeDetails['cash'] ?? '',
                debit: multimodeDetails['debit'] ?? '',
                adjustedamount: multimodeDetails['adjustedamount'] ?? '',
                pending: multimodeDetails['pendingAmount'] ?? '',
                finalamount: multimodeDetails['finalAmount'] ?? '',
              ),
            ]
          : [],
      moredetails: moreDetails.isNotEmpty
          ? [
              MoreDetails(
                advpayment: moreDetails['advpayment'] ?? '',
                advpaymentdate: moreDetails['advpaymentdate'] ?? '',
                installment: moreDetails['installment'] ?? '',
                toteldebitamount: moreDetails['toteldebitamount'] ?? '',
              )
            ]
          : [],
    );

    clearAll();

    bool success = await salesService.addSalesEntry(salesEntry, context);
    // Get the id of the newly added sales entry
    if (success) {
      fetchSales().then((_) {
        final newSalesEntry = suggestionItems6.firstWhere(
            (element) => element.no == salesEntry.no,
            orElse: () => SalesEntry(
                  id: '',
                  companyCode: '',
                  no: 0,
                  date: '',
                  type: '',
                  party: '',
                  place: '',
                  dcNo: '',
                  date2: '',
                  totalamount: '',
                  cashAmount: '',
                  dueAmount: '',
                  entries: [],
                  sundry: [],
                  remark: '',
                  dispatch: [],
                  multimode: [],
                  moredetails: [],
                ));

        // Navigate to the sales entry details page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Print Receipt'),
              content: const Text('Do you want to print receipt?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PrintBigReceipt(
                            sales: newSalesEntry.id, 'Print Sales Receipt'),
                      ),
                    );
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const DBMyDesktopBody()),
                    );
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  // Functions
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

  // Total Values
  double Ttotal = 0.00;
  double Tqty = 0.00;
  double Tamount = 0.00;
  double Tsgst = 0.00;
  double Tcgst = 0.00;
  double Tigst = 0.00;
  double TnetAmount = 0.00;
  double Tdiscount = 0.00;
  double roundedValue = 0.00;
  double roundOff = 0.00;

  // Calculate total debit and credit
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

  void updateDueAmountController() {
    // Ensure TnetAmount and Ttotal are not null and are of type double
    if (TnetAmount == null || Ttotal == null) {
      print("Error: TnetAmount or Ttotal is null");
      salesEntryFormController.dueAmountController.text = '0';
    } else {
      if (selectedStatus == 'DEBIT') {
        salesEntryFormController.dueAmountController.text =
            (TnetAmount + Ttotal).toString();
      } else if (selectedStatus == 'MULTI MODE') {
        // Convert debit to a string
        String? debit = multimodeDetails['debit']?.toString();
        // Check if debit is a valid string
        if (debit == null || debit.isEmpty) {
          print("Error: Debit is null or empty");
          salesEntryFormController.dueAmountController.text = '0';
        } else {
          salesEntryFormController.dueAmountController.text = debit;
        }
      } else {
        salesEntryFormController.dueAmountController.text = '0';
      }
    }
  }

  // Fluttertoast.showToast(
  //   msg: "Values added to list successfully!",
  //   toastLength: Toast.LENGTH_LONG,
  //   gravity: ToastGravity.CENTER_RIGHT,
  //   webPosition: "right",
  //   timeInSecForIosWeb: 1,
  //   backgroundColor: Colors.black,
  //   textColor: Colors.white,
  // );

  void calculateSundry() {
    double total = 0.00;
    for (var values in _allValuesSundry) {
      total += double.tryParse(values['sundryAmount']) ?? 0;
      // ledgerAmount -= (TnetAmount + total);
    }

    setState(() {
      Ttotal = total;
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

  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();

      items.insert(
        0,
        Item(
          id: '',
          itemName: '',
          itemGroup: '',
          itemBrand: '',
          hsnCode: '',
          mrp: 0.0,
          taxCategory: '',
          measurementUnit: '',
          secondaryUnit: '',
          barcode: '',
          codeNo: '0',
          date: DateTime.now().toString(),
          dealer: 0,
          maximumStock: 0,
          minimumStock: 0,
          monthlySalesQty: 0,
          openingStock: '0',
          price: 0,
          printName: '',
          retail: 0,
          status: '',
          storeLocation: '',
          subDealer: 0,
          openingBalance: [],
          openingBalanceAmt: 0.00,
          openingBalanceQty: 0.00,
        ),
      );

      setState(() {
        itemsList = items;
      });

      // print("Rate Controller ${widget.rateControllerP.text}");
    } catch (error) {
      // print('Failed to fetch item name: $error');
    }
  }

  Future<void> fetchAndSetTaxRates() async {
    try {
      final List<TaxRate> taxRates = await taxRateService.fetchTaxRates();

      setState(() {
        taxLists = taxRates;
      });
    } catch (error) {
      // print('Failed to fetch Tax Rates: $error');
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
    setState(() {
      isLoading = true;
    });
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
          ledgerGroup: '',
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

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        suggestionItems5 = ledger
            .where((element) =>
                element.status == 'Yes' &&
                element.ledgerGroup != '662f97d2a07ec73369c237b0')
            .toList();
        ledgerNames = suggestionItems5.map((ledger) => ledger.name).toList();

        selectedLedgerName =
            suggestionItems5.isNotEmpty ? suggestionItems5.first.id : null;
        ledgerAmount = suggestionItems5.first.debitBalance;

        isLoading = false;
      });
    } catch (error) {}
  }

  Future<void> _initliazeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        setCompanyCode(),
        fetchLedgers2(),
        fetchSales(),
        fetchItems(),
        fetchAndSetTaxRates(),
        fetchMeasurementLimit(),
        fetchPriceCategoryType(),
        Future.delayed(const Duration(seconds: 1)),
      ]);

      //item
      for (int i = 0; i < 10; i++) {
        final entryId = UniqueKey().toString();
        setState(() {
          _newWidget.add(SEntries(
            key: ValueKey(entryId),
            serialNumber: _currentSerialNumber,
            itemNameControllerP: salesEntryFormController.itemNameController,
            qtyControllerP: salesEntryFormController.qtyController,
            rateControllerP: salesEntryFormController.rateController,
            unitControllerP: salesEntryFormController.unitController,
            amountControllerP: salesEntryFormController.amountController,
            discountControllerP: salesEntryFormController.discountController,
            taxControllerP: salesEntryFormController.taxController,
            sgstControllerP: salesEntryFormController.sgstController,
            cgstControllerP: salesEntryFormController.cgstController,
            igstControllerP: salesEntryFormController.igstController,
            netAmountControllerP: salesEntryFormController.netAmountController,
            selectedLegerId: selectedLedgerName!,
            onSaveValues: saveValues,
            onDelete: (String entryId) {
              setState(() {
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

                // Calculate total
                calculateTotal();
              });
            },
            entryId: entryId,
            itemsList: itemsList,
            measurement: measurement,
            taxLists: taxLists,
            pricecategory: pricecategory,
          ));
          _currentSerialNumber++;
        });
      }

      //sundry
      for (int i = 0; i < 4; i++) {
        final entryId = UniqueKey().toString();

        setState(() {
          _newSundry.add(
            SundryRow(
                key: ValueKey(entryId),
                serialNumber: _currentSerialNumberSundry,
                sundryControllerP: sundryFormController.sundryController,
                sundryControllerQ: sundryFormController.amountController,
                onSaveValues: saveSundry,
                entryId: entryId,
                onDelete: (String entryId) {
                  setState(() {
                    _newSundry.removeWhere(
                        (widget) => widget.key == ValueKey(entryId));

                    Map<String, dynamic>? entryToRemove;
                    for (final entry in _allValuesSundry) {
                      if (entry['uniqueKey'] == entryId) {
                        entryToRemove = entry;
                        break;
                      }
                    }

                    // Remove the map from _allValues if found
                    if (entryToRemove != null) {
                      _allValuesSundry.remove(entryToRemove);
                    }
                    calculateSundry();
                  });
                }),
          );
          _currentSerialNumberSundry++;
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

  void clearAll() {
    setState(() {
      _newWidget.clear();
      _newSundry.clear();
      _allValues.clear();
      _allValuesSundry.clear();
      dispacthDetails.clear();
      Ttotal = 0.00;
      Tqty = 0.00;
      Tamount = 0.00;
      Tsgst = 0.00;
      Tcgst = 0.00;
      Tigst = 0.00;
      TnetAmount = 0.00;
      roundOff = 0.00;
      roundedValue = 0.00;
      salesEntryFormController.noController.clear();
      // salesEntryFormController.dateController1.clear();
      selectedLedgerName = suggestionItems5.first.id;
      salesEntryFormController.dcNoController.clear();
      // salesEntryFormController.dateController2.clear();
      salesEntryFormController.remarkController?.clear();
      _generateBillNumber();
      _generateRandomNumber();
    });
  }

  void _initializaControllers() {
    salesEntryFormController.noController.text = _generatedNumber.toString();
    salesEntryFormController.typeController.text = selectedStatus;
    salesEntryFormController.dateController1.text =
        formatter.format(DateTime.now());
    salesEntryFormController.dateController2.text =
        formatter.format(DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
    _newSundry.clear();
    _allValues.clear();
    _allValuesSundry.clear();
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _initliazeData();
    _generateRandomNumber();
    // _generateBillNumber();
    _initializaControllers();
    _startTimer();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<OnChangeLedgerProvider>(context);

    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : suggestionItems5.isEmpty
            ? Scaffold(
                body: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xff79442F),
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
                            'SALES ENTRY',
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lottie/PageNotFound.json',
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Ledger Found!, Click the Button Below to Add New Ledger',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LGMyDesktopBody(),
                                ),
                              );
                            },
                            child: const Text(
                              'Create New Ledger',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SEDesktopAppbar(
                          text1: 'Tax Invoice GST',
                          text2: 'Sales Entry',
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.901,
                            child: Opacity(
                              opacity: _isSaving ? 0.5 : 1,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                SETopText(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  height: 30,
                                                  text: 'No',
                                                  padding: EdgeInsets.only(
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00),
                                                ),
                                                SETopTextfield(
                                                  controller:
                                                      salesEntryFormController
                                                          .noController,
                                                  onSaved: (newValue) {
                                                    salesEntryFormController
                                                        .noController
                                                        .text = newValue!;
                                                  },
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.07,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          bottom: 16.0),
                                                  hintText: '',
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: SETopText(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                    height: 30,
                                                    text: 'Date',
                                                    padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.00,
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.0005),
                                                  ),
                                                ),
                                                SETopTextfield(
                                                  controller:
                                                      salesEntryFormController
                                                          .dateController1,
                                                  onSaved: (newValue) {
                                                    salesEntryFormController
                                                        .dateController1
                                                        .text = newValue!;
                                                  },
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.09,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          bottom: 16.0),
                                                  hintText:
                                                      _selectedDate == null
                                                          ? '12/12/2023'
                                                          : formatter.format(
                                                              _selectedDate!),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                  child: IconButton(
                                                      onPressed:
                                                          _presentDatePICKER,
                                                      icon: const Icon(Icons
                                                          .calendar_month)),
                                                ),
                                                SETopText(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  height: 30,
                                                  text: 'Type',
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.0005,
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      value: selectedStatus,
                                                      underline: Container(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedStatus =
                                                              newValue!;
                                                          salesEntryFormController
                                                                  .typeController
                                                                  .text =
                                                              selectedStatus;
                                                          // Set Type
                                                        });
                                                      },
                                                      items: status
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(value),
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 2.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SETopText(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  height: 30,
                                                  text: 'Party',
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00,
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.377,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  // child: SearchField<String>(
                                                  //   onSuggestionTap: (value) {
                                                  //     final selectedLedger =
                                                  //         suggestionItems5.firstWhere(
                                                  //             (element) =>
                                                  //                 element.id ==
                                                  //                 value
                                                  //                     .searchKey
                                                  //                     .toString());
                                                  //     setState(() {
                                                  //       selectedLedgerName =
                                                  //           selectedLedger.id;
                                                  //       fetchSingleLedger(
                                                  //           selectedLedgerName!);
                                                  //       ledgerAmount =
                                                  //           selectedLedger
                                                  //               .debitBalance;
                                                  //       lp.setLedger(selectedLedger
                                                  //           .priceListCategory);
                                                  //     });
                                                  //   },
                                                  //   suggestions: suggestionItems5
                                                  //       .map((ledger) =>
                                                  //           SearchFieldListItem<
                                                  //                   String>(
                                                  //               ledger.name))
                                                  //       .toList(),
                                                  // ),
                                                  // child:
                                                  //     DropdownButtonHideUnderline(
                                                  //   child:
                                                  //       DropdownButton<String>(
                                                  //     value: selectedLedgerName,
                                                  //     underline: Container(),
                                                  //     onChanged:
                                                  //         (String? newValue) {
                                                  //       setState(() {
                                                  //         selectedLedgerName =
                                                  //             newValue;
                                                  //         fetchSingleLedger(
                                                  //             selectedLedgerName!);
                                                  //         if (selectedLedgerName !=
                                                  //             null) {
                                                  //           final selectedLedger =
                                                  //               suggestionItems5.firstWhere(
                                                  //                   (element) =>
                                                  //                       element
                                                  //                           .id ==
                                                  //                       selectedLedgerName);
                                                  //           ledgerAmount =
                                                  //               selectedLedger
                                                  //                   .debitBalance;
                                                  //           lp.setLedger(
                                                  //               selectedLedger
                                                  //                   .priceListCategory);
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
                                                  //             Text(ledger.name),
                                                  //           ],
                                                  //         ),
                                                  //       );
                                                  //     }).toList(),
                                                  //   ),
                                                  // ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      hint: Text(
                                                        'Select Item',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                        ),
                                                      ),
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
                                                              Text(ledger.name),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                      value: selectedLedgerName,
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedLedgerName =
                                                              newValue;
                                                          fetchSingleLedger(
                                                              selectedLedgerName!);

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

                                                            lp.setLedger(
                                                                selectedLedger
                                                                    .priceListCategory);
                                                          }
                                                        });
                                                      },
                                                      buttonStyleData:
                                                          const ButtonStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 16,
                                                        ),
                                                        height: 40,
                                                        width: 200,
                                                      ),
                                                      dropdownStyleData:
                                                          const DropdownStyleData(
                                                        maxHeight: 200,
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        height: 40,
                                                      ),
                                                      dropdownSearchData:
                                                          DropdownSearchData(
                                                        searchController:
                                                            salesEntryFormController
                                                                .partyController,
                                                        searchInnerWidgetHeight:
                                                            50,
                                                        searchInnerWidget:
                                                            Container(
                                                          height: 50,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 8,
                                                            bottom: 4,
                                                            right: 8,
                                                            left: 8,
                                                          ),
                                                          child: TextFormField(
                                                            onChanged:
                                                                (value) {},
                                                            expands: true,
                                                            maxLines: null,
                                                            controller:
                                                                salesEntryFormController
                                                                    .partyController,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                              hintText:
                                                                  'Search for an item...',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  8,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        searchMatchFn: (item,
                                                            searchValue) {
                                                          final ledgerName =
                                                              suggestionItems5
                                                                  .firstWhere((e) =>
                                                                      e.id ==
                                                                      item.value)
                                                                  .name;

                                                          return ledgerName
                                                              .toLowerCase()
                                                              .contains(searchValue
                                                                  .toLowerCase());
                                                        },
                                                      ),
                                                      // //This to clear the search value when you close the menu
                                                      // onMenuStateChange: (isOpen) {
                                                      //   if (!isOpen) {
                                                      //     textEditingController.clear();
                                                      //   }
                                                      // },
                                                    ),
                                                  ),
                                                ),

                                                SETopText(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  height: 30,
                                                  text: 'Place',
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.01,
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00,
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00),
                                                ),
                                                // Custom Textfield

                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.14,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      menuMaxHeight: 300,
                                                      isExpanded: true,
                                                      value: selectedPlaceState,
                                                      underline: Container(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedPlaceState =
                                                              newValue!;
                                                          salesEntryFormController
                                                                  .placeController
                                                                  .text =
                                                              selectedPlaceState;
                                                        });
                                                      },
                                                      items: placestate
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(value),
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
                                    ),
                                    const SizedBox(height: 2),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 2.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SETopText(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  height: 30,
                                                  text: 'Bill No',
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00,
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.00),
                                                ),
                                                // Text Button to generate new Bill Number
                                                // TextButton(
                                                //     onPressed: _generateBillNumber,
                                                //     child: Text(
                                                //       'Generate',
                                                //       style: GoogleFonts.poppins(
                                                //         textStyle: const TextStyle(
                                                //           color: Colors.black,
                                                //           fontSize: 15,
                                                //         ),
                                                //       ),
                                                //     )),
                                                SETopTextfield(
                                                  controller:
                                                      salesEntryFormController
                                                          .dcNoController,
                                                  onSaved: (newValue) {
                                                    salesEntryFormController
                                                        .dcNoController
                                                        .text = newValue!;
                                                  },
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.248,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          bottom: 16.0),
                                                  hintText: '',
                                                ),
                                                const SizedBox(width: 20),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: SETopText(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                    height: 30,
                                                    text: 'Date',
                                                    padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.0005,
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.00),
                                                  ),
                                                ),
                                                SETopTextfield(
                                                  controller:
                                                      salesEntryFormController
                                                          .dateController2,
                                                  onSaved: (newValue) {
                                                    salesEntryFormController
                                                        .dateController2
                                                        .text = newValue!;

                                                    print(
                                                        salesEntryFormController
                                                            .dateController2
                                                            .text);
                                                  },
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.09,
                                                  height: 30,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          bottom: 16.0),
                                                  hintText:
                                                      _pickedDateData == null
                                                          ? '12/12/2023'
                                                          : formatter.format(
                                                              _pickedDateData!),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                  child: IconButton(
                                                      onPressed:
                                                          _showDataPICKER,
                                                      icon: const Icon(Icons
                                                          .calendar_month)),
                                                ),
                                                // Visibility(
                                                //   visible:
                                                //       selectedStatus == 'CASH',
                                                //   child: Padding(
                                                //     padding: EdgeInsets.only(
                                                //         left: MediaQuery.of(
                                                //                     context)
                                                //                 .size
                                                //                 .width *
                                                //             0.01,
                                                //         top: MediaQuery.of(
                                                //                     context)
                                                //                 .size
                                                //                 .width *
                                                //             0.003),
                                                //     child: SizedBox(
                                                //       width:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .width *
                                                //               0.05,
                                                //       child: const Text(
                                                //         'Cash',
                                                //         style: TextStyle(
                                                //             color: Colors.black,
                                                //             fontWeight:
                                                //                 FontWeight
                                                //                     .bold),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                // Visibility(
                                                //   visible:
                                                //       selectedStatus == 'Cash',
                                                //   child: Flexible(
                                                //     child: Container(
                                                //       width:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .width *
                                                //               0.07,
                                                //       height: 30,
                                                //       decoration: BoxDecoration(
                                                //         border: Border.all(
                                                //             color:
                                                //                 Colors.black),
                                                //         borderRadius:
                                                //             BorderRadius
                                                //                 .circular(0),
                                                //       ),
                                                //       child: Padding(
                                                //         padding:
                                                //             const EdgeInsets
                                                //                 .all(0.0),
                                                //         child: TextFormField(
                                                //           controller:
                                                //               salesEntryFormController
                                                //                   .cashAmountController,
                                                //           onSaved: (newValue) {
                                                //             salesEntryFormController
                                                //                 .cashAmountController
                                                //                 .text = newValue!;
                                                //           },
                                                //           decoration:
                                                //               const InputDecoration(
                                                //             border: InputBorder
                                                //                 .none,
                                                //           ),
                                                //           textAlign:
                                                //               TextAlign.start,
                                                //           style:
                                                //               const TextStyle(
                                                //                   fontWeight:
                                                //                       FontWeight
                                                //                           .bold,
                                                //                   color: Colors
                                                //                       .black),
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),

                                                const Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SEFormButton(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    height: 30,
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            content: SizedBox(
                                                              width: 700,
                                                              height: 350,
                                                              child: Scaffold(
                                                                appBar: AppBar(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFF4169E1),
                                                                  automaticallyImplyLeading:
                                                                      false,
                                                                  centerTitle:
                                                                      true,
                                                                  title: Text(
                                                                    'More Details',
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                body: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text(
                                                                              '1. ADVANCE PAYMENT',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 109, 17, 189)),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 400,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Colors.black),
                                                                                borderRadius: BorderRadius.circular(0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                                                                child: TextFormField(
                                                                                  controller: _advpaymentController,
                                                                                  onSaved: (newValue) {
                                                                                    _advpaymentController.text = newValue!;
                                                                                  },
                                                                                  style: const TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 17,
                                                                                    height: 1,
                                                                                  ),
                                                                                  decoration: const InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text(
                                                                              '2. ADVANCE PAYMENT DATE',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 109, 17, 189)),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 400,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Colors.black),
                                                                                borderRadius: BorderRadius.circular(0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                                                                child: TextFormField(
                                                                                  controller: _advpaymentdateController,
                                                                                  onSaved: (newValue) {
                                                                                    _advpaymentdateController.text = newValue!;
                                                                                  },
                                                                                  style: const TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 17,
                                                                                    height: 1,
                                                                                  ),
                                                                                  decoration: const InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text(
                                                                              '3. INSTALLMENT',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 109, 17, 189)),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 400,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Colors.black),
                                                                                borderRadius: BorderRadius.circular(0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                                                                child: TextFormField(
                                                                                  controller: _installmentController,
                                                                                  onSaved: (newValue) {
                                                                                    _installmentController.text = newValue!;
                                                                                  },
                                                                                  style: const TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 17,
                                                                                    height: 1,
                                                                                  ),
                                                                                  decoration: const InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text(
                                                                              '4. TOTAL DEBIT AMOUNT',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 109, 17, 189)),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 400,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Colors.black),
                                                                                borderRadius: BorderRadius.circular(0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                                                                child: TextFormField(
                                                                                  controller: _toteldebitamountController,
                                                                                  onSaved: (newValue) {
                                                                                    _toteldebitamountController.text = newValue!;
                                                                                  },
                                                                                  style: const TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 17,
                                                                                    height: 1,
                                                                                  ),
                                                                                  decoration: const InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            50),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SEFormButton(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.1,
                                                                          height:
                                                                              30,
                                                                          onPressed:
                                                                              saveMoreDetailsValues,
                                                                          buttonText:
                                                                              'Save',
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        SEFormButton(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.1,
                                                                          height:
                                                                              30,
                                                                          onPressed:
                                                                              () {
                                                                            moreDetails.clear();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          buttonText:
                                                                              'Cancel',
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    buttonText: 'More Details',
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const NotaTable(),
                                        SizedBox(
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: _newWidget,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            NotaTableFooter(
                                              qty: Tqty,
                                              amount: Tamount,
                                              sgst: Tsgst,
                                              cgst: Tcgst,
                                              igst: Tigst,
                                              netAmount: TnetAmount,
                                              discount: Tdiscount,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
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
                                                                child:
                                                                    const Text(
                                                                  'Remarks',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          20,
                                                                          88,
                                                                          181)),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.67,
                                                                  height: 30,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0,
                                                                        bottom:
                                                                            16.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          salesEntryFormController
                                                                              .remarkController,
                                                                      onSaved:
                                                                          (newValue) {
                                                                        salesEntryFormController
                                                                            .remarkController!
                                                                            .text = newValue!;
                                                                      },
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            17,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
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
                                                                  border: Border
                                                                      .all(
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
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.4,
                                                                      height:
                                                                          30,
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
                                                                          const Center(
                                                                        child:
                                                                            Text(
                                                                          'Ledger Information',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                14,
                                                                                63,
                                                                                138),
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                17,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.3,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.3,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              border: Border(
                                                                                bottom: BorderSide(
                                                                                  color: Color.fromARGB(255, 44, 43, 43),
                                                                                  width: 2,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.5,
                                                                              height: 30,
                                                                              child: Row(
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
                                                                  builder:
                                                                      (context,
                                                                          itemID,
                                                                          _) {
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
                                                                        Border
                                                                            .all(
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
                                                                            flex:
                                                                                4,
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                              height: 30,
                                                                              child: ElevatedButton(
                                                                                onPressed: () {},
                                                                                style: ElevatedButton.styleFrom(
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(0),
                                                                                  ),
                                                                                  backgroundColor: const Color.fromARGB(
                                                                                    255,
                                                                                    255,
                                                                                    243,
                                                                                    132,
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  'Statements',
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                  softWrap: false,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Expanded(
                                                                            flex:
                                                                                6,
                                                                            child:
                                                                                Text(
                                                                              'Recent Transaction for the item',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color.fromARGB(255, 20, 88, 181),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                              height: 30,
                                                                              child: ElevatedButton(
                                                                                onPressed: () {},
                                                                                style: ElevatedButton.styleFrom(
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(0),
                                                                                  ),
                                                                                  backgroundColor: const Color.fromARGB(255, 255, 243, 132),
                                                                                ),
                                                                                child: const Text(
                                                                                  'Purchase',
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),

                                                                      // Table Starts Here
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.black),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          children:
                                                                              List.generate(
                                                                            headerTitles.length,
                                                                            (index) =>
                                                                                Expanded(
                                                                              child: Text(
                                                                                headerTitles[index],
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 13,
                                                                                  color: Color.fromARGB(255, 14, 63, 138),
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
                                                                            border:
                                                                                TableBorder.all(width: 1.0, color: Colors.black),
                                                                            children: [
                                                                              // Iterate over all purchases' entries
                                                                              for (int i = 0; i < suggestionItems6.length; i++)
                                                                                ...suggestionItems6[i].entries.where((entry) => entry.itemName == itemID.itemID).map((entry) {
                                                                                  // Find the corresponding ledger for the current entry
                                                                                  String ledgerName = '';
                                                                                  if (suggestionItems5.isNotEmpty) {
                                                                                    final ledger = suggestionItems5.firstWhere(
                                                                                      (ledger) => ledger.id == suggestionItems6[i].party,
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
                                                                                        suggestionItems6[i].date.toString(),
                                                                                        textAlign: TextAlign.center,
                                                                                      ),
                                                                                      Text(
                                                                                        suggestionItems6[i].dcNo.toString(),
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
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.22,
                                                height: 210,
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
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: Row(
                                                        children: List.generate(
                                                          header2Titles.length,
                                                          (index) => Expanded(
                                                            child: Text(
                                                              header2Titles[
                                                                  index],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                                color: Color
                                                                    .fromARGB(
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
                                                    SizedBox(
                                                      height: 120,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: _newSundry,
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 18.0,
                                                              bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            child: InkWell(
                                                              onTap:
                                                                  calculateSundry,
                                                              child: const Text(
                                                                'Save All',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15,
                                                                ),
                                                                softWrap: false,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 100,
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            child: InkWell(
                                                              onTap: () {
                                                                final entryId =
                                                                    UniqueKey()
                                                                        .toString();

                                                                setState(() {
                                                                  _newSundry
                                                                      .add(
                                                                    SundryRow(
                                                                        key: ValueKey(
                                                                            entryId),
                                                                        serialNumber:
                                                                            _currentSerialNumberSundry,
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
                                                                        onDelete:
                                                                            (String
                                                                                entryId) {
                                                                          setState(
                                                                              () {
                                                                            _newSundry.removeWhere((widget) =>
                                                                                widget.key ==
                                                                                ValueKey(entryId));

                                                                            Map<String, dynamic>?
                                                                                entryToRemove;
                                                                            for (final entry
                                                                                in _allValuesSundry) {
                                                                              if (entry['uniqueKey'] == entryId) {
                                                                                entryToRemove = entry;
                                                                                break;
                                                                              }
                                                                            }

                                                                            // Remove the map from _allValues if found
                                                                            if (entryToRemove !=
                                                                                null) {
                                                                              _allValuesSundry.remove(entryToRemove);
                                                                            }
                                                                            calculateSundry();
                                                                          });
                                                                        }),
                                                                  );
                                                                  _currentSerialNumberSundry++;
                                                                });
                                                              },
                                                              child: const Text(
                                                                'Add',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15,
                                                                ),
                                                                softWrap: false,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          children: [
                                            SEFormButton(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14,
                                              height: 30,
                                              onPressed: () {
                                                if (selectedLedgerName!
                                                    .isEmpty) {
                                                  // Show dialog for selecting ledger
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Error!',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        content: Text(
                                                          'Please select a ledger!',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (_allValues.isEmpty) {
                                                  // Show dialog for adding an item
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Error!',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        content: Text(
                                                          'Please add an item!',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (selectedStatus ==
                                                    'MULTI MODE') {
                                                  // Show the multi-mode details dialog
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        content: SizedBox(
                                                          width: 700,
                                                          height: 700,
                                                          child: PoPUP(
                                                            multimodeDetails:
                                                                multimodeDetails,
                                                            onSaveData:
                                                                createSalesEntry,
                                                            totalAmount:
                                                                TnetAmount +
                                                                    Ttotal,
                                                            listWidget:
                                                                Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    _allValues
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  Map<String,
                                                                          dynamic>
                                                                      e =
                                                                      _allValues[
                                                                          index];
                                                                  return Row(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            145,
                                                                        height:
                                                                            30,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.red),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.0),
                                                                          child:
                                                                              Text(
                                                                            itemsList.firstWhere((item) => item.id == e['itemName']).itemName,
                                                                            style:
                                                                                const TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            145,
                                                                        height:
                                                                            30,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.red),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.0),
                                                                          child:
                                                                              Text(
                                                                            '${e['netAmount']}',
                                                                            style:
                                                                                const TextStyle(fontSize: 18),
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // Proceed with creating sales entry
                                                  createSalesEntry();
                                                }
                                              },
                                              buttonText: 'Save [F4]',
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.002),
                                        Column(
                                          children: [
                                            SEFormButton(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14,
                                              height: 30,
                                              onPressed: () {
                                                openDialog(context);
                                              },
                                              buttonText: 'Dispatch',
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.002),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.002,
                                        ),
                                        Column(
                                          children: [
                                            SEFormButton(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14,
                                              height: 30,
                                              onPressed: () {},
                                              buttonText: 'Delete',
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                                    width:
                                                        MediaQuery.of(context)
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '- ${roundOff.toStringAsFixed(2)}',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    child: const Text(
                                                      'Net Amount: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '$roundedValue',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
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
                                      builder: (context) => const SalesHome(),
                                    ),
                                  );
                                  return KeyEventResult.handled;
                                } else if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.keyB) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BarcodePrintD(),
                                    ),
                                  );
                                } else if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.keyM) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NIMyDesktopBody(),
                                    ),
                                  );
                                } else if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.keyL) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LGMyDesktopBody(),
                                    ),
                                  );
                                } else if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.keyA) {
                                  final entryId = UniqueKey().toString();
                                  setState(() {
                                    _newWidget.add(SEntries(
                                      key: ValueKey(entryId),
                                      serialNumber: _currentSerialNumber,
                                      itemNameControllerP:
                                          salesEntryFormController
                                              .itemNameController,
                                      qtyControllerP: salesEntryFormController
                                          .qtyController,
                                      rateControllerP: salesEntryFormController
                                          .rateController,
                                      unitControllerP: salesEntryFormController
                                          .unitController,
                                      amountControllerP:
                                          salesEntryFormController
                                              .amountController,
                                      taxControllerP: salesEntryFormController
                                          .taxController,
                                      discountControllerP:
                                          salesEntryFormController
                                              .discountController,
                                      sgstControllerP: salesEntryFormController
                                          .sgstController,
                                      cgstControllerP: salesEntryFormController
                                          .cgstController,
                                      igstControllerP: salesEntryFormController
                                          .igstController,
                                      netAmountControllerP:
                                          salesEntryFormController
                                              .netAmountController,
                                      selectedLegerId: selectedLedgerName!,
                                      onSaveValues: saveValues,
                                      onDelete: (String entryId) {
                                        setState(() {
                                          _newWidget.removeWhere((widget) =>
                                              widget.key == ValueKey(entryId));
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
                                        });
                                      },
                                      entryId: entryId,
                                      itemsList: itemsList,
                                      measurement: measurement,
                                      taxLists: taxLists,
                                      pricecategory: pricecategory,
                                    ));
                                    _currentSerialNumber++;
                                  });
                                }
                                return KeyEventResult.ignored;
                              },
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.099,
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
                                                const SalesHome(),
                                          ),
                                        );
                                      },
                                    ),
                                    CustomList(
                                      Skey: "F2",
                                      name: "New",
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SEMyDesktopBody(),
                                          ),
                                        );
                                      },
                                    ),
                                    CustomList(
                                        Skey: "P", name: "Print", onTap: () {}),
                                    CustomList(
                                      Skey: "A",
                                      name: "Add",
                                      onTap: () {
                                        final entryId = UniqueKey().toString();
                                        setState(() {
                                          _newWidget.add(SEntries(
                                            key: ValueKey(entryId),
                                            serialNumber: _currentSerialNumber,
                                            itemNameControllerP:
                                                salesEntryFormController
                                                    .itemNameController,
                                            qtyControllerP:
                                                salesEntryFormController
                                                    .qtyController,
                                            rateControllerP:
                                                salesEntryFormController
                                                    .rateController,
                                            unitControllerP:
                                                salesEntryFormController
                                                    .unitController,
                                            amountControllerP:
                                                salesEntryFormController
                                                    .amountController,
                                            taxControllerP:
                                                salesEntryFormController
                                                    .taxController,
                                            discountControllerP:
                                                salesEntryFormController
                                                    .discountController,
                                            sgstControllerP:
                                                salesEntryFormController
                                                    .sgstController,
                                            cgstControllerP:
                                                salesEntryFormController
                                                    .cgstController,
                                            igstControllerP:
                                                salesEntryFormController
                                                    .igstController,
                                            netAmountControllerP:
                                                salesEntryFormController
                                                    .netAmountController,
                                            selectedLegerId:
                                                selectedLedgerName!,
                                            onSaveValues: saveValues,
                                            onDelete: (String entryId) {
                                              setState(() {
                                                _newWidget.removeWhere(
                                                    (widget) =>
                                                        widget.key ==
                                                        ValueKey(entryId));
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
                                                if (entryToRemove != null) {
                                                  _allValues
                                                      .remove(entryToRemove);
                                                }
                                                calculateTotal();
                                              });
                                            },
                                            entryId: entryId,
                                            itemsList: itemsList,
                                            measurement: measurement,
                                            taxLists: taxLists,
                                            pricecategory: pricecategory,
                                          ));
                                          _currentSerialNumber++;
                                        });
                                      },
                                    ),
                                    CustomList(
                                        Skey: "F5",
                                        name: "Change Type",
                                        onTap: () {}),
                                    CustomList(
                                        Skey: "", name: "", onTap: () {}),
                                    CustomList(
                                        Skey: "B",
                                        name: "Prn Barcode",
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarcodePrintD(),
                                            ),
                                          );
                                        }),
                                    CustomList(
                                      Skey: "",
                                      name: "",
                                      onTap: () {},
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
                                        Skey: "PgDn",
                                        name: "Next",
                                        onTap: () {}),
                                    CustomList(
                                        Skey: "", name: "", onTap: () {}),
                                    CustomList(
                                        Skey: "G",
                                        name: "Attach. Img",
                                        onTap: () {}),
                                    CustomList(
                                        Skey: "", name: "", onTap: () {}),
                                    CustomList(
                                        Skey: "G",
                                        name: "Vch Setup",
                                        onTap: () {}),
                                    CustomList(
                                        Skey: "T",
                                        name: "Print Setup",
                                        onTap: () {}),
                                    CustomList(
                                        Skey: "", name: "", onTap: () {}),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_isSaving)
                            Center(
                              child: Lottie.asset('lottie/loading.json'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DispatchDetailsDialog(
        dispacthDetails: dispacthDetails,
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
        salesEntryFormController.dateController1.text =
            formatter.format(pickedDate);
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
        salesEntryFormController.dateController2.text =
            formatter.format(pickedDate);
      });
    }
  }
}
