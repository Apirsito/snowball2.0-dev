import 'package:snowball/src/models/recommend/recommend_model.dart';
import 'package:snowball/src/models/snowball/snowball.dart';

class GroupRecommend {
  String id;
  Snowball snowball;
  String descripcion;
  String snowballId;
  List<RecommendModel> recommends;

  GroupRecommend(
    {
      this.id,
      this.descripcion,
      this.snowball,
      this.recommends,
      this.snowballId = ''
    }
  );
}
