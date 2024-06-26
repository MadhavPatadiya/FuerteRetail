import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import 'package:billingsphere/data/models/salesEntries/sales_entrires_model.dart';
import 'package:billingsphere/data/repository/sales_enteries_repository.dart';
import 'package:billingsphere/views/SE_responsive/SE_receipt_2.dart';
import 'package:billingsphere/views/SE_responsive/SalesEditScreen.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/user/user_group_model.dart';
import '../../data/repository/ledger_repository.dart';

import 'dart:html' as html;

import '../../data/repository/user_group_repository.dart';

class SalesHome extends StatefulWidget {
  const SalesHome({super.key});

  @override
  State<SalesHome> createState() => _SalesHomeState();
}

class _SalesHomeState extends State<SalesHome> {
  List<SalesEntry> fetchedSales = [];
  LedgerService ledgerService = LedgerService();
  late SharedPreferences _prefs;

  String? selectedId;
  bool isLoading = false;
  String? userGroup = '';
  UserGroupServices userGroupServices = UserGroupServices();
  List<UserGroup> userGroupM = [];

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SalesEntryService salesEntryService = SalesEntryService();

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

  Future<void> fetchAllSales() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<SalesEntry> sales = await salesEntryService.getSales();
      // final filteredSalesEntry = sales
      //     .where((salesentry) => salesentry.companyCode == companyCode?[0])
      //     .toList();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        if (sales.isNotEmpty) {
          fetchedSales = sales;
          selectedId = fetchedSales[0].id;
        } else {
          fetchedSales = sales;
        }
        isLoading = false;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> exportToExcel() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch ledger data for each sales entry
      List<Ledger?> ledgerList = [];
      for (var salesEntry in fetchedSales) {
        Ledger? ledger = await ledgerService.fetchLedgerById(salesEntry.party);
        ledgerList.add(ledger);
      }

      // Create an Excel document.
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Add heading row.
      sheet.getRangeByName('A1').setText('Sr');
      sheet.getRangeByName('B1').setText('Date');
      sheet.getRangeByName('C1').setText('Bill No');
      sheet.getRangeByName('D1').setText('Type');
      sheet.getRangeByName('E1').setText('Ledger Name');

      // Format the heading row.
      final xlsio.Style headingStyle = workbook.styles.add('HeadingStyle');
      headingStyle.bold = true;
      headingStyle.backColor = '#D3D3D3'; // Light grey background color

      for (int i = 1; i <= 5; i++) {
        sheet.getRangeByIndex(1, i).cellStyle = headingStyle;
      }

      // Add data to the sheet.
      for (int i = 0; i < fetchedSales.length; i++) {
        int itemNumber = i + 1; // Fix the item number calculation

        sheet.getRangeByIndex(i + 2, 1).setText(itemNumber.toString());
        sheet.getRangeByIndex(i + 2, 2).setText(fetchedSales[i].date);
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(fetchedSales[i].dcNo.toString());
        sheet
            .getRangeByIndex(i + 2, 4)
            .setText(fetchedSales[i].type.toString());

        // Add ledger name to the sheet
        if (ledgerList[i] != null) {
          sheet.getRangeByIndex(i + 2, 5).setText(ledgerList[i]!.name);
        } else {
          sheet.getRangeByIndex(i + 2, 5).setText('No Data');
        }
      }

      // Save the document as a stream of bytes.
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Convert the bytes to a Uint8List
      final Uint8List uint8List = Uint8List.fromList(bytes);

      // Create a blob from the Uint8List
      final html.Blob blob = html.Blob([uint8List]);
      final formatter = DateFormat('dd-MM-yyyy');
      final formattedDate = formatter.format(DateTime.now());

      // Create a link element
      final html.AnchorElement link = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob),
      )
        ..setAttribute("download", "SalesEntries-$formattedDate.xlsx")
        ..click();

      // Optionally, you can show a message or alert to indicate the file has been saved.
      print('Excel file saved successfully and download triggered.');
    } catch (error) {
      print('Failed to export to Excel: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserGroup() async {
    final List<UserGroup> userGroupFetch =
        await userGroupServices.getUserGroups();

    setState(() {
      userGroupM = userGroupFetch;
    });
  }

  Future<void> initialize() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      _initPrefs().then((value) => {
            userGroup = _prefs.getString('usergroup'),
          }),
      fetchUserGroup().then((value) => {}),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllSales();
    setCompanyCode();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SALES LIST',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 132, 232, 132),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isLoading) {
                          exportToExcel();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download, size: 24),
                          SizedBox(width: 8),
                          Text('Export to Excel'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(4),
                      5: FlexColumnWidth(4),
                    },
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              "Sr",
                              style: GoogleFonts.poppins(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "Date",
                              style: GoogleFonts.poppins(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "Bill No",
                              style: GoogleFonts.poppins(
                                color: Colors.pinkAccent,
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
                                color: Colors.pinkAccent,
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
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "Action",
                              style: GoogleFonts.poppins(
                                color: Colors.pinkAccent,
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
                  Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 750,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: fetchedSales.length,
                          itemBuilder: (context, index) {
                            int itemNumber = index + 1;
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              elevation: 1,
                              child: ListTile(
                                title: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.04,
                                      child: Text(
                                        itemNumber.toString(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.145,
                                      child: Text(
                                        fetchedSales[index].date,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.135,
                                      child: Text(
                                        fetchedSales[index].dcNo,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.135,
                                      child: Text(
                                        fetchedSales[index].type,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.265,
                                      child: FutureBuilder<Ledger?>(
                                        future: ledgerService.fetchLedgerById(
                                            fetchedSales[index].party),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Ledger?> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('');
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            // If the future completes successfully
                                            if (snapshot.hasData &&
                                                snapshot.data != null) {
                                              return Text(
                                                ' ${snapshot.data!.name}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              );
                                            } else {
                                              return const Text('No Data');
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        return SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.16,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Visibility(
                                                visible:
                                                    (userGroup == "Admin" ||
                                                        userGroup == "Owner"),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.green,
                                                    size: 15,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SalesEditScreen(
                                                          salesEntryId:
                                                              fetchedSales[
                                                                      index]
                                                                  .id,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const Spacer(),
                                              Visibility(
                                                visible:
                                                    (userGroup == "Admin" ||
                                                        userGroup == "Owner"),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.pinkAccent,
                                                    size: 15,
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Delete Sales'),
                                                          content: const Text(
                                                              'Are you sure you want to delete this sales?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'No'),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await salesEntryService
                                                                    .deleteSalesEntry(
                                                                        fetchedSales[index]
                                                                            .id);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                setState(() {
                                                                  fetchedSales
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pushReplacement(MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const SalesHome()));
                                                              },
                                                              child: const Text(
                                                                  'Yes'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.print,
                                                    size: 15,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PrintBigReceipt(
                                                        'Print Sales',
                                                        sales:
                                                            fetchedSales[index]
                                                                .id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          height: 750,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 132, 232, 132),
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
    );
  }
}
