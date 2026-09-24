/// وحدة واحدة داخل فئة تحويل: تحمل اسمها بالعربي والإنجليزي ومعامل تحويلها
/// إلى "الوحدة الأساسية" الخاصة بالفئة (مثلاً المتر لفئة الطول).
class UnitDef {
  final String key;
  final String nameAr;
  final String nameEn;
  final double toBase; // factor to multiply by to reach the base unit
  const UnitDef(this.key, this.nameAr, this.nameEn, this.toBase);

  String label(bool isArabic) => isArabic ? nameAr : nameEn;
}

class UnitCategory {
  final String key;
  final String titleKey; // مفتاح الترجمة في strings.dart
  final List<UnitDef> units;
  final bool isTemperature;
  const UnitCategory(this.key, this.titleKey, this.units, {this.isTemperature = false});
}

const List<UnitCategory> kUnitCategories = [
  UnitCategory('length', 'unit_length', [
    UnitDef('mm', 'مليمتر', 'Millimeter', 0.001),
    UnitDef('cm', 'سنتيمتر', 'Centimeter', 0.01),
    UnitDef('m', 'متر', 'Meter', 1.0),
    UnitDef('km', 'كيلومتر', 'Kilometer', 1000.0),
    UnitDef('in', 'بوصة', 'Inch', 0.0254),
    UnitDef('ft', 'قدم', 'Foot', 0.3048),
    UnitDef('yd', 'ياردة', 'Yard', 0.9144),
    UnitDef('mi', 'ميل', 'Mile', 1609.344),
    UnitDef('nmi', 'ميل بحري', 'Nautical Mile', 1852.0),
  ]),
  UnitCategory('weight', 'unit_weight', [
    UnitDef('mg', 'مليغرام', 'Milligram', 0.001),
    UnitDef('g', 'غرام', 'Gram', 1.0),
    UnitDef('kg', 'كيلوغرام', 'Kilogram', 1000.0),
    UnitDef('ton', 'طن متري', 'Metric Ton', 1000000.0),
    UnitDef('oz', 'أونصة', 'Ounce', 28.3495),
    UnitDef('lb', 'رطل (باوند)', 'Pound', 453.592),
    UnitDef('st', 'ستون', 'Stone', 6350.29),
  ]),
  UnitCategory('temperature', 'unit_temperature', [
    UnitDef('c', 'مئوية °C', 'Celsius °C', 1),
    UnitDef('f', 'فهرنهايت °F', 'Fahrenheit °F', 1),
    UnitDef('k', 'كلفن K', 'Kelvin K', 1),
  ], isTemperature: true),
  UnitCategory('area', 'unit_area', [
    UnitDef('m2', 'متر مربع', 'Square Meter', 1.0),
    UnitDef('km2', 'كيلومتر مربع', 'Square Kilometer', 1000000.0),
    UnitDef('cm2', 'سنتيمتر مربع', 'Square Centimeter', 0.0001),
    UnitDef('ha', 'هكتار', 'Hectare', 10000.0),
    UnitDef('acre', 'فدان (أكر)', 'Acre', 4046.86),
    UnitDef('ft2', 'قدم مربع', 'Square Foot', 0.092903),
    UnitDef('mi2', 'ميل مربع', 'Square Mile', 2589988.11),
  ]),
  UnitCategory('volume', 'unit_volume', [
    UnitDef('ml', 'مليلتر', 'Milliliter', 0.001),
    UnitDef('l', 'لتر', 'Liter', 1.0),
    UnitDef('m3', 'متر مكعب', 'Cubic Meter', 1000.0),
    UnitDef('gal_us', 'غالون أمريكي', 'US Gallon', 3.78541),
    UnitDef('gal_uk', 'غالون إمبراطوري', 'Imperial Gallon', 4.54609),
    UnitDef('qt', 'كوارت', 'Quart', 0.946353),
    UnitDef('pt', 'باينت', 'Pint', 0.473176),
    UnitDef('cup', 'كوب', 'Cup', 0.24),
    UnitDef('fl_oz', 'أونصة سائلة', 'Fluid Ounce', 0.0295735),
    UnitDef('tbsp', 'ملعقة كبيرة', 'Tablespoon', 0.0147868),
    UnitDef('tsp', 'ملعقة صغيرة', 'Teaspoon', 0.00492892),
  ]),
  UnitCategory('speed', 'unit_speed', [
    UnitDef('mps', 'متر/ثانية', 'Meter/second', 1.0),
    UnitDef('kmh', 'كيلومتر/ساعة', 'Kilometer/hour', 0.277778),
    UnitDef('mph', 'ميل/ساعة', 'Mile/hour', 0.44704),
    UnitDef('knot', 'عقدة بحرية', 'Knot', 0.514444),
    UnitDef('fps', 'قدم/ثانية', 'Foot/second', 0.3048),
  ]),
  UnitCategory('time', 'unit_time', [
    UnitDef('sec', 'ثانية', 'Second', 1.0),
    UnitDef('min', 'دقيقة', 'Minute', 60.0),
    UnitDef('hour', 'ساعة', 'Hour', 3600.0),
    UnitDef('day', 'يوم', 'Day', 86400.0),
    UnitDef('week', 'أسبوع', 'Week', 604800.0),
    UnitDef('month', 'شهر (تقريبي)', 'Month (approx)', 2629800.0),
    UnitDef('year', 'سنة', 'Year', 31557600.0),
  ]),
  UnitCategory('pressure', 'unit_pressure', [
    UnitDef('pa', 'باسكال', 'Pascal', 1.0),
    UnitDef('kpa', 'كيلوباسكال', 'Kilopascal', 1000.0),
    UnitDef('bar', 'بار', 'Bar', 100000.0),
    UnitDef('atm', 'ضغط جوي', 'Atmosphere', 101325.0),
    UnitDef('psi', 'رطل/بوصة مربعة', 'PSI', 6894.76),
    UnitDef('mmhg', 'مليمتر زئبق', 'mmHg', 133.322),
  ]),
  UnitCategory('energy', 'unit_energy', [
    UnitDef('j', 'جول', 'Joule', 1.0),
    UnitDef('kj', 'كيلوجول', 'Kilojoule', 1000.0),
    UnitDef('cal', 'سعرة حرارية صغيرة', 'Calorie', 4.184),
    UnitDef('kcal', 'سعرة حرارية كبيرة', 'Kilocalorie', 4184.0),
    UnitDef('wh', 'واط ساعة', 'Watt-hour', 3600.0),
    UnitDef('kwh', 'كيلوواط ساعة', 'Kilowatt-hour', 3600000.0),
    UnitDef('btu', 'وحدة حرارية بريطانية', 'BTU', 1055.06),
  ]),
  UnitCategory('power', 'unit_power', [
    UnitDef('w', 'واط', 'Watt', 1.0),
    UnitDef('kw', 'كيلوواط', 'Kilowatt', 1000.0),
    UnitDef('mw', 'ميغاواط', 'Megawatt', 1000000.0),
    UnitDef('hp', 'حصان قوة', 'Horsepower', 745.7),
  ]),
  UnitCategory('data', 'unit_data', [
    UnitDef('bit', 'بت', 'Bit', 0.125),
    UnitDef('byte', 'بايت', 'Byte', 1.0),
    UnitDef('kb', 'كيلوبايت', 'Kilobyte', 1024.0),
    UnitDef('mb', 'ميغابايت', 'Megabyte', 1048576.0),
    UnitDef('gb', 'غيغابايت', 'Gigabyte', 1073741824.0),
    UnitDef('tb', 'تيرابايت', 'Terabyte', 1099511627776.0),
  ]),
  UnitCategory('angle', 'unit_angle', [
    UnitDef('deg', 'درجة', 'Degree', 1.0),
    UnitDef('rad', 'راديان', 'Radian', 57.29577951),
    UnitDef('grad', 'غراد', 'Gradian', 0.9),
    UnitDef('rev', 'دورة كاملة', 'Revolution', 360.0),
  ]),
  UnitCategory('fuel', 'unit_fuel', [
    // الوحدة الأساسية: كم لكل لتر (كل ما هو "أقل = أفضل استهلاك" يُحوَّل عكسيًا في الكود)
    UnitDef('kml', 'كم/لتر', 'km/L', 1.0),
    UnitDef('l100km', 'لتر/100كم', 'L/100km', -1.0), // معكوسة: تعامل خاصة بالكود
    UnitDef('mpg_us', 'ميل/غالون أمريكي', 'MPG (US)', 0.425144),
    UnitDef('mpg_uk', 'ميل/غالون إمبراطوري', 'MPG (UK)', 0.354006),
  ]),
];
