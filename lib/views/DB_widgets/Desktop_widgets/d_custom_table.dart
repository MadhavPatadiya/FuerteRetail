import 'package:billingsphere/data/models/purchase/purchase_model.dart';
import 'package:billingsphere/data/repository/purchase_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/ledger/ledger_model.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/models/salesEntries/sales_entrires_model.dart';
import '../../../data/repository/ledger_repository.dart';
import '../../../data/repository/payment_respository.dart';
import '../../../data/repository/sales_enteries_repository.dart';

class DTable extends StatefulWidget {
  const DTable({super.key});

  @override
  State<DTable> createState() => _DTableState();
}

class _DTableState extends State<DTable> {
//Services
  SalesEntryService salesService = SalesEntryService();
  PurchaseServices purchaseService = PurchaseServices();
  PaymentService paymentService = PaymentService();
  LedgerService ledgerService = LedgerService();

//Fetch Data
  List<SalesEntry> suggestionSales = [];
  List<SalesEntry> suggestionSalesCash = [];
  List<Purchase> suggestionPurchase = [];
  List<Payment> suggestionPayment = [];
  List<Ledger> suggestionLedger = [];
  List<Ledger> suggestionLedgerCustomer = [];

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

//----------------------------------FETCH SALES START-------------------------------//

  Future<void> fetchSales() async {
    try {
      final List<SalesEntry> sales = await salesService.fetchSalesEntries();
      final filteredSalesEntry = sales
          .where((salesentry) => salesentry.companyCode == companyCode!.first)
          .toList();
      final filteredSalesCashEntry = sales
          .where((salesentry) =>
              salesentry.companyCode == companyCode!.first &&
              salesentry.type == 'CASH')
          .toList();
      setState(() {
        suggestionSales = filteredSalesEntry;
        suggestionSalesCash = filteredSalesCashEntry;
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

//fetch sales by date
  double calculateSalesByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionSales) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  //fetch sales by month
  double calculateSalesByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionSales) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  // Fetch sales by total amount
  double calculateSalesTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionSales) {
      totalAmount += double.parse(entry.totalamount);
    }
    return totalAmount;
  }

//----------------------------------FETCH SALES CASH START------------------------//
  double calculateSalesCashByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionSalesCash) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  //fetch sales cash by month
  double calculateSalesCashByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionSalesCash) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  // Fetch sales cash by total amount
  double calculateSalesCashTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionSalesCash) {
      totalAmount += double.parse(entry.totalamount);
    }
    return totalAmount;
  }

//----------------------------------FETCH SALES CASH END--------------------------//

//----------------------------------FETCH SALES END-------------------------------//

