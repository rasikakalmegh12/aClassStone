# Catalogue API Management Guide

## Overview
The catalogue page (`catalog_main.dart`) uses two different APIs to fetch products:
1. **GetCatalogueProductListBloc** - Simple product list without filters
2. **PostSearchBloc** - Advanced search with filters

## Flags Used

### 1. `_hasFiltersApplied` (bool)
- **Purpose**: Tracks whether any filters are currently applied by the user
- **Set to `true`**: When user applies filters in the filter bottom sheet
- **Set to `false`**: When user clears all filters or refreshes the page

### 2. `_usePostSearchApi` (bool)
- **Purpose**: Determines which API response to use for displaying products
- **Set to `true`**: When PostSearchBloc returns successful results
- **Set to `false`**: When using GetCatalogueProductList or when filters are cleared

## Flow Scenarios

### Scenario 1: Page Load (Default)
```
1. Page opens
2. GetCatalogueProductListBloc is called with showLoader: true
3. _hasFiltersApplied = false
4. _usePostSearchApi = false
5. Products displayed from GetCatalogueProductList response
```

### Scenario 2: Search (No Filters Applied)
```
1. User types in search bar
2. Check _hasFiltersApplied -> false
3. Call GetCatalogueProductListBloc with search parameter
4. _usePostSearchApi = false
5. Products displayed from GetCatalogueProductList response
```

### Scenario 3: Apply Filters (No Search)
```
1. User opens filter sheet and selects filters
2. User clicks "Apply Filters"
3. _hasFiltersApplied = true
4. _usePostSearchApi = true
5. Call PostSearchBloc with filter IDs and empty search
6. Products displayed from PostSearch response
```

### Scenario 4: Search + Filters Applied
```
1. Filters are already applied (_hasFiltersApplied = true)
2. User types in search bar
3. Check _hasFiltersApplied -> true
4. Call PostSearchBloc with filter IDs + search query
5. _usePostSearchApi = true
6. Products displayed from PostSearch response
```

### Scenario 5: Clear Search (Filters Still Applied)
```
1. User clicks clear (X) button in search bar
2. Check _hasFiltersApplied -> true
3. Call PostSearchBloc with filter IDs + empty search
4. _usePostSearchApi remains true
5. Products displayed from PostSearch response
```

### Scenario 6: Clear All Filters
```
1. User clicks "Clear All" in filter sheet
2. _filters.clear()
3. _hasFiltersApplied = false
4. _usePostSearchApi = false
5. Call GetCatalogueProductListBloc with current search (if any)
6. Products displayed from GetCatalogueProductList response
```

### Scenario 7: Pull to Refresh
```
1. User pulls down to refresh
2. _filters.clear()
3. _search = ''
4. _hasFiltersApplied = false
5. _usePostSearchApi = false
6. Call GetCatalogueProductListBloc
7. Products displayed from fresh GetCatalogueProductList response
```

## API Response Handling

### GetCatalogueProductListBloc (BlocBuilder)
```dart
if (state is GetCatalogueProductListLoaded) {
  // Only update products if NOT using PostSearch API
  if (!_usePostSearchApi) {
    _products = apiProducts.map(...).toList();
  }
}
```

### PostSearchBloc (BlocListener)
```dart
if (searchState is PostSearchSuccess) {
  // Set flag to use PostSearch results
  _usePostSearchApi = true;
  _products = apiProducts.map(...).toList();
}
```

## Key Implementation Details

### Search Bar Logic
- **Debounce**: 500ms delay before calling API
- **Decision**: 
  - If `_hasFiltersApplied == true` → Call PostSearchBloc
  - If `_hasFiltersApplied == false` → Call GetCatalogueProductListBloc

### Filter Application Logic
- Collect all selected filter names
- Convert filter names to IDs using mapping dictionaries
- Build PostSearchRequestBody with filter IDs
- Call PostSearchBloc

### State Management
- Both BLoCs are available in the widget tree via MultiBlocProvider
- GetCatalogueProductListBloc uses BlocBuilder (rebuilds UI)
- PostSearchBloc uses BlocListener (updates state without rebuild)

## Benefits of This Approach

1. **Clear Separation**: Easy to understand which API is being used
2. **Smooth Transitions**: No flickering when switching between APIs
3. **Proper State**: Maintains correct product list based on user actions
4. **Refresh Works**: Always resets to default GetCatalogueProductList
5. **Search Intelligence**: Automatically uses correct API based on filter state

## Testing Checklist

- [ ] Open page → Shows all products (GetCatalogueProductList)
- [ ] Search without filters → Uses GetCatalogueProductList
- [ ] Apply filters → Uses PostSearch
- [ ] Search with filters → Uses PostSearch
- [ ] Clear search (filters active) → Uses PostSearch
- [ ] Clear all filters → Uses GetCatalogueProductList
- [ ] Pull to refresh → Resets to GetCatalogueProductList
- [ ] Apply filters + refresh → Clears filters, uses GetCatalogueProductList

