import 'package:flutter/widgets.dart';
import 'package:fusewallet/modals/businesses.dart';
import 'package:fusewallet/modals/community.dart';
import 'package:fusewallet/modals/user.dart';
import 'package:fusewallet/redux/actions/wallet_actions.dart';
import 'package:fusewallet/redux/state/app_state.dart';
import 'package:redux/redux.dart';
import '../transactions.dart';

class WalletViewModel {
  final bool isLoading;
  final String balance;
  final User user;
  final Community community;
  final TransactionList transactions;
  final List<Business> businesses;
  final Function(BuildContext) initWallet;
  final Function(BuildContext, String, String) sendTransaction;
  final Function() loadBusinesses;
  final Function(String) switchCommunity;

  WalletViewModel({
    this.isLoading,
    this.balance,
    this.user,
    this.community,
    this.transactions,
    this.initWallet,
    this.sendTransaction,
    this.businesses,
    this.loadBusinesses,
    this.switchCommunity
  });

  static WalletViewModel fromStore(Store<AppState> store) {
    return WalletViewModel(
      isLoading: store.state.walletState.isLoading,
      balance: store.state.walletState.balance,
      user: store.state.userState.user,
      community: store.state.walletState.community,
      transactions: store.state.walletState.transactions,
      businesses: store.state.walletState.businesses,
      initWallet: (context) {
        store.dispatch(initWalletCall(context));
      },
      sendTransaction: (context, address, amount) {
        store.dispatch(sendTransactionCall(context, address, amount));
      },
      loadBusinesses: () {
        store.dispatch(loadBusinessesCall());
      },
      switchCommunity: (address) {
        store.dispatch(switchCommunityCall(address));
      }
    );
  }
}
