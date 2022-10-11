import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/common/drop_down_translate.dart';
import 'package:snowball/src/controller/profile/profile_controller.dart';
import 'package:snowball/src/scenes/add/add_view.dart';
import 'package:snowball/src/scenes/chats/chat_list.dart';
import 'package:snowball/src/scenes/common/lates_cards.dart';
import 'package:snowball/src/scenes/common/options_profile.dart';
import 'package:snowball/src/scenes/detail/detail_list.dart';
import 'package:snowball/src/scenes/profile/profile_edit_view.dart';
import 'package:snowball/src/scenes/recomend/recomend_view.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var rollsname = "Rolls";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 242, 244),
        ),
        child: GetBuilder<ProfileController>(
            initState: (_) => ProfileController.to.getProfile(),
            dispose: (_) => ProfileController.to.crearData(),
            builder: (controller) => Obx(() => controller.loading.value
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await Get.to(() => ProfileEditView());
                            ProfileController.to.getProfile();
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                    width: 124,
                                    height: 120,
                                    margin: EdgeInsets.only(top: 15),
                                    child: InkWell(
                                      child: Hero(
                                        tag: "profile",
                                        child: ClipOval(
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/snowball_logo.png",
                                            image:
                                                controller.profile.user.image,
                                            height: 128,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              Positioned(
                                  left: 10,
                                  top: 10,
                                  child: DropDownTranslate()),
                              Positioned(
                                right: 0,
                                top: 10,
                                child: RaisedButton(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () =>
                                            controller.logoutSession(),
                                        icon: Icon(Icons.input),
                                        tooltip: 'Close session',
                                      ),
                                      Text('log_out'.tr)
                                    ],
                                  ),
                                  onPressed: () => controller.logoutSession(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 11),
                          child: Text(
                            controller.profile.user.name ?? "",
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 12, 22),
                              fontSize: 22,
                              fontFamily: "Lato",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Opacity(
                            opacity: 0.4,
                            child: Text(
                              controller.profile.user.correo,
                              style: TextStyle(
                                color: Color.fromARGB(255, 5, 12, 22),
                                fontSize: 15,
                                fontFamily: "Lato",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          width: Get.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await Get.to(() => ProfileEditView());
                                  ProfileController.to.getProfile();
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: AppConstants.darBlue,
                                    ),
                                    SizedBox(width: 5),
                                    Text('edit'.tr)
                                  ],
                                ),
                              ),
                              SizedBox(width: 30),
                              GestureDetector(
                                onTap: () => Get.to(ChatListView()),
                                child: Row(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: () =>
                                                Get.to(() => ChatListView()),
                                            icon: Icon(
                                              FontAwesomeIcons.envelope,
                                              color: AppConstants.darBlue,
                                            )),
                                        Positioned(
                                          right: 4,
                                          top: 6,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppConstants.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 14,
                                              minHeight: 14,
                                            ),
                                            child: Text(
                                              "${controller.profile.notificationNumber}",
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Text('messagelabel'.tr)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: InkWell(
                            onTap: () => controller.displayDialog(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.mapPin,
                                      color: AppConstants.darBlue,
                                    ),
                                    onPressed: () =>
                                        controller.displayDialog()),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppConstants.blue,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5))),
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 2,
                                          bottom: 2,
                                          left: 10,
                                          right: 10),
                                      child: Text('change_custom'.tr,
                                          style:
                                              TextStyle(color: Colors.white))),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppConstants.darBlue,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4, left: 2, right: 2),
                                    child: Icon(
                                      FontAwesomeIcons.chevronDown,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 251, 251, 251),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OptionProfile(
                                name: "Snowballs",
                                value: controller.snowballs.value.toString(),
                                onTap: () {
                                  Get.to(
                                      () => DetailListView(type: "snowball"));
                                },
                              ),
                              OptionProfile(
                                name: "Rolls",
                                value: controller.rolls.value.toString(),
                                onTap: () {
                                  Get.to(() => DetailListView(type: "rolls"));
                                },
                              ),
                              OptionProfile(
                                name: 'recommendation'.tr,
                                value: (controller.recommends.length +
                                        controller.recommendsAcepted.length)
                                    .toString(),
                                onTap: () {
                                  Get.offAll(() => RecomendView());
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 2, top: 20, right: 2, bottom: 0),
                          child: Column(
                            children: [
                              Center(
                                  child: Text(
                                'last_snowball'.tr,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withAlpha(90),
                                  fontSize: 12,
                                  letterSpacing: -0.074,
                                  fontFamily: "Lato",
                                ),
                              )),
                              SizedBox(height: 10),
                              LatesCard(
                                  latesList: controller.latesSnowballList,
                                  onTap: () => Get.to(AddView()),
                                  onPressed: (value) {
                                    controller.gotoDetail(value - 1, 1);
                                  },
                                  isAdd: true)
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 2, top: 20, right: 2, bottom: 0),
                          child: Column(
                            children: [
                              Center(
                                  child: Text(
                                'last_rolls'.tr,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withAlpha(90),
                                  fontSize: 12,
                                  letterSpacing: -0.074,
                                  fontFamily: "Lato",
                                ),
                              )),
                              SizedBox(height: 10),
                              LatesCard(
                                  latesList: controller.latesRollsList,
                                  onPressed: (value) {
                                    controller.gotoDetail(value, 2);
                                  },
                                  isAdd: false)
                            ],
                          ),
                        )
                      ],
                    ),
                  ))),
      ),
    );
  }
}
