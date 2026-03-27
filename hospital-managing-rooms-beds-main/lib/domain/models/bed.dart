import 'enum.dart';
import 'patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Bed {
  final String bedId;
  BedStatus bedStatus;
  Patient? patient;

  Bed({String? bedId, this.bedStatus = BedStatus.Available, this.patient})
      : bedId = bedId ?? uuid.v4();

  void assignPatient(Patient newPatient) {
    patient = newPatient;
    newPatient.assignBed(bedId);
    bedStatus = BedStatus.Occupied;
  }

  void releasePatient() {
    patient?.releaseBed();
    patient = null;
    bedStatus = BedStatus.Available;
  }

  Map<String, dynamic> toJson() => {
        'bedId': bedId,
        'bedStatus': bedStatus.toString().split('.').last,
        'patient': patient?.toJson(),
      };

  factory Bed.fromJson(Map<String, dynamic> json) => Bed(
        bedId: json['bedId'],
        bedStatus: BedStatus.values.firstWhere(
            (s) => s.toString().split('.').last == json['bedStatus']),
        patient:
            json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      );
}
