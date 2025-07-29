// common_widgets.dart

import 'package:flutter/material.dart';

const kInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const kYellow = Color.fromARGB(255, 245, 198, 57);

InputDecoration buildInputDecoration(String label, Icon icon) {
  return InputDecoration(
    labelText: label,
    border: kInputBorder,
    prefixIcon: icon,
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 53, 122, 233),
              Color.fromARGB(255, 113, 195, 230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
