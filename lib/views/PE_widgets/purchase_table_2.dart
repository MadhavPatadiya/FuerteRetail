import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/item/item_model.dart';
import '../../data/models/measurementLimit/measurement_limit_model.dart';
import '../../data/models/taxCategory/tax_category_model.dart';
import '../../data/repository/item_repository.dart';
import '../../data/repository/measurement_limit_repository.dart';
import '../../data/repository/tax_category_repository.dart';
import '../SE_variables/SE_variables.dart';
import '../searchable_dropdown.dart';

class PEntries2 extends StatefulWidget {
  const PEntries2({
    super.key,
    required this.unitControllerP,
    required this.entryId,
    required this.itemNameControllerP,
    required this.qtyControllerP,
    required this.rateControllerP,
    required this.amountControllerP,
    required this.taxControllerP,
    required this.sgstControllerP,
    required this.cgstControllerP,
    required this.igstControllerP,
    required this.netAmountControllerP,
    required this.discountControllerP,
    required this.sellingPriceControllerP,
    required this.onSaveValues,
    required this.onDelete,
    required this.serialNo,
  });

  final TextEditingController itemNameControllerP;
  final TextEditingController qtyControllerP;
  final TextEditingController rateControllerP;
  final TextEditingController unitControllerP;
  final TextEditingController amountControllerP;
  final TextEditingController taxControllerP;
  final TextEditingController sgstControllerP;
  final TextEditingController cgstControllerP;
  final TextEditingController igstControllerP;
  final TextEditingController netAmountControllerP;
  final TextEditingController discountControllerP;
  final TextEditingController sellingPriceControllerP;
  final Function(Map<String, dynamic>) onSaveValues;
  final Function(String) onDelete;
  final String entryId;
  final int serialNo;

  @override
  State<PEntries2> createState() => _PEntriesState();
}

