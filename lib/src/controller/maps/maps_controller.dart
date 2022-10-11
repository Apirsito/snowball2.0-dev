import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/location/user_location.dart';
import 'package:snowball/src/models/maps/location_point_model.dart';

class MapsController extends GetxController {
  // final _db = FirebaseFirestore.instance.collection("snowball");

  Rx<CameraPosition> initialPosition =
      CameraPosition(target: LatLng(28.481151, -81.4388778), zoom: 12).obs;

  RxSet<Marker> markers = RxSet<Marker>();
  RxSet<Marker> pointMarker = RxSet<Marker>();
  List<Position> positions = <Position>[];
  List<UserLocations> locations = <UserLocations>[];
  final Geolocator geolocator = Geolocator();
  Stream<List<DocumentSnapshot>> stream;

  RxList<AutocompletePrediction> predictions = RxList<AutocompletePrediction>();
  TextEditingController searchCTR = TextEditingController();

  List<ClusterItem> items = [];
  ClusterManager manager;
  GooglePlace googlePlace;

  final geo = Geoflutterfire();
  final box = GetStorage();

  var addres = "".obs;
  final searchString = "".obs;
  GoogleMapController mapController;
  LocationPointModel userPoint = new LocationPointModel();

  @override
  void onReady() {
    googlePlace = GooglePlace(AppConstants.kGoogleApiKey);
    debounce(searchString, getPrediccions, time: Duration(seconds: 1));
  }

  @override
  void onInit() {
    _getCurrentLocation();
    super.onInit();
  }

  void _getCurrentLocation() async {
    await Geolocator.requestPermission();
  }

  @override
  void onClose() {
    markers.clear();
    searchString.value = "";
    addres.value = "";
    userPoint = new LocationPointModel();
    items.clear();
    positions.clear();
    super.onClose();
  }

  void onMapCreatedFunc(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Marker> Function(Cluster) get _markerBuilder => (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print('---- $cluster');
            cluster.items.forEach((p) => print(p));
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  void _updateMarkers(Set<Marker> markers) {
    this.markers.clear();
    this.markers.addAll(markers);
  }

  autoCompleteLocation(String value) {
    if (value != "") {
      searchString.value = value;
    } else {
      predictions.clear();
      refresh();
    }
  }

  getPrediccions(String value) async {
    if (value == "") {
      predictions.clear();
    } else {
      await googlePlace.autocomplete.get(value).then((response) {
        predictions.clear();
        printFirstElement(response.predictions.first);
        predictions.addAll(response.predictions);
      }).catchError((eror) {
        printError(info: eror);
      });
    }
  }

  void getDetailPlace(String placeId) async {
    var detail = await googlePlace.details.get(placeId);
    if (detail != null) {
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      if (detail.result.addressComponents.length > 3) {
        var locality = detail.result.addressComponents.firstWhere(
            (element) => element.types.contains("locality"),
            orElse: () => null);
        var country = detail.result.addressComponents.firstWhere(
            (element) => element.types.contains("country"),
            orElse: () => null);
        userPoint.ciudad =
            locality != null ? locality.longName : detail.result.name;
        userPoint.pais = country.longName ?? detail.result.formattedAddress;
      } else {
        userPoint.ciudad = detail.result.name;
        userPoint.pais = detail.result.formattedAddress;
      }
      addres(detail.result.formattedAddress);
      userPoint.id = placeId;
      userPoint.point = geo.point(latitude: lat, longitude: lng);
      userPoint.address = detail.result.formattedAddress;
      searchCTR.text = detail.result.formattedAddress;
      autoCompleteLocation(detail.result.formattedAddress);
    }
  }

  void printFirstElement(AutocompletePrediction first) async {
    var detail = await googlePlace.details.get(first.placeId);
    if (detail != null) {
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      initialPosition.value =
          CameraPosition(target: LatLng(lat, lng), zoom: 17);
      updateCamera();
    }
  }

  Future<void> updateCamera() async {
    if (mapController != null) {
      await mapController
          .animateCamera(CameraUpdate.newCameraPosition(initialPosition.value));
      onMapCreatedFunc(mapController);
      refresh();
    }
  }

  returnSelection() {
    markers.clear();
    searchString.value = "";
    addres.value = "";
    items.clear();
    positions.clear();
    searchCTR.text = "";
    Get.back(result: userPoint);
    userPoint = new LocationPointModel();
  }
}
