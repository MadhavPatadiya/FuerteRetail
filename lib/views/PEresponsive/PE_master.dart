import 'package:billingsphere/data/models/purchase/purchase_model.dart';
import 'package:billingsphere/data/models/user/user_group_model.dart';
import 'package:billingsphere/data/repository/ledger_repository.dart';
import 'package:billingsphere/data/repository/user_group_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/repository/purchase_repository.dart';
import 'PE_edit_desktop_body.dart';
import 'PE_receipt_print.dart';

class PEMasterBody extends StatefulWidget {
  const PEMasterBody({super.key});

  @override
  State<PEMasterBody> createState() => _PEMasterBodyState();
}

class _PEMasterBodyState extends State<PEMasterBody> {
  late SharedPreferences _prefs;

  PurchaseServices purchaseServices = PurchaseServices();
  LedgerService ledgerService = LedgerService();
  List<Purchase> fetchedPurchase = [];
  String? selectedId;
  bool isLoading = false;
  int? activeIndex;
  String? activeid;
  String? userGroup = '';
  UserGroupServices userGroupServices = UserGroupServices();
  List<UserGroup> userGroupM = [];
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
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

  Future<void> fetchPurchaseEntries() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<Purchase> purchase = await purchaseServices.getPurchase();

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        fetchedPurchase = purchase;
        if (fetchedPurchase.isNotEmpty) {
          selectedId = fetchedPurchase[0].id;
        }
        isLoading = false;
      });
    } catch (error) {
      print('Failed to fetch purchase name: $error');
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

  void _initializeData() async {
    await setCompanyCode();
    await fetchPurchaseEntries();
  }

  void _handleTap(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List of Retail Purchase Vouchers',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 232, 159, 132),
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
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(3),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(4),
                      6: FlexColumnWidth(2),
                      7: FlexColumnWidth(4),
                    },
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      TableRow(
                        children: [
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
                              "No",
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
                              "Amount",
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
                          itemCount: fetchedPurchase.length,
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
                                          0.07,
                                      child: Text(
                                        fetchedPurchase[index].date,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.08,
                                      child: Text(
                                        fetchedPurchase[index].no,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                      child: Text(
                                        fetchedPurchase[index].type,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.16,
                                      child: Text(
                                        fetchedPurchase[index].billNumber,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.11,
                                      child: Text(
                                        fetchedPurchase[index].date2,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: FutureBuilder<Ledger?>(
                                        future: ledgerService.fetchLedgerById(
                                            fetchedPurchase[index].ledger),
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
                                    //    SizedBox(
                                    //   width: MediaQuery.of(context).size.width * 0.05,
                                    //   child: Text(
                                    //     fetchedPurchase[index].remarks,
                                    //     textAlign: TextAlign.center,
                                    //     style: GoogleFonts.poppins(
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.normal,
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      child: Text(
                                        fetchedPurchase[index].totalamount,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
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
                                                CrossAxisAlignment.center,
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
                                                            PurchaseEditD(
                                                          data: fetchedPurchase[
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
                                                              'Delete Purchase'),
                                                          content: const Text(
                                                              'Are you sure you want to delete this purchase?'),
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
                                                              onPressed: () {
                                                                purchaseServices
                                                                    .deletePurchase(
                                                                        fetchedPurchase[index]
                                                                            .id,
                                                                        context)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Navigator.of(context).pop(),
                                                                              setState(() {
                                                                                fetchedPurchase.removeAt(index);
                                                                              })
                                                                            });
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
                                                          PurchasePrintBigReceipt(
                                                        'Purchase Print Receipt',
                                                        purchaseID:
                                                            fetchedPurchase[
                                                                    index]
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
                              color: Color.fromARGB(255, 232, 159, 132),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Expanded(
                  //   child: Table(
                  //     border: TableBorder.all(color: Colors.black),
                  //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  //     children: [
                  //       TableRow(
                  //         decoration: const BoxDecoration(color: Colors.white),
                  //         children: [
                  //           Center(
                  //               child: Text(
                  //             'Date',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'No',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Type',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Bill No',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Date',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Particulars',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Remarks',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Amount',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //           Center(
                  //               child: Text(
                  //             'Action',
                  //             style: GoogleFonts.poppins(
                  //               textStyle: const TextStyle(
                  //                 color: Colors.pinkAccent,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           )),
                  //         ],
                  //       ),
                  //       // Add more TableRows if needed
                  //       TableRow(
                  //         children: [
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: 'Search Here',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Center(
                  //             child: TextField(
                  //               textAlign: TextAlign.center,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: Colors.pinkAccent,
                  //                 hintText: '',
                  //                 hintStyle: GoogleFonts.poppins(
                  //                   textStyle: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       // Add more TableRows if needed
                  //       // Iterate over fetchedPurchase
                  //       for (int i = 0; i < fetchedPurchase.length; i++)
                  //         TableRow(
                  //           children: [
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].date,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].no,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].type,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].billNumber,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].date2,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //               child: FutureBuilder<Ledger?>(
                  //                 future: ledgerService
                  //                     .fetchLedgerById(fetchedPurchase[i].ledger),
                  //                 builder: (BuildContext context,
                  //                     AsyncSnapshot<Ledger?> snapshot) {
                  //                   if (snapshot.connectionState ==
                  //                       ConnectionState.waiting) {
                  //                     return const Text('');
                  //                   } else if (snapshot.hasError) {
                  //                     return Text('Error: ${snapshot.error}');
                  //                   } else {
                  //                     // If the future completes successfully
                  //                     if (snapshot.hasData &&
                  //                         snapshot.data != null) {
                  //                       return Text(
                  //                         ' ${snapshot.data!.name}',
                  //                         style: GoogleFonts.poppins(
                  //                           fontWeight: FontWeight.w500,
                  //                           fontSize: 15,
                  //                         ),
                  //                       );
                  //                     } else {
                  //                       return const Text('No Data');
                  //                     }
                  //                   }
                  //                 },
                  //               ),
                  //             ),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].remarks,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Text(
                  //               fetchedPurchase[i].totalamount,
                  //               style: GoogleFonts.poppins(
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 15,
                  //               ),
                  //             )),
                  //             Center(
                  //                 child: Row(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 IconButton(
                  //                   icon: const Icon(
                  //                     Icons.edit,
                  //                     color: Colors.green,
                  //                     size: 15,
                  //                   ),
                  //                   onPressed: () {},
                  //                 ),
                  //                 IconButton(
                  //                   icon: const Icon(
                  //                     Icons.delete,
                  //                     color: Colors.pinkAccent,
                  //                     size: 15,
                  //                   ),
                  //                   onPressed: () {},
                  //                 ),
                  //                 IconButton(
                  //                   icon: const Icon(Icons.print,
                  //                       size: 15, color: Colors.blue),
                  //                   onPressed: () {},
                  //                 ),
                  //               ],
                  //             )),
                  //           ],
                  //         ),

                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class List1 extends StatelessWidget {
//   final String? name;
//   final String? Skey;
//   final Function onPressed;
//   const List1({Key? key, this.name, this.Skey, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;

//     return Padding(
//       padding: const EdgeInsets.only(top: 5),
//       child: InkWell(
//         splashColor: Colors.grey[350],
//         onTap: onPressed as void Function()?,
//         child: Container(
//           height: 35,
//           width: w * 0.1,
//           decoration: const BoxDecoration(
//             border: Border(
//               top: BorderSide(width: 2, color: Color(0xFF00C853)),
//               right: BorderSide(width: 2, color: Color(0xFF00C853)),
//               left: BorderSide(width: 2, color: Color(0xFF00C853)),
//               bottom: BorderSide(width: 2, color: Color(0xFF00C853)),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     child: Text(
//                       Skey ?? "",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     name ?? " ",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Color(0xFF00C853),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