//----------------------------------FETCH PURCHASE START--------------------------//
  Future<void> fetchPurchase() async {
    try {
      final List<Purchase> purchase = await purchaseService.getPurchase();
      final filteredPurchaseEntry = purchase
          .where(
              (purchasentry) => purchasentry.companyCode == companyCode!.first)
          .toList();
      setState(() {
        suggestionPurchase = filteredPurchaseEntry;
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

  double calculatePurchaseByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionPurchase) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  double calculatePurchaseTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionPurchase) {
      totalAmount += double.parse(entry.totalamount);
    }
    return totalAmount;
  }

  double calculatePurchaseByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionPurchase) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += double.parse(entry.totalamount);
      }
    }

    return totalAmount;
  }

  //----------------------------------FETCH PURCHASE END-------------------------------//
  //----------------------------------FETCH PAYMENT START------------------------------//

  Future<void> fetchPayment() async {
    try {
      final List<Payment> payment = await paymentService.fetchPayments();
      final filteredPaymentEntry = payment
          .where(
              (purchasentry) => purchasentry.companyCode == companyCode!.first)
          .toList();
      setState(() {
        suggestionPayment = filteredPaymentEntry;
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

  double calculatePaymentByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionPayment) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += entry.totalamount;
      }
    }

    return totalAmount;
  }

  double calculatePaymentByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionPayment) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += entry.totalamount;
      }
    }

    return totalAmount;
  }

  double calculatePaymentTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionPayment) {
      totalAmount += entry.totalamount;
    }
    return totalAmount;
  }

  //----------------------------------FETCH PAYMENT END-------------------------------//
  //----------------------------------FETCH Ledger VENDOR START-----------------------//
  Future<void> fetchLedger() async {
    try {
      final List<Ledger> ledger = await ledgerService.fetchLedgers();
      print(ledger);
      final filteredLedgerEntry = ledger
          .where((ledgerentry) =>
              ledgerentry.ledgerGroup == '662f97d2a07ec73369c237b0')
          .toList();
      final filteredLedgerCustomerEntry = ledger
          .where((ledgerentry) =>
              ledgerentry.ledgerGroup == '662f984ba07ec73369c237c8')
          .toList();
      setState(() {
        suggestionLedger = filteredLedgerEntry;
        suggestionLedgerCustomer = filteredLedgerCustomerEntry;
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

  //fetch vendor balance by date
  double calculateVendorByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionLedger) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
      }
    }

    return totalAmount;
  }

  //fetch by month
  double calculateVendorByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionLedger) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
      }
    }

    return totalAmount;
  }

  // Fetch sales by total amount
  double calculateVendorTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionLedger) {
      totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
    }
    return totalAmount;
  }

  //----------------------------------FETCH Ledger Customer START-----------------------------//
  //fetch vendor balance by date
  double calculateCustomerByDate() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int todayDay = today.day;
    int todayMonth = today.month;
    int todayYear = today.year;
    // print('Today\'s Date: $todayMonth/$todayDay/$todayYear');
    for (var entry in suggestionLedgerCustomer) {
      // Parse entry date string into its components
      List<String> entryDateComponents = entry.date.split('/');
      int entryDay = int.parse(entryDateComponents[1]); // Adjusted index
      int entryMonth = int.parse(entryDateComponents[0]); // Adjusted index
      int entryYear = int.parse(entryDateComponents[2]);
      // print('Entry Date: $entryMonth/$entryDay/$entryYear');
      if (entryDay == todayDay &&
          entryMonth == todayMonth &&
          entryYear == todayYear) {
        totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
      }
    }

    return totalAmount;
  }

  //fetch by month
  double calculateCustomerByMonth() {
    double totalAmount = 0;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    for (var entry in suggestionLedgerCustomer) {
      List<String> entryDateComponents = entry.date.split('/');
      int entryMonth = int.parse(entryDateComponents[0]);
      int entryYear = int.parse(entryDateComponents[2]);
      if (entryMonth == currentMonth && entryYear == currentYear) {
        totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
      }
    }

    return totalAmount;
  }

  // Fetch ledger customer by total amount
  double calculateCustomerTotalAmount() {
    double totalAmount = 0;
    for (var entry in suggestionLedgerCustomer) {
      totalAmount += double.parse(entry.openingBalance.toStringAsFixed(2));
    }
    return totalAmount;
  }

  //----------------------------------FETCH Ledger Customer END-------------------------------//
  //----------------------------------FETCH Ledger VENDOR END---------------------------------//

  void _initializeData() async {
    await setCompanyCode();
    await fetchSales();
    await fetchPurchase();
    await fetchPayment();
    await fetchLedger();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.all(0.0),
          child: Container(
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DASH BOARD (${DateFormat('MM/dd/yyyy').format(DateTime.now())})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchSales();
                    fetchPurchase();
                    fetchPayment();
                    fetchLedger();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 253, 253, 253),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(),
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'Description ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 5, 5, 112),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          DateFormat('d-MMM').format(DateTime.now()),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 5, 5, 112),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          DateFormat('MMM-yy').format(DateTime.now()),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 5, 5, 112),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '24-25 (Lacs)',
                          style: TextStyle(
                            color: Color.fromARGB(255, 5, 5, 112),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                // for (String item in items)
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'SALES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'PURCHASE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePurchaseByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePurchaseByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePurchaseTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'RECEIPT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'PAYMENT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePaymentByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePaymentByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculatePaymentTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'EXPENSE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),

                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'CASH BALANCE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesCashByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesCashByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateSalesCashTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),

                const TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'STOCK VALUE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'CUSTOMER BALANCE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateCustomerByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateCustomerByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateCustomerTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'VENDOR BALANCE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateVendorByDate().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateVendorByMonth().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          calculateVendorTotalAmount().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Table Contents
      ],
    );
  }
}
