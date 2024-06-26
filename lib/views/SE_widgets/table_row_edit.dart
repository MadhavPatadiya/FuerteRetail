// ignore: file_names
import 'package:billingsphere/auth/providers/onchange_item_provider.dart';
import 'package:billingsphere/auth/providers/onchange_ledger_provider.dart';
import 'package:billingsphere/data/models/item/item_model.dart';
import 'package:billingsphere/data/models/measurementLimit/measurement_limit_model.dart';
import 'package:billingsphere/data/models/taxCategory/tax_category_model.dart';
import 'package:billingsphere/data/repository/item_repository.dart';
import 'package:billingsphere/data/repository/measurement_limit_repository.dart';
import 'package:billingsphere/data/repository/tax_category_repository.dart';
import 'package:billingsphere/views/SE_variables/SE_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:provider/provider.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/price/price_category.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/price_category_repository.dart';
import '../searchable_dropdown.dart';

class SEEntries extends StatefulWidget {
  const SEEntries(
      {super.key,
      required this.itemNameControllerP,
      required this.qtyControllerP,
      required this.rateControllerP,
      required this.unitControllerP,
      required this.amountControllerP,
      required this.taxControllerP,
      required this.sgstControllerP,
      required this.cgstControllerP,
      required this.igstControllerP,
      required this.netAmountControllerP,
      required this.discountControllerP,
      required this.onSaveValues,
      required this.onDelete,
      required this.entryId,
      required this.selectedLegerId,
      required this.stockControllerP,
      required this.serialNo
      // Create Cont
      });

  final TextEditingController itemNameControllerP;
  final TextEditingController stockControllerP;
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
  final String selectedLegerId;
  final Function(Map<String, dynamic>) onSaveValues;
  final Function(String) onDelete;
  final String entryId;
  final int serialNo;

  @override
  State<SEEntries> createState() => _SEEntriesState();
}

class _SEEntriesState extends State<SEEntries> {
  late TextEditingController itemNameController;
  late TextEditingController qtyController;
  late TextEditingController stockController;
  late TextEditingController discountController;
  late TextEditingController rateController;
  late TextEditingController unitController;
  late TextEditingController amountController;
  late TextEditingController taxController;
  late TextEditingController sgstController;
  late TextEditingController cgstController;
  late TextEditingController igstController;
  late TextEditingController netAmountController;

  // Backend Services/Repositories
  ItemsService itemsService = ItemsService();
  TaxRateService taxRateService = TaxRateService();
  PriceCategoryRepository pricetypeService = PriceCategoryRepository();
  MeasurementLimitService measurementService = MeasurementLimitService();
  final TextEditingController searchController = TextEditingController();
  double originalNetAmount = 0.0;

  // Variables
  String? selectedItemId;
  String? selectedItemId2;
  String? selectedTaxRateId;
  String? selectedPriceTypeId;
  String? selectedmeasurementId;
  double itemRate = 0.0;
  double stock = 0.0;
  // List of items
  List<Item> itemsList = [];
  List<TaxRate> taxLists = [];
  List<MeasurementLimit> measurement = [];

  Ledger? _fetchedSingleLedger;

  //Ledger
  LedgerService ledgerService = LedgerService();
  String? selectedLedgerName;
  String? selectedPersonType;
  List<Ledger> suggestionItems5 = [];
  List<PriceCategory> pricecategory = [];

  // Future Functions
  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();
      items.insert(
          0,
          Item(
            id: "",
            itemGroup: "",
            itemBrand: "",
            itemName: "",
            printName: "",
            codeNo: "",
            barcode: "",
            taxCategory: "",
            hsnCode: "",
            storeLocation: "",
            measurementUnit: "",
            secondaryUnit: "",
            minimumStock: 0,
            maximumStock: 0,
            monthlySalesQty: 0,
            date: "",
            dealer: 0,
            subDealer: 0,
            retail: 0,
            mrp: 0,
            openingStock: "",
            status: "",
            price: 0,
            openingBalance: [],
            openingBalanceAmt: 0.00,
            openingBalanceQty: 0.00,
          ));
      final TaxRate? matchingTax =
          taxLists.firstWhereOrNull((tax) => tax.id == items.first.taxCategory);
      if (matchingTax != null) {
        setState(() {
          taxController.text = items.isNotEmpty ? matchingTax.rate : '0';
          widget.taxControllerP.text = taxController.text;
        });
      }

