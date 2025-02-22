import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ManagePDF {
  Future<String> _getDownloadDirectoryPath() async {
    final Directory? downloadsDir = await getExternalStorageDirectory();
    final file = File("${downloadsDir!.path}/invoice.pdf");

    return file.path;
  }

  List<Product> products = [
    Product(
        quantity: 5,
        price: 10,
        total: 0,
        id: 'gttgt',
        name: 'Product1',
        tva: 0,
        remise: 0),
    Product(
        quantity: 5,
        price: 15,
        total: 0,
        id: 'gttgt',
        name: 'Product2',
        tva: 0,
        remise: 0)
  ];

  // await _sendEmail();
  // await _deleteFDF(context);
  Future<void> createPdf(BuildContext context) async {
    final pdf = pw.Document();
    final img = await rootBundle.load('assets/icon.png');
    final imageBytes = img.buffer.asUint8List();
    pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  child: image1,
                  height: 50,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Invoice', style: pw.TextStyle(fontSize: 24)),
                    pw.Text('Invoice number: INV/202405-0002'),
                    pw.Text('Issue date: 14 May, 2024'),
                    pw.Container(
                      padding: pw.EdgeInsets.all(4),
                      color: PdfColors.green,
                      child: pw.Text('Paid',
                          style: pw.TextStyle(color: PdfColors.white)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Issuer',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Bird company LTD'),
                    pw.Text('2, Paris Street'),
                    pw.Text('New York'),
                    pw.Text('USA'),
                    pw.Text('ID #NY2938742-05'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Client',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Salve Corp'),
                    pw.Text('Rembrandt Square, 40. NY81920. NYC'),
                    pw.Text('VAT: US123456789'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(headers: [
              'Description',
              'Quantity',
              'Unit price',
              'Tax',
              'Amount'
            ], data: [
              for (int i = 0; i < products.length; i++)
                [
                  products[i].name,
                  '${products[i].quantity}',
                  '${products[i].price}',
                  '${products[i].tva}',
                  '${products[i].total}'
                ]
            ]
                // data: [
                //   [
                //     'Marketing services - SEO optimisation',
                //     '15',
                //     '\$300.00',
                //     '6.0%',
                //     '\$4,770.00'
                //   ],
                //   [
                //     'Description: SEO analysis',
                //     '2',
                //     '\$100.00',
                //     '15.0%',
                //     '\$230.00'
                //   ],
                // ],
                ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildTotalRow('Subtotal', '\$4,700.00'),
                    _buildTotalRow('Tax amount', '\$300.00'),
                    pw.Divider(),
                    _buildTotalRow('Total', '\$5,000.00', bold: true),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final downloadPath = await _getDownloadDirectoryPath();
    final file = File("$downloadPath");

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF Saved: ${file.path}')),
    );

    //OpenFile.open(file.path);
  }

  Future<void> _sendEmail(BuildContext context) async {
    String username = 'lamine.daikha@univ-constantine2.dz'; // Your email
    String password =
        'AMINEamine9696'; // Your email password or app-specific password

    final smtpServer = gmail(username, password); // Using Gmail
    final Directory? downloadsDir = await getExternalStorageDirectory();
    final file = File("${downloadsDir!.path}/invoice.pdf");
    final message = Message()
      ..from = Address(username, 'CRM')
      ..recipients.add('elamine.daikha@gmail.com') // Recipient email
      ..subject = 'subject'
      ..text = 'important'
      ..attachments = [FileAttachment(file)];

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      showMessage(
          message:
          'Email a été envoyé avec succès',
          context: context,
          color: primaryColor);
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
      showMessage(
          message: 'Échec de l\'envoi d\'email',
          context: context,
          color: Colors.red);
    }
  }

  Future<void> _deleteFDF() async {
    final Directory? downloadsDir = await getExternalStorageDirectory();
    final file = File("${downloadsDir!.path}/invoice.pdf");

    if (await file.exists()) {
      await file.delete();
      print('Deleted succefully !');
    } else {
      print('File not found');
    }
  }

  pw.Widget _buildTotalRow(String label, String amount, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: bold
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : pw.TextStyle()),
        pw.Text(amount,
            style: bold
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : pw.TextStyle()),
      ],
    );
  }
}
