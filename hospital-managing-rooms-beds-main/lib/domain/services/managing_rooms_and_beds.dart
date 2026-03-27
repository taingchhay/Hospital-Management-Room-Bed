import '../models/patient.dart';
import '../models/room.dart';
import '../models/enum.dart';
import '../../data/storing_data_repository.dart';

class HospitalSystem {
  final List<EmergencyRoom> emergencyRooms;
  final List<ICURoom> icuRooms;
  final List<GeneralRoom> generalRooms;
  final List<ICUVipRoom> icuVipRooms;
  final List<GeneralVIPRoom> generalVipRooms;

  int nextRoomNumber = 1;

  int allocateRoomNumber() => nextRoomNumber++;

  //AI Generated
  HospitalSystem()
      : emergencyRooms = [],
        icuRooms = [],
        generalRooms = [],
        icuVipRooms = [],
        generalVipRooms = [] {
    for (int i = 0; i < 5; i++) {
      emergencyRooms.add(EmergencyRoom(roomNumber: allocateRoomNumber()));
    }
    for (int i = 0; i < 15; i++) {
      icuRooms.add(ICURoom(roomNumber: allocateRoomNumber()));
    }
    for (int i = 0; i < 15; i++) {
      generalRooms.add(GeneralRoom(roomNumber: allocateRoomNumber()));
    }
    for (int i = 0; i < 10; i++) {
      icuVipRooms.add(ICUVipRoom(roomNumber: allocateRoomNumber()));
    }
    for (int i = 0; i < 10; i++) {
      generalVipRooms.add(GeneralVIPRoom(roomNumber: allocateRoomNumber()));
    }
  }

  final List<Patient> activePatients = [];
  final List<Patient> recoveredPatients = [];

  String enumName(Object value) => value.toString().split('.').last;

  void admitPatient(Patient patient) {
    activePatients.add(patient);
    patient.history.add(enumName(patient.code));

    switch (patient.code) {
      case PatientCode.Black:
        moveToEmergency(patient);
        break;
      case PatientCode.Red:
        moveToICU(patient);
        break;
      case PatientCode.Yellow:
        moveToGeneral(patient);
        break;
      case PatientCode.Green:
        markAsRecovered(patient);
        break;
    }
  }

  void updatePatientCode(Patient patient, PatientCode newCode) {
    updatePatientCodeWithTargetRoom(patient, newCode, targetRoom: null);
  }

  void updatePatientCodeWithTargetRoom(Patient patient, PatientCode newCode,
      {Rooms? targetRoom}) {
    patient.updatePatientCode(newCode);
    patient.history.add(enumName(newCode));

    if (newCode == PatientCode.Green) {
      markAsRecovered(patient);
      return;
    }

    Rooms? destination = targetRoom ?? findRoomForCode(newCode, patient.isVIP);
    if (destination != null) {
      releasePatientBed(patient);
      movePatientToRoom(patient, destination);
    }
  }

  void markAsRecovered(Patient patient) {
    patient.leaveDate = DateTime.now();
    patient.history.add('Go home');
    recoveredPatients.add(patient);
    releasePatientBed(patient);
    activePatients.remove(patient);
  }

  void releasePatientBed(Patient patient) {
    for (var room in allRooms) {
      for (var bed in room.beds) {
        if (bed.patient?.patientId == patient.patientId) {
          bed.releasePatient();
          return;
        }
      }
    }
  }

  void moveToEmergency(Patient patient) {
    for (var room in emergencyRooms) {
      var bed = room.getAvailableBed();
      if (bed != null) {
        bed.assignPatient(patient);
        patient.history.add(enumName(room.roomType));
        return;
      }
    }
  }

  void moveToICU(Patient patient) {
    List<Rooms> rooms = patient.isVIP ? icuVipRooms : icuRooms;
    for (var room in rooms) {
      var bed = room.getAvailableBed();
      if (bed != null) {
        bed.assignPatient(patient);
        patient.history.add(enumName(room.roomType));
        return;
      }
    }
  }

