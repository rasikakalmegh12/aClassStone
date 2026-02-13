# EditCatalogue Code Architecture

## 📁 File Structure

```
lib/
├── presentation/
│   └── catalog/
│       └── edit_catalogue.dart (NEW - Main Edit Page)
├── bloc/
│   └── catalogue/
│       ├── get_catalogue_methods/
│       │   ├── get_catalogue_bloc.dart (Existing)
│       │   ├── get_catalogue_event.dart (Existing)
│       │   └── get_catalogue_state.dart (Existing)
│       └── put_catalogues_methods/
│           ├── put_edit_product_bloc.dart (Existing)
│           ├── put_edit_product_event.dart (Existing)
│           └── put_edit_product_state.dart (Existing)
└── api/
    └── models/
        ├── request/
        │   └── PutEditCatalogueRequestBody.dart
        └── response/
            └── GetCatalogueProductDetailsResponseBody.dart
```

## 🔄 State Management Flow

### GetCatalogueProductDetailsBloc

```
┌──────────────────────────────────┐
│ GetCatalogueProductDetailsInitial │
└──────────────┬───────────────────┘
               │
               │ FetchGetCatalogueProductDetails
               ▼
┌──────────────────────────────────┐
│ GetCatalogueProductDetailsLoading │
│ (with showLoader: true)          │
└──────────────┬───────────────────┘
               │
         ┌─────┴─────┐
         │           │
         ▼           ▼
    Success       Error
         │           │
    ┌────▼───┐   ┌───▼─────┐
    │ Loaded │   │ Error   │
    │ (data) │   │ (msg)   │
    └────────┘   └─────────┘
```

**Purpose**: Load product details from API

**Events**:
- `FetchGetCatalogueProductDetails(productId, showLoader)`

**States**:
- `GetCatalogueProductDetailsInitial` → `GetCatalogueProductDetailsLoading` → `GetCatalogueProductDetailsLoaded` OR `GetCatalogueProductDetailsError`

**Data Loaded**:
```dart
Data {
  id: String
  name: String
  description: String
  pricePerSqft: String
  productTypeId: String
  productTypeName: String
  priceSqftArchitectGradeA: int
  priceSqftArchitectGradeB: int
  priceSqftArchitectGradeC: int
  priceSqftTraderGradeA: int
  priceSqftTraderGradeB: int
  priceSqftTraderGradeC: int
  priceRangeId: String
  priceRangeName: String
  marketingOneLiner: String
  mineId: String
  isActive: bool
  sortOrder: int
  imageUrls: List<String>
  primaryImageUrl: String
  // ... other attributes
}
```

### PutEditProductBloc

```
┌──────────────────────────┐
│ PutEditProductInitial     │
└──────────────┬────────────┘
               │
               │ SubmitPutEditProduct
               ▼
┌──────────────────────────┐
│ PutEditProductLoading    │
│ (with showLoader: true)  │
└──────────────┬────────────┘
               │
         ┌─────┴─────┐
         │           │
         ▼           ▼
    Success       Error
         │           │
    ┌────▼───┐   ┌───▼─────┐
    │ Success│   │ Error   │
    │(response)  │ (msg)   │
    └────────┘   └─────────┘
```

**Purpose**: Update product details on server

**Events**:
- `SubmitPutEditProduct(productId, requestBody, showLoader)`

**States**:
- `PutEditProductInitial` → `PutEditProductLoading` → `PutEditProductSuccess` OR `PutEditProductError`

**Request Body**:
```dart
PutEditCatalogueRequestBody {
  name: String
  description: String
  productTypeId: String
  priceRangeId: String
  mineId: String
  isActive: bool
  sortOrder: int
  priceSqftArchitectGradeA: int
  priceSqftArchitectGradeB: int
  priceSqftArchitectGradeC: int
  priceSqftTraderGradeA: int
  priceSqftTraderGradeB: int
  priceSqftTraderGradeC: int
  marketingOneLiner: String
}
```

## 🎯 EditCatalogue Widget Architecture

### Class Structure

