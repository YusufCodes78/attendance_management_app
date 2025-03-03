class AttendanceModel{
  final DateTime date;
  final String employeeName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String overtime;
  final String status;

  AttendanceModel({
    required this.date,
    required this.employeeName,
    required this.checkIn,
    required this.checkOut,
    required this.overtime,
    required this.status
  });

  AttendanceModel copyWith({
    DateTime? date,
    String? employeeName,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    String? overtime,
  }) {
    return AttendanceModel(
      date: date ?? this.date,
      employeeName: employeeName ?? this.employeeName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      overtime: overtime ?? this.overtime,
    );
  }

  List<Object?> get props => [date, employeeName, checkIn, checkOut, status, overtime];
  
}