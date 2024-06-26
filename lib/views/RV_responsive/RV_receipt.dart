import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger/ledger_model.dart';
import '../../data/models/newCompany/new_company_model.dart';
import '../../data/models/receiptVoucher/receipt_voucher_model.dart';
import '../../data/repository/ledger_repository.dart';
import '../../data/repository/new_company_repository.dart';
import '../../data/repository/receipt_voucher_repository.dart';

class ReceiptVoucherPrint extends StatefulWidget {
  const ReceiptVoucherPrint(this.title, {super.key, required this.receiptID});
  final String receiptID;

  final String title;

  @override
  State<ReceiptVoucherPrint> createState() => _ReceiptVoucherPrintState();
}

class _ReceiptVoucherPrintState extends State<ReceiptVoucherPrint> {
  List<NewCompany> selectedComapny = [];
  List<Ledger> fectedLedgers = [];
  List<Uint8List> _selectedImages = [];
  List<String>? companyCode;

  NewCompanyRepository newCompanyRepo = NewCompanyRepository();
  LedgerService ledgerService = LedgerService();
  ReceiptVoucherService receiptVchService = ReceiptVoucherService();

  ReceiptVoucher? _ReceiptVch;
  bool isLoading = false;

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

  Future<void> fetchNewCompany() async {
    try {
      final newcom = await newCompanyRepo.getAllCompanies();

      final filteredCompany = newcom
          .where((company) =>
              company.stores!.any((store) => store.code == companyCode!.first))
          .toList();
      setState(() {
        selectedComapny = filteredCompany;
        _selectedImages =
            filteredCompany.first.logo1!.map((e) => e.data).toList();
      });
      // print(_selectedImages);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchReceiptById() async {
    final sales = await receiptVchService.fetchReceiptVchById(widget.receiptID);
    print(widget.receiptID);

    setState(() {
      _ReceiptVch = sales;
    });
  }

  Future<void> fetchLedger() async {
    try {
      final List<Ledger> ledgers = await ledgerService.fetchLedgers();
      setState(() {
        fectedLedgers = ledgers;
      });
    } catch (error) {
      print('Failed to fetch ledger name: $error');
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        setCompanyCode(),
        fetchNewCompany(),
        fetchReceiptById(),
        fetchLedger(),
      ]);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(widget.title),
                centerTitle: true,
              ),
              body: PdfPreview(
                build: (format) => _generatePdf(format, widget.title),
              ),
            ),
      debugShowCheckedModeBanner:
          false, // Set to false to hide the debug banner
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            children: [
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: PdfColors.black)),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 2),
                        pw.Container(
                          width: 50,
                          child: _selectedImages.isNotEmpty
                              ? pw.Image(pw.MemoryImage(_selectedImages[0]))
                              : pw.SizedBox(width: 50),
                        ),
                        pw.Spacer(),
                        pw.Container(
                          width: 200,
                          child: pw.Center(
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  selectedComapny.first.companyName!,
                                  style: pw.TextStyle(
                                      fontSize: 18,
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                                // pw.Text(
                                //   '"${selectedComapny.first.tagline}"',
                                //   style: pw.TextStyle(
                                //       fontSize: 12,
                                //       fontWeight: pw.FontWeight.normal),
                                // ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  selectedComapny.first.stores!.first.address,
                                  maxLines: 3,
                                  textAlign: pw.TextAlign.center,
                                  softWrap: true,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                                pw.SizedBox(height: 2),

                                pw.Text(
                                  'E-mail: ${selectedComapny.first.stores!.first.email}, Mo. ${selectedComapny.first.stores!.first.phone}',
                                  style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.normal),
                                ),
                                pw.SizedBox(width: 2),
                              ],
                            ),
                          ),
                        ),
                        pw.Spacer(),
                        pw.Container(
                          width: 50,
                          child: _selectedImages.isNotEmpty
                              ? pw.Image(pw.MemoryImage(_selectedImages[0]))
                              : pw.SizedBox(width: 50),
                        ),
                        pw.SizedBox(width: 2),
                      ],
                    ),
                    pw.SizedBox(width: 2),
                    pw.SizedBox(
                      width: format.availableWidth,
                      child: pw.Row(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                              'GSTIN : ${selectedComapny.first.gstin}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal),
                            ),
                          ),
                          pw.Spacer(),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                              'State : ${selectedComapny.first.stores!.first.state}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal),
                            ),
                          ),
                          pw.Spacer(),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                              'PAN : ${selectedComapny.first.pan}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'RECEIPT VOUCHER',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      width: 70,
                      child: pw.Text(
                        'Receipt No. : ',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      width: 100,
                      child: pw.Text(
                        _ReceiptVch!.no.toString(),
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Spacer(),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      width: 50,
                      child: pw.Text(
                        'Date : ',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      width: 50,
                      child: pw.Text(
                        _ReceiptVch!.date,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 50,
                          child: pw.Text(
                            'Party : ',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 200,
                          child: pw.Text(
                            '${fectedLedgers.firstWhere((ledger) => ledger.id == _ReceiptVch!.ledger).name} ',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 50,
                          child: pw.Text(
                            '',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 200,
                          child: pw.Text(
                            'Mo. ${fectedLedgers.firstWhere((ledger) => ledger.id == _ReceiptVch!.ledger).mobile} ',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 50,
                          child: pw.Text(
                            '',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          width: 200,
                          child: pw.Text(
                            '${fectedLedgers.firstWhere((ledger) => ledger.id == _ReceiptVch!.ledger).state} ',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(
                      ' We thank you very much for your payment of Rs. ${_ReceiptVch!.totalcreditamount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(5.0),
                        child: pw.Text(
                          'Rs.       ${_ReceiptVch!.totalcreditamount.toStringAsFixed(2)} ',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline,
                            decorationThickness:
                                2.0, // Adjust the thickness as needed
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 80,
                                child: pw.Text(
                                  'Payment A/c:',
                                  style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.SizedBox(
                                child: pw.Text(
                                  _ReceiptVch!.cashtype,
                                  style: const pw.TextStyle(
                                    fontSize: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 80,
                                child: pw.Text(
                                  'Balance :',
                                  style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.SizedBox(
                                child: pw.Text(
                                  '${fectedLedgers.firstWhere((ledger) => ledger.id == _ReceiptVch!.ledger).debitBalance.toStringAsFixed(2)} Dr ',
                                  style: const pw.TextStyle(
                                    fontSize: 6,
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
              ),
              pw.Container(
                width: format.availableWidth,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                            '(Cheque Payment subject to Realization)',
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                            '$formattedDate  $formattedTime',
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Text(
                        selectedComapny.first.companyName!,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
