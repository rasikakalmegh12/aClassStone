// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../core/constants/app_colors.dart';
//
// /// A reusable cool app card with a title and input field
// class CoolAppCard extends StatelessWidget {
//   final String title;
//   final String? initialValue;
//   final ValueChanged<String>? onChanged;
//   final String? hintText;
//   final TextInputType? keyboardType;
//   final bool obscureText;
//   final Color backgroundColor ;
//
//   const CoolAppCard({
//     Key? key,
//     required this.title,
//     this.initialValue,
//     this.onChanged,
//     this.hintText,
//     this.keyboardType,
//     this.obscureText = false,
//     this.backgroundColor = AppColors.primaryTealDark,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//      return  Container(
//        decoration: BoxDecoration(
//          color: backgroundColor,
//          borderRadius: const BorderRadius.only(
//            bottomLeft: Radius.circular(18),
//            bottomRight: Radius.circular(18),
//          ),
//          boxShadow: [
//            BoxShadow(
//              color: Colors.black.withAlpha((0.08 * 255).toInt()),
//              blurRadius: 12,
//              offset: const Offset(0, 4),
//            ),
//          ],
//        ),
//        child: AppBar(
//          backgroundColor: Colors.transparent,
//          elevation: 0,
//          automaticallyImplyLeading: true,
//          leading: Padding(
//            padding: const EdgeInsets.only(left: 8.0),
//            child: Container(
//              // decoration: BoxDecoration(
//              //   color: Colors.white.withAlpha((0.13 * 255).toInt()),
//              //   borderRadius: BorderRadius.circular(12),
//              // ),
//              child: IconButton(
//                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
//                onPressed: () {
//                  context.pop();
//                },
//                tooltip: 'Back',
//              ),
//            ),
//          ),
//          title:  Text(
//            title,
//            style: const TextStyle(
//              color: Colors.white,
//              fontWeight: FontWeight.bold,
//              fontSize: 18,
//              letterSpacing: -0.5,
//            ),
//          ),
//          centerTitle: true,
//        ),
//      );
//
//   }
// }


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class CoolAppCard extends StatelessWidget {
  final String title;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Color backgroundColor;

  /// Optional single trailing action (e.g. calendar icon button)
  final Widget? action;

  // If you ever need multiple actions, you can instead use:
  // final List<Widget>? actions;

  const CoolAppCard({
    Key? key,
    required this.title,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.backgroundColor = AppColors.primaryTealDark,
    this.action,
    // this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              context.pop();
            },
            tooltip: 'Back',
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,

        // Only show action when provided
        actions: action != null ? [action!] : null,
        // If using List<Widget>? actions field:
        // actions: actions,
      ),
    );
  }
}
