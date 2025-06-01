import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class Schedule {
  int? id;
  int dayOfWeek;
  String time;
  int personalsId;

  Schedule({
    this.id,
    required this.dayOfWeek,
    required this.time,
    required this.personalsId,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      time: json['time'],
      personalsId: json['personalsId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dayOfWeek': dayOfWeek,
      'time': time,
      'personalsId': personalsId
    };
  }
}
