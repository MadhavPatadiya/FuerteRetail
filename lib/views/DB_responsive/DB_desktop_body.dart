import 'dart:async';
import 'package:billingsphere/views/DB_widgets/Desktop_widgets/d_custom_buttons.dart';
import 'package:billingsphere/views/DB_widgets/Desktop_widgets/d_custom_todo.dart';
import 'package:billingsphere/views/DB_widgets/Desktop_widgets/d_custome_remainder.dart';
import 'package:billingsphere/views/DB_widgets/custom_footer.dart';
import 'package:billingsphere/views/RA_homepage.dart';
import 'package:billingsphere/views/RV_homepage.dart';
import 'package:billingsphere/views/SE_responsive/SE_desktop_body_POS.dart';
import 'package:billingsphere/views/menu/menubar%20_onwer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../PA_homepage.dart';
import '../../data/models/user/user_group_model.dart';
import '../../data/repository/user_group_repository.dart';
import '../CM_responsive/CM_new_desktop_body.dart';
import '../CM_responsive/blank_desktop_body.dart';
import '../DB_widgets/Desktop_widgets/d_custom_table.dart';
import '../DC_responsive/DC_receipt.dart';
import '../LG_responsive/LG_HOME.dart';
import '../Ledger_statement_responsive/ledger_statement_desktop.dart';
import '../NI_responsive.dart/NI_home.dart';
import '../PEresponsive/PE_desktop_body.dart';
import '../PEresponsive/PE_edit_desktop_body.dart';
import '../PM_homepage.dart';
import '../PM_responsive/payment_home.dart';
import '../PM_responsive/payment_receipt2.dart';
import '../RV_responsive/RV_desktopBody.dart';
import '../SE_homepage.dart';
import '../SE_responsive/SE_desktop_body.dart';
import '../SE_responsive/SE_master.dart';
import '../SE_responsive/SE_multimode.dart';
import '../SE_responsive/SE_receipt_2.dart';
import '../SE_responsive/SalesEditScreen.dart';
import '../Sales_Register/sales_register_desktop.dart';
import '../Stock_Status/stock_status.dart';
import '../Stock_Status/stock_status_filter.dart';
import '../TrailBalance_resposive/trail_balance.dart';
import '../menu/menubar.dart';
import '../paginated_datatable_test.dart';
import '../stock_voucher/stock_voucher_desktop.dart';
import '../item_brand_edit.dart';

class DBMyDesktopBody extends StatefulWidget {
  const DBMyDesktopBody({super.key});

  @override
  State<DBMyDesktopBody> createState() => _DBMyDesktopBodyState();
}

