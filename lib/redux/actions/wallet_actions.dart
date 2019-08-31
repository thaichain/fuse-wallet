import 'package:flutter/material.dart';
import 'package:fusewallet/modals/businesses.dart';
import 'package:fusewallet/modals/community.dart';
import 'package:fusewallet/modals/transactions.dart';
import 'package:fusewallet/services/wallet_service.dart';
import 'package:fusewallet/widgets/bonusDialog.dart';
import 'package:local_auth/local_auth.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:fusewallet/logic/crypto.dart' as crypto;
import 'package:flutter/widgets.dart';

ThunkAction initWalletCall(BuildContext context) {
  return (Store store) async {

    var localAuth = LocalAuthentication();
    bool didAuthenticate =
    await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to open the wallet');
        
    await loadCommunity(store);
    
    /// Show bonus dialog
    if (store.state.walletState.community != null) { //&& store.state.walletState.showBonusDialog == null
      new Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return BonusDialog();
            });
      });
    }

    store.dispatch(new WalletLoadedAction());
  };
}

Future loadCommunity(Store store) async {
  var tokenAddress = store.state.walletState.tokenAddress;
  if ((tokenAddress ?? "") == "") {
    tokenAddress = DEFAULT_COMMUNITY;
  }
  var community = await getCommunity(tokenAddress);
  store.dispatch(new CommunityLoadedAction(tokenAddress, community));
  loadBalance(store);
  loadTransactions(store);
}

Future loadBalance(Store store) async {
  var publicKey = store.state.userState.user.publicKey;
  var tokenAddress = store.state.walletState.tokenAddress;
  var balance = await getBalance(publicKey, tokenAddress);
  store.dispatch(new BalanceLoadedAction(balance));
}

Future loadTransactions(Store store) {
  var publicKey = store.state.userState.user.publicKey;
  var tokenAddress = store.state.walletState.tokenAddress;
  getTransactions(publicKey, tokenAddress).then((list) {
    store.dispatch(new TransactionsLoadedAction(list));
  });
}

ThunkAction sendTransactionCall(BuildContext context, address, amount) {
  return (Store store) async {
    store.dispatch(new StartLoadingAction());
    crypto.sendNIS(crypto.cleanAddress(address), int.parse(amount), store.state.userState.user.privateKey)
      .then((ret) {
          Navigator.of(context).pop();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Transaction sent successfully'),
            //duration: new Duration(seconds: 5),
          ));
        store.dispatch(new TransactionSentAction());
      });
    return true;
  };
}

ThunkAction loadBusinessesCall() {
  return (Store store) async {
    store.dispatch(new StartLoadingAction());
    getBusinesses().then((list) {
      store.dispatch(new BusinessesLoadedAction(list));
    });
    return true;
  };
}

ThunkAction switchCommunityCall(communityAddress) {
  return (Store store) async {
    store.dispatch(new SwitchCommunityAction(communityAddress));
    return true;
  };
}

class WalletLoadedAction {
  WalletLoadedAction();
}

class StartLoadingAction {
  StartLoadingAction();
}

class CommunityLoadedAction {
  final Community community;
  final String tokenAddress;

  CommunityLoadedAction(this.tokenAddress, this.community);
}

class TransactionsLoadedAction {
  final TransactionList transactions;

  TransactionsLoadedAction(this.transactions);
}

class BalanceLoadedAction {
  final String balance;

  BalanceLoadedAction(this.balance);
}

class SendTransactionAction {
  SendTransactionAction();
}

class TransactionSentAction {
  TransactionSentAction();
}

class BusinessesLoadedAction {
  final List<Business> businessList;

  BusinessesLoadedAction(this.businessList);
}

class SwitchCommunityAction {
  final String address;

  SwitchCommunityAction(this.address);
}