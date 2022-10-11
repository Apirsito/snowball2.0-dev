import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/controller/user/user_controller.dart';
import 'package:snowball/src/scenes/common/lates_cards.dart';
import 'package:snowball/src/scenes/common/options_profile.dart';
import 'package:snowball/src/scenes/detail/detail_list.dart';

// ignore: must_be_immutable
class UserView extends StatefulWidget {
  String id;
  UserView({this.id});

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(0, 146, 209, 1),
        title: Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: GetBuilder<UserController>(
          initState: (_) => UserController.to.getDataUser(widget.id),
          dispose: (_) => UserController.to.crearData(),
          builder: (controller) => Obx(() => controller.loading.value
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/snowball_logo.png",
                            image: controller.userData.user.image,
                            height: 128,
                            width: 128,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 11, bottom: 10),
                        child: Text(
                          controller.userData.user.name ?? "",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontFamily: "Lato",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    controller.userData.userBlock
                        ? SizedBox(height: 50)
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      MaterialButton(
                                        color: Colors.white,
                                        elevation: 0,
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: (){},
                                              icon: Icon(Icons.email),
                                              tooltip: 'send_mesage'.tr,
                                            ),
                                            Text('send_mesage'.tr)
                                          ],
                                        ),
                                        onPressed: () => controller.senToMessageChat(widget.id),
                                      ),
                                      MaterialButton(
                                        color: Colors.white,
                                        elevation: 0,
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: (){},
                                              icon: Icon(Icons.warning),
                                              tooltip: 'Block',
                                            ),
                                            Text('report'.tr)
                                          ],
                                        ),
                                        onPressed: () => controller
                                            .openDenuncias(widget.id, context),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 60,
                                width: Get.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OptionProfile(
                                      name: "Snowballs",
                                      value: controller
                                          .userData.snowballs.length
                                          .toString(),
                                      onTap: () {
                                        Get.to( () => DetailListView(
                                            type: "snowball",
                                            idUser: widget.id));
                                      },
                                    ),
                                    OptionProfile(
                                      name: "Rolls",
                                      value:
                                          controller.userData.rolls.toString(),
                                      onTap: () {
                                        Get.to( () => DetailListView(
                                          type: "rolls",
                                          idUser: widget.id,
                                        ));
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
                                        onTap: () => print("object"),
                                        onPressed: (value) {
                                          controller.gotoDetail(value, 1);
                                        },
                                        isAdd: false)
                                  ],
                                ),
                              ),
                            ],
                          ),
                    controller.userData.userBlock
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width - 100,
                                child: Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'message_user_block'.tr,
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        : SizedBox(),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        child: MaterialButton(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.block),
                                tooltip: 'Block',
                              ),
                              Text(controller.userData.userBlock ? 'unlock_user'.tr : 'block_user'.tr),
                            ],
                          ),
                          onPressed: () => controller.userData.userBlock
                              ? controller.unBlockUser()
                              : controller.blockthisUser(),
                        ),
                      ),
                    )
                  ],
                )),
        ),
      ),
    );
  }
}
