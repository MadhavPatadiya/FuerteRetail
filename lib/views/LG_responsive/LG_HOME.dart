import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/ledgerGroup/ledger_group_model.dart';
import '../../data/repository/ledger_group_respository.dart';
import '../../data/repository/ledger_repository.dart';
import '../DB_responsive/DB_desktop_body.dart';
import '../LG_homepage.dart';
import 'LG_desktop_body.dart';
import 'LG_update.dart';

class LedgerHome extends StatefulWidget {
  const LedgerHome({super.key});

  @override
  State<LedgerHome> createState() => _LedgerHomeState();
}

class _LedgerHomeState extends State<LedgerHome> {
  // Ledger Service
  LedgerService ledgerService = LedgerService();
  final LedgerGroupService ledgerGroupService = LedgerGroupService();
  final TextEditingController _searchController = TextEditingController();

  // Fetched Ledger List
  List<Ledger> fectedLedgers = [];
  List<Ledger> fectedLedgers2 = [];
  String? selectedId;
  bool isLoading = false;

  Future<void> fetchLedgers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<Ledger> ledger = await ledgerService.fetchLedgers();
      setState(() {
        fectedLedgers = ledger;
        fectedLedgers2 = ledger;
        if (fectedLedgers.isNotEmpty) {
          selectedId = fectedLedgers[0].id;
        }
        isLoading = false;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchItem(query);
    });
  }

  void searchItem(String query) {
    if (query.isNotEmpty) {
      List<Ledger> filteredList = fectedLedgers2.where((group) {
        return group.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        fectedLedgers = filteredList;
      });
    } else {
      setState(() {
        fectedLedgers = fectedLedgers2;
      });
    }
  }

  void deleteLedger() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {
                  ledgerService.deleteLedger(selectedId!, context).then(
                      (value) => {Navigator.of(context).pop(), fetchLedgers()});
                },
              ),
              CupertinoDialogAction(
                child: const Text('No', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.f12) {
      // Execute your function when F3 key is pressed
      deleteLedger();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLedgers();
    RawKeyboard.instance.addListener(_handleKey);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    RawKeyboard.instance.removeListener(_handleKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                title: const Text('LEDGERS MASTER'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple[900],
                centerTitle: true,
              ),
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 35,
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.09,
                                  child: Text(
                                    "Search",
                                    style: GoogleFonts.poppins(
                                      color:
                                          Colors.purple[900] ?? Colors.purple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Container(
                                    color: Colors.black,
                                    height: 35,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: _onSearchChanged,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          height: 0.8,
                                        ),
                                        // cursorHeight: 15,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(0.0),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                0.0), // Adjust the border radius as needed
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 15, left: 10, top: 10),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.88,
                          width: MediaQuery.of(context).size.width * 0.88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.purple[900] ?? Colors.purple,
                                width: 1),
                          ),
                          child: Table(
                            border:
                                TableBorder.all(width: 1, color: Colors.white),
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
                              TableRow(
                                children: [
                                  TableCell(
                                      child: Text(
                                    "Select",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.purple[900],
                                        fontSize: 20),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Sr",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Name",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Ledger Group",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Opening Balance",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Debit Balance",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                  TableCell(
                                      child: Text(
                                    "Status",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple[900],
                                      fontSize: 20,
                                    ),
                                  )),
                                ],
                              ),
                              // Populate table rows with data from fectedLedgers
                              for (int i = 0; i < fectedLedgers.length; i++)
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Radio<String>(
                                        value: fectedLedgers[i].id,
                                        groupValue: selectedId,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedId = value;
                                          });

                                          print(selectedId);
                                        },
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${i + 1}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          fectedLedgers[i].name,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FutureBuilder<LedgerGroup?>(
                                          future: ledgerGroupService
                                              .fetchLedgerGroupById(
                                                  fectedLedgers[i].ledgerGroup),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<LedgerGroup?>
                                                  snapshot) {
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
                                                  textAlign: TextAlign.center,
                                                );
                                              } else {
                                                return const Text('No Data');
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          fectedLedgers[i]
                                              .openingBalance
                                              .toStringAsFixed(2)
                                              .toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          fectedLedgers[i]
                                              .debitBalance
                                              .toStringAsFixed(2)
                                              .toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          fectedLedgers[i].status.toString(),
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
                Shortcuts(
                    shortcuts: {
                      LogicalKeySet(LogicalKeyboardKey.f3):
                          const ActivateIntent(),
                      LogicalKeySet(LogicalKeyboardKey.f4):
                          const ActivateIntent(),
                    },
                    child: Focus(
                      autofocus: true,
                      onKey: (FocusNode node, RawKeyEvent event) {
                        if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.f3) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LGHomePage(),
                            ),
                          );
                          return KeyEventResult.handled;
                        } else if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.f4) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LGUpdateEntry(
                                id: selectedId!,
                              ),
                            ),
                          );
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Builder(
                        builder: (context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.88,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  List1(
                                    name: "New",
                                    Skey: 'F3',
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LGHomePage(),
                                        ),
                                      );
                                    },
                                  ),
                                  List1(
                                    name: "Edit",
                                    Skey: 'F4',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LGUpdateEntry(
                                            id: selectedId!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Delete",
                                    Skey: 'D',
                                    onPressed: deleteLedger,
                                  ),
                                  List1(
                                    name: "Export Excel",
                                    Skey: 'F4',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Bulk Upload",
                                    Skey: 'F5',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    Skey: 'F6',
                                    name: "Filters",
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Label Printing",
                                    Skey: 'F7',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Envelope Print",
                                    Skey: 'F8',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Envelope",
                                    Skey: 'F9',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Opening Bal",
                                    Skey: 'F10',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Statement",
                                    Skey: 'F11',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    name: "Print Setup",
                                    Skey: 'F12',
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                  List1(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          );
  }
}

class List1 extends StatelessWidget {
  final String? name;
  final String? Skey;
  final Function onPressed;
  const List1({Key? key, this.name, this.Skey, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        splashColor: Colors.grey[350],
        onTap: onPressed as void Function()?,
        child: Container(
          height: 35,
          width: w * 0.1,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              right: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              left: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              bottom: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    Skey ?? "",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    name ?? " ",
                    style: TextStyle(
                      color: Colors.purple[900] ?? Colors.purple,
                      fontSize: 12,
                    ),
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
