from django.db import migrations, models
from django.db.models import F


def sync_existing_flyer_state(apps, schema_editor):
    Flyer = apps.get_model("flyers", "Flyer")

    Flyer.objects.filter(is_active=True).update(
        status="published",
        published_at=F("created_at"),
    )
    Flyer.objects.filter(is_active=False).update(status="draft")


class Migration(migrations.Migration):
    dependencies = [
        ("flyers", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="flyer",
            name="description",
            field=models.TextField(blank=True),
        ),
        migrations.AddField(
            model_name="flyer",
            name="file_url",
            field=models.URLField(blank=True),
        ),
        migrations.AddField(
            model_name="flyer",
            name="published_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="flyer",
            name="share_count",
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="flyer",
            name="status",
            field=models.CharField(
                choices=[
                    ("draft", "Draft"),
                    ("published", "Published"),
                    ("paused", "Paused"),
                    ("expired", "Expired"),
                ],
                db_index=True,
                default="draft",
                max_length=16,
            ),
        ),
        migrations.AddField(
            model_name="flyer",
            name="thumbnail_url",
            field=models.URLField(blank=True),
        ),
        migrations.AddField(
            model_name="flyer",
            name="view_count",
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AlterField(
            model_name="flyer",
            name="file",
            field=models.FileField(blank=True, null=True, upload_to="flyers/"),
        ),
        migrations.AlterField(
            model_name="flyer",
            name="is_active",
            field=models.BooleanField(default=False),
        ),
        migrations.RunPython(sync_existing_flyer_state, migrations.RunPython.noop),
    ]