import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:get/get.dart';
import 'package:snowball/src/controller/detail/detail_snowball_controller.dart';
import 'package:snowball/src/scenes/common/comentarios.dart';
import 'package:snowball/src/scenes/common/custom_video.dart';
import 'package:snowball/src/scenes/common/image_zoom.dart';
import 'package:snowball/src/scenes/common/modals.dart';
import 'package:snowball/src/scenes/common/toolbar_view.dart';
import 'package:snowball/src/scenes/detail/detail_all_tag.dart';
import 'package:snowball/src/scenes/user/user_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailSnowballView extends StatefulWidget {
  final String id;
  DetailSnowballView(this.id);

  @override
  _DetailSnowballViewState createState() => _DetailSnowballViewState();
}

class _DetailSnowballViewState extends State<DetailSnowballView> {
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
                AppConstants.blue,
                Color.fromRGBO(82, 173, 187, 1)
              ])),
        ),
        title: Text(
          'detail'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: GetBuilder<DetailSnowballController>(
          initState: (state) =>
              DetailSnowballController.to.getDetail(widget.id),
          dispose: (state) => DetailSnowballController.to.clearData(),
          builder: (controller) => Obx(
            () => controller.loading.value
                ? Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      ListView(
                        children: [
                          Container(
                            height: 400,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  itemCount: controller.resources.length,
                                  itemBuilder: (context, index) {
                                    final item = controller.resources[index];
                                    if (item.image != null) {
                                      return InkWell(
                                        onTap: () => Get.to(ImageZoomView(
                                            controller.resources)),
                                        child: Center(
                                          child: CachedNetworkImage(
                                            imageUrl: item.image,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                              value: downloadProgress.progress,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      );
                                    } else if (item.video != null) {
                                      return CustomVideo(urlVideo: item.video);
                                    } else {
                                      return Image.asset(
                                        "assets/snowball_logo.png",
                                        width: 300,
                                      );
                                    }
                                  },
                                  onPageChanged: (value) =>
                                      controller.changePage(value),
                                ),
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List<Widget>.generate(
                                            controller.resources.length,
                                            (index) {
                                          return Container(
                                            width: 15,
                                            child: Center(
                                                child: Material(
                                              color:
                                                  controller.page.value == index
                                                      ? Colors.grey
                                                      : Colors.black54,
                                              type: MaterialType.circle,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                child: InkWell(
                                                  onTap: () => print("Next"),
                                                ),
                                              ),
                                            )),
                                          );
                                        }))),
                                Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: controller.resources.length > 1
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "${controller.page.value + 1}/${controller.resources.length}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox()),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                    child: ListTile(
                                  leading: InkWell(
                                      onTap: () => Get.to(UserView(
                                          id: controller.autor.value.id)),
                                      child: ClipOval(
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/snowball_logo.png",
                                          image: controller.autor.value.image,
                                          height: 55,
                                          width: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                  title: Text(
                                    controller.autor.value.name == null
                                        ? "Anonimo"
                                        : controller.autor.value.name,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: controller.mySnowball.value
                                      ? IconButton(
                                          onPressed: () async {
                                            await controller.gotoEdit();
                                          },
                                          icon: Icon(Icons.edit),
                                        )
                                      : IconButton(
                                          onPressed: () =>
                                              ModalsView.showSnowballOptions(
                                                  controller,
                                                  controller
                                                      .snowball.value.autor,
                                                  context),
                                          icon: Icon(Icons.more_horiz),
                                        ),
                                )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              height: 1,
                              width: Get.width,
                              color: Colors.black26,
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 2, bottom: 10, left: 20),
                                    child: Text(
                                      controller.snowball.value.nombre,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //PROBLEMA SE ESTABA OCASIONANDO POR LOS MAPAS
                          //DESCOMENTAR ANTES DE SALIR APRODUCCION

                          controller.snowball.value.position.latitude != null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: GoogleMap(
                                      mapType: MapType.normal,
                                      myLocationEnabled: false,
                                      scrollGesturesEnabled: false,
                                      zoomControlsEnabled: false,
                                      zoomGesturesEnabled: false,
                                      myLocationButtonEnabled: false,
                                      initialCameraPosition: CameraPosition(
                                          zoom: 17,
                                          target: LatLng(
                                              controller.snowball.value.position
                                                  .latitude,
                                              controller.snowball.value.position
                                                  .longitude)),
                                      markers: Set<Marker>.of([
                                        Marker(
                                            icon: BitmapDescriptor.fromBytes(
                                                controller.markerIcon),
                                            markerId: MarkerId(
                                                controller.snowball.value.id),
                                            position: LatLng(
                                                controller.snowball.value
                                                    .position.latitude,
                                                controller.snowball.value
                                                    .position.longitude))
                                      ]),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          Row(
                            children: [
                              Flexible(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 20, right: 20, bottom: 10),
                                child: Container(
                                  height: 17,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller
                                          .snowball.value.etiquetas.length,
                                      itemBuilder: (contex, index) {
                                        return InkWell(
                                          onTap: () => Get.to(DetailAllTags(
                                              controller.snowball.value
                                                  .etiquetas[index])),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 3.0),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppConstants.blue
                                                    .withAlpha(180),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 14,
                                                minHeight: 14,
                                              ),
                                              child: new Text(
                                                "${controller.snowball.value.etiquetas[index]}",
                                                style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 2, bottom: 10, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      controller.snowball.value.ciudad,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      controller.snowball.value.pais,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                              color: Colors.white,
                              child: ToolsSnowBalls(
                                  id: controller.snowball.value.id)),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: ComentariosView(
                                  controller.snowball.value.id,
                                  controller.snowball.value.autor)),
                          SizedBox(height: 50),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        // child: SafeArea(
                        // bottom: true,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Row(
                            children: <Widget>[
                              Material(
                                child: new Container(
                                  margin:
                                      new EdgeInsets.symmetric(horizontal: 1.0),
                                  child: new IconButton(
                                    onPressed: () => print("object"),
                                    icon: new Icon(Icons.face),
                                    color: Colors.grey,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              Flexible(
                                child: Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  height: 50,
                                  child: TextField(
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 15.0),
                                    controller: controller.comments,
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'your_comments'.tr,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    onSubmitted: (value) =>
                                        controller.sendOtherComment(),
                                    focusNode: controller.focusNode,
                                  ),
                                ),
                              ),
                              Material(
                                child: new Container(
                                  margin:
                                      new EdgeInsets.symmetric(horizontal: 8.0),
                                  child: new IconButton(
                                    icon: new Icon(Icons.send),
                                    onPressed: () =>
                                        controller.sendOtherComment(),
                                    color: AppConstants.darBlue,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        // ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
