import 'package:geolocator/geolocator.dart';

class UserLocations {
  String id;
  String name;
  double latitude;
  double longitude;
  Position position;
  UserLocations(
      this.id, this.name, this.latitude, this.longitude, this.position);
}
