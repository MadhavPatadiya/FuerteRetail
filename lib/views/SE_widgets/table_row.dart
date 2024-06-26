// ignore: file_names
// ignore_for_file: unnecessary_null_comparison

import 'package:billingsphere/data/models/item/item_model.dart';
import 'package:billingsphere/data/models/measurementLimit/measurement_limit_model.dart';
import 'package:billingsphere/data/models/taxCategory/tax_category_model.dart';
import 'package:billingsphere/data/repository/item_repository.dart';
import 'package:billingsphere/views/SE_variables/SE_variables.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/onchange_item_provider.dart';
import '../../auth/providers/onchange_ledger_provider.dart';
import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/price/price_category.dart';
import '../../data/repository/ledger_repository.dart';

class SEntries extends StatefulWidget {
  final int serialNumber;

  const SEntries({
    super.key,
    required this.serialNumber,
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
    required this.itemsList,
    required this.measurement,
    required this.taxLists,
    required this.pricecategory,
    // Create Cont
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
  final String selectedLegerId;
  final Function(Map<String, dynamic>) onSaveValues;
  final Function(String) onDelete;
  final String entryId;
  final List<Item> itemsList;
  final List<MeasurementLimit> measurement;
  final List<TaxRate> taxLists;
  final List<PriceCategory> pricecategory;
  @override
  State<SEntries> createState() => _SEntriesState();
}

class _SEntriesState extends State<SEntries> {
  late TextEditingController itemNameController;
  late TextEditingController qtyController;
  late TextEditingController stockController;
  late TextEditingController discountController;
  late TextEditingController priceController;
  late TextEditingController rateController;
  late TextEditingController unitController;
  late TextEditingController amountController;
  late TextEditingController taxController;
  late TextEditingController sgstController;
  late TextEditingController cgstController;
  final TextEditingController igstController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController price2Controller = TextEditingController();
  final TextEditingController discountRateController = TextEditingController();
  late TextEditingController netAmountController;
  double originalNetAmount = 0.0;

  // Backend Services/Repositories
  ItemsService itemsService = ItemsService();

  // Variables
  String? selectedItemId;
  String? selectedTaxRateId;
  String? selectedPriceTypeId;
  String? selectedmeasurementId;
  double itemRate = 0.0;
  double stock = 0.0;
  double price = 0.0;
  bool isLoading = false;

  //Ledger
  LedgerService ledgerService = LedgerService();
  String? selectedLedgerName;
  String? selectedPersonType;
  List<Ledger> suggestionItems5 = [];
  List<PriceCategory> pricecategory = [];
  List<String>? company = [];

  void _saveValues() {
    final values = {
      'uniqueKey': widget.entryId,
      'itemName': itemNameController.text,
      'qty': qtyController.text,
      'unit': unitController.text,
      'rate': price2Controller.text,
      'unit2': unitController.text,
      'amount': amountController.text,
      'tax': taxController.text,
      'discount': discountRateController.text,
      'sgst': sgstController.text,
      'cgst': cgstController.text,
      'igst': igstController.text,
      'netAmount': netAmountController.text,
    };

    widget.onSaveValues(values);
  }

  @override
  void initState() {
    super.initState();

    itemNameController = TextEditingController();
    qtyController = TextEditingController();
    stockController = TextEditingController();
    discountController = TextEditingController();
    priceController = TextEditingController();
    rateController = TextEditingController();
    unitController = TextEditingController();
    amountController = TextEditingController();
    taxController = TextEditingController();
    sgstController = TextEditingController();
    cgstController = TextEditingController();
    netAmountController = TextEditingController();
  }

  @override
  void dispose() {
    qtyController.dispose();
    rateController.dispose();
    amountController.dispose();
    priceController.dispose();
    taxController.dispose();
    sgstController.dispose();
    cgstController.dispose();
    netAmountController.dispose();
    stockController.dispose();
    discountController.dispose();
    unitController.dispose();
    itemNameController.dispose();
    igstController.dispose();
    Provider.of<OnChangeLedgerProvider>(context, listen: false).clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider =
        Provider.of<OnChangeItenProvider>(context, listen: false);
    // final ledgerProvider =
    //     Provider.of<OnChangeLedgerProvider>(context, listen: false);

    return Row(
      children: [
        Consumer<OnChangeLedgerProvider>(
          builder: (context, value, _) {
            // Get the ledger and store in a variable
            final cat = value.ledger;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.023,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                          // top: BorderSide(),
                          left: BorderSide(),
                        ),
                      ),
                      child: Text(
                        '${widget.serialNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.21,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: widget.itemsList.map((Item items) {
                            return DropdownMenuItem<String>(
                              value: items.id,
                              child: Text(
                                items.itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          value: selectedItemId,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedItemId = newValue;
                              selectedmeasurementId = newValue;

                              itemNameController.text = selectedItemId!;
                              widget.itemNameControllerP.text =
                                  itemNameController.text;

                              igstController.text = '0.00';
                              discountController.text = '0.00';

                              String newId = '';
                              String newId2 = '';

                              for (Item item in widget.itemsList) {
                                if (item.id == selectedItemId) {
                                  newId = item.taxCategory;
                                }
                              }

                              for (Item item in widget.itemsList) {
                                if (item.id == selectedmeasurementId) {
                                  newId2 = item.measurementUnit;
                                }
                              }

                              for (TaxRate tax in widget.taxLists) {
                                if (tax.id == newId) {
                                  setState(() {
                                    taxController.text =
                                        items.isNotEmpty ? tax.rate : '0';
                                    widget.taxControllerP.text =
                                        taxController.text;
                                  });
                                }
                              }
                              for (MeasurementLimit meu in widget.measurement) {
                                if (meu.id == newId2) {
                                  print('Measurement: ${meu.id}');
                                  setState(() {
                                    unitController.text = items.isNotEmpty
                                        ? meu.measurement
                                        : '0';
                                    widget.unitControllerP.text =
                                        unitController.text;
                                  });
                                }
                              }

                              var item = widget.itemsList.firstWhere(
                                (e) => e.id == selectedItemId,
                              );
                              // rateController.text = itemRate.toString();
                              stockController.text = item != null
                                  ? item.maximumStock.toString()
                                  : '0.0';

                              // priceController.text = price.toString();
                              // Check if the cat from the consumer is DEALER or RETAIL, THEN PASS IT TO PRICE CONTROLLER
                              if (selectedItemId != null) {
                                switch (cat) {
                                  case 'DEALER':
                                    // Find the item with the selectedItemId and get the dealer price
                                    var item = widget.itemsList.firstWhere(
                                      (e) => e.id == selectedItemId,
                                    );
                                    priceController.text = item != null
                                        ? item.dealer.toString()
                                        : '0.0';
                                    break;
                                  case 'SUB DEALER':
                                    // Find the item with the selectedItemId and get the sub dealer price
                                    var item = widget.itemsList.firstWhere(
                                      (e) => e.id == selectedItemId,
                                    );
                                    priceController.text = item != null
                                        ? item.subDealer.toString()
                                        : '0.0';
                                    break;
                                  case 'RETAIL':
                                    // Find the item with the selectedItemId and get the retail price
                                    var item = widget.itemsList.firstWhere(
                                      (e) => e.id == selectedItemId,
                                    );
                                    priceController.text = item != null
                                        ? item.retail.toString()
                                        : '0.0';
                                    break;
                                  case 'MRP':
                                    // Find the item with the selectedItemId and get the MRP
                                    var item = widget.itemsList.firstWhere(
                                      (e) => e.id == selectedItemId,
                                    );
                                    priceController.text = item != null
                                        ? item.mrp.toString()
                                        : '0.0';
                                    break;
                                  default:
                                    priceController.text = '0.0';
                                }
                              }
                              itemProvider.updateItemID(selectedItemId!);
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            height: 40,
                            width: 200,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: searchController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                onChanged: (value) {},
                                expands: true,
                                maxLines: null,
                                controller: searchController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search for an item...',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (DropdownMenuItem<String> item,
                                String searchValue) {
                              final itemName = widget.itemsList
                                  .firstWhere((e) => e.id == item.value)
                                  .itemName;
                              return itemName
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase());
                            },
                          ),
                        ),
                      ),

                      // child: DropdownButton<String>(
                      //   value: selectedItemId,
                      //   underline: Container(),
                      //   onChanged: (String? newValue) {
                      //     setState(() {
                      //       selectedItemId = newValue;
                      //       selectedmeasurementId = newValue;
                      //       itemNameController.text = selectedItemId!;
                      //       widget.itemNameControllerP.text =
                      //           itemNameController.text;
                      //       igstController.text = '0.00';
                      //       String newId = '';
                      //       String newId2 = '';
                      //       for (Item item in widget.itemsList) {
                      //         if (item.id == selectedItemId) {
                      //           newId = item.taxCategory;
                      //         }
                      //       }
                      //       for (Item item in widget.itemsList) {
                      //         if (item.id == selectedmeasurementId) {
                      //           newId2 = item.measurementUnit;
                      //         }
                      //       }
                      //       for (TaxRate tax in widget.taxLists) {
                      //         if (tax.id == newId) {
                      //           setState(() {
                      //             taxController.text =
                      //                 items.isNotEmpty ? tax.rate : '0';
                      //             widget.taxControllerP.text =
                      //                 taxController.text;
                      //           });
                      //         }
                      //       }
                      //       for (MeasurementLimit meu in widget.measurement) {
                      //         if (meu.id == newId2) {
                      //           print('Measurement: ${meu.id}');
                      //           setState(() {
                      //             unitController.text =
                      //                 items.isNotEmpty ? meu.measurement : '0';
                      //             widget.unitControllerP.text =
                      //                 unitController.text;
                      //           });
                      //         }
                      //       }
                      //       var item = widget.itemsList.firstWhere(
                      //         (e) => e.id == selectedItemId,
                      //       );
                      //       // rateController.text = itemRate.toString();
                      //       stockController.text = item != null
                      //           ? item.maximumStock.toString()
                      //           : '0.0';
                      //       // priceController.text = price.toString();
                      //       // Check if the cat from the consumer is DEALER or RETAIL, THEN PASS IT TO PRICE CONTROLLER
                      //       if (selectedItemId != null) {
                      //         switch (cat) {
                      //           case 'DEALER':
                      //             // Find the item with the selectedItemId and get the dealer price
                      //             var item = widget.itemsList.firstWhere(
                      //               (e) => e.id == selectedItemId,
                      //             );
                      //             priceController.text = item != null
                      //                 ? item.dealer.toString()
                      //                 : '0.0';
                      //             break;
                      //           case 'SUB DEALER':
                      //             // Find the item with the selectedItemId and get the sub dealer price
                      //             var item = widget.itemsList.firstWhere(
                      //               (e) => e.id == selectedItemId,
                      //             );
                      //             priceController.text = item != null
                      //                 ? item.subDealer.toString()
                      //                 : '0.0';
                      //             break;
                      //           case 'RETAIL':
                      //             // Find the item with the selectedItemId and get the retail price
                      //             var item = widget.itemsList.firstWhere(
                      //               (e) => e.id == selectedItemId,
                      //             );
                      //             priceController.text = item != null
                      //                 ? item.retail.toString()
                      //                 : '0.0';
                      //             break;
                      //           case 'MRP':
                      //             // Find the item with the selectedItemId and get the MRP
                      //             var item = widget.itemsList.firstWhere(
                      //               (e) => e.id == selectedItemId,
                      //             );
                      //             priceController.text = item != null
                      //                 ? item.mrp.toString()
                      //                 : '0.0';
                      //             break;
                      //           default:
                      //             priceController.text = '0.0';
                      //         }
                      //       }
                      //       itemProvider.updateItemID(selectedItemId!);
                      //     });
                      //   },
                      //   isDense: true,
                      //   isExpanded: true,
                      //   items: widget.itemsList.map((Item items) {
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
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.061,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        cursorHeight: 18,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                            double rateWithTax = double.tryParse(
                                    priceController.text.toString()) ??
                                0;
                            double tax =
                                double.tryParse(taxController.text) ?? 0;
                            double qty =
                                double.tryParse(qtyController.text) ?? 0;

                            // Calculate base rate (excluding tax)
                            double baseRate = rateWithTax / (1 + (tax / 100));

                            // Calculate amount before tax
                            double amountBeforeTax = qty * baseRate;

                            // Calculate the tax amount
                            double taxAmount = (tax / 100) * amountBeforeTax;

                            // Calculate the GST (split the tax amount into two equal parts)
                            double gst = taxAmount / 2;

                            // Calculate the total amount including tax
                            double totalAmount = amountBeforeTax + taxAmount;

                            setState(() {
                              price2Controller.text =
                                  baseRate.toStringAsFixed(2);

                              amountController.text =
                                  amountBeforeTax.toStringAsFixed(2);
                              sgstController.text = gst.toStringAsFixed(2);
                              cgstController.text = gst.toStringAsFixed(2);
                              netAmountController.text =
                                  totalAmount.toStringAsFixed(2);
                              originalNetAmount = totalAmount;
                              widget.amountControllerP.text =
                                  amountController.text;
                              widget.sgstControllerP.text = sgstController.text;
                              widget.cgstControllerP.text = cgstController.text;
                              widget.netAmountControllerP.text =
                                  netAmountController.text;
                              widget.qtyControllerP.text = qtyController.text;
                              widget.rateControllerP.text = rateController.text;
                              discountController.text = '0.00';
                              discountRateController.text = '0.00';
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
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: unitController,
                        readOnly: true,
                        onSaved: (newValue) {
                          unitController.text = newValue!;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
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
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        // itemRate.toString(),

                        controller: price2Controller,
                        readOnly: true,

                        onSaved: (newValue) {
                          price2Controller.text = newValue!;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),

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
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: amountController,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.061,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: discountRateController,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.041,
                      // padding: const EdgeInsets.only(left: 0.0, bottom: 4.0),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(),
                            // top: BorderSide(),
                            left: BorderSide()),
                      ),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$')),
                        ],
                        controller: discountController,
                        readOnly: false,
                        onSaved: (newValue) {
                          discountController.text = newValue!;
                        },
                        onChanged: (value) {
                          double discountPercentage =
                              double.tryParse(discountController.text) ?? 0;
                          double qty = double.tryParse(qtyController.text) ?? 0;
                          double rateWithTax = double.tryParse(
                                  priceController.text.toString()) ??
                              0;
                          double tax = double.tryParse(taxController.text) ?? 0;
                          // Calculate base rate (excluding tax)
                          double baseRate = rateWithTax / (1 + (tax / 100));
                          print('baseRate $baseRate');
                          // Calculate the discount amount as a percentage of the base rate
                          double discountAmountPerUnit =
                              baseRate * (discountPercentage / 100);
                          double totalDiscountAmount =
                              discountAmountPerUnit * qty;
                          print('discountAmountPerUnit $discountAmountPerUnit');
                          print('totalDiscountAmount $totalDiscountAmount');

                          // Calculate the rate after applying the discount percentage
                          double rateAfterDiscountPerUnit =
                              baseRate - discountAmountPerUnit;
                          print(
                              'rateAfterDiscountPerUnit $rateAfterDiscountPerUnit');

                          // Calculate the amount before tax
                          double amountBeforeTax =
                              qty * rateAfterDiscountPerUnit;
                          print('amountBeforeTax $amountBeforeTax');

                          // Calculate the total tax amount on the amount before tax
                          double taxAmount = (tax / 100) * amountBeforeTax;
                          print('taxAmount $taxAmount');

                          // Calculate the final amount including tax
                          double amountAfterTax = amountBeforeTax + taxAmount;
                          print('amountAfterTax $amountAfterTax');

                          // Split the tax amount into SGST and CGST
                          double gst = taxAmount / 2;

                          setState(() {
                            amountController.text =
                                amountBeforeTax.toStringAsFixed(2);
                            netAmountController.text =
                                amountAfterTax.toStringAsFixed(2);
                            sgstController.text = gst.toStringAsFixed(2);
                            cgstController.text = gst.toStringAsFixed(2);
                            discountRateController.text =
                                totalDiscountAmount.toStringAsFixed(2);
                          });
                          _saveValues();
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
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
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        onChanged: (value) {},
                        controller: taxController,
                        readOnly: true,
                        onSaved: (newValue) {
                          taxController.text = newValue!;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
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
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: sgstController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.061,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: cgstController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.061,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              // top: BorderSide(),
                              left: BorderSide())),
                      child: TextFormField(
                        controller: igstController,
                        onChanged: (value) {
                          widget.igstControllerP.text = igstController.text;
                        },
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$')),
                        ],
                      ),
                    ),

                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.061,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              left: BorderSide(),
                              // top: BorderSide(),
                              right: BorderSide())),
                      child: TextFormField(
                        controller: netAmountController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    // Flexible(
                    //   child: SizedBox(
                    //     width: MediaQuery.of(context).size.width * 0.01,
                    //     height: 20,
                    //     child: IconButton(
                    //       hoverColor: Colors.transparent,
                    //       splashColor: Colors.transparent,
                    //       onPressed: () {
                    //         _saveValues();
                    //       },
                    //       icon: const Icon(
                    //         Icons.save,
                    //         size: 15,
                    //         color: Colors.green,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width * 0.005,
                    // ),
                    // Flexible(
                    //   child: SizedBox(
                    //     width: MediaQuery.of(context).size.width * 0.01,
                    //     height: 20,
                    //     child: IconButton(
                    //       hoverColor: Colors.transparent,
                    //       splashColor: Colors.transparent,
                    //       onPressed: _deleteEntry,
                    //       icon: const Icon(
                    //         Icons.delete,
                    //         size: 15,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
