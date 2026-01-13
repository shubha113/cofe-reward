import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ToolKitScreen extends StatelessWidget {
  const ToolKitScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> tools = const [
    {
      'title': 'Capacity',
      'subtitle': 'Calculation',
      'icon': Icons.storage_rounded,
      'color': Color(0xFF4A90E2),
    },
    {
      'title': 'IP',
      'subtitle': 'Calculation',
      'icon': Icons.settings_input_component,
      'color': Color(0xFF50E3C2),
    },
    {
      'title': 'Lens',
      'subtitle': 'Calculation',
      'icon': Icons.camera_enhance_rounded,
      'color': Color(0xFFF5A623),
    },
    {
      'title': 'Switch Access',
      'subtitle': 'Calculation',
      'icon': Icons.router_rounded,
      'color': Color(0xFFD0021B),
    },
    {
      'title': 'Bandwidth',
      'subtitle': 'Calculation',
      'icon': Icons.speed_rounded,
      'color': Color(0xFF9013FE),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        title: const Text(
          "Tool Kit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _buildToolCard(tool);
        },
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tool['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(tool['icon'], color: tool['color'], size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            tool['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tool['subtitle'],
            style: const TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}
