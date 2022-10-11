import 'package:flutter/material.dart';
import 'package:snowball/src/common/app_constants.dart';

class OptionProfile extends StatelessWidget {
  const OptionProfile({
    Key key,
    @required this.onTap,
    @required this.value,
    @required this.name,
  }) : super(key: key);

  final String name;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        height: 44,
        width: 110,
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(
                color: AppConstants.darBlue,
                fontSize: 24,
                fontFamily: "Lato",
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 12,
                    fontFamily: "Lato",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
