import 'package:geoflutterfire/geoflutterfire.dart';

class LocationPointModel {
  String id;
  String ciudad;
  String pais;
  String address;
  GeoFirePoint point;
  LocationPointModel({this.ciudad, this.pais, this.address, this.point});
}
