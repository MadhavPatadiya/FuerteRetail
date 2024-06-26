import 'dart:math';

import 'package:billingsphere/data/repository/ledger_repository.dart';
import 'package:billingsphere/utils/controllers/ledger_text_controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footer/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/ledgerGroup/ledger_group_model.dart';
import '../../data/models/price/price_category.dart';
import '../../data/repository/ledger_group_respository.dart';
import '../../data/repository/price_category_repository.dart';
import '../searchable_dropdown.dart';

class LGMyDesktopBody extends StatefulWidget {
  const LGMyDesktopBody({super.key});

  @override
  State<LGMyDesktopBody> createState() => _LGMyDesktopBodyState();
}

class _LGMyDesktopBodyState extends State<LGMyDesktopBody> {
  LedgerFormController controller = LedgerFormController();
  final _formKey = GlobalKey<FormState>();
  final LedgerService ledgerService = LedgerService();
  bool _isSaving = false;
  final formatter = DateFormat.yMd();
  final TextEditingController _searchController = TextEditingController();
  // Dropdown Data
  List<LedgerGroup> fetchedLedgerGroups = [];
  List<PriceCategory> fetchedPriceCategories = [];

  // Dropdown Values
  String? selectedLedgerGId;
  String? selectedPriceCId;
  String? ledgerTitle;
  String? billwiseAccounting;
  String? isActived;
  String selectedPriceType = 'DEALER';
  List<String> pricetype = ['DEALER', 'SUB DEALER', 'RETAIL', 'MRP'];

  String selectedPlaceState = 'Gujarat';
  List<String> placestate = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  final LedgerGroupService ledgerGroupService = LedgerGroupService();
  final PriceCategoryRepository priceCategoryRepository =
      PriceCategoryRepository();

  Future<void> fetchLedgerGroups() async {
    try {
      List<LedgerGroup> groups = await ledgerGroupService.fetchLedgerGroups();

      setState(() {
        fetchedLedgerGroups = groups;
        selectedLedgerGId = fetchedLedgerGroups[0].id;
      });
    } catch (error) {
      // Handle errors here
      print('Error fetching ledger groups: $error');
    }
  }

  Future<void> fetchPriceCategories() async {
    try {
      List<PriceCategory> categories =
          await priceCategoryRepository.fetchPriceCategories();
      setState(() {
        fetchedPriceCategories = categories;
        selectedPriceCId = fetchedPriceCategories[0].id;
      });

      print('Price Categories: $fetchedPriceCategories');
    } catch (error) {
      // Handle errors here
      print('Error fetching price categories: $error');
    }
  }