```dart
class EditCatalogue extends StatefulWidget {
  final String? productId;
  // Entry point with productId
}

class _EditCatalogueState extends State<EditCatalogue> {
  // State management for form
}
```

### Key State Variables

```dart
// Form Keys & Controllers
GlobalKey<FormState> _formKey;
TextEditingController _nameController;
TextEditingController _descriptionController;
TextEditingController _marketingOneLinedController;
TextEditingController _sortOrderController;
TextEditingController _archGradeAController;
TextEditingController _archGradeBController;
TextEditingController _archGradeCController;
TextEditingController _traderGradeAController;
TextEditingController _traderGradeBController;
TextEditingController _traderGradeCController;

// Selection State
String? selectedProductTypeId;
String? selectedPriceRangeId;
String? selectedMineId;
bool isActive = true;

// Image Management
List<String> uploadedImageUrls = [];
String? primaryImageUrl;
List<File> newLocalImages = [];
```

### Lifecycle Methods

```dart
@override
void initState() {
  // 1. Initialize all controllers
  // 2. Load product details from API
}

@override
void dispose() {
  // Dispose all controllers
}
```

### Main Methods

```dart
void _initializeControllers()
  → Creates empty TextEditingControllers

void _populateFormWithData(Data data)
  → Fills form fields from API response

Future<void> _pickImage()
  → Opens image picker and adds to list

void _removeImage(int index, {bool isUploaded})
  → Removes image from list (uploaded or new)

void _setPrimaryImage(String imageUrl)
  → Marks image as primary

void _submitForm()
  → Validates and submits form via BLoC
```

### Widget Building Methods

```dart
Widget _buildImagesSection()
  → Image management UI
  
Widget _buildImageCard()
  → Individual image card with controls
  
Widget _buildLocalImageCard()
  → New image card with delete option
  
Widget _buildSectionTitle(String title)
  → Section header styling
  
Widget _buildTextField()
  → Reusable text field with label & validation
```

## 🔌 BLoC Integration

### GetCatalogueProductDetailsBloc

**Usage**:
```dart
BlocBuilder<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
  builder: (context, state) {
    if (state is GetCatalogueProductDetailsLoading && state.showLoader) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is GetCatalogueProductDetailsLoaded) {
      final data = state.response.data;
      // Populate form with data
    }
    
    if (state is GetCatalogueProductDetailsError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    
    return const SizedBox();
  },
)
```

**Trigger**:
```dart
context.read<GetCatalogueProductDetailsBloc>().add(
  FetchGetCatalogueProductDetails(
    productId: widget.productId!,
    showLoader: true,
  ),
);
```

### PutEditProductBloc

**Usage**:
```dart
BlocListener<PutEditProductBloc, PutEditProductState>(
  listener: (context, state) {
    if (state is PutEditProductLoading && state.showLoader) {
      showCustomProgressDialog(context);
    } else if (state is PutEditProductSuccess) {
      dismissCustomProgressDialog(context);
      // Navigate back
      context.pop(true);
    } else if (state is PutEditProductError) {
      dismissCustomProgressDialog(context);
      // Show error
    }
  },
  child: // Form content
)
```

**Trigger**:
```dart
context.read<PutEditProductBloc>().add(
  SubmitPutEditProduct(
    productId: widget.productId!,
    requestBody: requestBody,
    showLoader: true,
  ),
);
```

## 📐 Layout Structure

```
Scaffold
├── AppBar (CoolAppCard)
└── BlocListener<PutEditProductBloc>
    └── BlocBuilder<GetCatalogueProductDetailsBloc>
        └── SingleChildScrollView
            └── Form
                └── Column (Main Content)
                    ├── _buildImagesSection()
                    ├── SizedBox(24)
                    ├── "Basic Information" Title
                    ├── Name TextField
                    ├── Description TextField
                    ├── Marketing One Liner TextField
                    ├── SizedBox(24)
                    ├── "Pricing - Architect Grade" Title
                    ├── Row(Grade A, B, C TextFields)
                    ├── SizedBox(24)
                    ├── "Pricing - Trader Grade" Title
                    ├── Row(Grade A, B, C TextFields)
                    ├── SizedBox(24)
                    ├── "Additional Settings" Title
                    ├── Sort Order TextField
                    ├── Active Switch
                    ├── SizedBox(24)
                    ├── Update Button
                    └── SizedBox(16)
```

