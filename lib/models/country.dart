class Country {
  final String code;    
  final String name;    

  Country({required this.code, required this.name});

  String get flagUrl => 'https://flagcdn.com/w320/$code.png';
}