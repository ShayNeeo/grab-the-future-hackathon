class SmsMessage {
  final String? address;
  final String? body;

  SmsMessage({this.address, this.body});
}

class Telephony {
  static final Telephony instance = Telephony._();
  Telephony._();

  Future<bool?> get requestPhoneAndSmsPermissions async => false;

  void listenIncomingSms({
    required Function(SmsMessage) onNewMessage,
    required Function(SmsMessage) onBackgroundMessage,
  }) {}
}
