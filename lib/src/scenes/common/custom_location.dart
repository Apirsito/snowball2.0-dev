import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/maps/maps_controller.dart';

class CustomLocation extends StatefulWidget {
  @override
  _CustomLocationState createState() => _CustomLocationState();
}

class _CustomLocationState extends State<CustomLocation> {
  MapsController controller = Get.put(MapsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text("Snowball"),
      ),
      body: Container(
        child: Stack(
          children: [
            ListView(
              primary: true,
              children: [
                Container(
                  height: 200,
                  child: Obx(
                    () => GoogleMap(
                      markers: controller.pointMarker,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: controller.onMapCreatedFunc,
                      initialCameraPosition: controller.initialPosition.value,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: Get.height,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 10, right: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                  maxLines: 1,
                                  autofocus: true,
                                  controller: controller.searchCTR,
                                  decoration: InputDecoration(
                                      labelText: "search_address".tr + " *",
                                      contentPadding: EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          right: 0,
                                          bottom: 10),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black26, width: 0.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black26, width: 0.0),
                                      )),
                                  onChanged: (value) {
                                    controller.addres.value = "";
                                    controller.autoCompleteLocation(value);
                                  },
                                  onSubmitted: (value) {
                                    controller.addres.value = "";
                                    FocusScope.of(context).unfocus();
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Obx(
                            () => ListView.builder(
                              primary: false,
                              itemCount: controller.predictions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.pin_drop_outlined,
                                    color: Colors.grey,
                                  ),
                                  title: Text(controller
                                      .predictions[index].description),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    controller.getDetailPlace(
                                        controller.predictions[index].placeId);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Obx(() => controller.addres.value != ""
                ? Positioned(
                    bottom: 10,
                    left: 20,
                    right: 20,
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: AppConstants.blue,
                        onPressed: () => controller.returnSelection(),
                        child: Text("select".tr,
                            style: TextStyle(color: Colors.white))))
                : SizedBox())
          ],
        ),
      ),
    );
  }
}
