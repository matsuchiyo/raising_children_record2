
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/viewmodel/invitationCodeReadViewModel.dart';

class InvitationCodeReadView extends StatefulWidget {
  void Function(InvitationCode) onInvitationCodeRead;

  InvitationCodeReadView({Key key, this.onInvitationCodeRead });

  @override
  _InvitationCodeReadViewState createState() => _InvitationCodeReadViewState();
}

class _InvitationCodeReadViewState extends State<InvitationCodeReadView> {
  final _messageStyle = TextStyle(fontSize: 16);
  final _readButtonStyle = TextStyle(fontSize: 16.0);
  final _cancelButtonStyle = TextStyle(fontSize: 16.0);

  InvitationCodeReadViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<InvitationCodeReadViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(
          l10n.readingInvitationCodeTitle,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.readingInvitationCodeMessage,
              textAlign: TextAlign.center,
              style: _messageStyle,
            ),
            Container(
                height: 48,
            ),
            RaisedButton(
              onPressed: _onUseInvitationCodeButtonTapped,
              child: Text(
                l10n.readInvitationCodeButton,
                style: _readButtonStyle,
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onInvitationCodeRead(null);
              },
              child: Text(
                l10n.noInvitationCodeButton,
                style: _cancelButtonStyle,
              )
            ),
          ],
        ),
      ),
    );
  }

  void _onUseInvitationCodeButtonTapped() async {
    final ScanResult result = await BarcodeScanner.scan();
    final json = result.rawContent.toString();
    final InvitationCode invitationCode = InvitationCode.fromJSON(json);
    Navigator.pop(context);
    widget.onInvitationCodeRead(invitationCode);
  }
}