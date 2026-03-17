class LoyaltyProgramSummary {
  final int id;
  final String name;
  final int stampsRequired;
  final String rewardLabel;

  LoyaltyProgramSummary({
    required this.id,
    required this.name,
    required this.stampsRequired,
    required this.rewardLabel,
  });

  factory LoyaltyProgramSummary.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramSummary(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      stampsRequired: (json['stamps_required'] as int?) ?? 10,
      rewardLabel: (json['reward_label'] as String?) ?? '',
    );
  }
}
