from django.db import migrations, models


class Migration(migrations.Migration):
    """
    Add composite index to Deal for the Exists subquery used in shop discovery:
      Deal.objects.filter(shop_id=..., status=PUBLISHED, starts_at__lte=now, ends_at__gte=now)
    The leading columns are (shop_id, status) since those are equality filters.
    """

    dependencies = [
        ("deals", "0003_alter_deal_ends_at_alter_deal_starts_at"),
    ]

    operations = [
        migrations.AddIndex(
            model_name="deal",
            index=models.Index(
                fields=["shop", "status", "starts_at", "ends_at"],
                name="deal_shop_status_dates_idx",
            ),
        ),
    ]
