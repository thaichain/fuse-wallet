import 'dart:convert';
import 'dart:async';
import 'package:absinthe_socket/absinthe_socket.dart';
import 'package:flutter/foundation.dart';
import 'package:fusewallet/modals/businesses.dart';
import 'package:fusewallet/modals/community.dart';
import 'package:fusewallet/modals/transactions.dart';
import 'package:fusewallet/modals/user.dart';
import 'package:fusewallet/modals/token.dart';
import 'package:web3dart/web3dart.dart' as web3dart;
import 'crypto_service.dart';
import 'package:http/http.dart' as http;
import "package:web3dart/src/utils/numbers.dart" as numbers;
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const DEFAULT_TOKEN_ADDRESS = '0xE10c6f106426c0996e58a2f31dB47FCcfC01e5bf';
const DEFAULT_ENV = 'qa'; //CHANGE WHEN DEPLOY DAPP TO PROD
const DEFAULT_ORIGIN_NETWORK = 'ropsten';
//const API_ROOT = 'https://studio{env}{originNetwork}.fusenet.io/api/v1/';
const EXPLORER_ROOT = 'http://exp.tch.in.th/api';
const API_FUNDER = 'https://funder{env}.fusenet.io/api';

parseAPIRoot(String path, env, originNetwork) {
  var _path = path;
  _path = _path.replaceAll("{env}", env == 'qa' ? '-qa' : '');
  _path = _path.replaceAll(
      "{originNetwork}", originNetwork == 'ropsten' ? '-ropsten' : '');
  print(_path);
  return _path;
}

parseFunderAPIRoot(String path, env) {
  var _path = path;
  _path = _path.replaceAll("{env}", env == 'qa' ? '-qa' : '');
  print(_path);
  return _path;
}

Future generateWallet(User user) async {
  String mnemonic = "";
  if (user == null) {
    user = new User();
  }
  if (user.mnemonic != null) {
    mnemonic = user.mnemonic;
  } else {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: 'mnemonic');
    if (value != null) {
      mnemonic = value;
    } else {
      mnemonic = generateMnemonic();
    }
  }
  print(mnemonic);
  user.mnemonic = mnemonic;
  user.privateKey = await compute(getPrivateKeyFromMnemonic, mnemonic);
  user.publicKey = await getPublickKey(user.privateKey);

  //Call funder
  //fundNative(user.publicKey, DEFAULT_ENV);

  return user;
}

Future fundNative(accountAddress, env) async {
  print("requesting native funding for account $accountAddress");
  var body = '{ "accountAddress": "$accountAddress"}';

  return await http.post(
      Uri.encodeFull("${parseFunderAPIRoot(API_FUNDER, env)}/fund/native"),
      body: body,
      headers: {
        "Content-Type": "application/json"
      }).then((http.Response response) {
    print('native funding for account $accountAddress succeeded');
  });
}

Future fundToken(accountAddress, tokenAddress, env, originNetwork) async {
  print(
      "requesting token funding of $tokenAddress for account $accountAddress ");
  var body =
      '{ "accountAddress": "$accountAddress", "tokenAddress": "$tokenAddress", "originNetwork": "$originNetwork" }';

  return await http.post(
      Uri.encodeFull("${parseFunderAPIRoot(API_FUNDER, env)}/fund/token"),
      body: body,
      headers: {
        "Content-Type": "application/json"
      }).then((http.Response response) {
    print(
        'token funding of $tokenAddress for account $accountAddress succeeded');
  });
}

