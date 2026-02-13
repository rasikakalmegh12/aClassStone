# Quick Reference - EditCatalogue Page

## 🚀 Quick Start

### 1. Navigate to Edit Product
```dart
// From catalog_main.dart - Long press on product (SuperAdmin only)
onLongPress: () {
  if (SessionManager.getUserRole().toString().toLowerCase() == "superadmin") {
    context.pushNamed('editProduct', pathParameters: {
      'productId': product.id!
    });
  }
}
```

### 2. What Happens Automatically
✅ Product details loaded via API
✅ Form fields populated with current data
✅ Images displayed with edit options

## 📸 Image Management

### Add Image
- Click "+ Add Image" button
- Select from gallery
- New image appears with "New" badge

### Delete Image
- Click red X button on image
- Immediately removed from list

### Set as Primary
- Click green checkmark on uploaded image
- Image gets "Primary" badge
- Green border indicates primary status

## 📝 Editing Fields

### Text Fields (Single Line)
- Product Name (required)
- Marketing One Liner

### Text Areas (Multiple Lines)
- Description

### Number Fields
- All price fields (Architect & Trader Grades)
- Sort Order

### Toggle Switch
- Active (On/Off)

## ✅ Form Validation

```
Product Name     → Required (error if empty)
Price Fields     → Optional (numeric only)
Other Fields     → Optional (free text)
```

## 🔄 Submission Flow

1. **Fill Form**
   - Edit any fields
   - Add/remove images
   - Set primary image

2. **Click "Update Product"**
   - Validates form
   - Shows loading indicator
   - Sends request to server

3. **Result**
   - ✅ Success: Shows message, goes back
   - ❌ Error: Shows error message, stays on form

## 💾 Data Saved

### Request Body Includes
```json
{
  "name": "Edited Name",
  "description": "Edited Description",
  "productTypeId": "...",
  "priceRangeId": "...",
  "mineId": "...",
  "isActive": true,
  "sortOrder": 0,
  "priceSqftArchitectGradeA": 50,
  "priceSqftArchitectGradeB": 45,
  "priceSqftArchitectGradeC": 40,
  "priceSqftTraderGradeA": 30,
  "priceSqftTraderGradeB": 28,
  "priceSqftTraderGradeC": 25,
  "marketingOneLiner": "..."
}
```

## ⚙️ Configuration

### Price Sections
- **Architect Grade**: Prices for A, B, C grades
- **Trader Grade**: Prices for A, B, C grades

### Status
- **Active Toggle**: Enable/disable product

## 🎯 Common Tasks

### Change Product Name
1. Edit "Product Name" field
2. Click Update

### Update Pricing
1. Edit any price field
2. Numbers only (no special characters)
3. Click Update

### Change Primary Image
1. Click checkmark on desired image
2. Gets "Primary" badge
3. Click Update

### Remove Image
1. Click red X button
2. Image removed immediately
3. Click Update to save

### Deactivate Product
1. Toggle "Active" to OFF
2. Click Update

## 🔍 Form Sections

### Basic Information
- Product Name
- Description
- Marketing One Liner

### Pricing - Architect Grade
- Grade A
- Grade B
- Grade C

### Pricing - Trader Grade
- Grade A
- Grade B
- Grade C

### Additional Settings
- Sort Order
- Active Status

## ⏱️ Loading States

### Initial Load (Product Details)
- Shows: Circular loading indicator
- Until: API returns product data

### During Submit
- Shows: Progress dialog with animation
- Until: Server responds with success/error

## 📱 Navigation

### Entry Point
- Long press on product card (SuperAdmin)

### Exit Point
- Auto-navigate back on success
- Manual back button if error

## 🔐 Permissions

### Who Can Edit
- Super Admin only

### What They Can Edit
- All product details
- All pricing information
- Product images
- Status and sort order

## 💡 Tips

1. **Images**
   - You can add multiple images
   - Always mark one as "Primary"
   - New images need future upload functionality

2. **Pricing**
   - Keep prices consistent between grades (A > B > C)
   - Both Architect and Trader pricing supported

3. **Naming**
   - Clear product names help with identification
   - Marketing one-liner used in listings

4. **Status**
   - Turn off "Active" to hide product
   - No need to delete products

## ❌ Common Issues

### Issue: Cannot edit certain fields
**Solution**: Check user role (SuperAdmin required)

### Issue: Image doesn't show as primary
**Solution**: Click checkmark again, ensure image is loaded

### Issue: Form won't submit
**Solution**: Check if required fields (Product Name) are filled

### Issue: Changes don't save
**Solution**: Wait for success message before going back

## 📋 Checklist Before Submit

- [ ] Product name filled in
- [ ] Prices are numeric
- [ ] Primary image selected (if needed)
- [ ] No validation errors shown
- [ ] All required information complete

## 🆘 Need Help?

1. Check error message displayed
2. Verify all required fields filled
3. Ensure network connection
4. Try refreshing and editing again
5. Check user permissions (SuperAdmin role)

