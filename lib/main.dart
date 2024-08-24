import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Coin Live By Magesh Varan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CryptoStream(),
    );
  }
}

class CryptoStream extends StatefulWidget {
  @override
  _CryptoStreamState createState() => _CryptoStreamState();
}

class _CryptoStreamState extends State<CryptoStream> {
  late WebSocketChannel channel;
  Map<String, String> _cryptoPrices = {
    "BTCUSDT": '',
    "ETHUSDT": '',
    "BNBUSDT": '',
  };

  final Queue<String> _messageQueue = Queue();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Establish WebSocket connection
    channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://fstream.binance.com/stream?streams=btcusdt@aggTrade/ethusdt@aggTrade/bnbusdt@aggTrade'),
    );

    // Send subscription message
    channel.sink.add(jsonEncode({
      "method": "SUBSCRIBE",
      "params": [
        "btcusdt@aggTrade",
        "ethusdt@aggTrade",
        "bnbusdt@aggTrade",
      ],
      "id": 1,
    }));

    // Listen to WebSocket messages
    channel.stream.listen(
      (message) {
        _messageQueue.add(message); // Add incoming message to the queue
        _processQueue(); // Start processing the queue
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
      onDone: () {
        print("WebSocket Closed");
      },
    );
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return; // Prevent multiple processing at the same time
    _isProcessing = true;

    while (_messageQueue.isNotEmpty) {
      final message =
          _messageQueue.removeFirst(); // Get the next message from the queue
      final data = jsonDecode(message); // Parse the message as JSON

      // Check if the stream is one we are interested in
      if (data['stream'] == 'btcusdt@aggTrade' ||
          data['stream'] == 'ethusdt@aggTrade' ||
          data['stream'] == 'bnbusdt@aggTrade') {
        // Extract the price
        final price = data['data']['p'];
        final symbol = data['data']['s'];

        setState(() {
          _cryptoPrices[symbol] = price; // Update the crypto price
        });
        print('$symbol Price: $price'); // Print the crypto price
      }

      await Future.delayed(
          Duration(milliseconds: 500)); // Delay of 500 milliseconds
    }

    _isProcessing = false; // Mark processing as complete
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

// gdsgf
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto Coin Live By Magesh Varan"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Crypto Prices:",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'BTCUSDT: ${_cryptoPrices["BTCUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["BTCUSDT"]}',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 16),
              Text(
                'ETHUSDT: ${_cryptoPrices["ETHUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["ETHUSDT"]}',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 16),
              Text(
                'BNBUSDT: ${_cryptoPrices["BNBUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["BNBUSDT"]}',
                style: TextStyle(fontSize: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
