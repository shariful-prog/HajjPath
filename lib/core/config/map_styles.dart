class AppMapStyle {
  final String name;
  final String urlTemplate;
  final List<String> subdomains;

  const AppMapStyle({
    required this.name,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c'],
  });

  static const List<AppMapStyle> styles = [
    AppMapStyle(
      name: 'Standard',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    AppMapStyle(
      name: 'Voyager',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
    ),
    AppMapStyle(
      name: 'Light',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
    ),
    AppMapStyle(
      name: 'Dark',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
    ),
    AppMapStyle(
      name: 'Satellite',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      subdomains: [],
    ),
  ];
}
