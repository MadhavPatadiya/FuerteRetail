import 'package:billingsphere/views/DB_widgets/custom_footer.dart';
import 'package:billingsphere/views/DB_widgets/custom_table.dart';
import 'package:billingsphere/views/DB_widgets/sections/account_report.dart';
import 'package:billingsphere/views/DB_widgets/sections/master_report.dart';
import 'package:billingsphere/views/DB_widgets/sections/reminders.dart';
import 'package:billingsphere/views/DB_widgets/sections/todo_list.dart';
import 'package:billingsphere/views/DB_widgets/sections/transaction.dart';
import 'package:flutter/material.dart';

class DBMyMobileBody extends StatelessWidget {
  const DBMyMobileBody({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Accounts',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 2.0,
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Inventory',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 2.0,
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SMS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 2.0,
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 2.0,
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Utility',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
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
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: const Text(
                              'QUICK ACCESS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Row(
                            children: [
                              Transaction(),
                              Spacer(),
                              AccountReport(),
                            ],
                          ),
                          const MasterReport(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const TodoList(),
              const Reminders(),
              const CustomTable(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }
}
