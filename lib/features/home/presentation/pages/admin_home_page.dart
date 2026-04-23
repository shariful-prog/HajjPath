import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/config/map_styles.dart';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/config/app_config.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final MapController _mapController = MapController();
  final Map<String, Marker> _markers = {};
  final Map<String, List<ll.LatLng>> _trails = {};
  final Map<String, Map<String, dynamic>> _userMetadata = {};
  AppMapStyle _currentStyle = AppMapStyle.styles[0]; // Default to Voyager
  bool _showTrails = false;
  bool _isInitialLoading = true;
  String? _statusMessage;
  
  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.firebaseDatabaseUrl,
  );

  @override
  void initState() {
    super.initState();
    _startListeningToUsers();
  }

  void _startListeningToUsers() {
    setState(() {
      _isInitialLoading = true;
      _statusMessage = null; // We'll handle the "Searching" message in build()
    });

    db.ref('users').onValue.listen((event) {
      if (!mounted) return;
      if (event.snapshot.value == null) {
        setState(() {
          _isInitialLoading = false;
          _statusMessage = 'empty'; // Sentinel value
        });
        return;
      }
      
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>;
      int userCount = 0;
      for (var entry in usersMap.entries) {
        final username = entry.key as String;
        final userData = entry.value as Map;
        
        if (userData['type'] == 'user') {
          userCount++;
          _userMetadata[username] = Map<String, dynamic>.from(userData);
          _listenToUserLocation(username);
        }
      }

      setState(() {
        _isInitialLoading = false;
        _statusMessage = userCount > 0 ? null : 'empty';
      });
    }, onError: (error) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _statusMessage = 'Database error: $error';
      });
    });
  }

  void _listenToUserLocation(String username) {
    db.ref('locations/$username/current').onValue.listen((event) {
      if (event.snapshot.value == null) return;
      
      final data = event.snapshot.value as Map;
      final double? lat = double.tryParse(data['lat']?.toString() ?? '');
      final double? lng = double.tryParse(data['long']?.toString() ?? '');
      final int battery = int.tryParse(data['battery']?.toString() ?? '0') ?? 0;
      
      // Strict validation: coordinates must be finite and non-zero (to avoid 0,0 glitches)
      if (!isValidLatLng(lat, lng)) return;

      final ll.LatLng point = ll.LatLng(lat!, lng!);

      setState(() {
        // Update Trail
        if (!_trails.containsKey(username)) {
          _trails[username] = [];
        }
        
        // Only add if different from last point to save memory
        if (_trails[username]!.isEmpty || _trails[username]!.last != point) {
           _trails[username]!.add(point);
        }

        // Auto-center on first user if not moved yet. Wrap in try-catch to avoid camera corruption.
        if (_markers.isEmpty) {
          try {
            _mapController.move(point, 14);
          } catch (e) {
            debugPrint('Map center failed: $e');
          }
        }

        _markers[username] = Marker(
          point: point,
          width: 80,
          height: 100,
          child: GestureDetector(
            onTap: () => _showUserDetail(username, data),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow/Border
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: battery < 20 ? Colors.red.withAlpha(40) : Theme.of(context).colorScheme.primary.withAlpha(40),
                        border: Border.all(
                          color: battery < 20 ? Colors.red : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      backgroundImage: _userMetadata[username]?['profilePic'] != null
                          ? NetworkImage(getGoogleDriveDirectLink(_userMetadata[username]!['profilePic']))
                          : null,
                      child: _userMetadata[username]?['profilePic'] == null
                          ? Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    // Battery Status indicator badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          battery < 20 ? Icons.battery_alert_rounded : Icons.battery_full_rounded,
                          size: 12,
                          color: battery < 20 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  void _showUserDetail(String username, Map data) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(Icons.battery_3_bar_rounded, 'Battery: ${data['battery']}%'),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time_rounded, 'Last Check: ${data['localTime']}'),
            const SizedBox(height: 8),
            _infoRow(Icons.speed_rounded, 'Speed: ${data['speed']?.toStringAsFixed(1)} km/h'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Current Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            FutureBuilder<String>(
              future: getAddressFromLatLng((data['lat'] as num).toDouble(), (data['long'] as num).toDouble()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(l10n.fetchingLabel, style: const TextStyle(color: Colors.blueAccent, fontStyle: FontStyle.italic));
                }
                return Text(snapshot.data ?? l10n.locationNotAvailable, style: const TextStyle(fontSize: 14));
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final latNum = data['lat'] as num?;
                  final lngNum = data['long'] as num?;
                  
                  if (isValidLatLng(latNum?.toDouble(), lngNum?.toDouble())) {
                    Navigator.pop(context);
                    _mapController.move(ll.LatLng(latNum!.toDouble(), lngNum!.toDouble()), 17);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidLocation)),
                    );
                  }
                },
                child: Text(l10n.centerOnMap),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const ll.LatLng(21.4225, 39.8262), // Mecca
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: _currentStyle.urlTemplate,
                subdomains: _currentStyle.subdomains,
                userAgentPackageName: 'com.appbund.techgic.familypath',
              ),
              if (_showTrails)
                PolylineLayer(
                  polylines: _trails.entries
                      .where((e) => e.value.length >= 2)
                      .map((e) => Polyline(
                        points: List.from(e.value),
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        strokeWidth: 3,
                      )).toList(),
                ),
              MarkerLayer(
                markers: _markers.values.toList(),
              ),
            ],
          ),
          // Top Overlay Info
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hub_rounded, color: Colors.blueAccent),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'FamilyPath',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                l10n.navMap,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_isInitialLoading)
                            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          Text(
                            _isInitialLoading 
                              ? '  ${l10n.loadingLabel}...' 
                              : (_statusMessage == 'empty' ? l10n.noUsersInDB : l10n.activeCount(_markers.length.toString())),
                            style: TextStyle(
                              color: (_isInitialLoading || _statusMessage == 'empty') ? Colors.grey : Colors.blueAccent, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            onPressed: _startListeningToUsers,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_statusMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 10),
                // Style Selector & Toggle Show Trails Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Style Selector
                    _buildStyleSelector(),
                    const SizedBox(width: 8),
                    // Toggle Show Trails
                    FilterChip(
                      label: Text(l10n.showTrails, style: const TextStyle(fontSize: 12)),
                      selected: _showTrails,
                      onSelected: (val) => setState(() => _showTrails = val),
                      backgroundColor: Colors.white.withValues(alpha: 0.7),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return PopupMenuButton<AppMapStyle>(
      initialValue: _currentStyle,
      onSelected: (style) => setState(() => _currentStyle = style),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_rounded, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(
                  _currentStyle.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      itemBuilder: (context) => AppMapStyle.styles.map((style) => PopupMenuItem(
        value: style,
        child: Row(
          children: [
            Icon(
              style.name == 'Satellite' ? Icons.satellite_alt : Icons.map_outlined,
              size: 20,
              color: style.name == _currentStyle.name ? Colors.blueAccent : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(style.name),
          ],
        ),
      )).toList(),
    );
  }
}

