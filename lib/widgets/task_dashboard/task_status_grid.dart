import 'package:flutter/material.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';

class TaskStatusGrid extends StatelessWidget {
  final Map<String, int> taskCounts;

  const TaskStatusGrid({super.key, required this.taskCounts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Task Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.appFont,
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Utilisation de Wrap au lieu de GridView
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _buildStatusCard(
              context, 
              'Pending', 
              taskCounts['pending'] ?? 0, // ✅ Safe null handling
              Colors.orange, 
              Icons.hourglass_empty_rounded
            ),
            _buildStatusCard(
              context, 
              'In Progress', 
              taskCounts['in_progress'] ?? 0, // ✅ Safe null handling
              Colors.blue, 
              Icons.work_outline_rounded
            ),
            _buildStatusCard(
              context, 
              'Completed', 
              taskCounts['completed'] ?? 0, // ✅ Safe null handling
              Colors.green, 
              Icons.check_circle_outline_rounded
            ),
            _buildStatusCard(
              context, 
              'Cancelled', 
              taskCounts['cancelled'] ?? 0, // ✅ Safe null handling
              Colors.red, 
              Icons.cancel_outlined
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, int count, Color color, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Icon in soft circle ---
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 6,
                    offset: Offset(-3, -3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade100,
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.subColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}