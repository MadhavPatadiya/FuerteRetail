import 'package:billingsphere/data/models/payment/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/payment_respository.dart';
import 'payment_receipt2.dart';

class PaymentHome extends StatefulWidget {
  const PaymentHome({super.key});

  @override
  State<PaymentHome> createState() => _PaymentHomeState();
}

class _PaymentHomeState extends State<PaymentHome> {
  List<Payment> fectedPayments = [];
  PaymentService paymentService = PaymentService();
  LedgerService ledgerService = LedgerService();
  String? selectedId;
  bool isLoading = false;
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

  Future<void> fetchPayments() async {
    final List<Payment> payments = await paymentService.fetchPayments();

    setState(() {
      fectedPayments = payments;

      if (fectedPayments.isNotEmpty) {
        selectedId = fectedPayments[0].id;
      }
    });
  }

  Future<void> deletePayment(String id) async {
    try {
      await paymentService.deletePayment(id, context);
      await fetchPayments();
    } catch (error) {
      print('Failed to delete payment: $error');
    }
  }

  void _initializeData() async {
    await setCompanyCode();
    await fetchPayments();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.brown,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'PAYMENT VOUCHER LIST',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.brown,
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
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(4),
                            3: FlexColumnWidth(4),
                            4: FlexColumnWidth(4),
                          },
                          border: TableBorder.all(color: Colors.grey),
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Text(
                                    "Date",
                                    style: GoogleFonts.poppins(
                                      color: Colors.brown,
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
                                      color: Colors.brown,
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
                                      color: Colors.brown,
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
                                      color: Colors.brown,
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
                                      color: Colors.brown,
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
                          itemCount: fectedPayments.length,
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
                                          0.113,
                                      child: Text(
                                        fectedPayments[index].date,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.123,
                                      child: Text(
                                        fectedPayments[index].no.toString(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: FutureBuilder<Ledger?>(
                                        future: ledgerService.fetchLedgerById(
                                            fectedPayments[index]
                                                .entries
                                                .first
                                                .ledger),
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
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: Text(
                                        (fectedPayments[index].totalamount)
                                            .toStringAsFixed(2),
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
                                              0.23,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // IconButton(
                                              //   icon: const Icon(
                                              //     Icons.edit,
                                              //     color: Colors.green,
                                              //     size: 15,
                                              //   ),
                                              //   onPressed: () {
                                              //     // Navigator.of(context).push(
                                              //     //   MaterialPageRoute(
                                              //     //     builder: (context) =>
                                              //     //         SalesEditScreen(
                                              //     //       salesEntryId:
                                              //     //           fetchedReceipt[index]
                                              //     //               .id,
                                              //     //     ),
                                              //     //   ),
                                              //     // );
                                              //   },
                                              // ),
                                              // const Spacer(),
                                              // IconButton(
                                              //   icon: const Icon(
                                              //     Icons.delete,
                                              //     color: Colors.pinkAccent,
                                              //     size: 15,
                                              //   ),
                                              //   onPressed: () {
                                              //     showDialog(
                                              //       context: context,
                                              //       builder: (context) {
                                              //         return AlertDialog(
                                              //           title: const Text(
                                              //               'Delete Sales'),
                                              //           content: const Text(
                                              //               'Are you sure you want to delete this sales?'),
                                              //           actions: [
                                              //             TextButton(
                                              //               onPressed: () {
                                              //                 Navigator.of(
                                              //                         context)
                                              //                     .pop();
                                              //               },
                                              //               child: const Text(
                                              //                   'No'),
                                              //             ),
                                              //             TextButton(
                                              //               onPressed: () {
                                              //                 // salesEntryService
                                              //                 //     .deleteSalesEntry(
                                              //                 //         fetchedSales[
                                              //                 //                 index]
                                              //                 //             .id);
                                              //                 // Navigator.of(
                                              //                 //         context)
                                              //                 //     .pop();
                                              //                 // setState(() {
                                              //                 //   fetchedSales
                                              //                 //       .removeAt(
                                              //                 //           index);
                                              //                 // });
                                              //               },
                                              //               child: const Text(
                                              //                   'Yes'),
                                              //             ),
                                              //           ],
                                              //         );
                                              //       },
                                              //     );
                                              //   },
                                              // ),

                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.print,
                                                    size: 15,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PaymentVoucherPrint(
                                                        'PAYMENT VOUCHER PRINT',
                                                        receiptID:
                                                            fectedPayments[
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
