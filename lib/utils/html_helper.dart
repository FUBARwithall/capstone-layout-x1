String htmlToPlainText(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
}

String getFirstSentence(String? text) {
  if (text == null || text.isEmpty) return '';
  final sentences = text.split(RegExp(r'[.!?]'));
  if (sentences.isEmpty) return text;
  String firstSentence = sentences[0].trim();
  if (!firstSentence.endsWith('.') &&
      !firstSentence.endsWith('!') &&
      !firstSentence.endsWith('?')) {
    firstSentence += '.';
  }
  return firstSentence;
}