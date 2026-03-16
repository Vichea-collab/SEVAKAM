class LocationOptions {
  static const String defaultCity = 'Phnom Penh';

  static const Map<String, List<String>> cityDistrictOptions = {
    defaultCity: [
      'Chamkar Mon',
      'Daun Penh',
      '7 Makara',
      'Toul Kork',
      'Sen Sok',
      'Mean Chey',
      'Chbar Ampov',
      'Russey Keo',
      'Por Senchey',
      'Dangkao',
      'Prek Pnov',
      'Chroy Changvar',
      'Boeng Keng Kang',
      'Kamboul',
    ],
  };

  static List<String> districtsForCity(String city) {
    return cityDistrictOptions[city.trim()] ?? const <String>[];
  }

  static String areaFromDistrict(String district, {String city = defaultCity}) {
    final trimmedDistrict = district.trim();
    final trimmedCity = city.trim();
    return [
      trimmedDistrict,
      trimmedCity,
    ].where((item) => item.isNotEmpty).join(', ');
  }

  static String districtFromArea(String area, {String city = defaultCity}) {
    final trimmedArea = area.trim();
    if (trimmedArea.isEmpty) return '';
    final districts = districtsForCity(city);
    for (final district in districts) {
      if (trimmedArea.toLowerCase().contains(district.toLowerCase())) {
        return district;
      }
    }
    return trimmedArea;
  }
}
