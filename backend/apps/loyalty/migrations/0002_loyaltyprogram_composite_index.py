from django.db import migrations, models


class Migration(migrations.Migration):
    """
    Add composite index to LoyaltyProgram for the Exists subquery used in shop
    discovery and for the prefetch_related filter:
      LoyaltyProgram.objects.filter(shop_id=..., is_active=True)
    """

    dependencies = [
        ("loyalty", "0001_initial"),
    ]

    operations = [
        migrations.AddIndex(
            model_name="loyaltyprogram",
            index=models.Index(
                fields=["shop", "is_active"],
                name="loyalty_shop_active_idx",
            ),
        ),
    ]
