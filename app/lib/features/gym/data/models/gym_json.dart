import '../../domain/entities/gym_entities.dart';

typedef Json = Map<String, dynamic>;

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

PlanEntity planFromJson(Json j) => PlanEntity(
  id: j['id'] as int,
  name: j['name'] as String,
  price: (j['price'] as num).toDouble(),
  durationMonths: j['durationMonths'] as int,
);

GymEntity gymFromJson(Json j) => GymEntity(
  id: j['id'] as int,
  name: j['name'] as String,
  address: j['address'] as String?,
  plans: [
    for (final p in (j['plans'] as List? ?? const [])) planFromJson(p as Json),
  ],
);

MemberEntity memberFromJson(Json j) {
  final user = j['user'] as Json? ?? const {};
  return MemberEntity(
    subscriptionId: j['id'] as int,
    name: user['name'] as String? ?? '—',
    email: user['email'] as String? ?? '',
    status: j['status'] as String,
    startDate: DateTime.parse(j['startDate'] as String),
    endDate: _date(j['endDate']),
    planName: (j['plan'] as Json?)?['name'] as String?,
  );
}

PaymentEntity paymentFromJson(Json j) => PaymentEntity(
  id: j['id'] as int,
  amount: (j['amount'] as num).toDouble(),
  status: j['status'] as String,
  date: DateTime.parse(j['date'] as String),
  memberName: (j['user'] as Json?)?['name'] as String? ?? '—',
  planName:
      ((j['subscription'] as Json?)?['plan'] as Json?)?['name'] as String?,
);

GymDashboardEntity dashboardFromJson(Json j) => GymDashboardEntity(
  activeMembers: j['activeMembers'] as int,
  pendingPayments: j['pendingPayments'] as int,
  overduePayments: j['overduePayments'] as int,
  revenueThisMonth: (j['revenueThisMonth'] as num).toDouble(),
);

MembershipEntity membershipFromJson(Json j) => MembershipEntity(
  gymName: (j['gym'] as Json?)?['name'] as String? ?? '—',
  status: j['status'] as String,
  planName: (j['plan'] as Json?)?['name'] as String?,
  endDate: _date(j['endDate']),
  pendingPayments:
      (j['payments'] as List? ?? const [])
          .where((p) => (p as Json)['status'] != 'PAID')
          .length,
);
