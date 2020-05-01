
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/baseRecordViewModel.dart';
import 'package:intl/intl.dart';

abstract class BaseRecordView<VM extends BaseRecordViewModel> extends StatefulWidget {
  final bool isNew;

  BaseRecordView({ Key key, this.isNew }): super(key: key);

  @override
  _BaseRecordViewState createState() => _BaseRecordViewState<VM>();

  Widget buildContent(BuildContext context);
}

class _BaseRecordViewState<VM extends BaseRecordViewModel> extends State<BaseRecordView> {
  final _recordTypeFont = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _deleteButtonFont = const TextStyle(color: Colors.red, fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  TextEditingController _noteController;
  VM _viewModel;

  @override
  void initState() {
    super.initState();

    _noteController = TextEditingController();

    print("### before $VM");
    _viewModel = Provider.of<VM>(context, listen: false);
    print("### after");
    _viewModel.onSaveComplete.listen((_) => _pop());

    StreamSubscription subscription;
    subscription = _viewModel.note.listen((note) {
      _noteController.text = note;
      subscription.cancel(); // listen only first time
    });
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _plainRecordScaffold();
  }

  Widget _plainRecordScaffold() {
    L10n l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isNew ?? false ? l10n.recordTitleNew : l10n.recordTitleEdit),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => _viewModel.onSaveButtonTapped.add(null),
            ),
          ]
      ),
      body: _plainRecordForm(),
    );
  }

  Widget _plainRecordForm() {
    L10n l10n = L10n.of(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 36, 24, 36),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                StreamBuilder(
                    stream: _viewModel.assetName,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: AssetImage(snapshot.data),
                          ),
                        ),
                        height: 48,
                        width: 48,
                      );
                    }
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _viewModel.title,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return Container(
                        padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Text(
                          snapshot.data,
                          style: _recordTypeFont,
                        ),
                      );
                    },
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            Container(
              height: 36,
            ),
            StreamBuilder(
              stream: _viewModel.dateTime,
              builder: (context, snapshot) {
                final dateTime = snapshot.data ?? DateTime.now();
                return Container(
                  alignment: Alignment.centerLeft,
                  child: FlatButton(
                    child: Text(
                      _dateFormat.format(dateTime),
                      style: _dateButtonFont,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    onPressed: () => _onDateTimeButtonPressed(dateTime),
                  ),
                );
              },
            ),
            widget.buildContent(context),
            Container(
              height: 24,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: l10n.recordLabelNote,
              ),
              onChanged: (text) => _viewModel.onNoteChanged.add(text),
              controller: _noteController,
            ),
            Container(
              height: 24,
            ),
            !(widget.isNew ?? false) ? FlatButton(
              child: Text(
                l10n.recordDeleteButtonLabel,
                style: _deleteButtonFont,
              ),
              onPressed: () => _viewModel.onDeleteButtonTapped.add(null),
            ) : Container()
          ],
        ),
      ),
    );
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _onDateTimeButtonPressed(DateTime currentDateTime) async {
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );

    if (selectedDate == null) {
      return;
    }

    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );

    if (selectedTime == null) {
      return;
    }

    DateTime selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
    _viewModel.onDateTimeSelected.add(selectedDateTime);
  }
}