  void moveToGeneral(Patient patient) {
    List<Rooms> rooms = patient.isVIP ? generalVipRooms : generalRooms;
    for (var room in rooms) {
      var bed = room.getAvailableBed();
      if (bed != null) {
        bed.assignPatient(patient);
        patient.history.add(enumName(room.roomType));
        return;
      }
    }
  }

  void movePatientToRoom(Patient patient, Rooms room) {
    releasePatientBed(patient);
    final bed = room.getAvailableBed();
    if (bed != null) {
      bed.assignPatient(patient);
      patient.history.add(enumName(room.roomType));
    }
  }

  bool roomHasAvailability(Rooms room) => room.getAvailableBed() != null;

  Rooms? findRoomForCode(PatientCode code, bool isVip) {
    switch (code) {
      case PatientCode.Black:
        for (final r in emergencyRooms) {
          if (roomHasAvailability(r)) return r;
        }
        return null;
      case PatientCode.Red:
        final list = isVip ? icuVipRooms : icuRooms;
        for (final r in list) {
          if (roomHasAvailability(r)) return r;
        }
        return null;
      case PatientCode.Yellow:
        final list = isVip ? generalVipRooms : generalRooms;
        for (final r in list) {
          if (roomHasAvailability(r)) return r;
        }
        return null;
      case PatientCode.Green:
        return null;
    }
  }

  List<Rooms> get allRooms => [
        ...emergencyRooms,
        ...icuRooms,
        ...generalRooms,
        ...icuVipRooms,
        ...generalVipRooms
      ];

  //AI Generated
  Map<RoomType, RoomTypeStats> getRoomStatus() {
    final status = <RoomType, RoomTypeStats>{};
    for (final room in allRooms) {
      final type = room.roomType;
      final availableCount =
          room.beds.where((b) => b.bedStatus == BedStatus.Available).length;
      final totalCount = room.beds.length;
      final occupiedCount = totalCount - availableCount;

      final prev = status[type] ?? const RoomTypeStats();
      status[type] = prev.add(
        rooms: 1,
        available: availableCount,
        occupied: occupiedCount,
        total: totalCount,
      );
    }
    return status;
  }

  Future<void> saveData(String filePath) async {
    await StoringDataRepository().saveData(this, filePath);
  }

  Future<void> loadData(String filePath) async {
    await StoringDataRepository().loadData(this, filePath);
  }

  PatientLocation? findPatientLocation(Patient patient) {
    final byType = <RoomType, List<Rooms>>{};
    for (final r in allRooms) {
      byType.putIfAbsent(r.roomType, () => []).add(r);
    }

    for (final entry in byType.entries) {
      final type = entry.key;
      final rooms = entry.value;
      for (int i = 0; i < rooms.length; i++) {
        final room = rooms[i];
        for (int j = 0; j < room.beds.length; j++) {
          final b = room.beds[j];
          if (b.bedId == patient.currentBedId ||
              b.patient?.patientId == patient.patientId) {
            return PatientLocation(
              roomType: type,
              roomId: room.roomId,
              roomIndexWithinType: i + 1,
              bedId: b.bedId,
              bedIndexWithinRoom: j + 1,
            );
          }
        }
      }
    }
    return null;
  }
}

// AI Generated
class RoomTypeStats {
  final int rooms;
  final int available;
  final int occupied;
  final int total;

  const RoomTypeStats({
    this.rooms = 0,
    this.available = 0,
    this.occupied = 0,
    this.total = 0,
  });

  RoomTypeStats add({
    int rooms = 0,
    int available = 0,
    int occupied = 0,
    int total = 0,
  }) {
    return RoomTypeStats(
      rooms: this.rooms + rooms,
      available: this.available + available,
      occupied: this.occupied + occupied,
      total: this.total + total,
    );
  }

  Map<String, int> toJson() => {
        'rooms': rooms,
        'available': available,
        'occupied': occupied,
        'total': total,
      };
}