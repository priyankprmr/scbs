String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone is required';
  if (value.trim().length < 10) return 'Enter a valid phone number';
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.trim().isEmpty) return 'Price is required';
  final price = double.tryParse(value.trim());
  if (price == null || price <= 0) return 'Enter a valid price';
  return null;
}
