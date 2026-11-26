import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _currentLocation;
  LatLng? _destination;
  double? _calculatedDistanceKm;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isSelectingStart = false;
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    } 

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentLocation = const LatLng(30.0444, 31.2357); // Cairo
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'FuelCalculatorApp/1.0',
      });
      
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to search location.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchResultSelected(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final point = LatLng(lat, lon);
    
    setState(() {
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
      if (_isSelectingStart) {
        _currentLocation = point;
      } else {
        _destination = point;
      }
    });

    _mapController.move(point, 14.0);
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    if (_currentLocation == null || _destination == null) return;
    
    setState(() {
      _calculatedDistanceKm = null;
    });

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${_currentLocation!.longitude},${_currentLocation!.latitude};'
      '${_destination!.longitude},${_destination!.latitude}?overview=false'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final distanceMeters = data['routes'][0]['distance'] as num;
          if (mounted) {
            setState(() {
              _calculatedDistanceKm = distanceMeters / 1000;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate distance. Check internet connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Destination'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(30.0444, 31.2357),
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        if (_isSelectingStart) {
                          _currentLocation = point;
                        } else {
                          _destination = point;
                        }
                      });
                      _calculateRoute();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flutter_application_2',
                    ),
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                          ),
                          if (_destination != null)
                            Marker(
                              point: _destination!,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                        ],
                      ),
                  ],
                ),
                
                // Search Bar Overlay
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Start'),
                                    selected: _isSelectingStart,
                                    onSelected: (selected) {
                                      setState(() => _isSelectingStart = true);
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  ChoiceChip(
                                    label: const Text('Destination'),
                                    selected: !_isSelectingStart,
                                    onSelected: (selected) {
                                      setState(() => _isSelectingStart = false);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: _isSelectingStart ? 'Search start location...' : 'Search destination...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchResults = [];
                                          });
                                        },
                                      ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onSubmitted: _searchLocation,
                            ),
                          ],
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          margin: const EdgeInsets.only(top: 8),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final result = _searchResults[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on_outlined),
                                  title: Text(
                                    result['display_name'] ?? 'Unknown Location',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _onSearchResultSelected(result),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _calculatedDistanceKm != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, _calculatedDistanceKm);
              },
              icon: const Icon(Icons.check),
              label: Text('Confirm: ${_calculatedDistanceKm!.toStringAsFixed(1)} km'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
