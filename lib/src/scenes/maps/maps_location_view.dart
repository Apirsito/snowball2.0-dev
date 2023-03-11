import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowball/src/controller/maps/maps_controller.dart';
import 'package:snowball/src/models/location/user_location.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:snowball/src/scenes/profile/profile_add_location.dart';

class MapsLocationView extends StatefulWidget {
  @override
  _MapsLocationViewState createState() => _MapsLocationViewState();
}

class _MapsLocationViewState extends State<MapsLocationView> {
  var locale = false;
  final geo = Geoflutterfire();
  final _db = FirebaseFirestore.instance.collection("snowball");
  MapsController controller = Get.put(MapsController());
  CameraPosition initialPosition = CameraPosition(target: LatLng(28.481151, -81.4388778), zoom: 12);
  Set<Marker> markers = Set<Marker>();
  List<ClusterItem<Marker>> items = [];
  GoogleMapController mapController;
  ClusterManager _manager;
  bool firstLoad = false;
  String dropdownValue;
  List<String> listLocations = <String>[];
  List<Position> userPositions = <Position>[];
  List<UserLocations> userLocations = <UserLocations>[];

  @override
  void initState() {
    _manager = initClusterManager();
    _getListaPosition();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await getLocation();
  }

  Future<void> getLocation() async {
    print("55 Ubicación usuario");
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always ||
          permission != LocationPermission.whileInUse) {
        Geolocator.requestPermission().whenComplete(() {
          getDataPositions();
        });
      } else {
        getDataPositions();
      }
    } catch (e) {
      printError(info: e);
    }
  }

  _getListaPosition() async {
    User user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .collection("locations")
        .limit(3)
        .get()
        .then((val) {
      setState(() {
        val.docs.forEach((val) {
          listLocations.add(val.data()["name"]);
          userLocations.add(
            UserLocations(val.id, val["name"], val["lat"], val["lon"], null)
          );
          Position pos = Position(
            latitude: val.data()["lat"],
            longitude: val.data()["lon"]
          );
          userPositions.add(pos);
        });
        listLocations.add('add_favorite'.tr);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: Geolocator.requestPermission(),
            builder: (context, permisos) {
              if (!permisos.hasData) {
                return Center(child: SizedBox());
              }
              if (permisos.data == LocationPermission.denied) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Request location permission",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Access to the device\'s location has been denied, please request permissions before continuing",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        MaterialButton(
                            child: const Text('Request permission'),
                            onPressed: () => Geolocator.openLocationSettings()
                                    .then((status) {
                                  setState(() {
                                    Geolocator.requestPermission();
                                    controller.positions.clear();
                                  });
                                })),
                      ],
                    ),
                  ),
                );
              }
              return GoogleMap(
                onCameraMove: _manager.onCameraMove,
                onCameraIdle: _manager.updateMap,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: onMapCreatedFunc,
                initialCameraPosition: initialPosition,
                zoomControlsEnabled: false,
              );
            },
          ),
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                child: Container(
                  child: Center(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      hint: Text('favorite_place'.tr),
                      value: dropdownValue,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (String newValue) {
                        if (newValue == 'add_favorite'.tr) {
                          _handlePressButton();
                        } else {
                          dropdownValue = newValue;
                          _changePosition(dropdownValue);
                        }
                      },
                      items: listLocations
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.my_location_outlined,
          color: Colors.black,
        ),
        onPressed: () async {
          dropdownValue = null;
          await getLocation();
          await updateCamera();
        },
      ),
    );
  }

  void getGeoposiotions() {
    GeoFirePoint center = geo.point(
      latitude: initialPosition.target.latitude,
      longitude: initialPosition.target.longitude
    );
    var collectionReference = _db;

    geo.collection(collectionRef: collectionReference)
    .within(center: center, radius: 1000, field: "position")
    .listen((list) {
      setState(() {
        updateMarkers(list);
      });
    });
  }

  ClusterManager<Marker> initClusterManager() {
    return ClusterManager<Marker>(
      items, _updateMarkers,
      markerBuilder: _markerBuilder,
      initialZoom: initialPosition.zoom,
      stopClusteringZoom: 13
    );
  }

  updateMarkers(List<DocumentSnapshot> documentList) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/snowball_logo.png', 70);
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document['position']['geopoint'];
      MarkerId id = MarkerId(document.id);
      Marker _marker = Marker(
        markerId: id,
        position: LatLng(point.latitude, point.longitude),
        onTap: () {
          senToDetails(document);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: document["nombre"],
          snippet: document["ciudad"],
          onTap: () {
            senToDetails(document);
          }
        ),
      );
      items.add(
        ClusterItem(
          LatLng(point.latitude, point.longitude),
          item: _marker
        )
      );
    });
    setState(() {
      _manager = initClusterManager();
      updateCamera();
    });
  }

  void _handlePressButton() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileAddLocation())
    );

    listLocations.clear();
    _getListaPosition();
  }

  Future<Marker> Function(Cluster<Marker>) get _markerBuilder => (cluster) async {
    final String icono = cluster.isMultiple ? 'assets/snowball_multiple.png' : 'assets/snowball_logo.png';
    final Uint8List markerIcon = await getBytesFromAsset(icono, 70);

    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      infoWindow: cluster.items.first.infoWindow,
      onTap: () async {
        if (cluster.isMultiple) {
          mapController.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: cluster.location, zoom: 14)
            )
          );
          setState(() {});
        } else {
          getSnowballSimilar(
            cluster.items.first.markerId.value,
            cluster.location
          );
        }
      },
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
  };

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void getDataPositions() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) {
      setState(() {
        initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12
        );
      });
      getGeoposiotions();
      updateCamera();
    }).catchError((e) {
      print(e);
    });

    Geolocator.getLastKnownPosition(forceAndroidLocationManager: true).then(
      (Position position) {
        setState(() {
          initialPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12
          );
        });
        getGeoposiotions();
        updateCamera();
      }
    );
  }

  Future<void> updateCamera() async {
    if (mapController != null) {
      await mapController.animateCamera(CameraUpdate.newCameraPosition(initialPosition));
      setState(() {
        onMapCreatedFunc(mapController);
      });
    }
  }

  void onMapCreatedFunc(GoogleMapController controller) async {
    mapController = controller;
    _manager.setMapController(controller);
    if (firstLoad == false) {
      await getLocation();
      await updateCamera();
      firstLoad = true;
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    this.markers.clear();
    setState(() {
      this.markers.addAll(markers);
    });
  }

  _changePosition(String pos) {
    UserLocations find = userLocations.where((item) => pos.contains(item.name)).first;
    setState(() {
      initialPosition = CameraPosition(
        target: LatLng(find.latitude, find.longitude),
        zoom: 12
      );
      updateCamera();
      getGeoposiotions();
    });
  }

  senToDetails(DocumentSnapshot document) {
    Get.to(() => DetailSnowballView(document.id));
  }

  getSnowballSimilar(String id, LatLng location) {
    GeoFirePoint center = geo.point(latitude: location.latitude, longitude: location.longitude);
    var collectionReference = _db;
    geo.collection(collectionRef: collectionReference)
    .within(center: center, radius: 1, field: "position")
    .listen((list) {
      List<Snowball> snowLista = list.map((e) => Snowball.fromSnapshot(e)).toList();
      var similarSnowballsList = [];
      try {
        final curent = snowLista.where((element) => element.id == id).first;
        similarSnowballsList = snowLista.where((element) =>
          element.position.latitude == curent.position.latitude &&
          element.position.longitude == curent.position.longitude
        ).toList();
      } catch (e) {
        print(e);
      }

      if (similarSnowballsList.length > 1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              title: Text('Snowballs'),
              content: Container(
                height: Get.height * 0.6,
                width: 400.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: similarSnowballsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final snowball = similarSnowballsList[index];
                    return ListTile(
                      title: Text(snowball.nombre),
                      onTap: () {
                        Get.back();
                        Get.to(() => DetailSnowballView(snowball.id));
                      },
                    );
                  },
                ),
              ),
            );
          }
        );
      }
    });
  }
}
