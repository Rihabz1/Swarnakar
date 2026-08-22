String normalizeBdPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('880') && digits.length == 13) {
    return digits.substring(2);
  }
  if (digits.startsWith('88') && digits.length == 13) {
    return digits.substring(2);
  }
  return digits;
}

bool isValidBdMobile(String value) => RegExp(r'^01[3-9]\d{8}$').hasMatch(value);
