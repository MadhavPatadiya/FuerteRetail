// ignore: file_names
// ignore_for_file: unnecessary_null_comparison

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
import 'package:provider/provider.dart';

import '../../auth/providers/onchange_ledger_provider.dart';
import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/price/price_category.dart';
import '../../data/models/stock/product_stock_model.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/price_category_repository.dart';
import '../../data/repository/product_stock_repository.dart';
import '../searchable_dropdown.dart';

class IEntries extends StatefulWidget {
  final int serialNumber;

  const IEntries({
    super.key,
    required this.serialNumber,
    required this.itemNameControllerP,
    required this.qtyControllerP,
    required this.rateControllerP,
    required this.unitControllerP,
    required this.netAmountControllerP,
    required this.selectedLegerId,
    required this.entryId,
    required this.onSaveValues,
  });

  final TextEditingController itemNameControllerP;
  final TextEditingController qtyControllerP;
  final TextEditingController rateControllerP;
  final TextEditingController unitControllerP;
  final TextEditingController netAmountControllerP;
  final String selectedLegerId;
  final String entryId;
  final Function(Map<String, dynamic>) onSaveValues;

  @override
  State<IEntries> createState() => _IEntriesState();
}

class _IEntriesState extends State<IEntries> {
  late TextEditingController itemNameController;
  late TextEditingController qtyController;
  late TextEditingController rateController;
  late TextEditingController unitController;
  late TextEditingController netAmountController;

  // Backend Services/Repositories
  ItemsService itemsService = ItemsService();
  TaxRateService taxRateService = TaxRateService();
  PriceCategoryRepository pricetypeService = PriceCategoryRepository();
  MeasurementLimitService measurementService = MeasurementLimitService();
  final TextEditingController searchController = TextEditingController();

  // Variables
  String? selectedItemId;
  String? selectedTaxRateId;
  String? selectedPriceTypeId;
  String? selectedmeasurementId;
  double itemRate = 0.0;
  double stock = 0.0;
  double price = 0.0;
  // List of items
  List<Item> itemsList = [];
  List<TaxRate> taxLists = [];
  List<MeasurementLimit> measurement = [];
  bool isLoading = false;

  ProductStockService productStockService = ProductStockService();
  List<ProductStockModel> fectedStocks = [];
  List<String>? company = [];

  //Ledger
  LedgerService ledgerService = LedgerService();
  String? selectedLedgerName;
  String? selectedPersonType;
  List<Ledger> suggestionItems5 = [];
  List<PriceCategory> pricecategory = [];

