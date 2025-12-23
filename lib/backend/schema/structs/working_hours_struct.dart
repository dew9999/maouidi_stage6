
class WorkingHoursStruct {
  String? day;
  String? openTime;
  String? closeTime;
  bool? isOpen;

  WorkingHoursStruct({
    this.day,
    this.openTime,
    this.closeTime,
    this.isOpen,
  });

  // Factory to create from Map
  factory WorkingHoursStruct.fromMap(Map<String, dynamic> data) {
    return WorkingHoursStruct(
      day: data['day'] as String?,
      openTime: data['open_time'] as String?,
      closeTime: data['close_time'] as String?,
      isOpen: data['is_open'] as bool?,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'open_time': openTime,
      'close_time': closeTime,
      'is_open': isOpen,
    };
  }

  // Serialization helpers for legacy code
  static WorkingHoursStruct? maybeFromMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return WorkingHoursStruct.fromMap(data);
    }
    return null;
  }

  @override
  String toString() =>
      'WorkingHoursStruct(day: $day, openTime: $openTime, closeTime: $closeTime, isOpen: $isOpen)';

  @override
  bool operator ==(Object other) {
    return other is WorkingHoursStruct &&
        day == other.day &&
        openTime == other.openTime &&
        closeTime == other.closeTime &&
        isOpen == other.isOpen;
  }

  @override
  int get hashCode => Object.hash(day, openTime, closeTime, isOpen);
}

WorkingHoursStruct createWorkingHoursStruct({
  String? day,
  String? openTime,
  String? closeTime,
  bool? isOpen,
}) =>
    WorkingHoursStruct(
      day: day,
      openTime: openTime,
      closeTime: closeTime,
      isOpen: isOpen,
    );
