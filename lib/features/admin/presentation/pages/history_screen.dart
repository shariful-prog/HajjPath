import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/config/map_styles.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  final String? initialUser;
  const HistoryScreen({super.key, this.initialUser});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedUser;
  List<Map<String, dynamic>> _historyPoints = [];
  bool _isLoading = false;
  final MapController _mapController = MapController();
  AppMapStyle _currentStyle = AppMapStyle.styles[0]; // Default to Standard

  // Analytics State
  double _totalDistance = 0.0;
  double _topSpeed = 0.0;
  String _travelDuration = '--';

  // UI State
  bool _showLines = true;
  int? _highlightedIndex; // Chronological index

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.firebaseDatabaseUrl,
  );

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _selectedUser = widget.initialUser;
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    if (_selectedUser == null) return;
    
    setState(() => _isLoading = true);

    try {
      final snapshot = await db.ref('locations/$_selectedUser/history').get();
      
      if (snapshot.exists && snapshot.value != null) {
        // Safe cast: Data could be a Map or List depending on keys
        final dynamic rawData = snapshot.value;
        Map<dynamic, dynamic> data;
        
        if (rawData is Map) {
          data = rawData;
        } else if (rawData is List) {
          // Firebase sometimes converts maps with integer-like keys to lists
          data = rawData.asMap();
        } else {
          throw 'Unexpected data format';
        }
        
        final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).millisecondsSinceEpoch;
        final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59).millisecondsSinceEpoch;

        final List<Map<String, dynamic>> filtered = [];
        
        data.forEach((key, value) {
          if (value is Map) {
            final point = Map<String, dynamic>.from(value);
            // Ensure timestamp is parsed from the key
            final int ts = int.tryParse(key.toString()) ?? 0;
            point['timestamp'] = ts;
            
            // Safe lat/long parsing
            final double lat = double.tryParse(point['lat']?.toString() ?? '') ?? 0.0;
            final double lon = double.tryParse(point['long']?.toString() ?? '') ?? 0.0;
            
            point['lat'] = lat;
            point['long'] = lon;
            point['localTime'] = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(ts));

            // Only filter by time range and validity
            if (ts >= startOfDay && ts <= endOfDay && isValidLatLng(lat, lon)) {
              filtered.add(point);
            }
          }
        });

        // Sort Chronologically
        filtered.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

        // Calculate Stats
        double totalDist = 0.0;
        double maxSpeed = 0.0;
        final distanceCalc = const ll.Distance();

        for (int i = 0; i < filtered.length; i++) {
          final p = filtered[i];
          final s = double.tryParse(p['speed']?.toString() ?? '0') ?? 0.0;
          if (s > maxSpeed) maxSpeed = s;

          if (i > 0) {
            final prev = filtered[i - 1];
            totalDist += distanceCalc.as(
              ll.LengthUnit.Meter,
              ll.LatLng(prev['lat'] as double, prev['long'] as double),
              ll.LatLng(p['lat'] as double, p['long'] as double),
            );
          }
        }

        String durationStr = '--';
        if (filtered.isNotEmpty) {
          final firstTime = DateTime.fromMillisecondsSinceEpoch(filtered.first['timestamp'] as int);
          final lastTime = DateTime.fromMillisecondsSinceEpoch(filtered.last['timestamp'] as int);
          final diff = lastTime.difference(firstTime);
          if (diff.inHours > 0) {
            durationStr = '${diff.inHours}h ${diff.inMinutes % 60}m';
          } else {
            durationStr = '${diff.inMinutes}m';
          }
        }

        setState(() {
          _historyPoints = filtered;
          _isLoading = false;
          _highlightedIndex = null;
          _totalDistance = totalDist / 1000.0; // Convert to KM
          _topSpeed = maxSpeed * 3.6; // Assuming m/s, convert to km/h (check service logic)
          _travelDuration = durationStr;
        });

        // Auto-fit camera to show the full day
        if (filtered.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final points = filtered
                  .map((p) => ll.LatLng(p['lat'] as double, p['long'] as double))
                  .toList();
              
              if (points.isNotEmpty) {
                final bounds = LatLngBounds.fromPoints(points);
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(50),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Error fitting camera: $e');
            }
          });
        }
        
        debugPrint('Loaded ${filtered.length} history points for $_selectedUser');
        debugPrint('Loaded ${filtered.length} history points for $_selectedUser');
      } else {
        debugPrint('No history node found for $_selectedUser at locations/$_selectedUser/history');
        setState(() {
          _historyPoints = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() {
        _historyPoints = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FamilyPath'),
            Text(
              l10n.navHistory,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Main Content Area (Map + Floating Controls)
          Expanded(
            flex: 5, // Even larger map
            child: Stack(
              children: [
                _buildHistoryMap(),
                
                // Floating Style & Toggle Overlay (Right Side)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _buildStyleSelector(),
                      const SizedBox(height: 8),
                      _buildPathToggle(),
                    ],
                  ),
                ),

                // Floating User/Date Selector Card (Top Center)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 70, 
                  child: _buildFloatingSelectionCard(),
                ),

                // Map Overview (Bottom Center) - Glassmorphic Overlay
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: _buildStatsDashboard(),
                ),
              ],
            ),
          ),
          
          // Timeline List
          Expanded(
            flex: 2, // Compact details area
            child: _buildInteractiveTimeline(),
          ),
        ],
      ),
    );
  }

  Widget _buildPathToggle() {
    return _glassContainer(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => setState(() => _showLines = !_showLines),
        child: Icon(
          _showLines ? Icons.route_rounded : Icons.alt_route_rounded,
          color: _showLines ? Colors.blueAccent : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFloatingSelectionCard() {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildUserSelectorWidget(),
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withAlpha(50),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          InkWell(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd').format(_selectedDate),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInteractiveTimeline() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedUser == null) {
      return Center(child: Text(l10n.selectUserHint));
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyPoints.isEmpty) {
      return Center(child: Text(l10n.noTravelData));
    }

    // Newest on top for the list view
    final displayPoints = _historyPoints.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentMovements,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (_highlightedIndex != null)
                TextButton(
                  onPressed: () => setState(() => _highlightedIndex = null),
                  child: const Text('View Full Day', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: displayPoints.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final point = displayPoints[index];
              final chronoIndex = _historyPoints.length - 1 - index;
              final isHighlighted = _highlightedIndex == chronoIndex;

              return InkWell(
                onTap: () {
                  final lat = point['lat'] as double;
                  final lng = point['long'] as double;
                  if (isValidLatLng(lat, lng)) {
                    setState(() => _highlightedIndex = chronoIndex);
                    _mapController.move(ll.LatLng(lat, lng), 17);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidLocation)),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighlighted ? Colors.blue.withAlpha(15) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHighlighted ? Colors.blueAccent : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (!isHighlighted)
                        BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            point['localTime'],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            isHighlighted ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 14,
                            color: isHighlighted ? Colors.blueAccent : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: getAddressFromLatLng(point['lat'] as double, point['long'] as double),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? l10n.fetchingLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.speed}: ${point['speed']?.toStringAsFixed(1) ?? 0} km/h',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsDashboard() {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(l10n.distLabel, '${_totalDistance.toStringAsFixed(1)} KM', Icons.edit_road_rounded), 
          _buildStatItem(l10n.topLabel, '${_topSpeed.toStringAsFixed(0)} km/h', Icons.speed_rounded),
          _buildStatItem(l10n.timeLabel, _travelDuration, Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row( // Changed to Row for more horizontal compactness
      children: [
        Icon(icon, size: 14, color: Colors.blueAccent), // Smaller icon
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildUserSelectorWidget() {
    return StreamBuilder(
      stream: db.ref('users').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Text('...', style: TextStyle(fontSize: 12));
        }
        
        final usersMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final users = usersMap.entries
            .where((e) => (e.value as Map)['type'] == 'user')
            .map((e) => e.key as String)
            .toList();

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedUser,
            hint: Text(l10n.selectUserHint, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            isDense: true,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            items: users.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) {
              setState(() {
                 _selectedUser = val;
                 _highlightedIndex = null;
              });
              _loadHistory();
            },
          ),
        );
      },
    );
  }

  Widget _buildStyleSelector() {
    return PopupMenuButton<AppMapStyle>(
      initialValue: _currentStyle,
      onSelected: (style) => setState(() => _currentStyle = style),
      child: _glassContainer(
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.layers_rounded, color: Colors.black54, size: 24),
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
            Text(style.name, style: const TextStyle(fontSize: 13)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMarkerWithLabel({
    required ll.LatLng point,
    required Color color,
    required IconData icon,
    required String label,
    double size = 32,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 4)],
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        // Icon
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: size),
        ),
      ],
    );
  }


  Widget _buildHistoryMap() {
    final List<ll.LatLng> allPoints = _historyPoints
        .map((p) => ll.LatLng(p['lat'] as double, p['long'] as double))
        .toList();
    
    final List<ll.LatLng> visiblePoints = (_showLines && _highlightedIndex != null)
        ? allPoints.sublist(0, _highlightedIndex! + 1)
        : (_showLines ? allPoints : []);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: (allPoints.isNotEmpty) 
            ? allPoints.last 
            : const ll.LatLng(21.4225, 39.8262),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: _currentStyle.urlTemplate,
          subdomains: _currentStyle.subdomains,
          userAgentPackageName: 'com.appbund.techgic.familypath',
        ),
        if (visiblePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: visiblePoints,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (allPoints.isNotEmpty) ...[
              // Start Marker (Point 0)
              Marker(
                point: allPoints.first,
                width: 70, // Wider for larger label
                height: 85, // Taller to prevent overflow
                alignment: Alignment.topCenter,
                child: _buildMarkerWithLabel(
                  point: allPoints.first,
                  color: Colors.green,
                  icon: Icons.trip_origin,
                  label: l10n.startLoc,
                  size: 26,
                ),
              ),
              // End/Selected Marker
              Marker(
                point: allPoints[_highlightedIndex ?? (allPoints.length - 1)],
                width: 70,
                height: 85,
                alignment: Alignment.topCenter,
                child: _buildMarkerWithLabel(
                  point: allPoints[_highlightedIndex ?? (allPoints.length - 1)],
                  color: Colors.red,
                  icon: Icons.person_pin,
                  label: l10n.endLoc,
                  size: 32,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

