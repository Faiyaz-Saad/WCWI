<h1>⭐ A S M Hossain Mahmmud Shadhin (68)  🛜<i><b>Networking</b></i></h1> 

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
</ol>

<h2>Problems ❌</h2>
<ul>
  <li>how  to  test whether the app is running in wifi mode or not</li>
</ul>

<h1>⭐ Faiyaz Karim Annoor (69) <img width="56" height="56" alt="image" src="https://github.com/user-attachments/assets/3cc6576e-ef37-442b-bfae-553a2740de81" /> <i><b>UI</b></i></h1>

<ol>
  <li># ডেভেলপার ১: UI/UX এবং ফ্রন্টএন্ড ডেভেলপমেন্ট প্রম্পট

## গুরুত্বপূর্ণ নোট

এই অ্যাপ্লিকেশনের সকল ইউজার ইন্টারফেস (UI) টেক্সট, লেবেল, মেসেজ, বাটন, মেনু এবং অন্যান্য সকল দৃশ্যমান উপাদান শুধুমাত্র ইংরেজিতে থাকবে। অ্যাপের মধ্যে কোনো বাংলা ভাষার টেক্সট ব্যবহার করা যাবে না।

---

## ডেভেলপারের দায়িত্ব

আপনার দায়িত্ব হলো WCWI (Wireless Communication Without Internet) অ্যাপের সম্পূর্ণ ইউজার ইন্টারফেস (UI) এবং ইউজার এক্সপেরিয়েন্স (UX) ডিজাইন এবং ডেভেলপ করা। আপনাকে Flutter ব্যবহার করে সকল স্ক্রিন তৈরি করতে হবে।

---

## ১. টেকনোলজি স্ট্যাক

- **ফ্রেমওয়ার্ক:** Flutter
- **ভাষা:** Dart
- **UI লাইব্রেরি:** Material Design 3
- **স্টেট ম্যানেজমেন্ট:** Provider বা Riverpod
- **নেভিগেশন:** Flutter Navigator 2.0

---

## ২. ডিজাইন থিম এবং স্টাইল

### ২.১. কালার প্যালেট