class _PEntriesState extends State<PEntries2> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController igstController = TextEditingController();
  final TextEditingController netAmountController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  double originalNetAmount = 0.0;

  // Backend Services/Repositories
  ItemsService itemsService = ItemsService();
  TaxRateService taxRateService = TaxRateService();
  MeasurementLimitService measurementService = MeasurementLimitService();
  // Variables
  String? selectedItemId;
  String? selectedTaxRateId;
  String? selectedmeasurementId;
  double itemRate = 0.0; // Track the selected item's rate

  // List of items
  List<Item> itemsList = [];
  List<TaxRate> taxLists = [];
  List<MeasurementLimit> measurement = [];
  double persistentTotal = 0.00;
  String? uid;
  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> setId() async {
    String? id = await getUID();
    setState(() {
      uid = id;
    });
  }

  // Future Functions
  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();

      for (TaxRate tax in taxLists) {
        if (tax.id == items.first.taxCategory) {
          setState(() {
            taxController.text = items.isNotEmpty ? tax.rate : '0';
            widget.taxControllerP.text = taxController.text;
          });
        }
      }

      for (MeasurementLimit meu in measurement) {
        if (meu.id == items.first.measurementUnit) {
          setState(() {
            unitController.text = items.isNotEmpty ? meu.measurement : '0';
            widget.unitControllerP.text = unitController.text;
          });
        }
      }

      setState(() {
        itemsList = items;
        selectedItemId = widget.itemNameControllerP.text.isNotEmpty
            ? widget.itemNameControllerP.text
            : itemsList.first.id;
        itemNameController.text = selectedItemId!;
        widget.itemNameControllerP.text = itemNameController.text;
        itemRate = itemsList.first.mrp;
      });
    } catch (error) {
      // ignore: avoid_print
      print('Failed to fetch ledger name: $error');
    }
  }

  // void updateItemRate(String? selectedItemId) {
  //   // Find the selected Item
  //   Item? selectedItem = itemsList.firstWhere(
  //     (item) => item.id == selectedItemId,
  //   );

  //   // Update itemRate based on the selected Item
  //   if (selectedItem != '') {
  //     setState(() {
  //       itemRate = selectedItem.mrp;
  //     });
  //   }
  // }

  void _saveValues() {
    final values = {
      'uniqueKey': widget.entryId,
      'itemName': itemNameController.text,
      'qty': qtyController.text,
      'unit': unitController.text,
      'rate': rateController.text,
      'amount': amountController.text,
      'tax': taxController.text,
      'sgst': sgstController.text,
      'cgst': cgstController.text,
      'igst': igstController.text,
      'netAmount': netAmountController.text,
      'discount': discountController.text,
      'sellingPrice': sellingPriceController.text,
    };

    Fluttertoast.showToast(
      msg: "Values added to list successfully!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER_RIGHT,
      webPosition: "right",
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );

    widget.onSaveValues(values);
  }

  // Method to delete entry
  void _deleteEntry() {
    widget.onDelete(widget.entryId);
    Fluttertoast.showToast(
      msg: "Entry deleted successfully!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER_RIGHT,
      webPosition: "right",
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    _saveValues;
  }

  Future<void> fetchAndSetTaxRates() async {
    try {
      final List<TaxRate> taxRates = await taxRateService.fetchTaxRates();

      setState(() {
        taxLists = taxRates;
        selectedTaxRateId = taxLists.isNotEmpty ? taxLists.first.id : null;
        taxController.text = taxLists.isNotEmpty ? taxLists.first.rate : '0';
      });

      print(taxRates);
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  Future<void> fetchMeasurementLimit() async {
    try {
      final List<MeasurementLimit> measurements =
          await measurementService.fetchMeasurementLimits();

      setState(() {
        measurement = measurements;
        selectedmeasurementId =
            measurement.isNotEmpty ? measurement.first.id : null;
        unitController.text =
            measurement.isNotEmpty ? measurement.first.measurement : 'Lt';
      });

      print(measurements);
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  void _initializeData() async {
    await setId();
    await fetchAndSetTaxRates();
    await fetchMeasurementLimit();
    await fetchItems();

    setState(() {
      itemNameController.text = widget.itemNameControllerP.text;
      qtyController.text = widget.qtyControllerP.text;
      rateController.text = widget.rateControllerP.text;
      unitController.text = widget.unitControllerP.text;
      amountController.text = widget.amountControllerP.text;
      taxController.text = widget.taxControllerP.text;
      sgstController.text = widget.sgstControllerP.text;
      cgstController.text = widget.cgstControllerP.text;
      igstController.text = widget.igstControllerP.text;
      netAmountController.text = widget.netAmountControllerP.text;
      sellingPriceController.text = widget.sellingPriceControllerP.text;
      selectedItemId = widget.itemNameControllerP.text;
      discountController.text = widget.discountControllerP.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    qtyController.dispose();
    rateController.dispose();
    amountController.dispose();
    sgstController.dispose();
    cgstController.dispose();
    igstController.dispose();
    netAmountController.dispose();
    sellingPriceController.dispose();
    itemNameController.dispose();
    taxController.dispose();
    unitController.dispose();
    discountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.023,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: Text(
                  '${widget.serialNo}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                // child: DropdownButton<String>(
                //   value: selectedItemId,
                //   underline: Container(),
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       selectedItemId = newValue;
                //       selectedmeasurementId = newValue;
                //       setState(() {
                //         itemNameController.text = selectedItemId!;
                //         widget.itemNameControllerP.text =
                //             itemNameController.text;
                //       });
                //       String newId = '';
                //       String newId2 = '';
                //       for (Item item in itemsList) {
                //         if (item.id == selectedItemId) {
                //           newId = item.taxCategory;
                //         }
                //       }
                //       for (Item item in itemsList) {
                //         if (item.id == selectedmeasurementId) {
                //           newId2 = item.measurementUnit;
                //         }
                //       }
                //       for (TaxRate tax in taxLists) {
                //         if (tax.id == newId) {
                //           setState(() {
                //             taxController.text =
                //                 items.isNotEmpty ? tax.rate : '0';
                //             widget.taxControllerP.text = taxController.text;
                //           });
                //         }
                //       }
                //       for (MeasurementLimit meu in measurement) {
                //         if (meu.id == newId2) {
                //           setState(() {
                //             unitController.text =
                //                 items.isNotEmpty ? meu.measurement : '0';
                //             widget.unitControllerP.text = unitController.text;
                //           });
                //         }
                //       }
                //     });
                //   },
                //   isDense: true,
                //   isExpanded: true,
                //   items: itemsList.map((Item items) {
                //     return DropdownMenuItem<String>(
                //       value: items.id,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             items.itemName,
                //             style: const TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //             maxLines: 1,
                //           ),
                //         ],
                //       ),
                //     );
                //   }).toList(),
                // ),
                child: SearchableDropDown(
                  controller: searchController,
                  searchController: searchController,
                  value: selectedItemId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItemId = newValue;
                      selectedmeasurementId = newValue;

                      setState(() {
                        itemNameController.text = selectedItemId!;
                        widget.itemNameControllerP.text =
                            itemNameController.text;
                      });

                      String newId = '';
                      String newId2 = '';

                      for (Item item in itemsList) {
                        if (item.id == selectedItemId) {
                          newId = item.taxCategory;
                        }
                      }

                      for (Item item in itemsList) {
                        if (item.id == selectedmeasurementId) {
                          newId2 = item.measurementUnit;
                        }
                      }

                      for (TaxRate tax in taxLists) {
                        if (tax.id == newId) {
                          setState(() {
                            taxController.text =
                                items.isNotEmpty ? tax.rate : '0';
                            widget.taxControllerP.text = taxController.text;
                          });
                        }
                      }
                      for (MeasurementLimit meu in measurement) {
                        if (meu.id == newId2) {
                          setState(() {
                            unitController.text =
                                items.isNotEmpty ? meu.measurement : '0';
                            widget.unitControllerP.text = unitController.text;
                          });
                        }
                      }
                    });
                  },
                  items: itemsList.map((Item items) {
                    return DropdownMenuItem<String>(
                      value: items.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            items.itemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  searchMatchFn: (item, searchValue) {
                    final peItem = itemsList
                        .firstWhere((e) => e.id == item.value)
                        .itemName;
                    return peItem
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: qtyController,
                  onChanged: (value) {
                    setState(() {
                      int amount = (int.tryParse(rateController.text) ?? 0) *
                          int.parse(value);
                      discountController.text = '0.00';

                      amountController.text = amount.toString();

                      double amountValue =
                          double.tryParse(amountController.text) ?? 0.0;
                      double taxValue =
                          double.tryParse(taxController.text) ?? 0.0;

                      if (taxValue != 0) {
                        double gsts = (amountValue * taxValue) / 100;
                        sgstController.text = (gsts / 2).toString();
                        cgstController.text = (gsts / 2).toString();
                        netAmountController.text =
                            (amountValue + gsts).toString();
                      } else {
                        // Handle division by zero scenario
                        sgstController.text = '0';
                        cgstController.text = '0';
                        netAmountController.text = amountController.text;
                      }

                      // Update persistent controllers if needed
                      widget.sgstControllerP.text = sgstController.text;
                      widget.cgstControllerP.text = cgstController.text;
                      widget.netAmountControllerP.text =
                          netAmountController.text;
                      persistentTotal =
                          double.tryParse(netAmountController.text) ?? 0.0;
                      originalNetAmount = persistentTotal;
                      widget.qtyControllerP.text = qtyController.text;
                    });
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      left: BorderSide()),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: unitController,
                  onSaved: (newValue) {
                    unitController.text = newValue!;
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  readOnly: true,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  // itemRate.toString(),
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),

                  controller: rateController,
                  onSaved: (newValue) {
                    rateController.text = newValue!;
                  },
                  onChanged: (value) {
                    setState(() {
                      amountController.text =
                          (int.parse(value) * int.parse(qtyController.text))
                              .toString();

                      double amount = double.parse(amountController.text);
                      double tax = double.parse(taxController.text);
                      double gsts = (amount * tax) / 100;

                      sgstController.text = (gsts / 2).toString();
                      cgstController.text = (gsts / 2).toString();
                      netAmountController.text = (amount + gsts).toString();

                      widget.sgstControllerP.text = sgstController.text;
                      widget.cgstControllerP.text = cgstController.text;
                      widget.netAmountControllerP.text =
                          netAmountController.text;
                      persistentTotal = double.parse(netAmountController.text);
                      originalNetAmount = persistentTotal;
                      widget.qtyControllerP.text = qtyController.text;
                    });
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  // keyboardType: TextInputType.number,
                ),
              ),

              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: true,
                ),
              ),
              // Container(
              //   height: 20,
              //   width: MediaQuery.of(context).size.width * 0.061,
              //   decoration: const BoxDecoration(
              //     border: Border(
              //       bottom: BorderSide(),
              //       top: BorderSide(),
              //       left: BorderSide(),
              //     ),
              //   ),
              //   child: TextFormField(
              //     controller: discountController,
              //     keyboardType: TextInputType.number,
              //     onChanged: (value) {
              //       setState(() {
              //         double amount = double.parse(amountController.text);
              //         double discount = double.parse(discountController.text);
              //         double tax = double.parse(taxController.text);
              //         double gsts = (amount * tax) / 100;

              //         double netAmount = (amount - discount) + gsts;

              //         sgstController.text = (gsts / 2).toString();
              //         cgstController.text = (gsts / 2).toString();
              //         netAmountController.text = netAmount.toString();

              //         widget.sgstControllerP.text = sgstController.text;
              //         widget.cgstControllerP.text = cgstController.text;
              //         widget.netAmountControllerP.text =
              //             netAmountController.text;
              //         persistentTotal = double.parse(netAmountController.text);

              //         widget.qtyControllerP.text = qtyController.text;
              //       });
              //     },
              //     onSaved: (newValue) {
              //       discountController.text = newValue!;
              //     },
              //     textAlign: TextAlign.center,
              //     style: const TextStyle(fontWeight: FontWeight.bold),
              //     inputFormatters: <TextInputFormatter>[
              //       FilteringTextInputFormatter.allow(
              //         RegExp(r'^\d*\.?\d*$'),
              //       ),
              //     ],
              //   ),
              // ),

              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  onChanged: (value) {},
                  controller: taxController,
                  onSaved: (newValue) {
                    taxController.text = newValue!;
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: true,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: sgstController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: true,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: cgstController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: true,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: igstController,
                  onChanged: (value) {
                    widget.igstControllerP.text = igstController.text;
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^\d*\.?\d*$')), // Allow digits and a single decimal point
                  ],
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        left: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: InputBorder.none,
                  ),
                  controller: discountController,
                  onSaved: (newValue) {
                    discountController.text = newValue!;
                  },
                  onChanged: (value) {
                    double discount =
                        double.tryParse(discountController.text) ?? 0;
                    setState(() {
                      double finalAmount = originalNetAmount - discount;
                      netAmountController.text = finalAmount.toStringAsFixed(2);
                      widget.discountControllerP.text =
                          netAmountController.text;
                    });
                    _saveValues();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {}
                    return null;
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: false,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        left: BorderSide(),
                        top: BorderSide(),
                        right: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: netAmountController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: true,
                ),
              ),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.061,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(),
                        left: BorderSide(),
                        top: BorderSide(),
                        right: BorderSide())),
                child: TextFormField(
                  cursorHeight: 18,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  controller: sellingPriceController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  readOnly: false,
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                  height: 25,
                  child: IconButton(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      _saveValues();
                    },
                    icon: const Icon(
                      Icons.save,
                      size: 15,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                  height: 25,
                  child: IconButton(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: _deleteEntry,
                    icon: const Icon(
                      Icons.delete,
                      size: 15,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
