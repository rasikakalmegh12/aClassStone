# Catalogue API Flow - Quick Test Guide

## Test the Implementation

### Test 1: Default Page Load
**Steps:**
1. Open the catalogue page
2. Observe the products displayed

**Expected:**
- ✅ GetCatalogueProductListBloc is called
- ✅ All products are displayed
- ✅ `_usePostSearchApi = false`
- ✅ `_hasFiltersApplied = false`

---

### Test 2: Search Without Filters
**Steps:**
1. Type "granite" in the search bar
2. Wait 500ms for debounce

**Expected:**
- ✅ GetCatalogueProductListBloc is called with search="granite"
- ✅ Filtered products displayed
- ✅ `_usePostSearchApi = false`
- ✅ `_hasFiltersApplied = false`

---

### Test 3: Apply Filters (No Search)
**Steps:**
1. Click filter icon (tune icon)
2. Select "Product Type" → "Granite"
3. Click "Apply Filters"

**Expected:**
- ✅ PostSearchBloc is called with productTypeIds=["granite-id"]
- ✅ Filtered products displayed
- ✅ `_usePostSearchApi = true`
- ✅ `_hasFiltersApplied = true`

---

### Test 4: Search With Filters Applied
**Steps:**
1. (Assuming filters are already applied from Test 3)
2. Type "marble" in the search bar
3. Wait 500ms

**Expected:**
- ✅ PostSearchBloc is called with filters + search="marble"
- ✅ Products matching both filters and search displayed
- ✅ `_usePostSearchApi = true`
- ✅ `_hasFiltersApplied = true`

---

### Test 5: Clear Search (Filters Still Active)
**Steps:**
1. (Filters still applied)
2. Click the X button in search bar

**Expected:**
- ✅ PostSearchBloc is called with filters + search=""
- ✅ Products matching filters displayed (no search)
- ✅ `_usePostSearchApi = true`
- ✅ `_hasFiltersApplied = true`

---

### Test 6: Clear All Filters
**Steps:**
1. Click filter icon
2. Click "Clear All" button

**Expected:**
- ✅ GetCatalogueProductListBloc is called
- ✅ All products displayed
- ✅ Filters cleared
- ✅ `_usePostSearchApi = false`
- ✅ `_hasFiltersApplied = false`

---

### Test 7: Pull to Refresh
**Steps:**
1. Apply some filters
2. Search for something
3. Pull down to refresh

**Expected:**
- ✅ All filters cleared
- ✅ Search cleared
- ✅ GetCatalogueProductListBloc is called
- ✅ Fresh product list displayed
- ✅ `_usePostSearchApi = false`
- ✅ `_hasFiltersApplied = false`

---

### Test 8: Multiple Filters
**Steps:**
1. Open filters
2. Select "Product Type" → "Granite"
3. Select "Colour" → "Black"
4. Select "Price Range" → "100-200"
5. Click "Apply Filters"

**Expected:**
- ✅ PostSearchBloc called with all filter IDs
- ✅ Products matching all criteria displayed
- ✅ `_usePostSearchApi = true`
- ✅ `_hasFiltersApplied = true`

---

## Debug Console Checks

When testing, check the console for these logs:

### GetCatalogueProductListBloc
```
📥 getCatalogueProductList body: {...}
```

### PostSearchBloc
```
📥 postSearch request: {...}
📥 postSearch body: {...}
```

---

## Common Issues & Solutions

### Issue 1: Products don't update after filter
**Solution:** Check that `_usePostSearchApi` flag is set to `true`

### Issue 2: Search shows old results
**Solution:** Verify debounce timer is working (500ms delay)

### Issue 3: Refresh doesn't clear filters
**Solution:** Check `_handleRefresh()` resets all flags and clears filters

### Issue 4: Blank screen after applying filters
**Solution:** 
- Verify PostSearchBloc is returning data
- Check filter ID mappings are populated correctly
- Ensure API request body has correct structure

---

## API Request Body Examples

### GetCatalogueProductList (No Filters)
```json
{
  "page": 1,
  "pageSize": 20,
  "search": "marble"  // or null
}
```

### PostSearch (With Filters)
```json
{
  "page": 1,
  "pageSize": 20,
  "search": "marble",
  "sort": 0,
  "productTypeIds": ["22222222-2222-2222-2222-222222222222"],
  "colourOptionIds": [],
  "finishOptionIds": [],
  "textureOptionIds": [],
  "naturalColourOptionIds": [],
  "utilityIds": [],
  "originOptionIds": [],
  "stateCountryOptionIds": [],
  "processingNatureOptionIds": [],
  "materialNaturalityOptionIds": [],
  "handicraftTypeOptionIds": [],
  "priceRangeIds": []
}
```

Note: Empty arrays (`[]`) are used instead of `null` to avoid backend errors.