## 🎨 UI Component Hierarchy

### Image Section
```
_buildImagesSection()
├── Section Title
├── Wrap (Uploaded Images)
│   └── _buildImageCard() × n
├── Wrap (New Images)
│   └── _buildLocalImageCard() × n
└── Add Image Button
```

### Image Card
```
_buildImageCard()
├── Container (Image + Border)
│   └── ClipRRect
│       └── Image.network()
├── Positioned (Delete Button - Top Right)
├── Positioned (Set Primary Button - Bottom Left)
└── Positioned (Primary Badge)
```

### Text Field
```
_buildTextField()
├── Label Text
├── TextFormField
    ├── Decoration (Border, Focus)
    ├── Validation (if required)
    └── Keyboard Type
```

## 🔗 API Integration

### Load Product Details
```
EditCatalogue
  └── initState()
      └── GetCatalogueProductDetailsBloc
          └── ApiIntegration.getCatalogueProductDetails()
              └── GET /api/catalogue/products/{productId}
```

### Update Product
```
EditCatalogue
  └── _submitForm()
      └── PutEditProductBloc
          └── ApiIntegration.putEditProduct()
              └── PUT /api/catalogue/products/{productId}
```

## 💾 Data Flow

### Load → Display
```
API Response (GetCatalogueProductDetails)
  ↓
BLoC (GetCatalogueProductDetailsLoaded)
  ↓
Widget (BlocBuilder)
  ↓
_populateFormWithData()
  ↓
Form Fields Display Current Values
```

### Edit → Submit
```
User Edits Form Fields
  ↓
Click "Update Product" Button
  ↓
_submitForm() Validates Form
  ↓
Creates PutEditCatalogueRequestBody
  ↓
PutEditProductBloc.add(SubmitPutEditProduct)
  ↓
API PUT Request
  ↓
Success/Error Response
  ↓
Update UI & Navigate
```

## 🔄 Validation Flow

```
User clicks "Update Product"
  ↓
_submitForm()
  ├── Check _formKey.currentState!.validate()
  │   ├── Product Name required ✓
  │   ├── Numeric fields ✓
  │   └── Return true if valid
  ├── If valid:
  │   └── Create request body
  │       └── Add to BLoC
  └── If invalid:
      └── Show field errors
```

## 🎯 Error Handling

### API Loading Errors
```dart
if (state is GetCatalogueProductDetailsError) {
  return Center(
    child: Text('Error: ${state.message}'),
  );
}
```

### API Submit Errors
```dart
if (state is PutEditProductError) {
  dismissCustomProgressDialog(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```

### Validation Errors
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  },
)
```

## 📊 State Management Summary

| Component | Purpose | Input | Output |
|-----------|---------|-------|--------|
| GetCatalogueProductDetailsBloc | Load data | productId | Product Data |
| PutEditProductBloc | Save changes | requestBody | Success/Error |
| EditCatalogue Widget | UI & Logic | productId | Updated Product |

## 🚀 Initialization Sequence

```
1. EditCatalogue created with productId
2. initState() called
3. Controllers initialized (empty)
4. FetchGetCatalogueProductDetails event added
5. API call in progress (loading indicator shown)
6. API response received
7. GetCatalogueProductDetailsLoaded state emitted
8. _populateFormWithData() called
9. Form fields filled with current values
10. User can now edit
```

## 📱 Responsive Layout

```dart
SingleChildScrollView  // Vertical scroll
  └── Column          // Vertical stacking
      ├── Images Section
      ├── Text Fields  // Full width
      ├── Price Rows  // 3 fields per row
      │   └── Row
      │       ├── Expanded (Grade A)
      │       ├── Expanded (Grade B)
      │       └── Expanded (Grade C)
      ├── Settings
      └── Submit Button (Full width)
```

