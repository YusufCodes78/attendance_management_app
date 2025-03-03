import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gsheets/gsheets.dart';

class GSheetsService {
  final String spreadsheetId;
  late GSheets gsheets;
  late Spreadsheet spreadsheet;

  GSheetsService({required this.spreadsheetId});

  Future<void> init() async {
    try {
      debugPrint("[GSheetsService] Loading credentials...");
      final credentials = await rootBundle.loadString('assets/gsheets_credentials.json');
      gsheets = GSheets(credentials);
      debugPrint("[GSheetsService] Credentials loaded successfully!");

      debugPrint("[GSheetsService] Fetching spreadsheet...");
      spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      debugPrint("[GSheetsService] Spreadsheet fetched successfully!");
    } catch (e) {
      debugPrint("[GSheetsService] ERROR: $e");
    }
  }

  Future<Worksheet> getWorksheet(String sheetTitle) async {
    try {
      debugPrint("[GSheetsService] Fetching worksheet: $sheetTitle");
      return spreadsheet.worksheetByTitle(sheetTitle) ??
             (await spreadsheet.addWorksheet(sheetTitle));
    } catch (e) {
      debugPrint("[GSheetsService] ERROR fetching worksheet ($sheetTitle): $e");
      rethrow;
    }
  }
}
