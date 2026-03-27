import 'package:test/test.dart';
import '../lib/domain/models/room.dart';
import '../lib/domain/models/patient.dart';
import '../lib/domain/models/enum.dart';

void main() {
  group('Rooms', () {
    test('getAvailableBed returns next available bed', () {
      final room = GeneralRoom(roomNumber: 1); // 10 beds
      expect(room.getAvailableBed(), isNotNull);

      // Fill all beds
      for (var i = 0; i < room.beds.length; i++) {
        final p = Patient(
          patientName: 'P$i',
          gender: PatientGender.Male,
          entryDate: DateTime.now(),
          code: PatientCode.Yellow,
          isVIP: false,
        );
        final bed = room.getAvailableBed();
        expect(bed, isNotNull);
        bed!.assignPatient(p);
      }

      // Now should be full
      expect(room.getAvailableBed(), isNull);
    });
  });
}
