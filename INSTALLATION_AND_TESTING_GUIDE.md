# 📱 Guide d'Installation et Tests - LocalBoost Beta

## PARTIE 1: INSTALLATION CLIENT SUR TÉLÉPHONE

### 🔧 Prérequis
- Téléphone Android avec ADB configuré
- USB Debug activé sur le téléphone
- Câble USB
- APK client généré: `client/build/app/outputs/apk/release/app-release.apk` (66.2 MB)

### 📥 Étape 1: Installer l'APK Client

```bash
# Connecter le téléphone en USB et vérifier la connexion
adb devices

# Installer l'APK
adb install client/build/app/outputs/apk/release/app-release.apk

# Vérifier l'installation
adb shell pm list packages | grep localboost
```

**Output attendu:**
```
package:com.localboost.client
```

### ✅ Étape 2: Vérifier l'Installation
1. Sur le téléphone, aller dans **Paramètres → Applications**
2. Chercher **Localboost Client**
3. Taper sur l'app pour lancer
4. Accepter les permissions de localisation si demandé

### 📍 Étape 3: Tester la Connexion
1. **Écran de connexion s'affiche?** ✓ Succès!
2. Utiliser les credentials (voir TEST_CREDENTIALS.md):
   ```
   Email: customer_loyalty@localboost.test
   Password: customer-password-123
   ```

---

## PARTIE 2: TESTS CRUD CÔTÉ MERCHANT APP

### 🏪 Prérequis (Merchant Side)
- Merchant app installée (debug APK)
- Compte merchant créé: `seed.merchant@localboost.com` / `SeedMerchant!2026`
- Magasin créé avec au moins un shop actif

---

## 📋 TEST 1: PROGRAMMES DE FIDÉLITÉ (LOYALTY / FIDELITE)

### ✨ Workflow Complet: CREATE → READ → UPDATE → DELETE

#### 1️⃣ CREATE (Créer un programme)

**Écran:** Merchant App → Tab "Fidélité" → Bouton "+" ou "Créer"

**Formulaire à remplir:**
```
Titre du programme:        "Récompense Café"
Description:               "Gagnez 1 café gratuit après 10 achats"
Nombre de timbres requis:  10
Description de récompense: "1 café moyen gratuit"
```

**Validation requise:**
- ✅ Titre: **OBLIGATOIRE** (min 1 caractère)
- ✅ Description: **OBLIGATOIRE** (min 1 caractère)
- ✅ Timbres: **OBLIGATOIRE** (min 1)
- ✅ Récompense: **OBLIGATOIRE** (min 1 caractère)

**Erreurs possibles & Solutions:**
```
❌ "Le nombre de timbres doit être au moins 1"
   → Vérifier que le champ "Nombre de timbres" ≥ 1
   → Ne pas laisser blanc ou 0

❌ "Erreur réseau"
   → Vérifier la connexion backend (http://localhost:8000 ou production URL)
   → Activer le mode debug pour voir les logs réseau

❌ "Permission refusée"
   → Vérifier que vous êtes connecté comme MERCHANT (pas customer)
   → Vérifier le token JWT est valide (relogin si nécessaire)
```

**Actions après Create:**
- [ ] Appuyer sur "Activer" (save as ACTIVE)
- [ ] Voir message: "Programme créé ✓"
- [ ] Voir le programme dans la liste (tab "Actifs")

---

#### 2️⃣ READ (Lire/Voir les programmes)

**Écran:** Merchant App → Tab "Fidélité"

**Vérifier:**
- [ ] Liste des programmes s'affiche
- [ ] Type de statut visible: "Actif", "Brouillon", "Pausé"
- [ ] Pour chaque programme:
  - [ ] Titre affiché
  - [ ] Description visible
  - [ ] Nombre de timbres requis affichés
  - [ ] Nombre d'inscrits affichés
  - [ ] Date de création visible
  - [ ] Boutons d'action: Edit, Delete, Pause/Resume

**Tests à faire:**
1. **Filter par statut:**
   - Tap tab "Actifs" → voir programmes actifs
   - Tap tab "Brouillons" → voir programmes en brouillon
   
2. **Voir détails:** Tap sur une carte de programme
   - Doit voir tous les détails du programme
   - Date de création/modification affichées

---

#### 3️⃣ UPDATE (Modifier un programme)

**Écran:** Tap sur un programme existant → Bouton "Modifier"

**Modifier:**
```
Titre:     "Récompense Café" → "Récompense Café Premium"
Description: (modifier le texte)
Timbres:   10 → 15
Récompense: "1 café moyen" → "1 café + pain au chocolat"
```

**Vérifier:**
- [ ] Les champs se pré-remplissent avec les données existantes
- [ ] Les modifications se sauvegardent
- [ ] Message de succès s'affiche: "Programme mis à jour"
- [ ] Les changements sont visibles immédiatement dans la liste

---

#### 4️⃣ DELETE (Supprimer un programme)

**Écran:** Tap sur un programme → Bouton "Supprimer"

