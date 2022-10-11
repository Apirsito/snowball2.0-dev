import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalsView {
  static showSnowballOptions(
      dynamic controller, String id, BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                InkWell(
                  onTap: () => controller.gotoPerfilUser(id),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.comment),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('send_message'.tr),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => neverSatisfied(context, 'we_are_curremtly'.tr),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cancel),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('hide_publish'.tr),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => whiIdDenuncePublish(context, id),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.flag),
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text('report_publish'.tr),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static neverSatisfied(BuildContext context, String message) async {
    Get.back();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text('thanks_your_info'.tr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static whiIdDenuncePublish(BuildContext context, String id,
      {bool parent = true}) {
    if (parent) Navigator.pop(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 400,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[Text('why_report'.tr)],
                  ),
                ),
                Container(height: 1, color: Colors.grey, child: SizedBox()),
                InkWell(
                  onTap: () =>
                      neverSatisfied(context, 'message_repor_detail'.tr),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove,
                          size: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('message_inapro'.tr),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      neverSatisfied(context, 'message_repor_detail'.tr),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove,
                          size: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('message_false'.tr),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      neverSatisfied(context, 'message_repor_detail'.tr),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove,
                          size: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('message_faude'.tr),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      neverSatisfied(context, 'message_repor_detail'.tr),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove,
                          size: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text('message_repor_inapro'.tr),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
