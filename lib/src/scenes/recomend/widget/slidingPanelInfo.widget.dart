import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/recomend/list_controller.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';

class SlidingPanelInfo {
  static Widget info(
    ScrollController controller,
    RecommendListController recommendController,
    PanelController panelController,
    bool isApproved
  ) =>
      SingleChildScrollView(
        controller: controller,
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/snowball_logo.png",
                  image: (recommendController.itemSelected.value?.imagen != null && 
                    recommendController.itemSelected.value.imagen.isNotEmpty)
                      ? recommendController.itemSelected.value?.imagen
                      : recommendController.listRecommend.value.snowball.adjuntos.isNotEmpty 
                        ? (recommendController.listRecommend.value.snowball.adjuntos.first.video != null )
                          ? AppConstants.logoSnowball 
                          : recommendController.listRecommend.value.snowball.adjuntos.first.image 
                        : AppConstants.logoSnowball,
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                child: Text(
                  recommendController.itemSelected.value?.autorName ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  recommendController.itemSelected.value?.descripcion ?? '',
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Visibility(
                        visible: !isApproved,
                        child: TextButton(
                          child: Icon(
                            Icons.delete,
                            size: 28,
                            color: Colors.red[300],
                          ),
                          onPressed: (){
                            recommendController.ignoreRecomend( recommendController.itemSelected.value );
                            panelController.close();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          Get.to( () =>
                            DetailSnowballView(
                              recommendController.itemSelected.value?.snowballId
                            )
                          );
                        },
                        child: Text('showPost'.tr),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.lightBlue[300],
                          minimumSize: Size(150, 45),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Visibility(
                        visible: !isApproved,
                        child: TextButton(
                          child: Icon(
                            Icons.check_box_rounded,
                            size: 28,
                            color: Colors.green[300],
                          ),
                          onPressed: (){
                            recommendController.acepRecommend( recommendController.itemSelected.value );
                            panelController.close();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
