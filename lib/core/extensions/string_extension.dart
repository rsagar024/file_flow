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

  String get maskEmail {
    final parts = this?.split('@');

    if (parts?.length != 2) return this ?? '';

    final username = parts![0];
    final domain = parts[1];

    // Don't mask if username is too short
    if (username.length <= 4) {
      return this!;
    }

    final first = username.substring(0, 2);
    final last = username.substring(username.length - 2);
    final masked = '*' * (username.length - 4);

    return '$first$masked$last@$domain';
  }
}