Future getCommunity(tokenAddress, env, originNetwork) async {
  print('Fetching community data by the token address: $tokenAddress');
  var body =
      ' {"data":{"_id":"5d74a44da520a30011ce6396","isClosed":false,"communityAddress":"0xbA01716EAD7989a00cC3b2AE6802b54eaF40fb72","homeTokenAddress":"0xE10c6f106426c0996e58a2f31dB47FCcfC01e5bf","foreignTokenAddress":"0xC05B60cCAaa9989E406cb58ad19c98dDaA996D84","foreignBridgeAddress":"0xdbb95f2b9E400C04e24FEE0b235138fbD527Bfec","homeBridgeAddress":"0xe541BBF61e5FD71205F88AC404C85E8871027935","__v":0,"plugins":{"businessList":{"isActive":true},"joinBonus":{"isActive":true,"hasTransferToFunder":true,"joinInfo":{"message":"Welcome to the Fat Fuse Unicorn Community! Here are some free FFU to get you started🦄 🌈 ","amount":"10"}}},"name":"Fat Fuse Unicorn 🦄 "}}';
  Map<String, dynamic> obj = json.decode(body);
  if (obj["data"] == null) {
    throw new Exception("No token information found");
  }
  var community = Community.fromJson(obj["data"]);
  print('Done fetching community data for $tokenAddress');
  return community;
}

Future getToken(tokenAddress, env, originNetwork) async {
  var body =
      '{"data":{"_id":"5d74a412a520a30011ce6391","address":"0xE10c6f106426c0996e58a2f31dB47FCcfC01e5bf","factoryAddress":"0xb895638fb3870AD5832402a5BcAa64A044687db0","blockNumber":669620,"tokenType":"basic","networkType":"fuse","name":"Fat Fuse Unicorn 🦄 ","symbol":"FFU","totalSupply":"0","createdAt":"2019-09-08T06:47:46.170Z","updatedAt":"2019-09-08T06:48:45.333Z","tokenURI":"ipfs://Qmc1WwfAweQgjjS1YSwrAeaHcFgiSNiqEoZFZsXeFr54Wo","owner":"0xAde4785c5B5699E25B1E345d708be6295CDce938"}}';
  Map<String, dynamic> obj = json.decode(body);
  if (obj["data"] == null) {
    throw new Exception("No token information found");
  }
  var token = Token.fromJson(obj["data"]);
  print('Done fetching token data for $tokenAddress');
  return token;
}

Future<String> getBalance(accountAddress, tokenAddress) async {
  var uri = Uri.encodeFull(EXPLORER_ROOT +
      '/address/$accountAddress/owned_tokens?limit=100&skip=0&onlycontractaddress=$tokenAddress');
  var response = await http.get(uri);
  print(uri);

  var result = json.decode(response.body);
  //var balance = (result['owned_tokens'][0]['balance']);

  if (result['owned_tokens'] == null) {
    return "0";
  }
  var balance =
      (BigInt.parse(result['owned_tokens'][0]['balance']) / BigInt.from(1))
          .toStringAsFixed(1);
  print(
      'Fetching balance of token $tokenAddress for account $accountAddress done. balance: $balance');
  return balance;
}

Future<TransactionList> getTransactions(accountAddress, tokenAddress) async {
  print(
      'Fetching transactions of token $tokenAddress for account $accountAddress done.');
  var uri =
      '${EXPLORER_ROOT}/address/$accountAddress/internal_transactions?limit=200&skip=0&token_transactions=true&onlycontractaddress=$tokenAddress';
  print(uri);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return TransactionList.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load transaction');
  }
}

Future<List<Business>> getBusinesses(
    communityAddress, env, originNetwork) async {
  print('Fetching businesses for commnuity: $communityAddress');

  List<Business> businessList = new List();

  return businessList;
}

