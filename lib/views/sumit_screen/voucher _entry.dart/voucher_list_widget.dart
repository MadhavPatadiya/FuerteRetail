import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  final String? name;
  final String? Skey;
  final VoidCallback? onTap; // Add this line
  const CustomList({super.key, this.name, this.Skey, this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 32,
          width: w * 0.1,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              right: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              bottom: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
              left: BorderSide(
                  width: 2, color: Colors.purple[900] ?? Colors.purple),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: Text(
                  Skey ?? "",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                name ?? " ",
                style: TextStyle(color: Colors.purple[900] ?? Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
