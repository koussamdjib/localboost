"""Add qrToken field to shared/lib/models/enrollment.dart"""
path = r'shared\lib\models\enrollment.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# 1. Add qrToken to class fields (after rewardRequestId)
old = '  final int? rewardRequestId;\r\n\r\n  Enrollment({'
new = '  final int? rewardRequestId;\r\n  final String qrToken;\r\n\r\n  Enrollment({'
assert old in text, '1: field decl site not found'
text = text.replace(old, new, 1)

# 2. Add qrToken to constructor params (after rewardRequestId)
old = '    this.rewardStatus,\r\n    this.rewardRequestId,\r\n  });'
new = '    this.rewardStatus,\r\n    this.rewardRequestId,\r\n    this.qrToken = \'\',\r\n  });'
assert old in text, '2: constructor param not found'
text = text.replace(old, new, 1)

# 3. Add qrToken to fromJson factory (after rewardRequestId)
old = '      rewardRequestId: json[\'reward_request_id\'] as int?,\r\n    );'
new = ('      rewardRequestId: json[\'reward_request_id\'] as int?,\r\n'
       '      qrToken: (json[\'qr_token\'] as String?) ?? \'\',\r\n'
       '    );')
assert old in text, '3: fromJson site not found'
text = text.replace(old, new, 1)

# 4. Add qrToken to toJson (after rewardRequestId)
old = "      'reward_request_id': rewardRequestId,\r\n    };"
new = ("      'reward_request_id': rewardRequestId,\r\n"
       "      'qr_token': qrToken,\r\n"
       "    };")
assert old in text, '4: toJson site not found'
text = text.replace(old, new, 1)

# 5. Add qrToken param to copyWith signature (after rewardRequestId)
old = '    int? rewardRequestId,\r\n    bool clearRewardStatus = false,'
new = '    int? rewardRequestId,\r\n    String? qrToken,\r\n    bool clearRewardStatus = false,'
assert old in text, '5: copyWith param not found'
text = text.replace(old, new, 1)

# 6. Add qrToken body to copyWith return (after rewardRequestId)
old = '      rewardStatus: clearRewardStatus ? null : (rewardStatus ?? this.rewardStatus),\r\n      rewardRequestId: clearRewardStatus ? null : (rewardRequestId ?? this.rewardRequestId),\r\n    );'
new = ('      rewardStatus: clearRewardStatus ? null : (rewardStatus ?? this.rewardStatus),\r\n'
       '      rewardRequestId: clearRewardStatus ? null : (rewardRequestId ?? this.rewardRequestId),\r\n'
       '      qrToken: qrToken ?? this.qrToken,\r\n'
       '    );')
assert old in text, '6: copyWith body not found'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