      final MeasurementLimit? matchingMeasurement = measurement
          .firstWhereOrNull((meu) => meu.id == items.first.measurementUnit);
      if (matchingMeasurement != null) {
        setState(() {
          unitController.text =
              items.isNotEmpty ? matchingMeasurement.measurement : '0';
          widget.unitControllerP.text = unitController.text;
        });
      }

      final ledgers =
          await ledgerService.fetchLedgerById(widget.selectedLegerId);

      // cat = ledgers!.priceListCategory;

      setState(() {
        itemsList = items;
        _fetchedSingleLedger = ledgers;
        selectedItemId = widget.itemNameControllerP.text.isNotEmpty
            ? widget.itemNameControllerP.text
            : items.isNotEmpty
                ? items.first.id
                : null;
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
      });
    } catch (error) {
      print('Failed to fetch items: $error');
    }
  }

  void _saveValues() {
    final values = {
      'uniqueKey': widget.entryId,
      'itemName': itemNameController.text,
      'qty': qtyController.text,
      'unit': unitController.text,
      'rate': rateController.text,
      'unit2': unitController.text,
      'amount': amountController.text,
      'tax': taxController.text,
      'discount': discountController.text,
      'sgst': sgstController.text,
      'cgst': cgstController.text,
      'igst': igstController.text,
      'netAmount': netAmountController.text,
    };

    // Fluttertoast.showToast(
    //   msg: "Values added to list successfully!",
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.CENTER_RIGHT,
    //   webPosition: "right",
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.black,
    //   textColor: Colors.white,
    // );

    widget.onSaveValues(values);
  }

  void _initializeData() async {
    await fetchAndSetTaxRates();
    await fetchItems();
    await fetchMeasurementLimit();
    await fetchPriceCategoryType();
  }

  Future<void> fetchAndSetTaxRates() async {
    try {
      final List<TaxRate> taxRates = await taxRateService.fetchTaxRates();

      setState(() {
        taxLists = taxRates;
        selectedTaxRateId = taxLists.isNotEmpty ? taxLists.first.id : null;
      });
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  Future<void> fetchPriceCategoryType() async {
    try {
      final List<PriceCategory> priceType =
          await pricetypeService.fetchPriceCategories();

      setState(() {
        pricecategory = priceType;
        selectedPriceTypeId =
            pricecategory.isNotEmpty ? pricecategory.first.id : null;
      });
    } catch (error) {
      print('Failed to fetch Price Type: $error');
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
      });
    } catch (error) {
      print('Failed to fetch Tax Rates: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    itemNameController =
        TextEditingController(text: widget.itemNameControllerP.text);
    qtyController = TextEditingController(text: widget.qtyControllerP.text);
    stockController = TextEditingController(text: widget.stockControllerP.text);
    rateController = TextEditingController(text: widget.rateControllerP.text);
    unitController = TextEditingController(text: widget.unitControllerP.text);
    amountController =
        TextEditingController(text: widget.amountControllerP.text);
    taxController = TextEditingController(text: widget.taxControllerP.text);
    sgstController = TextEditingController(text: widget.sgstControllerP.text);
    cgstController = TextEditingController(text: widget.cgstControllerP.text);
    igstController = TextEditingController(text: widget.igstControllerP.text);
    netAmountController =
        TextEditingController(text: widget.netAmountControllerP.text);
    discountController =
        TextEditingController(text: widget.discountControllerP.text);

    _initializeData();
  }

  // Get the ledger and store in a variable
  String cat = '';

  @override
  void dispose() {
    itemNameController.dispose();
    qtyController.dispose();
    stockController.dispose();
    rateController.dispose();
    unitController.dispose();
    amountController.dispose();
    taxController.dispose();
    discountController.dispose();
    sgstController.dispose();
    cgstController.dispose();
    igstController.dispose();
    netAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider =
        Provider.of<OnChangeItenProvider>(context, listen: false);
    return Row(
      children: [
        Consumer<OnChangeLedgerProvider>(
          builder: (context, value, _) {
            cat = value.ledger;
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
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width * 0.21,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(),
                                top: BorderSide(),
                                left: BorderSide())),
                        child: SearchableDropDown(
                          controller: searchController,
                          searchController: searchController,
                          value: selectedItemId,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedItemId = newValue;

                              qtyController.text = '';
                              discountController.text = '0.00';

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
                                  taxController.text = item.taxCategory;
                                  widget.taxControllerP.text =
                                      taxController.text;
                                }
                              }

                              for (Item item in itemsList) {
                                if (item.id == selectedItemId) {
                                  newId2 = item.measurementUnit;
                                  unitController.text = item.measurementUnit;
                                  widget.unitControllerP.text =
                                      unitController.text;

                                  stockController.text =
                                      item.maximumStock.toString();

                                  print(stockController.text);
                                }
                              }

                              for (TaxRate tax in taxLists) {
                                if (tax.id == newId) {
                                  setState(() {
                                    taxController.text =
                                        items.isNotEmpty ? tax.rate : '0';
                                    widget.taxControllerP.text =
                                        taxController.text;
                                  });
                                }
                              }
                              for (MeasurementLimit meu in measurement) {
                                if (meu.id == newId2) {
                                  setState(() {
                                    unitController.text = items.isNotEmpty
                                        ? meu.measurement
                                        : '0';
                                    widget.unitControllerP.text =
                                        unitController.text;
                                  });
                                }
                              }
                              // Find the selected item
                              Item? selectedItem = itemsList.firstWhere(
                                (item) => item.id == selectedItemId,
                              );

                              cat = _fetchedSingleLedger!.priceListCategory;
                              igstController.text = '0.0';

                              if (selectedItemId != null) {
                                switch (cat) {
                                  case 'DEALER':
                                    rateController.text =
                                        selectedItem.dealer.toString();
                                    break;
                                  case 'SUB DEALER':
                                    rateController.text =
                                        selectedItem.subDealer.toString();
                                    break;
                                  case 'RETAIL':
                                    rateController.text =
                                        selectedItem.retail.toString();
                                    break;
                                  case 'MRP':
                                    rateController.text =
                                        selectedItem.mrp.toString();
                                    break;
                                  default:
                                    rateController.text = '0.0';
                                }
                              }
                              itemProvider.updateItemID(selectedItemId!);
                            });
                          },
                          items: itemsList.map((Item items) {
                            return DropdownMenuItem<String>(
                              value: items.id,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            final itemName = itemsList
                                .firstWhere((e) => e.id == item.value)
                                .itemName;
                            return itemName
                                .toLowerCase()
                                .contains(searchValue.toLowerCase());
                          },
                        ),

                        // child: DropdownButton<String>(
                        //   value: selectedItemId,
                        //   underline: Container(),
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       selectedItemId = newValue;

                        //       qtyController.text = '';

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
                        //           taxController.text = item.taxCategory;
                        //           widget.taxControllerP.text =
                        //               taxController.text;
                        //         }
                        //       }

                        //       for (Item item in itemsList) {
                        //         if (item.id == selectedItemId) {
                        //           newId2 = item.measurementUnit;
                        //           unitController.text = item.measurementUnit;
                        //           widget.unitControllerP.text =
                        //               unitController.text;

                        //           stockController.text =
                        //               item.maximumStock.toString();

                        //           print(stockController.text);
                        //         }
                        //       }

                        //       for (TaxRate tax in taxLists) {
                        //         if (tax.id == newId) {
                        //           setState(() {
                        //             taxController.text =
                        //                 items.isNotEmpty ? tax.rate : '0';
                        //             widget.taxControllerP.text =
                        //                 taxController.text;
                        //           });
                        //         }
                        //       }
                        //       for (MeasurementLimit meu in measurement) {
                        //         if (meu.id == newId2) {
                        //           setState(() {
                        //             unitController.text = items.isNotEmpty
                        //                 ? meu.measurement
                        //                 : '0';
                        //             widget.unitControllerP.text =
                        //                 unitController.text;
                        //           });
                        //         }
                        //       }
                        //       // Find the selected item
                        //       Item? selectedItem = itemsList.firstWhere(
                        //         (item) => item.id == selectedItemId,
                        //       );

                        //       cat = _fetchedSingleLedger!.priceListCategory;
                        //       igstController.text = '0.0';

                        //       if (selectedItemId != null) {
                        //         switch (cat) {
                        //           case 'DEALER':
                        //             rateController.text =
                        //                 selectedItem.dealer.toString();
                        //             break;
                        //           case 'SUB DEALER':
                        //             rateController.text =
                        //                 selectedItem.subDealer.toString();
                        //             break;
                        //           case 'RETAIL':
                        //             rateController.text =
                        //                 selectedItem.retail.toString();
                        //             break;
                        //           case 'MRP':
                        //             rateController.text =
                        //                 selectedItem.mrp.toString();
                        //             break;
                        //           default:
                        //             rateController.text = '0.0';
                        //         }
                        //       }
                        //       itemProvider.updateItemID(selectedItemId!);
                        //     });
                        //   },
                        //   isDense: true,
                        //   isExpanded: true,
                        //   items: itemsList.map((Item items) {
                        //     return DropdownMenuItem<String>(
                        //       value: items.id,
                        //       child: Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
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
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          cursorHeight: 18,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                          ),
                          controller: qtyController,
                          onChanged: (value) {
                            double qty = double.tryParse(value) ?? 0;
                            double stock =
                                double.tryParse(stockController.text) ?? 0;
                            if (qty > stock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please Add Stock ${stockController.text} Left.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              qtyController.text = stockController.text;
                            } else {
                              double rate =
                                  double.tryParse(rateController.text) ?? 0;
                              double tax =
                                  double.tryParse(taxController.text) ?? 0;

                              double amount = qty * rate;
                              double taxAmount = (tax / 100) * amount;

                              double gst = taxAmount / 2;
                              double totalAmount = amount;
                              double amountbrforetax = amount - taxAmount;
                              discountController.text = '0.00';
                              setState(() {
                                amountController.text =
                                    amountbrforetax.toStringAsFixed(2);
                                sgstController.text = gst.toString();
                                cgstController.text = gst.toString();
                                originalNetAmount = totalAmount;

                                netAmountController.text =
                                    totalAmount.toString();
                                widget.amountControllerP.text =
                                    amountController.text;
                                widget.sgstControllerP.text =
                                    sgstController.text;
                                widget.cgstControllerP.text =
                                    cgstController.text;
                                widget.netAmountControllerP.text =
                                    netAmountController.text;
                                widget.qtyControllerP.text = qtyController.text;
                                widget.rateControllerP.text =
                                    rateController.text;
                              });
                            }
                            _saveValues();
                          },
                          keyboardType: TextInputType.number,
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
                          readOnly: true,

                          onSaved: (newValue) {
                            rateController.text = newValue!;
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
                          controller: unitController,
                          readOnly: true,
                          onSaved: (newValue) {
                            unitController.text = newValue!;
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          onChanged: (value) {},
                          controller: taxController,
                          readOnly: true,
                          onSaved: (newValue) {
                            taxController.text = newValue!;
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          readOnly: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          readOnly: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                              left: BorderSide()),
                        ),

                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')),
                          ],
                          cursorHeight: 18,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                          ),
                          controller: discountController,
                          readOnly: false,
                          onSaved: (newValue) {
                            discountController.text = newValue!;
                          },
                          onChanged: (value) {
                            double discount =
                                double.tryParse(discountController.text) ?? 0;
                            setState(() {
                              double finalAmount = originalNetAmount - discount;
                              netAmountController.text =
                                  finalAmount.toStringAsFixed(2);
                              widget.discountControllerP.text =
                                  netAmountController.text;
                            });
                            _saveValues();
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // child: TextFormField(
                        //   controller: unitController,
                        //   readOnly: true,
                        //   onSaved: (newValue) {
                        //     unitController.text = newValue!;
                        //   },
                        //   textAlign: TextAlign.center,
                        //   style: const TextStyle(fontWeight: FontWeight.bold),
                        // ),
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
                          readOnly: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
