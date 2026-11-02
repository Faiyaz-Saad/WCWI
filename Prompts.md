<h1>A S M Hossain Mahmmud Shadhin (68)  <b>Networking</b></h1> 

<ol>
  <li>এই অ্যাপ্লিকেশনের সকল ইউজার ইন্টারফেস (UI) টেক্সট, লেবেল, মেসেজ, বাটন, মেনু এবং অন্যান্য সকল দৃশ্যমান উপাদান শুধুমাত্র ইংরেজিতে থাকবে। অ্যাপের মধ্যে কোনো বাংলা ভাষার টেক্সট ব্যবহার করা যাবে না।

---

## ডেভেলপারের দায়িত্ব

আপনার দায়িত্ব হলো WCWI (Wireless Communication Without Internet) অ্যাপের সম্পূর্ণ নেটওয়ার্কিং লজিক, সার্ভার-ক্লায়েন্ট আর্কিটেকচার এবং মেসেজিং সার্ভিস ডেভেলপ করা। আপনাকে Wi-Fi এবং Bluetooth দুটি মোডেই সংযোগ স্থাপন এবং মেসেজ আদান-প্রদান বাস্তবায়ন করতে হবে।

---

## ১. টেকনোলজি স্ট্যাক

•⁠  ⁠*ফ্রেমওয়ার্ক:* Flutter
•⁠  ⁠*ভাষা:* Dart
•⁠  ⁠*Wi-Fi নেটওয়ার্কিং:* WebSocket (web_socket প্যাকেজ)
•⁠  ⁠*Bluetooth নেটওয়ার্কিং:* flutter_bluetooth_serial বা flutter_blue
•⁠  ⁠*স্টেট ম্যানেজমেন্ট:* Provider বা Riverpod
•⁠  ⁠*অ্যাসিঙ্ক্রোনাস প্রোগ্রামিং:* async/await, Future, Stream

---

## ২. সিস্টেম আর্কিটেকচার

### ২.১. সার্ভার-ক্লায়েন্ট মডেল

এই অ্যাপটি একটি সার্ভার-ক্লায়েন্ট আর্কিটেকচার ব্যবহার করবে:
•⁠  ⁠একটি ডিভাইস সার্ভার হিসেবে কাজ করবে
•⁠  ⁠এক বা একাধিক ডিভাইস ক্লায়েন্ট হিসেবে সার্ভারের সাথে সংযুক্ত হবে
•⁠  ⁠সার্ভার মেসেজ ব্রডকাস্ট করবে এবং ক্লায়েন্টরা মেসেজ গ্রহণ করবে

### ২.২. কম্পোনেন্ট স্ট্রাকচার


lib/
├── services/
│   ├── connection_manager.dart
│   ├── wifi_service.dart
│   ├── bluetooth_service.dart
│   └── messaging_service.dart
├── models/
│   ├── message.dart
│   └── device_info.dart
└── utils/
    ├── network_utils.dart
    └── ip_utils.dart


---

## ৩. Wi-Fi নেটওয়ার্কিং

### ৩.১. WebSocket সার্ভার ইমপ্লিমেন্টেশন

*ফাইল নাম:* ⁠ wifi_service.dart ⁠

*সার্ভার মোড:*

⁠ dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';

class WiFiService {
  WebSocketChannel? _serverChannel;
  List<WebSocketChannel> _clients = [];
  bool _isServerRunning = false;
  
  // সার্ভার চালু করা
  Future<void> startServer(int port) async {
    try {
      final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _isServerRunning = true;
      
      server.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            final channel = WebSocketChannel(socket);
            _clients.add(channel);
            
            // নতুন ক্লায়েন্ট সংযুক্ত হলে
            _broadcastMessage({
              'type': 'client_joined',
              'clientId': _clients.length.toString(),
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // ক্লায়েন্ট থেকে মেসেজ গ্রহণ
            channel.stream.listen((message) {
              _handleServerMessage(message, channel);
            }, onDone: () {
              _clients.remove(channel);
            });
          });
        }
      });
      
      print('Server started on port $port');
    } catch (e) {
      print('Error starting server: $e');
      _isServerRunning = false;
    }
  }
  
  // সার্ভার বন্ধ করা
  void stopServer() {
    for (var client in _clients) {
      client.sink.close();
    }
    _clients.clear();
    _serverChannel?.sink.close();
    _isServerRunning = false;
  }
  
  // মেসেজ ব্রডকাস্ট করা
  void _broadcastMessage(Map<String, dynamic> message) {
    for (var client in _clients) {
      client.sink.add(message);
    }
  }
  
  // সার্ভার থেকে মেসেজ হ্যান্ডেল করা
  void _handleServerMessage(dynamic message, WebSocketChannel senderChannel) {
    final decodedMessage = message is String ? message : message.toString();
    
    // সকল ক্লায়েন্টে ব্রডকাস্ট করা (প্রেরক ছাড়া)
    for (var client in _clients) {
      if (client != senderChannel) {
        client.sink.add(decodedMessage);
      }
    }
  }
  
  // সার্ভার চলছে কি না
  bool get isServerRunning => _isServerRunning;
  
  // সংযুক্ত ক্লায়েন্ট সংখ্যা
  int get connectedClientsCount => _clients.length;
}
 ⁠

