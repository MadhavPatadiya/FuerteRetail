// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:billingsphere/data/models/brand/item_brand_model.dart';
import 'package:billingsphere/data/models/hsn/hsn_model.dart';
import 'package:billingsphere/data/models/item/item_model.dart';
import 'package:billingsphere/data/models/itemGroup/item_group_model.dart';
import 'package:billingsphere/data/models/measurementLimit/measurement_limit_model.dart';
import 'package:billingsphere/data/models/secondaryUnit/secondary_unit_model.dart';
import 'package:billingsphere/data/models/storeLocation/store_location_model.dart';
import 'package:billingsphere/data/models/taxCategory/tax_category_model.dart';
import 'package:billingsphere/data/repository/item_brand_repository.dart';
import 'package:billingsphere/data/repository/item_repository.dart';
import 'package:billingsphere/logic/cubits/itemBrand_cubit/itemBrand_state.dart';
import 'package:billingsphere/logic/cubits/itemGroup_cubit/itemGroup_cubit.dart';
import 'package:billingsphere/utils/controllers/items_text_controllers.dart';
import 'package:billingsphere/views/NI_widgets/NI_new_table.dart';
import 'package:billingsphere/views/NI_widgets/NI_singleTextField.dart';
import 'package:billingsphere/views/searchable_dropdown.dart';
import 'package:billingsphere/views/sumit_screen/measurement_unit/measurement_unit.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repository/item_group_repository.dart';
import '../../logic/cubits/hsn_cubit/hsn_cubit.dart';
import '../../logic/cubits/hsn_cubit/hsn_state.dart';
import '../../logic/cubits/itemBrand_cubit/itemBrand_cubit.dart';
import '../../logic/cubits/itemGroup_cubit/itemGroup_state.dart';
import '../../logic/cubits/measurement_cubit/measurement_limit_cubit.dart';
import '../../logic/cubits/measurement_cubit/measurement_limit_state.dart';
import '../../logic/cubits/secondary_unit_cubit/secondary_unit_cubit.dart';
import '../../logic/cubits/secondary_unit_cubit/secondary_unit_state.dart';
import '../../logic/cubits/store_cubit/store_cubit.dart';
import '../../logic/cubits/store_cubit/store_state.dart';
import '../../logic/cubits/taxCategory_cubit/taxCategory_cubit.dart';
import '../../logic/cubits/taxCategory_cubit/taxCategory_state.dart';
import '../sumit_screen/hsn_code/hsn_code.dart';
import '../sumit_screen/secondary_unit/secondary_unit.dart';

class NIMyDesktopBody extends StatefulWidget {
  const NIMyDesktopBody({super.key});

  @override
  State<NIMyDesktopBody> createState() => _BasicDetailsState();
}

class _BasicDetailsState extends State<NIMyDesktopBody> {
  List<List<String>> tableData = [
    // Initial data for the table
    ["Header 1", "Header 2", "Header 3"],
    ["Data 1", "Data 2", "Data 3"],
  ];
  ItemsGroupService itemsGroup = ItemsGroupService();
  ItemsBrandsService itemsBrand = ItemsBrandsService();
  ItemsFormControllers controllers = ItemsFormControllers();
  bool _isSaving = false;
  ItemsService items = ItemsService();
  List<Uint8List> _selectedImages = [];
  final List<Widget> openingBalance = [];
  Map<String, dynamic> saveOpeningbalance = {};
  final List<Map<String, dynamic>> storesData = [];
  double totalQty = 0;
  double totalAmount = 0;

