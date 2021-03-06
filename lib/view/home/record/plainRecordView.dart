
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/view/home/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/plainRecordViewModel.dart';

class PlainRecordView extends BaseRecordView<PlainRecordViewModel> {

  PlainRecordView({ Key key, bool isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    return Container();
  }
}
