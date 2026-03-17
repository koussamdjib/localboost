part of '../my_cards_page.dart';

extension _MyCardsPageData on _MyCardsPageState {
  List<Shop> get _filteredShops {
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);
    final allEnrollments = enrollmentProvider.enrollments;
    var filteredEnrollments = allEnrollments;

    bool hasOpenRewardRequest(Enrollment e) =>
        e.rewardStatus == RewardRequestStatus.requested ||
        e.rewardStatus == RewardRequestStatus.approved;

    switch (_selectedFilter) {
      case 'Actifs':
        filteredEnrollments = filteredEnrollments
            .where(
              (e) => !e.isRedeemed &&
                  !e.canRequestReward &&
                  !hasOpenRewardRequest(e),
            )
            .toList(growable: false);
        break;
      case 'Complétés':
        filteredEnrollments = filteredEnrollments
            .where((e) => e.canRequestReward || hasOpenRewardRequest(e))
            .toList(growable: false);
        break;
      case 'Utilisés':
        filteredEnrollments = filteredEnrollments
            .where((e) => e.isRedeemed)
            .toList(growable: false);
        break;
      case 'Tous':
      default:
        break;
    }

    final enrollmentShops = _toEnrollmentShops(filteredEnrollments);

    final enrolledShopIds = allEnrollments
        .map((enrollment) => enrollment.shopId)
        .toSet();

    final enrolledProgramIds = allEnrollments
        .where((e) => e.loyaltyProgramId != null)
        .map((e) => e.loyaltyProgramId!)
        .toSet();

    final marketOffers = _marketplaceOffers.where((offer) {
      if (offer.dealType != 'Loyalty') {
        return true;
      }
      // For per-program cards (with loyaltyProgramId), filter by program.
      if (offer.loyaltyProgramId != null) {
        return !enrolledProgramIds.contains(offer.loyaltyProgramId);
      }
      // Fallback: filter by shop ID for legacy/single-program cards.
      return !enrolledShopIds.contains(offer.id);
    }).toList(growable: false);

    final shops = <Shop>[
      ...enrollmentShops,
      if (_selectedFilter == 'Tous' || _selectedFilter == 'Actifs')
        ...marketOffers,
    ];

    switch (_selectedSort) {
      case 'A-Z':
        shops.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Plus proche':
        shops.sort((a, b) => _getDistance(a).compareTo(_getDistance(b)));
        break;
      case 'Défaut':
      default:
        break;
    }

    return shops;
  }

  Future<void> _loadMarketplaceOffers() async {
    if (!mounted) {
      return;
    }

    // ignore: invalid_use_of_protected_member
    setState(() {
      _isLoadingMarketplaceOffers = true;
      _marketplaceOffersError = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        SearchService.searchDealsAsync(
          filter: const SearchFilter(
            offerType: OfferType.deal,
            sortBy: SortOption.nearest,
          ),
          userLocation: _currentPosition,
        ),
        SearchService.searchDealsAsync(
          filter: const SearchFilter(
            offerType: OfferType.flashSale,
            sortBy: SortOption.nearest,
          ),
          userLocation: _currentPosition,
        ),
        SearchService.searchShopsAsync(
          filter: const SearchFilter(
            offerType: OfferType.loyalty,
            sortBy: SortOption.nearest,
          ),
          userLocation: _currentPosition,
        ),
        _flyerService.listFlyers(),
      ]);

      final deals = results[0] as List<Shop>;
      final flashDeals = results[1] as List<Shop>;
      final loyaltyOffers = results[2] as List<Shop>;
      final flyers = results[3] as List<Flyer>;

      final allOffers = <Shop>[
        ...deals,
        ...flashDeals,
        ...loyaltyOffers,
        ..._toFlyerShops(flyers),
      ];

      final dedupedByKey = <String, Shop>{};
      for (final offer in allOffers) {
        final key = '${offer.dealType}|${offer.id}';
        dedupedByKey[key] = offer;
      }

      if (!mounted) {
        return;
      }

      // ignore: invalid_use_of_protected_member
      setState(() {
        _marketplaceOffers = dedupedByKey.values.toList(growable: false);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      // ignore: invalid_use_of_protected_member
      setState(() {
        _marketplaceOffersError = 'Erreur de chargement des offres: $e';
      });
    } finally {
      // ignore: invalid_use_of_protected_member
      if (mounted) setState(() => _isLoadingMarketplaceOffers = false);
    }
  }

  List<Shop> _toEnrollmentShops(List<Enrollment> enrollments) {
    return enrollments.map((enrollment) {
      final rewardLabel = switch (enrollment.rewardStatus) {
        RewardRequestStatus.requested => 'Demande en attente',
        RewardRequestStatus.approved => 'Recompense approuvee',
        _ when enrollment.canRequestReward => 'Recompense disponible',
        _ => enrollment.loyaltyProgramName ?? 'Programme fidelite',
      };

      final programName = enrollment.loyaltyProgramName;
      final shopDisplayName = (programName != null && programName.isNotEmpty)
          ? '${enrollment.shopName} — $programName'
          : enrollment.shopName;

      return Shop(
        id: enrollment.shopId,
        enrollmentId: enrollment.id,
        loyaltyProgramId: enrollment.loyaltyProgramId,
        name: shopDisplayName,
        location: 'Djibouti',
        rewardValue: rewardLabel,
        rewardType: 'special_offer',
        dealType: 'Loyalty',
        stamps: enrollment.stampsCollected,
        totalRequired: enrollment.stampsRequired,
        timeLeft: '',
        logoUrl: '',
        latitude: 0,
        longitude: 0,
        history: null,
        isRedeemed: enrollment.isRedeemed,
        imageUrl: '',
      );
    }).toList(growable: false);
  }

  List<Shop> _toFlyerShops(List<Flyer> flyers) {
    return flyers.map((flyer) {
      final thumbnail = flyer.thumbnailUrl?.trim();
      final fileUrl = flyer.fileUrl?.trim();
      final imageUrl = (thumbnail != null && thumbnail.isNotEmpty)
          ? thumbnail
          : (fileUrl != null && fileUrl.isNotEmpty)
              ? fileUrl
              : 'https://placehold.co/1200x800?text=Flyer';
      final logoUrl = flyer.storeLogoUrl.trim().isNotEmpty
          ? flyer.storeLogoUrl
          : 'https://placehold.co/200x200?text=LB';

      return Shop(
        id: 'flyer-${flyer.id}',
        name: flyer.storeName.trim().isNotEmpty ? flyer.storeName : 'Commerce',
        stamps: 0,
        totalRequired: 1,
        dealType: 'Flyer',
        timeLeft: flyer.validUntil,
        location: 'Djibouti',
        rewardValue: flyer.title.trim().isNotEmpty ? flyer.title : 'Prospectus',
        rewardType: 'special_offer',
        imageUrl: imageUrl,
        logoUrl: logoUrl,
        latitude: flyer.latitude,
        longitude: flyer.longitude,
      );
    }).toList(growable: false);
  }
}