**প্রাইমারি কালার:**
- ব্যাকগ্রাউন্ড: গাঢ় বেগুনি গ্র্যাডিয়েন্ট (#1A1A2E থেকে #16213E)
- প্রাইমারি: #6C63FF (বেগুনি)
- সেকেন্ডারি: #4A90E2 (নীল)
- টার্শিয়ারি: #E91E63 (গোলাপী)
- টেক্সট: Colors.white
- বাটন: #0F3460

### ২.২. থিম ভ্যারিয়েশন

অ্যাপে ৩টি ইউনিক UI থিম থাকবে যা ব্যবহারকারীরা স্যুইচ করতে পারবে:

**থিম ১ - পার্পল থিম:**
- প্রাইমারি কালার: বেগুনি গ্র্যাডিয়েন্ট
- কার্ড ব্যাকগ্রাউন্ড: বেগুনি গ্র্যাডিয়েন্ট

**থিম ২ - ব্লু থিম:**
- প্রাইমারি কালার: নীল গ্র্যাডিয়েন্ট
- কার্ড ব্যাকগ্রাউন্ড: নীল গ্র্যাডিয়েন্ট

**থিম ৩ - পিংক থিম:**
- প্রাইমারি কালার: গোলাপী গ্র্যাডিয়েন্ট
- কার্ড ব্যাকগ্রাউন্ড: গোলাপী গ্র্যাডিয়েন্ট

### ২.৩. টাইপোগ্রাফি

- ফন্ট ফ্যামিলি: Roboto বা Poppins
- হেডিং ফন্ট সাইজ: 24-32px
- বডি ফন্ট সাইজ: 14-16px
- ক্যাপশন ফন্ট সাইজ: 12-14px

### ২.৪. কম্পোনেন্ট স্টাইল

- কার্ড বর্ডার রেডিয়াস: 16px
- বাটন বর্ডার রেডিয়াস: 8px
- বক্স শ্যাডো: হালকা শ্যাডো
- প্যাডিং: 16-20px

---

## ৩. স্ক্রিন তালিকা এবং বিস্তারিত বর্ণনা

### ৩.১. ল্যান্ডিং পেজ (Landing Page)

**ফাইল নাম:** `landing_page.dart`

**ব্যাকগ্রাউন্ড:**
- গাঢ় বেগুনি গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড (#1A1A2E থেকে #16213E)
- Smooth gradient transition

**হেডার সেকশন (Column, centered):**
- WCWI লোগো (সাদা বোল্ড, 32px)
- ট্যাগলাইন "Wireless Connection Without Internet" (সাদা, 14px, opacity 0.8)
- ElevatedButton "Choose connection mode" (light purple #0F3460, white text, rounded corners)
- SizedBox height: 32px

**কানেকশন মোড সিলেকশন সেকশন:**
- শিরোনাম "Select Connection Mode" (সাদা, bold, 24px, centered)
- SizedBox height: 24px

**তিনটি কার্ড (Column with spacing):**

**WiFi Mode কার্ড:**
- Container with purple gradient (#6C63FF to #7B68EE)
- Border radius: 16px
- BoxShadow for depth
- Padding: 20px
- Icon(Icons.wifi, white, 48px)
- Text "WiFi Mode" (white, bold, 18px)
- Text "Connect via Local WiFi Access Point or Hotspot" (white, 12px)
- GestureDetector for tap handling
- ট্যাপ করলে WiFi মোড স্ক্রিনে নেভিগেট হবে

**Bluetooth Mode কার্ড:**
- Container with blue gradient (#4A90E2 to #5C9CE6)
- Border radius: 16px
- BoxShadow for depth
- Padding: 20px
- Icon(Icons.bluetooth, white, 48px)
- Text "Bluetooth Mode" (white, bold, 18px)
- Text "Connect directly offline using Bluetooth paired devices" (white, 12px)
- GestureDetector for tap handling
- ট্যাপ করলে Bluetooth মোড স্ক্রিনে নেভিগেট হবে

**Chat History কার্ড:**
- Container with pink gradient (#E91E63 to #F48FB1)
- Border radius: 16px
- BoxShadow for depth
- Padding: 20px
- Icon(Icons.history, white, 48px)
- Text "Chat History" (white, bold, 18px)
- Text "View & manage offline messages, audio & photos" (white, 12px)
- GestureDetector for tap handling
- ট্যাপ করলে চ্যাট হিস্টরি স্ক্রিনে নেভিগেট হবে

**স্পেসিং:**
- SizedBox height: 16px between each card
- Cards width: 85% of screen width
- Cards centered using Align or Center widget

---

### ৩.২. Wi-Fi মোড স্ক্রিন (WiFi Mode Screen)

**ফাইল নাম:** `wifi_mode_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Change Connection Mode"
- ল্যান্ডিং পেজে ফিরে যাওয়ার জন্য

**প্রধান কন্টেন্ট (Column, centered):**
- শিরোনাম "WiFi Mode" (সাদা, bold, 28px)
- SizedBox height: 32px

**Start Wifi Server বাটন:**
- ElevatedButton বা Container
- বেগুনি গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Icon(Icons.router, white)
- Text "Start Wifi Server" (white, bold, 18px)
- Padding: 20px
- Border radius: 12px
- ট্যাপ করলে WiFi সার্ভার স্ক্রিনে নেভিগেট হবে

**SizedBox height: 24px**

**Connect as Wifi Client বাটন:**
- ElevatedButton বা Container
- নীল গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Icon(Icons.phone_android, white)
- Text "Connect as Wifi Client" (white, bold, 18px)
- Padding: 20px
- Border radius: 12px
- ট্যাপ করলে WiFi ক্লায়েন্ট স্ক্রিনে নেভিগেট হবে

---

### ৩.৩. Wi-Fi সার্ভার স্ক্রিন (WiFi Server Screen)

**ফাইল নাম:** `wifi_server_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Back"

**সার্ভার স্ট্যাটাস কার্ড:**
- Container with white background (opacity 0.1)
- Border radius: 16px
- Padding: 24px

**সার্ভার তথ্য:**
- Icon(Icons.server, white, 64px)
- SizedBox height: 16px
- Text "Server Running" (সাদা, bold, 20px)
- SizedBox height: 8px
- Text "Your IP Address:" (সাদা, 16px)
- SizedBox height: 8px
- Text "192.168.1.100" (সাদা, bold, 32px) - এটি ডায়নামিক হবে
- SizedBox height: 16px
- Text "Connected Clients: 0" (সাদা, 16px)

**Stop Server বাটন:**
- ElevatedButton
- লাল গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Text "Stop Server" (white, bold, 18px)
- Padding: 16px
- Border radius: 12px
- ট্যাপ করলে সার্ভার বন্ধ হবে এবং আগের স্ক্রিনে ফিরবে

---

### ৩.৪. Wi-Fi ক্লায়েন্ট স্ক্রিন (WiFi Client Screen)

**ফাইল নাম:** `wifi_client_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Back"

**শিরোনাম:**
- Text "Connect to Server" (সাদা, bold, 24px)
- SizedBox height: 32px

**IP অ্যাড্রেস ইনপুট কার্ড:**
- Container with white background (opacity 0.1)
- Border radius: 16px
- Padding: 20px

**ইনপুট ফিল্ড:**
- TextField
- Hint text: "Enter Server IP Address"
- Style: white text, white hint
- Border: OutlineInputBorder with white color
- Padding: 16px

**SizedBox height: 24px**

**Connect বাটন:**
- ElevatedButton
- বেগুনি গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Text "Connect" (white, bold, 18px)
- Padding: 20px
- Border radius: 12px
- ট্যাপ করলে সংযোগ চেষ্টা করবে

---

### ৩.৫. Bluetooth মোড স্ক্রিন (Bluetooth Mode Screen)

**ফাইল নাম:** `bluetooth_mode_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Change Connection Mode"
- ল্যান্ডিং পেজে ফিরে যাওয়ার জন্য

**প্রধান কন্টেন্ট (Column, centered):**
- শিরোনাম "Bluetooth Mode" (সাদা, bold, 28px)
- SizedBox height: 32px

**Start Bluetooth Server বাটন:**
- ElevatedButton বা Container
- বেগুনি গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Icon(Icons.bluetooth, white)
- Text "Start Bluetooth Server" (white, bold, 18px)
- Padding: 20px
- Border radius: 12px
- ট্যাপ করলে Bluetooth সার্ভার স্ক্রিনে নেভিগেট হবে

**SizedBox height: 24px**

**Connect as Bluetooth Client বাটন:**
- ElevatedButton বা Container
- নীল গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Icon(Icons.bluetooth_searching, white)
- Text "Connect as Bluetooth Client" (white, bold, 18px)
- Padding: 20px
- Border radius: 12px
- ট্যাপ করলে Bluetooth ক্লায়েন্ট স্ক্রিনে নেভিগেট হবে

---

### ৩.৬. Bluetooth সার্ভার স্ক্রিন (Bluetooth Server Screen)

**ফাইল নাম:** `bluetooth_server_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Back"

**সার্ভার স্ট্যাটাস কার্ড:**
- Container with white background (opacity 0.1)
- Border radius: 16px
- Padding: 24px

**সার্ভার তথ্য:**
- Icon(Icons.bluetooth, white, 64px)
- SizedBox height: 16px
- Text "Bluetooth Server Running" (সাদা, bold, 20px)
- SizedBox height: 8px
- Text "Device Name: WCWI_Server" (সাদা, 16px)
- SizedBox height: 16px
- Text "Waiting for client connection..." (সাদা, 14px)

**Stop Server বাটন:**
- ElevatedButton
- লাল গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
- Text "Stop Server" (white, bold, 18px)
- Padding: 16px
- Border radius: 12px
- ট্যাপ করলে সার্ভার বন্ধ হবে এবং আগের স্ক্রিনে ফিরবে

---

### ৩.৭. Bluetooth ক্লায়েন্ট স্ক্রিন (Bluetooth Client Screen)

**ফাইল নাম:** `bluetooth_client_screen.dart`

**ব্যাক বাটন:**
- AppBar বা কাস্টম ব্যাক বাটন "Back"

**শিরোনাম:**
- Text "Available Devices" (সাদা, bold, 24px)
- SizedBox height: 16px

**ডিভাইস লিস্ট (ListView):**
- প্রতিটি ডিভাইসের জন্য Card:
  - Container with white background (opacity 0.1)
  - Border radius: 12px
  - Padding: 16px
  - Row with:
    - Icon(Icons.bluetooth, white)
    - SizedBox width: 16px
    - Column with:
      - Text "WCWI_Server" (সাদা, bold, 16px)
      - Text "Paired" (সাদা, 12px)
  - GestureDetector for tap handling
  - ট্যাপ করলে সেই ডিভাইসের সাথে সংযুক্ত হবে

**Loading/Empty State:**
- যদি কোনো ডিভাইস না পাওয়া যায়:
  - Text "No devices found" (সাদা, 16px)
  - CircularProgressIndicator (সাদা)

---

### ৩.৮. চ্যাট পেজ (Chat Page)

**ফাইল নাম:** `chat_page.dart`

**AppBar:**
- শিরোনাম: ডিভাইসের নাম (সাদা)
- সাবটাইটেল: সংযোগের ধরন (WiFi/Bluetooth)
- অ্যাকশন বাটন: Disconnect icon

**চ্যাট বডি (ListView):**
- প্রতিটি মেসেজের জন্য:
  - **Sent Message (ডানদিকে):**
    - Container with purple gradient background
    - Border radius: 16px (top-left, top-right, bottom-left)
    - Padding: 12px
    - Max width: 70% of screen
    - Align: right
    - Text (সাদা, 14px)
    - Text (সময়, সাদা, 10px, opacity 0.7)
  
  - **Received Message (বামদিকে):**
    - Container with blue gradient background
    - Border radius: 16px (top-left, top-right, bottom-right)
    - Padding: 12px
    - Max width: 70% of screen
    - Align: left
    - Text (সাদা, 14px)
    - Text (সময়, সাদা, 10px, opacity 0.7)

**মেসেজ ইনপুট এরিয়া (Bottom):**
- Container with white background (opacity 0.1)
- Padding: 16px
- Row with:
  - IconButton (ছবি আইকন)
  - Expanded with TextField (টেক্সট ইনপুট)
  - IconButton (ভয়েস রেকর্ড আইকন)
  - IconButton (সেন্ড আইকন)

**মেসেজ সিলেকশন মোড:**
- লং প্রেস করলে সিলেকশন মোড চালু হবে
- AppBar এ "Select All" এবং "Delete" বাটন দেখাবে
- মেসেজের পাশে checkbox দেখাবে

---

### ৩.৯. চ্যাট হিস্টরি পেজ (Chat History Page)

**ফাইল নাম:** `chat_history_screen.dart`

**ব্যাকগ্রাউন্ড:**
- BAUST লোগো ব্যাকগ্রাউন্ড (opacity 0.1)

**AppBar:**
- শিরোনাম: "Chat History" (সাদা)

**চ্যাট লিস্ট (ListView):**
- প্রতিটি চ্যাটের জন্য Card:
  - Container with white background (opacity 0.1)
  - Border radius: 12px
  - Padding: 16px
  - Row with:
    - CircleAvatar (ডিভাইসের প্রথম অক্ষর)
    - SizedBox width: 16px
    - Expanded with Column:
      - Text "Device Name" (সাদা, bold, 16px)
      - Text "Last message preview..." (সাদা, 14px, opacity 0.7)
      - Text "Date, Time" (সাদা, 12px, opacity 0.5)
  - GestureDetector for tap handling
  - ট্যাপ করলে সেই চ্যাট খুলবে

**চ্যাট ডিলিট মোড:**
- লং প্রেস করলে সিলেকশন মোড চালু হবে
- AppBar এ "Select All" এবং "Delete" বাটন দেখাবে
- চ্যাটের পাশে checkbox দেখাবে

---

## ৪. নেভিগেশন স্ট্রাকচার

```dart
// main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WCWI',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/wifi_mode': (context) => WiFiModeScreen(),
        '/wifi_server': (context) => WiFiServerScreen(),
        '/wifi_client': (context) => WiFiClientScreen(),
        '/bluetooth_mode': (context) => BluetoothModeScreen(),
        '/bluetooth_server': (context) => BluetoothServerScreen(),
        '/bluetooth_client': (context) => BluetoothClientScreen(),
        '/chat': (context) => ChatPage(),
        '/chat_history': (context) => ChatHistoryScreen(),
      },
    );
  }
}
```

---

## ৫. থিম স্যুইচিং ফিচার

**Settings পেজ বা ড্রয়ারে থিম সিলেকশন:**
- ৩টি থিম অপশন (Purple, Blue, Pink)
- থিম সিলেক্ট করলে সম্পূর্ণ অ্যাপে থিম পরিবর্তন হবে
- Provider বা Riverpod ব্যবহার করে থিম স্টেট ম্যানেজ করতে হবে

---

## ৬. অ্যানিমেশন

**পেজ ট্রানজিশন:**
- Fade-in animation
- Slide-up animation
- Duration: 300ms

**বাটন ট্যাপ:**
- Ripple effect
- Scale animation (0.95 to 1.0)

**লোডিং স্টেট:**
- CircularProgressIndicator (সাদা)
- লোডিং টেক্সট "Loading..."

---

## ৭. রেসপন্সিভ ডিজাইন

- বিভিন্ন স্ক্রিন সাইজে সামঞ্জস্যপূর্ণ হতে হবে
- MediaQuery ব্যবহার করে স্ক্রিন সাইজ ডিটেক্ট করতে হবে
- ল্যান্ডস্কেপ এবং পোর্ট্রেট দুটি মোডে কাজ করতে হবে

---

## ৮. ব্র্যান্ডিং এলিমেন্টস

**লোগো:**
- কাস্টমাইজড লোগো "WCWI" এবং "BAUST" নামের সাথে
- লোগো সকল পেজে কনসিস্টেন্ট থাকবে

**ব্যাকগ্রাউন্ড:**
- চ্যাট হিস্টরি পেজে BAUST লোগো ব্যাকগ্রাউন্ড

---

## ৯. ডেভেলপমেন্ট গাইডলাইন

### ৯.১. কোডিং স্ট্যান্ডার্ড

- ক্লিন এবং মডুলার কোড স্ট্রাকচার
- প্রপার কমেন্ট এবং ডকুমেন্টেশন
- Widget এর নাম PascalCase এ
- Variable এর নাম camelCase এ

### ৯.২. ফাইল স্ট্রাকচার

```
lib/
├── main.dart
├── screens/
│   ├── landing_page.dart
│   ├── wifi_mode_screen.dart
│   ├── wifi_server_screen.dart
│   ├── wifi_client_screen.dart
│   ├── bluetooth_mode_screen.dart
│   ├── bluetooth_server_screen.dart
│   ├── bluetooth_client_screen.dart
│   ├── chat_page.dart
│   └── chat_history_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_card.dart
│   └── message_bubble.dart
├── theme/
│   ├── app_theme.dart
│   └── colors.dart
└── utils/
    └── constants.dart
```

### ৯.৩. টেস্টিং

- Widget testing করতে হবে
- UI কম্পোনেন্ট টেস্ট করতে হবে
- নেভিগেশন টেস্ট করতে হবে

---

## ১০. ডেলিভারেবলস

১. সকল স্ক্রিনের Flutter কোড
২. থিম স্যুইচিং ফিচার
৩. নেভিগেশন লজিক
৪. UI কম্পোনেন্ট লাইব্রেরি
৫. অ্যানিমেশন এবং ট্রানজিশন
৬. রেসপন্সিভ ডিজাইন
৭. UI টেস্ট কোড

---

## ১১. নোট

- আপনাকে শুধুমাত্র UI এবং UX ডিজাইন এবং ডেভেলপ করতে হবে
- নেটওয়ার্কিং লজিক, ডেটা স্টোরেজ এবং মেসেজিং লজিক অন্য ডেভেলপাররা করবে
- আপনাকে অন্য ডেভেলপারদের সাথে কোড ইন্টিগ্রেট করতে হবে
- সকল UI টেক্সট ইংরেজিতে থাকবে
</li>
</ol>

<h2>Problems ❌</h2>
<ul>
  <li>header and footer remove koran</li>
  <li>WiFi mode page a WiFi Mode ar pori borta ata add koran</li>
</ul>

<h1>⭐ Pranto Roy (70) 🗄️ <i><b>Storage</b></i></h1>

<ol>
  <li># ডেভেলপার ৩: ডেটা স্টোরেজ এবং চ্যাট হিস্টরি ম্যানেজমেন্ট প্রম্পট

## গুরুত্বপূর্ণ নোট

এই অ্যাপ্লিকেশনের সকল ইউজার ইন্টারফেস (UI) টেক্সট, লেবেল, মেসেজ, বাটন, মেনু এবং অন্যান্য সকল দৃশ্যমান উপাদান শুধুমাত্র ইংরেজিতে থাকবে। অ্যাপের মধ্যে কোনো বাংলা ভাষার টেক্সট ব্যবহার করা যাবে না।

---

## ডেভেলপারের দায়িত্ব

আপনার দায়িত্ব হলো WCWI (Wireless Communication Without Internet) অ্যাপের সম্পূর্ণ ডেটা স্টোরেজ সিস্টেম, চ্যাট হিস্টরি ম্যানেজমেন্ট, ফাইল স্টোরেজ (ছবি এবং ভয়েস মেসেজ) এবং ডেটা পার্সিস্টেন্স ডেভেলপ করা। আপনাকে স্থানীয় ডেটাবেস এবং ফাইল সিস্টেম ব্যবহার করে সকল ডেটা সংরক্ষণ করতে হবে।

---

## ১. টেকনোলজি স্ট্যাক

- *ফ্রেমওয়ার্ক:* Flutter
- *ভাষা:* Dart
- *ডেটাবেস:* SQLite (sqflite প্যাকেজ) বা Hive (NoSQL)
- *ফাইল স্টোরেজ:* path_provider প্যাকেজ
- *ইমেজ প্রসেসিং:* image_picker প্যাকেজ
- *ভয়েস রেকর্ডিং:* record বা audioplayers প্যাকেজ
- *স্টেট ম্যানেজমেন্ট:* Provider বা Riverpod

---

## ২. ডেটা স্টোরেজ আর্কিটেকচার

### ২.১. ডেটাবেস স্কিমা

*টেবিল ১: Chats (চ্যাট সেশন)*
sql
CREATE TABLE chats (
  id TEXT PRIMARY KEY,
  device_name TEXT NOT NULL,
  connection_type TEXT NOT NULL, -- 'wifi' or 'bluetooth'
  last_message TEXT,
  last_message_time INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);


*টেবিল ২: Messages (মেসেজ)*
sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  chat_id TEXT NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT NOT NULL, -- 'text', 'image', 'voice'
  direction TEXT NOT NULL, -- 'sent' or 'received'
  file_path TEXT,
  timestamp INTEGER NOT NULL,
  is_deleted INTEGER DEFAULT 0,
  FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
);


### ২.২. ফাইল স্টোরেজ স্ট্রাকচার


app_data/
├── images/
│   ├── chat_1/
│   │   ├── msg_1.jpg
│   │   └── msg_2.jpg
│   └── chat_2/
│       └── msg_1.jpg
└── voice/
    ├── chat_1/
    │   ├── msg_1.mp3
    │   └── msg_2.mp3
    └── chat_2/
        └── msg_1.mp3


### ২.৩. কম্পোনেন্ট স্ট্রাকচার


lib/
├── services/
│   ├── database_service.dart
│   ├── chat_service.dart
│   ├── message_service.dart
│   ├── file_storage_service.dart
│   └── image_service.dart
├── models/
│   ├── chat.dart
│   ├── message.dart
│   └── file_info.dart
└── repositories/
    ├── chat_repository.dart
    └── message_repository.dart


---

## ৩. ডেটাবেস সার্ভিস

### ৩.১. ডেটাবেস সার্ভিস ইমপ্লিমেন্টেশন

*ফাইল নাম:* database_service.dart

dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  // ডেটাবেস ইনিশিয়ালাইজ করা
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  // ডেটাবেস তৈরি করা
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wcwi.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // টেবিল তৈরি করা
  Future<void> _onCreate(Database db, int version) async {
    // Chats টেবিল
    await db.execute('''
      CREATE TABLE chats (
        id TEXT PRIMARY KEY,
        device_name TEXT NOT NULL,
        connection_type TEXT NOT NULL,
        last_message TEXT,
        last_message_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // Messages টেবিল
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        content TEXT NOT NULL,
        message_type TEXT NOT NULL,
        direction TEXT NOT NULL,
        file_path TEXT,
        timestamp INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
      )
    ''');
    
    // ইনডেক্স তৈরি করা
    await db.execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
  }
  
  // ডেটাবেস আপগ্রেড
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ভবিষ্যতে আপগ্রেড লজিক এখানে যোগ করা হবে
  }
  
  // ডেটাবেস বন্ধ করা
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}


---

## ৪. চ্যাট মডেল এবং সার্ভিস

### ৪.১. চ্যাট মডেল

*ফাইল নাম:* chat.dart

dart
class Chat {
  final String id;
  final String deviceName;
  final String connectionType;
  final String? lastMessage;
  final int? lastMessageTime;
  final int createdAt;
  final int updatedAt;
  
  Chat({
    required this.id,
    required this.deviceName,
    required this.connectionType,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // ডেটাবেস থেকে Chat তৈরি করা
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      deviceName: map['device_name'],
      connectionType: map['connection_type'],
      lastMessage: map['last_message'],
      lastMessageTime: map['last_message_time'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
  
  // Chat থেকে Map তৈরি করা
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_name': deviceName,
      'connection_type': connectionType,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


### ৪.২. চ্যাট সার্ভিস

*ফাইল নাম:* chat_service.dart

dart
import 'package:uuid/uuid.dart';

class ChatService {
  final DatabaseService _dbService;
  
  ChatService({required DatabaseService dbService}) 
      : _dbService = dbService;
  
  // নতুন চ্যাট তৈরি করা
  Future<Chat> createChat({
    required String deviceName,
    required String connectionType,
  }) async {
    final db = await _dbService.database;
    final chatId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final chat = Chat(
      id: chatId,
      deviceName: deviceName,
      connectionType: connectionType,
      createdAt: now,
      updatedAt: now,
    );
    
    await db.insert('chats', chat.toMap());
    return chat;
  }
  
  // সকল চ্যাট পাওয়া
  Future<List<Chat>> getAllChats() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      orderBy: 'updated_at DESC',
    );
    
    return maps.map((map) => Chat.fromMap(map)).toList();
  }
  
  // নির্দিষ্ট চ্যাট পাওয়া
  Future<Chat?> getChatById(String chatId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
    
    if (maps.isEmpty) return null;
    return Chat.fromMap(maps.first);
  }
  
  // চ্যাট আপডেট করা
  Future<void> updateChat(Chat chat) async {
    final db = await _dbService.database;
    final updatedChat = Chat(
      id: chat.id,
      deviceName: chat.deviceName,
      connectionType: chat.connectionType,
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageTime,
      createdAt: chat.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    await db.update(
      'chats',
      updatedChat.toMap(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }
  
  // চ্যাট ডিলিট করা
  Future<void> deleteChat(String chatId) async {
    final db = await _dbService.database;
    await db.delete(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }
  
  // সকল চ্যাট ডিলিট করা
  Future<void> deleteAllChats() async {
    final db = await _dbService.database;
    await db.delete('chats');
  }
}


---

## ৫. মেসেজ মডেল এবং সার্ভিস

### ৫.১. মেসেজ মডেল

*ফাইল নাম:* message.dart

dart
class Message {
  final String id;
  final String chatId;
  final String content;
  final String messageType; // 'text', 'image', 'voice'
  final String direction; // 'sent' or 'received'
  final String? filePath;
  final int timestamp;
  final bool isDeleted;
  
  Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.messageType,
    required this.direction,
    this.filePath,
    required this.timestamp,
    this.isDeleted = false,
  });
  
  // ডেটাবেস থেকে Message তৈরি করা
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      chatId: map['chat_id'],
      content: map['content'],
      messageType: map['message_type'],
      direction: map['direction'],
      filePath: map['file_path'],
      timestamp: map['timestamp'],
      isDeleted: map['is_deleted'] == 1,
    );
  }
  
  // Message থেকে Map তৈরি করা
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'content': content,
      'message_type': messageType,
      'direction': direction,
      'file_path': filePath,
      'timestamp': timestamp,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
  
  // DateTime থেকে timestamp
  static int toDateTime(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
  
  // timestamp থেকে DateTime
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}


### ৫.২. মেসেজ সার্ভিস

*ফাইল নাম:* message_service.dart

dart
import 'package:uuid/uuid.dart';

class MessageService {
  final DatabaseService _dbService;
  final ChatService _chatService;
  
  MessageService({
    required DatabaseService dbService,
    required ChatService chatService,
  }) : _dbService = dbService,
       _chatService = chatService;
  
  // নতুন মেসেজ তৈরি করা
  Future<Message> createMessage({
    required String chatId,
    required String content,
    required String messageType,
    required String direction,
    String? filePath,
  }) async {
    final db = await _dbService.database;
    final messageId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final message = Message(
      id: messageId,
      chatId: chatId,
      content: content,
      messageType: messageType,
      direction: direction,
      filePath: filePath,
      timestamp: now,
    );
    
    await db.insert('messages', message.toMap());
    
    // চ্যাট আপডেট করা
    final chat = await _chatService.getChatById(chatId);
    if (chat != null) {
      await _chatService.updateChat(Chat(
        id: chat.id,
        deviceName: chat.deviceName,
        connectionType: chat.connectionType,
        lastMessage: content,
        lastMessageTime: now,
        createdAt: chat.createdAt,
        updatedAt: now,
      ));
    }
    
    return message;
  }
  
  // নির্দিষ্ট চ্যাটের সকল মেসেজ পাওয়া
  Future<List<Message>> getMessagesByChatId(String chatId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_id = ? AND is_deleted = 0',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
    
    return maps.map((map) => Message.fromMap(map)).toList();
  }
  
  // নির্দিষ্ট মেসেজ পাওয়া
  Future<Message?> getMessageById(String messageId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    if (maps.isEmpty) return null;
    return Message.fromMap(maps.first);
  }
  
  // মেসেজ ডিলিট করা (soft delete)
  Future<void> deleteMessage(String messageId) async {
    final db = await _dbService.database;
    await db.update(
      'messages',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  
  // চ্যাটের সকল মেসেজ ডিলিট করা
  Future<void> deleteAllMessagesByChatId(String chatId) async {
    final db = await _dbService.database;
    await db.update(
      'messages',
      {'is_deleted': 1},
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
  }
  
  // মেসেজ সিলেক্ট করা
  Future<void> selectMessage(String messageId, bool isSelected) async {
    // UI এর জন্য সিলেকশন স্টেট ম্যানেজ করতে হবে
    // এটি Provider বা Riverpod এর মাধ্যমে করা যেতে পারে
  }
  
  // সকল মেসেজ সিলেক্ট করা
  Future<void> selectAllMessages(String chatId, bool isSelected) async {
    // UI এর জন্য সিলেকশন স্টেট ম্যানেজ করতে হবে
  }
}


---

## ৬. ফাইল স্টোরেজ সার্ভিস

### ৬.১. ফাইল স্টোরেজ সার্ভিস

*ফাইল নাম:* file_storage_service.dart

dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileStorageService {
  // অ্যাপ ডিরেক্টরি পাওয়া
  Future<Directory> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
  
  // ইমেজ ডিরেক্টরি পাওয়া
  Future<Directory> getImageDirectory(String chatId) async {
    final appDir = await getAppDirectory();
    final imageDir = Directory('${appDir.path}/images/$chatId');
    
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    return imageDir;
  }
  
  // ভয়েস ডিরেক্টরি পাওয়া
  Future<Directory> getVoiceDirectory(String chatId) async {
    final appDir = await getAppDirectory();
    final voiceDir = Directory('${appDir.path}/voice/$chatId');
    
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    
    return voiceDir;
  }
  
  // ফাইল সেভ করা
  Future<File> saveFile(File sourceFile, Directory targetDirectory) async {
    final fileName = sourceFile.path.split('/').last;
    final targetPath = '${targetDirectory.path}/$fileName';
    final targetFile = await sourceFile.copy(targetPath);
    return targetFile;
  }
  
  // ফাইল ডিলিট করা
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  // চ্যাটের সকল ফাইল ডিলিট করা
  Future<void> deleteChatFiles(String chatId) async {
    final imageDir = await getImageDirectory(chatId);
    final voiceDir = await getVoiceDirectory(chatId);
    
    if (await imageDir.exists()) {
      await imageDir.delete(recursive: true);
    }
    
    if (await voiceDir.exists()) {
      await voiceDir.delete(recursive: true);
    }
  }
  
  // ফাইলের সাইজ পাওয়া
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}


---

## ৭. ইমেজ সার্ভিস

### ৭.১. ইমেজ সার্ভিস

*ফাইল নাম:* image_service.dart

dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'file_storage_service.dart';

class ImageService {
  final FileStorageService _fileStorageService;
  final ImagePicker _imagePicker = ImagePicker();
  
  ImageService({required FileStorageService fileStorageService})
      : _fileStorageService = fileStorageService;
  
  // গ্যালারি থেকে ইমেজ পিক করা
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
  
  // ক্যামেরা থেকে ইমেজ পিক করা
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
  
  // ইমেজ সেভ করা
  Future<String> saveImage(File imageFile, String chatId) async {
    final imageDir = await _fileStorageService.getImageDirectory(chatId);
    final savedFile = await _fileStorageService.saveFile(imageFile, imageDir);
    return savedFile.path;
  }
  
  // ইমেজ কমপ্রেস করা
  Future<File> compressImage(File imageFile) async {
    // ইমেজ কমপ্রেশন লজিক
    // image প্যাকেজ ব্যবহার করে কমপ্রেশন করা যেতে পারে
    return imageFile;
  }
  
  // ইমেজ ডিলিট করা
  Future<void> deleteImage(String imagePath) async {
    await _fileStorageService.deleteFile(imagePath);
  }
}


---

## ৮. ভয়েস রেকর্ডিং সার্ভিস

### ৮.১. ভয়েস সার্ভিস

*ফাইল নাম:* voice_service.dart

dart
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'file_storage_service.dart';

class VoiceService {
  final FileStorageService _fileStorageService;
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  VoiceService({required FileStorageService fileStorageService})
      : _fileStorageService = fileStorageService;
  
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  // রেকর্ডিং শুরু করা
  Future<String> startRecording(String chatId) async {
    if (_isRecording) return _currentRecordingPath!;
    
    final voiceDir = await _fileStorageService.getVoiceDirectory(chatId);
    final fileName = '${const Uuid().v4()}.mp3';
    final filePath = '${voiceDir.path}/$fileName';
    
    await _audioRecorder.startRecorder(
      toFile: filePath,
      encoder: AudioEncoder.aacLc,
    );
    
    _isRecording = true;
    _currentRecordingPath = filePath;
    
    return filePath;
  }
  
  // রেকর্ডিং বন্ধ করা
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    final path = await _audioRecorder.stopRecorder();
    _isRecording = false;
    _currentRecordingPath = null;
    
    return path;
  }
  
  // রেকর্ডিং চলছে কি না
  bool get isRecording => _isRecording;
  
  // ভয়েস ফাইল ডিলিট করা
  Future<void> deleteVoice(String voicePath) async {
    await _fileStorageService.deleteFile(voicePath);
  }
  
  // ভয়েস ফাইলের সময়কাল পাওয়া
  Future<Duration?> getVoiceDuration(String voicePath) async {
    // audioplayers প্যাকেজ ব্যবহার করে সময়কাল পাওয়া যেতে পারে
    return Duration(seconds: 0);
  }
}


---

## ৯. রিপোজিটরি প্যাটার্ন

### ৯.১. চ্যাট রিপোজিটরি

*ফাইল নাম:* chat_repository.dart

dart
class ChatRepository {
  final ChatService _chatService;
  final MessageService _messageService;
  
  ChatRepository({
    required ChatService chatService,
    required MessageService messageService,
  }) : _chatService = chatService,
       _messageService = messageService;
  
  // চ্যাট তৈরি করা
  Future<Chat> createChat({
    required String deviceName,
    required String connectionType,
  }) async {
    return await _chatService.createChat(
      deviceName: deviceName,
      connectionType: connectionType,
    );
  }
  
  // সকল চ্যাট পাওয়া
  Future<List<Chat>> getAllChats() async {
    return await _chatService.getAllChats();
  }
  
  // চ্যাট ডিলিট করা
  Future<void> deleteChat(String chatId) async {
    await _messageService.deleteAllMessagesByChatId(chatId);
    await _chatService.deleteChat(chatId);
  }
}


### ৯.২. মেসেজ রিপোজিটরি

*ফাইল নাম:* message_repository.dart

dart
class MessageRepository {
  final MessageService _messageService;
  final ImageService _imageService;
  final VoiceService _voiceService;
  
  MessageRepository({
    required MessageService messageService,
    required ImageService imageService,
    required VoiceService voiceService,
  }) : _messageService = messageService,
       _imageService = imageService,
       _voiceService = voiceService;
  
  // টেক্সট মেসেজ পাঠানো
  Future<Message> sendTextMessage({
    required String chatId,
    required String content,
    required String direction,
  }) async {
    return await _messageService.createMessage(
      chatId: chatId,
      content: content,
      messageType: 'text',
      direction: direction,
    );
  }
  
  // ছবি মেসেজ পাঠানো
  Future<Message> sendImageMessage({
    required String chatId,
    required File imageFile,
    required String direction,
  }) async {
    final imagePath = await _imageService.saveImage(imageFile, chatId);
    
    return await _messageService.createMessage(
      chatId: chatId,
      content: 'Image',
      messageType: 'image',
      direction: direction,
      filePath: imagePath,
    );
  }
  
  // ভয়েস মেসেজ পাঠানো
  Future<Message> sendVoiceMessage({
    required String chatId,
    required String voicePath,
    required String direction,
  }) async {
    return await _messageService.createMessage(
      chatId: chatId,
      content: 'Voice',
      messageType: 'voice',
      direction: direction,
      filePath: voicePath,
    );
  }
  
  // মেসেজ ডিলিট করা
  Future<void> deleteMessage(String messageId) async {
    final message = await _messageService.getMessageById(messageId);
    if (message != null && message.filePath != null) {
      if (message.messageType == 'image') {
        await _imageService.deleteImage(message.filePath!);
      } else if (message.messageType == 'voice') {
        await _voiceService.deleteVoice(message.filePath!);
      }
    }
    await _messageService.deleteMessage(messageId);
  }
}


---

## ১০. ডেটা মাইগ্রেশন এবং ব্যাকআপ

### ১০.১. ডেটা ব্যাকআপ

dart
class BackupService {
  final DatabaseService _dbService;
  final FileStorageService _fileStorageService;
  
  BackupService({
    required DatabaseService dbService,
    required FileStorageService fileStorageService,
  }) : _dbService = dbService,
       _fileStorageService = fileStorageService;
  
  // ডেটাবেস ব্যাকআপ নেওয়া
  Future<File> backupDatabase() async {
    final db = await _dbService.database;
    final dbPath = db.path;
    final backupFile = File('${dbPath}.backup');
    await File(dbPath).copy(backupFile.path);
    return backupFile;
  }
  
  // ফাইল ব্যাকআপ নেওয়া
  Future<void> backupFiles(String targetDirectory) async {
    final appDir = await _fileStorageService.getAppDirectory();
    final targetDir = Directory(targetDirectory);
    
    if (await appDir.exists()) {
      await _copyDirectory(appDir, targetDir);
    }
  }
  
  // ডিরেক্টরি কপি করা
  Future<void> _copyDirectory(Directory source, Directory target) async {
    // ডিরেক্টরি কপি লজিক
  }
}


---

## ১১. টেস্টিং

### ১১.১. ডেটাবেস টেস্ট

dart
// test/database_service_test.dart
void main() {
  group('DatabaseService Tests', () {
    test('should create database successfully', () async {
      final service = DatabaseService();
      final db = await service.database;
      expect(db, isNotNull);
    });
    
    test('should create chat successfully', () async {
      final service = ChatService(dbService: DatabaseService());
      final chat = await service.createChat(
        deviceName: 'Test Device',
        connectionType: 'wifi',
      );
      expect(chat.deviceName, 'Test Device');
    });
  });
}


---

## ১২. ডেভেলপমেন্ট গাইডলাইন

### ১২.১. কোডিং স্ট্যান্ডার্ড

- ক্লিন এবং মডুলার কোড স্ট্রাকচার
- প্রপার এরর হ্যান্ডলিং
- অ্যাসিঙ্ক্রোনাস অপারেশনের জন্য async/await ব্যবহার
- কমেন্ট এবং ডকুমেন্টেশন

### ১২.২. পারফরম্যান্স অপ্টিমাইজেশন

- ডেটাবেস কোয়েরি অপ্টিমাইজ করা
- ইমেজ কমপ্রেশন ব্যবহার করা
- ফাইল ক্যাশিং ব্যবহার করা
- মেমোরি লিক প্রতিরোধ করা

---

## ১৩. ডেলিভারেবলস

১. ডেটাবেস সার্ভিস ইমপ্লিমেন্টেশন
২. চ্যাট সার্ভিস এবং মডেল
৩. মেসেজ সার্ভিস এবং মডেল
৪. ফাইল স্টোরেজ সার্ভিস
৫. ইমেজ সার্ভিস
৬. ভয়েস রেকর্ডিং সার্ভিস
৭. রিপোজিটরি প্যাটার্ন ইমপ্লিমেন্টেশন
৮. ডেটা ব্যাকআপ সার্ভিস
৯. ডেটাবেস টেস্ট কোড

---

## ১৪. নোট

- আপনাকে শুধুমাত্র ডেটা স্টোরেজ এবং চ্যাট হিস্টরি ম্যানেজমেন্ট ডেভেলপ করতে হবে
- UI ডিজাইন এবং নেটওয়ার্কিং অন্য ডেভেলপাররা করবে
- আপনাকে UI ডেভেলপার এবং নেটওয়ার্কিং ডেভেলপারের সাথে কোড ইন্টিগ্রেট করতে হবে
- সকল এরর মেসেজ ইংরেজিতে থাকবে</li>
</ol>
