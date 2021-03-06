
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/baseRecordViewModel.dart';

class MilkRecordViewModel extends BaseRecordViewModel<MilkRecord> {

  Stream<int> get amount => recordBehaviorSubject.stream.map((record) => record.amount ?? 0);
  final StreamController<int> _onAmountSelectedStreamController = StreamController<int>();
  StreamSink<int> get onAmountSelected => _onAmountSelectedStreamController.sink;

  MilkRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository, { bool isNew = false }): super(record, user, baby, recordRepository, isNew: isNew) {

    _onAmountSelectedStreamController.stream.listen((amount) {
      MilkRecord record = recordBehaviorSubject.value;
      record.amount = amount;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onAmountSelectedStreamController.close();
  }
}