*ক্লায়েন্ট মোড:*

⁠ dart
class WiFiService {
  WebSocketChannel? _clientChannel;
  bool _isConnected = false;
  
  // সার্ভারের সাথে সংযুক্ত হওয়া
  Future<void> connectToServer(String serverIP, int port) async {
    try {
      final uri = 'ws://$serverIP:$port';
      _clientChannel = WebSocketChannel.connect(Uri.parse(uri));
      _isConnected = true;
      
      // সার্ভার থেকে মেসেজ গ্রহণ
      _clientChannel!.stream.listen((message) {
        _handleClientMessage(message);
      }, onDone: () {
        _isConnected = false;
      }, onError: (error) {
        _isConnected = false;
        print('Connection error: $error');
      });
      
      print('Connected to server: $uri');
    } catch (e) {
      print('Error connecting to server: $e');
      _isConnected = false;
    }
  }
  
  // সার্ভার থেকে মেসেজ হ্যান্ডেল করা
  void _handleClientMessage(dynamic message) {
    final decodedMessage = message is String ? message : message.toString();
    // মেসেজ প্রসেস করা এবং UI তে পাঠানো
    // এটি MessagingService এর মাধ্যমে করা হবে
  }
  
  // সার্ভারে মেসেজ পাঠানো
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _clientChannel != null) {
      _clientChannel!.sink.add(message);
    }
  }
  
  // সংযোগ বিচ্ছিন্ন করা
  void disconnect() {
    _clientChannel?.sink.close();
    _isConnected = false;
  }
  
  // সংযুক্ত আছে কি না
  bool get isConnected => _isConnected;
}
 ⁠

### ৩.২. IP অ্যাড্রেস ডিটেকশন

*ফাইল নাম:* ⁠ ip_utils.dart ⁠

⁠ dart
import 'dart:io';

class IPUtils {
  // লোকাল IP অ্যাড্রেস পাওয়া
  static Future<String> getLocalIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: NetworkInterfaceType.any,
      );
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
      
      return '192.168.1.100'; // Default IP
    } catch (e) {
      print('Error getting IP address: $e');
      return '192.168.1.100'; // Default IP
    }
  }
  
  // Wi-Fi সংযুক্ত আছে কি না চেক করা
  static Future<bool> isWiFiConnected() async {
    // প্ল্যাটফর্ম স্পেসিফিক ইমপ্লিমেন্টেশন
    // Android এর জন্য connectivity_plus প্যাকেজ ব্যবহার করা যেতে পারে
    return true; // Simplified
  }
}
 ⁠

---

## ৪. Bluetooth নেটওয়ার্কিং

### ৪.১. Bluetooth সার্ভার ইমপ্লিমেন্টেশন

*ফাইল নাম:* ⁠ bluetooth_service.dart ⁠

