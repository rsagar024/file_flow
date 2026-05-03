extension StringExtension on String? {
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get capitalize => this![0].toUpperCase() + this!.substring(1);

  String? get getTimeStamp => RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch(this ?? '')?.group(1);

  bool get isNetworkUrl {
    if (this == null) return false;
    final uri = Uri.tryParse(this!);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}
