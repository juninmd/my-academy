import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  const PlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
  });
  final int id;
  final String name;
  final double price;
  final int durationMonths;

  @override
  List<Object?> get props => [id, name, price, durationMonths];
}

class GymEntity extends Equatable {
  const GymEntity({
    required this.id,
    required this.name,
    this.address,
    this.plans = const [],
  });
  final int id;
  final String name;
  final String? address;
  final List<PlanEntity> plans;

  @override
  List<Object?> get props => [id, name, address, plans];
}

class MemberEntity extends Equatable {
  const MemberEntity({
    required this.subscriptionId,
    required this.name,
    required this.email,
    required this.status,
    required this.startDate,
    this.endDate,
    this.planName,
  });
  final int subscriptionId;
  final String name;
  final String email;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? planName;

  @override
  List<Object?> get props => [subscriptionId, status, endDate];
}

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.memberName,
    this.planName,
  });
  final int id;
  final double amount;
  final String status;
  final DateTime date;
  final String memberName;
  final String? planName;

  @override
  List<Object?> get props => [id, amount, status, date];
}

class GymDashboardEntity extends Equatable {
  const GymDashboardEntity({
    required this.activeMembers,
    required this.pendingPayments,
    required this.overduePayments,
    required this.revenueThisMonth,
  });
  final int activeMembers;
  final int pendingPayments;
  final int overduePayments;
  final double revenueThisMonth;

  @override
  List<Object?> get props => [
    activeMembers,
    pendingPayments,
    overduePayments,
    revenueThisMonth,
  ];
}

/// A student's own membership, shown on their profile.
class MembershipEntity extends Equatable {
  const MembershipEntity({
    required this.gymName,
    required this.status,
    this.planName,
    this.endDate,
    this.pendingPayments = 0,
  });
  final String gymName;
  final String status;
  final String? planName;
  final DateTime? endDate;
  final int pendingPayments;

  @override
  List<Object?> get props => [gymName, status, planName, endDate];
}
