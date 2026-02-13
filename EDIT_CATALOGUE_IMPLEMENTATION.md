# EditCatalogue Page - Complete Implementation Guide

## 📋 Overview
The `EditCatalogue` page provides a comprehensive product editing interface with the following features:
- ✅ Load product details via `GetCatalogueProductDetailsBloc`
- ✅ Edit product information (name, description, pricing)
- ✅ Image management (add, delete, set as primary)
- ✅ Submit changes via `PutEditProductBloc`
- ✅ Real-time form validation

## 🎨 Features

### 1. **Product Details Loading**
```dart
// Triggered in initState
context.read<GetCatalogueProductDetailsBloc>().add(
  FetchGetCatalogueProductDetails(
    productId: widget.productId!,
    showLoader: true,
  ),
);
```

### 2. **Image Management**
- **Add Images**: Pick images from gallery
- **Delete Images**: Remove uploaded or new images
- **Set Primary**: Mark any uploaded image as primary
- **Visual Feedback**: Badges show "Primary" and "New" status

#### Image Display
- Uploaded images show with checkmark button to set as primary
- New local images marked with "New" badge
- Delete button available for both types
- Primary image highlighted with green border

### 3. **Form Fields**

#### Basic Information
- Product Name (required)
- Description
- Marketing One Liner

#### Pricing - Architect Grade
- Grade A Price
- Grade B Price
- Grade C Price

#### Pricing - Trader Grade
- Grade A Price
- Grade B Price
- Grade C Price

#### Additional Settings
- Sort Order
- Active Toggle

### 4. **Validation**
- Form validation on submit
- Required field validation
- Numeric validation for price fields
- Sort order validation

### 5. **State Management**
```dart
// GetCatalogueProductDetailsBloc
- Loads product data
- Populates form fields
- Shows loading state

// PutEditProductBloc
- Submits updated data
- Shows progress dialog
- Handles success/error states
```

## 🔌 Integration Points

### Route Definition
The route should provide both BLoCs:

```dart
GoRoute(
  path: '/editProduct/:productId',
  name: 'editProduct',
  builder: (context, state) {
    final productId = state.pathParameters['productId'];
    return MultiBlocProvider(
      providers: [
        BlocProvider<GetCatalogueProductDetailsBloc>(
          create: (context) => GetCatalogueProductDetailsBloc(),
        ),
        BlocProvider<PutEditProductBloc>(
          create: (context) => PutEditProductBloc(),
        ),
      ],
      child: EditCatalogue(productId: productId),
    );
  },
)
```

### Navigation from Catalogue Page
```dart
// Long press on product card (SuperAdmin only)
onLongPress: () {
  if (SessionManager.getUserRole().toString().toLowerCase() == "superadmin") {
    context.pushNamed('editProduct', pathParameters: {'productId': productId});
  }
}
```

## 📊 Data Flow

```
┌─────────────────────────────────────────┐
│     EditCatalogue Widget Created        │
└─────────────────────┬───────────────────┘
                      │
                      ▼
        ┌─────────────────────────┐
        │  Load Product Details   │
        │  GetCatalogueDetails    │
        │  Bloc.add(Fetch...)     │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │  Populate Form Fields   │
        │  with API Response      │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │  User Edits Form        │
        │  - Text Fields          │
        │  - Images               │
        │  - Toggle Settings      │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │  Submit Form            │
        │  PutEditProduct         │
        │  Bloc.add(Submit...)    │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │  Show Progress Dialog   │
        │  Update Product         │
        └────────────┬────────────┘
                     │
        ┌────────────▼──────────────────┐
        │  Success / Error Response     │
        │  - Dismiss Progress Dialog    │
        │  - Show SnackBar Message      │
        │  - Pop Navigation (on success)│
        └───────────────────────────────┘
```

## 🎯 Key Implementation Details

### Image Management
```dart
// Upload stored images
List<String> uploadedImageUrls = [];
String? primaryImageUrl;

// New local images
List<File> newLocalImages = [];

// Operations
_pickImage()        // Add new image
_removeImage()      // Delete image
_setPrimaryImage()  // Mark as primary
```

