import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/controller/notification/notification_controller.dart';

class NotificationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "assets/fondo_login.png"), // <-- BACKGROUND IMAGE
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1), BlendMode.dstATop)),
          ),
        ),
        Scaffold(
          body: Container(
            child: GetBuilder<NotificationController>(
              initState: (_) => NotificationController.to.getNotifications(),
              dispose: (_) => NotificationController.to.clearData(),
              builder: (controller) => Obx(() => ListView.builder(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 0, right: 16, left: 16),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    var item = controller.notifications[index];
                    return Card(
                      elevation: item.read ? 0 : 1,
                      child: InkWell(
                        onTap: () => controller.senDataDetail(item.type, item),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Icon(
                                controller.getTypeNotification(
                                    item.type, "icons"),
                                color: item.read
                                    ? Colors.grey.shade400
                                    : Colors.grey,
                                size: 20,
                              ),
                            ),
                            title: Text(
                                controller.getTypeNotification(
                                    item.type, "title"),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: item.read
                                        ? Colors.grey.shade400
                                        : Colors.black54)),
                            subtitle: Text(
                              item.autor,
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              controller.getTypeNotification(
                                  item.type, "subtitle"),
                              style: TextStyle(
                                  color: item.read
                                      ? Colors.grey.shade400
                                      : Colors.black,
                                  fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    );
                  })),
            ),
          ),
        ),
      ],
    );
  }
}