  List<String>? companyCode;
  Future<List<String>?> getCompanyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('companies');
  }

  Future<void> setCompanyCode() async {
    List<String>? code = await getCompanyCode();
    setState(() {
      companyCode = code;
    });
  }

  void createItems() async {
    setState(() {
      _isSaving = true;
    });

    List<ImageData>? imageList;
    if (_selectedImages.isNotEmpty) {
      imageList = _selectedImages
          .map((image) => ImageData(
                data: image,
                contentType: 'image/jpeg',
                filename: 'filename.jpg',
              ))
          .toList();
    }

    items.createItem(
      itemGroup: selectedItemId!,
      companyCode: companyCode!.first,
      itemBrand: selectedItemId2!,
      itemName: controllers.itemNameController.text,
      printName: controllers.printNameController.text,
      codeNo: controllers.codeNoController.text,
      taxCategory: selectedTaxRateId!,
      hsnCode: selectedHSNCodeId!,
      barcode: controllers.barcodeController.text,
      storeLocation: selectedStoreLocationId!,
      measurementUnit: selectedMeasurementLimitId!,
      secondaryUnit: selectedSecondaryUnitId!,
      minimumStock:
          int.tryParse(controllers.minimumStockController.text.trim()) ?? 0,
      maximumStock:
          ((int.tryParse(controllers.minimumStockController.text.trim()) ?? 0) +
                  totalQty)
              .toInt(),
      monthlySalesQty:
          int.tryParse(controllers.monthlySalesQtyController.text.trim()) ?? 0,
      dealer: double.parse(controllers.dealerController.text),
      subDealer: double.parse(controllers.subDealerController.text),
      retail: double.parse(controllers.retailController.text),
      mrp: double.parse(controllers.mrpController.text),
      openingStock: selectedStock,
      status: selectedStatus,
      context: context,
      date: controllers.dateController.text,
      images: imageList ?? [],
      openingBalance: storesData.map((e) {
        return OpeningBalance(
          qty: e['qty'],
          unit: e['unit'],
          rate: e['rate'],
          total: e['total'],
        );
      }).toList(),
      openingBalanceQty: totalQty,
      openingBalanceAmt: totalAmount,
    );

    controllers.itemNameController.clear();
    controllers.printNameController.clear();
    controllers.codeNoController.clear();
    controllers.minimumStockController.clear();
    controllers.maximumStockController.clear();
    controllers.monthlySalesQtyController.clear();
    controllers.dealerController.clear();
    controllers.subDealerController.clear();
    controllers.retailController.clear();
    controllers.mrpController.clear();
    controllers.openingStockController.clear();
    controllers.barcodeController.clear();
    controllers.dateController.clear();
    selectedItemId = fetchedItemGroups.first.id;
    selectedItemId2 = fetchedItemBrands.first.id;
    selectedTaxRateId = fetchedTaxCategories.first.id;
    selectedHSNCodeId = fetchedHSNCodes.first.id;
    selectedStoreLocationId = fetchedStores.first.id;
    selectedMeasurementLimitId = fetchedMLimits.first.id;
    selectedUnitId = fetchedMLimits.first.id;
    selectedSecondaryUnitId = fetchedSUnit.first.id;
    imageList = [];
    _selectedImages = [];
    selectedStatus = 'Active';
    selectedStock = 'Yes';
    _generateRandomNumber();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSaving = false;
    });
  }

  //  Dropdown Data
  List<ItemsGroup> fetchedItemGroups = [];
  List<ItemsBrand> fetchedItemBrands = [];
  List<TaxRate> fetchedTaxCategories = [];
  List<HSNCode> fetchedHSNCodes = [];
  List<StoreLocation> fetchedStores = [];
  List<MeasurementLimit> fetchedMLimits = [];
  List<SecondaryUnit> fetchedSUnit = [];
  List<String> status = ['Active', 'Inactive'];
  List<String> stock = ['Yes', 'No'];
  List<File> files = [];

  // Variables
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int _generatedNumber = 0;
  Random random = Random();
  bool isFetched = false;

  // Dropdown Values
  String? selectedItemId;
  String? selectedItemId2;
  String? selectedTaxRateId;
  String? selectedHSNCodeId;
  String? selectedStoreLocationId;
  String? selectedMeasurementLimitId;
  String? selectedUnitId;
  String? selectedSecondaryUnitId;
  String selectedStatus = 'Active';
  String selectedStock = 'No';

  void _generateRandomNumber() {
    setState(() {
      int seed = DateTime.now().millisecondsSinceEpoch;
      Random random = Random(seed);
      _generatedNumber = random.nextInt(900) + 100;
      controllers.codeNoController.text = _generatedNumber.toString();
    });
  }

  void _generateBarcode() {
    setState(() {
      int firstPart = Random().nextInt(1000000000);
      int secondPart = Random().nextInt(1000);
      _generatedNumber = int.parse('$firstPart$secondPart');
      controllers.barcodeController.text = _generatedNumber.toString();
    });
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchData(),
      setCompanyCode(),
    ]);
  }

  void _initControllers() {
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    controllers.dateController.text = formattedDate;
    controllers.maximumStockController.text = '0';
    controllers.minimumStockController.text = '0';
    controllers.monthlySalesQtyController.text = '0';
    controllers.dealerController.text = '0';
    controllers.subDealerController.text = '0';
    controllers.retailController.text = '0';
    controllers.mrpController.text = '0';
    controllers.currentPriceController.text = '0.0';
  }

  void _allDataInit() {
    _initializeData();
    _generateRandomNumber();
    _generateBarcode();
    _initControllers();
  }

  @override
  void initState() {
    _allDataInit();
    super.initState();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Method to fetch data from Cubits
  Future<void> _fetchData() async {
    await Future.wait([
      BlocProvider.of<ItemBrandCubit>(context).getItemBrand(),
      BlocProvider.of<ItemGroupCubit>(context).getItemGroups(),
      BlocProvider.of<TaxCategoryCubit>(context).getTaxCategory(),
      BlocProvider.of<HSNCodeCubit>(context).getHSNCodes(),
      BlocProvider.of<CubitStore>(context).getStores(),
      BlocProvider.of<MeasurementLimitCubit>(context).getLimit(),
      BlocProvider.of<SecondaryUnitCubit>(context).getLimit(),
    ]);
  }

  void initializeControllers() {
    controllers.oPBQtyController = TextEditingController();
    controllers.oPBUnitController = TextEditingController();
    controllers.oPBRateController = TextEditingController();
    controllers.oPBTotalController = TextEditingController();
  }

  void calculateTotals() {
    totalQty = storesData.fold(0, (sum, item) => sum + (item['qty'] ?? 0));
    totalAmount =
        storesData.fold(0.0, (sum, item) => sum + (item['total'] ?? 0.0));

    print('Total Qty: $totalQty');
    print('Total Amount: $totalAmount');
    print('Stores Data: $storesData');
  }

  Widget buildStoresDetails({required Function() updateTotals}) {
    initializeControllers();
    final key = Random().nextInt(1000).toString();
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Container(
              height: 50,
              width: 70,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      left: BorderSide())),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${openingBalance.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              // height: 30,
              width: 250,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(),
                  top: BorderSide(),
                  left: BorderSide(),
                ),
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                cursorHeight: 20,
                controller: controllers.oPBQtyController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 50,
              width: 130,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      left: BorderSide())),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SearchableDropDown(
                  controller: controllers.oPBUnitController,
                  searchController: controllers.oPBUnitController,
                  value: selectedUnitId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUnitId = newValue;
                    });
                  },
                  items:
                      fetchedMLimits.map((MeasurementLimit measurementLimit) {
                    return DropdownMenuItem<String>(
                      value: measurementLimit.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(measurementLimit.measurement),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  searchMatchFn: (item, searchValue) {
                    final itemMLimit = fetchedMLimits
                        .firstWhere((e) => e.id == item.value)
                        .measurement;
                    return itemMLimit
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
              ),
            ),
            Container(
              // height: 30,
              width: 250,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      left: BorderSide())),
              child: TextFormField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                cursorHeight: 20,
                controller: controllers.oPBRateController,
                onChanged: (value) {
                  int qty =
                      int.tryParse(controllers.oPBQtyController.text) ?? 0;
                  double rate = double.tryParse(value) ?? 0;
                  double amount = qty * rate;
                  setState(() {
                    controllers.oPBTotalController.text =
                        amount.toStringAsFixed(2);
                  });

                  saveOpeningbalance = {
                    'key': key,
                    'qty': int.tryParse(controllers.oPBQtyController.text),
                    'unit': selectedUnitId,
                    'rate': double.tryParse(controllers.oPBRateController.text),
                    'total':
                        double.tryParse(controllers.oPBTotalController.text),
                  };
                  if (storesData
                      .where((element) =>
                          element['key'] == saveOpeningbalance['key'])
                      .isNotEmpty) {
                    storesData[storesData.indexWhere((element) =>
                            element['key'] == saveOpeningbalance['key'])] =
                        saveOpeningbalance;

                    // showToast('Opening Balance updated successfully');
                  } else {
                    storesData.add(saveOpeningbalance);
                    // showToast('Opening Balance added successfully');
                  }
                  updateTotals();
                },
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              // height: 30,
              width: 250,
              decoration: BoxDecoration(border: Border.all()),
              child: TextFormField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                ),
                cursorHeight: 20,
                controller: controllers.oPBTotalController,
                textAlign: TextAlign.center,
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.1;
    double buttonHeight = MediaQuery.of(context).size.height * 0.03;
    double screenWidth = MediaQuery.of(context).size.width;

    return _isSaving
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title:
                  const Text('NEW ITEM', style: TextStyle(color: Colors.white)),
              centerTitle: true,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () {
                    _fetchData();
                  },
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<ItemBrandCubit, CubitItemBrandStates>(
                  listener: (context, state) {
                    if (state is CubitItemBrandLoaded) {
                      setState(() {
                        fetchedItemBrands = state.itemBrands;
                        selectedItemId2 = fetchedItemBrands.first.id;
                      });
                    } else if (state is CubitItemBrandError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<ItemGroupCubit, CubitItemGroupStates>(
                  listener: (context, state) {
                    if (state is CubitItemGroupLoaded) {
                      setState(() {
                        fetchedItemGroups = state.itemGroups;
                        selectedItemId = fetchedItemGroups.first.id;
                      });
                    } else if (state is CubitItemGroupError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<TaxCategoryCubit, CubitTaxCategoryStates>(
                  listener: (context, state) {
                    if (state is CubitTaxCategoryLoaded) {
                      setState(() {
                        fetchedTaxCategories = state.taxCategories;
                        selectedTaxRateId = fetchedTaxCategories.first.id;
                      });
                    } else if (state is CubitTaxCategoryError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<HSNCodeCubit, CubitHsnStates>(
                  listener: (context, state) {
                    if (state is CubitHsnLoaded) {
                      setState(() {
                        fetchedHSNCodes = state.hsns;
                        selectedHSNCodeId = fetchedHSNCodes.first.id;
                      });
                    } else if (state is CubitHsnError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<CubitStore, CubitStoreStates>(
                  listener: (context, state) {
                    if (state is CubicStoreLoaded) {
                      setState(() {
                        fetchedStores = state.stores;
                        selectedStoreLocationId = fetchedStores.first.id;
                      });
                    } else if (state is CubitStoreError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<MeasurementLimitCubit,
                    CubitMeasurementLimitStates>(
                  listener: (context, state) {
                    if (state is CubitMeasurementLimitLoaded) {
                      setState(() {
                        fetchedMLimits = state.measurementLimits;
                        selectedMeasurementLimitId = fetchedMLimits.first.id;
                        selectedUnitId = fetchedMLimits.first.id;
                      });
                    } else if (state is CubitMeasurementLimitError) {
                      print(state.error);
                    }
                  },
                ),
                BlocListener<SecondaryUnitCubit, CubitSecondaryUnitStates>(
                  listener: (context, state) {
                    if (state is CubitSecondaryUnitLoaded) {
                      setState(() {
                        fetchedSUnit = state.secondaryUnits;
                        selectedSecondaryUnitId = fetchedSUnit.first.id;
                      });
                    } else if (state is CubitSecondaryUnitError) {
                      print(state.error);
                    }
                  },
                ),
              ],
              child: Column(
                children: [
                  Expanded(
                    child: isFetched == true
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Stack(
                              children: [
                                Opacity(
                                  opacity: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              // Give me 5 buttons in a row
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .6,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .44,
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                      top: BorderSide(
                                                          width: 1,
                                                          color: Colors.black),
                                                      left: BorderSide(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                    )),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .04,
                                                              width: screenWidth < 900
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .14
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.1,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  14, 63, 147),
                                                              child: Text(
                                                                ' BASIC DETAILS',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: screenWidth <
                                                                            1030
                                                                        ? 11.0
                                                                        : 14.0),
                                                              )),
                                                        ),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 3,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                        'Item Group',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                14,
                                                                                63,
                                                                                147))),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 9,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black, // Choose the border color you prefer
                                                                            width:
                                                                                1.0, // Adjust the border width
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0), // Adjust the border radius
                                                                        ),
                                                                        child:
                                                                            SearchableDropDown(
                                                                          controller:
                                                                              controllers.itemGroupController,
                                                                          searchController:
                                                                              controllers.itemGroupController,
                                                                          value:
                                                                              selectedItemId,
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              selectedItemId = newValue;
                                                                            });
                                                                          },
                                                                          items:
                                                                              fetchedItemGroups.map((ItemsGroup itemGroup) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: itemGroup.id,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                                                child: Text(itemGroup.name),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          searchMatchFn:
                                                                              (item, searchValue) {
                                                                            final itemGroup =
                                                                                fetchedItemGroups.firstWhere((e) => e.id == item.value).name;
                                                                            return itemGroup.toLowerCase().contains(searchValue.toLowerCase());
                                                                          },
                                                                        ),
                                                                        // child:
                                                                        //     DropdownButtonHideUnderline(
                                                                        //   child:
                                                                        //       DropdownButton<String>(
                                                                        //     value:
                                                                        //         selectedItemId,
                                                                        //     underline:
                                                                        //         Container(),
                                                                        //     onChanged:
                                                                        //         (String? newValue) {
                                                                        //       setState(() {
                                                                        //         selectedItemId = newValue;
                                                                        //       });
                                                                        //     },
                                                                        //     items:
                                                                        //         fetchedItemGroups.map((ItemsGroup itemGroup) {
                                                                        //       return DropdownMenuItem<String>(
                                                                        //         value: itemGroup.id,
                                                                        //         child: Padding(
                                                                        //           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                                        //           child: Text(itemGroup.name),
                                                                        //         ),
                                                                        //       );
                                                                        //     }).toList(),
                                                                        //   ),
                                                                        // ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Item Brand',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                2),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.black,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          child:
                                                                              SearchableDropDown(
                                                                            controller:
                                                                                controllers.itemBrandController,
                                                                            searchController:
                                                                                controllers.itemBrandController,
                                                                            value:
                                                                                selectedItemId2,
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                selectedItemId2 = newValue;
                                                                              });
                                                                            },
                                                                            items:
                                                                                fetchedItemBrands.map((ItemsBrand itemBrand) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: itemBrand.id,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                                                  child: Text(
                                                                                    itemBrand.name,
                                                                                    style: const TextStyle(fontSize: 15),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                            searchMatchFn:
                                                                                (item, searchValue) {
                                                                              final itemBrands = fetchedItemBrands.firstWhere((e) => e.id == item.value).name;
                                                                              return itemBrands.toLowerCase().contains(searchValue.toLowerCase());
                                                                            },
                                                                          ),
                                                                          // child:
                                                                          //     DropdownButtonHideUnderline(
                                                                          //   child:
                                                                          //       DropdownButton<String>(
                                                                          //     isExpanded: true,
                                                                          //     value: selectedItemId2,
                                                                          //     underline: Container(),
                                                                          //     onChanged: (String? newValue) {
                                                                          //       setState(() {
                                                                          //         selectedItemId2 = newValue;
                                                                          //       });
                                                                          //     },
                                                                          //     items: fetchedItemBrands.map((ItemsBrand itemBrand) {
                                                                          //       return DropdownMenuItem<String>(
                                                                          //         value: itemBrand.id,
                                                                          //         child: Padding(
                                                                          //           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                                          //           child: Text(
                                                                          //             itemBrand.name,
                                                                          //             style: const TextStyle(fontSize: 15),
                                                                          //           ),
                                                                          //         ),
                                                                          //       );
                                                                          //     }).toList(),
                                                                          //   ),
                                                                          // ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Code No',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          TextFormField(
                                                                        enabled:
                                                                            false,
                                                                        controller:
                                                                            controllers.codeNoController,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        cursorHeight:
                                                                            21,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            NISingleTextField(
                                                              labelText:
                                                                  'Item Name',
                                                              flex1: 3,
                                                              flex2: 9,
                                                              controller:
                                                                  controllers
                                                                      .itemNameController,
                                                            ),
                                                            NISingleTextField(
                                                              labelText:
                                                                  'Print Name',
                                                              flex1: 3,
                                                              flex2: 9,
                                                              controller:
                                                                  controllers
                                                                      .printNameController,
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Tax Category',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                        ),
                                                                        child:
                                                                            DropdownButtonHideUnderline(
                                                                          child:
                                                                              DropdownButton<String>(
                                                                            value:
                                                                                selectedTaxRateId,
                                                                            underline:
                                                                                Container(),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                selectedTaxRateId = newValue;
                                                                              });
                                                                            },
                                                                            items:
                                                                                fetchedTaxCategories.map((TaxRate taxRate) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: taxRate.id,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                                                  child: Text('${taxRate.rate}%'),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'HSN Code',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                        ),
                                                                        // child:
                                                                        //     DropdownButtonHideUnderline(
                                                                        //   child:
                                                                        //       DropdownButton<String>(
                                                                        //     value:
                                                                        //         selectedHSNCodeId,
                                                                        //     underline:
                                                                        //         Container(),
                                                                        //     onChanged:
                                                                        //         (String? newValue) {
                                                                        //       setState(() {
                                                                        //         selectedHSNCodeId = newValue;
                                                                        //       });
                                                                        //     },
                                                                        //     items:
                                                                        //         fetchedHSNCodes.map((HSNCode hsnCode) {
                                                                        //       return DropdownMenuItem<String>(
                                                                        //         value: hsnCode.id,
                                                                        //         child: Row(
                                                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        //           children: [
                                                                        //             Padding(
                                                                        //               padding: const EdgeInsets.all(8.0),
                                                                        //               child: Text(
                                                                        //                 hsnCode.hsn,
                                                                        //               ),
                                                                        //             ),
                                                                        //           ],
                                                                        //         ),
                                                                        //       );
                                                                        //     }).toList(),
                                                                        //   ),
                                                                        // ),

                                                                        child:
                                                                            SearchableDropDown(
                                                                          controller:
                                                                              controllers.itemHsnController,
                                                                          searchController:
                                                                              controllers.itemHsnController,
                                                                          value:
                                                                              selectedHSNCodeId,
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              selectedHSNCodeId = newValue;
                                                                            });
                                                                          },
                                                                          items:
                                                                              fetchedHSNCodes.map((HSNCode hsnCode) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: hsnCode.id,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Text(
                                                                                      hsnCode.hsn,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          searchMatchFn:
                                                                              (item, searchValue) {
                                                                            final itemHsn =
                                                                                fetchedHSNCodes.firstWhere((e) => e.id == item.value).hsn;
                                                                            return itemHsn.toLowerCase().contains(searchValue.toLowerCase());
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Spacer(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const Responsive_NewHSNCommodity(),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Add HSN Code',
                                                                      style:
                                                                          TextStyle(
                                                                        decoration:
                                                                            TextDecoration.underline, // Underline the text
                                                                        color: Colors
                                                                            .blue, // Change text color to blue
                                                                        fontSize:
                                                                            16, // Set font size
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .6,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .44,
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                      left: BorderSide(
                                                          color: Colors.black),
                                                      bottom: BorderSide(
                                                          color: Colors.black),
                                                    )),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const DottedLine(
                                                          direction:
                                                              Axis.horizontal,
                                                          lineLength:
                                                              double.infinity,
                                                          lineThickness: 1.0,
                                                          dashLength: 4.0,
                                                          dashColor:
                                                              Colors.black,
                                                          dashRadius: 0.0,
                                                          dashGapLength: 4.0,
                                                          dashGapColor: Colors
                                                              .transparent,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 4,
                                                                  top: 4),
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .04,
                                                            width: screenWidth < 900
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .14
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                14, 63, 147),
                                                            child: Text(
                                                              ' STOCK OPTIONS',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      screenWidth <
                                                                              1030
                                                                          ? 11.0
                                                                          : 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Store Location',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                        ),
                                                                        child:
                                                                            DropdownButtonHideUnderline(
                                                                          child:
                                                                              DropdownButton<String>(
                                                                            value:
                                                                                selectedStoreLocationId,
                                                                            underline:
                                                                                Container(),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                selectedStoreLocationId = newValue;
                                                                              });
                                                                            },
                                                                            items:
                                                                                fetchedStores.map((StoreLocation storeLocation) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: storeLocation.id,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Text(storeLocation.location),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Barcode Sr',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            controllers.barcodeController,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        cursorHeight:
                                                                            21,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Measurement Unit',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                        ),
                                                                        // child:
                                                                        //     DropdownButtonHideUnderline(
                                                                        //   child:
                                                                        //       DropdownButton<String>(
                                                                        //     value:
                                                                        //         selectedMeasurementLimitId,
                                                                        //     underline:
                                                                        //         Container(),
                                                                        //     onChanged:
                                                                        //         (String? newValue) {
                                                                        //       setState(() {
                                                                        //         selectedMeasurementLimitId = newValue;
                                                                        //       });
                                                                        //     },
                                                                        //     items:
                                                                        //         fetchedMLimits.map((MeasurementLimit measurementLimit) {
                                                                        //       return DropdownMenuItem<String>(
                                                                        //         value: measurementLimit.id,
                                                                        //         child: Row(
                                                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        //           children: [
                                                                        //             Padding(
                                                                        //               padding: const EdgeInsets.all(8.0),
                                                                        //               child: Text(measurementLimit.measurement),
                                                                        //             ),
                                                                        //           ],
                                                                        //         ),
                                                                        //       );
                                                                        //     }).toList(),
                                                                        //   ),
                                                                        // ),

                                                                        child:
                                                                            SearchableDropDown(
                                                                          controller:
                                                                              controllers.itemMeasureunitController,
                                                                          searchController:
                                                                              controllers.itemMeasureunitController,
                                                                          value:
                                                                              selectedMeasurementLimitId,
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              selectedMeasurementLimitId = newValue;
                                                                            });
                                                                          },
                                                                          items:
                                                                              fetchedMLimits.map((MeasurementLimit measurementLimit) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: measurementLimit.id,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Text(measurementLimit.measurement),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          searchMatchFn:
                                                                              (item, searchValue) {
                                                                            final itemMLimit =
                                                                                fetchedMLimits.firstWhere((e) => e.id == item.value).measurement;
                                                                            return itemMLimit.toLowerCase().contains(searchValue.toLowerCase());
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Secondary Unit',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                        ),
                                                                        // child:
                                                                        //     DropdownButtonHideUnderline(
                                                                        //   child:
                                                                        //       DropdownButton<String>(
                                                                        //     value:
                                                                        //         selectedSecondaryUnitId,
                                                                        //     underline:
                                                                        //         Container(),
                                                                        //     onChanged:
                                                                        //         (String? newValue) {
                                                                        //       setState(() {
                                                                        //         selectedSecondaryUnitId = newValue;
                                                                        //       });
                                                                        //     },
                                                                        //     items:
                                                                        //         fetchedSUnit.map((SecondaryUnit secondaryUnit) {
                                                                        //       return DropdownMenuItem<String>(
                                                                        //         value: secondaryUnit.id,
                                                                        //         child: Row(
                                                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        //           children: [
                                                                        //             Padding(
                                                                        //               padding: const EdgeInsets.all(8.0),
                                                                        //               child: Text(secondaryUnit.secondaryUnit),
                                                                        //             ),
                                                                        //           ],
                                                                        //         ),
                                                                        //       );
                                                                        //     }).toList(),
                                                                        //   ),
                                                                        // ),

                                                                        child:
                                                                            SearchableDropDown(
                                                                          controller:
                                                                              controllers.itemMeasureunitController,
                                                                          searchController:
                                                                              controllers.itemMeasureunitController,
                                                                          value:
                                                                              selectedSecondaryUnitId,
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              selectedSecondaryUnitId = newValue;
                                                                            });
                                                                          },
                                                                          items:
                                                                              fetchedSUnit.map((SecondaryUnit secondaryUnit) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: secondaryUnit.id,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Text(secondaryUnit.secondaryUnit),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          searchMatchFn:
                                                                              (item, searchValue) {
                                                                            final itemSunit =
                                                                                fetchedSUnit.firstWhere((e) => e.id == item.value).secondaryUnit;
                                                                            return itemSunit.toLowerCase().contains(searchValue.toLowerCase());
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .10),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const Responsive_measurementunit(),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Add Measurement Unit',
                                                                      style:
                                                                          TextStyle(
                                                                        decoration:
                                                                            TextDecoration.underline, // Underline the text
                                                                        color: Colors
                                                                            .blue, // Change text color to blue
                                                                        fontSize:
                                                                            16, // Set font size
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const Responsive_NewItemUnit(),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Add Secondary Unit',
                                                                      style:
                                                                          TextStyle(
                                                                        decoration:
                                                                            TextDecoration.underline, // Underline the text
                                                                        color: Colors
                                                                            .blue, // Change text color to blue
                                                                        fontSize:
                                                                            16, // Set font size
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Minimum Stock',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            controllers.minimumStockController,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        cursorHeight:
                                                                            21,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Maximum Stock',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            controllers.maximumStockController,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        cursorHeight:
                                                                            21,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'Monthly Sale Qty',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            14,
                                                                            63,
                                                                            147),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .055,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            controllers.monthlySalesQtyController,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        cursorHeight:
                                                                            21,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Visibility(
                                                                  visible:
                                                                      false,
                                                                  child:
                                                                      Expanded(
                                                                    flex: 3,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          Text(
                                                                        'Maximum Stock',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              14,
                                                                              63,
                                                                              147),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible:
                                                                      false,
                                                                  child:
                                                                      Expanded(
                                                                    flex: 6,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                      child:
                                                                          SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            .055,
                                                                        child:
                                                                            TextFormField(
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                          cursorHeight:
                                                                              21,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.top,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            border:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(0),
                                                                              borderSide: const BorderSide(
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .6,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .44,
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            top: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            right: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            left: BorderSide(
                                                                color: Colors
                                                                    .black))),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 4),
                                                          child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .04,
                                                              width: screenWidth < 900
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .14
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.1,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  14, 63, 147),
                                                              child: Text(
                                                                ' PRICE DETAILS',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: screenWidth <
                                                                            1030
                                                                        ? 11.0
                                                                        : 14.0),
                                                              )),
                                                        ),
                                                        // NIEditableTable()
                                                        NInewTable(
                                                          dealerController:
                                                              controllers
                                                                  .dealerController,
                                                          subDealerController:
                                                              controllers
                                                                  .subDealerController,
                                                          retailController:
                                                              controllers
                                                                  .retailController,
                                                          mrpController:
                                                              controllers
                                                                  .mrpController,
                                                          dateController:
                                                              controllers
                                                                  .dateController,
                                                          currentPriceController:
                                                              controllers
                                                                  .currentPriceController,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .6,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .44,
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                right:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                                left: BorderSide(
                                                                    color: Colors
                                                                        .black))),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const DottedLine(
                                                          direction:
                                                              Axis.horizontal,
                                                          lineLength:
                                                              double.infinity,
                                                          lineThickness: 1.0,
                                                          dashLength: 4.0,
                                                          dashColor:
                                                              Colors.black,
                                                          dashRadius: 0.0,
                                                          dashGapLength: 4.0,
                                                          dashGapColor: Colors
                                                              .transparent,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 4,
                                                                  top: 4),
                                                          child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .04,
                                                              width: screenWidth < 900
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .14
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.1,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  14, 63, 147),
                                                              child: Text(
                                                                ' ITEM IMAGES',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: screenWidth <
                                                                            1030
                                                                        ? 11.0
                                                                        : 14.0),
                                                              )),
                                                        ),
                                                        Column(children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Row(
                                                              children: [
                                                                const Text(
                                                                  'Update Image ? :',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          14,
                                                                          63,
                                                                          147)),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .01,
                                                                ),
                                                                SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .13,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        .055,
                                                                    child:
                                                                        const TextField(
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      cursorHeight:
                                                                          21,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .top,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .01,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.black)),
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.29,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.22,
                                                                  child: _selectedImages
                                                                          .isEmpty
                                                                      ? const Center(
                                                                          child: Text(
                                                                              'No Image Selected'))
                                                                      : Image.memory(
                                                                          _selectedImages[
                                                                              0]),
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          FilePickerResult?
                                                                              result =
                                                                              await FilePicker.platform.pickFiles(
                                                                            type:
                                                                                FileType.custom,
                                                                            allowedExtensions: [
                                                                              'jpg',
                                                                              'jpeg',
                                                                              'png',
                                                                              'gif'
                                                                            ],
                                                                          );

                                                                          if (result !=
                                                                              null) {
                                                                            // setState(() {
                                                                            //   _filePickerResult =
                                                                            //       result;
                                                                            // });
                                                                            List<Uint8List>
                                                                                fileBytesList =
                                                                                [];

                                                                            for (PlatformFile file
                                                                                in result.files) {
                                                                              Uint8List fileBytes = file.bytes!;
                                                                              fileBytesList.add(fileBytes);
                                                                            }

                                                                            setState(() {
                                                                              _selectedImages.addAll(fileBytesList);
                                                                            });

                                                                            // print(_selectedImages);
                                                                          } else {
                                                                            // User canceled the picker
                                                                            print('File picking canceled by the user.');
                                                                          }
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.black,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fixedSize: Size(
                                                                              buttonWidth,
                                                                              buttonHeight),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          side:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Add',
                                                                          style:
                                                                              TextStyle(fontSize: screenWidth < 1030 ? 11.0 : 13.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {},
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.black,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fixedSize: Size(
                                                                              buttonWidth,
                                                                              buttonHeight),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          side:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        child: Center(
                                                                            child: Text(
                                                                          'Delete',
                                                                          style:
                                                                              TextStyle(fontSize: screenWidth < 1030 ? 11.0 : 13.0),
                                                                        )),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {},
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.black,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fixedSize: Size(
                                                                              buttonWidth,
                                                                              buttonHeight),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          side:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Next',
                                                                          style:
                                                                              TextStyle(fontSize: screenWidth < 1030 ? 11.0 : 13.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {},
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.black,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fixedSize: Size(
                                                                              buttonWidth,
                                                                              buttonHeight),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          side:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Previous',
                                                                          style:
                                                                              TextStyle(fontSize: screenWidth < 1030 ? 11.0 : 13.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {},
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.black,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fixedSize: Size(
                                                                              buttonWidth,
                                                                              buttonHeight),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                          ),
                                                                          side:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Zoom',
                                                                          style:
                                                                              TextStyle(fontSize: screenWidth < 1030 ? 11.0 : 13.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ]),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .1,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .88,
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    right: BorderSide(
                                                      color: Colors.black,
                                                    ),
                                                    bottom: BorderSide(
                                                      color: Colors.black,
                                                    ),
                                                    left: BorderSide(
                                                        color: Colors.black))),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    'Opening Stock (F7) :',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color.fromARGB(
                                                            255, 14, 63, 147)),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .01,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .13,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .055,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .black, // Choose the border color you prefer
                                                          width:
                                                              1.0, // Adjust the border width
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                0), // Adjust the border radius
                                                      ),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                            String>(
                                                          value: selectedStock,
                                                          underline:
                                                              Container(),
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              selectedStock =
                                                                  newValue!;
                                                            });
                                                          },
                                                          items: stock.map(
                                                              (String value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    Text(value),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .03,
                                                  ),
                                                  const Text(
                                                    'Is Active :',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color.fromARGB(
                                                            255, 14, 63, 147)),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .01,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .13,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .055,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .black, // Choose the border color you prefer
                                                          width:
                                                              1.0, // Adjust the border width
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                0), // Adjust the border radius
                                                      ),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                            String>(
                                                          value: selectedStatus,
                                                          underline:
                                                              Container(),
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              selectedStatus =
                                                                  newValue!;
                                                            });
                                                          },
                                                          items: status.map(
                                                              (String value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    Text(value),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .01,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              fixedSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .1,
                                                                  25),
                                                              shape: const BeveledRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          .3)),
                                                              backgroundColor:
                                                                  Colors.yellow
                                                                      .shade100),
                                                          onPressed: () {
                                                            if (selectedStock ==
                                                                'Yes') {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                      void
                                                                          updateTotals() {
                                                                        setState(
                                                                            () {
                                                                          calculateTotals();
                                                                        });
                                                                      }

                                                                      return AlertDialog(
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        content:
                                                                            Container(
                                                                          height:
                                                                              500,
                                                                          width:
                                                                              1000,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Container(
                                                                                width: 1000,
                                                                                height: 50,
                                                                                decoration: BoxDecoration(color: Colors.blue[600]),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      const SizedBox(),
                                                                                      const Spacer(),
                                                                                      const Text(
                                                                                        'Opening Stock Entry',
                                                                                        style: TextStyle(
                                                                                          color: Colors.white,
                                                                                          fontSize: 18,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                        textAlign: TextAlign.center,
                                                                                      ),
                                                                                      const Spacer(),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                          openingBalance.clear();
                                                                                          totalQty = 0;
                                                                                          totalAmount = 0;
                                                                                          storesData.clear();
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.close_outlined,
                                                                                          color: Colors.white,
                                                                                          // size: 36.0,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 2),
                                                                              Container(
                                                                                alignment: Alignment.topCenter,
                                                                                width: 990,
                                                                                height: 350,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(),
                                                                                ),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 70,
                                                                                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(), top: BorderSide(), left: BorderSide())),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(2.0),
                                                                                            child: Text(
                                                                                              'Sr',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 250,
                                                                                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(), top: BorderSide(), left: BorderSide())),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(2.0),
                                                                                            child: Text(
                                                                                              'Qty',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 130,
                                                                                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(), top: BorderSide(), left: BorderSide())),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(2.0),
                                                                                            child: Text(
                                                                                              'Unit',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 250,
                                                                                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(), top: BorderSide(), left: BorderSide())),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(2.0),
                                                                                            child: Text(
                                                                                              'Rate',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 250,
                                                                                          decoration: BoxDecoration(border: Border.all()),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(2.0),
                                                                                            child: Text(
                                                                                              'Total',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 30,
                                                                                          child: IconButton(
                                                                                            onPressed: () {
                                                                                              setState(() {
                                                                                                openingBalance.add(buildStoresDetails(updateTotals: updateTotals));
                                                                                              });
                                                                                            },
                                                                                            icon: const Icon(
                                                                                              Icons.add,
                                                                                              color: Colors.black,
                                                                                              size: 30.0,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Column(
                                                                                      children: openingBalance,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 2),
                                                                              Container(
                                                                                width: 990,
                                                                                height: 50,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(),
                                                                                ),
                                                                                child: Row(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: 200,
                                                                                      child: Text(
                                                                                        '$totalQty',
                                                                                        style: TextStyle(color: Color.fromARGB(255, 4, 26, 228), fontSize: 14, fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.end,
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 620,
                                                                                      child: Text(
                                                                                        '$totalAmount',
                                                                                        style: TextStyle(color: Color.fromARGB(255, 4, 26, 228), fontSize: 14, fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.end,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 5),
                                                                              Row(
                                                                                children: [
                                                                                  const SizedBox(),
                                                                                  const Spacer(),
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width * .1, 25), shape: const BeveledRectangleBorder(side: BorderSide(color: Colors.black, width: .3)), backgroundColor: Colors.yellow.shade100),
                                                                                    onPressed: createItems,
                                                                                    child: const Text(
                                                                                      'Save',
                                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 10),
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width * .1, 25), shape: const BeveledRectangleBorder(side: BorderSide(color: Colors.black, width: .3)), backgroundColor: Colors.yellow.shade100),
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      openingBalance.clear();
                                                                                      totalQty = 0;
                                                                                      totalAmount = 0;
                                                                                      storesData.clear();
                                                                                    },
                                                                                    child: const Text(
                                                                                      'Cancel',
                                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                                                    ),
                                                                                  ),
                                                                                  const Spacer(),
                                                                                  const SizedBox(),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            } else {
                                                              createItems();
                                                            }
                                                          },
                                                         
                                                          child: const Text(
                                                            'Save [F4]',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .002,
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              fixedSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .1,
                                                                  25),
                                                              shape: const BeveledRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          .3)),
                                                              backgroundColor:
                                                                  Colors.yellow
                                                                      .shade100),
                                                          onPressed: () {},
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .002,
                                                        ),
                                                        // Add Category Button
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              fixedSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .14,
                                                                  25),
                                                              shape: const BeveledRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          .3)),
                                                              backgroundColor:
                                                                  Colors.yellow
                                                                      .shade100),
                                                          onPressed: () {
                                                            final TextEditingController
                                                                catNameController =
                                                                TextEditingController();

                                                            final TextEditingController
                                                                catDescController =
                                                                TextEditingController();

                                                            List<Uint8List>
                                                                selectedImage =
                                                                [];

                                                            Alert(
                                                                context:
                                                                    context,
                                                                title:
                                                                    "ADD ITEM GROUP",
                                                                content:
                                                                    StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                    return Column(
                                                                      children: <Widget>[
                                                                        TextField(
                                                                          controller:
                                                                              catNameController,
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            icon:
                                                                                Icon(Icons.category),
                                                                            labelText:
                                                                                'Category Name',
                                                                          ),
                                                                        ),
                                                                        TextField(
                                                                          controller:
                                                                              catDescController,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            icon:
                                                                                Icon(Icons.description),
                                                                            labelText:
                                                                                'Category Description',
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Stack(
                                                                          children: [
                                                                            Container(
                                                                              height: 200,
                                                                              width: MediaQuery.of(context).size.width * 0.4,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white10,
                                                                                border: Border.all(color: Colors.black, width: 2),
                                                                              ),
                                                                              child: selectedImage.isEmpty ? const Center(child: Text('No Image Selected')) : Image.memory(selectedImage[0]),
                                                                            ),
                                                                            Positioned(
                                                                              top: 150,
                                                                              right: -10,
                                                                              left: 0,
                                                                              child: GestureDetector(
                                                                                onTap: () async {
                                                                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                                                    type: FileType.custom,
                                                                                    allowedExtensions: [
                                                                                      'jpg',
                                                                                      'jpeg',
                                                                                      'png',
                                                                                      'gif'
                                                                                    ],
                                                                                  );

                                                                                  if (result != null) {
                                                                                    List<Uint8List> fileBytesList = [];

                                                                                    for (PlatformFile file in result.files) {
                                                                                      Uint8List fileBytes = file.bytes!;
                                                                                      fileBytesList.add(fileBytes);
                                                                                    }

                                                                                    setState(() {
                                                                                      selectedImage.addAll(fileBytesList);
                                                                                    });

                                                                                    // print(_selectedImages);
                                                                                  } else {
                                                                                    // User canceled the picker
                                                                                    print('File picking canceled by the user.');
                                                                                  }
                                                                                },
                                                                                child: MouseRegion(
                                                                                  cursor: SystemMouseCursors.click,
                                                                                  child: SizedBox(
                                                                                    height: 50,
                                                                                    child: CircleAvatar(
                                                                                      radius: 50,
                                                                                      backgroundColor: Colors.yellow.shade100,
                                                                                      child: const Icon(Icons.upload),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                                buttons: [
                                                                  DialogButton(
                                                                    color: Colors
                                                                        .yellow
                                                                        .shade100,
                                                                    onPressed:
                                                                        () {
                                                                      itemsGroup
                                                                          .createItemsGroup(
                                                                        name: catNameController
                                                                            .text,
                                                                        desc: catDescController
                                                                            .text,
                                                                        images: selectedImage ==
                                                                                []
                                                                            ? []
                                                                            : selectedImage
                                                                                .map((image) => ImageData(
                                                                                      data: image,
                                                                                      contentType: 'image/jpeg',
                                                                                      filename: 'filename.jpg',
                                                                                    ))
                                                                                .toList(),
                                                                      );

                                                                      _fetchData();

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "CREATE",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                  ),
                                                                  DialogButton(
                                                                    color: Colors
                                                                        .yellow
                                                                        .shade100,
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child:
                                                                        const Text(
                                                                      "CANCEL",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                  ),
                                                                ]).show();
                                                          },
                                                          child: const Text(
                                                            'ADD ITEM GROUP',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .002,
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              fixedSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .079,
                                                                  20),
                                                              shape: const BeveledRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          .3)),
                                                              backgroundColor:
                                                                  Colors.yellow
                                                                      .shade100),
                                                          onPressed: () {
                                                            final TextEditingController
                                                                catNameController =
                                                                TextEditingController();
                                                            final TextEditingController
                                                                catBrandController =
                                                                TextEditingController();

                                                            final TextEditingController
                                                                catDescController =
                                                                TextEditingController();

                                                            List<Uint8List>
                                                                selectedImage =
                                                                [];

                                                            Alert(
                                                                context:
                                                                    context,
                                                                title:
                                                                    "ADD BRAND",
                                                                content:
                                                                    StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                    return Column(
                                                                      children: <Widget>[
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        TextField(
                                                                          controller:
                                                                              catBrandController,
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            icon:
                                                                                Icon(Icons.category),
                                                                            labelText:
                                                                                'Brand Name',
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                                buttons: [
                                                                  DialogButton(
                                                                    color: Colors
                                                                        .yellow
                                                                        .shade100,
                                                                    onPressed:
                                                                        () {
                                                                      itemsBrand
                                                                          .createItemBrand(
                                                                        name: catBrandController
                                                                            .text,
                                                                      );

                                                                      _fetchData();

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "CREATE",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                  ),
                                                                  DialogButton(
                                                                    color: Colors
                                                                        .yellow
                                                                        .shade100,
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child:
                                                                        const Text(
                                                                      "CANCEL",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                  ),
                                                                ]).show();
                                                          },
                                                          child: const Text(
                                                            'ADD BRAND',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
