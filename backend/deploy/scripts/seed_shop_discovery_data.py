from datetime import timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone

from apps.deals.models import Deal, DealStatus, DealType
from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.shops.models import Shop


def seed_shop_discovery_data():
    User = get_user_model()

    user, created_user = User.objects.get_or_create(
        email="seed.merchant@localboost.com",
        defaults={
            "username": "seed_merchant_localboost",
            "role": "merchant",
            "is_active": True,
        },
    )
    if created_user:
        user.set_password("SeedMerchant!2026")
        user.save(update_fields=["password"])

    if user.role != "merchant":
        user.role = "merchant"
        user.save(update_fields=["role"])

    merchant, _ = MerchantProfile.objects.get_or_create(
        user=user,
        defaults={
            "business_name": "Ocean Cafe Seed",
            "status": MerchantStatus.ACTIVE,
        },
    )

    merchant_updates = []
    if merchant.business_name != "Ocean Cafe Seed":
        merchant.business_name = "Ocean Cafe Seed"
        merchant_updates.append("business_name")
    if merchant.status != MerchantStatus.ACTIVE:
        merchant.status = MerchantStatus.ACTIVE
        merchant_updates.append("status")
    if merchant_updates:
        merchant.save(update_fields=merchant_updates)

    shop, _ = Shop.objects.get_or_create(
        slug="ocean-cafe-seed",
        defaults={
            "merchant": merchant,
            "name": "Ocean Cafe Seed",
            "category": "cafe",
            "description": "Seeded production shop for discovery verification.",
            "logo_url": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300",
            "cover_image_url": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200",
            "phone_number": "+253700555000",
            "address_line_1": "Avenue 26",
            "city": "Djibouti",
            "country": "Djibouti",
            "latitude": 11.588000,
            "longitude": 43.145000,
            "is_active": True,
        },
    )

    shop_target = {
        "merchant": merchant,
        "name": "Ocean Cafe Seed",
        "category": "cafe",
        "description": "Seeded production shop for discovery verification.",
        "logo_url": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300",
        "cover_image_url": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200",
        "phone_number": "+253700555000",
        "address_line_1": "Avenue 26",
        "city": "Djibouti",
        "country": "Djibouti",
        "latitude": 11.588000,
        "longitude": 43.145000,
        "is_active": True,
    }
    shop_updates = []
    for field_name, target_value in shop_target.items():
        current_value = getattr(shop, field_name)
        if current_value != target_value:
            setattr(shop, field_name, target_value)
            shop_updates.append(field_name)
    if shop_updates:
        shop.save(update_fields=shop_updates)

    now = timezone.now()

    deal, _ = Deal.objects.get_or_create(
        shop=shop,
        title="Seed 20% Breakfast Deal",
        defaults={
            "description": "Production seed deal for API verification.",
            "deal_type": DealType.PERCENTAGE,
            "status": DealStatus.PUBLISHED,
            "starts_at": now - timedelta(days=1),
            "ends_at": now + timedelta(days=7),
        },
    )

    deal_target = {
        "description": "Production seed deal for API verification.",
        "deal_type": DealType.PERCENTAGE,
        "status": DealStatus.PUBLISHED,
        "starts_at": now - timedelta(days=1),
        "ends_at": now + timedelta(days=7),
    }
    deal_updates = []
    for field_name, target_value in deal_target.items():
        current_value = getattr(deal, field_name)
        if current_value != target_value:
            setattr(deal, field_name, target_value)
            deal_updates.append(field_name)
    if deal_updates:
        deal.save(update_fields=deal_updates)

    loyalty, _ = LoyaltyProgram.objects.get_or_create(
        shop=shop,
        name="Seed Ocean Stamps",
        defaults={
            "description": "Seed loyalty program for production discovery.",
            "reward_label": "Free drink",
            "stamps_required": 10,
            "is_active": True,
        },
    )

    loyalty_target = {
        "description": "Seed loyalty program for production discovery.",
        "reward_label": "Free drink",
        "stamps_required": 10,
        "is_active": True,
    }
    loyalty_updates = []
    for field_name, target_value in loyalty_target.items():
        current_value = getattr(loyalty, field_name)
        if current_value != target_value:
            setattr(loyalty, field_name, target_value)
            loyalty_updates.append(field_name)
    if loyalty_updates:
        loyalty.save(update_fields=loyalty_updates)

    print(
        "SEEDED "
        f"user_id={user.id} "
        f"merchant_id={merchant.id} "
        f"shop_id={shop.id} "
        f"deal_id={deal.id} "
        f"loyalty_id={loyalty.id}"
    )


seed_shop_discovery_data()
