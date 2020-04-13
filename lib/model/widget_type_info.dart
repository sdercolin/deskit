import 'package:deskit/model/config.dart';
import 'package:deskit/model/value_keeper_config.dart';

enum WidgetTypeInfo {
  VALUE_KEEPER,
}

extension WidgetTypeInfoExtension on WidgetTypeInfo {
  String get name {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Counter';
      default:
        return null;
    }
  }

  String get description {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Retain a value that can be incremented or decremented by a customized interval';
      default:
        return null;
    }
  }

  Config createDefaultConfig() {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return ValueKeeperConfig();
      default:
        return null;
    }
  }
}
