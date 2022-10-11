import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/chat/chat_controller.dart';

class ChatListView extends StatelessWidget {
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
                AppConstants.darBlue,
                Color.fromRGBO(82, 173, 187, 1)
              ])),
        ),
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: GetBuilder<ChatController>(
          initState: (state) => ChatController.to.getListUsers(),
          dispose: (state) => ChatController.to.clearData(),
          builder: (controller) => Obx(() => ListView.builder(
              padding:
                  const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
              itemCount: controller.users.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var item = controller.users[index];
                return Card(
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(8.0),
                    child: InkWell(
                      onTap: () => controller.gotoDetail(item),
                      child: ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: Hero(
                              tag: item.name,
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/snowball_logo.png',
                                  image: item.image,
                                  height: 55,
                                  width: 55,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(item.name),
                      ),
                    ),
                  ),
                );
              })),
        ),
      ),
    );
  }
}
