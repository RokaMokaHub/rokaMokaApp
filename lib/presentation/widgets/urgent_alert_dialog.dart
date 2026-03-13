import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';

class UrgentAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color confirmTextColor;

  const UrgentAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'OK',
    this.cancelText = 'Cancelar',
    this.confirmTextColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(titleColor),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(greySubtitleColor),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _buildGradientButton(
              label: confirmText,
              onPressed: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 14),
            _buildGradientButton(
              label: cancelText,
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
