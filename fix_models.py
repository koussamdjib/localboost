"""Edit backend model files for QR token redesign."""
import re

# --- enrollments/models.py ---
path = r'backend\apps\enrollments\models.py'
with open(path, 'r', newline='') as f:
    text = f.read()

# Replace first import block
old = 'from django.db import models\r\n\r\nfrom apps.common.models import TimeStampedModel'
new = 'import uuid\r\n\r\nfrom django.db import models\r\nfrom apps.common.models import TimeStampedModel'
assert old in text, f'Pattern not found in {path}'
text = text.replace(old, new, 1)

# Add qr_token before class Meta
old = '\tlast_activity_at = models.DateTimeField(null=True, blank=True)\r\n\r\n\tclass Meta:'
new = (
    '\tlast_activity_at = models.DateTimeField(null=True, blank=True)\r\n'
    '\tqr_token = models.UUIDField(\r\n'
    '\t\tdefault=uuid.uuid4,\r\n'
    '\t\tunique=True,\r\n'
    '\t\teditable=False,\r\n'
    '\t\tdb_index=True,\r\n'
    '\t)\r\n'
    '\r\n'
    '\tclass Meta:'
)
assert old in text, f'Pattern (qr_token) not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# --- transactions/models.py ---
path = r'backend\apps\transactions\models.py'
with open(path, 'r', newline='') as f:
    text = f.read()

old = '\tnotes = models.TextField(blank=True)\r\n\r\n\tdef __str__(self):'
new = (
    '\tnotes = models.TextField(blank=True)\r\n'
    '\tidempotency_key = models.CharField(max_length=64, blank=True, db_index=True)\r\n'
    '\r\n'
    '\tclass Meta:\r\n'
    '\t\tconstraints = [\r\n'
    '\t\t\tmodels.UniqueConstraint(\r\n'
    '\t\t\t\tfields=[\'enrollment\', \'idempotency_key\'],\r\n'
    '\t\t\t\tcondition=models.Q(idempotency_key__gt=\'\'),\r\n'
    '\t\t\t\tname=\'uq_stamp_transaction_idempotency\',\r\n'
    '\t\t\t)\r\n'
    '\t\t]\r\n'
    '\r\n'
    '\tdef __str__(self):'
)
assert old in text, f'Pattern not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

print('All done.')
