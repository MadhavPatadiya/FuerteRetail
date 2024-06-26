import 'package:billingsphere/views/RA_widgets/RA_D_side_buttons.dart';
import 'package:billingsphere/views/RA_widgets/RA_M_Button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DB_widgets/custom_footer.dart';
import 'sales_register_show.dart';

class SalesRegisterDesktop extends StatefulWidget {
  const SalesRegisterDesktop({
    super.key,
  });

  @override
  State<SalesRegisterDesktop> createState() => _SalesRegisterDesktopState();
}

class _SalesRegisterDesktopState extends State<SalesRegisterDesktop> {
  DateTime? startDate;
  DateTime? endDate;

  String dropdownValue = 'All';

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Register',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 143, 7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  // const RACustomAppBar(
                  //   text: 'Stock Voucher',
                  //   color: Color.fromARGB(255, 33, 65, 243),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.01,
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 550,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 350,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Report Critaria',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              child: const Text(
                                                '  Date Range',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10,
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Show Date Picker for Start Date
                                                  showDatePicker(
                                                    context: context,
                                                    initialDate: startDate ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                    builder:
                                                        (BuildContext context,
                                                            Widget? child) {
                                                      return Theme(
                                                        data: ThemeData
                                                            .light(), // Change to dark if needed
                                                        child: child!,
                                                      );
                                                    },
                                                  ).then(
                                                      (DateTime? selectedDate) {
                                                    if (selectedDate != null) {
                                                      setState(() {
                                                        startDate =
                                                            selectedDate;
                                                      });
                                                    }
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                  elevation:
                                                      MaterialStateProperty.all<
                                                              double>(
                                                          0), // Remove elevation
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      side: const BorderSide(
                                                          color: Colors
                                                              .black), // Border color
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  startDate != null
                                                      ? dateFormat
                                                          .format(startDate!)
                                                      : 'Start Date',
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .black, // Text color
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              'to',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10,
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Show Date Picker for End Date with constraints
                                                  showDatePicker(
                                                    context: context,
                                                    initialDate: endDate ??
                                                        DateTime.now(),
                                                    firstDate: startDate ??
                                                        DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                    builder:
                                                        (BuildContext context,
                                                            Widget? child) {
                                                      return Theme(
                                                        data: ThemeData
                                                            .light(), // Change to dark if needed
                                                        child: child!,
                                                      );
                                                    },
                                                  ).then(
                                                      (DateTime? selectedDate) {
                                                    if (selectedDate != null) {
                                                      setState(() {
                                                        endDate = selectedDate;
                                                      });
                                                    }
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                  elevation:
                                                      MaterialStateProperty.all<
                                                              double>(
                                                          0), // Remove elevation
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      side: const BorderSide(
                                                          color: Colors
                                                              .black), // Border color
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  endDate != null
                                                      ? dateFormat
                                                          .format(endDate!)
                                                      : 'End Date',
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .black, // Text color
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              child: const Text(
                                                '  Format',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.225,
                                              height: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(
                                                              0.5), // Add shadow color
                                                      spreadRadius:
                                                          2, // Spread radius
                                                      blurRadius:
                                                          2, // Blur radius
                                                      offset: const Offset(0,
                                                          1), // Offset of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: dropdownValue,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      dropdownValue = newValue!;
                                                    });
                                                  },
                                                  items: <String>[
                                                    'All',
                                                    'Inward',
                                                    'Outward'
                                                  ].map<
                                                      DropdownMenuItem<String>>(
                                                    (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0,
                                                              vertical:
                                                                  4.0), // Add padding to text
                                                          child: Text(
                                                            value,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                  dropdownColor: Colors
                                                      .white, // Set dropdown background color
                                                  icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.black,
                                                  ), // Customize dropdown icon
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  underline:
                                                      Container(), // Remove the underline
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 250,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.01,
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.01,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.055,
                                                    ),
                                                    RAMButtons(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.11,
                                                      height: 30,
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SalesRegisterShow(
                                                              startDate:
                                                                  startDate,
                                                              endDate: endDate,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      text: 'Show [F4]',
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: RAMButtons(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.11,
                                                        height: 30,
                                                        text: 'Close',
                                                      ),
                                                    ),
                                                  ],
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: 700,
                child: Column(
                  children: [
                    DSideBUtton(
                      onTapped: () {},
                      text: 'P Print',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: 'F2 Report',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: 'F5 Make Receipt',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                    DSideBUtton(
                      onTapped: () {},
                      text: '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }
}
