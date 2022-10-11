import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/detail/detail_list.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controllerSearch = new TextEditingController();
  FocusNode focusSearch = new FocusNode();
  List<AlgoliaObjectSnapshot> _results = [];
  AlgoliaQuerySnapshot querys = AlgoliaQuerySnapshot();
  String querySearch;
  AlgoliaQuerySnapshot results;
  bool _searching = false;
  Algolia algolia;
  void searchResults(String data) async {
    if (data.length >= 3) {
      getDataResult(controllerSearch.text);
    }
  }

  @override
  void initState() {
    super.initState();
    algolia = Application.algolia;
  }

  void getDataResult(String texto) async {
    AlgoliaQuery query = algolia.instance.index('Snowball');
    if (texto.length >= 3) {
      setState(() {
        _searching = true;
        FocusScope.of(context).requestFocus(focusSearch);
      });

      FocusScope.of(context).requestFocus(focusSearch);

      String valor = controllerSearch.text.trim();
      query = query.search(valor);

      AlgoliaQuerySnapshot snaps = await query.getObjects();

      _results = snaps.hits;

      setState(() {
        querySearch = controllerSearch.text;
        _searching = false;
        FocusScope.of(context).requestFocus(focusSearch);
      });

      FocusScope.of(context).requestFocus(focusSearch);
    }
  }

  void _showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Error"),
              content: Text("Snowball no found"),
            ));
  }

  @override
  Widget build(BuildContext context) {
    void sendataToDetail(String document) {
      if (document.isNotEmpty) {
        Snowball item = new Snowball();
        item.id = document;
        Get.to(() => DetailSnowballView(document));
      } else {
        _showAlert(context);
      }
    }

    Widget videoPreview(String video) {
      if (video != null) {
        video =
            "https://isaca-gwdc.org/wp-content/uploads/2016/12/Video-placeholder.png";
      }
      return Image.network(
        video,
        height: 250,
        width: 250,
        fit: BoxFit.cover,
      );
    }

    Widget imagePreview(String image) {
      if (image == null) {
        image =
            "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Image.network(
            image,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
        );
      } else {
        return Image.network(
          image,
          height: 250,
          width: 250,
          fit: BoxFit.cover,
        );
      }
    }

    Widget listTendenci = Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 20),
        height: 250.0,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("snowball")
              .where("rolls", isGreaterThan: 1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox();
            } else {
              return ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 16, left: 16),
                  itemCount: snapshot.data.docs.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    int indexTemp = snapshot.data.docs.length - index - 1;
                    Snowball snowball =
                        Snowball.fromSnapshot(snapshot.data.docs[indexTemp]);
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      elevation: 1,
                      child: InkWell(
                          onTap: () {
                            sendataToDetail(snapshot.data.docs[indexTemp].id);
                          },
                          child: ClipRRect(
                            borderRadius: new BorderRadius.circular(4.0),
                            child: Stack(
                              children: <Widget>[
                                ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.transparent
                                      ],
                                    ).createShader(Rect.fromLTRB(
                                        0, 0, rect.width, rect.height + 20));
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: snowball.adjuntos.isNotEmpty
                                      ? snowball.adjuntos.first.video != null
                                          ? videoPreview(
                                              snowball.adjuntos.first.video)
                                          : imagePreview(
                                              snowball.adjuntos.first.image)
                                      : imagePreview(null),
                                ),
                                Positioned(
                                    bottom: 20,
                                    left: 10,
                                    child: Text(
                                      snapshot.data.docs[indexTemp]
                                          .data()["nombre"],
                                      style: TextStyle(
                                          color: AppConstants.darBlue,
                                          fontSize: 19),
                                    )),
                                Positioned(
                                    bottom: 8,
                                    left: 10,
                                    child: Text(
                                      snapshot.data.docs[indexTemp]
                                          .data()["ciudad"],
                                      style: TextStyle(
                                          color: AppConstants.darBlue,
                                          fontSize: 12),
                                    ))
                              ],
                            ),
                          )),
                    );
                  });
            }
          },
        ));

    Widget listPapular = Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 20),
        height: 250.0,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("snowball")
              .where("rolls", isGreaterThan: 1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox();
            } else {
              List<QueryDocumentSnapshot> temp = snapshot.data.docs;

              temp.sort((a, b) => a
                  .data()["comentarios"]
                  .length
                  .compareTo(b.data()["comentarios"].length));
              for (var ss in temp) {
                print(ss.data()["comentarios"].length);
              }
              return ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 16, left: 16),
                  itemCount: temp.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, indexx) {
                    int index = temp.length - indexx - 1;
                    Snowball snowball = Snowball.fromSnapshot(temp[index]);
                    return Card(
                      elevation: 1,
                      color: Colors.white.withOpacity(0.1),
                      child: InkWell(
                        onTap: () {
                          sendataToDetail(temp[index].id);
                        },
                        child: Hero(
                            tag: "${temp[index]["id"]}$index",
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(4.0),
                              child: Stack(
                                children: <Widget>[
                                  ShaderMask(
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withAlpha(200),
                                            Colors.transparent
                                          ],
                                        ).createShader(Rect.fromLTRB(0, 0,
                                            rect.width, rect.height + 20));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: snowball.adjuntos.isNotEmpty
                                          ? snowball.adjuntos.first.video !=
                                                  null
                                              ? videoPreview(
                                                  snowball.adjuntos.first.video)
                                              : imagePreview(
                                                  snowball.adjuntos.first.image)
                                          : imagePreview(null)),
                                  Positioned(
                                      bottom: 20,
                                      left: 10,
                                      child: Text(
                                        temp[index].data()["nombre"],
                                        style: TextStyle(
                                            color: AppConstants.darBlue,
                                            fontSize: 19),
                                      )),
                                  Positioned(
                                      bottom: 8,
                                      left: 10,
                                      child: Text(
                                        temp[index].data()["ciudad"],
                                        style: TextStyle(
                                            color: AppConstants.darBlue,
                                            fontSize: 12),
                                      ))
                                ],
                              ),
                            )),
                      ),
                    );
                  });
            }
          },
        ));

    Widget sarchContent = Container(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 15, bottom: 10, top: 20),
        child: TextField(
          controller: controllerSearch,
          focusNode: focusSearch,
          onChanged: (val) => searchResults(val),
          decoration: InputDecoration(
              labelText: 'search_for'.tr,
              contentPadding: EdgeInsets.all(2),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )),
        ),
      ),
    );

    Widget listResultados = Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        sarchContent,
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, right: 15, bottom: 10),
          child: Text(
            'result'.tr + ' ' + _results.length.toString(),
            style: TextStyle(
                fontSize: 13,
                color: Color.fromRGBO(40, 70, 117, 1),
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: _searching == true
              ? Center(child: Text('search_load'.tr))
              : _results.length == 0
                  ? Center(
                      child: Text('no_result'.tr),
                    )
                  : ListView.builder(
                      primary: true,
                      padding: EdgeInsets.only(
                          top: 0, bottom: 0, right: 16, left: 16),
                      itemCount: _results.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        AlgoliaObjectSnapshot snap = _results[index];
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              onTap: () => sendataToDetail(
                                  !['', 'null', null].contains(snap.data["id"])
                                      ? snap.data["id"]
                                      : snap.objectID),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage("assets/snowball_logo.png"),
                              ),
                              title: Text(
                                snap.data["nombre"],
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                snap.data["descripcion"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(top: 38.0),
                                child: Text(
                                  snap.data["ciudad"],
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
        )
      ],
    ));

    return Stack(
      children: <Widget>[
        sarchContent,
        Container(
          decoration: BoxDecoration(),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            child: controllerSearch.text.length >= 3
                ? listResultados
                : ListNoSearch(
                    sarchContent: sarchContent,
                    listTendenci: listTendenci,
                    listPapular: listPapular),
          ),
        )
      ],
    );
  }
}

