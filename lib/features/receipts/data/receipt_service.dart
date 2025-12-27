// lib/features/receipts/data/receipt_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

/// Service for generating and managing receipts
class ReceiptService {
  final SupabaseClient _supabase;

  ReceiptService(this._supabase);

  /// Generate receipt number (format: HC-2024-00123)
  Future<String> _generateReceiptNumber() async {
    final year = DateTime.now().year;

    // Get the count of receipts this year
    final response = await _supabase
        .from('payment_receipts')
        .select()
        .like('receipt_number', 'HC-$year-%')
        .count(CountOption.exact);

    final count = response.count;
    final nextNumber = (count + 1).toString().padLeft(5, '0');
    return 'HC-$year-$nextNumber';
  }

  /// Generate PDF receipt
  Future<File> generateReceipt({
    required String requestId,
  }) async {
    // Fetch all required data
    final request = await _supabase.from('homecare_requests').select('''
          *,
          patient:patient_id(first_name, last_name, phone),
          partner:partner_id(full_name, phone)
        ''').eq('id', requestId).single();

    final negotiatedPrice = (request['negotiated_price'] as num).toDouble();
    final platformFee = (request['platform_fee'] as num?)?.toDouble() ?? 500.0;
    final totalAmount = (request['total_amount'] as num).toDouble();
    final paidAt = DateTime.parse(request['paid_at'] as String);
    final patientLocation = request['address'] as String;

    final patient = request['patient'] as Map<String, dynamic>;
    final partner = request['partner'] as Map<String, dynamic>;

    final receiptNumber = await _generateReceiptNumber();

    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'MAOUIDI HOMECARE RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Receipt #: $receiptNumber',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Date: ${DateFormat('dd MMMM yyyy, HH:mm').format(paidAt)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Patient Information
              _buildSection(
                title: 'PATIENT INFORMATION',
                content: [
                  'Name: ${patient['first_name']} ${patient['last_name']}',
                  'Phone: ${patient['phone']}',
                  'Location: $patientLocation',
                ],
              ),

              pw.SizedBox(height: 16),

              // Partner Information
              _buildSection(
                title: 'PARTNER INFORMATION',
                content: [
                  'Name: ${partner['full_name']}',
                  'Phone: ${partner['phone']}',
                  'Service Type: ${request['service_type']}',
                ],
              ),

              pw.SizedBox(height: 24),

              // Payment Breakdown
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PAYMENT BREAKDOWN',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildPriceRow('Negotiated Price:', negotiatedPrice),
                    pw.SizedBox(height: 8),
                    _buildPriceRow('Platform Fee:', platformFee,
                        isHighlighted: true,),
                    pw.Divider(thickness: 2),
                    _buildPriceRow('TOTAL PAID:', totalAmount, isTotal: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Partner Payout
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green200),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PARTNER PAYOUT',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPriceRow('To be paid:', negotiatedPrice),
                    _buildPriceRow('Platform keeps:', platformFee),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for using Maouidi!',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Support: support@maouidi.dz',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
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

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_$receiptNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    // Save receipt record to database
    await _supabase.from('payment_receipts').insert({
      'homecare_request_id': requestId,
      'patient_id': request['patient_id'],
      'partner_id': request['partner_id'],
      'service_price': negotiatedPrice,
      'platform_fee': platformFee,
      'total_paid': totalAmount,
      'partner_amount': negotiatedPrice,
      'receipt_number': receiptNumber,
    });

    return file;
  }

  pw.Widget _buildSection({
    required String title,
    required List<String> content,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          ...content.map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(line, style: const pw.TextStyle(fontSize: 11)),
              ),),
        ],
      ),
    );
  }

  pw.Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isHighlighted = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          '${isHighlighted ? '+' : ''}${amount.toStringAsFixed(2)} DA',
          style: pw.TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal || isHighlighted
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            color: isTotal
                ? PdfColors.blue900
                : isHighlighted
                    ? PdfColors.orange900
                    : PdfColors.black,
          ),
        ),
      ],
    );
  }

  /// Get receipt for a request
  Future<Map<String, dynamic>?> getReceipt(String requestId) async {
    final receipts = await _supabase
        .from('payment_receipts')
        .select()
        .eq('homecare_request_id', requestId);

    if (receipts.isEmpty) return null;
    return receipts.first;
  }
}
