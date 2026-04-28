import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfService {
  Future<Uint8List> generateHealthReport({
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> vitals,
    required List<Map<String, dynamic>> medicineLogs,
    required List<Map<String, dynamic>> alerts,
    required List<Map<String, dynamic>> sleepLogs,
    required List<Map<String, dynamic>> nutritionLogs,
    required List<Map<String, dynamic>> activityLogs,
    required DateTime startDate,
    required DateTime endDate,
    required bool includeVitals,
    required bool includeMedicines,
    required bool includeAlerts,
    required bool includeQuickModules,
  }) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    String name = userProfile['name'] ?? "Patient Name";
    String age = userProfile['age'] ?? "N/A";
    String bloodGroup = userProfile['bloodGroup'] ?? "N/A";
    String generationDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    String reportPeriod = "${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}";

    // Helper to build shared headers/footers
    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        margin: const pw.EdgeInsets.only(bottom: 20),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey200, width: 1))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Health Monitor Report", style: pw.TextStyle(color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
            pw.Text(generationDate, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
          ]
        )
      );
    }

    pw.Widget buildFooter(pw.Context context) {
      return pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10))
      );
    }

    // Page 1: Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildCoverPage(name, age, bloodGroup, reportPeriod, generationDate),
      ),
    );

    // Page 2: Table of Contents (Interactive)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildTableOfContents(
           includeVitals: includeVitals, 
           includeMedicines: includeMedicines, 
           includeAlerts: includeAlerts, 
           includeQuickModules: includeQuickModules
        ),
      ),
    );

    // Page 3: Vitals Summary
    if (includeVitals) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: buildHeader,
          footer: buildFooter,
          build: (context) => [
            pw.Anchor(name: 'vitals_section', child: pw.SizedBox()),
            ..._buildVitalsPage(vitals)
          ],
        ),
      );
    }

    // Page 4: Medicines Adherence
    if (includeMedicines) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: buildHeader,
          footer: buildFooter,
          build: (context) => [
            pw.Anchor(name: 'medicines_section', child: pw.SizedBox()),
            ..._buildMedicinesPage(medicineLogs)
          ],
        ),
      );
    }

    // Page 5: Alerts
    if (includeAlerts) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: buildHeader,
          footer: buildFooter,
          build: (context) => [
            pw.Anchor(name: 'alerts_section', child: pw.SizedBox()),
            ..._buildAlertsPage(alerts)
          ],
        ),
      );
    }

    // Page 6: Quick Modules
    if (includeQuickModules) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: buildHeader,
          footer: buildFooter,
          build: (context) => [
            pw.Anchor(name: 'quick_modules_section', child: pw.SizedBox()),
            ..._buildQuickModulesPage(sleepLogs, nutritionLogs, activityLogs)
          ],
        ),
      );
    }

    // Page 7: Notes / Footer
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: buildHeader,
        footer: buildFooter,
        build: (context) => [
          pw.Anchor(name: 'physician_notes', child: pw.SizedBox()),
          ..._buildFooterPage()
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildCoverPage(String name, String age, String bloodGroup, String period, String genDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 60),
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(15)),
          ),
          child: pw.Center(
            child: pw.Text(
              "COMPREHENSIVE HEALTH REPORT",
              style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              textAlign: pw.TextAlign.center
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Center(
          child: pw.Text("Securely Generated by Health Monitor", style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
        ),
        
        pw.SizedBox(height: 60),
        
        pw.Container(
          padding: const pw.EdgeInsets.all(25),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
            border: pw.Border.all(color: PdfColors.blue300, width: 2)
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               pw.Text("PATIENT PROFILE", style: pw.TextStyle(fontSize: 20, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold)),
               pw.SizedBox(height: 20),
               _buildProfileRow("Patient Name:", name),
               pw.Divider(color: PdfColors.blue200),
               _buildProfileRow("Age:", age),
               pw.Divider(color: PdfColors.blue200),
               _buildProfileRow("Blood Group:", bloodGroup),
            ]
          )
        ),
        
        pw.Spacer(),
        
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey300)
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               _buildProfileRow("Report Period:", period),
               pw.SizedBox(height: 8),
               _buildProfileRow("Date Generated:", genDate),
            ]
          ),
        ),
        pw.SizedBox(height: 40),
      ],
    );
  }

  pw.Widget _buildTableOfContents({
    required bool includeVitals, 
    required bool includeMedicines, 
    required bool includeAlerts, 
    required bool includeQuickModules
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 40),
        pw.Text("Table of Contents", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple800)),
        pw.SizedBox(height: 10),
        pw.Text("Interactive Links: Tap an item below to jump directly to the section.", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.SizedBox(height: 30),
        
        if (includeVitals) _buildTocLink("Vitals Summary", 'vitals_section'),
        if (includeMedicines) _buildTocLink("Medicines Adherence", 'medicines_section'),
        if (includeAlerts) _buildTocLink("Health Alerts Log", 'alerts_section'),
        if (includeQuickModules) _buildTocLink("Quick Modules (Sleep, Nutrition, Activity)", 'quick_modules_section'),
        _buildTocLink("Physician Notes", 'physician_notes'),
      ]
    );
  }

  pw.Widget _buildTocLink(String title, String destination) {
     return pw.Padding(
       padding: const pw.EdgeInsets.symmetric(vertical: 8),
       child: pw.Link(
         destination: destination,
         child: pw.Row(
           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
           children: [
             pw.Text(title, style: pw.TextStyle(fontSize: 18, color: PdfColors.blue800, decoration: pw.TextDecoration.underline)),
           ]
         )
       )
     );
  }

  pw.Widget _buildProfileRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(width: 150, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
        pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
      ]
    );
  }

  List<pw.Widget> _buildVitalsPage(List<Map<String, dynamic>> vitals) {
    if (vitals.isEmpty) {
      return [pw.Header(level: 0, text: 'Vitals Summary'), pw.Text("No vitals recorded in this period.")];
    }

    final headers = ['Date', 'Type', 'Value', 'Unit'];
    
    final data = vitals.map((v) {
       DateTime dt = (v['timestamp'] as Timestamp).toDate();
       String dateStr = DateFormat('MMM dd, yyyy HH:mm').format(dt);
       String type = (v['metricType'] as String).toUpperCase();
       String valueStr = v.containsKey('value2') ? "${v['value'].toInt()}/${v['value2'].toInt()}" : "${v['value']}";
       String unitStr = v['unit'] ?? "";
       return [dateStr, type, valueStr, unitStr];
    }).toList();

    return [
      pw.Header(level: 0, text: 'Vitals Summary', textStyle: pw.TextStyle(color: PdfColors.blue800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.all(8),
      ),
    ];
  }

  List<pw.Widget> _buildMedicinesPage(List<Map<String, dynamic>> logs) {
     if (logs.isEmpty) {
      return [pw.Header(level: 0, text: 'Medicine Adherence'), pw.Text("No medications logged in this period.")];
    }

    // Simplistic breakdown counting instances taken
    Map<String, int> medicineCounts = {};
    for (var log in logs) {
      String name = log['medicineDetails']['name'] ?? "Unknown Med";
      medicineCounts[name] = (medicineCounts[name] ?? 0) + 1;
    }

    final data = medicineCounts.entries.map((e) => [e.key, e.value.toString() + " doses taken"]).toList();

    return [
      pw.Header(level: 0, text: 'Medicine Adherence', textStyle: pw.TextStyle(color: PdfColors.blue800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
      pw.TableHelper.fromTextArray(
        headers: ["Medicine", "Compliance Count"],
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.all(8),
      ),
    ];
  }

  List<pw.Widget> _buildAlertsPage(List<Map<String, dynamic>> alerts) {
    if (alerts.isEmpty) {
      return [pw.Header(level: 0, text: 'Health Alerts'), pw.Text("0 alerts triggered. Excellent health baseline!")];
    }

    final headers = ['Date', 'Severity', 'Trigger', 'Message'];
    
    final data = alerts.map((a) {
       DateTime dt = (a['timestamp'] as Timestamp).toDate();
       String dateStr = DateFormat('MMM dd, HH:mm').format(dt);
       String severity = (a['severity'] ?? "Normal").toString().toUpperCase();
       String trigger = a['value'] ?? "";
       String message = a['message'] ?? "";
       return [dateStr, severity, trigger, message];
    }).toList();

    return [
      pw.Header(level: 0, text: 'Alerts Log', textStyle: pw.TextStyle(color: PdfColors.red800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.all(8),
        /* Dynamic coloring is supported natively but row cell builders are complex so we keep raw data arrays */
      ),
    ];
  }

  List<pw.Widget> _buildQuickModulesPage(
    List<Map<String, dynamic>> sleepLogs, 
    List<Map<String, dynamic>> nutritionLogs, 
    List<Map<String, dynamic>> activityLogs
  ) {
    List<pw.Widget> content = [
      pw.Header(level: 0, text: 'Quick Modules Report', textStyle: pw.TextStyle(color: PdfColors.deepPurple800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
    ];

    if (sleepLogs.isEmpty && nutritionLogs.isEmpty && activityLogs.isEmpty) {
       content.add(pw.Text("No quick module data recorded in this period."));
       return content;
    }

    if (sleepLogs.isNotEmpty) {
      content.add(pw.Text("Sleep Tracking", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)));
      content.add(pw.SizedBox(height: 10));
      final headers = ['Date', 'Sleep Window', 'Duration', 'Quality'];
      final data = sleepLogs.map((log) {
        String dateStr = log['date'] ?? (log['timestamp'] != null && log['timestamp'] is Timestamp ? DateFormat('yyyy-MM-dd').format((log['timestamp'] as Timestamp).toDate()) : "Unknown Date");
        String window = "${log['bedTime'] ?? '--:--'} to ${log['wakeTime'] ?? '--:--'}";
        String dur = log['durationHours'] != null ? "${(log['durationHours'] as num).toDouble().toStringAsFixed(1)} hrs" : "0.0 hrs";
        String quality = log['quality']?.toString() ?? "N/A";
        return [dateStr, window, dur, quality];
      }).toList();
      content.add(pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo400),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
      ));
      content.add(pw.SizedBox(height: 30));
    }

    if (nutritionLogs.isNotEmpty) {
      content.add(pw.Text("Nutrition Tracking", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)));
      content.add(pw.SizedBox(height: 10));
      final headers = ['Date / Meal', 'Macros (Cal/Pro/Car/Fat)', 'Items Logged'];
      final data = nutritionLogs.map((log) {
        String dateStr = log['dateStamp'] ?? (log['timestamp'] != null && log['timestamp'] is Timestamp ? DateFormat('yyyy-MM-dd').format((log['timestamp'] as Timestamp).toDate()) : "Unknown Date");
        String meal = (log['mealType'] ?? "N/A").toString().toUpperCase();
        String macros = "${log['calories'] ?? 0} kcal / ${log['protein'] ?? 0}g / ${log['carbs'] ?? 0}g / ${log['fats'] ?? 0}g";
        
        // Safely parse food items and meal names
        String itemsStr = log['mealName']?.toString() ?? '';
        
        if ((itemsStr.isEmpty || itemsStr == 'null') && log['foodItems'] is List) {
           List<dynamic> itemsList = log['foodItems'];
           List<String> names = itemsList.map((e) {
             if (e is Map) return e['name']?.toString() ?? '';
             return '';
           }).where((e) => e.isNotEmpty).toList();
           if (names.isNotEmpty) itemsStr = names.join(', ');
        }
        
        if (itemsStr.isEmpty || itemsStr == 'null') {
           itemsStr = "Custom Entry";
        }
        
        return ["$dateStr\n$meal", macros, itemsStr];
      }).toList();
      content.add(pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.green500),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
      ));
      content.add(pw.SizedBox(height: 30));
    }

    if (activityLogs.isNotEmpty) {
      content.add(pw.Text("Activity Tracking", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)));
      content.add(pw.SizedBox(height: 10));
      final headers = ['Date', 'Total Steps', 'Distance'];
      final data = activityLogs.map((log) {
        String dateStr = log['timestamp'] != null && log['timestamp'] is Timestamp ? DateFormat('yyyy-MM-dd').format((log['timestamp'] as Timestamp).toDate()) : "Unknown Date";
        int manual = log['steps'] != null ? (log['steps'] as num).toInt() : 0;
        int auto = log['auto_steps'] != null ? (log['auto_steps'] as num).toInt() : 0;
        int total = manual + auto;
        String dist = log['distance'] != null ? "${(log['distance'] as num).toDouble().toStringAsFixed(2)} km" : "0.00 km";
        
        return [dateStr, total.toString(), dist];
      }).toList();
      content.add(pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.orange500),
        rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        cellAlignment: pw.Alignment.centerLeft,
      ));
    }

    return content;
  }

  List<pw.Widget> _buildFooterPage() {
    return [
      pw.Header(level: 0, text: 'Physician Notes', textStyle: pw.TextStyle(color: PdfColors.blue800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 40),
      _buildLine(),
      pw.SizedBox(height: 30),
      _buildLine(),
      pw.SizedBox(height: 30),
      _buildLine(),
      pw.SizedBox(height: 30),
      _buildLine(),
      pw.SizedBox(height: 30),
      _buildLine(),
      pw.SizedBox(height: 30),
      _buildLine(),
      
      pw.Spacer(),
    ];
  }

  pw.Widget _buildLine() {
    return pw.Container(
      height: 1, 
      width: double.infinity, 
      color: PdfColors.grey400
    );
  }
}
