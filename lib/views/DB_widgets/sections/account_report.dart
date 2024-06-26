import 'package:billingsphere/views/DB_widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AccountReport extends StatelessWidget {
  const AccountReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              decoration: TextDecoration.underline,
              decorationColor: Colors.red,
              decorationThickness: 2.0,
            ),
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '1)  Trial Balance',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '2)  Ledger Stmnt.',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '3)  Voucher Regi.',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
          const Text(
            'Inventory Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              decoration: TextDecoration.underline,
              decorationColor: Colors.red,
              decorationThickness: 2.0,
            ),
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '6)  Stock Status',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '7)  Stock Vouchers',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
          const SizedBox(height: 5),
          CustomButton(
            text: '8)  Sales',
            onPressed: () {},
            width: MediaQuery.of(context).size.width / 3,
          ),
        ],
      ),
    );
  }
}
