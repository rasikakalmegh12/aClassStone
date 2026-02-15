# BLoC Implementation for Delete Image and Set Primary Image APIs

## Summary
Successfully created a complete BLoC structure for managing delete image and set image as primary operations in the edit catalogue page.

## Files Created

### 1. **put_catalogue_image_operations_event.dart**
Location: `lib/bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_event.dart`

Defines two events:
- `DeleteProductImage`: Triggers deletion of an image from a product
  - Parameters: `productId`, `imageId`, `showLoader`
  
- `SetImagePrimary`: Sets an image as the primary product image
  - Parameters: `productId`, `imageId`, `showLoader`

### 2. **put_catalogue_image_operations_state.dart**
Location: `lib/bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_state.dart`

Defines state classes:
- `PutCatalogueImageOperationsInitial`: Initial state
- `PutCatalogueImageOperationsLoading`: Loading state with operation type tracking
- `DeleteImageSuccess`: Success state after image deletion with imageId
- `SetImagePrimarySuccess`: Success state after setting primary image with imageId
- `PutCatalogueImageOperationsError`: Error state with operation type tracking

### 3. **put_catalogue_image_operations_bloc.dart**
Location: `lib/bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_bloc.dart`

Main BLoC class that handles:
- Event handlers for `DeleteProductImage` and `SetImagePrimary` events
- API integration with `ApiIntegration.deleteProductImage()` and `ApiIntegration.setImagePrimary()`
- Proper state emission based on API responses
- Error handling

## Integration in edit_catalogue.dart

### Changes Made:

1. **Added Imports**
   ```dart
   import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_bloc.dart';
   import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_event.dart';
   import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_state.dart';
   ```

2. **Updated State Variables**
   - Added `imageIds` list to track image IDs alongside URLs
   - Added `primaryImageId` to track primary image ID

3. **Updated _populateFormWithData Method**
   - Extracts imageIds from URLs (last segment after `/`)
   - Maps primary image URL to its corresponding ID

4. **Updated _deleteImageAndRefresh Method**
   - Now dispatches `DeleteProductImage` event to BLoC
   - Finds imageId from the uploadedImageUrls list
   - Handles errors with proper user feedback

5. **Updated _setPrimaryImageAndRefresh Method**
   - Now dispatches `SetImagePrimary` event to BLoC
   - Finds imageId from the uploadedImageUrls list
   - Handles errors with proper user feedback

6. **Added BLocListener for PutCatalogueImageOperationsBloc**
   - Nested between `CatalogueImageEntryBloc` and `PutEditProductBloc` listeners
   - Handles loading state with operation-specific messages
   - Updates UI on success:
     - Removes deleted images from the list
     - Updates primary image status
     - Refreshes product details
   - Shows error messages to user

## How It Works

### Delete Image Flow:
1. User long-presses an image in the carousel
2. Clicks "Delete Image" from the context menu
3. Confirms deletion in the confirmation dialog
4. `_deleteImageAndRefresh` extracts the imageId
5. `DeleteProductImage` event is dispatched to BLoC
6. BLoC calls `ApiIntegration.deleteProductImage()`
7. On success:
   - Image is removed from `uploadedImageUrls`
   - ImageId is removed from `imageIds`
   - If primary image was deleted, `primaryImageUrl` is reset
   - User receives success notification
   - Product details are refreshed

### Set Primary Image Flow:
1. User long-presses an image in the carousel
2. Clicks "Set as Primary" from the context menu
3. Confirms action in the confirmation dialog
4. `_setPrimaryImageAndRefresh` extracts the imageId
5. `SetImagePrimary` event is dispatched to BLoC
6. BLoC calls `ApiIntegration.setImagePrimary()`
7. On success:
   - `primaryImageUrl` is updated
   - `primaryImageId` is updated
   - Image preview shows primary badge
   - User receives success notification
   - Product details are refreshed

## ImageId Extraction Strategy

The current implementation extracts imageId from the URL by taking the last segment:
```dart
final segments = url.split('/');
return segments.isNotEmpty ? segments.last : url;
```

**Note:** If the backend returns imageIds in a different format or requires additional processing, update the `_populateFormWithData` method accordingly.

## API Integration

The implementation uses existing API methods:
- `ApiIntegration.deleteProductImage(productId, imageId)` - DELETE request
- `ApiIntegration.setImagePrimary(productId, imageId)` - PUT request

Both methods return `ApiCommonResponseBody` with status and message.

## Testing Checklist

- [ ] Long press on an image shows the context menu
- [ ] Delete Image option removes image after confirmation
- [ ] Delete Image shows loading dialog during operation
- [ ] Success notification appears after deletion
- [ ] Set as Primary option updates the primary badge
- [ ] Set as Primary shows loading dialog during operation
- [ ] Success notification appears after setting primary
- [ ] Error notifications display for failed operations
- [ ] Product details refresh after successful operations
- [ ] UI updates immediately on success

## Future Enhancements

1. Optimize imageId extraction if backend provides ID metadata
2. Add retry logic for failed operations
3. Add optimistic UI updates (show changes immediately)
4. Add undo functionality for deleted images
5. Batch operations for multiple image management

