import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:new_learn/Secondpage.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Crypto Live',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/homepage': (context) => CryptoStream(),
        '/Secondpage': (context) => Secondpage(),
        // '/secondpage': (context) => Seconpage(),
      },
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

// sdf
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
          Duration(milliseconds: 1000)); // Delay of 500 milliseconds
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
        title: Text("Boulty Trading"),
        backgroundColor: Color(0xFFD4CAA2),
        actions: [
          IconButton(
            onPressed: () {
              print("clicked");
            },
            icon: Icon(
              Icons.account_circle_rounded,
              size: 24,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1,
          color: Color(0xFFD4CAA2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFABA272),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'BTCUSDT',
                                style: TextStyle(
                                  color: Color(0xFF5C542C),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${_cryptoPrices["BTCUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["BTCUSDT"]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5c542c),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16), // Add space between containers
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFABA272),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'ETHUSDT',
                                style: TextStyle(
                                  color: Color(0xFF5c542c),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${_cryptoPrices["ETHUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["ETHUSDT"]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5c542c),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 26),
                Text(
                  'BNBUSDT: ${_cryptoPrices["BNBUSDT"]?.isEmpty == true ? 'Waiting for data...' : _cryptoPrices["BNBUSDT"]}',
                  style: TextStyle(fontSize: 32),
                ),
                Image.asset(
                  'assets/163434.jpg',
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
                ElevatedButton(
                  // Within the `FirstRoute` widget:
                  onPressed: () {
                    Navigator.pushNamed(context, '/Secondpage');
                  },
                  child: Text("go to next"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
