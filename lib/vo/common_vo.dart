import 'package:json_annotation/json_annotation.dart';

part 'common_vo.g.dart';

typedef FromJsonFn<Obj, DeData> = Obj? Function(DeData?)?;
typedef ToJsonFn<Obj> = Object Function(Obj)?;
typedef CommonMapVoData = Map<String, dynamic>;
typedef CommonListVoData = List<dynamic>;

@JsonSerializable(genericArgumentFactories: true)
class CommonVo<Obj, DeData> {
  final int? code;
  final String? message;
  final String? date;
  final Obj? data;

  const CommonVo({this.code, this.message, this.date, this.data});

  factory CommonVo.fromJson(
    Map<String, dynamic> json, {
    FromJsonFn<Obj, DeData> fromJsonT,
  }) => _$CommonVoFromJson<Obj, DeData>(json, fromJsonT: fromJsonT);

  factory CommonVo.fromJsonNullData(Map<String, dynamic> json) =>
      _$CommonVoFromJson<Obj, DeData>(json);

  Object toJson({ToJsonFn toJsonT}) => _$CommonVoToJson(this, toJsonT);
}