**Actions:**
- [ ] Confirmation s'affiche: "Êtes-vous sûr?"
- [ ] Appuyer "Oui"
- [ ] Le programme disparaît de la liste
- [ ] Message: "Programme supprimé ✓"

---

## 📊 TEST 2: PROMOTIONS (DEALS / PROMOTION)

### ✨ Workflow Complet: CREATE → READ → UPDATE → DELETE

#### 1️⃣ CREATE (Créer une promotion)

**Écran:** Merchant App → Tab "Promotions" → Bouton "+" ou "Créer"

**Formulaire à remplir:**
```
Titre:            "Réduction Vendredi"
Description:      "30% de réduction tous les vendredis"
Type de promotion: PERCENTAGE (ou AMOUNT, STAMP)
Statut:           DRAFT
Date début:       2026-03-15
Date fin:         2026-03-31
Max rédemptions:  50 (optionnel)
```

**Validation requise:**
- ✅ Titre: **OBLIGATOIRE**
- ✅ Description: **OBLIGATOIRE**
- ✅ Type: **OBLIGATOIRE**
- ✅ Date début ≤ Date fin: **OBLIGATOIRE**
- ✅ Max rédemptions ≥ 1 si spécifié

**Erreurs possibles & Solutions:**
```
❌ "Date invalide"
   → Vérifier que date_fin > date_début
   → Format: MM/DD/YYYY

❌ "Max rédemptions invalide"
   → Vérifier que c'est un nombre ≥ 1
   → Laisser vide si pas de limite

❌ "Champ vide obligatoire"
   → Tous les champs avec * sont obligatoires
```

**Actions après Create:**
- [ ] Appuyer "Sauvegarder comme brouillon" ou "Publier"
- [ ] Voir message: "Promotion créée ✓"
- [ ] Voir la promotion dans la liste

---

#### 2️⃣ READ (Lire/Voir les promotions)

**Écran:** Merchant App → Tab "Promotions"

**Vérifier:**
- [ ] Liste des promotions s'affiche
- [ ] Pour chaque promotion:
  - [ ] Titre affiché
  - [ ] Description visible
  - [ ] Type de promotion visible
  - [ ] Statut visible: "Brouillon", "Publiée", "Expirée"
  - [ ] Dates de validité affichées
  - [ ] Nombre de rédemptions affichées
  - [ ] Boutons d'action: Edit, Delete, Publish (si brouillon)

---

#### 3️⃣ UPDATE (Modifier une promotion)

**Écran:** Tap sur une promotion → Bouton "Modifier"

**Modifier:**
```
Titre:    "Réduction Vendredi" → "Super Réduction Vendredi"
Descrip:  (mettre à jour le texte)
Max red:  50 → 100
Date fin: 2026-03-31 → 2026-04-30
```

**Vérifier:**
- [ ] Les champs se pré-remplissent correctement
- [ ] Les modifications se sauvegardent
- [ ] Message: "Promotion mise à jour ✓"
- [ ] Visibles immédiatement

---

#### 4️⃣ DELETE (Supprimer une promotion)

**Écran:** Tap sur une promotion → Bouton "Supprimer"

**Actions:**
- [ ] Confirmation s'affiche
- [ ] Appuyer "Oui"
- [ ] La promotion disparaît de la liste
- [ ] Message: "Promotion supprimée ✓"

---

## 📸 TEST 3: PROSPECTUS (FLYERS)

### ✨ Workflow Complet: CREATE → READ → UPDATE → DELETE

#### 1️⃣ CREATE (Créer un flyer)

**Écran:** Merchant App → Tab "Prospectus" → Bouton "+" ou "Créer"

**Formulaire à remplir:**
```
Titre:            "Nouvelle Collection Printemps"
Description:      "Découvrez nos nouveaux produits!"
Format:           IMAGE (ou PDF)
Statut:           DRAFT
Image:            (Upload image depuis galerie)
Date début:       2026-03-15  
Date fin:         2026-05-31
```

**Validation requise:**
- ✅ Titre: **OBLIGATOIRE**
- ✅ Description: **OBLIGATOIRE**
- ✅ Format: **OBLIGATOIRE** (IMAGE ou PDF)
- ✅ Image: **OBLIGATOIRE** si format IMAGE
- ✅ Date début ≤ Date fin

**Erreurs possibles & Solutions:**
```
❌ "Format de fichier non supporté"
   → Utiliser seulement: JPG, PNG, PDF
   → Taille max: 10 MB

❌ "Image non sélectionnée"
   → Tap bouton "Ajouter image"
   → Choisir depuis galerie

❌ "Dates invalides"
   → Date fin > Date début requise
```

**Actions après Create:**
- [ ] Appuyer "Sauvegarder comme brouillon" ou "Publier"
- [ ] Voir message: "Flyer créé ✓"
- [ ] Voir le flyer dans la liste

---

#### 2️⃣ READ (Lire/Voir les flyers)

