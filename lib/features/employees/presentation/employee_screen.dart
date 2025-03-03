import 'package:attendance_management_app/features/employees/presentation/widgets/add_employee.dart';
import 'package:attendance_management_app/features/employees/presentation/widgets/employee_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_bloc.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(FetchEmployeesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocBuilder<EmployeeBloc, EmployeeState>(builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmployeeLoaded) {
            final employees = state.employees;
            return employees.isEmpty
                ? const Center(child: Text("No employees found"))
                : ListView.builder(
                    itemCount: employees.length + 1,
                    itemBuilder: (context, index) {
                      if (index < employees.length) {
                        final employee = employees[index];
                        return EmployeeTile(
                            employee: employee,
                            onTap: !employee.isActive
                                ? null
                                : () {
                                    context.read<EmployeeBloc>().add(RemoveEmployeeEvent(employee.id));
                                  });
                      } else {
                        return SizedBox(height: 60);
                      }
                    },
                  );
          } else if (state is EmployeeError) {
            return Center(child: Text("No employees found"));
          }
          return const Center(child: Text("No employees found"));
        }),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () => _showAddEmployeeDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddEmployee());
  }
}
