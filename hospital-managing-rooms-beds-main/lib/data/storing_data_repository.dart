import 'dart:convert';
import 'dart:io';

import '../domain/models/patient.dart';
import '../domain/models/room.dart';
import '../domain/models/enum.dart';
import '../domain/services/managing_rooms_and_beds.dart';

class StoringDataRepository {
  Future<void> saveData(HospitalSystem system, String filePath) async {
    final data = {
      'activePatients': system.activePatients.map((p) => p.toJson()).toList(),
      'recoveredPatients':
          system.recoveredPatients.map((p) => p.toJson()).toList(),
      'rooms': system.allRooms.map((r) => r.toJson()).toList(),
    };

    final file = File(filePath);
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> loadData(HospitalSystem system, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final jsonString = await file.readAsString();
    if (jsonString.trim().isEmpty) return;

    final Map<String, dynamic> data = jsonDecode(jsonString);

    system.activePatients.clear();
    system.recoveredPatients.clear();
    for (final p in data['activePatients']) {
      system.activePatients.add(Patient.fromJson(p));
    }
    for (final p in data['recoveredPatients']) {
      system.recoveredPatients.add(Patient.fromJson(p));
    }

    final roomList =
        (data['rooms'] as List).map((r) => Rooms.fromJson(r)).toList();

    system.emergencyRooms.clear();
    system.icuRooms.clear();
    system.icuVipRooms.clear();
    system.generalRooms.clear();
    system.generalVipRooms.clear();

    for (final room in roomList) {
      switch (room.roomType) {
        case RoomType.Emergency:
          system.emergencyRooms.add(room as EmergencyRoom);
          break;
        case RoomType.ICU:
          system.icuRooms.add(room as ICURoom);
          break;
        case RoomType.ICUVIP:
          system.icuVipRooms.add(room as ICUVipRoom);
          break;
        case RoomType.General:
          system.generalRooms.add(room as GeneralRoom);
          break;
        case RoomType.GeneralVIP:
          system.generalVipRooms.add(room as GeneralVIPRoom);
          break;
      }
    }

    for (final room in system.allRooms) {
      for (final bed in room.beds) {
        final bedPatient = bed.patient;
        if (bedPatient == null) continue;
        final match = system.activePatients
            .where((p) => p.patientId == bedPatient.patientId);
        if (match.isNotEmpty) {
          bed.patient = match.first;
          match.first.assignBed(bed.bedId);
        }
      }
    }
  }
}
