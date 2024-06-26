import 'dart:async';

import 'package:billingsphere/data/repository/item_brand_repository.dart';
import 'package:billingsphere/data/repository/item_group_repository.dart';
import 'package:billingsphere/data/repository/store_location_repository.dart';
import 'package:billingsphere/views/DB_widgets/Desktop_widgets/d_custom_buttons.dart';
import 'package:billingsphere/views/NI_responsive.dart/NI_desktopBody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../data/models/brand/item_brand_model.dart';
import '../../data/models/item/item_model.dart';
import '../../data/models/itemGroup/item_group_model.dart';
import '../../data/models/storeLocation/store_location_model.dart';
import '../../data/repository/item_repository.dart';
import '../NI_homepage.dart';
import 'NI_edit.dart';

class ItemHome extends StatefulWidget {
  const ItemHome({super.key});

  @override
  State<ItemHome> createState() => _ItemHomeState();
}

class _ItemHomeState extends State<ItemHome> {
  // Item Service
  ItemsService itemsService = ItemsService();
  ItemsBrandsService itemsBrandsService = ItemsBrandsService();
  ItemsGroupService itemsGroupService = ItemsGroupService();
  StoreLocationService storeLocationService = StoreLocationService();
  final TextEditingController _searchController = TextEditingController();

  // Fetched Ledger List
  List<Item> fectedItems = [];
  List<Item> fectedItems2 = [];
  String? selectedId;
  List<ItemsBrand> fectedItemBrands = [];
  List<ItemsGroup> fectedItemGroups = [];
  List<StoreLocation> fectedStoreLocations = [];

  int currentPage = 1;
  int totalPages = 1;
  int limit = 50;
  Timer? _debounce;

  // Variable
  bool isLoading = false;

  void goToPage(int page) {
    if (page != currentPage) {
      fetchItemsWithPagination(page);
      setState(() {
        currentPage = page;
      });
    }
  }

