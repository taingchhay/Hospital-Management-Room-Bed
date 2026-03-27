import 'bed.dart';
import 'enum.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

abstract class Rooms {
  final String roomId;
  final int roomNumber;
  final List<Bed> beds;
  final RoomType roomType;

  Rooms(
      {String? roomId,
      required this.roomType,
      required this.beds,
      required this.roomNumber})
      : roomId = roomId ?? uuid.v4();
  
  Bed? getAvailableBed() {
    for (final b in beds) {
      if (b.bedStatus == BedStatus.Available) return b;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'roomType': roomType.toString().split('.').last,
        'roomNumber': roomNumber,
        'beds': beds.map((b) => b.toJson()).toList(),
      };

  //AI Generated
  factory Rooms.fromJson(Map<String, dynamic> json) {
    var type = RoomType.values
        .firstWhere((t) => t.toString().split('.').last == json['roomType']);
    List<Bed> bedList =
        (json['beds'] as List).map((b) => Bed.fromJson(b)).toList();
    
    int parseRoomNumber(dynamic v) {
      if (v == null)
        return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is double) return v.toInt();
      return 0;
    }

    final int parsedRoomNumber = parseRoomNumber(json['roomNumber']);

    switch (type) {
      case RoomType.Emergency:
        return EmergencyRoom(beds: bedList, roomNumber: parsedRoomNumber);
      case RoomType.ICU:
        return ICURoom(beds: bedList, roomNumber: parsedRoomNumber);
      case RoomType.ICUVIP:
        return ICUVipRoom(beds: bedList, roomNumber: parsedRoomNumber);
      case RoomType.General:
        return GeneralRoom(beds: bedList, roomNumber: parsedRoomNumber);
      case RoomType.GeneralVIP:
        return GeneralVIPRoom(beds: bedList, roomNumber: parsedRoomNumber);
    }
  }
}

/// ===== SUBCLASSES =====

class EmergencyRoom extends Rooms {
  EmergencyRoom({List<Bed>? beds, required int roomNumber})
      : super(
            roomType: RoomType.Emergency,
            beds: beds ?? [Bed()],
            roomNumber: roomNumber);
}

class ICURoom extends Rooms {
  ICURoom({List<Bed>? beds, required int roomNumber})
      : super(
            roomType: RoomType.ICU,
            beds: beds ?? List.generate(5, (_) => Bed()),
            roomNumber: roomNumber);
}

class ICUVipRoom extends Rooms {
  ICUVipRoom({List<Bed>? beds, required int roomNumber})
      : super(
            roomType: RoomType.ICUVIP,
            beds: beds ?? [Bed()],
            roomNumber: roomNumber);
}

class GeneralRoom extends Rooms {
  GeneralRoom({List<Bed>? beds, required int roomNumber})
      : super(
            roomType: RoomType.General,
            beds: beds ?? List.generate(10, (_) => Bed()),
            roomNumber: roomNumber);
}

class GeneralVIPRoom extends Rooms {
  GeneralVIPRoom({List<Bed>? beds, required int roomNumber})
      : super(
            roomType: RoomType.GeneralVIP,
            beds: beds ?? [Bed()],
            roomNumber: roomNumber);
}