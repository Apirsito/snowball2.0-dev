import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/chat/chat_controller.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/user/user_view.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsUserView extends StatefulWidget {
  final String currentUser;
  final String iduser;
  final UserModel users;
  ChatsUserView(this.currentUser, this.iduser, this.users);

  @override
  _ChatsUserViewState createState() =>
      _ChatsUserViewState(iduser: iduser, currentUser: currentUser);
}

class _ChatsUserViewState extends State<ChatsUserView> {
  ChatController controller = Get.put(ChatController());

  String currentUser;
  String iduser;
  String tokenOtherUser;
  var greyColor2 = Colors.grey;

  _ChatsUserViewState({@required this.currentUser, @required this.iduser});

  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController =
      new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  var listMessage;
  String groupChatId;

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == currentUser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != currentUser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('chats')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': currentUser,
            'idTo': iduser,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });

      FirebaseFirestore.instance.collection("notifications").add({
        "id": iduser,
        "idFrom": currentUser,
        "read": false,
        "title": "New Message",
        "chatid": groupChatId,
        "type": 1,
        "fecha": DateTime.now()
      });

      saveChats();
      FirebaseFirestore.instance
          .collection("usuarios")
          .doc(currentUser)
          .get()
          .then((value) {
        print(value.data()["nombre_usuario"]);
        // NotificationService.shared.send(
        //     TypeNotify.message, value.data()["nombre_usuario"], tokenOtherUser);
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print("error");
    }
  }

  saveChats() async {
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(iduser)
        .collection("chats")
        .doc(currentUser)
        .set({
      "chatid": groupChatId,
      "id": currentUser,
      "to": iduser,
      "read": false,
      "fecha": DateTime.now()
    }).catchError((error) => print(error));

    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(currentUser)
        .collection("chats")
        .doc(iduser)
        .set({
      "chatid": groupChatId,
      "id": iduser,
      "to": currentUser,
      "read": true,
      "fecha": DateTime.now()
    }).catchError((error) => print(error));
  }

  void openPerfilUser(String users) {
    Get.to(UserView(id: users));
  }

  @override
  void initState() {
    super.initState();
    groupChatId = '';
    readLocal();
    getOtherUser();
  }

  void getOtherUser() {
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(iduser)
        .get()
        .then((value) {
      tokenOtherUser = value.data()["token"];
    });
  }

  void readLocal() {
    if (currentUser.hashCode <= iduser.hashCode) {
      groupChatId = '$currentUser-$iduser';
    } else {
      groupChatId = '$iduser-$currentUser';
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == currentUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              child: Text(
                document['content'],
                style: TextStyle(color: Colors.black54),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 210.0,
              decoration: BoxDecoration(
                  color: Color(0xffE8E8E8),
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(right: 5.0),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              child: Text(
                document['content'],
                style: TextStyle(color: Colors.black54),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: Color(0xffE8E8E8),
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(left: 5.0),
            ),
          ),
          isLastMessageLeft(index)
              ? Container(
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp']))),
                    style: TextStyle(
                        color: Color(0xffE8E8E8),
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                  margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                )
              : Container()
        ],
      );
    }
  }

  Widget _buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                onPressed: () {},
                icon: new Icon(Icons.face),
                color: Colors.grey,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              color: Colors.white,
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    style: TextStyle(color: Colors.blueAccent, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: '...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: focusNode,
                  ),
                ],
              ),
            ),
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blueAccent,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget listMessages() {
    return Flexible(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(groupChatId)
              .collection(groupChatId)
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent)));
            } else {
              listMessage = snapshot.data.documents;

              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(index, snapshot.data.docs[index]),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                controller: listScrollController,
              );
            }
          }),
    );
  }

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
        ),
        body: WillPopScope(
          onWillPop: () => Future.value(true),
          child: GetBuilder<ChatController>(
            initState: (_) => ChatController.to.getFrienData(by: iduser),
            dispose: (_) => ChatController.to.clearData(),
            builder: (controller) =>
                Obx(() => controller.selectUser.value.name == null
                    ? CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: InkWell(
                                    onTap: () => openPerfilUser( controller.selectUser.value.id ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: ListTile(
                                            dense: true,
                                            title: Text(
                                              controller.selectUser.value.name ?? "",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            subtitle: Text("last_login".tr +
                                              timeago.format(
                                                controller.selectUser.value.dateLastLogin ?? DateTime.now(),
                                                locale: 'locale'.tr
                                              )
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 70,
                                          width: 70,
                                          child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child: ClipOval(
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "assets/snowball_logo.png",
                                                  image: controller
                                                      .selectUser.value.image,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                listMessages(),
                                _buildInput(),
                              ],
                            ),
                          ],
                        ),
                      )),
          ),
        ));
  }
}
