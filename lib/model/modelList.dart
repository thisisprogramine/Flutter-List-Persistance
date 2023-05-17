
import 'package:list_persistence/model/model.dart';

class ResultModel {
  final List<Model> listModel;

  const ResultModel({
    required this.listModel,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    var list = List<Model>.empty(growable: true);

    if(json['results'] != null) {
      json['results'].forEach((t) {
        final transaction = Model.fromJson(t);
        list.add(transaction);
      }
      );
    }
    return ResultModel(listModel: list);
  }
}