  Future<void> fetchItemsWithPagination(int page) async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<Item> items =
          await itemsService.fetchItemsWithPagination(page);
      setState(() {
        fectedItems = items;
        isLoading = false;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();
      setState(() {
        fectedItems = items;
        fectedItems2 = items;

        if (fectedItems.isNotEmpty) {
          selectedId = fectedItems[0].id;
        }
        totalPages = itemsService.totalPages;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  // void searchItem(String query) {
  //   // Filter user groups based on query
  //   if (query.isNotEmpty) {
  //     List<Item> filteredList = fectedItems.where((group) {
  //       return group.itemName.toLowerCase().contains(query.toLowerCase());
  //     }).toList();

  //     setState(() {
  //       fectedItems = filteredList;
  //     });
  //   } else {
  //     setState(() {
  //       fectedItems = fectedItems2;
  //     });
  //   }
  // }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchItem(query);
    });
  }

  void searchItem(String query) {
    if (query.isNotEmpty) {
      List<Item> filteredList = fectedItems2.where((group) {
        return group.itemName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        fectedItems = filteredList;
      });
    } else {
      setState(() {
        fectedItems = fectedItems2;
      });
    }
  }

  Future<void> fetchItemBrands() async {
    try {
      final List<ItemsBrand> itemBrands =
          await itemsBrandsService.fetchItemBrands();
      setState(() {
        fectedItemBrands = itemBrands;
      });
    } catch (error) {
      print('Failed to fetch item brands: $error');
    }
  }

  Future<void> fetchItemGroups() async {
    try {
      final List<ItemsGroup> itemGroups =
          await itemsGroupService.fetchItemGroups();
      setState(() {
        fectedItemGroups = itemGroups;
      });
    } catch (error) {
      print('Failed to fetch item groups: $error');
    }
  }

  Future<void> fetchStoreLocations() async {
    try {
      final List<StoreLocation> storeLocations =
          await storeLocationService.fetchStoreLocations();
      setState(() {
        fectedStoreLocations = storeLocations;
      });
    } catch (error) {
      print('Failed to fetch store locations: $error');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        fetchItems(),
        fetchItemBrands(),
        fetchItemGroups(),
        fetchStoreLocations(),
      ]);
    } catch (error) {
//
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileWidget();
        } else if (constraints.maxWidth >= 600 && constraints.maxWidth < 1200) {
          return _buildTabletWidget();
        } else {
          return _buildDesktopWidget();
        }
      },
    );
  }

  Widget _buildMobileWidget() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
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
                SizedBox(width: MediaQuery.of(context).size.width * 0.30),
                Text(
                  'ITEM MASTER',
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
          const SizedBox(height: 5),

          // Buttons
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DButtons(
                      text: 'NEW',
                      alignment: Alignment.center,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NIMyDesktopBody(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DButtons(
                      text: 'EDIT',
                      alignment: Alignment.center,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NIMyDesktopBodyE(
                              id: selectedId!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DButtons(
                      text: 'DELETE',
                      alignment: Alignment.center,
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text('Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    itemsService
                                        .deleteItem(selectedId!, context)
                                        .then((value) => {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ItemHome(),
                                                ),
                                              )
                                            });
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('No',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(2),
              },
              border: TableBorder.all(width: 1, color: Colors.white),
              children: [
                TableRow(
                  children: [
                    TableCell(
                        child: Text(
                      "Sel",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                      ),
                    )),
                    TableCell(
                        child: Text(
                      "Name",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                      ),
                    )),
                    TableCell(
                        child: Text(
                      "Brand",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                      ),
                    )),
                    TableCell(
                        child: Text(
                      "Status",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                      ),
                    )),
                  ],
                ),

                // Populate table rows with data from fectedLedgers
                for (int i = 0; i < fectedItems.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Radio<String>(
                          value: fectedItems[i].id,
                          groupValue: selectedId,
                          fillColor:
                              MaterialStateProperty.all(Colors.blue.shade900),
                          onChanged: (String? value) {
                            setState(() {
                              selectedId = value;
                            });
                          },
                        ),
                      ),
                      TableCell(
                        child: Text(
                          fectedItems[i].itemName.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          fectedItemBrands
                              .firstWhere((element) =>
                                  element.id == fectedItems[i].itemBrand)
                              .name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          fectedItems[i].status.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabletWidget() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
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
                  'ITEM MASTER',
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
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade900, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.83,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(5),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(2),
                              },
                              border: TableBorder.all(
                                  width: 1, color: Colors.white),
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text(
                                        "Sel",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        "Sr",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        "Item Name",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        "Item Brand",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        "Status",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // TableRow(
                                //   decoration: BoxDecoration(
                                //     color: Colors.grey[300],
                                //   ),
                                //   children: const [
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Select',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Sr',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Item Name',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Item Brand',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Item Group',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Store Location',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //     TableCell(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'Status',
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // Populate table rows with data from fectedLedgers
                                for (int i = 0; i < fectedItems.length; i++)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Radio<String>(
                                          value: fectedItems[i].id,
                                          groupValue: selectedId,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedId = value;
                                            });
                                          },
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${i + 1}', // Proper numbering per page
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            fectedItems[i].itemName.toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            fectedItemBrands
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    fectedItems[i].itemBrand)
                                                .name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            fectedItems[i].status.toString(),
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
                      ),
                      // Button for next and previous
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: 'GoTo First Page',
                            child: IconButton(
                              onPressed:
                                  currentPage > 1 ? () => goToPage(1) : null,
                              icon: const Icon(Icons.first_page),
                            ),
                          ),
                          Tooltip(
                            message: 'GoTo Previous Page',
                            child: IconButton(
                              onPressed: currentPage > 1
                                  ? () => goToPage(currentPage - 1)
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          Tooltip(
                            message: 'GoTo Next Page',
                            child: IconButton(
                              onPressed: currentPage < totalPages
                                  ? () => goToPage(currentPage + 1)
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          ),
                          Tooltip(
                            message: 'GoTo Last Page',
                            child: IconButton(
                              onPressed: currentPage < totalPages
                                  ? () => goToPage(totalPages)
                                  : null,
                              icon: const Icon(Icons.last_page),
                            ),
                          ),

                          // Show current page
                          Text(
                            'Page: $currentPage of $totalPages',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Shortcuts(
                shortcuts: {
                  LogicalKeySet(LogicalKeyboardKey.f3): const ActivateIntent(),
                  LogicalKeySet(LogicalKeyboardKey.f4): const ActivateIntent(),
                },
                child: Focus(
                  autofocus: true,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.f3) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NIHomePage(),
                        ),
                      );
                      return KeyEventResult.handled;
                    } else if (event is RawKeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.f4) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NIMyDesktopBodyE(
                            id: selectedId!,
                          ),
                        ),
                      );
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Builder(
                    builder: (context) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.13,
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NIHomePage(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    ' F3    New',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NIMyDesktopBodyE(
                                          id: selectedId!,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    'F4   Edit',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: const Text('Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this entry?'),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                itemsService
                                                    .deleteItem(
                                                        selectedId!, context)
                                                    .then((value) => {
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const ItemHome(),
                                                            ),
                                                          )
                                                        });
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text('No',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Export-Excel'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Bulk-Upload'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Filters'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Label Printing'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Envelope Printing'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Envelope'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Opening Balance'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Edit button pressed');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text('Statement'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWidget() {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        // : fectedItems.isEmpty
        //     ? Scaffold(
        //         body: Column(
        //           children: [
        //             Container(
        //               width: double.infinity,
        //               decoration: BoxDecoration(
        //                 color: Colors.brown[900],
        //               ),
        //               child: Row(
        //                 children: [
        //                   IconButton(
        //                     onPressed: () {
        //                       Navigator.pop(context);
        //                     },
        //                     icon: const Icon(
        //                       CupertinoIcons.arrow_left,
        //                       color: Colors.white,
        //                       size: 15,
        //                     ),
        //                   ),
        //                   SizedBox(
        //                       width: MediaQuery.of(context).size.width * 0.45),
        //                   Text(
        //                     'ITEM MASTER',
        //                     style: GoogleFonts.poppins(
        //                       textStyle: const TextStyle(
        //                         color: Colors.white,
        //                         fontSize: 15,
        //                       ),
        //                     ),
        //                     textAlign: TextAlign.center,
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        //             Center(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //                   Lottie.asset(
        //                     'assets/lottie/PageNotFound.json',
        //                     height: 200,
        //                     fit: BoxFit.cover,
        //                   ),
        //                   const SizedBox(height: 20),
        //                   Text(
        //                     'No Item Found!, Click the Button Below to Add New Item',
        //                     style: GoogleFonts.poppins(
        //                       fontSize: 20,
        //                       fontWeight: FontWeight.w500,
        //                     ),
        //                   ),
        //                   const SizedBox(height: 20),
        //                   ElevatedButton(
        //                     style: ElevatedButton.styleFrom(
        //                       foregroundColor: Colors.black,
        //                       backgroundColor: Colors.white,
        //                       shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(0),
        //                       ),
        //                     ),
        //                     onPressed: () {
        //                       Navigator.of(context).push(
        //                         MaterialPageRoute(
        //                           builder: (context) => const NIMyDesktopBody(),
        //                         ),
        //                       );
        //                     },
        //                     child: const Text(
        //                       'Create Item Entry',
        //                       style: TextStyle(
        //                         color: Colors.black,
        //                         fontSize: 15,
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        : Scaffold(
            appBar: AppBar(
              title: const Text('ITEM MASTER'),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade900,
              centerTitle: true,
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue.shade900, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.09,
                                    child: Text(
                                      "Search",
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue.shade900,
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                0.0,
                                              ), // Adjust the border radius as needed
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

                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.all(0),
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.83,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(5),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(2),
                                },
                                border: TableBorder.all(
                                    width: 1, color: Colors.white),
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                          child: Text(
                                        "Select",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Sr",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Item Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Item Brand",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Item Group",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Store Location",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                      TableCell(
                                          child: Text(
                                        "Status",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20),
                                      )),
                                    ],
                                  ),

                                  // TableRow(
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.grey[300],
                                  //   ),
                                  //   children: const [
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Select',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Sr',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Item Name',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Item Brand',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Item Group',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Store Location',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     TableCell(
                                  //       child: Padding(
                                  //         padding: EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           'Status',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // Populate table rows with data from fectedLedgers
                                  for (int i = 0; i < fectedItems.length; i++)
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Radio<String>(
                                            value: fectedItems[i].id,
                                            groupValue: selectedId,
                                            onChanged: (String? value) {
                                              setState(() {
                                                selectedId = value;
                                              });
                                            },
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${i + 1}', // Proper numbering per page
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              fectedItems[i]
                                                  .itemName
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              fectedItemGroups
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      fectedItems[i].itemGroup)
                                                  .name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              fectedItemBrands
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      fectedItems[i].itemBrand)
                                                  .name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              fectedStoreLocations
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      fectedItems[i]
                                                          .storeLocation)
                                                  .location,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        // TableCell(
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(8.0),
                                        //     child: Text(
                                        //       fectedItems[i].storeLocation.toString(),
                                        //       textAlign: TextAlign.center,
                                        //     ),
                                        //   ),
                                        // ),

                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              fectedItems[i].status.toString(),
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
                        ),
                        // Button for next and previous
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'GoTo First Page',
                              child: IconButton(
                                onPressed:
                                    currentPage > 1 ? () => goToPage(1) : null,
                                icon: const Icon(Icons.first_page),
                              ),
                            ),
                            Tooltip(
                              message: 'GoTo Previous Page',
                              child: IconButton(
                                onPressed: currentPage > 1
                                    ? () => goToPage(currentPage - 1)
                                    : null,
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                            Tooltip(
                              message: 'GoTo Next Page',
                              child: IconButton(
                                onPressed: currentPage < totalPages
                                    ? () => goToPage(currentPage + 1)
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            Tooltip(
                              message: 'GoTo Last Page',
                              child: IconButton(
                                onPressed: currentPage < totalPages
                                    ? () => goToPage(totalPages)
                                    : null,
                                icon: const Icon(Icons.last_page),
                              ),
                            ),

                            // Show current page
                            Text(
                              'Page: $currentPage of $totalPages',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                            builder: (context) => const NIHomePage(),
                          ),
                        );
                        return KeyEventResult.handled;
                      } else if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.f4) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NIMyDesktopBodyE(
                              id: selectedId!,
                            ),
                          ),
                        );
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.13,
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NIHomePage(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(' F3        New'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NIMyDesktopBodyE(
                                            id: selectedId!,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('F4        Edit'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) {
                                          return CupertinoAlertDialog(
                                            title: const Text('Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this entry?'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('Yes'),
                                                onPressed: () {
                                                  itemsService
                                                      .deleteItem(
                                                          selectedId!, context)
                                                      .then((value) => {
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacement(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const ItemHome(),
                                                              ),
                                                            )
                                                          });
                                                },
                                              ),
                                              CupertinoDialogAction(
                                                child: const Text('No',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Export-Excel'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Bulk-Upload'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Filters'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Label Printing'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Envelope Printing'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Envelope'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Opening Balance'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('Statement'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('Edit button pressed');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text(''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
