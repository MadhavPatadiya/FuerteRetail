// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReceiptVoucher {
  final String id;
  final String companyCode;
  final double totaldebitamount;
  final double totalcreditamount;
  final int no;
  final String date;
  final String account;
  final String ledger;
  final String remark;
  final double debit;
  final double credit;
  final String cashaccount;
  final String cashtype;
  final String cashremark;
  final double cashdebit;
  final double cashcredit;
  // final List<Entry> entries;
  final String naration;

  ReceiptVoucher({
    required this.id,
    required this.companyCode,
    required this.totaldebitamount,
    required this.totalcreditamount,
    required this.no,
    required this.date,
    required this.account,
    required this.ledger,
    required this.remark,
    required this.debit,
    required this.credit,
    required this.cashaccount,
    required this.cashtype,
    required this.cashremark,
    required this.cashdebit,
    required this.cashcredit,
    // required this.entries,
    required this.naration,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': '',
      'companyCode': companyCode,
      'totaldebitamount': totaldebitamount,
      'totalcreditamount': totalcreditamount,
      'no': no,
      'date': date,
      'account': account,
      'ledger': ledger,
      'remark': remark,
      'debit': debit,
      'credit': credit,
      'cashaccount': cashaccount,
      'cashtype': cashtype,
      'cashremark': cashremark,
      'cashdebit': cashdebit,
      'cashcredit': cashcredit,
      'naration': naration,
    };
  }

  factory ReceiptVoucher.fromMap(Map<String, dynamic> map) {
    return ReceiptVoucher(
      id: map['_id'] as String,
      companyCode: map['companyCode'] as String,
      totaldebitamount: map['totaldebitamount'] as double,
      totalcreditamount: map['totalcreditamount'] as double,
      no: map['no'] as int,
      date: map['date'] as String,
      account: map['account'] as String,
      ledger: map['ledger'] as String,
      remark: map['remark'] as String,
      debit: map['debit'] as double,
      credit: map['credit'] as double,
      cashaccount: map['cashaccount'] as String,
      cashtype: map['cashtype'] as String,
      cashremark: map['cashremark'] as String,
      cashdebit: map['cashdebit'] as double,
      cashcredit: map['cashcredit'] as double,
      naration: map['naration'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReceiptVoucher.fromJson(String source) =>
      ReceiptVoucher.fromMap(json.decode(source) as Map<String, dynamic>);
}
