import 'package:catalyst/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WellnessStepper extends StatelessWidget {
  const WellnessStepper({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = ['Review Order', 'Payment', 'Confirmation'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 1,
              color: stepIndex < currentStep
                  ? AppColors.primary
                  : AppColors.border,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.surface,
                border: Border.all(
                  color: isCompleted || isActive
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : AppColors.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 10,
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }
}