class ListNoSearch extends StatelessWidget {
  const ListNoSearch({
    Key key,
    @required this.sarchContent,
    @required this.listTendenci,
    @required this.listPapular,
  }) : super(key: key);

  final Widget sarchContent;
  final Widget listTendenci;
  final Widget listPapular;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        sarchContent,
        Padding(
          padding: EdgeInsets.only(left: 20, right: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'rolling'.tr,
                style: TextStyle(
                    fontSize: 22,
                    color: Color.fromRGBO(40, 70, 117, 1),
                    fontWeight: FontWeight.w500),
              ),
              MaterialButton(
                  height: 10,
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Get.to(() => DetailListView(type: "rollsgreat"));
                  },
                  child: Text('see_label'.tr)),
            ],
          ),
        ),
        listTendenci,
        Padding(
          padding: EdgeInsets.only(left: 20, right: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'recommendation'.tr,
                style: TextStyle(
                    fontSize: 22,
                    color: Color.fromRGBO(40, 70, 117, 1),
                    fontWeight: FontWeight.w500),
              ),
              MaterialButton(
                height: 10,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Get.to(() => DetailListView(type: "rollsnogreat"));
                },
                child: Text('see_label'.tr),
              ),
            ],
          ),
        ),
        listPapular,
      ],
    );
  }
}

class Application {
  static final Algolia algolia = Algolia.init(
    applicationId: 'F71UYNAT2F',
    apiKey: '8662508d29559ddbc9a4653b2a57a264',
  );
}
