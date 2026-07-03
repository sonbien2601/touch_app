class InviteCode {
  const InviteCode._(this.value);

  final String value;

  static const length = 6;
  static final _pattern = RegExp(r'^[A-Z0-9]{6}$');

  static InviteCode parse(String input) {
    final normalized = input.trim().toUpperCase();
    if (!_pattern.hasMatch(normalized)) {
      throw const FormatException('Pairing code must contain 6 letters or numbers.');
    }

    return InviteCode._(normalized);
  }
}

