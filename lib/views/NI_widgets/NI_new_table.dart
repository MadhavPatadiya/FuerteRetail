import 'package:flutter/material.dart';

class NInewTable extends StatelessWidget {
  const NInewTable({
    super.key,
    required this.dealerController,
    required this.subDealerController,
    required this.retailController,
    required this.mrpController,
    required this.dateController,
    required this.currentPriceController,
  });

  final TextEditingController dealerController;
  final TextEditingController subDealerController;
  final TextEditingController retailController;
  final TextEditingController mrpController;
  final TextEditingController dateController;
  final TextEditingController currentPriceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(color: Colors.black),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: const [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'DEALER',
                          style: TextStyle(
                            color: Colors.black,
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
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'SUB DEAL..',
                          style: TextStyle(
                            color: Colors.black,
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
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'RETAIL',
                          style: TextStyle(
                            color: Colors.black,
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
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'MRP',
                          style: TextStyle(
                            color: Colors.black,
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
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          'Current Price',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Repeat the pattern for other cells
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    // border: const TableBorder(

                    //     verticalInside: BorderSide(color: Colors.black),
                    //     horizontalInside: BorderSide(color: Colors.black),
                    //     ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: dateController,
                              onSaved: (newValue) {
                                dateController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: dealerController,
                              onSaved: (newValue) {
                                dealerController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: subDealerController,
                              onSaved: (newValue) {
                                subDealerController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: retailController,
                              onSaved: (newValue) {
                                retailController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: mrpController,
                              onSaved: (newValue) {
                                mrpController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: TextFormField(
                              controller: currentPriceController,
                              onSaved: (newValue) {
                                currentPriceController.text = newValue!;
                              },
                              textAlign: TextAlign.center,
                            ),
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
      ],
    );
  }
}
