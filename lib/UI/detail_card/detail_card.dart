import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../small_card/small_card.dart';

// ─── Hardcoded review data for trust building ───────────────────────────
class _Review {
  final String name;
  final String text;
  final int stars;
  final String timeAgo;
  const _Review(this.name, this.text, this.stars, this.timeAgo);
}

const _kReviews = [
  _Review('Anna M.', 'Amazing deals! Saved so much with the coupon. Will definitely come back.', 5, '2 days ago'),
  _Review('Lukas P.', 'Great atmosphere and super friendly staff. Highly recommend!', 5, '1 week ago'),
  _Review('Sophie K.', 'Love this place — the discount was applied instantly. So easy!', 4, '3 weeks ago'),
];

class DetailCard extends StatefulWidget {
  final ShopData shopData;
  const DetailCard({super.key, required this.shopData});
  @override
  State<DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  double? _distanceKm;
  bool _locationLoading = true;
  String? _locationError;

  ShopData get shopData => widget.shopData;

  @override
  void initState() {
    super.initState();
    _fetchDistance();
  }

  Future<void> _fetchDistance() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() { _locationError = 'Location denied'; _locationLoading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final meters = Geolocator.distanceBetween(
        pos.latitude, pos.longitude,
        shopData.location.$1, shopData.location.$2,
      );
      setState(() { _distanceKm = meters / 1000; _locationLoading = false; });
    } catch (e) {
      setState(() { _locationError = 'Unavailable'; _locationLoading = false; });
    }
  }

  String _formatDistance() {
    if (_distanceKm == null) return '--';
    return _distanceKm! < 1
        ? '${(_distanceKm! * 1000).round()} m'
        : '${_distanceKm!.toStringAsFixed(1)} km';
  }

  String _walkTime() {
    if (_distanceKm == null) return '--';
    final min = (_distanceKm! / 5.0 * 60).round();
    return min < 60 ? '$min min' : '${min ~/ 60}h ${min % 60}min';
  }

  String _driveTime() {
    if (_distanceKm == null) return '--';
    final min = (_distanceKm! / 35.0 * 60).round();
    return min < 1 ? '<1 min' : min < 60 ? '$min min' : '${min ~/ 60}h ${min % 60}min';
  }

  Future<void> _openMaps() async {
    final lat = shopData.location.$1;
    final lng = shopData.location.$2;
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    try {
      if (await launchUrl(geoUri)) return;
    } catch (_) {}
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  bool _isCurrentlyOpen() {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final openMin = shopData.openingTime.hour * 60 + shopData.openingTime.minute;
    final closeMin = shopData.closingTime.hour * 60 + shopData.closingTime.minute;
    return nowMin >= openMin && nowMin <= closeMin;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isOpen = _isCurrentlyOpen();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heroSection(context, theme, cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _locationCard(theme, cs),
                const SizedBox(height: 12),
                _distanceCard(theme, cs),
                const SizedBox(height: 16),
                _hoursCard(theme, cs, isOpen),
                const SizedBox(height: 16),
                _categoryChip(theme, cs),
                const SizedBox(height: 16),
                if (shopData.tags.isNotEmpty) _tagsSection(theme, cs),
                if (shopData.tags.isNotEmpty) const SizedBox(height: 24),
                _reviewsSection(theme, cs),
                const SizedBox(height: 24),
                _qrSection(theme, cs),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Hero
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _heroSection(BuildContext context, ThemeData theme, ColorScheme cs) {
    return SizedBox(
      height: 320,
      child: Stack(fit: StackFit.expand, children: [
        if (shopData.imageUrl != null)
          Image.network(shopData.imageUrl!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _gradientBg(cs))
        else
          _gradientBg(cs),
        // Scrim
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
              stops: const [0.3, 1.0],
            ),
          ),
        ),
        // Content
        Positioned(left: 20, right: 20, bottom: 24, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _couponBadge(theme, cs),
            const SizedBox(height: 12),
            Text(shopData.name, style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w800, height: 1.1,
              shadows: [Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.5))],
            )),
            const SizedBox(height: 8),
            Text(shopData.description, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9), height: 1.4)),
          ],
        )),
        // Back
        Positioned(
          top: MediaQuery.of(context).padding.top + 8, left: 8,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _gradientBg(ColorScheme cs) => Container(decoration: BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [cs.primary, cs.tertiary]),
  ));

  Widget _couponBadge(ThemeData theme, ColorScheme cs) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: cs.primaryContainer, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.local_offer_rounded, size: 16, color: cs.onPrimaryContainer),
      const SizedBox(width: 6),
      Text(shopData.couponAmount, style: theme.textTheme.labelLarge?.copyWith(
        color: cs.onPrimaryContainer, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Location Card
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _locationCard(ThemeData theme, ColorScheme cs) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16), onTap: _openMaps,
        child: _infoContainer(cs, child: Row(children: [
          _iconBox(cs.primaryContainer, Icons.navigation_rounded, cs.onPrimaryContainer),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Navigate to shop', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 2),
            Text('${shopData.location.$1.toStringAsFixed(4)}, ${shopData.location.$2.toStringAsFixed(4)}',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ])),
          Icon(Icons.open_in_new_rounded, size: 18, color: cs.primary),
        ])),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Distance & Travel Time Card (NEW)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _distanceCard(ThemeData theme, ColorScheme cs) {
    return _infoContainer(cs, child: _locationLoading
      ? Row(children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 14),
          Text('Calculating distance…', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ])
      : _locationError != null
        ? Row(children: [
            Icon(Icons.location_off_rounded, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 14),
            Text(_locationError!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ])
        : Row(children: [
            // Distance
            Expanded(child: _travelInfoTile(
              theme, cs, Icons.straighten_rounded, _formatDistance(), 'Distance')),
            Container(width: 1, height: 36, color: cs.outlineVariant.withOpacity(0.5)),
            // Walk
            Expanded(child: _travelInfoTile(
              theme, cs, Icons.directions_walk_rounded, _walkTime(), 'Walking')),
            Container(width: 1, height: 36, color: cs.outlineVariant.withOpacity(0.5)),
            // Drive
            Expanded(child: _travelInfoTile(
              theme, cs, Icons.directions_car_rounded, _driveTime(), 'Driving')),
          ]),
    );
  }

  Widget _travelInfoTile(ThemeData theme, ColorScheme cs, IconData icon, String value, String label) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 20, color: cs.primary),
      const SizedBox(height: 4),
      Text(value, style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700, color: cs.onSurface)),
      Text(label, style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onSurfaceVariant, fontSize: 10)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Opening Hours
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _hoursCard(ThemeData theme, ColorScheme cs, bool isOpen) {
    final color = isOpen ? Colors.green : Colors.red;
    return _infoContainer(cs, child: Row(children: [
      _iconBox(color.withOpacity(0.15), Icons.access_time_rounded, color),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(isOpen ? 'Open Now' : 'Closed', style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 2),
        Text('${_formatTime(shopData.openingTime)} – ${_formatTime(shopData.closingTime)}',
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ])),
    ]));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Category
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _categoryChip(ThemeData theme, ColorScheme cs) {
    return Row(children: [
      Icon(Icons.category_rounded, size: 18, color: cs.onSurfaceVariant),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(20)),
        child: Text(shopData.category, style: theme.textTheme.labelMedium?.copyWith(
          color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Tags
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _tagsSection(ThemeData theme, ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tags', style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: shopData.tags.map((tag) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.secondaryContainer, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.secondary.withOpacity(0.2))),
          child: Text(tag, style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSecondaryContainer, fontWeight: FontWeight.w600)),
        )).toList()),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Reviews Section (NEW)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _reviewsSection(ThemeData theme, ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade700),
        const SizedBox(width: 6),
        Text('What others say', style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700, color: cs.onSurface)),
      ]),
      const SizedBox(height: 12),
      ..._kReviews.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Avatar
              CircleAvatar(
                radius: 16, backgroundColor: cs.primaryContainer,
                child: Text(r.name[0], style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.name, style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700, color: cs.onSurface)),
                Text(r.timeAgo, style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant, fontSize: 10)),
              ])),
              // Stars
              Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) =>
                Icon(i < r.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14, color: Colors.amber.shade700))),
            ]),
            const SizedBox(height: 8),
            Text(r.text, style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant, height: 1.4)),
          ]),
        ),
      )),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QR Code Coupon
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _qrSection(ThemeData theme, ColorScheme cs) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [cs.primaryContainer, cs.primaryContainer.withOpacity(0.6)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.qr_code_2_rounded, size: 22, color: cs.onPrimaryContainer),
          const SizedBox(width: 8),
          Text('Your Coupon', style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800, color: cs.onPrimaryContainer, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 4),
        Text('Show this QR code at the counter', style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onPrimaryContainer.withOpacity(0.7))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: QrImageView(
            data: shopData.id, version: QrVersions.auto, size: 180,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: cs.primary),
            dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: cs.onSurface),
            gapless: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: cs.onPrimaryContainer.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Text(shopData.id, style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onPrimaryContainer.withOpacity(0.6), fontFamily: 'monospace', letterSpacing: 1.2)),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared helpers
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _infoContainer(ColorScheme cs, {required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
    ),
    child: child,
  );

  Widget _iconBox(Color bg, IconData icon, Color iconColor) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: iconColor, size: 22),
  );
}
