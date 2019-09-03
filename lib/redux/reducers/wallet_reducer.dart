
import 'package:fusewallet/modals/community.dart';
import 'package:fusewallet/modals/transactions.dart';
import 'package:fusewallet/redux/actions/wallet_actions.dart';
import 'package:fusewallet/redux/state/wallet_state.dart';
import 'package:redux/redux.dart';

final walletReducer = combineReducers<WalletState>([
  TypedReducer<WalletState, CommunityLoadedAction>(_communityLoaded),
  TypedReducer<WalletState, BalanceLoadedAction>(_balanceLoaded),
  TypedReducer<WalletState, TransactionsLoadedAction>(_transactionsLoaded),
  TypedReducer<WalletState, StartLoadingAction>(_startLoading),
  TypedReducer<WalletState, TransactionSentAction>(_transactionSentAction),
  TypedReducer<WalletState, BusinessesLoadedAction>(_businessesLoadedAction),
  TypedReducer<WalletState, SwitchCommunityAction>(_switchCommunityAction),
  TypedReducer<WalletState, WalletLoadedAction>(_walletLoadedAction),
  TypedReducer<WalletState, LogoutAction>(_loagoutAction),
  TypedReducer<WalletState, SendStepAction>(_sendStepAction),
]);

WalletState _communityLoaded(WalletState state, CommunityLoadedAction action) {
  return state.copyWith(community: Nullable<Community>(action.community), tokenAddress: action.tokenAddress);
}

WalletState _balanceLoaded(WalletState state, BalanceLoadedAction action) {
  return state.copyWith(balance: action.balance);
}

WalletState _transactionsLoaded(WalletState state, TransactionsLoadedAction action) {
  return state.copyWith(transactions: Nullable<TransactionList>(action.transactions));
}

WalletState _startLoading(WalletState state, StartLoadingAction action) {
  return state.copyWith(isLoading: true);
}

WalletState _transactionSentAction(WalletState state, TransactionSentAction action) {
  return state.copyWith(isLoading: false);
}

WalletState _businessesLoadedAction(WalletState state, BusinessesLoadedAction action) {
  return state.copyWith(isLoading: false, businesses: action.businessList);
}

WalletState _switchCommunityAction(WalletState state, SwitchCommunityAction action) {
  return state.copyWith(isLoading: false, tokenAddress: action.address);
}

WalletState _walletLoadedAction(WalletState state, WalletLoadedAction action) {
  return state.copyWith(isLoading: false);
}

WalletState _loagoutAction(WalletState state, LogoutAction action) {
  return state.copyWith(community: Nullable<Community>(null), balance: "0", transactions: Nullable<TransactionList>(null), tokenAddress: "", sendAddress: "", sendAmount: 0, sendStep: "amount");
}

WalletState _sendStepAction(WalletState state, SendStepAction action) {
  return state.copyWith(sendStep: action.step);
}