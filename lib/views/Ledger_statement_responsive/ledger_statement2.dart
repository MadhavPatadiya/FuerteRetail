import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/purchase/purchase_model.dart';
import '../../data/models/salesEntries/sales_entrires_model.dart';
import '../../data/repository/purchase_repository.dart';
import '../../data/repository/sales_enteries_repository.dart';
import '../sumit_screen/voucher _entry.dart/voucher_list_widget.dart';

class LedgerShow extends StatefulWidget {
  final Ledger selectedLedger;
  final DateTime? startDate;
  final DateTime? endDate;

  const LedgerShow(
      {super.key, required this.selectedLedger, this.startDate, this.endDate});

  @override
  State<LedgerShow> createState() => _LedgerShowState();
}

class _LedgerShowState extends State<LedgerShow> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  // Fetch Purchase
  List<Purchase> suggestionPurchase = [];
  String? selectedPurchase;
  PurchaseServices purchaseService = PurchaseServices();

  // Fetch Sales
  List<SalesEntry> suggestionSales = [];
  String? selectedSales;
  SalesEntryService salesService = SalesEntryService();

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

  List<dynamic> combinedData = [];

  double totalAmountSumSales = 0.00;
  double totalAmountSumPurchase = 0.00;

  Future<void> fetchSalesAndPurchase() async {
    try {
      final List<SalesEntry> sales = await salesService.fetchSalesEntries();
      final List<Purchase> purchase = await purchaseService.getPurchase();

      final filteredSalesEntry = sales
          .where((salesentry) =>
              salesentry.companyCode == companyCode!.first &&
              salesentry.party == widget.selectedLedger.id &&
              (DateFormat('M/d/y')
                      .parse(salesentry.date)
                      .isAfter(widget.startDate!) ||
                  DateFormat('M/d/y').parse(salesentry.date) ==
                      widget.startDate!) &&
              (DateFormat('M/d/y')
                      .parse(salesentry.date)
                      .isBefore(widget.endDate!) ||
                  DateFormat('M/d/y').parse(salesentry.date) ==
                      widget.endDate!))
          .toList();
      double totalAmountSumSales = filteredSalesEntry.fold(
          0, (sum, item) => sum + double.parse(item.totalamount));

      final filteredPurchase = purchase
          .where((purchaseentry) =>
              purchaseentry.companyCode == companyCode!.first &&
              purchaseentry.ledger == widget.selectedLedger.id &&
              (DateFormat('M/d/y')
                      .parse(purchaseentry.date)
                      .isAfter(widget.startDate!) ||
                  DateFormat('M/d/y').parse(purchaseentry.date) ==
                      widget.startDate!) &&
              (DateFormat('M/d/y')
                      .parse(purchaseentry.date)
                      .isBefore(widget.endDate!) ||
                  DateFormat('M/d/y').parse(purchaseentry.date) ==
                      widget.endDate!))
          .toList();
      double totalAmountSumPurchase = filteredPurchase.fold(
          0, (sum, item) => sum + double.parse(item.totalamount));

      combinedData = [...filteredSalesEntry, ...filteredPurchase];
      combinedData.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        suggestionSales = filteredSalesEntry;
        suggestionPurchase = filteredPurchase;
        this.totalAmountSumSales = totalAmountSumSales;
        this.totalAmountSumPurchase = totalAmountSumPurchase;
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

  Future<void> _initliazeData() async {
    await setCompanyCode();
    await fetchSalesAndPurchase();
  }

  @override
  void initState() {
    super.initState();
    _initliazeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ledger Statement',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 33, 65, 243),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ledger: ${widget.selectedLedger.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          widget.startDate != null
                              ? dateFormat.format(widget.startDate!)
                              : 'Not selected',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                        const Text(
                          ' to',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                        Text(
                          ' ${widget.endDate != null ? dateFormat.format(widget.endDate!) : 'Not selected'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 550,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        children: [
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(4),
                              2: FlexColumnWidth(4),
                              3: FlexColumnWidth(4),
                              4: FlexColumnWidth(4),
                              5: FlexColumnWidth(4),
                              6: FlexColumnWidth(4),
                            },
                            border: TableBorder.all(color: Colors.black),
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Text(
                                      "Date",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "Particulars",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "Type",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "No/Ref",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "Debit",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "Credit",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      "Balance",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 500,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemCount: combinedData.length,
                              itemBuilder: (BuildContext context, int index) {
                                dynamic item = combinedData[index];

                                if (item is SalesEntry) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.0675,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            item.date,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1355,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            'Sales Entry',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1355,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(item.type,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.135,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(item.dcNo,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.135,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text('0.00',
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.135,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                              double.parse(item.totalamount)
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.134,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                              double.parse(item.totalamount)
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (item is Purchase) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.068,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(item.date,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1359,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text('Purchase Entry'),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1359,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(item.type,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.136,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(item.billNumber,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.135,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                              double.parse(item.totalamount)
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1359,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text('0.00',
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1355,
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                              double.parse(item.totalamount)
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return const SizedBox(); // Return an empty widget if the item is neither SalesEntry nor Purchase
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.0675,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                'Total (${combinedData.length})',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1355,
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                '',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1355,
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text('', textAlign: TextAlign.center),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.135,
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text('', textAlign: TextAlign.center),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.135,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  totalAmountSumPurchase.toStringAsFixed(2),
                                  textAlign: TextAlign.right),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.135,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  totalAmountSumSales.toStringAsFixed(2),
                                  textAlign: TextAlign.right),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1355,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  (totalAmountSumPurchase - totalAmountSumSales)
                                      .toStringAsFixed(2),
                                  textAlign: TextAlign.right),
                            ),
                          ),
                        ],
                      ),
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
                      CustomList(Skey: "F2", name: "Report", onTap: () {}),
                      CustomList(Skey: "P", name: "Print", onTap: () {}),
                      CustomList(Skey: "V", name: "AdvView", onTap: () {}),
                      CustomList(Skey: "", name: "", onTap: () {}),
                      CustomList(Skey: "X", name: "Export-Excel", onTap: () {}),
                      CustomList(Skey: "Q", name: "Quick Entry", onTap: () {}),
                      CustomList(Skey: "E", name: "Edit Ledger", onTap: () {}),
                      CustomList(Skey: "Z", name: "Prnt Vchers", onTap: () {}),
                      CustomList(Skey: "M", name: "Monthly", onTap: () {}),
                      CustomList(Skey: "D", name: "ConDensed", onTap: () {}),
                      CustomList(Skey: "T", name: "Show Stock", onTap: () {}),
                      CustomList(Skey: "N", name: "Neg. Bal.", onTap: () {}),
                      CustomList(Skey: "D", name: "Del. Vchers", onTap: () {}),
                      CustomList(Skey: "B", name: "Bal. Conf.", onTap: () {}),
                      CustomList(Skey: "", name: "", onTap: () {}),
                      CustomList(Skey: "F3", name: "Find", onTap: () {}),
                      CustomList(Skey: "F3", name: "Find Next", onTap: () {}),
                      CustomList(Skey: "U", name: "Summary", onTap: () {}),
                      CustomList(Skey: "", name: "", onTap: () {}),
                      CustomList(Skey: "M", name: "MultiPrint", onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
