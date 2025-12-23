import 'package:from_css_color/from_css_color.dart';


/// Define the missing enum locally
enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,
}

/// Define the missing deserialization function locally
dynamic deserializeParam<T>(
  dynamic param,
  ParamType paramType,
  bool isList,
) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramList = param is List ? param : [param];
      if (paramType == ParamType.JSON) {
        return paramList;
      }
      return paramList
          .map((p) => deserializeParam<T>(p, paramType, false))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }

    if (paramType == ParamType.String) {
      return param.toString();
    } else if (paramType == ParamType.int) {
      return int.tryParse(param.toString());
    } else if (paramType == ParamType.double) {
      return double.tryParse(param.toString());
    } else if (paramType == ParamType.bool) {
      return param is bool ? param : (param.toString().toLowerCase() == 'true');
    } else if (paramType == ParamType.DateTime) {
      return DateTime.tryParse(param.toString());
    } else if (paramType == ParamType.Color) {
      return fromCssColor(param.toString());
    } else if (paramType == ParamType.JSON) {
      return param; // Assuming Map or List
    }
    // Add other types if needed (LatLng, Place, etc.)
    return param;
  } catch (e) {
    print('Error deserializing parameter: $e');
    return null;
  }
}

/// Helper for serialization
String serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return 'null';
    }
    if (isList) {
      final serializedList = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .toList();
      return serializedList.toString(); // simplified
    }
    if (paramType == ParamType.String) {
      return param.toString();
    }
    // simplified serialization for migration purposes
    return param.toString();
  } catch (e) {
    return 'null';
  }
}