const String _URL = "https://rpc.tch.in.th";
const String _ABI_EXTRACT =
    '[ { "constant": true, "inputs": [], "name": "name", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_spender", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "approve", "outputs": [ { "name": "success", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "totalSupply", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_tokenContract", "type": "address" } ], "name": "withdrawAltcoinTokens", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_from", "type": "address" }, { "name": "_to", "type": "address" }, { "name": "_amount", "type": "uint256" } ], "name": "transferFrom", "outputs": [ { "name": "success", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "decimals", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [], "name": "withdraw", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_value", "type": "uint256" } ], "name": "burn", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_participant", "type": "address" }, { "name": "_amount", "type": "uint256" } ], "name": "adminClaimAirdrop", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_addresses", "type": "address[]" }, { "name": "_amount", "type": "uint256" } ], "name": "adminClaimAirdropMultiple", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "_owner", "type": "address" } ], "name": "balanceOf", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "symbol", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [], "name": "finishDistribution", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_tokensPerEth", "type": "uint256" } ], "name": "updateTokensPerEth", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_to", "type": "address" }, { "name": "_amount", "type": "uint256" } ], "name": "transfer", "outputs": [ { "name": "success", "type": "bool" } ], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": false, "inputs": [], "name": "getTokens", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": true, "inputs": [], "name": "minContribution", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "distributionFinished", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "tokenAddress", "type": "address" }, { "name": "who", "type": "address" } ], "name": "getTokenBalance", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "tokensPerEth", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "_owner", "type": "address" }, { "name": "_spender", "type": "address" } ], "name": "allowance", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "totalDistributed", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnership", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "_from", "type": "address" }, { "indexed": true, "name": "_to", "type": "address" }, { "indexed": false, "name": "_value", "type": "uint256" } ], "name": "Transfer", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "_owner", "type": "address" }, { "indexed": true, "name": "_spender", "type": "address" }, { "indexed": false, "name": "_value", "type": "uint256" } ], "name": "Approval", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "to", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" } ], "name": "Distr", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [], "name": "DistrFinished", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "_owner", "type": "address" }, { "indexed": false, "name": "_amount", "type": "uint256" }, { "indexed": false, "name": "_balance", "type": "uint256" } ], "name": "Airdrop", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "_tokensPerEth", "type": "uint256" } ], "name": "TokensPerEthUpdated", "type": "event", "stateMutability": "view" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "burner", "type": "address" }, { "indexed": false, "name": "value", "type": "uint256" } ], "name": "Burn", "type": "event", "stateMutability": "view" } ]';

Future sendTransaction(address, amount, tokenAddress, privateKey) async {
  var httpClient = new Client();
  var ethClient = new web3dart.Web3Client(_URL, httpClient);

  var credentials = web3dart.Credentials.fromPrivateKeyHex(privateKey);
  var contractABI = web3dart.ContractABI.parseFromJSON(_ABI_EXTRACT, "XTEST");
  var contract = new web3dart.DeployedContract(contractABI,
      new web3dart.EthereumAddress(tokenAddress), ethClient, credentials);

  var getKittyFn = contract.findFunctionsByName("transfer").first;
  address = cleanAddress(address);
  var n = BigInt.parse(numbers.strip0x(address), radix: 16);

  try {
    var response = await new web3dart.Transaction(
            keys: credentials,
            maximumGas: 1350000,
            gasPrice: web3dart.EtherAmount.fromUnitAndValue(
                web3dart.EtherUnit.gwei, 5))
        .prepareForPaymentCall(
            contract,
            getKittyFn,
            [n, BigInt.from(amount) * BigInt.from(1)],
            web3dart.EtherAmount.zero())
        .send(ethClient, chainId: 7);

    return "000";
  } catch (e) {
    return e.toString();
  }
}

String cleanAddress(address) {
  address = address.toString().replaceAll("ethereum:", "");
  return address;
}

initSocket(_onStart) async {
  var _socket = AbsintheSocket("wss://explorer.fusenet.io/socket/websocket");
  Observer _categoryObserver = Observer(
    //onAbort: _onStart,
    //onCancel: _onStart,
    //onError: _onStart,
    onResult: _onStart,
    //onStart: _onStart
  );

  Notifier notifier = _socket.send(GqlRequest(
      operation:
          "subscription { tokenTransfers(tokenContractAddressHash: \"0x415c11223bca1324f470cf72eac3046ea1e755a3\") { amount, fromAddressHash, toAddressHash }}"));
  notifier.observe(_categoryObserver);
}
