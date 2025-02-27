import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusewallet/modals/views/signin_viewmodel.dart';
import 'package:fusewallet/redux/actions/signin_actions.dart';
import 'package:fusewallet/redux/state/app_state.dart';
import 'dart:core';
import 'package:fusewallet/screens/signup/backup2.dart';
import 'package:fusewallet/logic/common.dart';
import 'package:fusewallet/screens/wallet/wallet.dart';
import 'package:fusewallet/widgets/widgets.dart';

class ShowKeyPage extends StatefulWidget {
  ShowKeyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ShowKeyPageState createState() => _ShowKeyPageState();
}

class _ShowKeyPageState extends State<ShowKeyPage> {
  static GlobalKey<ScaffoldState> scaffoldState;

  @override
  Future initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(title: "Back up", children: <Widget>[
      Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 0.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Text("Please write down those 12 words:",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.normal)),
            )
          ],
        ),
      ),
      new StoreConnector<AppState, SignInViewModel>(onInit: (store) {
        //store.dispatch(generateWalletCall());
      }, converter: (store) {
        return SignInViewModel.fromStore(store);
      }, builder: (_, viewModel) {
        return (viewModel.user != null &&
                viewModel.user.mnemonic.length > 0 &&
                !viewModel.isLoading)
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          color: const Color(0xFFFFFFFF)),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              wordWidget(viewModel.user.mnemonic.split(" ")[0]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[1]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[2])
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              wordWidget(viewModel.user.mnemonic.split(" ")[3]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[4]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[5])
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              wordWidget(viewModel.user.mnemonic.split(" ")[6]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[7]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[8])
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              wordWidget(viewModel.user.mnemonic.split(" ")[9]),
                              wordWidget(
                                  viewModel.user.mnemonic.split(" ")[10]),
                              wordWidget(viewModel.user.mnemonic.split(" ")[11])
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 25),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CopyToClipboard(
                                    context: context,
                                    scaffoldState: scaffoldState,
                                    content: viewModel.user.mnemonic,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    Icons.content_copy,
                                    color: const Color(0xFF546c7c),
                                    size: 16,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Center(
                      child: PrimaryButton(
                    label: "BACK",
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  )),
                  const SizedBox(height: 16.0),
                ],
              )
            : Padding(
                child: Preloader(),
                padding: EdgeInsets.only(top: 70),
              );
      })
    ]);
  }

  Widget wordWidget(word) {
    return Expanded(
      child: Center(
        child: Padding(
          child: Text(word,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 0),
        ),
      ),
    );
  }
}
