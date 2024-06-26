import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/salesPos/sales_pos_model.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/sales_pos_repository.dart';

class PosMaster extends StatefulWidget {
  const PosMaster({super.key});

  @override
  State<PosMaster> createState() => _PosMasterState();
}

class _PosMasterState extends State<PosMaster> {
  SalesPosRepository salesPosRepository = SalesPosRepository();
  LedgerService ledgerService = LedgerService();
  List<SalesPos> fetchedSalesPos = [];

  Future<void> fetchSalesPos() async {
    final fetchedSalesPos = await salesPosRepository.fetchSalesPos();
    setState(() {
      this.fetchedSalesPos = fetchedSalesPos;
    });

    print(fetchedSalesPos.length);
  }

  @override
  initState() {
    super.initState();
    fetchSalesPos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.indigo,
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.45),
                  Text(
                    'POS MASTER LIST',
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
            const SizedBox(height: 20),
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                                color: Colors.indigo,
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
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: fetchedSalesPos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 1,
                        child: ListTile(
                          title: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: Text(
                                  fetchedSalesPos[index].date,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.08,
                                child: Text(
                                  fetchedSalesPos[index].no.toString(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: Text(
                                  fetchedSalesPos[index].type,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.16,
                                child: Text(
                                  fetchedSalesPos[index].accountNo,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.11,
                                child: Text(
                                  fetchedSalesPos[index].date,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: FutureBuilder<Ledger?>(
                                  future: ledgerService.fetchLedgerById(
                                      fetchedSalesPos[index].customer),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Ledger?> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
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
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: Text(
                                  fetchedSalesPos[index].totalAmount.toString(),
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
                                    width: MediaQuery.of(context).size.width *
                                        0.16,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.green,
                                            size: 15,
                                          ),
                                          onPressed: () {},
                                        ),
                                        const Spacer(),
                                        IconButton(
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
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // purchaseServices
                                                        //     .deletePurchase(
                                                        //         fetchedPurchase[
                                                        //                 index]
                                                        //             .id,
                                                        //         context)
                                                        //     .then((value) => {
                                                        //           Navigator.of(
                                                        //                   context)
                                                        //               .pop(),
                                                        //           setState(() {
                                                        //             fetchedPurchase
                                                        //                 .removeAt(
                                                        //                     index);
                                                        //           })
                                                        //         });
                                                      },
                                                      child: const Text('Yes'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.print,
                                              size: 15, color: Colors.blue),
                                          onPressed: () {
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         PurchasePrintBigReceipt(
                                            //       'Purchase Print Receipt',
                                            //       purchaseID:
                                            //           fetchedPurchase[index].id,
                                            //     ),
                                            //   ),
                                            // );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
