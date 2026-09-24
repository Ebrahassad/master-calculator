import 'package:flutter/material.dart';

/// متحكم اللغة العام للتطبيق (عربي / إنجليزي)
class LanguageController extends ChangeNotifier {
  String _code = 'ar';
  String get code => _code;
  bool get isArabic => _code == 'ar';
  TextDirection get direction => isArabic ? TextDirection.rtl : TextDirection.ltr;
  Locale get locale => Locale(_code);

  void toggle() {
    _code = _code == 'ar' ? 'en' : 'ar';
    notifyListeners();
  }

  void setCode(String code) {
    if (_code != code) {
      _code = code;
      notifyListeners();
    }
  }
}

/// ويدجت وسيطة لتوزيع اللغة على كل الشجرة
class Lang extends InheritedNotifier<LanguageController> {
  const Lang({super.key, required LanguageController controller, required super.child})
      : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<Lang>();
    assert(widget != null, 'Lang.of() called with no Lang ancestor');
    return widget!.notifier!;
  }
}

/// دالة اختصار للترجمة داخل أي Widget
String tr(BuildContext context, String key) {
  final code = Lang.of(context).code;
  return AppStrings.map[key]?[code] ?? AppStrings.map[key]?['ar'] ?? key;
}

class AppStrings {
  static final Map<String, Map<String, String>> map = {
    // عام / التطبيق
    'app_title': {'ar': 'موسوعة الحاسبات الشاملة', 'en': 'Master Calculator Hub'},
    'app_title_short': {'ar': 'الحاسبة الشاملة', 'en': 'Master Calculator'},
    'nav_money': {'ar': 'المال', 'en': 'Finance'},
    'nav_health': {'ar': 'الصحة', 'en': 'Health'},
    'nav_calc': {'ar': 'الحسابات', 'en': 'General'},
    'nav_convert': {'ar': 'التحويلات', 'en': 'Convert'},
    'scientific_tooltip': {'ar': 'الآلة الحاسبة العلمية الهندسية', 'en': 'Scientific Calculator'},

    // القائمة الجانبية
    'drawer_save_session': {'ar': 'حفظ الجلسة الحالية', 'en': 'Save Current Session'},
    'drawer_history': {'ar': 'سجل الجلسات والعمليات', 'en': 'Session History'},
    'drawer_background': {'ar': 'تغيير الخلفية بألوان انتقائية', 'en': 'Change Background Color'},
    'drawer_language': {'ar': 'تغيير اللغة', 'en': 'Change Language'},
    'drawer_about': {'ar': 'حول التطبيق', 'en': 'About App'},
    'drawer_share': {'ar': 'مشاركة التطبيق', 'en': 'Share App'},
    'drawer_rate': {'ar': 'قيّم التطبيق', 'en': 'Rate the App'},
    'drawer_exit': {'ar': 'خروج من التطبيق', 'en': 'Exit App'},
    'drawer_version': {'ar': 'الإصدار', 'en': 'Version'},
    'drawer_contact': {'ar': 'تواصل معنا', 'en': 'Contact us'},
    'session_saved': {'ar': '✅ تم حفظ الجلسة الحالية بنجاح في السجل', 'en': '✅ Current session saved successfully'},
    'active_session': {'ar': 'جلسة حسابات مالية وصحية نشطة', 'en': 'Active finance & health session'},
    'pick_color': {'ar': 'اختر لون الخلفية', 'en': 'Choose Background Color'},
    'premium_theme': {'ar': 'ثيم ذهبي مميز 👑', 'en': 'Premium Gold Theme 👑'},
    'watch_ad_to_unlock': {'ar': 'شاهد إعلانًا قصيرًا لفتح هذا الثيم نهائيًا', 'en': 'Watch a short ad to unlock this theme forever'},
    'ad_not_ready_try_later': {'ar': 'الإعلان غير جاهز الآن، حاول بعد قليل', 'en': 'Ad not ready yet, please try again shortly'},
    'unlocked_now': {'ar': '🎉 تم فتح الثيم المميز بنجاح!', 'en': '🎉 Premium theme unlocked successfully!'},    'no_sessions': {'ar': 'لا توجد جلسات محفوظة حتى الآن', 'en': 'No saved sessions yet'},
    'clear_history': {'ar': 'مسح السجل', 'en': 'Clear History'},

    // حول التطبيق
    'about_desc': {
      'ar': 'تطبيق شامل لكل ما تحتاجه من حاسبات مالية، صحية، هندسية وتحويلات فورية للعملات والوحدات — بواجهة سريعة وأنيقة تعمل بدون إنترنت (باستثناء تحديث أسعار العملات اللحظية).',
      'en': 'An all-in-one hub for finance, health, scientific and instant currency & unit conversion calculators — fast, elegant, and works offline (except live currency updates).'
    },
    'about_developer': {'ar': 'تم تطوير هذا التطبيق بواسطة HASSADI لتوفير تجربة مستخدم سلسة واحترافية في إجراء كافة التحويلات والحسابات اليومية بدقة عالية.', 'en': 'Developed by HASSADI to provide a smooth, professional experience for everyday calculations and conversions with high accuracy.'},

    // عام - عناصر مشتركة
    'result': {'ar': 'النتيجة', 'en': 'Result'},
    'from': {'ar': 'من', 'en': 'From'},
    'to': {'ar': 'إلى', 'en': 'To'},
    'value_to_convert': {'ar': 'القيمة المراد تحويلها', 'en': 'Value to convert'},
    'converted_value': {'ar': 'القيمة المحولة', 'en': 'Converted value'},
    'swap': {'ar': 'تبديل', 'en': 'Swap'},
    'category': {'ar': 'الفئة', 'en': 'Category'},
    'currency_category': {'ar': 'تحويل العملات (أسعار لحظية مباشرة)', 'en': 'Currency (live exchange rates)'},
    'live_rate_note': {'ar': 'الأسعار محدّثة لحظيًا من مصدر عالمي موثوق', 'en': 'Rates updated live from a trusted global source'},
    'last_updated': {'ar': 'آخر تحديث', 'en': 'Last updated'},
    'refresh_rates': {'ar': 'تحديث الأسعار الآن', 'en': 'Refresh rates now'},
    'offline_rates': {'ar': 'تعذر الاتصال — تُعرض آخر أسعار محفوظة', 'en': 'Offline — showing last saved rates'},
    'fetching_rates': {'ar': 'جاري جلب أسعار الصرف اللحظية...', 'en': 'Fetching live exchange rates...'},
    'search_currency': {'ar': 'ابحث عن عملة...', 'en': 'Search currency...'},
    'search_unit': {'ar': 'ابحث عن وحدة...', 'en': 'Search unit...'},
    'amount': {'ar': 'المبلغ', 'en': 'Amount'},

    // فئات التحويل (الوحدات)
    'unit_length': {'ar': 'الطول والمسافة', 'en': 'Length & Distance'},
    'unit_weight': {'ar': 'الوزن والكتلة', 'en': 'Weight & Mass'},
    'unit_temperature': {'ar': 'درجة الحرارة', 'en': 'Temperature'},
    'unit_area': {'ar': 'المساحة', 'en': 'Area'},
    'unit_volume': {'ar': 'الحجم والسوائل', 'en': 'Volume & Liquid'},
    'unit_speed': {'ar': 'السرعة', 'en': 'Speed'},
    'unit_time': {'ar': 'الزمن', 'en': 'Time'},
    'unit_pressure': {'ar': 'الضغط', 'en': 'Pressure'},
    'unit_energy': {'ar': 'الطاقة', 'en': 'Energy'},
    'unit_power': {'ar': 'القدرة', 'en': 'Power'},
    'unit_data': {'ar': 'حجم البيانات الرقمية', 'en': 'Digital Storage'},
    'unit_angle': {'ar': 'الزاوية', 'en': 'Angle'},
    'unit_fuel': {'ar': 'استهلاك الوقود', 'en': 'Fuel Consumption'},

    // تبويب المال
    'fin_vat': {'ar': 'ضريبة القيمة المضافة (VAT)', 'en': 'VAT Calculator'},
    'fin_loan': {'ar': 'حاسبة القروض والفوائد (قسط شهري)', 'en': 'Loan / EMI Calculator'},
    'fin_investment': {'ar': 'حاسبة الاستثمار والأرباح', 'en': 'Investment & Profit'},
    'fin_compound': {'ar': 'حاسبة الفائدة المركبة', 'en': 'Compound Interest'},
    'fin_simple_interest': {'ar': 'حاسبة الفائدة البسيطة', 'en': 'Simple Interest'},
    'fin_profit_margin': {'ar': 'حاسبة هامش الربح', 'en': 'Profit Margin'},
    'fin_break_even': {'ar': 'حاسبة نقطة التعادل', 'en': 'Break-even Point'},
    'fin_savings_goal': {'ar': 'حاسبة هدف الادخار الشهري', 'en': 'Monthly Savings Goal'},
    'fin_salary_zakat': {'ar': 'حاسبة زكاة المال', 'en': 'Zakat Calculator'},
    'fin_amount': {'ar': 'المبلغ الأساسي', 'en': 'Principal Amount'},
    'fin_rate': {'ar': 'النسبة أو الفائدة (%)', 'en': 'Rate / Interest (%)'},
    'fin_years': {'ar': 'المدة (سنوات)', 'en': 'Duration (years)'},
    'fin_months': {'ar': 'المدة (أشهر)', 'en': 'Duration (months)'},
    'fin_cost': {'ar': 'سعر التكلفة', 'en': 'Cost Price'},
    'fin_price': {'ar': 'سعر البيع', 'en': 'Selling Price'},
    'fin_fixed_costs': {'ar': 'التكاليف الثابتة', 'en': 'Fixed Costs'},
    'fin_unit_price': {'ar': 'سعر الوحدة', 'en': 'Price per Unit'},
    'fin_unit_cost': {'ar': 'تكلفة الوحدة المتغيرة', 'en': 'Variable Cost per Unit'},
    'fin_sub_result': {'ar': 'الناتج الفرعي / الزيادة', 'en': 'Sub-result / Increase'},
    'fin_total_result': {'ar': 'الإجمالي الشامل', 'en': 'Grand Total'},
    'fin_monthly_payment': {'ar': 'القسط الشهري', 'en': 'Monthly Installment'},
    'fin_total_interest': {'ar': 'إجمالي الفوائد', 'en': 'Total Interest'},
    'fin_final_amount': {'ar': 'المبلغ النهائي', 'en': 'Final Amount'},
    'fin_profit': {'ar': 'صافي الربح', 'en': 'Net Profit'},
    'fin_margin_pct': {'ar': 'نسبة هامش الربح', 'en': 'Profit Margin %'},
    'fin_breakeven_units': {'ar': 'عدد الوحدات لتحقيق التعادل', 'en': 'Units for break-even'},
    'fin_goal_amount': {'ar': 'المبلغ المستهدف', 'en': 'Target Amount'},
    'fin_monthly_saving': {'ar': 'الادخار الشهري المطلوب', 'en': 'Required Monthly Saving'},

    // تبويب الصحة
    'h_bmi': {'ar': 'مؤشر كتلة الجسم (BMI)', 'en': 'BMI Calculator'},
    'h_hba1c': {'ar': 'متوسط السكر التراكمي (HbA1c)', 'en': 'HbA1c Estimated Glucose'},
    'h_bmr': {'ar': 'معدل الأيض الأساسي (BMR)', 'en': 'BMR (Basal Metabolic Rate)'},
    'h_calories': {'ar': 'الاحتياج اليومي من السعرات', 'en': 'Daily Calorie Needs'},
    'h_water': {'ar': 'الاحتياج اليومي من الماء', 'en': 'Daily Water Intake'},
    'h_ideal_weight': {'ar': 'الوزن المثالي', 'en': 'Ideal Body Weight'},
    'h_body_fat': {'ar': 'نسبة الدهون في الجسم', 'en': 'Body Fat Percentage'},
    'h_heart_rate': {'ar': 'المعدل المستهدف لنبضات القلب', 'en': 'Target Heart Rate Zones'},
    'h_pregnancy': {'ar': 'حاسبة موعد الولادة المتوقع', 'en': 'Pregnancy Due Date'},
    'h_weight': {'ar': 'الوزن (كجم)', 'en': 'Weight (kg)'},
    'h_height': {'ar': 'الطول (سم)', 'en': 'Height (cm)'},
    'h_age': {'ar': 'العمر (سنة)', 'en': 'Age (years)'},
    'h_gender': {'ar': 'الجنس', 'en': 'Gender'},
    'h_male': {'ar': 'ذكر', 'en': 'Male'},
    'h_female': {'ar': 'أنثى', 'en': 'Female'},
    'h_activity': {'ar': 'مستوى النشاط', 'en': 'Activity Level'},
    'h_neck': {'ar': 'محيط الرقبة (سم)', 'en': 'Neck (cm)'},
    'h_waist': {'ar': 'محيط الخصر (سم)', 'en': 'Waist (cm)'},
    'h_hip': {'ar': 'محيط الورك (سم) - للإناث فقط', 'en': 'Hip (cm) - females only'},
    'h_hba1c_input': {'ar': 'نسبة السكر التراكمي (%)', 'en': 'HbA1c (%)'},
    'h_lmp': {'ar': 'أول يوم من آخر دورة شهرية (كم يومًا مضى)', 'en': 'Days since first day of last period'},
    'h_result_health': {'ar': 'النتيجة الصحية', 'en': 'Health Result'},
    'h_status_low': {'ar': 'وزن منخفض', 'en': 'Underweight'},
    'h_status_normal': {'ar': 'وزن مثالي ورائع', 'en': 'Normal - Great!'},
    'h_status_over': {'ar': 'زيادة في الوزن', 'en': 'Overweight'},
    'h_status_obese': {'ar': 'سمنة مفرطة', 'en': 'Obese'},

    // تبويب الحسابات العامة
    'c_discount': {'ar': 'حاسبة الخصم والنسبة (Discount)', 'en': 'Discount Calculator'},
    'c_percentage': {'ar': 'حاسبة النسب المئوية البسيطة', 'en': 'Simple Percentage'},
    'c_tip': {'ar': 'حاسبة إكرامية وتقسيم الفاتورة', 'en': 'Tip & Bill Split'},
    'c_age': {'ar': 'حاسبة العمر بالتفصيل', 'en': 'Detailed Age Calculator'},
    'c_date_diff': {'ar': 'حاسبة الفرق بين تاريخين', 'en': 'Date Difference'},
    'c_gpa': {'ar': 'حاسبة المعدل التراكمي (GPA)', 'en': 'GPA Calculator'},
    'c_original_value': {'ar': 'السعر الأصلي أو القيمة', 'en': 'Original Price / Value'},
    'c_discount_pct': {'ar': 'نسبة الخصم (%)', 'en': 'Discount (%)'},
    'c_savings': {'ar': 'مقدار التوفير', 'en': 'Amount Saved'},
    'c_final_price': {'ar': 'السعر النهائي', 'en': 'Final Price'},
    'c_bill_amount': {'ar': 'مبلغ الفاتورة', 'en': 'Bill Amount'},
    'c_tip_pct': {'ar': 'نسبة الإكرامية (%)', 'en': 'Tip (%)'},
    'c_people_count': {'ar': 'عدد الأشخاص', 'en': 'Number of People'},
    'c_tip_amount': {'ar': 'مبلغ الإكرامية', 'en': 'Tip Amount'},
    'c_per_person': {'ar': 'نصيب الفرد', 'en': 'Per Person'},
    'c_birth_date': {'ar': 'تاريخ الميلاد (يوم/شهر/سنة)', 'en': 'Birth date (day/month/year)'},
    'c_day': {'ar': 'اليوم', 'en': 'Day'},
    'c_month': {'ar': 'الشهر', 'en': 'Month'},
    'c_year': {'ar': 'السنة', 'en': 'Year'},

    // الآلة الحاسبة العلمية
    'sci_deg': {'ar': 'درجات', 'en': 'DEG'},
    'sci_rad': {'ar': 'راديان', 'en': 'RAD'},
    'sci_error': {'ar': 'خطأ', 'en': 'Error'},
    'sci_history': {'ar': 'سجل العمليات', 'en': 'Calc History'},

    // عام
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'close': {'ar': 'إغلاق', 'en': 'Close'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'ok': {'ar': 'موافق', 'en': 'OK'},
  };
}