⁠ dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  bool _isServerRunning = false;
  bool _isConnected = false;
  
  // Bluetooth সার্ভার চালু করা
  Future<void> startServer() async {
    try {
      // ডিভাইসের নাম সেট করা
      await FlutterBluetoothSerial.instance.requestEnableBluetooth();
      
      // ডিভাইস discoverable করা
      await FlutterBluetoothSerial.instance.requestDiscoverable(300);
      
      _isServerRunning = true;
      print('Bluetooth server started');
      
      // ইনকামিং কানেকশন লিসেন করা
      FlutterBluetoothSerial.instance.onDeviceConnected().listen((device) {
        _handleIncomingConnection(device);
      });
      
    } catch (e) {
      print('Error starting Bluetooth server: $e');
      _isServerRunning = false;
    }
  }
  
  // ইনকামিং কানেকশন হ্যান্ডেল করা
  void _handleIncomingConnection(BluetoothDevice device) {
    print('Device connected: ${device.name}');
    _isConnected = true;
    
    // কানেকশন স্থাপন করা
    BluetoothConnection.toAddress(device.address).then((connection) {
      _connection = connection;
      
      // মেসেজ গ্রহণ
      connection.input?.listen((data) {
        _handleBluetoothMessage(data);
      }, onDone: () {
        _isConnected = false;
      });
    });
  }
  
  // Bluetooth সার্ভার বন্ধ করা
  void stopServer() {
    _connection?.close();
    _isServerRunning = false;
    _isConnected = false;
  }
  
  // Bluetooth মেসেজ হ্যান্ডেল করা
  void _handleBluetoothMessage(String message) {
    // মেসেজ প্রসেস করা এবং UI তে পাঠানো
  }
  
  // সার্ভার চলছে কি না
  bool get isServerRunning => _isServerRunning;
  
  // সংযুক্ত আছে কি না
  bool get isConnected => _isConnected;
}
 ⁠

### ৪.২. Bluetooth ক্লায়েন্ট ইমপ্লিমেন্টেশন

⁠ dart
class BluetoothService {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  
  // উপলব্ধ ডিভাইস সার্চ করা
  Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnableBluetooth();
      
      List<BluetoothDevice> devices = [];
      
      // Paired devices
      final pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      devices.addAll(pairedDevices);
      
      // Unpaired devices (discover)
      FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
        if (!devices.contains(device)) {
          devices.add(device);
        }
      });
      
      return devices;
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }
  
  // নির্দিষ্ট ডিভাইসের সাথে সংযুক্ত হওয়া
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      
      // মেসেজ গ্রহণ
      _connection!.input?.listen((data) {
        _handleBluetoothMessage(data);
      }, onDone: () {
        _isConnected = false;
      }, onError: (error) {
        _isConnected = false;
        print('Connection error: $error');
      });
      
      print('Connected to device: ${device.name}');
    } catch (e) {
      print('Error connecting to device: $e');
      _isConnected = false;
    }
  }
  
  // Bluetooth মেসেজ হ্যান্ডেল করা
  void _handleBluetoothMessage(String message) {
    // মেসেজ প্রসেস করা এবং UI তে পাঠানো
  }
  
  // ডিভাইসে মেসেজ পাঠানো
  void sendMessage(String message) {
    if (_isConnected && _connection != null) {
      _connection!.output.add(UTF8.encode(message));
    }
  }
  
  // সংযোগ বিচ্ছিন্ন করা
  void disconnect() {
    _connection?.close();
    _isConnected = false;
  }
  
  // সংযুক্ত আছে কি না
  bool get isConnected => _isConnected;
}
 ⁠

---

## ৫. মেসেজিং সার্ভিস

### ৫.১. মেসেজ মডেল

*ফাইল নাম:* ⁠ message.dart ⁠

⁠ dart
class Message {
  final String id;
  final String content;
  final MessageType type;
  final MessageDirection direction;
  final DateTime timestamp;
  final String? senderDeviceName;
  final String? filePath; // ছবি বা ভয়েস ফাইলের জন্য
  
  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.senderDeviceName,
    this.filePath,
  });
  
  // JSON থেকে Message তৈরি করা
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      direction: MessageDirection.values.firstWhere(
        (e) => e.toString() == json['direction'],
        orElse: () => MessageDirection.sent,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      senderDeviceName: json['senderDeviceName'],
      filePath: json['filePath'],
    );
  }
  
  // Message থেকে JSON তৈরি করা
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString(),
      'direction': direction.toString(),
      'timestamp': timestamp.toIso8601String(),
      'senderDeviceName': senderDeviceName,
      'filePath': filePath,
    };
  }
}

enum MessageType {
  text,
  image,
  voice,
}

enum MessageDirection {
  sent,
  received,
}
 ⁠

### ৫.২. মেসেজিং সার্ভিস

*ফাইল নাম:* ⁠ messaging_service.dart ⁠

⁠ dart
import 'dart:convert';
import 'package:uuid/uuid.dart';

class MessagingService {
  final WiFiService _wifiService;
  final BluetoothService _bluetoothService;
  final List<Message> _messages = [];
  final Function(Message) _onMessageReceived;
  
  MessagingService({
    required WiFiService wifiService,
    required BluetoothService bluetoothService,
    required Function(Message) onMessageReceived,
  }) : _wifiService = wifiService,
       _bluetoothService = bluetoothService,
       _onMessageReceived = onMessageReceived;
  
