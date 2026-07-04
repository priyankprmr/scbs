import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String address;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.notes = '',
    required this.createdAt,
  });

  factory Customer.create({
    required String name,
    required String phone,
    String address = '',
    String notes = '',
  }) {
    return Customer(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      address: address,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address, notes, createdAt];
}
