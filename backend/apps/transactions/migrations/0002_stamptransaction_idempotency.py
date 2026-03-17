from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('transactions', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='stamptransaction',
            name='idempotency_key',
            field=models.CharField(blank=True, db_index=True, max_length=64, default=''),
            preserve_default=False,
        ),
        migrations.AddConstraint(
            model_name='stamptransaction',
            constraint=models.UniqueConstraint(
                condition=models.Q(idempotency_key__gt=''),
                fields=['enrollment', 'idempotency_key'],
                name='uq_stamp_transaction_idempotency',
            ),
        ),
    ]
