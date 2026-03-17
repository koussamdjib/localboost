from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("deals", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="deal",
            name="share_count",
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="deal",
            name="view_count",
            field=models.PositiveIntegerField(default=0),
        ),
    ]
