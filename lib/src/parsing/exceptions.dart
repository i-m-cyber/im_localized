class L10nException implements Exception {
  L10nException(this.message);

  final String message;

  @override
  String toString() => message;
}

class L10nParserException extends L10nException {
  L10nParserException(this.error, this.fileName, this.messageId,
      this.messageString, this.charNumber)
      : super('''
[$fileName:$messageId] $error
    $messageString
    ${List<String>.filled(charNumber, ' ').join()}^''');

  final String error;
  final String fileName;
  final String messageId;
  final String messageString;
  // Position of character within the "messageString" where the error is.
  final int charNumber;
}
