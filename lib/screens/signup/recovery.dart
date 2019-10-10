import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusewallet/modals/views/signin_viewmodel.dart';
import 'package:fusewallet/redux/state/app_state.dart';
import 'package:fusewallet/screens/signup/backup1.dart';
import 'package:fusewallet/screens/wallet/wallet.dart';
import 'dart:core';
import 'package:fusewallet/widgets/widgets.dart';
import 'package:fusewallet/logic/common.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecoveryPage extends StatefulWidget {
  RecoveryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RecoveryPageState createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  GlobalKey<ScaffoldState> scaffoldState;
  bool isLoading = false;
  final wordsController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(title: "Recover your wallet", children: <Widget>[
      Container(
        //color: Theme.of(context).primaryColor,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 0.0),
              child: Text(
                  "This is a 12 word phrase you were given when you created your previous wallet",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.normal)),
            ),
          ],
        ),
      ),
      new StoreConnector<AppState, SignInViewModel>(converter: (store) {
        return SignInViewModel.fromStore(store);
      }, builder: (_, viewModel) {
        return Padding(
          padding: EdgeInsets.only(top: 10, left: 30, right: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: wordsController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: 'Write down your 12 words...',
                  ),
                  validator: (String value) {
                    if (value.split(" ").length != 12) {
                      return 'Please enter 12 words';
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: PrimaryButton(
                      label: "Next",
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          final storage = new FlutterSecureStorage();
                          await storage.write(
                              key: 'mnemonic', value: wordsController.text);
                          viewModel.signUp(context, "", "", "");
                        }
                      }),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: Padding(
                    child: Text(
                      "This data will be enrypted and stored only on this device secured storage.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    padding: const EdgeInsets.only(bottom: 30.0),
                  ),
                )
              ],
            ),
          ),
        );
      })
    ]);
  }
}
