import 'package:flutter/material.dart';

class TestingFlutterWebT extends StatefulWidget {
  const TestingFlutterWebT({super.key});

  @override
  State<TestingFlutterWebT> createState() => _TestingFlutterWebTState();
}

class _TestingFlutterWebTState extends State<TestingFlutterWebT> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Example'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 10, top: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    width: MediaQuery.of(context).size.width * 0.88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.purple[900] ?? Colors.purple, width: 1),
                    ),
                    child: Table(
                      border: TableBorder.all(width: 1, color: Colors.white),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(5),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(2),
                        6: FlexColumnWidth(2),
                      },
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                                child: Text(
                              "Select",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Sr",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Name",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Ledger Code",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Opening Balance",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Opening Balance",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                            TableCell(
                                child: Text(
                              "Status",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                          ],
                        ),
                        // Populate table rows with data from fectedLedgers

                        TableRow(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: const TableCell(
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '1',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Text',
                                  textAlign: TextAlign.center,
                                ),
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
      ),
    );
  }
}
