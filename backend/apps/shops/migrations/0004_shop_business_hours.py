from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("shops", "0003_shop_status_and_email"),
    ]

    operations = [
        migrations.AddField(
            model_name="shop",
            name="business_hours",
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
