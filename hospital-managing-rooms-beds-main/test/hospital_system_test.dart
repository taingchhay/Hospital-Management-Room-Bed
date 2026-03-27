import 'dart:io';

import 'package:test/test.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/services/managing_rooms_and_beds.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/patient.dart';
import 'package:HOSPITAL_MANAGING_ROOMS_BEDS/domain/models/enum.dart';

void main() {
  group('HospitalSystem admissions & updates', () {
    test('admit Yellow non-VIP goes to General', () {
      final hs = HospitalSystem();
      final patient = Patient(
        patientName: 'Anna John',
        gender: PatientGender.Female,
        entryDate: DateTime.now(),
        code: PatientCode.Yellow,
        isVIP: false,
      );

      hs.admitPatient(patient);
      expect(hs.activePatients, contains(patient));
      final location = hs.findPatientLocation(patient);
      expect(location, isNotNull);
      expect(location!.roomType.toString(), contains('General'));
    });

    test('admit Yellow VIP goes to GeneralVIP', () {
      final hs = HospitalSystem();
      final patient = Patient(
        patientName: 'Ben Ten',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Yellow,
        isVIP: true,
      );

      hs.admitPatient(patient);
      final location = hs.findPatientLocation(patient);
      expect(location, isNotNull);
      expect(location!.roomType, RoomType.GeneralVIP);
    });

    test('admit Red VIP goes to ICUVIP', () {
      final hs = HospitalSystem();
      final patient = Patient(
        patientName: 'Cali David',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Red,
        isVIP: true,
      );
      hs.admitPatient(patient);
      final location = hs.findPatientLocation(patient);
      expect(location, isNotNull);
      expect(location!.roomType, RoomType.ICUVIP);
    });

    test('update to Green recovers patient and frees bed', () {
      final hs = HospitalSystem();
      final patient = Patient(
        patientName: 'Dani John',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Yellow,
        isVIP: false,
      );
      hs.admitPatient(patient);
      expect(hs.activePatients, contains(patient));

      hs.updatePatientCode(patient, PatientCode.Green);
      expect(hs.activePatients.contains(patient), isFalse);
      expect(hs.recoveredPatients, contains(patient));
      final location = hs.findPatientLocation(patient);
      expect(location, isNull);
      expect(patient.history.last, 'Go home');
    });
  });

  group('HospitalSystem room status & persistence', () {
    //AI Generated
    test('getRoomStatus aggregates counts', () {
      final hs = HospitalSystem();
      final status = hs.getRoomStatus(); // Map<RoomType, RoomTypeStats>

      expect(
        status.keys,
        containsAll([
          RoomType.Emergency,
          RoomType.ICU,
          RoomType.ICUVIP,
          RoomType.General,
          RoomType.GeneralVIP
        ]),
      );

      final emergencyTotal =
          status[RoomType.Emergency]!.total; // 5 rooms x 1 bed
      final icuTotal = status[RoomType.ICU]!.total; // 15 rooms x 5 beds
      final icuVipTotal = status[RoomType.ICUVIP]!.total; // 10 rooms x 1 bed
      final generalTotal =
          status[RoomType.General]!.total; // 15 rooms x 10 beds
      final generalVipTotal =
          status[RoomType.GeneralVIP]!.total; // 10 rooms x 1 bed

      expect(emergencyTotal, 5 * 1);
      expect(icuTotal, 15 * 5);
      expect(icuVipTotal, 10 * 1);
      expect(generalTotal, 15 * 10);
      expect(generalVipTotal, 10 * 1);
    });

    test('saveData/loadData roundtrip', () async {
      final hs = HospitalSystem();
      final p1 = Patient(
        patientName: 'Eve Son',
        gender: PatientGender.Female,
        entryDate: DateTime.now(),
        code: PatientCode.Black,
        isVIP: false,
      );
      final p2 = Patient(
        patientName: 'Finn Dana',
        gender: PatientGender.Male,
        entryDate: DateTime.now(),
        code: PatientCode.Yellow,
        isVIP: true,
      );

      hs.admitPatient(p1);
      hs.admitPatient(p2);
      hs.updatePatientCode(p2, PatientCode.Green);

      final tmp = await File(
              '${Directory.systemTemp.path}/hs_${DateTime.now().microsecondsSinceEpoch}.json')
          .create(recursive: true);
      await hs.saveData(tmp.path);

      final hs2 = HospitalSystem();
      await hs2.loadData(tmp.path);

      expect(
          hs2.activePatients.any((patient) => patient.patientName == 'Eve Son'),
          isTrue);
      expect(
          hs2.recoveredPatients
              .any((patient) => patient.patientName == 'Finn Dana'),
          isTrue);

      final eve = hs2.activePatients
          .firstWhere((patient) => patient.patientName == 'Eve Son');
      expect(hs2.findPatientLocation(eve), isNotNull);

      final finn = hs2.recoveredPatients
          .firstWhere((patient) => patient.patientName == 'Finn Dana');
      expect(finn.history.contains('Go home'), isTrue);

      await tmp.delete();
    });
  });
}
