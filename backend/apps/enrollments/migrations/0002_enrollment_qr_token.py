import uuid

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('enrollments', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='enrollment',
            name='qr_token',
            field=models.UUIDField(
                default=uuid.uuid4,
                editable=False,
                unique=True,
                db_index=True,
            ),
        ),
    ]
