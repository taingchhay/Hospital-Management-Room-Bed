import 'package:test/test.dart';
import '../lib/domain/models/bed.dart';
import '../lib/domain/models/enum.dart';
import '../lib/domain/models/patient.dart';

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
