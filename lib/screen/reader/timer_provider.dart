import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_provider.g.dart';

@riverpod
class AppTimer extends _$AppTimer {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void update() {
    state = DateTime.now();
    // Log.i('update : ${state}');
  }

  String get time => "${state.hour}:${state.minute}:${state.second}";
}
