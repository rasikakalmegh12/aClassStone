# Edit Client BLoC - Quick Reference

## Files Modified/Created

| File | Action | Purpose |
|------|--------|---------|
| `lib/bloc/client/put_edit_client/put_edit_client_event.dart` | Created | Defines `FetchPutEditClient` event |
| `lib/bloc/client/put_edit_client/put_edit_client_state.dart` | Created | Defines 4 states (Initial, Loading, Success, Error) |
| `lib/bloc/client/put_edit_client/put_edit_client_bloc.dart` | Created | BLoC logic for handling PUT request |
| `lib/api/integration/api_integration.dart` | Modified | Added `putEditClient()` method |
| `lib/core/services/repository_provider.dart` | Modified | Added PutEditClientBloc initialization & disposal |
| `lib/core/navigation/app_router.dart` | Modified | Added PutEditClientBloc to route providers |
| `lib/presentation/screens/executive/clients/add_client_screen.dart` | Modified | Added BlocListener and updated `_saveClient()` |

## Quick Integration Steps (Already Completed)

### ✅ Step 1: Create BLoC Files
- Created Event class with `FetchPutEditClient(clientId, requestBody, showLoader)`
- Created State classes (Initial, Loading, Success, Error)
- Created BLoC class extending `Bloc<PutEditClientEvent, PutEditClientState>`

### ✅ Step 2: Add API Integration
```dart
static Future<PostClientAddResponseBody> putEditClient({
  required String clientId,
  required PostClientAddRequestBody requestBody,
}) async
```

### ✅ Step 3: Register in AppBlocProvider
- Added static variable: `static late PutEditClientBloc _putEditClientBloc;`
- Added initialization: `_putEditClientBloc=PutEditClientBloc();`
- Added getter: `static PutEditClientBloc get putEditClientBloc => _putEditClientBloc;`
- Added disposal: `_putEditClientBloc.close();`

### ✅ Step 4: Add to Routes
Added `BlocProvider<PutEditClientBloc>` to `addClientScreen` route

### ✅ Step 5: Implement in Screen
- Added imports
- Added `BlocListener<PutEditClientBloc>` for handling responses
- Updated `_saveClient()` to call correct BLoC based on mode

## Usage

### Edit Mode (Pass existing client)
```dart
// In clients_list_screen.dart
void _editClient(GetClientIdDetailsResponseBody.Data client) {
  context.pushNamed(
    'addClientScreen',
    extra: {'existingClient': client},
  );
}
```

### In add_client_screen.dart - _saveClient()
```dart
if (widget.existingClient != null) {
  // EDIT MODE - Call PutEditClientBloc
  context.read<PutEditClientBloc>().add(
    FetchPutEditClient(
      clientId: widget.existingClient!.id!,
      requestBody: requestBody,
      showLoader: true,
    ),
  );
} else {
  // CREATE MODE - Call PostClientAddBloc
  context.read<PostClientAddBloc>().add(
    FetchPostClientAdd(
      showLoader: true,
      requestBody: requestBody,
    ),
  );
}
```

### Response Handling
The `BlocListener<PutEditClientBloc>` handles:
- `PutEditClientLoading` → Show progress dialog
- `PutEditClientSuccess` → Show success message, pop with refresh
- `PutEditClientError` → Show error message

## API Details

**Endpoint:** `PATCH /marketing/clients/{clientId}`

**Request Body:** `PostClientAddRequestBody`
- clientTypeCode
- firmName
- gstn
- traderName
- facebookUrl
- instagramUrl
- twitterUrl
- initialLocation (optional for edit)
- ownerContact (optional for edit)

**Response:** `PostClientAddResponseBody`
- status
- message
- statusCode
- data (client info)

## Notes

- Both Create (POST) and Edit (PUT) use the same screen (`AddClientScreen`)
- Same `PostClientAddRequestBody` is used for both operations
- The choice between POST and PUT is determined by whether `widget.existingClient` is null
- Nested BLocListeners handle both operations seamlessly
- Returns `true` on success to trigger parent list refresh

