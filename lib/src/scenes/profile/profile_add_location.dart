import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/common/alerts.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/maps/location_point_model.dart';
import 'package:snowball/src/scenes/common/custom_location.dart';

const kGoogleApiKey = "AIzaSyCf05OPdarzUz2N3a7uSxK5_9Xgkyd8HEI";

class ProfileAddLocation extends StatefulWidget {
  @override
  _ProfileAddLocationState createState() => _ProfileAddLocationState();
}

class _ProfileAddLocationState extends State<ProfileAddLocation> {
  CollectionReference _db = FirebaseFirestore.instance.collection("usuarios");
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GooglePlace googlePlace;
  final box = GetStorage();
  int counPlaces = 0;
  var isActive = "";
  var uuid = "";
  var count = 0;

  Future<void> _activeLocation(String id, String name) async {
    uuid = box.read('uuid');
    _db.doc(uuid).collection("locations").doc(id).update({
      "update": DateTime.now(),
    }).then((val) {
      Navigator.pop(context, name);
    });
  }

  void _deleteLocation(String id) {
    uuid = box.read('uuid');
    showLoader();
    _db.doc(uuid).collection("locations").doc(id).delete().then((val) {
      setState(() {});
      hideLoader();
    });
  }

  void addLocations(LocationPointModel location) {
    uuid = box.read('uuid');
    _db.doc(uuid).collection("locations").add({
      "id": location.id,
      "name": location.address,
      "lat": location.point.latitude,
      "lon": location.point.longitude,
      "active": false,
      "update": DateTime.now()
    }).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                AppConstants.darBlue,
                Color.fromRGBO(82, 173, 187, 1)
              ])),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'add_location'.tr,
            onPressed: () async {
              if (count < 3) {
                LocationPointModel result = await Get.to(() => CustomLocation());
                if (result != null) {
                  addLocations(result);
                }
              } else {
                AlertsMessage.showSnackbar("cand_tree_location".tr);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'favorite_place'.tr,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              subtitle: Text('cand_tree_location'.tr),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(box.read("uuid"))
                  .collection("locations")
                  .limit(3)
                  .orderBy("update", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                count = snapshot.data.docs.length;
                return ListView(
                  children: snapshot.data.docs.map((document) {
                    counPlaces = snapshot.data.docs.length;
                    return ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(document['name']),
                      ),
                      trailing: InkWell(
                          onTap: () => _deleteLocation(document.id),
                          child: Icon(Icons.delete)),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
