import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Transaction {
  final String value;
  final String to;
  final String from;
  final String hash;
  final String timeStamp;
  final String tokenSymbol;
  final DateTime date;
  final double amount;
  final bool pending;

  Transaction(
      {this.value,
      this.to,
      this.from,
      this.hash,
      this.timeStamp,
      this.tokenSymbol,
      this.date,
      this.amount,
      this.pending});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.parse(json['created_at']);
    return Transaction(
        value: json['value'],
        to: json['to_address'],
        from: json['from_address'],
        hash: json['hash'],
        //timeStamp: json['timeStamp'],
        tokenSymbol: 'XSEGA',
        pending: false,
        date: json['created_at'] != null ? date : null,
        amount: json['value'] != null
//            ? BigInt.tryParse(json['value']) / BigInt.from(100)
            ? BigInt.tryParse(json['value']) / BigInt.from(1)
            : null);
  }

  dynamic toJson() => {
        'value': value,
        'to': to,
        'from': from,
        'hash': hash,
        'timeStamp': timeStamp,
        'tokenSymbol': tokenSymbol,
        'date': date.millisecondsSinceEpoch.toString(),
        'amount': amount
      };
}

class TransactionList {
  final List<Transaction> transactions;
  List<Transaction> pendingTransactions;

  TransactionList({this.transactions, this.pendingTransactions});

  factory TransactionList.fromJson(Map<String, dynamic> json) {
    if (json['internal_transactions'] == null) {
      return null;
    }
    var list = json['internal_transactions'] as List;
    List<Transaction> transactions = new List<Transaction>();
    transactions = list.map((i) => Transaction.fromJson(i)).toList();

    return new TransactionList(
        transactions: transactions,
        pendingTransactions: new List<Transaction>());
  }

  factory TransactionList.fromJsonState(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    var list = json['transactions'] as List;

    List<Transaction> transactions = new List<Transaction>();
    transactions = list.map((i) => Transaction.fromJson(i)).toList();

    return new TransactionList(
        transactions: transactions,
        pendingTransactions: new List<Transaction>());
  }

  dynamic toJson() => {'transactions': transactions};
}
