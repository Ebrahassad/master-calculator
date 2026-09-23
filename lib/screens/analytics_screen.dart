import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final Color backgroundColor;

  const AnalyticsScreen({
    Key? key,
    required this.onOpenDrawer,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('التحليلات والرسوم البيانية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onOpenDrawer,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نظرة عامة على استخدام الحاسبات',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // بطاقة الرسم البياني الدائري (Pie Chart)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'توزيع العمليات حسب الأقسام',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.blueAccent,
                            value: 40,
                            title: 'المالية',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.purpleAccent,
                            value: 30,
                            title: 'اليومية',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.tealAccent,
                            value: 20,
                            title: 'الصحة',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PieChartSectionData(
                            color: Colors.orangeAccent,
                            value: 10,
                            title: 'التحويلات',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // بطاقة مؤشرات أداء استخدام التطبيق
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إحصائيات سريعة',
                    style: TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.flash_on, color: Colors.amber),
                    title: Text('إجمالي العمليات المنفذة', style: TextStyle(color: Colors.white)),
                    trailing: Text('142 عملية', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ),
                  Divider(color: Colors.white24),
                  ListTile(
                    leading: Icon(Icons.trending_up, color: Colors.greenAccent),
                    title: Text('معدل النشاط الأسبوعي', style: TextStyle(color: Colors.white)),
                    trailing: Text('+18%', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
