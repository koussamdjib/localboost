part of '../map_view_widget.dart';

extension _MapViewLayout on _MapViewWidgetState {
  Widget _buildMapLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = (screenHeight * 0.3).clamp(200.0, 280.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: mapHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  _buildMapCanvas(),
                  _buildLocationBadge(),
                  _buildFilterChips(),
                  _buildMapButtons(context),
                ],
              ),
            ),
          ),
          _buildRadiusSlider(),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.radar_rounded,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Rayon',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.charcoalText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppColors.primaryGreen,
                  inactiveTrackColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                  thumbColor: AppColors.primaryGreen,
                  overlayColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: _selectedRadiusKm,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    // ignore: invalid_use_of_protected_member
                    setState(() => _selectedRadiusKm = value);
                  },
                ),
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(
                '${_selectedRadiusKm.toInt()} km',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCanvas() {
    final filteredShops = _getLocallyFilteredShops();

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.currentPosition,
            initialZoom: 13.5,
            minZoom: 11,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              // ArcGIS World Street Map — closest free tile to Google Maps style.
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.localboost.localboost_client',
              tileProvider: NetworkTileProvider(),
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: widget.currentPosition,
                  radius: _selectedRadiusKm * 1000,
                  useRadiusInMeter: true,
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderColor: AppColors.primaryGreen.withValues(alpha: 0.45),
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),
            MarkerLayer(markers: _buildMarkers(filteredShops)),
          ],
        ),
        if (_isFetchingShops)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primaryGreen,
            ),
          ),
      ],
    );
  }
}
