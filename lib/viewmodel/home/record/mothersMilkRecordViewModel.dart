
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/baseRecordViewModel.dart';

class MothersMilkRecordViewModel extends BaseRecordViewModel<MothersMilkRecord> {

  Stream<int> get leftMinutes => recordBehaviorSubject.stream.map((record) => ((record.leftMilliseconds ?? 0) / (1000 * 60)).round());
  final StreamController<int> _onLeftMinutesSelectedStreamController = StreamController<int>();
  StreamSink<int> get onLeftMinutesSelected => _onLeftMinutesSelectedStreamController.sink;

  Stream<int> get rightMinutes => recordBehaviorSubject.stream.map((record) => ((record.rightMilliseconds ?? 0) / (1000 * 60)).round());
  final StreamController<int> _onRightMinutesSelectedStreamController = StreamController<int>();
  StreamSink<int> get onRightMinutesSelected => _onRightMinutesSelectedStreamController.sink;

  MothersMilkRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository, { bool isNew = false }): super(record, user, baby, recordRepository, isNew: isNew) {

    _onLeftMinutesSelectedStreamController.stream.listen((leftMinutes) {
      MothersMilkRecord record = recordBehaviorSubject.value;
      record.leftMilliseconds = leftMinutes * 1000 * 60;
      recordBehaviorSubject.add(record);
    });

    _onRightMinutesSelectedStreamController.stream.listen((rightMinutes) {
      MothersMilkRecord record = recordBehaviorSubject.value;
      record.rightMilliseconds = rightMinutes * 1000 * 60;
      recordBehaviorSubject.add(record);
    });

  }

  void dispose() {
    _onLeftMinutesSelectedStreamController.close();
    _onRightMinutesSelectedStreamController.close();
  }
}