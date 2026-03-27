import 'enum.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Patient {
  String patientId;
  final String patientName;
  final PatientGender gender;
  final DateTime entryDate;
  DateTime? leaveDate;
  PatientCode code;
  bool isVIP;

  String? currentBedId;
  List<String> bedHistory = [];
  List<String> history = [];

  Patient(
      {String? patientId,
      required this.patientName,
      required this.gender,
      required this.entryDate,
      required this.code,
      required this.isVIP,
      this.leaveDate})
      : patientId = patientId ?? uuid.v4();

  void updatePatientCode(PatientCode newCode) {
    code = newCode;
  }

  void assignBed(String bedId) {
    currentBedId = bedId;
    bedHistory.add(bedId);
  }

  void releaseBed() => currentBedId = null;

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'patientName': patientName,
        'gender': gender.toString().split('.').last,
        'entryDate': entryDate.toIso8601String(),
        'leaveDate': leaveDate?.toIso8601String(),
        'code': code.toString().split('.').last,
        'isVip': isVIP,
        'currentBedId': currentBedId,
        'bedHistory': bedHistory,
        'history': history,
      };

  //AI Generated
  factory Patient.fromJson(Map<String, dynamic> json) {
    var patient = Patient(
      patientId: json['patientId'],
      patientName: json['patientName'],
      gender: PatientGender.values
          .firstWhere((g) => g.toString().split('.').last == json['gender']),
      entryDate: DateTime.parse(json['entryDate']),
      leaveDate:
          json['leaveDate'] != null ? DateTime.parse(json['leaveDate']) : null,
      code: PatientCode.values
          .firstWhere((c) => c.toString().split('.').last == json['code']),
      isVIP: json['isVip'] ?? json['IsVip'] ?? false,
    );
    patient.currentBedId = json['currentBedId'];
    patient.bedHistory = List<String>.from(json['bedHistory'] ?? []);
    patient.history = List<String>.from(json['history'] ?? []);
    return patient;
  }
}

class PatientLocation {
  final RoomType roomType;
  final String roomId;
  final int roomIndexWithinType;
  final String bedId;
  final int bedIndexWithinRoom;

  PatientLocation({
    required this.roomType,
    required this.roomId,
    required this.roomIndexWithinType,
    required this.bedId,
    required this.bedIndexWithinRoom,
  });
}
