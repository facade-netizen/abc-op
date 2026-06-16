import 'dart:typed_data';

import 'send/send.pb.dart';

class ProtoHandler {
  // Method to send Data
  Uint8List serializeSendData(String command) {
    Command data = Command(command: command);
    return data.writeToBuffer();
  }
}
