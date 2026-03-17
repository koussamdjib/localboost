from django.db import migrations, models


class Migration(migrations.Migration):
    """
    Add composite indexes to Shop for the two most common query filters:
    - (is_active, status): used on every shop list/search/discovery call
    - (latitude, longitude): speeds up the bounding-box range filter for geo queries
    """

    dependencies = [
        ("shops", "0004_shop_business_hours"),
    ]

    operations = [
        migrations.AddIndex(
            model_name="shop",
            index=models.Index(
                fields=["is_active", "status"],
                name="shop_is_active_status_idx",
            ),
        ),
        migrations.AddIndex(
            model_name="shop",
            index=models.Index(
                fields=["latitude", "longitude"],
                name="shop_lat_lng_idx",
            ),
        ),
    ]
