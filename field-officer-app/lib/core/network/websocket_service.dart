import 'dart:async';

enum WebSocketEventType {
  fieldTaskAssigned,
  fieldTaskUpdated,
  fieldVisitSubmitted,
  fieldVisitVerified,
  fieldVisitRejected,
  notificationCreated,
}

class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  WebSocketEvent({
    required this.type,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

abstract class IWebSocketService {
  Stream<WebSocketEvent> get eventStream;
  Future<void> connect(String token);
  Future<void> disconnect();
  bool get isConnected;
}

class MockWebSocketService implements IWebSocketService {
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  bool _connected = false;

  @override
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect(String token) async {
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  void emitMockEvent(WebSocketEvent event) {
    if (_connected && !_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void dispose() {
    _eventController.close();
  }
}
