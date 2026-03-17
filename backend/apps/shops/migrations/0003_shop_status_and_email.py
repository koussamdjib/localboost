from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("shops", "0002_shop_category_shop_cover_image_url_shop_logo_url_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="shop",
            name="email",
            field=models.EmailField(blank=True, max_length=254),
        ),
        migrations.AddField(
            model_name="shop",
            name="status",
            field=models.CharField(
                choices=[
                    ("draft", "Draft"),
                    ("active", "Active"),
                    ("suspended", "Suspended"),
                    ("archived", "Archived"),
                ],
                db_index=True,
                default="active",
                max_length=20,
            ),
        ),
    ]
