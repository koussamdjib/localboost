part of '../map_view_widget.dart';

extension _MapViewBadgesButtons on _MapViewWidgetState {
  Widget _buildLocationBadge() {
    final hasDetail = _quarterName != null && _cityName != null;

    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: hasDetail
            // ignore: invalid_use_of_protected_member
            ? () => setState(() => _locationExpanded = !_locationExpanded)
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _isLoadingLocationName
                      ? SizedBox(
                          width: 60,
                          height: 10,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: AppColors.primaryGreen,
                            backgroundColor:
                                AppColors.primaryGreen.withValues(alpha: 0.15),
                          ),
                        )
                      : _buildLocationText(),
                ),
                if (hasDetail) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _locationExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.primaryGreen,
                    size: 14,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationText() {
    if (_locationExpanded && _quarterName != null && _cityName != null) {
      // Expanded: show quarter on top, city smaller below.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _quarterName!,
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _cityName!,
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // Collapsed: show quarter if available, else city, else raw coords.
    final displayName = _quarterName ?? _cityName;
    if (displayName != null) {
      return Text(
        displayName,
        style: GoogleFonts.poppins(
          color: AppColors.charcoalText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Text(
      '${widget.currentPosition.latitude.toStringAsFixed(3)}, '
      '${widget.currentPosition.longitude.toStringAsFixed(3)}',
      style: GoogleFonts.poppins(
        color: AppColors.charcoalText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMapButtons(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          _buildMapButton(
            Icons.my_location,
            () => widget.mapController.move(widget.currentPosition, 14),
          ),
          const SizedBox(height: 8),
          _buildMapButton(Icons.fullscreen_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryGreen, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