  Future<void> fetchMeasurementLimit() async {
    try {
      final List<MeasurementLimit> measurements =
          await measurementService.fetchMeasurementLimits();

      setState(() {
        measurement = measurements;
        // selectedmeasurementId =
        //     measurement.isNotEmpty ? measurement.first.id : null;
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

  // Future Functions
  Future<void> fetchItems() async {
    try {
      final List<Item> items = await itemsService.fetchItems();

      items.insert(
        0,
        Item(
          id: '',
          itemName: '',
          itemGroup: '',
          itemBrand: '',
          hsnCode: '',
          mrp: 0.0,
          taxCategory: '',
          measurementUnit: '',
          secondaryUnit: '',
          barcode: '',
          codeNo: '0',
          date: DateTime.now().toString(),
          dealer: 0,
          maximumStock: 0,
          minimumStock: 0,
          monthlySalesQty: 0,
          openingStock: '0',
          price: 0,
          printName: '',
          retail: 0,
          status: '',
          storeLocation: '',
          subDealer: 0,
          openingBalance: [],
          openingBalanceAmt: 0.00,
          openingBalanceQty: 0.00,
        ),
      );

      setState(() {
        itemsList = items;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  void _saveValues() {
    final values = {
      'uniqueKey': widget.entryId,
      'itemName': itemNameController.text,
      'qty': qtyController.text,
      'rate': rateController.text,
      'unit': unitController.text,
      'netAmount': netAmountController.text,
    };

    widget.onSaveValues(values);
  }

  Future<void> fetchProducts() async {
    await fetchItems();
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchMeasurementLimit();
    itemNameController = TextEditingController();
    qtyController = TextEditingController();
    rateController = TextEditingController();
    unitController = TextEditingController();
    netAmountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Consumer<OnChangeLedgerProvider>(
          builder: (context, value, _) {
            final cat = value.ledger;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.023,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                          // top: BorderSide(),
                          left: BorderSide(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          '${widget.serialNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.25,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: SearchableDropDown(
                        controller: searchController,
                        searchController: searchController,
                        value: selectedItemId,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedItemId = newValue;
                            itemNameController.text = selectedItemId!;
                            widget.itemNameControllerP.text =
                                itemNameController.text;
                            String newId = '';
                            String newId2 = '';
                            for (Item item in itemsList) {
                              if (item.id == selectedItemId) {
                                newId = item.mrp.toString();
                                newId2 = item.measurementUnit;
                                stock = item.maximumStock as double;
                              }
                            }

                            for (var element in fectedStocks) {
                              if (company![0] == element.company) {
                                if (element.product == selectedItemId) {
                                  stock = element.quantity as double;
                                }
                              }
                            }

                            rateController.text = newId;
                            widget.rateControllerP.text = rateController.text;

                            for (MeasurementLimit meu in measurement) {
                              if (meu.id == newId2) {
                                setState(() {
                                  unitController.text =
                                      items.isNotEmpty ? meu.measurement : '0';
                                  widget.unitControllerP.text =
                                      unitController.text;
                                });
                              }
                            }

                            // itemProvider.updateItemID(selectedItemId!);
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
                          final peLedger = itemsList
                              .firstWhere((e) => e.id == item.value)
                              .itemName;
                          return peLedger
                              .toLowerCase()
                              .contains(searchValue.toLowerCase());
                        },
                      ),

                      //  DropdownButton<String>(
                      //   value: selectedItemId,
                      //   underline: Container(),
                      //   onChanged: (String? newValue) {
                      //     setState(() {
                      //       selectedItemId = newValue;

                      //       itemNameController.text = selectedItemId!;
                      //       widget.itemNameControllerP.text =
                      //           itemNameController.text;

                      //       String newId = '';
                      //       String newId2 = '';

                      //       for (Item item in itemsList) {
                      //         if (item.id == selectedItemId) {
                      //           newId = item.mrp.toString();
                      //           newId2 = item.measurementUnit;
                      //           stock = item.maximumStock as double;
                      //         }
                      //       }

                      //       for (var element in fectedStocks) {
                      //         if (company![0] == element.company) {
                      //           if (element.product == selectedItemId) {
                      //             stock = element.quantity as double;
                      //           }
                      //         }
                      //       }

                      //       rateController.text = newId;
                      //       widget.rateControllerP.text = rateController.text;

                      //       for (MeasurementLimit meu in measurement) {
                      //         if (meu.id == newId2) {
                      //           setState(() {
                      //             unitController.text =
                      //                 items.isNotEmpty ? meu.measurement : '0';
                      //             widget.unitControllerP.text =
                      //                 unitController.text;
                      //           });
                      //         }
                      //       }

                      //       // itemProvider.updateItemID(selectedItemId!);
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
                    ),
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        cursorHeight: 18,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                        ),
                        controller: qtyController,
                        onChanged: (value) {
                          double qty = double.parse(value);
                          if (qty > stock || qty <= 0) {
                            Fluttertoast.showToast(
                                msg:
                                    'Quantity should not be greater than stock and less/equal than 0',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            qtyController.text = stock.toString();
                          }
                          double rate = double.parse(rateController.text);
                          double netAmount = qty * rate;
                          netAmountController.text = netAmount.toString();
                          widget.qtyControllerP.text = qtyController.text;
                          widget.netAmountControllerP.text =
                              netAmountController.text;

                          _saveValues();
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        cursorHeight: 18,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
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
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        cursorHeight: 18,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: rateController,
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              left: BorderSide(),
                              // top: BorderSide(),
                              right: BorderSide())),
                      child: TextFormField(
                        cursorHeight: 18,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                        ),
                        controller: netAmountController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