**Écran:** Merchant App → Tab "Prospectus"

**Vérifier:**
- [ ] Liste des flyers s'affiche
- [ ] Thumbnails des images affichées
- [ ] Pour chaque flyer:
  - [ ] Titre visible
  - [ ] Description courte visible
  - [ ] Statut: "Brouillon", "Publié", "Expiré"
  - [ ] Dates de validité affichées
  - [ ] Nombre de vues (view_count) affichées
  - [ ] Nombre de partages (share_count) affichés
  - [ ] Boutons: Edit, Delete, Publish, View Stats

---

#### 3️⃣ UPDATE (Modifier un flyer)

**Écran:** Tap sur un flyer → Bouton "Modifier"

**Modifier:**
```
Titre:     "Nouvelle Collection" → "Grande Solde Printemps"
Descrip:   (mettre à jour)
Image:     (changer si besoin)
Date fin:  2026-05-31 → 2026-06-30
```

**Vérifier:**
- [ ] Données pré-remplissent correctement
- [ ] Image actuelle affichée
- [ ] Modifications sauvegardées
- [ ] Message: "Flyer mis à jour ✓"

---

#### 4️⃣ DELETE (Supprimer un flyer)

**Écran:** Tap sur un flyer → Bouton "Supprimer"

**Actions:**
- [ ] Confirmation s'affiche
- [ ] Appuyer "Oui"
- [ ] Le flyer disparaît de la liste
- [ ] Message: "Flyer supprimé ✓"

---

## 🐛 TROUBLESHOOTING - Erreurs Courantes

### Erreur: "Le nombre de timbres doit être au moins 1"

**Cause:** Le champ de timbres est vide ou = 0

**Solution:**
```dart
✅ BON:
  - Taper: 10 (ou nombre > 0)
  
❌ MAUVAIS:
  - Laisser le champ vide
  - Saisir: 0
  - Saisir: caractères (abc, xyz)
```

**Code validateur (backend):**
```python
def validate_stamps_required(self, value):
    if value < 1:
        raise ValidationError("Stamps required must be at least 1.")
    return value
```

---

### Erreur: "Permission refusée"

**Cause:** 
- Vous n'êtes pas millionnaire
- Token JWT expiré
- User n'a pas le rôle MERCHANT

**Solution:**
1. Logout complètement (Tab Profil → Logout)
2. Login à nouveau avec:
   ```
   Email: seed.merchant@localboost.com
   Password: SeedMerchant!2026
   ```
3. Vérifier que vous voyez "Merchant Dashboard" (pas "Customer Home")

---

### Erreur: "Erreur réseau / Connection timeout"

**Cause:** 
- Backend n'est pas accessible
- URL API incorrecte
-Connection WiFi/Mobile down

**Solution:**
1. Vérifier que backend fonctionne:
   ```bash
   curl http://localhost:8000/api/v1/health/
   ```
   Attendu: 200 avec `"status": "ok"`

2. Sur app settings modifier l'URL API si prod:
   ```dart
   // merchant/lib/config/api_config.dart
   static const String BASE_URL = 'https://your-production-domain.com';
   ```

3. Vérifier WiFi/données mobiles actifs

---

## ✅ CHECKLIST FINAL DE TEST

### Loyalty (Fidélité)
- [ ] CREATE: Créer un programme
- [ ] READ: Voir tous les programmes
- [ ] READ: Filtrer par statut (Actif/Brouillon)
- [ ] UPDATE: Modifier un programme existant
- [ ] DELETE: Supprimer un programme

### Deals (Promotion)
- [ ] CREATE: Créer une promotion avec dates valides
- [ ] READ: Voir toutes les promotions
- [ ] READ: Voir différents statuts
- [ ] UPDATE: Modifier type/dates
- [ ] DELETE: Supprimer une promotion

### Flyers (Prospectus)
- [ ] CREATE: Créer avec image uploadée
- [ ] READ: Voir tous les flyers avec thumbnails
- [ ] READ: Voir statistiques (vues, partages)
- [ ] UPDATE: Modifier image et dates
- [ ] DELETE: Supprimer un flyer

### Client App Integration
- [ ] INSTALL: APK installé sur téléphone
- [ ] LOGIN: Se connecter comme customer
- [ ] BROWSE: Voir les shops, deals, flyers du merchant
- [ ] ENROLL: S'inscrire à un programme de fidélité

---

## 📞 Support & Next Steps

Si vous avez une **erreur spécifique**, donnez-moi:
1. **Message d'erreur exact** (screenshot si possible)
2. **Compte utilisé** (merchant ou customer)
3. **Étape où ça s'est passé** (create, edit, delete)
4. **Backend logs** si disponible

**Pour plus d'infos:**
- Voir `TEST_CREDENTIALS.md` pour comptes
- Voir `BETA_READINESS_AUDIT_REPORT.md` pour architecture
- Check backend API docs à `/api/v1/`

---

**Status:** Ready for Beta Testing 🚀  
**Date:** March 13, 2026
