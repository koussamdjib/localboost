from django.contrib.auth import get_user_model

from apps.merchants.models import MerchantProfile
from apps.shops.models import Shop

SEED_EMAIL = "seed.merchant@localboost.com"
SEED_SHOP_SLUG = "ocean-cafe-seed"


def cleanup_seed_data():
    User = get_user_model()

    deleted_shop = False
    deleted_merchant = False
    deleted_user = False

    shop = Shop.objects.filter(slug=SEED_SHOP_SLUG).first()
    if shop is not None:
        shop.delete()
        deleted_shop = True

    merchant = MerchantProfile.objects.filter(user__email__iexact=SEED_EMAIL).first()
    if merchant is not None and not merchant.shops.exists():
        merchant.delete()
        deleted_merchant = True

    user = User.objects.filter(email__iexact=SEED_EMAIL).first()
    if user is not None:
        has_merchant_profile = MerchantProfile.objects.filter(user=user).exists()
        if not has_merchant_profile and not user.is_superuser:
            user.delete()
            deleted_user = True

    print(
        "CLEANUP_RESULT "
        f"shop_deleted={deleted_shop} "
        f"merchant_deleted={deleted_merchant} "
        f"user_deleted={deleted_user}"
    )


cleanup_seed_data()
