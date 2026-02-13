# 📱 Close MOM - Visual Guide & Architecture

## 🎨 UI Layout

### MOM Card (Before)
```
┌─────────────────────────────────────┐
│ ABC Corporation          [OPEN]     │
│ 14 Feb 2026 · Follow-up · John Doe │
└─────────────────────────────────────┘
```

### MOM Card (After - Admin/SuperAdmin)
```
┌─────────────────────────────────────┐
│ ABC Corporation          [OPEN]     │
│ 14 Feb 2026 · Follow-up · John Doe │
│                                     │
│             [Close MOM] ←─ Red btn  │
└─────────────────────────────────────┘
```

### MOM Card (After - Executive)
```
┌─────────────────────────────────────┐
│ ABC Corporation          [OPEN]     │
│ 14 Feb 2026 · Follow-up · John Doe │
│                                     │
│            (No button visible)      │
└─────────────────────────────────────┘
```

---

## 🔄 Architecture Diagram

```
                  meetings_list_screen.dart
                          ↓
              _buildMeetingCard(Items item)
                          ↓
        ┌─────────────────────────────────┐
        │ Role Check                      │
        │ admin/superadmin && !CLOSED?    │
        └──────────────┬──────────────────┘
                       ↓ Yes
              Show [Close MOM] button
                       ↓ Click
           _showCloseMomDialog(id, momNo)
                       ↓
              showDialog() called
                       ↓
        ┌──────────────────────────────┐
        │ BlocProvider<CloseMomBloc>  │
        ├──────────────────────────────┤
        │ BlocListener<CloseMomBloc>  │
        ├──────────────────────────────┤
        │ StatefulBuilder              │
        │ ├─ AlertDialog               │
        │ ├─ Confirmation message      │
        │ ├─ Remarks TextField         │
        │ └─ Cancel / Close MOM buttons│
        └──────────────┬───────────────┘
                       ↓ Click Close MOM
        context.read<CloseMomBloc>().add(
          FetchCloseMom(momId, remarks)
        )
                       ↓
        ┌──────────────────────────────┐
        │ CloseMomBloc                 │
        │ on<FetchCloseMom>            │
        └──────────────┬───────────────┘
                       ↓
        ┌──────────────────────────────┐
        │ emit(CloseMomLoading(...))   │
        └──────────────┬───────────────┘
                       ↓
        ┌──────────────────────────────┐
        │ ApiIntegration.closeMOM()    │
        │ POST /moms/{id}/close        │
        └──────────────┬───────────────┘
                       ↓
                  API Response
                   /          \
               Success      Error
                 ↓            ↓
        CloseMomSuccess   CloseMomError
           ↓                   ↓
        Emit state          Emit state
           ↓                   ↓
        BlocListener catches
           ↓
        Dialog closes
        Snackbar shows
        List refreshes
```

---

## 🔐 Role-Based Access Control

```
┌────────────────────────────────────────────┐
│           User Role Check                  │
├────────────────────────────────────────────┤
│                                            │
│  SessionManager.getUserRole()              │
│           ↓                                │
│  ┌────────┼────────┐                      │
│  ↓        ↓        ↓                      │
│ admin  superadmin executive               │
│  │        │        │                      │
│  ✅ Show ✅ Show   ❌ Hide                 │
│  button  button   button                  │
│                                            │
└────────────────────────────────────────────┘
```

---

## 📊 State Transitions

```
                    Initial
                       ↓
                    Initial
                       ↓ (Button click)
            _showCloseMomDialog()
                       ↓
            Dialog opens with BLoC
                       ↓
        User clicks [Close MOM] button
                       ↓
            FetchCloseMom event added
                       ↓
                  CloseMomLoading
                    (showLoader=true)
                       ↓
            ApiIntegration.closeMOM()
                       ↓
                   API Response
                   /          \
                  /            \
            success          error
              ↓               ↓
        CloseMomSuccess  CloseMomError
              ↓               ↓
        Dialog closes    Dialog closes
        Snackbar (✅)    Snackbar (❌)
        List refreshes  List stays same
```

---

## 📋 Class Hierarchy

```
CloseMomEvent
├─ FetchCloseMom
│  ├─ momId: String
│  ├─ remarks: String?
│  └─ showLoader: bool

CloseMomState
├─ CloseMomInitial
├─ CloseMomLoading
│  └─ showLoader: bool
├─ CloseMomSuccess
│  └─ message: String
└─ CloseMomError
   └─ message: String

CloseMomBloc extends Bloc<CloseMomEvent, CloseMomState>
├─ Initial state: CloseMomInitial
└─ on<FetchCloseMom>(handler)
```

---

## 🔌 API Integration

### Endpoint
```
POST /api/v1/marketing/moms/{id}/close
```

### Request
```json
{
  "message": "Optional remarks text"
}
```

### Success Response (200)
```json
{
  "status": true,
  "message": "MOM closed successfully",
  "statusCode": 200
}
```

### Error Response (400/500)
```json
{
  "status": false,
  "message": "Failed to close MOM",
  "statusCode": 400
}
```

---

## 🧬 Component Tree

```
_MeetingsListScreenState
├─ Scaffold
│  ├─ AppBar
│  ├─ Body (Column)
│  │  ├─ _buildSearchAndFilters()
│  │  └─ BlocBuilder<GetMomListBloc>
│  │     └─ ListView.builder
│  │        └─ _buildMeetingCard(Items, int)
│  │           ├─ InkWell (onTap: _openMomDetailsBottomSheet)
│  │           └─ Container
│  │              └─ Column
│  │                 ├─ Row (ClientName + StatusBadge)
│  │                 ├─ Row (Details)
│  │                 └─ [Conditional] Row
│  │                    └─ ElevatedButton [Close MOM]
│  │                       └─ onPressed: _showCloseMomDialog
│  │
│  └─ FloatingActionButton (Add MOM)
│
└─ showDialog() [Not in tree, created dynamically]
   └─ BlocProvider<CloseMomBloc>
      └─ BlocListener<CloseMomBloc>
         └─ StatefulBuilder
            └─ AlertDialog
               ├─ Title: Close MOM
               ├─ Content: Column
               │  ├─ Confirmation text
               │  └─ TextField (remarks)
               └─ Actions: [Cancel] [Close MOM]
```

---

## ✨ Key Design Decisions

### 1. **Conditional Rendering**
```dart
if ((SessionManager.getUserRole() == "admin" || 
     SessionManager.getUserRole() == "superadmin") && 
    meeting.status != "CLOSED") ...[
  // Show Close MOM button
]
```

### 2. **StatefulBuilder for Dialog**
- Allows dialog to rebuild independently
- Can update UI on text changes
- Separate from page state

### 3. **BLoC Pattern**
- Proper separation of concerns
- Testable business logic
- Reusable state management

### 4. **Error Handling**
- Try-catch in BLoC
- Clear error messages
- User-friendly feedback

---

## 🎯 Benefits

✅ **Security** - Only authorized roles can close MOMs  
✅ **Usability** - Simple, intuitive dialog  
✅ **Maintainability** - Proper BLoC pattern  
✅ **Testability** - Clean state management  
✅ **Scalability** - Easy to extend features  
✅ **Reliability** - Proper error handling  

---

**Date:** February 14, 2026  
**Version:** 1.0  
**Status:** Production Ready

