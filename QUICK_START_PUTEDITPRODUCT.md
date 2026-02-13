# Quick Start - PutEditProductBloc Usage

## 🚀 Quick Integration Guide

### Step 1: Use the BLoC in EditCatalogue Page

```dart
import 'package:apclassstone/bloc/catalogue/put_catalogues_methods/put_edit_product_bloc.dart';
import 'package:apclassstone/bloc/catalogue/put_catalogues_methods/put_edit_product_event.dart';
import 'package:apclassstone/bloc/catalogue/put_catalogues_methods/put_edit_product_state.dart';

class EditCatalogue extends StatefulWidget {
  final String? productId;

  const EditCatalogue({super.key, this.productId});

  @override
  State<EditCatalogue> createState() => _EditCatalogueState();
}

class _EditCatalogueState extends State<EditCatalogue> {
  // Your form variables
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  // ... other controllers

  @override
  void initState() {
    super.initState();
    _initializeForm();
    
    if (widget.productId != null) {
      _loadProductDetails();
    }
  }

  void _initializeForm() {
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    // Initialize other controllers
  }

  void _loadProductDetails() {
    // TODO: Load product details using productId
    // You can use GetCatalogueProductDetailsBloc for this
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create request body
      final requestBody = PutEditCatalogueRequestBody(
        productCode: _codeController.text,
        name: _nameController.text,
        // ... fill other fields
      );

      // Trigger bloc
      context.read<PutEditProductBloc>().add(
        SubmitPutEditProduct(
          productId: widget.productId!,
          requestBody: requestBody,
          showLoader: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: BlocListener<PutEditProductBloc, PutEditProductState>(
        listener: (context, state) {
          if (state is PutEditProductLoading && state.showLoader) {
            // Show progress indicator
            showCustomProgressDialog(context);
          } else if (state is PutEditProductSuccess) {
            // Hide progress
            dismissCustomProgressDialog(context);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate back with success flag
            Navigator.pop(context, true);
          } else if (state is PutEditProductError) {
            // Hide progress
            dismissCustomProgressDialog(context);
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Product Code Field
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Product Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Product code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ... other form fields

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    // Dispose other controllers
    super.dispose();
  }
}
```

## Step 2: Access BLoC in Routes

The BLoC is already provided in the route:

```dart
// In app_router.dart - Already configured
GoRoute(
  path: '/editProduct',
  name: 'editProduct',
  builder: (context, state) {
    final productId = state.extra as String?;
    return MultiBlocProvider(
      providers: [
        // ... other providers
        BlocProvider<PutEditProductBloc>(
          create: (context) => PutEditProductBloc(),
        ),
      ],
      child: EditCatalogue(productId: productId),
    );
  },
)
```

## Step 3: Optional - Use AppBlocProvider

If you need to access the bloc outside of the route context:

```dart
import 'package:apclassstone/core/services/repository_provider.dart';

class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access via AppBlocProvider
    final bloc = AppBlocProvider.putEditProductBloc;
    
    // Or use BlocBuilder
    return BlocBuilder<PutEditProductBloc, PutEditProductState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is PutEditProductLoading) {
          return const CircularProgressIndicator();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

## 📝 Common Tasks

### Task 1: Show Loading Dialog
```dart
if (state is PutEditProductLoading && state.showLoader) {
  showCustomProgressDialog(context);
}
```

### Task 2: Handle Success
```dart
if (state is PutEditProductSuccess) {
  dismissCustomProgressDialog(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Success!')),
  );
  Navigator.pop(context, true);
}
```

### Task 3: Handle Error
```dart
if (state is PutEditProductError) {
  dismissCustomProgressDialog(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${state.message}')),
  );
}
```

### Task 4: Trigger Update
```dart
context.read<PutEditProductBloc>().add(
  SubmitPutEditProduct(
    productId: productId,
    requestBody: PutEditCatalogueRequestBody(
      productCode: code,
      name: name,
      description: description,
      productTypeId: typeId,
      pricePerSqftArchitectGradeA: priceA,
      pricePerSqftArchitectGradeB: priceB,
      pricePerSqftArchitectGradeC: priceC,
      pricePerSqftTraderGradeA: traderA,
      pricePerSqftTraderGradeB: traderB,
      pricePerSqftTraderGradeC: traderC,
      priceRangeId: priceRangeId,
      mineId: mineId,
    ),
    showLoader: true,
  ),
);
```

## 🔍 Debugging Tips

### Check State Changes
```dart
BlocListener<PutEditProductBloc, PutEditProductState>(
  listener: (context, state) {
    print('State changed to: ${state.runtimeType}');
    if (state is PutEditProductLoading) {
      print('Loading: showLoader = ${state.showLoader}');
    }
  },
)
```

### Monitor API Calls
Check your console/logs for:
- `📤 Sending PutEditCatalogueResponseBody request to: ...`
- `📥 PutEditCatalogueResponseBody status: ...`
- `✅ Success or ❌ Error messages`

### Test State Transitions
```
Initial → Loading → Success/Error
```

## ✅ Verification Checklist

- [ ] BLoC imports added to EditCatalogue
- [ ] BlocListener wraps form UI
- [ ] _submitForm() calls context.read<PutEditProductBloc>()
- [ ] Request body properly created
- [ ] States are handled (Loading, Success, Error)
- [ ] Form validation works
- [ ] Success navigates back
- [ ] Error shows message
- [ ] Loading indicator displays

---

**Ready to implement!** Follow the examples above and you're all set! 🎉

