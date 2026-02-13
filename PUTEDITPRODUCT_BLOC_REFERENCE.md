# PutEditProductBloc - Complete Structure Reference

## 📁 Project Structure

```
lib/
├── bloc/
│   └── catalogue/
│       ├── get_catalogue_methods/
│       │   ├── get_catalogue_bloc.dart
│       │   ├── get_catalogue_event.dart
│       │   └── get_catalogue_state.dart
│       │
│       ├── post_catalogue_methods/
│       │   ├── post_catalogue_bloc.dart
│       │   ├── post_catalogue_event.dart
│       │   └── post_catalogue_state.dart
│       │
│       └── put_catalogues_methods/  ✨ NEW
│           ├── put_edit_product_bloc.dart
│           ├── put_edit_product_event.dart
│           └── put_edit_product_state.dart
│
├── core/
│   ├── navigation/
│   │   └── app_router.dart (✅ Updated with editProduct route)
│   └── services/
│       └── repository_provider.dart (✅ Updated with PutEditProductBloc)
│
└── presentation/
    └── catalog/
        └── edit_catalogue.dart (✅ Updated to accept productId)
```

## 📋 File Details

### put_edit_product_event.dart (482 bytes)
```dart
abstract class PutEditProductEvent {}

class SubmitPutEditProduct extends PutEditProductEvent {
  final String productId;
  final PutEditCatalogueRequestBody requestBody;
  final bool showLoader;
  
  SubmitPutEditProduct({
    required this.productId,
    required this.requestBody,
    this.showLoader = false,
  });
}
```

### put_edit_product_state.dart (694 bytes)
```dart
abstract class PutEditProductState {}

class PutEditProductInitial extends PutEditProductState {}
class PutEditProductLoading extends PutEditProductState { ... }
class PutEditProductSuccess extends PutEditProductState { ... }
class PutEditProductError extends PutEditProductState { ... }
```

### put_edit_product_bloc.dart (1065 bytes)
```dart
class PutEditProductBloc extends Bloc<PutEditProductEvent, PutEditProductState> {
  PutEditProductBloc() : super(PutEditProductInitial()) {
    on<SubmitPutEditProduct>((event, emit) async { ... });
  }
}
```

## 🔗 Integration Points

### 1️⃣ AppBlocProvider (repository_provider.dart)
```dart
// Import
import '../../bloc/catalogue/put_catalogues_methods/put_edit_product_bloc.dart';

// Static Variable
static late PutEditProductBloc _putEditProductBloc;

// Initialization
_putEditProductBloc = PutEditProductBloc();

// Getter
static PutEditProductBloc get putEditProductBloc => _putEditProductBloc;

// Disposal
_putEditProductBloc.close();
```

### 2️⃣ App Router (app_router.dart)
```dart
// Import
import '../../bloc/catalogue/put_catalogues_methods/put_edit_product_bloc.dart';

// Route Provider
GoRoute(
  path: '/editProduct',
  name: 'editProduct',
  builder: (context, state) {
    final productId = state.extra as String?;
    return MultiBlocProvider(
      providers: [
        // ... other BLoCs
        BlocProvider<PutEditProductBloc>(
          create: (context) => PutEditProductBloc(),
        ),
      ],
      child: EditCatalogue(productId: productId),
    );
  },
)
```

### 3️⃣ Catalogue Main (catalog_main.dart)
```dart
void _enterSelectionModeWith(Items p) {
  if (SessionManager.getUserRole() == 'superadmin') {
    _showEditOptionMenu(p);
    return;
  }
  // ... existing code
}

void _showEditOptionMenu(Items product) {
  showModalBottomSheet(
    // Shows Edit button that navigates to:
    context.pushNamed(
      'editProduct',
      extra: product.id,
    );
  );
}
```

## 🔄 Data Flow

```
User (Superadmin)
      ↓
Long Press Product
      ↓
_enterSelectionModeWith(Items)
      ↓
_showEditOptionMenu(Items)
      ↓
Bottom Sheet Menu
      ↓
Click Edit Button
      ↓
context.pushNamed('editProduct', extra: productId)
      ↓
EditCatalogue Page (with productId)
      ↓
BlocListener<PutEditProductBloc>
      ↓
User fills/edits form
      ↓
Submit Form
      ↓
context.read<PutEditProductBloc>().add(
  SubmitPutEditProduct(
    productId: productId,
    requestBody: requestBody,
    showLoader: true,
  )
)
      ↓
PutEditProductBloc
      ↓
ApiIntegration.putEditProduct()
      ↓
PutEditProductLoading → API Call → Success/Error
      ↓
BlocListener handles state
      ↓
Show feedback (SnackBar/Dialog)
      ↓
Navigate back / Refresh
```

## 🎯 Key Features

| Feature | Status | Details |
|---------|--------|---------|
| Event Class | ✅ | SubmitPutEditProduct with productId, requestBody, showLoader |
| State Classes | ✅ | Initial, Loading, Success, Error |
| BLoC Class | ✅ | Handles events and calls API |
| API Integration | ✅ | Uses ApiIntegration.putEditProduct() |
| Route | ✅ | /editProduct with productId as extra |
| AppBlocProvider | ✅ | Added to singleton provider |
| Bottom Sheet Menu | ✅ | Edit option for superadmins |
| Navigation | ✅ | From catalogue_main to edit_catalogue |
| Error Handling | ✅ | Proper error messages and states |
| Loading States | ✅ | Progress indicators supported |

## 📚 Related Classes

### Request Body
- **Class**: `PutEditCatalogueRequestBody`
- **Location**: `lib/api/models/request/`
- **Fields**: productCode, name, description, prices, mineId, etc.

### Response Body
- **Class**: `PutEditCatalogueResponseBody`
- **Location**: `lib/api/models/response/`
- **Fields**: status, message, statusCode, data

### API Integration
- **Method**: `ApiIntegration.putEditProduct()`
- **HTTP Method**: PUT
- **Endpoint**: `{ApiConstants.editProduct}/{productId}`

## ✅ Testing Checklist

- [x] Files created in correct directory
- [x] Imports added to AppBlocProvider
- [x] Static variable declared and initialized
- [x] Getter created
- [x] Disposal method updated
- [x] Route configured in app_router
- [x] BlocProvider added to route
- [x] Navigation implemented in catalog_main
- [x] Bottom sheet menu created
- [x] No compilation errors
- [x] Follows existing patterns

## 🚀 Ready for Use

The PutEditProductBloc structure is complete and ready to be used in the EditCatalogue page. The bloc is fully integrated and can be accessed via:

```dart
// Option 1: Using BlocProvider in route (automatic)
context.read<PutEditProductBloc>()

// Option 2: Using AppBlocProvider
AppBlocProvider.putEditProductBloc

// Option 3: Via BlocBuilder/BlocListener
BlocBuilder<PutEditProductBloc, PutEditProductState>
BlocListener<PutEditProductBloc, PutEditProductState>
```

---

**Status**: ✅ Implementation Complete & Ready
**Date**: February 10, 2026
**Maintainer**: GitHub Copilot

