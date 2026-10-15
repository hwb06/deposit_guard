import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/extensions/date_extension.dart';
import '../data/models/issue_model.dart';
import '../data/models/issue_severity.dart';
import '../data/models/issue_stage.dart';
import '../data/models/rental_model.dart';
import '../data/repositories/issue_repository.dart';
import 'image/image_service.dart';

/// Builds a PDF evidence report for one rental and opens the share sheet.
class ReportService {
  ReportService(this._issues, this._images);

  final IssueRepository _issues;
  final ImageService _images;

  /// Default PDF fonts support Latin text only, so keep report text ASCII.
  Future<void> shareRentalReport(RentalModel rental) async {
    final issues = await _issues.getIssues(rental.id);
    final bytes = await _build(rental, issues);

    final safeName = rental.name
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'deposit-report-${safeName.isEmpty ? 'rental' : safeName}.pdf',
    );
  }

  Future<Uint8List> _build(RentalModel rental, List<IssueModel> issues) async {
    final doc = pw.Document(title: 'Deposit report', author: 'DepositGuard');

    // Oldest first inside each stage reads like a timeline.
    final sorted = [...issues]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Load photos first (async file reads).
    final photos = <String, pw.MemoryImage>{};
    for (final issue in sorted) {
      final image = await _loadPhoto(issue.photoPath);
      if (image != null) photos[issue.id] = image;
    }

    final widgets = <pw.Widget>[
      pw.Text(
        'Deposit report',
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Generated on ${DateTime.now().formatted}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
      pw.Divider(height: 24),
      _summary(rental, sorted),
      pw.SizedBox(height: 16),
    ];

    if (sorted.isEmpty) {
      widgets.add(pw.Text('No issues recorded for this rental.'));
    } else {
      for (final stage in IssueStage.values) {
        final inStage = sorted.where((i) => i.stage == stage).toList();
        if (inStage.isEmpty) continue;

        widgets
          ..add(
            pw.Text(
              '${stage.label} (${inStage.length})',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          )
          ..add(pw.SizedBox(height: 8))
          ..addAll(inStage.map((i) => _issueBlock(i, photos[i.id])))
          ..add(pw.SizedBox(height: 8));
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (_) => widgets,
      ),
    );

    return doc.save();
  }

  pw.Widget _summary(RentalModel rental, List<IssueModel> issues) {
    int count(IssueSeverity s) => issues.where((i) => i.severity == s).length;

    final rows = <MapEntry<String, String>>[
      MapEntry('Property', rental.name),
      MapEntry('Address', rental.address),
      MapEntry('Lease start', rental.leaseStart.formatted),
      MapEntry('Lease end', rental.leaseEnd.formatted),
      MapEntry(
        'Recorded issues',
        '${issues.length} (severe ${count(IssueSeverity.severe)}, '
            'moderate ${count(IssueSeverity.moderate)}, '
            'minor ${count(IssueSeverity.minor)})',
      ),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    row.key,
                    style: const pw.TextStyle(color: PdfColors.grey700),
                  ),
                ),
                pw.Expanded(child: pw.Text(row.value)),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _issueBlock(IssueModel issue, pw.MemoryImage? image) {
    final note = issue.note?.trim() ?? '';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  issue.title,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                issue.severity.label,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _severityColor(issue.severity),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${issue.room}  |  ${issue.createdAt.formatted}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          if (note.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(note),
          ],
          if (image != null) ...[
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.SizedBox(
                height: 200,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PdfColor _severityColor(IssueSeverity severity) => switch (severity) {
        IssueSeverity.severe => PdfColors.red700,
        IssueSeverity.moderate => PdfColors.orange700,
        IssueSeverity.minor => PdfColors.grey700,
      };

  Future<pw.MemoryImage?> _loadPhoto(String? name) async {
    if (name == null || name.isEmpty) return null;
    try {
      final file = _images.fileFor(name);
      if (!await file.exists()) return null;
      return pw.MemoryImage(await file.readAsBytes());
    } catch (error) {
      debugPrint('ReportService: skipped photo ($error)');
      return null;
    }
  }
}
