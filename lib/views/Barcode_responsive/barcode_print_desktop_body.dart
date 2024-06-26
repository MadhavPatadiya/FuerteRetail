// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:billingsphere/views/Barcode_responsive/testbarcodepdf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../../data/models/barcode/barcode_model.dart';
import '../../data/models/item/item_model.dart';
import '../../data/repository/barcode_repository.dart';
import '../../data/repository/item_repository.dart';

class BarcodePrintD extends StatefulWidget {
  const BarcodePrintD({super.key});

  @override
  State<BarcodePrintD> createState() => _BarcodePrintDState();
}

class _BarcodePrintDState extends State<BarcodePrintD> {
  List<Item> fectedItems = [];
  List<Item> fectedItems2 = [];
  bool isLoading = false;
  ItemsService itemsService = ItemsService();
  BarcodeRepository barcodeRepository = BarcodeRepository();
  String barcode = '';
  List<Uint8List>? barcodeImages;
  TextEditingController qtyController = TextEditingController();
  String barcodeType = 'codabar';
  String printerType = 'Single Print';
  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<Item> items = await itemsService.fetchItems();
      // final filteredItem =
      //     items.where((payment) => payment.user_id == user_id).toList();
      setState(() {
        fectedItems = items;
        fectedItems2 = items;
        isLoading = false;
      });

      print('Fetched Length: ${fectedItems.length}');
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  // Fetch Barcode by Id
  Future<Barcode> fetchBarcodeById(String id) async {
    try {
      final Barcode? barcode = await barcodeRepository.fetchBarcodeById(id);
      if (barcode != null) {
        return barcode;
      } else {
        throw 'Barcode not found';
      }
    } catch (error) {
      throw 'Failed to fetch barcode: $error';
    }
  }

// Create Barcode Image
  Future<void> createBarcodeImages(String id, int qty) async {
    try {
      final List<Uint8List>? barcodeImages =
          await barcodeRepository.createBarcodeImages(id, qty);
      if (barcodeImages != null && barcodeImages.isNotEmpty) {
        setState(() {
          this.barcodeImages = barcodeImages;
        });
      } else {
        print('No barcode images received.');
      }
    } catch (error) {
      print('Failed to create barcode images: $error');
    }
  }

  void _initializeData() async {
    await fetchItems();
  }

  @override
  void dispose() {
    super.dispose();
    qtyController.dispose();
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
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 19, 3, 201),
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
                        'BARCODE PRINT',
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
                // Make container and center it with the help of Center widget
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white10,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Search by Item Name',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  CupertinoIcons.search,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    fectedItems = fectedItems
                                        .where((element) => element.itemName
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  } else {
                                    fectedItems = fectedItems2;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: fectedItems.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                elevation: 1,
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(
                                    fectedItems[index].itemName,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Item Code: ${fectedItems[index].codeNo} | Price: ${fectedItems[index].mrp} | Stock: ${fectedItems[index].monthlySalesQty}',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      int numberOfBarcodes = 1;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Print Barcodes'),
                                            content: StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Select barcode type:',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    5)),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value: barcodeType,
                                                        isExpanded: true,
                                                        underline:
                                                            const SizedBox(), // Remove the underline
                                                        items: [
                                                          'codabar',
                                                          'code 39',
                                                          'code 93',
                                                          'code 128',
                                                          'EAN-13',
                                                        ].map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                          (String value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                                child:
                                                                    Text(value),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                        onChanged:
                                                            (String? newValue) {
                                                          if (newValue !=
                                                              null) {
                                                            setState(() {
                                                              barcodeType =
                                                                  newValue;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Select Printer type:',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    5)),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value: printerType,
                                                        isExpanded: true,
                                                        underline:
                                                            const SizedBox(), // Remove the underline
                                                        items: [
                                                          'Single Print',
                                                          'Double Print',
                                                        ].map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                          (String value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                                child:
                                                                    Text(value),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                        onChanged:
                                                            (String? newValue) {
                                                          if (newValue !=
                                                              null) {
                                                            setState(() {
                                                              printerType =
                                                                  newValue;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Enter the number of barcodes to print:',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    TextField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        numberOfBarcodes =
                                                            int.tryParse(
                                                                value)!;

                                                        if (numberOfBarcodes %
                                                                    2 !=
                                                                0 &&
                                                            printerType ==
                                                                'Double Print') {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please Enter an even number for double print.'),
                                                            ),
                                                          );

                                                          setState(() {
                                                            numberOfBarcodes =
                                                                2;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () async {
                                                  final barcode =
                                                      await fetchBarcodeById(
                                                          fectedItems[index]
                                                              .barcode);

                                                  List<Widget> barcodes = [];
                                                  for (int i = 0;
                                                      i < numberOfBarcodes;
                                                      i++) {
                                                    barcodes.add(
                                                      SizedBox(
                                                        width: printerType ==
                                                                'Double Print'
                                                            ? 150
                                                            : 100,
                                                        height: printerType ==
                                                                'Single Print'
                                                            ? 50
                                                            : 50,
                                                        child:
                                                            SfBarcodeGenerator(
                                                          value:
                                                              barcode.barcode,
                                                          symbology: barcodeType ==
                                                                  'codabar'
                                                              ? Codabar()
                                                              : barcodeType ==
                                                                      'code 39 Extended'
                                                                  ? Code39Extended()
                                                                  : barcodeType ==
                                                                          'code 39'
                                                                      ? Code39()
                                                                      : barcodeType ==
                                                                              'code 93'
                                                                          ? Code93()
                                                                          : barcodeType == 'code 128A'
                                                                              ? Code128A()
                                                                              : barcodeType == 'code 128B'
                                                                                  ? Code128B()
                                                                                  : barcodeType == 'code 128C'
                                                                                      ? Code128C()
                                                                                      : barcodeType == 'code 128'
                                                                                          ? Code128()
                                                                                          : barcodeType == 'EAN-13'
                                                                                              ? EAN13()
                                                                                              : Code128C(),
                                                          showValue: true,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Generated Barcodes'),
                                                        content: SizedBox(
                                                          height: 500,
                                                          width: 500,
                                                          child:
                                                              GridView.builder(
                                                            gridDelegate:
                                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  printerType ==
                                                                          'Single Print'
                                                                      ? 1
                                                                      : 2,
                                                              childAspectRatio:
                                                                  3,
                                                              crossAxisSpacing:
                                                                  32.0, // Add horizontal spacing between items
                                                              mainAxisSpacing:
                                                                  32.0, // Add vertical spacing between items
                                                            ),
                                                            itemCount:
                                                                barcodes.length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return barcodes[
                                                                  index];
                                                            },
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder: (context) => BarcodePrintingPage(
                                                                      printerType:
                                                                          printerType,
                                                                      barcodes:
                                                                          barcodes,
                                                                      barcodeType:
                                                                          barcodeType),
                                                                ),
                                                              );
                                                            },
                                                            child: const Text(
                                                                'Print Barcode'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Close'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Text('Print'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.barcode_viewfinder,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