### Form Submission
```dart
void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final requestBody = PutEditCatalogueRequestBody(
      name: _nameController.text,
      description: _descriptionController.text,
      // ... other fields
    );

    context.read<PutEditProductBloc>().add(
      SubmitPutEditProduct(
        productId: widget.productId!,
        requestBody: requestBody,
        showLoader: true,
      ),
    );
  }
}
```

### State Listeners
```dart
BlocListener<PutEditProductBloc, PutEditProductState>(
  listener: (context, state) {
    if (state is PutEditProductLoading && state.showLoader) {
      showCustomProgressDialog(context);
    } else if (state is PutEditProductSuccess) {
      dismissCustomProgressDialog(context);
      // Show success message
      // Navigate back
    } else if (state is PutEditProductError) {
      dismissCustomProgressDialog(context);
      // Show error message
    }
  },
  child: // Form content
)
```

## 🎨 UI Components

### Section Titles
```dart
Text(
  'Basic Information',
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
)
```

### Text Fields
- Custom `_buildTextField()` helper
- Configurable:
  - Label
  - Hint text
  - Max lines
  - Keyboard type
  - Required validation
  - Focused/enabled border colors

### Image Cards
- **Uploaded Images**: Green border if primary, checkmark to set primary
- **New Images**: Orange "New" badge
- **Delete**: Red circular X button
- Error handling: Broken image icon

### Buttons
- **Update Product**: Blue button matching theme
- **Add Image**: Dashed container with icon
- **Delete/Primary**: Small circular icon buttons

## 📝 Form Fields Reference

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| Name | Text | ✓ | Not empty |
| Description | TextArea | | Any text |
| Marketing One Liner | Text | | Any text |
| Arch Grade A | Number | | Numeric |
| Arch Grade B | Number | | Numeric |
| Arch Grade C | Number | | Numeric |
| Trader Grade A | Number | | Numeric |
| Trader Grade B | Number | | Numeric |
| Trader Grade C | Number | | Numeric |
| Sort Order | Number | | Numeric |
| Active | Toggle | | Boolean |

## 🔄 State Management

### GetCatalogueProductDetailsBloc States
- `GetCatalogueProductDetailsLoading`: Shows progress while loading
- `GetCatalogueProductDetailsLoaded`: Data loaded, form populated
- `GetCatalogueProductDetailsError`: Error message displayed

### PutEditProductBloc States
- `PutEditProductLoading`: Shows progress dialog during update
- `PutEditProductSuccess`: Update successful, navigate back
- `PutEditProductError`: Show error message

## ⚠️ Important Notes

### Image Handling
- **New Images**: Not uploaded in this implementation
  - Ready for future upload functionality
  - Currently stored in `newLocalImages` list
- **Uploaded Images**: Can be deleted or marked as primary
- **Primary Image**: Selected image shown as default

### Form Population
- Data loaded once when page initializes
- Controllers populated from API response
- Subsequent API calls update internal state

### Validation
- Product name is required
- Price fields accept numeric input
- Form validates before submission

### Navigation
- Uses GoRouter for type-safe navigation
- ProductId passed as path parameter
- Pops with `true` on success

## 🚀 Future Enhancements

1. **Image Upload**: Implement image upload to server
2. **Dropdown Selectors**: Add dropdowns for:
   - Product Type
   - Price Range
   - Mine Selection
3. **Image Compression**: Compress images before upload
4. **Undo Changes**: Add reset/undo functionality
5. **Auto-save**: Implement auto-save on field changes

## 📱 Responsive Design

The page uses:
- `SingleChildScrollView` for scrollable content
- `Flexible` containers for responsive layouts
- `Expanded` widgets for optimal spacing
- Proper padding and margins

## 🎯 Testing Checklist

- [ ] Load product details successfully
- [ ] Form fields populate correctly
- [ ] Add image functionality works
- [ ] Delete image removes it from list
- [ ] Set primary image updates badge
- [ ] Form validation works (required fields)
- [ ] Submit form triggers BLoC
- [ ] Loading dialog shows during update
- [ ] Success message shows on success
- [ ] Navigation back after success
- [ ] Error message shows on failure
- [ ] Numeric validation on price fields

## 📞 Support

For issues or questions:
1. Check BLoC states and transitions
2. Verify GetCatalogueProductDetailsBloc data loading
3. Check PutEditProductBloc submission
4. Validate form field controllers
5. Check API response structure

