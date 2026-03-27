import 'package:test/test.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/patient.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/enum.dart';

void main() {
  group('Patient model', () {
    test('toJson/fromJson roundtrip', () {
      final p = Patient(
        patientName: 'Alice John',
        gender: PatientGender.Female,
        entryDate: DateTime.utc(2025, 1, 2, 3, 4, 5),
        code: PatientCode.Yellow,
        isVIP: true,
      );
      p.history.addAll(['Yellow', 'General']);
      final json = p.toJson();
      final p2 = Patient.fromJson(json);

      expect(p2.patientName, 'Alice John');
      expect(p2.gender, PatientGender.Female);
      expect(p2.entryDate.toUtc(), DateTime.utc(2025, 1, 2, 3, 4, 5));
      expect(p2.code, PatientCode.Yellow);
      expect(p2.isVIP, true);
      expect(p2.history, ['Yellow', 'General']);
    });

    test('assignBed and releaseBed update state', () {
      final p = Patient(
        patientName: 'Bob Ten',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Red,
        isVIP: false,
      );

      expect(p.currentBedId, isNull);
      expect(p.bedHistory, isEmpty);

      p.assignBed('bed-1');
      expect(p.currentBedId, 'bed-1');
      expect(p.bedHistory, ['bed-1']);

      p.releaseBed();
      expect(p.currentBedId, isNull);
      expect(p.bedHistory, ['bed-1']);
    });
  });
}
