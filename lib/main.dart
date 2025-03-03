import 'package:attendance_management_app/core/services/gsheets_repository.dart';
import 'package:attendance_management_app/core/services/gsheets_service.dart';
import 'package:attendance_management_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:attendance_management_app/features/employees/bloc/employee_bloc.dart';
import 'package:attendance_management_app/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String spreadsheetId = "1aed4jY2CNUG8Jfgtyi-Ip8NKN4hV6WGkTUEEgRCopHs";
  debugPrint("[Main] Initializing Google Sheets Service...");
  final gsheetsService = GSheetsService(spreadsheetId: spreadsheetId);
  final gsheetsRepository = GSheetsRepository(gsheetsService: gsheetsService);
  await gsheetsRepository.init();
  debugPrint("[Main] Running the Flutter app...");
  runApp(MainApp(gsheetsRepository: gsheetsRepository));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.gsheetsRepository});
  final GSheetsRepository gsheetsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            debugPrint("[Main] Initializing AttendanceBloc...");
            return AttendanceBloc(gsheetsRepository: gsheetsRepository)..add(FetchAttendanceEvent(DateTime.now()));
          },
        ),
        BlocProvider(
          create: (_) {
            debugPrint("[Main] Initializing EmployeeBloc...");
            return EmployeeBloc(gsheetsRepository: gsheetsRepository)..add(FetchEmployeesEvent());
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance Management App',
        home: HomeScreen(),
        theme: ThemeData(
            appBarTheme: AppBarTheme(centerTitle: true),
            colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: Colors.blue.shade700,
                onPrimary: Colors.white,
                secondary: Colors.amber,
                onSecondary: Colors.black,
                error: Colors.red,
                onError: Colors.white,
                surface: Color(0xFFF3F3F4),
                onSurface: Colors.black)),
      ),
    );
  }
}
