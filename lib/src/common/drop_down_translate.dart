import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/service/localize_service.dart';

class DropDownTranslate extends StatefulWidget {
  @override
  _DropDownTranslateState createState() => _DropDownTranslateState();
}

class _DropDownTranslateState extends State<DropDownTranslate> {
  String _selectedLang = LocalizationService.langs.first;
  final box = GetStorage();

  updateLocaleUser(int position) {
    final uuid = box.read("uuid");
    if (uuid != null) {
      FirebaseFirestore.instance.collection("usuarios").doc(uuid).update({
        "locale": position,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
              margin: EdgeInsets.only(right: 10, top: 13),
              child: Icon(
                Icons.translate,
                size: 20,
              )),
          DropdownButton(
            value: _selectedLang,
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: AppConstants.darBlue),
            items: LocalizationService.langs.map((String lang) {
              return DropdownMenuItem(
                  value: lang,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(lang),
                  ));
            }).toList(),
            onChanged: (String value) {
              setState(() => _selectedLang = value);
              LocalizationService().changeLocale(value);
              if (value == "English")
                updateLocaleUser(0);
              else
                updateLocaleUser(1);
            },
          ),
        ],
      ),
    );
  }
}