class _DBMyDesktopBodyState extends State<DBMyDesktopBody> {
  late SharedPreferences _prefs;
  List<String> _companies = [];
  String? userGroup = '';
  String? email = '';
  String? fullName = '';
  UserGroupServices userGroupServices = UserGroupServices();
  List<UserGroup> userGroupM = [];
  bool isLoading = false;
  Future<void> fetchUserGroup() async {
    final List<UserGroup> userGroupFetch =
        await userGroupServices.getUserGroups();

    setState(() {
      userGroupM = userGroupFetch;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      _initPrefs().then((value) => {
            _companies = (_prefs.getStringList('companies') ?? []),
            userGroup = _prefs.getString('usergroup'),
            email = _prefs.getString('email'),
            fullName = _prefs.getString('fullName'),
          }),
      fetchUserGroup().then((value) => {}),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  void navigateSales() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.sales == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Sales page.'),
              actions: <Widget>[
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
        return;
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Select Sales Type'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DButtons(
                      text: 'POS',
                      onPressed: () {
                        // pop
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesReturn(),
                          ),
                        );
                      },
                    ),
                    DButtons(
                      text: 'Normal',
                      onPressed: () {
                        // pop
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SEMyDesktopBody(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            });
      }
    }
  }

  void navigateReceipt() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.receipt2 == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Receipt page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RVHomePage(),
          ),
        );
      }
    }
  }

  void navigatePurchase() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.purchase == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Purchase page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PEMyDesktopBody(),
          ),
        );
      }
    }
  }

  void navigatePayment() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.payment == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Payment page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PMHomePage()),
        );
      }
    }
  }

  void navigateReceivable() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.stock == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Receivable page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RAhomepage(),
          ),
        );
      }
    }
  }

  void navigatePayable() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.ownerGroup == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Payable page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PAHomepage(),
          ),
        );
      }
    }
  }

  void navigateLedger() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.addMaster == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Ledger page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LedgerHome(),
          ),
        );
      }
    }
  }

  void navigateItem() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.jobcard == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You do not have access to Item page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ItemHome(),
          ),
        );
      }
    }
  }

  void navigateLedgerStmnt() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.receiptNote == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content: const Text(
                  'You do not have access to Ledger Statement page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LedgerStmnt(),
          ),
        );
      }
    }
  }

  void navigateStockStatus() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.deliveryNote == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content:
                  const Text('You do not have access to Stock Status page.'),
              actions: <Widget>[
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
        return;
      } else {
        userGroup == "Owner"
            ? Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StockFilter(),
                ),
              )
            : Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StockStatus(),
                ),
              );
      }
    }
  }

  void navigateStockVoucher() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.purchaseOrder == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content:
                  const Text('You do not have access to Stock Vouchers page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const StockVoucherDesktopBody(),
          ),
        );
      }
    }
  }

  void navigateSalesRegister() {
    if (userGroup != "Admin" || userGroup != "Owner") {
      var matchedGroup = userGroupM.firstWhere(
        (e) => e.userGroupName == userGroup,
      );

      if (matchedGroup.salesOrder == "No") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Denied'),
              content:
                  const Text('You do not have access to Sales Register page.'),
              actions: <Widget>[
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
        return;
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SalesRegisterDesktop(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.f3): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.f4): const ActivateIntent(),
      },
      child: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyA) {
            navigateSales();
            return KeyEventResult.handled;
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyB) {
            navigateReceipt();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyC) {
            navigatePurchase();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyD) {
            navigatePayment();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyE) {
            navigateReceivable();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyF) {
            navigatePayable();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.digit1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DataTablePaginationExample(),
              ),
            );
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.digit2) {
            navigateLedgerStmnt();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyS) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PaymentVoucherPrint(
                    receiptID: '667962daa01283cb4eed2972', ''),
              ),
            );
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyM) {
            navigateLedger();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyN) {
            navigateItem();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.digit6) {
            navigateStockStatus();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.digit7) {
            navigateStockVoucher();
          } else if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.digit8) {
            navigateSalesRegister();
          }
          return KeyEventResult.ignored;
        },
        child: isLoading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.white38,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.0859,
                            vertical: screenHeight * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: (userGroup == "Admin" ||
                                      userGroup == "Owner"),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Container(
                                      // Top Buttons
                                      width: screenWidth * 0.4,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: userGroup == "Admin"
                                          ? CustomAppBarMenuAdmin
                                              .buildTitleMenu(context)
                                          : (userGroup == "Owner"
                                              ? CustomAppBarMenuOwner
                                                  .buildTitleMenu(context)
                                              : const Text('')),
                                    ),
                                  ),
                                ),
                                // Icon button with power off, color red
                                const Spacer(),
                                SizedBox(
                                  child: Text(
                                    '$fullName | $email',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.power_settings_new,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Logout',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          content: Text(
                                            'Are you sure you want to logout?',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'No',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _prefs.clear();
                                                setState(() {});

                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const BlankScreen(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Yes',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: screenWidth * 0.4,
                                  height: 565,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 208, 31, 34),
                                        ),
                                        child: const Text(
                                          'QUICK ACCESS',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                // Transaction
                                                SizedBox(
                                                  width: screenWidth * 0.15,
                                                  height: 240,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Transactions',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 208, 31, 34),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  208,
                                                                  31,
                                                                  34),
                                                          decorationThickness:
                                                              2.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .sales !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'a) Sales',
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Select Sales Type'),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        DButtons(
                                                                          text:
                                                                              'POS',
                                                                          onPressed:
                                                                              () {
                                                                            // pop
                                                                            Navigator.pop(context);
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => const SalesReturn(),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                        DButtons(
                                                                          text:
                                                                              'Normal',
                                                                          onPressed:
                                                                              () {
                                                                            // pop
                                                                            Navigator.pop(context);
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => const SEMyDesktopBody(),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .receipt2 !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'b) Receipt',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const RVHomePage(),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .purchase !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'c) Purchase',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const PEMyDesktopBody(),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .payment !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'd) Payment',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const PMHomePage()),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .stock !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'e) Receivable',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const RAhomepage(),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Visibility(
                                                        visible: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner") ||
                                                            userGroupM
                                                                    .firstWhere(
                                                                      (e) =>
                                                                          e.userGroupName ==
                                                                          userGroup,
                                                                    )
                                                                    .ownerGroup !=
                                                                "No",
                                                        child: DButtons(
                                                          text: 'f) Payable',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const PAHomepage(),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  width: screenWidth * 0.15,
                                                  height: 140,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Account Reports',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 208, 31, 34),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  208,
                                                                  31,
                                                                  34),
                                                          decorationThickness:
                                                              2.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      DButtons(
                                                        text:
                                                            '1) Trial Balance',
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const DataTablePaginationExample(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 1),
                                                      DButtons(
                                                        isDisabled: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .receiptNote !=
                                                                    "No")
                                                            ? false
                                                            : true,
                                                        text:
                                                            '2) Ledger Stmnt.',
                                                        onPressed: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .receiptNote !=
                                                                    "No")
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const LedgerStmnt(),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                      ),
                                                      const SizedBox(height: 1),
                                                      DButtons(
                                                        text:
                                                            '3) Voucher Regi.',
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  StockFilter(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: screenWidth * 0.15,
                                                  height: 110,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Masters',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 208, 31, 34),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  208,
                                                                  31,
                                                                  34),
                                                          decorationThickness:
                                                              2.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      DButtons(
                                                        text: 'm) Ledgers',
                                                        onPressed: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .addMaster !=
                                                                    "No")
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const LedgerHome(),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                      ),
                                                      const SizedBox(height: 1),
                                                      DButtons(
                                                        text: 'n) Items',
                                                        onPressed: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .jobcard !=
                                                                    "No")
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const ItemHome(),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  width: screenWidth * 0.15,
                                                  height: 140,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Inventory Reports',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 208, 31, 34),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  208,
                                                                  31,
                                                                  34),
                                                          decorationThickness:
                                                              2.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      userGroup == "Owner"
                                                          ? DButtons(
                                                              text:
                                                                  '6) Stock Status',
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const StockFilter(),
                                                                  ),
                                                                );
                                                              })
                                                          : DButtons(
                                                              text:
                                                                  '6) Stock Status',
                                                              onPressed: (userGroup == "Admin" ||
                                                                      userGroup ==
                                                                          "Owner" ||
                                                                      userGroupM
                                                                              .firstWhere((e) => e.userGroupName == userGroup)
                                                                              .deliveryNote !=
                                                                          "No")
                                                                  ? () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const StockStatus(),
                                                                        ),
                                                                      );
                                                                    }
                                                                  : null,
                                                            ),
                                                      const SizedBox(height: 1),
                                                      DButtons(
                                                        text:
                                                            '7) Stock Vouchers',
                                                        onPressed: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .purchaseOrder !=
                                                                    "No")
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const StockVoucherDesktopBody(),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                      ),
                                                      const SizedBox(height: 1),
                                                      DButtons(
                                                        text:
                                                            '8)  Sales Register',
                                                        onPressed: (userGroup ==
                                                                    "Admin" ||
                                                                userGroup ==
                                                                    "Owner" ||
                                                                userGroupM
                                                                        .firstWhere((e) =>
                                                                            e.userGroupName ==
                                                                            userGroup)
                                                                        .salesOrder !=
                                                                    "No")
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const SalesRegisterDesktop(),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 2,
                                            top: screenHeight * 0.001),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Shortcuts(
                                              shortcuts: {
                                                LogicalKeySet(
                                                        LogicalKeyboardKey.f1):
                                                    const ActivateIntent(),
                                              },
                                              child: Focus(
                                                autofocus: true,
                                                // ignore: deprecated_member_use
                                                onKey: (FocusNode focusNode,
                                                    RawKeyEvent event) {
                                                  if (event
                                                          is RawKeyDownEvent &&
                                                      event.logicalKey ==
                                                          LogicalKeyboardKey
                                                              .f1) {
                                                    // Handle the shortcut, e.g., navigate to a new page
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LedgerHome()),
                                                    );
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                  return KeyEventResult.ignored;
                                                },
                                                child: const DToDo(),
                                              ),
                                            ),
                                            SizedBox(
                                                width: screenWidth * 0.006),
                                            const DRemainder(),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: (userGroup == "Admin" ||
                                                userGroup == "Owner") ||
                                            userGroupM
                                                    .firstWhere(
                                                      (e) =>
                                                          e.userGroupName ==
                                                          userGroup,
                                                    )
                                                    .ownerGroup !=
                                                "No",
                                        child: const DTable(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: const CustomFooter(),
              ),
      ),
    );
  }
}
