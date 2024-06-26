// ignore_for_file: must_be_immutable

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BarcodePrintingPage extends StatelessWidget {
  final List<Widget> barcodes;
  String barcodeType;
  String printerType;

  BarcodePrintingPage({
    super.key,
    required this.barcodes,
    required this.barcodeType,
    required this.printerType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
        build: (format) => _generatePdf(format, printerType),
      ),
    );
  }

  // Future<Uint8List> _generatePdf(PdfPageFormat format) async {
  //   final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  //   // Define the page size in inches
  //   final pageWidthInInches = 2.8;
  //   final pageHeightInInches = 1.5;
  //   // Create a custom page format using the specified dimensions
  //   final customPageFormat = PdfPageFormat(
  //     pageWidthInInches * PdfPageFormat.inch,
  //     pageHeightInInches * PdfPageFormat.inch,
  //   );
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: customPageFormat,
  //       build: (contextPdf) {
  //         // Create a list to hold rows of barcodes
  //         List<pw.Widget> rows = [];
  //         // Calculate the number of blank rows to add at the top
  //         int blankRows = (2 - barcodes.length % 2) % 2;
  //         // Add blank rows at the top if needed
  //         for (int i = 0; i < blankRows; i++) {
  //           rows.add(pw.SizedBox(height: 30)); // Adjust the height as needed
  //         }
  //         // Loop through the barcodes list in steps of 2
  //         for (int i = 0; i < barcodes.length; i += 2) {
  //           // Create a row with two barcodes
  //           pw.Widget row = pw.Row(
  //             children: [
  //               _widgetToPdfWidget(contextPdf, barcodes[i]),
  //               if (i + 1 < barcodes.length)
  //                 _widgetToPdfWidget(contextPdf, barcodes[i + 1]),
  //             ],
  //           );
  //           // Add the row to the list
  //           rows.add(row);
  //         }
  //         // Return a column of rows
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: rows,
  //         );
  //       },
  //     ),
  //   );
  //   return pdf.save();
  // }

  // Future<Uint8List> _generatePdf(PdfPageFormat format) async {
  //   final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  //   // Define the page size in inches
  //   final pageWidthInInches = 2.8;
  //   final pageHeightInInches = 1.5;
  //   // Create a custom page format using the specified dimensions
  //   final customPageFormat = PdfPageFormat(
  //     pageWidthInInches * PdfPageFormat.inch,
  //     pageHeightInInches * PdfPageFormat.inch,
  //   );
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: customPageFormat,
  //       build: (contextPdf) {
  //         // Assuming a single barcode to be centered
  //         final barcode = barcodes.isNotEmpty ? barcodes[0] : null;
  //         // Return a centered barcode widget
  //         return pw.Center(
  //           child: barcode != null
  //               ? _widgetToPdfWidget(contextPdf, barcode)
  //               : pw.Container(),
  //         );
  //       },
  //     ),
  //   );
  //   return pdf.save();
  // }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, String printerType) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    // Define the page size in inches
    const pageWidthInInchesForSingle = 3.1;
    var pageHeightInInchesForSingle = ((barcodes.length) / 2);

    const pageWidthInInchesForDouble = 4.2;
    var pageHeightInInchesForDouble = ((barcodes.length / 2) / 2);

    // Create a custom page format using the specified dimensions
    var customPageFormatForSingle = PdfPageFormat(
      pageWidthInInchesForSingle * PdfPageFormat.inch,
      pageHeightInInchesForSingle * PdfPageFormat.inch,
    );
    var customPageFormatForDouble = PdfPageFormat(
      pageWidthInInchesForDouble * PdfPageFormat.inch,
      pageHeightInInchesForDouble * PdfPageFormat.inch,
    );

    if (printerType == 'Single Print') {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: customPageFormatForSingle,
          build: (contextPdf) {
            List<pw.Widget> pages = [];

            for (int i = 0; i < barcodes.length; i++) {
              final barcode = barcodes[i];
              pages.add(
                pw.Center(
                  child: _widgetToPdfWidgetSingle(contextPdf, barcode),
                ),
              );
            }

            return pages;
          },
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: customPageFormatForDouble,
          build: (contextPdf) {
            // Create a list to hold rows of barcodes
            List<pw.Widget> rows = [];

            // Calculate the number of blank rows to add at the top
            int blankRows = (2 - barcodes.length % 2) % 2;

            // Add blank rows at the top if needed
            for (int i = 0; i < blankRows; i++) {
              rows.add(pw.SizedBox(height: 30)); // Adjust the height as needed
            }

            // Loop through the barcodes list in steps of 2
            for (int i = 0; i < barcodes.length; i += 2) {
              // Create a row with two barcodes
              pw.Widget row = pw.Row(
                children: [
                  _widgetToPdfWidget(contextPdf, barcodes[i]),
                  if (i + 1 < barcodes.length)
                    _widgetToPdfWidget(contextPdf, barcodes[i + 1]),
                ],
              );

              // Add the row to the list
              rows.add(row);
            }

            // Return a column of rows
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: rows,
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _widgetToPdfWidgetSingle(pw.Context context, Widget widget) {
    if (widget is SizedBox) {
      // Check if the SizedBox has a non-null child before attempting to convert it
      if (widget.child != null) {
        return pw.Container(
          width: widget.width ?? 0,
          height: widget.height ?? 0,
          child: _widgetToPdfWidget(context, widget.child!),
        );
      } else {
        return pw.SizedBox(width: 0, height: 0);
      }
    } else if (widget is SfBarcodeGenerator) {
      // Convert SfBarcodeGenerator to a PDF-compatible barcode
      // You'll need to implement this conversion logic
      return _generatePdfBarcodeSingle(
          context, widget.value ?? '', barcodeType);
    }

    // Return an empty widget if the conversion is not supported
    return pw.SizedBox(width: 0, height: 0);
  }

  pw.Widget _generatePdfBarcodeSingle(
      pw.Context context, String value, String barcodeType) {
    pw.Barcode? selectedBarcode;

    switch (barcodeType) {
      case 'codabar':
        selectedBarcode = pw.Barcode.codabar();
        break;
      case 'code 39':
        selectedBarcode = pw.Barcode.code39();
        break;
      case 'code 93':
        selectedBarcode = pw.Barcode.code93();
        break;
      case 'code 128':
        selectedBarcode = pw.Barcode.code128();
        break;
      case 'EAN-13':
        selectedBarcode = pw.Barcode.ean13();
        break;
      default:
        selectedBarcode = pw.Barcode.code128();
        break;
    }

    return pw.BarcodeWidget(
      barcode: selectedBarcode,
      data: value,

      // width: 141.73,
      // height: 70.87,

      padding:
          pw.EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0, top: 10.0),
      drawText: true,
    );
  }

//DOUBLE
  pw.Widget _widgetToPdfWidget(pw.Context context, Widget widget) {
    if (widget is SizedBox) {
      // Check if the SizedBox has a non-null child before attempting to convert it
      if (widget.child != null) {
        return pw.Container(
          width: widget.width ?? 0,
          height: widget.height ?? 0,
          child: _widgetToPdfWidget(context, widget.child!),
        );
      } else {
        return pw.SizedBox(width: 0, height: 0);
      }
    } else if (widget is SfBarcodeGenerator) {
      // Convert SfBarcodeGenerator to a PDF-compatible barcode
      // You'll need to implement this conversion logic
      return _generatePdfBarcode(context, widget.value ?? '', barcodeType);
    }

    // Return an empty widget if the conversion is not supported
    return pw.SizedBox(width: 0, height: 0);
  }

  pw.Widget _generatePdfBarcode(
      pw.Context context, String value, String barcodeType) {
    pw.Barcode? selectedBarcode;

    switch (barcodeType) {
      case 'codabar':
        selectedBarcode = pw.Barcode.codabar();
        break;
      case 'code 39':
        selectedBarcode = pw.Barcode.code39();
        break;
      case 'code 93':
        selectedBarcode = pw.Barcode.code93();
        break;
      case 'code 128':
        selectedBarcode = pw.Barcode.code128();
        break;
      case 'EAN-13':
        selectedBarcode = pw.Barcode.ean13();
        break;
      default:
        selectedBarcode = pw.Barcode.code128();
        break;
    }

    return pw.BarcodeWidget(
      barcode: selectedBarcode,
      data: value,

      // width: 141.73,
      // height: 70.87,

      padding:
          pw.EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0, top: 10.0),
      drawText: true,
    );
  }
}
