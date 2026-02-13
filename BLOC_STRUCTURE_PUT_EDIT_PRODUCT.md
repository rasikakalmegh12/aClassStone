## PutEditProductBloc Structure - Complete Implementation

### Overview
The `PutEditProductBloc` is a BLoC pattern implementation for handling product editing operations. It manages the state and events for PUT requests to update existing products in the catalogue.

### Files Created

#### 1. **put_edit_product_event.dart**
```dart
- SubmitPutEditProduct
  - productId: String (ID of the product to edit)
  - requestBody: PutEditCatalogueRequestBody (contains product details to update)
  - showLoader: bool (whether to show loading indicator)
```

#### 2. **put_edit_product_state.dart**
```dart
- PutEditProductInitial (initial state)
- PutEditProductLoading (when API call is in progress)
- PutEditProductSuccess (when update succeeds)
  - response: PutEditCatalogueResponseBody
- PutEditProductError (when update fails)
  - message: String (error message)
```

#### 3. **put_edit_product_bloc.dart**
```dart
class PutEditProductBloc extends Bloc<PutEditProductEvent, PutEditProductState>
- Handles SubmitPutEditProduct events
- Calls ApiIntegration.putEditProduct()
- Emits appropriate states based on response
```

### Integration with AppBlocProvider

The `PutEditProductBloc` has been added to `AppBlocProvider`:
- Import: `'../../bloc/catalogue/put_catalogues_methods/put_edit_product_bloc.dart'`
- Static variable: `static late PutEditProductBloc _putEditProductBloc`
- Initialization: `_putEditProductBloc = PutEditProductBloc()`
- Getter: `static PutEditProductBloc get putEditProductBloc => _putEditProductBloc`
- Disposal: `_putEditProductBloc.close()`

### Usage in EditCatalogue Page

```dart
// Using BlocProvider in route
BlocProvider<PutEditProductBloc>(
  create: (context) => PutEditProductBloc(),
  child: EditCatalogue(productId: productId),
)

// Or using AppBlocProvider
context.read<PutEditProductBloc>().add(
  SubmitPutEditProduct(
    productId: productId,
    requestBody: requestBody,
    showLoader: true,
  ),
)

// Listening to state changes
BlocListener<PutEditProductBloc, PutEditProductState>(
  listener: (context, state) {
    if (state is PutEditProductLoading && state.showLoader) {
      showCustomProgressDialog(context);
    } else if (state is PutEditProductSuccess) {
      dismissCustomProgressDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context, true);
    } else if (state is PutEditProductError) {
      dismissCustomProgressDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: // your widget
)
```

### API Integration

The bloc uses `ApiIntegration.putEditProduct()` which:
- Method: PUT
- Endpoint: `{ApiConstants.editProduct}/{productId}`
- Request Body: `PutEditCatalogueRequestBody`
- Response: `PutEditCatalogueResponseBody`

### Request Body Structure (PutEditCatalogueRequestBody)

```json
{
  "productCode": "string",
  "name": "string",
  "description": "string",
  "productTypeId": "uuid",
  "pricePerSqftArchitectGradeA": 0,
  "pricePerSqftArchitectGradeB": 0,
  "pricePerSqftArchitectGradeC": 0,
  "pricePerSqftTraderGradeA": 0,
  "pricePerSqftTraderGradeB": 0,
  "pricePerSqftTraderGradeC": 0,
  "priceRangeId": "uuid",
  "marketingOneLiner": "string",
  "mineId": "uuid"
}
```

### Response Body Structure (PutEditCatalogueResponseBody)

```json
{
  "status": true,
  "message": "Product updated successfully",
  "statusCode": 200,
  "data": {
    "id": "uuid",
    "productCode": "string",
    "name": "string",
    ...
  }
}
```

### Features

✅ State Management with BLoC pattern
✅ Loading indicators support
✅ Error handling with messages
✅ API integration via AppBlocProvider
✅ Proper disposal to prevent memory leaks
✅ Type-safe event and state handling

### Next Steps

1. Implement the EditCatalogue page UI
2. Load existing product details when editing
3. Bind form fields to request body
4. Add form validation
5. Call PutEditProductBloc when submitting form
6. Handle success/error states appropriately