  void setRandomNumberToController() {
    Random random = Random();
    int randomNumber = random.nextInt(
        1000000); // Generates a random number between 0 and 999999 (inclusive)
    setState(() {
      controller.ledgerCodeController.text = randomNumber.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLedgerGroups();
    fetchPriceCategories();
    setRandomNumberToController();
    controller.debitBalanceController.text = '0.00';

    setState(() {
      ledgerTitle = 'Dr';
      billwiseAccounting = 'Yes';
      isActived = 'Yes';
    });
  }

  void createLedger() async {
    setState(() {
      _isSaving = true;
    });

    if (controller.nameController.text.isEmpty ||
        controller.printNameController.text.isEmpty ||
        controller.openingBalanceController.text.isEmpty ||
        controller.ledgerCodeController.text.isEmpty ||
        controller.regionController.text.isEmpty ||
        controller.mobileController.text.isEmpty) {
      setState(() {
        _isSaving = false;
      });
      Fluttertoast.showToast(
        msg: 'Please fill all the fields as they are required.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    } else {
      ledgerService.createLedger(
        name: controller.nameController.text,
        printName: controller.printNameController.text,
        aliasName: controller.aliasNameController?.text ?? 'aliasName',
        ledgerGroup: selectedLedgerGId!,
        date: formatter.format(DateTime.now()),
        bilwiseAccounting: billwiseAccounting!,
        creditDays: int.tryParse(controller.creditDaysController!.text) ?? 0,
        openingBalance:
            double.tryParse(controller.openingBalanceController.text) ?? 0.00,
        debitBalance:
            double.tryParse(controller.debitBalanceController.text) ?? 0.00,
        ledgerType: ledgerTitle!,
        priceListCategory: selectedPriceType!,
        remarks: controller.remarksController?.text ?? 'remarks',
        status: isActived!,
        ledgerCode: int.tryParse(controller.ledgerCodeController.text) ?? 0,
        mailingName: controller.mailingNameController?.text ?? '',
        address: controller.addressController?.text ?? '',
        city: controller.cityController?.text ?? '',
        region: controller.regionController.text,
        state: selectedPlaceState,
        pincode: int.tryParse(controller.pincodeController!.text) ?? 0,
        tel: int.tryParse(controller.telController!.text) ?? 0,
        fax: int.tryParse(controller.faxController!.text) ?? 0,
        mobile: int.tryParse(controller.mobileController!.text) ?? 0,
        sms: int.tryParse(controller.smscontroller!.text) ?? 0,
        email: controller.emailController?.text ?? '',
        contactPerson: controller.contactPersonController?.text ?? '',
        bankName: controller.bankNameController?.text ?? '',
        branchName: controller.branchNameController?.text ?? '',
        ifsc: controller.ifscCodeController?.text ?? '',
        accName: controller.accNameController?.text ?? '',
        accNo: controller.accNoController?.text ?? '',
        panNo: controller.panNoController?.text ?? '',
        gst: controller.gstController?.text ?? '',
        gstDated: controller.gstDatedController?.text ?? '',
        cstNo: controller.cstNoController?.text ?? '',
        cstDated: controller.cstNoDatedController?.text ?? '',
        lstNo: controller.lstNoController?.text ?? '',
        lstDated: controller.lstNoDatedController?.text ?? '',
        serviceTaxNo: controller.serviceTypeController?.text ?? '',
        serviceTaxDated: controller.serviceTypeDatedController?.text ?? '',
        registrationType: controller.registrationTypeController?.text ?? '',
        registrationTypeDated:
            controller.registrationTypeDatedController?.text ?? '',
        context: context,
      );

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSaving = false;
      });
    }
  }

  final List<String> ledgers = ['Dr', 'Cr'];
  final List<String> billwiseAccount = ['Yes', 'No'];
  final List<String> isActive = ['Yes', 'No'];
  String? selectedFruit;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return _isSaving
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 215, 215, 215),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 113, 8, 170),
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
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45),
                          Text(
                            'CREATE NEW LEDGER',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: mediaQuery.size.width * 0.48,
                            height: 1164,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 228, 227, 227),
                              border: Border.all(
                                width: 1,

                                //                   <--- border width here
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 113, 8, 170),
                                      ),
                                      child: const SizedBox(
                                        child: Text(
                                          ' NEW Ledger',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            'Basic Details',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.black,
                                              decorationThickness: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: mediaQuery
                                                                  .size.width *
                                                              0.10,
                                                          height: 25,
                                                          child:
                                                              const Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Ledger Name',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            113,
                                                                            8,
                                                                            170),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: '*',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red, // Set the color to red
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _buildTextWidget(
                                                      mediaQuery,
                                                      0.90,
                                                      controller.nameController,
                                                      TextInputType.text,
                                                      false,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                      width: mediaQuery
                                                              .size.width *
                                                          0.10,
                                                      height: 25,
                                                      child: const Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  'Print Name',
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        113,
                                                                        8,
                                                                        170),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '*',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .red, // Set the color to red
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              _buildTextWidget(
                                                mediaQuery,
                                                0.90,
                                                controller.printNameController,
                                                TextInputType.text,
                                                false,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 25,
                                                    child: const Text(
                                                      'Alias',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              _buildTextWidget(
                                                mediaQuery,
                                                0.90,
                                                controller.aliasNameController!,
                                                TextInputType.text,
                                                false,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 25,
                                                    child: const Text(
                                                      'Print Name',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              _buildTextWidget(
                                                mediaQuery,
                                                0.90,
                                                controller.printNameController,
                                                TextInputType.text,
                                                false,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 25,
                                                    child: const Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                'Ledger Group',
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      113,
                                                                      8,
                                                                      170),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '*',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red, // Set the color to red
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // TextButton(
                                              //   onPressed: () {
                                              //     Navigator.of(context)
                                              //         .pushReplacement(
                                              //       MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             const LedgerGroupScreen(),
                                              //       ),
                                              //     );
                                              //   },
                                              //   child: Text(
                                              //     'Add',
                                              //     style: GoogleFonts.roboto(
                                              //       textStyle: const TextStyle(
                                              //         color: Color.fromARGB(
                                              //           255,
                                              //           113,
                                              //           8,
                                              //           170,
                                              //         ),
                                              //         fontWeight:
                                              //             FontWeight.bold,
                                              //         decoration: TextDecoration
                                              //             .underline,
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              Flexible(
                                                child: Container(
                                                  width: mediaQuery.size.width *
                                                      0.90,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: SearchableDropDown(
                                                    controller:
                                                        _searchController,
                                                    searchController:
                                                        _searchController,
                                                    value: selectedLedgerGId,
                                                    onChanged:
                                                        (String? newValue) {
                                                      // Update the state when the user selects a new fruit
                                                      setState(() {
                                                        selectedLedgerGId =
                                                            newValue;
                                                      });
                                                    },
                                                    items: fetchedLedgerGroups
                                                        .map((LedgerGroup
                                                            ledgerGroup) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: ledgerGroup.id,
                                                        child: Text(
                                                            ledgerGroup.name),
                                                      );
                                                    }).toList(),
                                                    searchMatchFn:
                                                        (item, searchValue) {
                                                      final itemMLimit =
                                                          fetchedLedgerGroups
                                                              .firstWhere((e) =>
                                                                  e.id ==
                                                                  item.value)
                                                              .name;
                                                      return itemMLimit
                                                          .toLowerCase()
                                                          .contains(searchValue
                                                              .toLowerCase());
                                                    },
                                                  ),
                                                  // child:
                                                  //     DropdownButtonHideUnderline(
                                                  //   child:
                                                  //       DropdownButton<String>(
                                                  //     underline: Container(),
                                                  //     value: selectedLedgerGId,
                                                  //     items: fetchedLedgerGroups
                                                  //         .map((LedgerGroup
                                                  //             ledgerGroup) {
                                                  //       return DropdownMenuItem<
                                                  //           String>(
                                                  //         value: ledgerGroup.id,
                                                  //         child: Text(
                                                  //             ledgerGroup.name),
                                                  //       );
                                                  //     }).toList(),
                                                  //     onChanged:
                                                  //         (String? newValue) {
                                                  //       // Update the state when the user selects a new fruit
                                                  //       setState(() {
                                                  //         selectedLedgerGId =
                                                  //             newValue;
                                                  //       });
                                                  //     },
                                                  //   ),
                                                  // ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: mediaQuery
                                                                  .size.width *
                                                              0.10,
                                                          height: 30,
                                                          child: const Text(
                                                            'Billwise Accounting',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        113,
                                                                        8,
                                                                        170),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Container(
                                                        width: mediaQuery
                                                                .size.width *
                                                            0.05,
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            underline:
                                                                Container(),
                                                            value:
                                                                billwiseAccounting,
                                                            items:
                                                                billwiseAccount
                                                                    .map((String
                                                                        fruit) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: fruit,
                                                                child:
                                                                    Text(fruit),
                                                              );
                                                            }).toList(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              // Update the state when the user selects a new fruit
                                                              setState(() {
                                                                billwiseAccounting =
                                                                    newValue;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: mediaQuery
                                                                  .size.width *
                                                              0.058,
                                                          height: 30,
                                                          child: const Text(
                                                            'Credit Days',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        113,
                                                                        8,
                                                                        170),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _buildTextWidget(
                                                      mediaQuery,
                                                      0.15,
                                                      controller
                                                          .creditDaysController!,
                                                      TextInputType.number,
                                                      true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: mediaQuery
                                                                  .size.width *
                                                              0.10,
                                                          height: 30,
                                                          child: Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Op. Balance(${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year.toString().substring(2)})',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            113,
                                                                            8,
                                                                            170),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const TextSpan(
                                                                  text: '*',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red, // Set the color to red
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        width: mediaQuery
                                                                .size.width *
                                                            0.05,
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0),
                                                        ),
                                                        child: TextFormField(
                                                          cursorHeight: 18,
                                                          controller: controller
                                                              .openingBalanceController,
                                                          keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                          inputFormatters: <TextInputFormatter>[
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    r'^\d+\.?\d{0,2}')),
                                                            LengthLimitingTextInputFormatter(
                                                                10),
                                                          ],
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    14.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Container(
                                                          width: mediaQuery
                                                                  .size.width *
                                                              0.05,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              underline:
                                                                  Container(),
                                                              value:
                                                                  ledgerTitle,
                                                              items: ledgers
                                                                  .map((String
                                                                      fruit) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: fruit,
                                                                  child: Text(
                                                                      fruit),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                // Update the state when the user selects a new fruit
                                                                setState(() {
                                                                  ledgerTitle =
                                                                      newValue;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 30,
                                                    child: const Text(
                                                      'Debit Balance',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: mediaQuery.size.width *
                                                      0.90,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      cursorHeight: 18,
                                                      onSaved: (newValue) {
                                                        controller
                                                            .debitBalanceController!
                                                            .text = newValue!;
                                                      },
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d{0,2}')),
                                                        LengthLimitingTextInputFormatter(
                                                            10),
                                                      ],
                                                      controller: controller
                                                          .debitBalanceController,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                11.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 30,
                                                    child: const Text(
                                                      'Price List Category',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // TextButton(
                                              //   onPressed: () {
                                              //     Navigator.of(context).push(
                                              //       MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             const LedgerPriceList(),
                                              //       ),
                                              //     );
                                              //   },
                                              //   child: Text(
                                              //     'Add',
                                              //     style: GoogleFonts.roboto(
                                              //       textStyle: const TextStyle(
                                              //         color: Color.fromARGB(
                                              //           255,
                                              //           113,
                                              //           8,
                                              //           170,
                                              //         ),
                                              //         fontWeight:
                                              //             FontWeight.bold,
                                              //         decoration: TextDecoration
                                              //             .underline,
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              Flexible(
                                                child: Container(
                                                  width: mediaQuery.size.width *
                                                      0.90,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      menuMaxHeight: 300,
                                                      isExpanded: true,
                                                      value: selectedPriceType,
                                                      underline: Container(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedPriceType =
                                                              newValue!;
                                                          // controller
                                                          //     .stateController
                                                          //     .text = selectedPlaceState;
                                                        });
                                                      },
                                                      items: pricetype
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(value),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 30,
                                                    child: const Text(
                                                      'Remarks',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: mediaQuery.size.width *
                                                      0.90,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      cursorHeight: 18,
                                                      onSaved: (newValue) {
                                                        controller
                                                            .remarksController!
                                                            .text = newValue!;
                                                      },
                                                      controller: controller
                                                          .remarksController,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                10.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        mediaQuery.size.width *
                                                            0.10,
                                                    height: 30,
                                                    child: const Text(
                                                      'Is Active',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 113, 8, 170),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: mediaQuery.size.width *
                                                      0.09,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      underline: Container(),
                                                      value: isActived,
                                                      items: isActive
                                                          .map((String fruit) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: fruit,
                                                          child: Text(fruit),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        // Update the state when the user selects a new fruit
                                                        setState(() {
                                                          isActived = newValue;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                children: [
                                  Container(
                                    width: mediaQuery.size.width * 0.48,
                                    height: 809,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 228, 227, 227),
                                      border: Border.all(
                                        width:
                                            1, //                   <--- border width here
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: mediaQuery.size.width * 0.06,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      'Mailing Details',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            Colors.black,
                                                        decorationThickness:
                                                            1.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Ledger Code',
                                                                  0.10,
                                                                  '*'),
                                                              TextButton(
                                                                onPressed: () {
                                                                  setRandomNumberToController();
                                                                },
                                                                child: Text(
                                                                  'Generate',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    textStyle:
                                                                        const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          113,
                                                                          8,
                                                                          170),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              _buildTextWidget(
                                                                  mediaQuery,
                                                                  0.01,
                                                                  controller
                                                                      .ledgerCodeController,
                                                                  TextInputType
                                                                      .number,
                                                                  true),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'Mailing Name',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.90,
                                                          controller
                                                              .mailingNameController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: SizedBox(
                                                              width: mediaQuery
                                                                      .size
                                                                      .width *
                                                                  0.10,
                                                              height: 25,
                                                              child: const Text(
                                                                'Address',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            113,
                                                                            8,
                                                                            170),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Change Here
                                                        Flexible(
                                                          flex: 3,
                                                          child: Container(
                                                            width: mediaQuery
                                                                    .size
                                                                    .width *
                                                                0.99,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  TextFormField(
                                                                maxLines: 2,
                                                                onSaved:
                                                                    (newValue) {
                                                                  controller
                                                                          .addressController!
                                                                          .text =
                                                                      newValue!;
                                                                },
                                                                controller:
                                                                    controller
                                                                        .addressController,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Region',
                                                                  0.095,
                                                                  '*'),
                                                              _buildTextWidget(
                                                                  mediaQuery,
                                                                  0.60,
                                                                  controller
                                                                      .regionController,
                                                                  TextInputType
                                                                      .text,
                                                                  false),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'State',
                                                                  0.04,
                                                                  '*'),
                                                              // _buildTextWidget(
                                                              //   mediaQuery,
                                                              //   0.20,
                                                              //   controller
                                                              //       .stateController,
                                                              //   TextInputType
                                                              //       .text,
                                                              //   false,
                                                              // ),

                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border:
                                                                            Border.all()),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                                height: 40,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        2.0),
                                                                child:
                                                                    DropdownButtonHideUnderline(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    menuMaxHeight:
                                                                        300,
                                                                    isExpanded:
                                                                        true,
                                                                    value:
                                                                        selectedPlaceState,
                                                                    underline:
                                                                        Container(),
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        selectedPlaceState =
                                                                            newValue!;
                                                                        // controller
                                                                        //     .stateController
                                                                        //     .text = selectedPlaceState;
                                                                      });
                                                                    },
                                                                    items: placestate
                                                                        .map((String
                                                                            value) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.0),
                                                                          child:
                                                                              Text(value),
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(mediaQuery,
                                                            'City', 0.095, ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .cityController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        _buildText(mediaQuery,
                                                            'Fax No', 0.04, ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.20,
                                                          controller
                                                              .faxController!,
                                                          TextInputType.phone,
                                                          true,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Pincode',
                                                                  0.095,
                                                                  ''),
                                                              _buildTextWidget(
                                                                  mediaQuery,
                                                                  0.60,
                                                                  controller
                                                                      .pincodeController!,
                                                                  TextInputType
                                                                      .number,
                                                                  true),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Tele NO',
                                                                  0.04,
                                                                  ''),
                                                              _buildTextWidget(
                                                                mediaQuery,
                                                                0.20,
                                                                controller
                                                                    .telController!,
                                                                TextInputType
                                                                    .phone,
                                                                true,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Mobile No',
                                                                  0.095,
                                                                  '*'),
                                                              _buildTextWidget(
                                                                mediaQuery,
                                                                0.30,
                                                                controller
                                                                    .mobileController!,
                                                                TextInputType
                                                                    .phone,
                                                                true,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              _buildText(
                                                                  mediaQuery,
                                                                  'Mobile 2',
                                                                  0.04,
                                                                  ''),
                                                              _buildTextWidget(
                                                                mediaQuery,
                                                                0.20,
                                                                controller
                                                                    .smscontroller!,
                                                                TextInputType
                                                                    .phone,
                                                                true,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'Email Address',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.90,
                                                          controller
                                                              .emailController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'Contact Person',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.90,
                                                          controller
                                                              .contactPersonController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'Bank Name',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .bankNameController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'Branch Name',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .branchNameController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'IFSC Code',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .ifscCodeController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'A/c Name',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .accNameController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                            mediaQuery,
                                                            'A/c No.',
                                                            0.095,
                                                            ''),
                                                        _buildTextWidget(
                                                          mediaQuery,
                                                          0.30,
                                                          controller
                                                              .accNoController!,
                                                          TextInputType.text,
                                                          false,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: mediaQuery.size.width * 0.48,
                                    height: 355,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 228, 227, 227),
                                      border: Border.all(
                                        width:
                                            1, //                   <--- border width here
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: mediaQuery.size.width * 0.06,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  'Tax Information',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        Colors.black,
                                                    decorationThickness: 1.5,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  PAN No.',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .panNoController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  GST No.',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .gstController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // _buildRowWidget(
                                                  //   mediaQuery,
                                                  //   'GST NO',
                                                  //   controller.gstController!,
                                                  //   controller
                                                  //       .gstDatedController!,
                                                  // ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  Registration Type',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .registrationTypeController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // _buildRowWidget(
                                                  //   mediaQuery,
                                                  //   'Registration Type',
                                                  //   controller
                                                  //       .registrationTypeController!,
                                                  //   controller
                                                  //       .registrationTypeDatedController!,
                                                  // ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  CST No.',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .cstNoController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // _buildRowWidget(
                                                  //   mediaQuery,
                                                  //   'CST NO',
                                                  //   controller.cstNoController!,
                                                  //   controller
                                                  //       .cstNoDatedController!,
                                                  // ),

                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  LST No.',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .lstNoController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // _buildRowWidget(
                                                  //   mediaQuery,
                                                  //   'LST NO',
                                                  //   controller.lstNoController!,
                                                  //   controller
                                                  //       .lstNoDatedController!,
                                                  // ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildText(
                                                                mediaQuery,
                                                                '  Service Tax No. ',
                                                                0.10,
                                                                ''),
                                                            _buildTextWidget(
                                                              mediaQuery,
                                                              0.40,
                                                              controller
                                                                  .serviceTypeController!,
                                                              TextInputType
                                                                  .text,
                                                              false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // _buildRowWidget(
                                                  //   mediaQuery,
                                                  //   'Service Tax No',
                                                  //   controller
                                                  //       .serviceTypeController!,
                                                  //   controller
                                                  //       .serviceTypeDatedController!,
                                                  // ),
                                                ],
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Container(
                            alignment: Alignment.center,
                            width: mediaQuery.size.width * 0.96,
                            height: 65,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 228, 227, 227),
                              border: Border.all(
                                width:
                                    1, //                   <--- border width here
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.10,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      child: SizedBox(
                                        child: ElevatedButton(
                                          onPressed: createLedger,
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              const Color.fromARGB(
                                                  172, 236, 226, 137),
                                            ),
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0),
                                                side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 88, 81, 11),
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Save [F4]',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.10,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                const Color.fromARGB(
                                                    172, 236, 226, 137),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  OutlinedBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.0),
                                                  side: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 88, 81, 11),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            child: const Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w900),
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Footer(
                    //   backgroundColor: const Color.fromARGB(255, 215, 215, 215),
                    //   padding: const EdgeInsets.only(
                    //     top: 5,
                    //   ),
                    //   child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Row(children: [
                    //           Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Padding(
                    //                 padding: EdgeInsets.only(
                    //                   left: MediaQuery.of(context).size.width *
                    //                       0.01,
                    //                 ),
                    //                 child: Container(
                    //                   decoration: BoxDecoration(
                    //                     color: const Color.fromARGB(
                    //                         255, 228, 227, 227),
                    //                     border: Border.all(
                    //                       width:
                    //                           1, //                   <--- border width here
                    //                     ),
                    //                   ),
                    //                   child: Row(
                    //                     children: [
                    //                       Column(
                    //                         children: [
                    //                           Padding(
                    //                             padding: const EdgeInsets.only(
                    //                                 left: 5),
                    //                             child: Container(
                    //                               width: MediaQuery.of(context)
                    //                                       .size
                    //                                       .width *
                    //                                   0.70,
                    //                               height: 88,
                    //                               padding:
                    //                                   const EdgeInsets.all(1.0),
                    //                               child: const Padding(
                    //                                 padding:
                    //                                     EdgeInsets.all(8.0),
                    //                                 child: Text(
                    //                                   'Fuerte Developers',
                    //                                   textAlign:
                    //                                       TextAlign.center,
                    //                                   style: TextStyle(
                    //                                     color: Color.fromARGB(
                    //                                         255, 0, 0, 0),
                    //                                     fontSize: 25,
                    //                                     fontWeight:
                    //                                         FontWeight.w600,
                    //                                     decoration:
                    //                                         TextDecoration
                    //                                             .underline,
                    //                                     decorationColor:
                    //                                         Color.fromARGB(
                    //                                             255, 0, 0, 0),
                    //                                     decorationThickness:
                    //                                         1.5,
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                           Padding(
                    //                             padding: const EdgeInsets.only(
                    //                                 top: 10.0, bottom: 10.0),
                    //                             child: Row(
                    //                               mainAxisAlignment:
                    //                                   MainAxisAlignment.start,
                    //                               children: [
                    //                                 Column(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   children: [
                    //                                     SizedBox(
                    //                                       width: 150,
                    //                                       height: 30,
                    //                                       child: SizedBox(
                    //                                         child:
                    //                                             ElevatedButton(
                    //                                           onPressed: () {},
                    //                                           style:
                    //                                               ButtonStyle(
                    //                                             backgroundColor:
                    //                                                 MaterialStateProperty
                    //                                                     .all<
                    //                                                         Color>(
                    //                                               const Color
                    //                                                   .fromARGB(
                    //                                                   255,
                    //                                                   228,
                    //                                                   227,
                    //                                                   227),
                    //                                             ),
                    //                                             shape: MaterialStateProperty
                    //                                                 .all<
                    //                                                     OutlinedBorder>(
                    //                                               RoundedRectangleBorder(
                    //                                                 borderRadius:
                    //                                                     BorderRadius.circular(
                    //                                                         1.0),
                    //                                                 side:
                    //                                                     const BorderSide(
                    //                                                   color: Color.fromARGB(
                    //                                                       255,
                    //                                                       88,
                    //                                                       81,
                    //                                                       11),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                           child:
                    //                                               const Align(
                    //                                             alignment:
                    //                                                 Alignment
                    //                                                     .center,
                    //                                             child: Text(
                    //                                               'Accounts',
                    //                                               style:
                    //                                                   TextStyle(
                    //                                                 color: Colors
                    //                                                     .black,
                    //                                                 fontSize:
                    //                                                     16,
                    //                                                 fontWeight:
                    //                                                     FontWeight
                    //                                                         .w900,
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                                 Column(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .only(
                    //                                               left: 15),
                    //                                       child: SizedBox(
                    //                                         width: 120,
                    //                                         height: 30,
                    //                                         child: SizedBox(
                    //                                           width: MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width *
                    //                                               0,
                    //                                           child:
                    //                                               ElevatedButton(
                    //                                             onPressed:
                    //                                                 () {},
                    //                                             style:
                    //                                                 ButtonStyle(
                    //                                               backgroundColor:
                    //                                                   MaterialStateProperty
                    //                                                       .all<
                    //                                                           Color>(
                    //                                                 const Color
                    //                                                     .fromARGB(
                    //                                                     255,
                    //                                                     228,
                    //                                                     227,
                    //                                                     227),
                    //                                               ),
                    //                                               shape: MaterialStateProperty
                    //                                                   .all<
                    //                                                       OutlinedBorder>(
                    //                                                 RoundedRectangleBorder(
                    //                                                   borderRadius:
                    //                                                       BorderRadius.circular(
                    //                                                           1.0),
                    //                                                   side:
                    //                                                       const BorderSide(
                    //                                                     color: Color.fromARGB(
                    //                                                         255,
                    //                                                         88,
                    //                                                         81,
                    //                                                         11),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                             child:
                    //                                                 const Align(
                    //                                               alignment:
                    //                                                   Alignment
                    //                                                       .center,
                    //                                               child: Text(
                    //                                                 'Inventory',
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .black,
                    //                                                     fontSize:
                    //                                                         16,
                    //                                                     fontWeight:
                    //                                                         FontWeight.w900),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                                 Column(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .only(
                    //                                               left: 15),
                    //                                       child: SizedBox(
                    //                                         width: 90,
                    //                                         height: 30,
                    //                                         child: SizedBox(
                    //                                           width: MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width *
                    //                                               0,
                    //                                           child:
                    //                                               ElevatedButton(
                    //                                             onPressed:
                    //                                                 () {},
                    //                                             style:
                    //                                                 ButtonStyle(
                    //                                               backgroundColor:
                    //                                                   MaterialStateProperty
                    //                                                       .all<
                    //                                                           Color>(
                    //                                                 const Color
                    //                                                     .fromARGB(
                    //                                                     255,
                    //                                                     228,
                    //                                                     227,
                    //                                                     227),
                    //                                               ),
                    //                                               shape: MaterialStateProperty
                    //                                                   .all<
                    //                                                       OutlinedBorder>(
                    //                                                 RoundedRectangleBorder(
                    //                                                   borderRadius:
                    //                                                       BorderRadius.circular(
                    //                                                           1.0),
                    //                                                   side:
                    //                                                       const BorderSide(
                    //                                                     color: Color.fromARGB(
                    //                                                         255,
                    //                                                         88,
                    //                                                         81,
                    //                                                         11),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                             child:
                    //                                                 const Align(
                    //                                               alignment:
                    //                                                   Alignment
                    //                                                       .center,
                    //                                               child: Text(
                    //                                                 'SMS',
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .black,
                    //                                                     fontSize:
                    //                                                         16,
                    //                                                     fontWeight:
                    //                                                         FontWeight.w900),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                                 Column(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .only(
                    //                                               left: 15),
                    //                                       child: SizedBox(
                    //                                         width: 100,
                    //                                         height: 30,
                    //                                         child: SizedBox(
                    //                                           width: MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width *
                    //                                               0,
                    //                                           child:
                    //                                               ElevatedButton(
                    //                                             onPressed:
                    //                                                 () {},
                    //                                             style:
                    //                                                 ButtonStyle(
                    //                                               backgroundColor:
                    //                                                   MaterialStateProperty
                    //                                                       .all<
                    //                                                           Color>(
                    //                                                 const Color
                    //                                                     .fromARGB(
                    //                                                     255,
                    //                                                     228,
                    //                                                     227,
                    //                                                     227),
                    //                                               ),
                    //                                               shape: MaterialStateProperty
                    //                                                   .all<
                    //                                                       OutlinedBorder>(
                    //                                                 RoundedRectangleBorder(
                    //                                                   borderRadius:
                    //                                                       BorderRadius.circular(
                    //                                                           1.0),
                    //                                                   side:
                    //                                                       const BorderSide(
                    //                                                     color: Color.fromARGB(
                    //                                                         255,
                    //                                                         88,
                    //                                                         81,
                    //                                                         11),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                             child:
                    //                                                 const Align(
                    //                                               alignment:
                    //                                                   Alignment
                    //                                                       .center,
                    //                                               child: Text(
                    //                                                 'Admin',
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .black,
                    //                                                     fontSize:
                    //                                                         16,
                    //                                                     fontWeight:
                    //                                                         FontWeight.w900),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                                 Column(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .only(
                    //                                               left: 15),
                    //                                       child: SizedBox(
                    //                                         width: 100,
                    //                                         height: 30,
                    //                                         child: SizedBox(
                    //                                           width: MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width *
                    //                                               0,
                    //                                           child:
                    //                                               ElevatedButton(
                    //                                             onPressed:
                    //                                                 () {},
                    //                                             style:
                    //                                                 ButtonStyle(
                    //                                               backgroundColor:
                    //                                                   MaterialStateProperty
                    //                                                       .all<
                    //                                                           Color>(
                    //                                                 const Color
                    //                                                     .fromARGB(
                    //                                                     255,
                    //                                                     228,
                    //                                                     227,
                    //                                                     227),
                    //                                               ),
                    //                                               shape: MaterialStateProperty
                    //                                                   .all<
                    //                                                       OutlinedBorder>(
                    //                                                 RoundedRectangleBorder(
                    //                                                   borderRadius:
                    //                                                       BorderRadius.circular(
                    //                                                           1.0),
                    //                                                   side:
                    //                                                       const BorderSide(
                    //                                                     color: Color.fromARGB(
                    //                                                         255,
                    //                                                         88,
                    //                                                         81,
                    //                                                         11),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                             child:
                    //                                                 const Align(
                    //                                               alignment:
                    //                                                   Alignment
                    //                                                       .center,
                    //                                               child: Text(
                    //                                                 'Utility',
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .black,
                    //                                                     fontSize:
                    //                                                         16,
                    //                                                     fontWeight:
                    //                                                         FontWeight.w900),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           )
                    //                         ],
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Container(
                    //                 width: MediaQuery.of(context).size.width *
                    //                     0.27,
                    //                 height: 140,
                    //                 decoration: BoxDecoration(
                    //                   color: const Color.fromARGB(
                    //                       255, 228, 227, 227),
                    //                   border: Border.all(
                    //                     width: 1,
                    //                   ),
                    //                 ),
                    //                 child: Column(
                    //                   children: [
                    //                     SizedBox(
                    //                       width: MediaQuery.of(context)
                    //                               .size
                    //                               .width *
                    //                           0.27,
                    //                       height: 75,
                    //                       child: Padding(
                    //                         padding:
                    //                             const EdgeInsets.only(top: 5),
                    //                         child: Image.asset(
                    //                           'images/logo.png',
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         Column(
                    //                           mainAxisAlignment:
                    //                               MainAxisAlignment.center,
                    //                           children: [
                    //                             SizedBox(
                    //                               width: MediaQuery.of(context)
                    //                                       .size
                    //                                       .width *
                    //                                   0.12,
                    //                               height: 15,
                    //                               child: const Text(
                    //                                 'www.fuertedevelopers.in',
                    //                                 style: TextStyle(
                    //                                     fontWeight:
                    //                                         FontWeight.w600,
                    //                                     fontSize: 12.0,
                    //                                     color: Color.fromARGB(
                    //                                         255, 0, 0, 0)),
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                         Column(
                    //                           children: [
                    //                             SizedBox(
                    //                               width: MediaQuery.of(context)
                    //                                       .size
                    //                                       .width *
                    //                                   0.12,
                    //                               height: 15,
                    //                               child: const Text(
                    //                                 'Ph: +91 799 0486 477',
                    //                                 style: TextStyle(
                    //                                     fontWeight:
                    //                                         FontWeight.w600,
                    //                                     fontSize: 12.0,
                    //                                     color: Color.fromARGB(
                    //                                         255, 0, 0, 0)),
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         )
                    //                       ],
                    //                     ),
                    //                     Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(top: 25),
                    //                       child: Container(
                    //                         width: mediaQuery.size.width * 1,
                    //                         decoration: BoxDecoration(
                    //                           color: const Color.fromARGB(
                    //                               255, 0, 0, 0),
                    //                           border: Border.all(
                    //                             width: 1,
                    //                           ),
                    //                         ),
                    //                         child: Column(
                    //                           children: [
                    //                             Text(
                    //                               'Copyright ©${DateTime.now().year}, All Rights Reserved. | Powered by Fuerte Developers',
                    //                               style: const TextStyle(
                    //                                   fontWeight:
                    //                                       FontWeight.w300,
                    //                                   fontSize: 12.0,
                    //                                   color: Color.fromARGB(
                    //                                       255, 253, 253, 253)),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ]),
                    //       ]),
                    // )
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = formattedDate;
      print(controller.text);
    }
  }

  Row _buildRowWidget(
    MediaQueryData mediaQuery,
    String text1,
    TextEditingController controller1,
    TextEditingController controller2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildText(mediaQuery, text1, 0.10, ''),
        _buildTextWidget(
          mediaQuery,
          0.26,
          controller1,
          TextInputType.text,
          false,
        ),
        const SizedBox(
          width: 10,
        ),
        _buildText(mediaQuery, 'Dated', 0.04, ''),
        _buildTextWidget(
          mediaQuery,
          0.20,
          controller2,
          TextInputType.text,
          false,
        ),
        IconButton(
          onPressed: () {
            selectDate(context, controller2);
          },
          icon: const Icon(
            Icons.calendar_today,
            size: 15,
          ),
          color: Colors.black,
        ),
      ],
    );
  }

  Flexible _buildText(
      MediaQueryData mediaQuery, String text, double width, String? text2) {
    return Flexible(
      child: SizedBox(
        width: mediaQuery.size.width * width,
        height: 25,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text,
                style: const TextStyle(
                  color: Color.fromARGB(255, 113, 8, 170),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: text2,
                style: const TextStyle(
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildTextWidget(
    MediaQueryData mediaQuery,
    double width,
    TextEditingController controller,
    TextInputType? keyboardType,
    bool? enableFormatting,
  ) {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * width,
          maxHeight: 40,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(0),
        ),
        child: TextFormField(
          cursorHeight: 18,
          keyboardType: keyboardType ?? TextInputType.number,
          inputFormatters: enableFormatting != null && enableFormatting
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          onSaved: (newValue) {
            controller.text = newValue!;
          },
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(14.0),
          ),
        ),
      ),
    );
  }
}
