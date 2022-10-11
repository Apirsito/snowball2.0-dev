import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snowball/src/models/user/user_model.dart';

class ProfileModel {
  UserModel user;
  int notificationNumber;

  ProfileModel();

  ProfileModel.fromJsonMap(DocumentSnapshot jsonUser, int number) {
    user = UserModel.fromJsonMap(jsonUser);
    notificationNumber = number;
  }
}
