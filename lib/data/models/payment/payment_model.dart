class Payment {
  final String id;
  final String companyCode;
  final double totalamount;
  final String no;
  final String date;
  final List<Entry> entries;
  final List<Billwise> billwise;
  final String? narration;

  Payment({
    required this.id,
    required this.companyCode,
    required this.totalamount,
    required this.no,
    required this.date,
    required this.entries,
    required this.billwise,
    this.narration,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'],
      companyCode: json['companyCode'],
      totalamount: json['totalamount'],
      no: json['no'],
      date: json['date'],
      entries: (json['entries'] as List<dynamic>)
          .map((entryJson) => Entry.fromJson(entryJson))
          .toList(),
      billwise: (json['billwise'] as List<dynamic>)
          .map((entryJson) => Billwise.fromJson(entryJson))
          .toList(),
      narration: json['narration'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'no': no,
      'companyCode': companyCode,
      'totalamount': totalamount,
      'date': date,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'billwise': billwise.map((entry) => entry.toJson()).toList(),
      'narration': narration,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['_id'] as String,
      totalamount: map['totalamount'] as double,
      companyCode: map['companyCode'] as String,
      no: map['no'] as String,
      date: map['date'] as String,
      entries: (map['entries'] as List<dynamic>)
          .map((entryJson) => Entry.fromJson(entryJson))
          .toList(),
      billwise: (map['billwise'] as List<dynamic>)
          .map((entryJson) => Billwise.fromJson(entryJson))
          .toList(),
      narration: map['narration'] as String?,
    );
  }
}

class Entry {
  final String account;
  final String ledger;
  final String? remark;
  final double? debit;
  final double? credit;

  Entry({
    required this.account,
    required this.ledger,
    this.remark,
    this.debit,
    this.credit,
  });
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      account: json['account'],
      ledger: json['ledger'],
      remark: json['remark'],
      debit: json['debit'],
      credit: json['credit'],
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'account': account,
      'ledger': ledger,
      'remark': remark,
      'debit': debit,
      'credit': credit,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'ledger': ledger,
      'remark': remark,
      'debit': debit,
      'credit': credit,
    };
  }
}

class Billwise {
  final String date;
  final String billNo;
  final String purchase;
  final double amount;

  Billwise({
    required this.date,
    required this.billNo,
    required this.purchase,
    required this.amount,
  });
  factory Billwise.fromJson(Map<String, dynamic> json) {
    return Billwise(
      date: json['date'],
      billNo: json['billNo'],
      purchase: json['purchase'],
      amount: json['amount'],
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'billNo': billNo,
      'purchase': purchase,
      'amount': amount,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'billNo': billNo,
      'purchase': purchase,
      'amount': amount,
    };
  }
}
