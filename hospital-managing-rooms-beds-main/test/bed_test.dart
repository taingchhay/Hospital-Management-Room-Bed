import 'package:test/test.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/bed.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/enum.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/patient.dart';

void main() {
  group('Bed', () {
    test('assign and release patient', () {
      final bed = Bed();
      final patient = Patient(
        patientName: 'Chris',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Black,
        isVIP: false,
      );

      expect(bed.bedStatus, BedStatus.Available);
      expect(bed.patient, isNull);

      bed.assignPatient(patient);
      expect(bed.bedStatus, BedStatus.Occupied);
      expect(bed.patient, isNotNull);
      expect(patient.currentBedId, bed.bedId);
      expect(patient.bedHistory.contains(bed.bedId), isTrue);

      bed.releasePatient();
      expect(bed.bedStatus, BedStatus.Available);
      expect(bed.patient, isNull);
      expect(patient.currentBedId, isNull);
    });
  });
}
