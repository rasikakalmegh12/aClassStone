import 'package:flutter/material.dart';

// CustomProgressDialog class
class CustomProgressDialog extends StatelessWidget {
  final String title;

  // Constructor to accept custom title text
  const CustomProgressDialog({Key? key, this.title = 'Please wait...!!!'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Set the background to transparent
      child: _buildDialogContent(context), // Build the dialog content
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0), // Container padding
      decoration: BoxDecoration(
        // color: Colors.black.withOpacity(0.8), // Semi-transparent background color
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimize the size to its content
        children: [
          // Display GIF loader from assets
          Image.asset(
            'assets/images/loading.gif', // Path to your GIF asset
            width: 200.0,
            height: 150.0,
          ),
          const SizedBox(height: 16.0), // Add some space between GIF and text

          // Display the title text below the GIF
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, // Text color
              fontSize: 16.0,      // Font size
              fontWeight: FontWeight.bold, // Bold text
            ),
            textAlign: TextAlign.center, // Center the text
          ),
        ],
      ),
    );
  }
}

// Function to show the custom progress dialog
void showCustomProgressDialog(BuildContext context, {String title = 'Please wait...!!!'}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return CustomProgressDialog(title: title);
    },
  );
}

// Function to dismiss the custom progress dialog
void dismissCustomProgressDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
}