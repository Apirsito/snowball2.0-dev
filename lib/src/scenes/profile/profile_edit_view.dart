import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/profile/profile_controller.dart';

// ignore: must_be_immutable
class ProfileEditView extends StatelessWidget {
  final controller = Get.put(ProfileController());

  Future<bool> _onWillPop() async {
    controller.changePass.value = false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
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
          title: Text(
            'edit_profile'.tr,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 20),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    margin: EdgeInsets.only(top: 15),
                    child: Stack(
                      children: <Widget>[
                        Obx(
                          () => Hero(
                            tag: "profile",
                            child: ClipOval(
                                child: controller.imageLoad.value == null
                                    ? FadeInImage.assetNetwork(
                                        placeholder: "assets/snowball_logo.png",
                                        image: controller.profile.user.image,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      )
                                    : AssetThumb(
                                        asset: controller.imageLoad.value,
                                        height: 220,
                                        width: 220)),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightBlueAccent,
                              ),
                              child: IconButton(
                                  icon: Icon(FontAwesomeIcons.image,
                                      color: Colors.white),
                                  onPressed: () =>
                                      controller.changeProfileImage()),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              InputProfileEdit(
                  controller: controller.teUsername, name: 'nick_name'.tr),
              InputProfileEdit(
                  controller: controller.teCorreo, name: 'email'.tr),
              Obx(
                () => controller.changePass.value
                    ? Column(
                        children: [
                          InputProfileEdit(
                              controller: controller.tePasss, name: 'pass'.tr),
                          InputProfileEdit(
                              controller: controller.teRepeatPass,
                              name: 'repeat_password'.tr)
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: Colors.blueAccent)),
                          onPressed: () => controller.changePass.value = true,
                          elevation: 0,
                          padding: EdgeInsets.all(15),
                          color: Colors.white,
                          child: Text('change_pass'.tr.toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        ),
                      ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Container(
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () => controller.validateDataToSave(),
                    elevation: 0,
                    padding: EdgeInsets.all(15),
                    color: Colors.teal,
                    child: Text('updatelabel'.tr,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputProfileEdit extends StatelessWidget {
  const InputProfileEdit({
    Key key,
    @required this.controller,
    @required this.name,
  }) : super(key: key);

  final TextEditingController controller;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
          controller: controller,
          decoration: InputDecoration(
              labelText: name,
              contentPadding:
                  EdgeInsets.only(top: 20, left: 10, right: 0, bottom: 10),
              labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black26, width: 0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black26, width: 0.0),
              ))),
    );
  }
}
