
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/baseRecordViewModel.dart';

class HeightRecordViewModel extends BaseRecordViewModel<HeightRecord> {

  Stream<double> get height => recordBehaviorSubject.stream.map((record) => record.height ?? 0);
  final StreamController<double> _onHeightSelectedStreamController = StreamController<double>();
  StreamSink<double> get onHeightSelected => _onHeightSelectedStreamController.sink;

  HeightRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository): super(record, user, baby, recordRepository) {

    _onHeightSelectedStreamController.stream.listen((height) {
      HeightRecord record = recordBehaviorSubject.value;
      record.height = height;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onHeightSelectedStreamController.close();
  }
}