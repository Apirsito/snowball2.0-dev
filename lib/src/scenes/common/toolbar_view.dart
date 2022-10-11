import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/controller/recomend/recommended_controller.dart';
import 'package:snowball/src/scenes/common/recommended.dart';
import 'package:snowball/src/controller/home/toolbar_controller.dart';

// ignore: must_be_immutable
class ToolsSnowBalls extends StatefulWidget {
  String id;
  void Function() onPressedMsj;

  ToolsSnowBalls({
    this.id,
    this.onPressedMsj,
  });

  @override
  _ToolsSnowballsState createState() => _ToolsSnowballsState(this.id);
}

class _ToolsSnowballsState extends State<ToolsSnowBalls>
    with SingleTickerProviderStateMixin {
  String id;
  _ToolsSnowballsState(this.id);
  AnimationController animatecontroller;
  final controller = Get.put(ToolBarController());

  @override
  void initState() {
    animatecontroller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    super.initState();
  }

  @override
  void dispose() {
    animatecontroller.dispose();
    super.dispose();
  }

  void showRecomendedBy(String id, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF737373),
      builder: (context) => GestureDetector(
        onTap: () {
          if (RecommendedController.to.focusNode.hasFocus) {
            RecommendedController.to.focusNode.unfocus();
            FocusScope.of(context).unfocus();
          }
        },
        child: RecommendedView(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                controller.addRolls(id);
                animatecontroller.forward();
              });
            },
            child: StreamBuilder<QuerySnapshot>(
                stream: controller.rolls
                    .where("snowball", isEqualTo: id)
                    .snapshots(),
                builder: (context, snapshot) {
                  return Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            controller.addRolls(id);
                            animatecontroller.forward();
                          });
                        },
                        icon: AnimatedBuilder(
                          animation: animatecontroller,
                          builder: (context, builder) {
                            return RotationTransition(
                              turns: animatecontroller,
                              child: controller.isCurrentSnowball(
                                snapshot.hasData
                                  ? snapshot.data.docs
                                  : <QueryDocumentSnapshot>[]
                              )
                                  ? Image.asset(
                                      "assets/icon_snow_a.png",
                                      width: 21,
                                    )
                                  : Image.asset(
                                      "assets/icon_snow.png",
                                      width: 25,
                                      height: 25,
                                    ),
                            );
                          },
                        ),
                      ),
                      Text(
                        "${snapshot.hasData ? snapshot.data.docs.length : 0}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }),
            color: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.white,
          ),
          MaterialButton(
            onPressed: () {},
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Image.asset("assets/icon_msj.png", width: 25),
                  onPressed: widget.onPressedMsj ?? () {},
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("comentarios")
                        .where("snowball_id", isEqualTo: id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 0, top: 1, bottom: 1, right: 0),
                        child: Text(
                          "${snapshot.hasData ? snapshot.data.docs.length : 0}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    })
              ],
            ),
            color: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.white,
          ),
          MaterialButton(
            color: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.white,
            onPressed: () => showRecomendedBy(id, context),
            child: Row(
              children: [
                IconButton(
                  icon: Image.asset("assets/icon_recommend.png", width: 20),
                  onPressed: () => showRecomendedBy(id, context),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("recomendaciones")
                        .where("snowball_id", isEqualTo: id)
                        .where("pending", isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 0, top: 1, bottom: 1, right: 0),
                        child: Text(
                          "${snapshot.hasData ? snapshot.data.docs.length : 0}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    })
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 0.0, left: 5),
            child: IconButton(
              icon: Image.asset("assets/icon_shared.png", width: 20),
              onPressed: () => controller.shareImageAndTextBy(id),
            ),
          ),
        ],
      ),
    );
  }
}
