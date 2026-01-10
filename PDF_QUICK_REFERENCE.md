# PDF Generation Quick Reference

## 🚀 Quick Start

### How to Use
1. Open any product in catalogue
2. Tap the **share icon (📤)** in product details
3. PDF will be generated automatically
4. Share via WhatsApp, Email, or other apps

---

## 📋 For Developers

### Trigger PDF Generation
```dart
context.read<GeneratePdfBloc>().add(
  GeneratePdfForProduct(
    productId: 'product-uuid-here',
    showLoader: true,
  ),
);
```

### Listen to Results
```dart
BlocConsumer<GeneratePdfBloc, GeneratePdfState>(
  listener: (context, state) {
    if (state is GeneratePdfSuccess) {
      final url = state.response.data?.fullUrl;
      // Share or open the PDF
    }
  },
  builder: (context, state) {
    return state is GeneratePdfLoading 
      ? CircularProgressIndicator()
      : IconButton(icon: Icon(Icons.share));
  },
)
```

---

## 🔧 API Details

### Endpoint
```
POST /api/v1/marketing/catalogue/products/{productId}/pdf
```

### Response
```json
{
  "status": true,
  "data": {
    "fullUrl": "http://example.com/product.pdf"
  }
}
```

---

## 📦 Required Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  url_launcher: ^6.2.5
  share_plus: ^7.2.2
```

Install:
```bash
flutter pub get
```

---

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `lib/bloc/generate_pdf/generate_pdf_bloc.dart` | State management |
| `lib/api/integration/api_integration.dart` | API call |
| `lib/presentation/catalog/catalog_main.dart` | UI integration |

---

## ✅ Features

- ✅ One-tap PDF generation
- ✅ Native share dialog (Android/iOS)
- ✅ Opens in browser as fallback
- ✅ Loading indicator
- ✅ Error handling
- ✅ Works offline-ready

---

## 🐛 Common Issues

### Issue: "Could not open PDF"
**Solution**: Check internet connection and try again

### Issue: Share dialog doesn't appear
**Solution**: PDF opens in browser automatically as fallback

### Issue: Product ID not available
**Solution**: Ensure product is loaded correctly before sharing

---

## 📝 Testing

```bash
# Run the app
flutter run

# Navigate to catalogue
# Open any product
# Tap share icon
# Verify PDF is generated and shared
```

---

**Status**: ✅ Production Ready
**Last Updated**: January 11, 2026

