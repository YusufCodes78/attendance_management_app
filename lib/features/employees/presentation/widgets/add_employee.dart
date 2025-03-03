import 'package:attendance_management_app/features/employees/bloc/employee_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final TextEditingController controller = TextEditingController();
  bool _validate = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text("Add New Employee"),
          actionsAlignment: MainAxisAlignment.center,
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Enter name",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                errorText: _validate ? "Name is required" : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey.shade300))),
            onEditingComplete: () => setState(() => _validate = controller.text.isEmpty),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue.shade700),
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60)),
              ),
              onPressed: () {
                final name = controller.text;
                if (name.isNotEmpty) {
                  setState(() {
                    _validate = false;
                  });
                  context.read<EmployeeBloc>().add(AddEmployeeEvent(name));
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _validate = controller.text.isEmpty;
                  });
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
}
