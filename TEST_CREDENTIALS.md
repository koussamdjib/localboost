# LocalBoost - Comptes de Test

## 📋 Comptes Merchant Disponibles

### Merchant Test 1 (Seed Data)
```
Email: seed.merchant@localboost.com
Username: seed_merchant_localboost
Password: SeedMerchant!2026
Role: merchant
```

### Merchant Test Deployment
```
Email: test_deploy_m1@test.com
Password: DeployTest123!
Role: merchant
```

### Merchant Test Validation
```
Email: test_merchant_crud_01@test.com
Password: TestPass123!
Role: merchant
```

### Merchant Test Alternative 2
```
Email: valtest_m1@test.com
Password: TestPass123!
Role: merchant
```

### Merchant Loyalty Test
```
Email: merchant_loyalty@localboost.test
Username: merchant_loyalty_1
Password: merchant-password-123
Role: merchant
```

### Merchant Alternative 2 (Loyalty)
```
Email: merchant_loyalty_2@localboost.test
Username: merchant_loyalty_2
Password: merchant-password-123
Role: merchant
```

---

## 👥 Comptes Client (Customer)

### Customer PROD Vérifié 1 (valide au 13/03/2026)
```
Email: client.live.20260313@localboost.test
Password: ClientLive!2026
Role: customer
```

### Customer PROD Vérifié 2 (backup)
```
Email: client.backup.20260313@localboost.test
Password: ClientBackup!2026
Role: customer
```

### Anciens comptes client (tests locaux uniquement)
- `customer_loyalty@localboost.test`
- `customer@localboost.test`
- `customer_public@localboost.test`
- Ces comptes retournent `401 Unauthorized` sur le backend production.

---

## 🔐 Comment Se Connecter

### Via API (Obtenir JWT Token)

```bash
curl -X POST "https://sirius-djibouti.com/api/v1/auth/token/" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "client.live.20260313@localboost.test",
    "password": "ClientLive!2026"
  }'
```

**Response (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "email": "seed.merchant@localboost.com",
    "username": "seed_merchant_localboost",
    "role": "merchant"
  }
}
```

### Via Flutter App

1. **Merchant App:**
   - Accédez à l'écran de connexion
   - Email: `seed.merchant@localboost.com` (ou n'importe quel compte merchant ci-dessus)
   - Mot de passe: `SeedMerchant!2026`

2. **Client App:**
   - Accédez à l'écran de connexion
    - Email: `client.live.20260313@localboost.test`
    - Mot de passe: `ClientLive!2026`

---

## 📝 Notes Importantes

### Pour Créer de Nouveaux Comptes de Test

#### Via Django Shell:
```bash
cd backend
python manage.py shell
```

```python
from django.contrib.auth import get_user_model
from apps.merchants.models import MerchantProfile
from apps.customers.models import CustomerProfile

User = get_user_model()

# Créer un merchant
user = User.objects.create_user(
    email='new_merchant@test.com',
    password='TestPass123!',
    role='merchant'
)
MerchantProfile.objects.create(user=user, business_name='Mon Magasin')

# Créer un client
user = User.objects.create_user(
    email='new_customer@test.com',
    password='TestPass123!',
    role='customer'
)
CustomerProfile.objects.create(user=user)
```

#### Via API (Registration):
```bash
curl -X POST "http://localhost:8000/api/v1/accounts/register/" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "new_merchant@test.com",
    "password": "TestPass123!",
    "name": "Mon Magasin",
    "role": "merchant"
  }'
```

---

## 🛍️ Données de Test Associées

### Shops (Magasins) Test

**Ocean Cafe (Seed Data):**
- Merchant: seed.merchant@localboost.com
- Name: Ocean Cafe Seed
- Location: Avenue 26, Djibouti
- Status: ACTIVE
- Latitude: 11.588
- Longitude: 43.145

---

## 🔗 Endpoints Utiles

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/accounts/register/` | POST | Créer un nouveau compte |
| `/api/v1/accounts/login/` | POST | Se connecter (obtenir token JWT) |
| `/api/v1/accounts/me/` | GET | Voir le profil courant |
| `/api/v1/merchant/shops/` | GET/POST | Liste/Créer des magasins (merchant) |
| `/api/v1/customer/enrollments/` | GET/POST | Liste/Créer des inscriptions (customer) |
| `/api/v1/health/` | GET | Vérifier la santé du serveur |
| `/api/v1/health/db/` | GET | Vérifier la base de données |
| `/api/v1/health/cache/` | GET | Vérifier le cache |

---

## ⚠️ Restrictions de Sécurité (Testing Only)

⚠️ **Ces comptes sont pour le testing uniquement.**  
- Les mots de passe ne respectent pas les standards de production
- À ne pas utiliser pour la production
- À régénérer régulièrement pour les tests
- Les données peuvent être supprimées/réinitialisées à tout moment

---

**Généré:** March 13, 2026  
**Validité:** À utiliser pour les tests de développement et QA seulement