  // টেক্সট মেসেজ পাঠানো
  void sendTextMessage(String content, String senderDeviceName) {
    final message = Message(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.text,
      direction: MessageDirection.sent,
      timestamp: DateTime.now(),
      senderDeviceName: senderDeviceName,
    );
    
    _messages.add(message);
    _sendMessageToNetwork(message);
  }
  
  // ছবি মেসেজ পাঠানো
  void sendImageMessage(String filePath, String senderDeviceName) {
    final message = Message(
      id: const Uuid().v4(),
      content: 'Image',
      type: MessageType.image,
      direction: MessageDirection.sent,
      timestamp: DateTime.now(),
      senderDeviceName: senderDeviceName,
      filePath: filePath,
    );
    
    _messages.add(message);
    _sendMessageToNetwork(message);
  }
  
  // ভয়েস মেসেজ পাঠানো
  void sendVoiceMessage(String filePath, String senderDeviceName) {
    final message = Message(
      id: const Uuid().v4(),
      content: 'Voice',
      type: MessageType.voice,
      direction: MessageDirection.sent,
      timestamp: DateTime.now(),
      senderDeviceName: senderDeviceName,
      filePath: filePath,
    );
    
    _messages.add(message);
    _sendMessageToNetwork(message);
  }
  
  // নেটওয়ার্কে মেসেজ পাঠানো
  void _sendMessageToNetwork(Message message) {
    final jsonMessage = jsonEncode(message.toJson());
    
    if (_wifiService.isConnected) {
      _wifiService.sendMessage({
        'type': 'message',
        'data': jsonMessage,
      });
    } else if (_bluetoothService.isConnected) {
      _bluetoothService.sendMessage(jsonMessage);
    }
  }
  
  // নেটওয়ার্ক থেকে মেসেজ গ্রহণ
  void receiveMessage(String jsonMessage) {
    final decoded = jsonDecode(jsonMessage);
    final message = Message.fromJson(decoded);
    
    message = Message(
      id: message.id,
      content: message.content,
      type: message.type,
      direction: MessageDirection.received,
      timestamp: message.timestamp,
      senderDeviceName: message.senderDeviceName,
      filePath: message.filePath,
    );
    
    _messages.add(message);
    _onMessageReceived(message);
  }
  
  // সকল মেসেজ পাওয়া
  List<Message> get messages => List.unmodifiable(_messages);
  
  // মেসেজ ডিলিট করা
  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
  }
  
  // সকল মেসেজ ডিলিট করা
  void deleteAllMessages() {
    _messages.clear();
  }
}
 ⁠

---

## ৬. কানেকশন ম্যানেজার

*ফাইল নাম:* ⁠ connection_manager.dart ⁠

⁠ dart
enum ConnectionType {
  wifi,
  bluetooth,
  none,
}

class ConnectionManager {
  final WiFiService _wifiService;
  final BluetoothService _bluetoothService;
  ConnectionType _currentConnectionType = ConnectionType.none;
  
  ConnectionManager({
    required WiFiService wifiService,
    required BluetoothService bluetoothService,
  }) : _wifiService = wifiService,
       _bluetoothService = bluetoothService;
  
  // Wi-Fi সার্ভার চালু করা
  Future<void> startWiFiServer(int port) async {
    await _wifiService.startServer(port);
    _currentConnectionType = ConnectionType.wifi;
  }
  
  // Wi-Fi ক্লায়েন্ট হিসেবে সংযুক্ত হওয়া
  Future<void> connectAsWiFiClient(String serverIP, int port) async {
    await _wifiService.connectToServer(serverIP, port);
    _currentConnectionType = ConnectionType.wifi;
  }
  
  // Bluetooth সার্ভার চালু করা
  Future<void> startBluetoothServer() async {
    await _bluetoothService.startServer();
    _currentConnectionType = ConnectionType.bluetooth;
  }
  
  // Bluetooth ক্লায়েন্ট হিসেবে সংযুক্ত হওয়া
  Future<void> connectAsBluetoothClient(BluetoothDevice device) async {
    await _bluetoothService.connectToDevice(device);
    _currentConnectionType = ConnectionType.bluetooth;
  }
  
  // সংযোগ বিচ্ছিন্ন করা
  void disconnect() {
    if (_currentConnectionType == ConnectionType.wifi) {
      _wifiService.disconnect();
    } else if (_currentConnectionType == ConnectionType.bluetooth) {
      _bluetoothService.disconnect();
    }
    _currentConnectionType = ConnectionType.none;
  }
  
