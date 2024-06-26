import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/deliveryChallan/delivery_challan_model.dart';
import '../../data/models/newCompany/new_company_model.dart';
import '../../data/repository/delivery_challan_repository.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/new_company_repository.dart';
import 'DC_receipt.dart';

class DeliveryChallanHome extends StatefulWidget {
  const DeliveryChallanHome({super.key});

  @override
  State<DeliveryChallanHome> createState() => _DeliveryChallanHomeState();
}

class _DeliveryChallanHomeState extends State<DeliveryChallanHome> {
  List<DeliveryChallan> fetchedDelivery = [];
  LedgerService ledgerService = LedgerService();
  List<NewCompany> selectedComapny = [];
  NewCompanyRepository newCompanyRepo = NewCompanyRepository();

  String? selectedId;
  bool isLoading = false;

  DeliveryChallanServices deliveryChallanRepo = DeliveryChallanServices();
  List<String>? companyCode;

  Future<List<String>?> getCompanyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('companies');
  }

  Future<void> setCompanyCode() async {
    List<String>? code = await getCompanyCode();
    setState(() {
      companyCode = code;
      print('DCCCC $companyCode');
    });
  }

  Future<void> fetchAllDC() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<DeliveryChallan> dc =
          await deliveryChallanRepo.fetchDeliveryChallan();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        if (dc.isNotEmpty) {
          fetchedDelivery = dc;
          selectedId = fetchedDelivery[0].id;
        } else {
          fetchedDelivery = dc;
        }
        isLoading = false;
      });

      print(dc);
    } catch (error) {
      print('Failed to fetch Devlivery Challan: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchNewCompany() async {
    try {
      final newcom = await newCompanyRepo.getAllCompanies();

      // Extract all unique types from fetchedDelivery
      final types = fetchedDelivery.map((delivery) => delivery.type).toSet();

      // Filter companies whose companyCode matches any of the types
      final filteredCompany = newcom
          .where((company) => types.contains(company.companyCode))
          .toList();

      setState(() {
        selectedComapny = filteredCompany;
      });

      print('selectedComapny $selectedComapny');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await setCompanyCode();
    await fetchNewCompany();
    await fetchAllDC();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'DELIVERY CHALLAN LIST',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
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
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: fetchedDelivery.length,
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
                                        fetchedDelivery[index].date,
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
                                        fetchedDelivery[index].dcNo,
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
                                        // selectedComapny
                                        //     .firstWhere(
                                        //       (company) =>
                                        //           company.companyCode ==
                                        //           fetchedDelivery[index].type,
                                        //       orElse: () => NewCompany(
                                        //           companyCode: '',
                                        //           companyName: 'Not Found',
                                        //           id: '',
                                        //           companyType: '',
                                        //           country: '',
                                        //           taxation: '',
                                        //           acYear: '',
                                        //           acYearTo: '',
                                        //           password: '',
                                        //           email: ''),
                                        //     )
                                        //     .companyName!,
                                        fetchedDelivery[index].type,
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
                                      child: Text(
                                        fetchedDelivery[index].type,
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
                                              //     //           fetchedDelivery[index]
                                              //     //               .id,
                                              //     //     ),
                                              //     //   ),
                                              //     // );
                                              //   },
                                              // ),

                                              const Spacer(),
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
                                              //               'Delete Purchase'),
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
                                              //               onPressed: () {},
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
                                                          DCReceipt(
                                                        'Print Sales',
                                                        deliveryChallan:
                                                            fetchedDelivery[
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
