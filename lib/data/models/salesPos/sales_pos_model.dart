// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SalesPos {
  final int no;
  final String date;
  final String companyCode;
  final String place;
  final String type;
  final List<POSEntry> entries;
  final String accountNo;
  final String customer;
  final String billedTo;
  final String remarks;
  final double totalAmount;

  SalesPos({
    required this.no,
    required this.date,
    required this.companyCode,
    required this.place,
    required this.type,
    required this.entries,
    required this.accountNo,
    required this.customer,
    required this.billedTo,
    required this.remarks,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'no': no,
      'date': date,
      'companyCode': companyCode,
      'place': place,
      'type': type,
      'entries': entries.map((x) => x.toMap()).toList(),
      'accountNo': accountNo,
      'customer': customer,
      'billedTo': billedTo,
      'remarks': remarks,
      'totalAmount': totalAmount,
    };
  }

  factory SalesPos.fromMap(Map<String, dynamic> map) {
  return SalesPos(
    no: map['no'] as int,
    date: map['date'] as String,
    companyCode: map['companyCode'] as String,
    place: map['place'] as String,
    type: map['type'] as String,
    entries: (map['entries'] as List<dynamic>)
      .map((entryJson) => POSEntry.fromMap(entryJson))
      .toList(),
    accountNo: map['accountNo'] as String,
    customer: map['customer'] as String,
    billedTo: map['billedTo'] as String,
    remarks: map['remarks'] as String,
    totalAmount: map['totalAmount'] as double,
  );
}


  String toJson() => json.encode(toMap());

  factory SalesPos.fromJson(String source) =>
      SalesPos.fromMap(json.decode(source) as Map<String, dynamic>);
}

class POSEntry {
  final String itemName;
  final int qty;
  final double rate;
  final String unit;
  final double netAmount;

  POSEntry({
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.unit,
    required this.netAmount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemName': itemName,
      'qty': qty,
      'rate': rate,
      'unit': unit,
      'netAmount': netAmount,
    };
  }

  factory POSEntry.fromMap(Map<String, dynamic> map) {
    return POSEntry(
      itemName: map['itemName'] as String,
      qty: map['qty'] as int,
      rate: map['rate'] as double,
      unit: map['unit'] as String,
      netAmount: map['netAmount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory POSEntry.fromJson(String source) =>
      POSEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
