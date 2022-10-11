import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class LatesCard extends StatelessWidget {
  const LatesCard(
      {Key key,
      this.onTap,
      @required this.latesList,
      @required this.isAdd,
      this.onPressed})
      : super(key: key);

  final List<String> latesList;
  final bool isAdd;
  final VoidCallback onTap;
  final Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: ListView.builder(
        itemCount: latesList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (isAdd && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => onTap(),
                child: Container(
                  height: 122,
                  width: 100,
                  child: Card(
                    elevation: 0,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            FontAwesomeIcons.plus,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'add_new'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            );
          } else {
            return Card(
              elevation: 1,
              child: InkWell(
                onTap: () => onPressed(index),
                child: latesList[index] == null
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "assets/snowball_logo.png",
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      )
                    : ClipRRect(
                        child: FadeInImage.assetNetwork(
                        placeholder: "assets/snowball_logo.png",
                        image: latesList[index],
                        height: 100,
                        fit: BoxFit.cover,
                      )),
              ),
            );
          }
        },
      ),
    );
  }
}
