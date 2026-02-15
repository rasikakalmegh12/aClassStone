# Quick Reference: Delete Image & Set Primary BLoC

## File Structure
```
lib/bloc/catalogue/put_catalogues_methods/
├── put_catalogue_image_operations_bloc.dart      (Main BLoC logic)
├── put_catalogue_image_operations_event.dart     (Event definitions)
└── put_catalogue_image_operations_state.dart     (State definitions)
```

## Usage in edit_catalogue.dart

### Triggering Delete Image
```dart
context.read<PutCatalogueImageOperationsBloc>().add(
  DeleteProductImage(
    productId: widget.productId!,
    imageId: imageId,  // extracted from URL
    showLoader: true,
  ),
);
```

### Triggering Set Primary
```dart
context.read<PutCatalogueImageOperationsBloc>().add(
  SetImagePrimary(
    productId: widget.productId!,
    imageId: imageId,  // extracted from URL
    showLoader: true,
  ),
);
```

## State Handling
```dart
BlocListener<PutCatalogueImageOperationsBloc, PutCatalogueImageOperationsState>(
  listener: (context, state) {
    if (state is PutCatalogueImageOperationsLoading) {
      // Show loading dialog
    } else if (state is DeleteImageSuccess) {
      // Remove image from UI
      // Update imageIds list
    } else if (state is SetImagePrimarySuccess) {
      // Update primary image marker
    } else if (state is PutCatalogueImageOperationsError) {
      // Show error message
    }
  },
  child: // ... rest of widget tree
)
```

## Key Implementation Points

1. **ImageId Mapping**: The code extracts imageId from image URL using the last segment
   ```dart
   final segments = url.split('/');
   return segments.isNotEmpty ? segments.last : url;
   ```

2. **Parallel Lists**: `uploadedImageUrls` and `imageIds` are kept in sync
   ```dart
   uploadedImageUrls = [url1, url2, url3]
   imageIds = [id1, id2, id3]
   // Same index = matching pairs
   ```

3. **Primary Image Tracking**: Both URL and ID are tracked
   ```dart
   primaryImageUrl: "https://..."
   primaryImageId: "image-id"
   ```

4. **UI Updates**: LocalUI is updated after successful API call
   - Images are removed from the list
   - Primary status is updated
   - Product details are refreshed from API

## API Endpoints Used
- `DELETE /api/v1/marketing/admin/catalogue/products/{productId}/images/{imageId}`
- `PUT /api/v1/marketing/admin/catalogue/products/{productId}/images/{imageId}:set-primary`

## Loading States
- `operationType: 'delete'` - Shows "Deleting image..." dialog
- `operationType: 'setPrimary'` - Shows "Setting as primary..." dialog

## Error Handling
- Network errors are caught and displayed to user
- API errors return message from server
- All errors dismiss the loading dialog before showing error message

## StateManagement Flow
```
User Action
    ↓
Event Dispatch (DeleteProductImage / SetImagePrimary)
    ↓
BLoC Listener emits Loading state
    ↓
Loading Dialog shown
    ↓
API Call in BLoC
    ↓
Success/Error State emitted
    ↓
Loading Dialog dismissed
    ↓
UI Updated (success) / Error shown (failure)
    ↓
Product Details refreshed
```

## Testing Notes
- Ensure imageId extraction works with your URL format
- Test both success and failure scenarios
- Verify loading dialogs appear and dismiss properly
- Check that UI updates match API responses
- Confirm product details refresh after operations