  // বর্তমান কানেকশন টাইপ
  ConnectionType get currentConnectionType => _currentConnectionType;
  
  // সংযুক্ত আছে কি না
  bool get isConnected {
    if (_currentConnectionType == ConnectionType.wifi) {
      return _wifiService.isConnected;
    } else if (_currentConnectionType == ConnectionType.bluetooth) {
      return _bluetoothService.isConnected;
    }
    return false;
  }
}
 ⁠

---

## ৭. ডিভাইস ইনফরমেশন

*ফাইল নাম:* ⁠ device_info.dart ⁠

⁠ dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  // ডিভাইসের নাম পাওয়া
  Future<String> getDeviceName() async {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model ?? 'Unknown Device';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model ?? 'Unknown Device';
      }
      return 'Unknown Device';
    } catch (e) {
      print('Error getting device name: $e');
      return 'Unknown Device';
    }
  }
}
 ⁠

---

## ৮. এরর হ্যান্ডলিং

### ৮.১. নেটওয়ার্ক এরর

⁠ dart
class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

// এরর হ্যান্ডেলিং ফাংশন
void handleNetworkError(dynamic error) {
  if (error is SocketException) {
    // সংযোগ ব্যর্থ
    print('Connection failed: Unable to connect to server');
  } else if (error is TimeoutException) {
    // টাইমআউট
    print('Connection timeout');
  } else {
    // অন্যান্য এরর
    print('Network error: $error');
  }
}
 ⁠

---

## ৯. টেস্টিং

### ৯.১. ইউনিট টেস্ট

⁠ dart
// test/wifi_service_test.dart
void main() {
  group('WiFiService Tests', () {
    test('should start server successfully', () async {
      final service = WiFiService();
      await service.startServer(8080);
      expect(service.isServerRunning, true);
    });
    
    test('should connect to server successfully', () async {
      final service = WiFiService();
      await service.connectToServer('192.168.1.100', 8080);
      expect(service.isConnected, true);
    });
  });
}
 ⁠

---

## ১০. ডেভেলপমেন্ট গাইডলাইন

### ১০.১. কোডিং স্ট্যান্ডার্ড

•⁠  ⁠ক্লিন এবং মডুলার কোড স্ট্রাকচার
•⁠  ⁠প্রপার এরর হ্যান্ডলিং
•⁠  ⁠অ্যাসিঙ্ক্রোনাস অপারেশনের জন্য async/await ব্যবহার
•⁠  ⁠কমেন্ট এবং ডকুমেন্টেশন

### ১০.২. পারফরম্যান্স অপ্টিমাইজেশন

•⁠  ⁠মেসেজ ব্রডকাস্টিং অপ্টিমাইজ করা
•⁠  ⁠কানেকশন পুলিং ব্যবহার করা
•⁠  ⁠মেমোরি লিক প্রতিরোধ করা

---

## ১১. ডেলিভারেবলস

১.⁠ ⁠Wi-Fi সার্ভার এবং ক্লায়েন্ট ইমপ্লিমেন্টেশন
২.⁠ ⁠Bluetooth সার্ভার এবং ক্লায়েন্ট ইমপ্লিমেন্টেশন
৩.⁠ ⁠মেসেজিং সার্ভিস
৪.⁠ ⁠কানেকশন ম্যানেজার
৫.⁠ ⁠ডিভাইস ইনফরমেশন সার্ভিস
৬.⁠ ⁠এরর হ্যান্ডলিং
৭.⁠ ⁠নেটওয়ার্কিং টেস্ট কোড

---

## ১২. নোট

•⁠  ⁠আপনাকে শুধুমাত্র নেটওয়ার্কিং এবং ব্যাকএন্ড লজিক ডেভেলপ করতে হবে
•⁠  ⁠UI ডিজাইন এবং ডেটা স্টোরেজ অন্য ডেভেলপাররা করবে
•⁠  ⁠আপনাকে UI ডেভেলপার এবং ডেটা স্টোরেজ ডেভেলপারের সাথে কোড ইন্টিগ্রেট করতে হবে
•⁠  ⁠সকল এরর মেসেজ ইংরেজিতে থাকবে</li>
<li></li>
</ol>
<h1>Faiyaz Karim Annoor (69)</h1>

<ol>
  <li></li>
</ol>
<h1>Pranto Roy (70)</h1>

<ol>
  <li></li>
</ol>
