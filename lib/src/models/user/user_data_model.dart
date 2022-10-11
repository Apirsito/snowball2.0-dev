import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/models/user/user_model.dart';

class UserDataModel {
  UserModel user;
  List<Snowball> snowballs = [];
  List<String> snowImage = [];
  bool userBlock;
  int recommends;
  int rolls;

  UserDataModel();

  UserDataModel.fromJsonMap(DocumentSnapshot snap, this.snowballs,
      this.snowImage, this.userBlock, this.rolls, this.recommends) {
    user = UserModel.fromJsonMap(snap);
  }
}
