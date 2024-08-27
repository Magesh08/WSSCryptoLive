import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;
  String _receivedMessage = '';

  @override
  void initState() {
    super.initState();
    // Establish WebSocket connection
    channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.org'), // Replace with your WebSocket URL
    );

    //build

    // Listen to WebSocket messages
    channel.stream.listen(
      (message) {
        setState(() {
          _receivedMessage = message;
        });
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
      onDone: () {
        print("WebSocket Closed");
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.yellowAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("hi"),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/second'); // Navigate to second page
                },
                child: Text("Go to Second Page"),
              ),
              Container(
                height: 50,
                width: 30,
                color: Colors.black38,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(labelText: 'Send a message'),
                    ),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: Text("Send Message"),
                    ),
                    SizedBox(height: 24),
                    Text(
                      _receivedMessage.isEmpty
                          ? 'Waiting for response...'
                          : 'Received: $_receivedMessage',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
