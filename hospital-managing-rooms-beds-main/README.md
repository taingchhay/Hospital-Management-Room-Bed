# hospital-managing-rooms-beds
This project focuses on a console-based Hospital Management System for rooms, beds, and patients.

## Default configuration

Rooms are preconfigured per type with the following counts:

- Emergency: 5 rooms (1 bed each)
- ICU: 15 rooms (5 beds each)
- ICUVIP: 10 rooms (1 bed each)
- General: 15 rooms (10 beds each)
- GeneralVIP: 10 rooms (1 bed each)

Availability output aggregates per room type and shows the number of rooms, available beds, occupied beds, and total beds.

## Run

From the project root:

```
dart lib/domain/main.dart
```

Use the on-screen menu to admit patients, update codes, view availability, and search by name.
