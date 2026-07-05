import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

import '../../core/constants/app_constants.dart';

part 'settings.g.dart';

@HiveType(typeId: 4)
class Settings extends Equatable {
  @HiveField(0)
  final String businessName;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String invoicePrefix;

  @HiveField(4)
  final int invoiceCounter;

  @HiveField(5)
  final int guaranteeMonths;

  const Settings({
    required this.businessName,
    this.address = '',
    this.phone = '',
    required this.invoicePrefix,
    required this.invoiceCounter,
    this.guaranteeMonths = 6,
  });

  factory Settings.defaults() {
    return const Settings(
      businessName: defaultBusinessName,
      invoicePrefix: defaultInvoicePrefix,
      invoiceCounter: defaultInvoiceCounter,
      guaranteeMonths: 6,
    );
  }

  Settings copyWith({
    String? businessName,
    String? address,
    String? phone,
    String? invoicePrefix,
    int? invoiceCounter,
    int? guaranteeMonths,
  }) {
    return Settings(
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceCounter: invoiceCounter ?? this.invoiceCounter,
      guaranteeMonths: guaranteeMonths ?? this.guaranteeMonths,
    );
  }

  @override
  List<Object?> get props =>
      [businessName, address, phone, invoicePrefix, invoiceCounter, guaranteeMonths];
}
