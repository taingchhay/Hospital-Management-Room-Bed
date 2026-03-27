import 'dart:io';
import '../domain/models/enum.dart';
import '../domain/models/patient.dart';
import '../domain/services/managing_rooms_and_beds.dart';
import '../domain/models/room.dart';

class HospitalConsoleUI {
  final HospitalSystem system = HospitalSystem();

  final String dataFilePath = 'lib/data/hospital_data.json';

  Future<void> start() async {
    while (true) {
      print('\n=== Hospital Management System ===');
      print('1. Admit new patient');
      print('2. Update patient code');
      print('3. Show active patients');
      print('4. Show recovered patients');
      print('5. Show room & bed availability');
      print('6. Search patient by name');
      print('0. Exit');
      stdout.write('Select: ');
      var choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          await admitPatientFlow();
          break;
        case '2':
          await updatePatientFlow();
          break;
        case '3':
          await showActivePatients();
          break;
        case '4':
          await showRecoveredPatients();
          break;
        case '5':
          await showRoomAvailability();
          break;
        case '6':
          await searchPatient();
          break;
        case '0':
          print('Exiting...');
          return;
        default:
          print('Invalid option. Try again.');
      }
    }
  }

  Future<void> admitPatientFlow() async {
    final String name = inputEmpty('Enter patient name: ');
    final PatientGender gender = inputGender();
    final PatientCode code = inputPatientCode();
    final bool isVip = inputYesNo('Is VIP? (y/n): ');

    var patient = Patient(
      patientName: name,
      gender: gender,
      entryDate: DateTime.now(),
      code: code,
      isVIP: isVip,
    );

    system.admitPatient(patient);

    await system.saveData(dataFilePath);

    print('$name admitted successfully.');
  }

  Future<void> updatePatientFlow() async {
    if (system.activePatients.isEmpty) {
      print('No active patients.');
      return;
    }

    print('\nActive patients:');
    for (int i = 0; i < system.activePatients.length; i++) {
      print(
          '${i + 1}. ${system.activePatients[i].patientName} (${enumName(system.activePatients[i].code)})');
    }

    final index = patientIndex('Select patient number to update: ', 1,
            system.activePatients.length) -
        1;

    var patient = system.activePatients[index];

    final newCode =
        inputPatientCode(prompt: 'Enter new code (Black/Red/Yellow/Green): ');

    system.updatePatientCode(patient, newCode);

    await system.saveData(dataFilePath);

    print(
        'Patient ${patient.patientName} code updated to ${enumName(newCode)}.');
  }

  Future<void> showActivePatients() async {
    await system.loadData(dataFilePath);

    if (system.activePatients.isEmpty) {
      print('No active patients.');
      return;
    }
    print('\n--- Active Patients ---');
    for (var p in system.activePatients) {
      final location = system.findPatientLocation(p);
      final roomInfo = location == null
          ? 'Room: - | Bed: -'
          : 'Room: ${enumName(location.roomType)} #${location.roomIndexWithinType} | Bed: ${bedLabel(location.roomType, location.roomIndexWithinType, location.bedIndexWithinRoom)}';
      print(
          '${p.patientName} | Code: ${enumName(p.code)} | Gender: ${enumName(p.gender)} | VIP: ${p.isVIP ? 'Yes' : 'No'} | $roomInfo');
    }
  }

  Future<void> showRecoveredPatients() async {
    await system.loadData(dataFilePath);

    if (system.recoveredPatients.isEmpty) {
      print('No recovered patients.');
      return;
    }
    print('\n--- Recovered Patients ---');
    for (var p in system.recoveredPatients) {
      print('${p.patientName} | Left on: ${p.leaveDate}');
    }
  }

  Future<void> showRoomAvailability() async {
    await system.loadData(dataFilePath);

    print('\n--- Room & Bed Availability ---');
    final status = system.getRoomStatus();
    status.forEach((type, stats) {
      print(
          '${enumName(type)} → Rooms: ${stats.rooms} | Available: ${stats.available} | Occupied: ${stats.occupied} | Total: ${stats.total}');
    });

    print('\n--- Per-room availability ---');
    final byType = <RoomType, List<Rooms>>{};
    for (final r in system.allRooms) {
      byType.putIfAbsent(r.roomType, () => []).add(r);
    }

    for (final entry in byType.entries) {
      final type = entry.key;
      final rooms = entry.value;
      print('\n${enumName(type)} rooms:');
      for (int i = 0; i < rooms.length; i++) {
        final room = rooms[i];
        final total = room.beds.length;
        final available =
            room.beds.where((b) => b.bedStatus == BedStatus.Available).length;
        final occupied = total - available;
        print(
            '  ${enumName(type)} #${i + 1} → Available: $available | Occupied: $occupied | Total: $total');
      }
    }
  }

  Future<void> searchPatient() async {
    await system.loadData(dataFilePath);

    stdout.write('Enter patient name to search: ');
    final input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) {
      print('Search cancelled.');
      return;
    }
    String searchName = input.trim();

    final allMatches = <Patient>[];
    allMatches.addAll(system.activePatients
        .where((p) => p.patientName.toLowerCase() == searchName.toLowerCase()));
    allMatches.addAll(system.recoveredPatients
        .where((p) => p.patientName.toLowerCase() == searchName.toLowerCase()));

    if (allMatches.isEmpty) {
      print('Patient not found.');
      return;
    }

    //AI Generated
    final records = List<Patient>.from(allMatches)
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate)); // most recent first

    print('\n--- Matching records (${records.length}) ---');
    int idx = 1;
    for (final p in records) {
      print('\nRecord #$idx');
      print('Name: ${p.patientName}');
      print('Gender: ${enumName(p.gender)}');
      print('Code: ${enumName(p.code)}');
      print('VIP: ${p.isVIP ? "Yes" : "No"}');
      print('Entry Date: ${p.entryDate}');
      print('Leave Date: ${p.leaveDate ?? "Still in hospital"}');

      final location = system.findPatientLocation(p);
      if (location != null) {
        final typeName = enumName(location.roomType);
        final currentbedLabel = bedLabel(location.roomType,
            location.roomIndexWithinType, location.bedIndexWithinRoom);
        print(
            'Current: Room $typeName #${location.roomIndexWithinType}, Bed $currentbedLabel');
      }

      final chain = buildHistoryLine(p) ?? '(no history)';
      print('History: $chain');

      idx++;
    }
  }

  String enumName(Object value) => value.toString().split('.').last;

  String bedLabel(
      RoomType type, int roomIndexWithinType, int bedIndexWithinRoom) {
    final perRoom = bedsPerRoom(type);
    final globalIndex =
        (roomIndexWithinType - 1) * perRoom + bedIndexWithinRoom;
    final typeName = enumName(type);
    return '$typeName$globalIndex';
  }

  int bedsPerRoom(RoomType type) {
    switch (type) {
      case RoomType.ICU:
        return 5;
      case RoomType.General:
        return 10;
      case RoomType.Emergency:
      case RoomType.ICUVIP:
      case RoomType.GeneralVIP:
        return 1;
    }
  }

  String inputEmpty(String prompt) {
    while (true) {
      stdout.write(prompt);
      final input = stdin.readLineSync();
      if (input != null) {
        final v = input.trim();
        if (v.isNotEmpty) return v;
      }
      print('Please enter patient name.');
    }
  }

  bool inputYesNo(String prompt) {
    while (true) {
      stdout.write(prompt);
      final input = stdin.readLineSync();
      if (input == null) continue;
      final v = input.trim().toLowerCase();
      if (v == 'y' || v == 'yes') return true;
      if (v == 'n' || v == 'no') return false;
      print("Please enter 'y' or 'n'.");
    }
  }

  int patientIndex(String prompt, int min, int max) {
    while (true) {
      stdout.write(prompt);
      final input = stdin.readLineSync();
      final idx = int.tryParse(input ?? '');
      if (idx != null && idx >= min && idx <= max) return idx;
      print('Enter a number between $min and $max.');
    }
  }

  PatientGender inputGender() {
    while (true) {
      stdout.write('Gender (Male/Female): ');
      final input = stdin.readLineSync();
      if (input == null) continue;
      final v = input.trim().toLowerCase();
      if (v == 'male' || v == 'm') return PatientGender.Male;
      if (v == 'female' || v == 'f') return PatientGender.Female;
      print("Please enter 'Male' or 'Female'.");
    }
  }

  PatientCode inputPatientCode(
      {String prompt = 'Patient code (Black/Red/Yellow/Green): '}) {
    while (true) {
      stdout.write(prompt);
      final input = stdin.readLineSync();
      if (input == null) continue;
      final v = input.trim().toLowerCase();
      switch (v) {
        case 'black':
        case 'b':
        case '1':
          return PatientCode.Black;
        case 'red':
        case 'r':
        case '2':
          return PatientCode.Red;
        case 'yellow':
        case 'y':
        case '3':
          return PatientCode.Yellow;
        case 'green':
        case 'g':
        case '4':
          return PatientCode.Green;
      }
      print("Invalid code. Use Black/Red/Yellow/Green (or 1/2/3/4).");
    }
  }

  String? buildHistoryLine(Patient patient) {
    final raw = <String>[];
    if (patient.history.isNotEmpty) {
      raw.addAll(patient.history);
    } else {
      raw.add(enumName(patient.code));
      final location = system.findPatientLocation(patient);
      if (location != null) {
        raw.add(enumName(location.roomType));
      }
      if (patient.leaveDate != null) {
        raw.add('Go home');
      }
    }
    if (raw.isEmpty) return null;

    final codeNames = PatientCode.values.map(enumName).toSet();
    final roomNames = RoomType.values.map(enumName).toSet();
    final labeled = raw.map((s) {
      if (s == 'Go home') return s;
      if (codeNames.contains(s)) return 'Code: ' + s;
      if (roomNames.contains(s)) return 'Room: ' + s;
      return s; // unknown token, print as-is
    }).toList();

    return labeled.join(' -> ');
  }
}
