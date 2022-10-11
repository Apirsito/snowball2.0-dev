import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/add/add_controller.dart';
import 'package:snowball/src/scenes/common/custom_video.dart';

class AddView extends StatefulWidget {
  final String id;
  AddView({this.id});

  @override
  _AddViewState createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  AddController controller = Get.put(AddController());
  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

  @override
  void initState() {
    if (widget.id != null) {
      controller.getDetail(widget.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('popop_exit'.tr),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Ok")),
                  FlatButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('cancel'.tr)),
                ],
              )),
      child: Obx(
        () => controller.loading.value
            ? Scaffold(
                body: Container(
                    color: AppConstants.blue,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            backgroundColor: Colors.white),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("load_message".tr,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              "${controller.currentResource.value} " "of".tr +
                                  " ${controller.resourcesForUpload.value}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ))),
              )
            : Scaffold(
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
                body: ListView(
                  children: [
                    Container(
                      child: Card(
                        child: Stack(
                          children: [
                            Container(
                              height: 280,
                              child: Obx(() => controller.resources.length < 1
                                  ? Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 20),
                                            child: Center(
                                                child: Text("select".tr)),
                                          ),
                                          Image.asset(
                                              "assets/placeholder_image.png",
                                              height: 150)
                                        ],
                                      ),
                                    )
                                  : PageView.builder(
                                      controller: controller.pageController,
                                      itemCount: controller.total,
                                      onPageChanged: (value) =>
                                          controller.page.value = value,
                                      itemBuilder: (context, position) {
                                        var item =
                                            controller.resources[position];
                                        if (item.asset != null) {
                                          return AssetThumb(
                                              asset: item.asset,
                                              height: 300,
                                              width: 400);
                                        } else if (item.files != null) {
                                          return CustomVideo(
                                              fileVideo: item.files,
                                              isUpload: true);
                                        } else if (item.image != null) {
                                          return FadeInImage.assetNetwork(
                                              placeholder:
                                                  "assets/snowball_logo.png",
                                              image: item.image);
                                        } else if (item.video != null) {
                                          return CustomVideo(
                                              urlVideo: item.video);
                                        } else {
                                          return Card(
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 20),
                                                    child: Center(
                                                        child:
                                                            Text("select".tr)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      })),
                            ),
                            Obx(
                              () {
                                var total = controller.resources.length;
                                return total > 1
                                    ? Positioned(
                                        bottom: 5,
                                        right: 10,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: total >=
                                                        controller.page.value +
                                                            1
                                                    ? 18.0
                                                    : 0),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  total >=
                                                          controller
                                                                  .page.value +
                                                              1
                                                      ? "${controller.page.value + 1}/$total"
                                                      : "",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                controller
                                                        .resources[controller
                                                            .page.value]
                                                        .isDelete
                                                    ? IconButton(
                                                        icon: Stack(
                                                          children: <Widget>[
                                                            Icon(
                                                                FontAwesomeIcons
                                                                    .trash,
                                                                size: 18,
                                                                color: Colors
                                                                    .white),
                                                          ],
                                                        ),
                                                        onPressed: () =>
                                                            controller
                                                                .deleteImagenes(),
                                                      )
                                                    : SizedBox(
                                                        height: 30, width: 18)
                                              ],
                                            ),
                                          ),
                                        ))
                                    : SizedBox();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton.icon(
                          onPressed: () => controller.loadImages(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: Color.fromRGBO(182, 215, 235, 1),
                                width: 2),
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'add'.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          icon:
                              Icon(FontAwesomeIcons.plus, color: Colors.white),
                          color: AppConstants.blue,
                          elevation: 1,
                        ),
                        SizedBox(width: 5),
                        RaisedButton.icon(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              side: BorderSide(
                                  color: Color.fromRGBO(182, 215, 235, 1),
                                  width: 2)),
                          label: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'addVideos'.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          icon: Icon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                          ),
                          color: AppConstants.blue,
                          elevation: 1,
                          onPressed: () => controller.loadVideos(),
                        ),
                      ],
                    ),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: TextField(
                          controller: controller.teName,
                          decoration: InputDecoration(
                              labelText: "name".tr + " *",
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              contentPadding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black26, width: 0.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black26, width: 0.0))),
                        )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: TextField(
                          maxLines: null,
                          controller: controller.teDescription,
                          decoration: InputDecoration(
                              labelText: "description".tr + " *",
                              contentPadding: EdgeInsets.only(
                                  top: 10, left: 10, right: 0, bottom: 10),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black26, width: 0.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black26, width: 0.0),
                              ))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 10),
                      child: Text("location".tr),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        readOnly: true,
                        controller: controller.teLocation,
                        decoration: InputDecoration(
                            labelText: 'search_address'.tr,
                            contentPadding: EdgeInsets.only(
                                top: 10, left: 10, right: 0, bottom: 10),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            )),
                        onTap: () {
                          if (controller.isEditable.isFalse) {
                            controller.senToCustomLocation();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: new LinearGradient(
                              colors: [
                                Colors.black12,
                                Colors.black12,
                              ],
                              begin: const FractionalOffset(0.0, 0.0),
                              end: const FractionalOffset(1.0, 1.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp),
                        ),
                        height: 1.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                      ),
                      child: Obx(
                        () => Tags(
                          key: _tagStateKey,
                          textField: TagsTextField(
                            autofocus: false,
                            width: Get.width - 40,
                            hintText: 'press_tag'.tr,
                            inputDecoration: InputDecoration(
                                labelText: "Tags",
                                contentPadding: EdgeInsets.only(
                                    top: 15, left: 10, right: 0, bottom: 10),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black26, width: 0.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black26, width: 0.0),
                                )),
                            textStyle:
                                TextStyle(fontSize: 14, color: Colors.black),
                            onSubmitted: (value) =>
                                controller.itemTags.add(value),
                          ),
                          itemCount: controller.itemTags.length, // required
                          itemBuilder: (index) {
                            return ItemTags(
                              index: index,
                              title: controller.itemTags[index],
                              elevation: 0,
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 3, left: 9, right: 3),
                              pressEnabled: false,
                              activeColor: AppConstants.blue,
                              removeButton: ItemTagsRemoveButton(
                                onRemoved: () => controller.removeTags(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () {
                          !controller.loading.value
                              ? controller.snow.id == null
                                  ? controller.createSnowball()
                                  : controller.updateSnowball()
                              : print("");
                        },
                        elevation: 0,
                        padding: EdgeInsets.all(15),
                        color: Color.fromRGBO(0, 146, 209, 1),
                        child: Text('save'.tr,
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                    widget.id != null
                        ? Padding(
                            padding: EdgeInsets.only(
                                bottom: 20, right: 20, left: 20),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              onPressed: () {
                                controller.deleteSnowball();
                              },
                              elevation: 0,
                              padding: EdgeInsets.all(15),
                              color: Colors.transparent,
                              child: Text('delete'.tr,
                                  style: TextStyle(color: AppConstants.blue)),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
      ),
    );
  }
}
