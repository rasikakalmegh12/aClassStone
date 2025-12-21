import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

/// A reusable cool app card with a title and input field
class CoolAppCard extends StatelessWidget {
  final String title;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Color backgroundColor = AppColors.primaryTealDark;

  const CoolAppCard({
    Key? key,
    required this.title,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return  Container(
       decoration: BoxDecoration(
         color: backgroundColor,
         borderRadius: const BorderRadius.only(
           bottomLeft: Radius.circular(18),
           bottomRight: Radius.circular(18),
         ),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withAlpha((0.08 * 255).toInt()),
             blurRadius: 12,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       child: AppBar(
         backgroundColor: Colors.transparent,
         elevation: 0,
         automaticallyImplyLeading: true,
         leading: Padding(
           padding: const EdgeInsets.only(left: 8.0),
           child: Container(
             // decoration: BoxDecoration(
             //   color: Colors.white.withAlpha((0.13 * 255).toInt()),
             //   borderRadius: BorderRadius.circular(12),
             // ),
             child: IconButton(
               icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
               onPressed: () {
                 context.pop();
               },
               tooltip: 'Back',
             ),
           ),
         ),
         title:  Text(
           title,
           style: const TextStyle(
             color: Colors.white,
             fontWeight: FontWeight.bold,
             fontSize: 18,
             letterSpacing: -0.5,
           ),
         ),
         centerTitle: true,
       ),
     );
    // Container(
    //   margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    //   padding: const EdgeInsets.all(18),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(18),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.07),
    //         blurRadius: 12,
    //         offset: const Offset(0, 4),
    //       ),
    //     ],
    //     border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         title,
    //         style: const TextStyle(
    //           fontSize: 17,
    //           fontWeight: FontWeight.bold,
    //           color: Color(0xFF1A202C),
    //           letterSpacing: -0.5,
    //         ),
    //       ),
    //       const SizedBox(height: 14),
    //       TextFormField(
    //         initialValue: initialValue,
    //         onChanged: onChanged,
    //         obscureText: obscureText,
    //         keyboardType: keyboardType,
    //         decoration: InputDecoration(
    //           hintText: hintText ?? 'Enter value...',
    //           filled: true,
    //           fillColor: const Color(0xFFF8FAFC),
    //           contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(12),
    //             borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    //           ),
    //           enabledBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(12),
    //             borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    //           ),
    //           focusedBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(12),
    //             borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}