class PriceUtils {
  PriceUtils._();

  static int? parseToInt(String value) {
    final cleaned = value
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(cleaned);
    if (parsed == null) {
      return null;
    }

    return parsed.round();
  }

  static String formatAmount(int amount) {
    final formattedDigits = _groupDigits(amount.abs().toString());
    return '₩ $formattedDigits';
  }

  static String formatFromString(String value) {
    final amount = parseToInt(value);
    if (amount == null) {
      return value;
    }
    return formatAmount(amount);
  }

  static String _groupDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
