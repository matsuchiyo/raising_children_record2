
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationCodeViewModel {

  final StreamController<void> _onInitStateStreamController = StreamController<void>();
  StreamSink<void> get onInitState => _onInitStateStreamController.sink;

  final StreamController<String> _invitationCodeJSONStreamController = StreamController<String>();
  Stream<String> get invitationCodeJSON => _invitationCodeJSONStreamController.stream;

  final StreamController<DateTime> _expirationDateStreamController = StreamController<DateTime>();
  Stream<DateTime> get expirationDate => _expirationDateStreamController.stream;

  InvitationCodeViewModel() {
    _onInitStateStreamController.stream.listen((_) => _generateInvitationCode());
  }

  void _generateInvitationCode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String familyId = sharedPreferences.getString('familyId');

    InvitationCode invitationCode = InvitationCode.newInstance(familyId);

    Firestore.instance
      .collection('families')
      .document(familyId)
      .collection("invitationCodes")
      .document(invitationCode.code)
      .setData(invitationCode.map)
      .then((_) {
        _invitationCodeJSONStreamController.sink.add(invitationCode.json);
        _expirationDateStreamController.sink.add(invitationCode.expirationDate);
      });
  }

  void dispose() {
    _onInitStateStreamController.close();
    _invitationCodeJSONStreamController.close();
    _expirationDateStreamController.close();
  }
}