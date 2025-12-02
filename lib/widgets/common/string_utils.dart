class StringUtils {
  static String capitalize(String input) {
    if (input.isEmpty) return '';
    return '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
  }

  // Optionally add other string utility methods
  static String capitalizeAllWords(String input) {
    if (input.isEmpty) return '';
    return input.split(' ').map((word) => capitalize(word)).join(' ');
  }
}