/// The models in this file are inspired by this GitHub repo:
/// https://github.com/daohoangson/dvhcvn/blob/master/transformers/dart-dvhcvn/lib/dvhcvn.dart
import 'package:rentalz/utils/my_string_extension.dart';

import 'dvhcvn_data.dart';

abstract class DvhcvnEntity {
  const DvhcvnEntity(this.id, this.name, this.type);

  final String id;

  final String name;

  final DvhcvnEntityType type;

  /// Returns type as Vietnamese string.
  String get typeAsString {
    switch (type) {
      case DvhcvnEntityType.huyen:
        return 'Huyện';
      case DvhcvnEntityType.quan:
        return 'Quận';
      case DvhcvnEntityType.phuong:
        return 'Phường';
      case DvhcvnEntityType.thiTran:
        return 'Thị trấn';
      case DvhcvnEntityType.thiXa:
        return 'Thị xã';
      case DvhcvnEntityType.tinh:
        return 'Tỉnh';
      case DvhcvnEntityType.tp:
        return 'Thành phố';
      case DvhcvnEntityType.tptw:
        return 'Thành phố trực thuộc Trung ương';
      case DvhcvnEntityType.xa:
        return 'Xã';
    }
  }
}

/// Represents a province or a city.
class Level1 extends DvhcvnEntity {
  const Level1(String id, String name, DvhcvnEntityType type, this.children)
      : super(id, name, type);

  final List<Level2> children;

  Level2? findLevel2ById(String id) =>
      findDvhcvnEntityById<Level2>(children, id);

  Level2? findLevel2ByName(String name) =>
      findDvhcvnEntityByName<Level2>(children, name);
}

/// Represents a city or a district.
class Level2 extends DvhcvnEntity {
  const Level2(this._level1Index, String id, String name, DvhcvnEntityType type,
      this.children)
      : super(id, name, type);

  final int _level1Index;
  final List<Level3> children;

  Level1 get parent => level1s[_level1Index];

  Level3? findLevel3ById(String id) =>
      findDvhcvnEntityById<Level3>(children, id);

  Level3? findLevel3ByName(String name) =>
      findDvhcvnEntityByName<Level3>(children, name);
}

/// Represents a town, a ward, or a commune.
class Level3 extends DvhcvnEntity {
  const Level3(this._level1Index, this._level2Index, String id, String name,
      DvhcvnEntityType type)
      : super(id, name, type);

  final int _level1Index;
  final int _level2Index;

  Level2 get parent => level1s[_level1Index].children[_level2Index];
}

T? findDvhcvnEntityById<T extends DvhcvnEntity>(List<T> list, String id) {
  for (final item in list) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
}

T? findDvhcvnEntityByName<T extends DvhcvnEntity>(List<T> list, String name) {
  for (final item in list) {
    if (item.name.isRelevantTo(name)) {
      return item;
    }
  }
  return null;
}

enum DvhcvnEntityType {
  /// Huyện
  huyen,

  /// Quận
  quan,

  /// Phường
  phuong,

  /// Thị trấn
  thiTran,

  /// Thị xã
  thiXa,

  /// Tỉnh
  tinh,

  /// Thành phố
  tp,

  /// Thành phố trực thuộc Trung ương
  tptw,

  /// Xã
  xa,
}
