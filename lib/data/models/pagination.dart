import 'package:screenshare/domain/entities/pagination_entity.dart';

class PaginationModel extends PaginationEntity {
  PaginationModel.fromJSON(Map<String, dynamic> json)
      : super(
          page: json['page'],
          limit: json['limit'],
          totalPage: json['totalPage'],
        );

  Map<String, dynamic> toJson() => {
        'page':page,
        'limit':limit,
        'totalPage': totalPage,
      };
}