import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermAndConditions extends StatefulWidget {
  final url;
  TermAndConditions({Key key, @required this.url}) : super(key: key);

  @override
  _TermAndConditionsState createState() => _TermAndConditionsState(this.url);
}

class _TermAndConditionsState extends State<TermAndConditions> {
  final url;
  _TermAndConditionsState(this.url);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(0, 146, 209, 1),
        elevation: 0,
        title: Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
