# NERAM POS — Comprehensive App API Inventory & Specifications

> **Document Version:** 1.0.0  
> **Environment Base URL:** `https://api.nerampos.com/v1` (Production) / `https://dev-api.nerampos.com/v1` (Development)  
> **Protocol:** HTTPS / JSON REST  
> **Date Format:** ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ssZ`)  
> **Currency / Money Format:** Decimal floating point / formatted string (e.g., `48.50` representing ₹48.50)  

---

## Global Standards & Envelopes

### 1. Success Response Envelope
All successful HTTP 200/201 responses return the standard envelope:
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "timestamp": "2026-10-27T14:15:30Z"
}
```

### 2. Error Response Envelope
All HTTP 4xx/5xx responses return the standard error envelope:
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid username or password.",
    "fields": {
      "password": "Password must be at least 6 characters"
    }
  },
  "timestamp": "2026-10-27T14:15:30Z"
}
```

### 3. Common Headers
- `Authorization`: `Bearer <jwt_access_token>` (Required for all protected endpoints)
- `Content-Type`: `application/json`
- `Accept`: `application/json`
- `X-Outlet-Id`: `<outlet_id>` (Required for multi-tenant store scoping, e.g. `outlet_001`)
- `Idempotency-Key`: `<client_uuid_v4>` (Required on transactional write endpoints, e.g. `POST /orders/sync`)

---

## Endpoint Index Table

| # | Endpoint | Method | Screen / Source in App | Roles Allowed | Description |
|---|----------|--------|------------------------|---------------|-------------|
| 1 | `/auth/login` | `POST` | `LoginView` | Public | Staff PIN / username authentication |
| 2 | `/auth/profile` | `GET` | `SplashScreen` / Startup | All Staff | Verify token & fetch current user profile |
| 3 | `/auth/refresh` | `POST` | `AuthInterceptor` | All Staff | Refresh expired access token |
| 4 | `/auth/logout` | `POST` | `NeramDrawer` / `ProfileView` | All Staff | Invalidate active server session |
| 5 | `/auth/change-password` | `POST` | `ChangePasswordDialog` | All Staff | Change staff terminal password |
| 6 | `/dashboard/quick-stats` | `GET` | `NeramDrawer` | Cashier, Manager | Today's orders count and terminal cash |
| 7 | `/tables` | `GET` | `TableTabView` | Waiter, Cashier, Manager | List dining tables and their real-time status |
| 8 | `/menu/categories` | `GET` | `TableTabView` | Waiter, Cashier, Manager | List menu dish categories with counts |
| 9 | `/menu/items` | `GET` | `TableTabView` | Waiter, Cashier, Manager | List catalog dishes with filters and search |
| 10 | `/orders/active` | `GET` | `ActiveOrdersDialog` | Waiter, Cashier, Kitchen, Manager | Real-time live kitchen & dining orders |
| 11 | `/tables/transfer` | `POST` | `TableTransferDialog` | Waiter, Cashier, Manager | Transfer table order to a different table |
| 12 | `/orders/sync` | `POST` | `CartDetailsModal` | Waiter, Cashier, Manager | Hybrid KOT order sync with direct print fallback |
| 13 | `/printers` | `GET` | App Startup / Station Settings | Cashier, Manager, Admin | LAN thermal printers & category routing |
| 14 | `/printers/reprint-log` | `POST` | `PrintStatusModal` | Waiter, Cashier, Manager | Log manual reprint of kitchen order ticket |
| 15 | `/inventory/items` | `GET` | `StockTabView` | Kitchen, Manager, Admin | Stock catalog listing with filter, search & sort |
| 16 | `/inventory/summary` | `GET` | `StockTabView` | Kitchen, Manager, Admin | Stock dashboard metrics and aggregate valuation |
| 17 | `/inventory/items/{id}/restock` | `POST` | `RestockModal` | Kitchen, Manager | Inward batch restock for existing item |
| 18 | `/inventory/items/{id}/issue` | `POST` | `IssueStockModal` / `UsageModal` | Kitchen, Manager | Deduct consumed or spoiled inventory stock |
| 19 | `/inventory/items` | `POST` | `NewStockItemModal` | Manager, Admin | Register brand new item in inventory |
| 20 | `/inventory/audit` | `POST` | `StockAuditModal` | Manager, Chef | Complete physical weekly kitchen stocktake |
| 21 | `/inventory/items/{id}/alert-manager` | `POST` | `AlertManagerModal` | Kitchen, Waiter | Notify manager about stock issues |
| 22 | `/inventory/items/{id}/history` | `GET` | `StockHistoryDialog` | Manager, Admin | Audit log history of inventory adjustments |
| 23 | `/attendance/monthly-summary` | `GET` | `LeavesTabView` | All Staff | Monthly working days, attendance rate & leaves |
| 24 | `/attendance/check-in` | `POST` | `LeavesTabView` | All Staff | Shift check-in punch station |
| 25 | `/attendance/check-out` | `POST` | `LeavesTabView` | All Staff | Shift check-out punch station |
| 26 | `/leaves` | `GET` | `LeavesTabView` | All Staff | Staff leave applications and audit records |
| 27 | `/leaves` | `POST` | `ApplyLeaveModal` | All Staff | Submit new leave application request |
| 28 | `/leaves/{id}` | `DELETE` | `LeavesTabView` | Applicant, Manager | Recall/cancel pending leave application |
| 29 | `/staff/profile` | `GET` | `ProfileView` | All Staff | Detailed employee profile (Account, Job, Bank) |
| 30 | `/staff/profile/status` | `PATCH` | `ProfileView` | Staff, Manager | Toggle staff active / inactive duty badge |

---

## Detailed Specifications by Module

### 1. Authentication & Session Module

#### 1.1 Staff Login
- **Endpoint:** `POST /auth/login`
- **Screen:** `LoginView` (`lib/views/auth/login_view.dart`)
- **Roles:** Public / All Staff
- **Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "username": "abhishek",
    "password": "sample_password"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "usr_001",
        "name": "Abhishek",
        "email": "abhishek@nerampos.com",
        "phone": "+91 9876543210",
        "role": "manager",
        "outletId": "outlet_001",
        "avatarUrl": null
      },
      "token": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "tokenType": "Bearer",
        "expiresIn": 28800
      }
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```
- **Error Responses:**
  - `401 Unauthorized` (`INVALID_CREDENTIALS`): "Invalid username or password."
  - `403 Forbidden` (`ACCOUNT_SUSPENDED`): "Staff terminal access is deactivated."

---

#### 1.2 Get Current Profile
- **Endpoint:** `GET /auth/profile`
- **Screen:** `SplashScreen` (`lib/views/splash/splash_screen.dart`)
- **Roles:** Authenticated Staff
- **Headers:** `Authorization: Bearer <token>`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "id": "usr_001",
      "name": "Abhishek",
      "email": "abhishek@nerampos.com",
      "phone": "+91 9876543210",
      "role": "manager",
      "outletId": "outlet_001"
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```
- **Error Responses:**
  - `401 Unauthorized` (`TOKEN_EXPIRED` / `UNAUTHORIZED`): "Session expired. Please log in again."

---

#### 1.3 Refresh Access Token
- **Endpoint:** `POST /auth/refresh`
- **Screen:** `AuthInterceptor` (`lib/core/network/auth_interceptor.dart`)
- **Roles:** Authenticated Staff
- **Request Body:**
  ```json
  {
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 28800
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 1.4 Logout
- **Endpoint:** `POST /auth/logout`
- **Screen:** `NeramDrawer` / `ProfileView`
- **Roles:** Authenticated Staff
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:** Empty `{}`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "message": "Successfully logged out from terminal session."
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 1.5 Change Terminal Password
- **Endpoint:** `POST /auth/change-password`
- **Screen:** `ChangePasswordDialog` (`lib/views/auth/widgets/change_password_dialog.dart`)
- **Roles:** Authenticated Staff
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "currentPassword": "old_password_123",
    "newPassword": "NewSecret@2026"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "message": "Password updated successfully."
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```
- **Error Responses:**
  - `400 Bad Request` (`INCORRECT_CURRENT_PASSWORD`): "Current password does not match."
  - `422 Unprocessable Entity` (`PASSWORD_POLICY_VIOLATION`): "New password does not meet security checklist rules."

---

### 2. Dashboard & Outlet Operations Module

#### 2.1 Terminal Quick Stats
- **Endpoint:** `GET /dashboard/quick-stats`
- **Screen:** `NeramDrawer` (`lib/views/home/widgets/neram_drawer.dart`)
- **Roles:** Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "todayOrdersCount": 48,
      "terminalCash": 14820.00,
      "currency": "INR",
      "shiftStatus": "active",
      "shiftStartedAt": "2026-10-27T06:00:00Z"
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

### 3. Dining Tables & Menu Catalog Module

#### 3.1 List Tables
- **Endpoint:** `GET /tables`
- **Screen:** `TableTabView` (`lib/views/table/table_tab_view.dart`)
- **Roles:** Waiter, Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Query Parameters:**
  - `zone` (Optional, string): `indoor`, `outdoor`, `takeaway`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "tables": [
        {
          "id": "T-01",
          "name": "Table T-01",
          "zone": "indoor",
          "seats": 4,
          "status": "preparing",
          "total": 48.50,
          "customerName": null,
          "timeElapsed": "12m ago",
          "itemCount": 4
        },
        {
          "id": "T-02",
          "name": "Table T-02",
          "zone": "indoor",
          "seats": 2,
          "status": "occupied",
          "total": 26.00,
          "customerName": "Elena R.",
          "timeElapsed": "24m ago",
          "itemCount": 2
        },
        {
          "id": "T-03",
          "name": "Table T-03",
          "zone": "indoor",
          "seats": 6,
          "status": "vacant",
          "total": 0.00,
          "customerName": null,
          "timeElapsed": "Ready",
          "itemCount": 0
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 3.2 List Menu Categories
- **Endpoint:** `GET /menu/categories`
- **Screen:** `TableTabView`
- **Roles:** Waiter, Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "categories": [
        { "id": "cat_all", "name": "All (48)", "count": 48 },
        { "id": "cat_starters", "name": "Starters", "count": 8 },
        { "id": "cat_egg", "name": "Egg Preparations", "count": 4 },
        { "id": "cat_soups", "name": "Soups", "count": 6 },
        { "id": "cat_main", "name": "Main Course", "count": 14 },
        { "id": "cat_breads", "name": "Breads & Rice", "count": 7 },
        { "id": "cat_beverages", "name": "Beverages", "count": 5 },
        { "id": "cat_desserts", "name": "Desserts", "count": 4 }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 3.3 List Menu Items / Dishes
- **Endpoint:** `GET /menu/items`
- **Screen:** `TableTabView`
- **Roles:** Waiter, Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Query Parameters:**
  - `category` (Optional, string): Filter by category name (e.g., `Starters`)
  - `search` (Optional, string): Search query for name or subtitle
  - `food_type` (Optional, string): `veg`, `egg`, `nonVeg`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "items": [
        {
          "id": "dish_1",
          "name": "Crispy Corn Pepper Fry",
          "category": "Starters",
          "subtitle": "Starters • Chef Special",
          "price": 8.50,
          "foodType": "veg",
          "isAvailable": true
        },
        {
          "id": "dish_4",
          "name": "Butter Chicken Handi",
          "category": "Main Course",
          "subtitle": "Main Course • Rich Makhani Gravy",
          "price": 14.50,
          "foodType": "nonVeg",
          "isAvailable": true
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 3.4 List Active Live Orders
- **Endpoint:** `GET /orders/active`
- **Screen:** `ActiveOrdersDialog` (`lib/views/table/widgets/active_orders_dialog.dart`)
- **Roles:** Waiter, Cashier, Kitchen, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Query Parameters:**
  - `zone` (Optional, string): `indoor`, `outdoor`, `takeaway`, or `all`
  - `search` (Optional, string): Query order ID, table name, or customer name
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "orders": [
        {
          "id": "#ORD-2849",
          "tableId": "T-01",
          "tableName": "Table T-01",
          "customerName": "Dine-In",
          "items": [
            "2x Crispy Corn Pepper Fry",
            "1x Butter Chicken Handi",
            "2x Garlic Butter Naan"
          ],
          "total": 48.50,
          "status": "preparing",
          "timeElapsed": "12m ago",
          "zone": "indoor"
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 3.5 Transfer Table
- **Endpoint:** `POST /tables/transfer`
- **Screen:** `TableTransferDialog` (`lib/views/table/widgets/table_transfer_dialog.dart`)
- **Roles:** Waiter, Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "fromTableId": "T-01",
    "toTableId": "T-03",
    "reason": "Window seat request",
    "orderId": "#ORD-2849"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "message": "Orders transferred successfully from Table T-01 to Table T-03",
      "fromTable": { "id": "T-01", "status": "vacant", "total": 0.00 },
      "toTable": { "id": "T-03", "status": "preparing", "total": 48.50 }
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```
- **Error Responses:**
  - `400 Bad Request` (`TARGET_TABLE_OCCUPIED`): "Destination table is not vacant."
  - `404 Not Found` (`TABLE_NOT_FOUND`): "Source or target table ID was not found."

---

### 4. Hybrid Kitchen Printing & Order Sync Module

#### 4.1 Order Sync & Fallback Enqueue
- **Endpoint:** `POST /orders/sync`
- **Screen:** `CartDetailsModal` (`lib/views/table/widgets/cart_details_modal.dart`)
- **Roles:** Waiter, Cashier, Manager
- **Headers:** 
  - `Authorization: Bearer <token>`
  - `X-Outlet-Id: outlet_001`
  - `Idempotency-Key: <orderId>` *(Client-generated RFC 4122 v4 UUID)*
- **Request Body:**
  ```json
  {
    "orderId": "550e8400-e29b-41d4-a716-446655440000",
    "localNo": "#ORD-1042",
    "tableId": "T-01",
    "tableName": "Table T-01",
    "diningMode": "dineIn",
    "customerName": "Elena R.",
    "orderNote": "Less spicy please",
    "items": [
      {
        "dishId": "dish_1",
        "name": "Crispy Corn Pepper Fry",
        "quantity": 2,
        "price": 8.50,
        "itemNote": "Extra crispy",
        "category": "Starters"
      },
      {
        "dishId": "dish_4",
        "name": "Butter Chicken Handi",
        "quantity": 1,
        "price": 14.50,
        "itemNote": "",
        "category": "Main Course"
      }
    ],
    "subtotal": 31.50,
    "tax": 1.58,
    "total": 33.08,
    "createdAt": "2026-10-27T14:15:30Z",
    "rev": 1,
    "jobs": [
      {
        "jobId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
        "printerId": "prn_kitchen_01",
        "type": "kitchen_kot",
        "status": "printed",
        "attempts": 1,
        "lastError": null
      },
      {
        "jobId": "2c6f1f45-0d4e-4f11-9a77-4b13a7bb1102",
        "printerId": "prn_bar_01",
        "type": "bar_kot",
        "status": "fallbackRequested",
        "attempts": 3,
        "lastError": "Connection timeout to 192.168.1.101:9100"
      }
    ]
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "serverOrderId": "srv_ord_998124",
      "finalOrderNo": "#ORD-1042",
      "rev": 1,
      "syncedAt": "2026-10-27T14:15:31Z",
      "jobs": [
        {
          "jobId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
          "status": "printed"
        },
        {
          "jobId": "2c6f1f45-0d4e-4f11-9a77-4b13a7bb1102",
          "status": "serverPrinted"
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:31Z"
  }
  ```
- **Business Rules & State Guarantees:**
  - **Idempotent Upsert:** Server matches existing record by `orderId`. Repeated sync requests return the existing record without creating duplicate orders.
  - **Status Immutability:** `printed` and `serverPrinted` are final states. The backend must never overwrite them with `pending` or `failed`.
  - **Fallback Queueing:** Any job that arrives with `fallbackRequested` that is not already `printed` or `serverPrinted` is enqueued into the backend print worker **exactly once** keyed by `jobId`.

---

#### 4.2 Get LAN Printers Configuration
- **Endpoint:** `GET /printers`
- **Screen:** App Startup / Station Settings
- **Roles:** Cashier, Manager, Admin
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "printers": [
        {
          "id": "prn_kitchen_01",
          "name": "Main Kitchen Thermal Printer",
          "ip": "192.168.1.100",
          "port": 9100,
          "role": "kitchen",
          "categories": [
            "Starters",
            "Egg Preparations",
            "Soups",
            "Main Course",
            "Breads & Rice"
          ]
        },
        {
          "id": "prn_bar_01",
          "name": "Beverage & Bar Thermal Printer",
          "ip": "192.168.1.101",
          "port": 9100,
          "role": "bar",
          "categories": [
            "Beverages",
            "Desserts"
          ]
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 4.3 Log Manual Reprint
- **Endpoint:** `POST /printers/reprint-log`
- **Screen:** `PrintStatusModal`
- **Roles:** Waiter, Cashier, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "jobId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "orderId": "550e8400-e29b-41d4-a716-446655440000",
    "printerId": "prn_kitchen_01",
    "staffName": "Abhishek",
    "reason": "Kitchen ticket jammed",
    "reprintedAt": "2026-10-27T14:20:00Z"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": { "logged": true },
    "error": null,
    "timestamp": "2026-10-27T14:20:01Z"
  }
  ```

---

### 5. Stocks & Inventory Management Module

#### 5.1 List Inventory Items
- **Endpoint:** `GET /inventory/items`
- **Screen:** `StockTabView` (`lib/views/stock/stock_tab_view.dart`)
- **Roles:** Kitchen, Manager, Admin
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Query Parameters:**
  - `category` (Optional, string): `food`, `consumables`, `small_equip`, `fixed`, `all`
  - `low_stock_only` (Optional, boolean): `true` / `false`
  - `search` (Optional, string): Search item name, supplier, or unit
  - `sort` (Optional, string): `nameAsc`, `stockLevelAsc`, `stockLevelDesc`, `valueDesc`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "items": [
        {
          "id": "stk_00",
          "name": "Gloves Nitrile Black Disposable",
          "category": "consumables",
          "unit": "ml",
          "currentStock": 500.0,
          "minLevel": 1250.0,
          "costPerUnit": 0.60,
          "packetsCount": 2,
          "amountPerPacket": 250.0,
          "costPerPacket": 150.00,
          "minPackets": 5,
          "supplier": "Prime Safety Supplies",
          "lastAudited": "2026-10-26T18:00:00Z",
          "logs": [
            {
              "id": "log_101",
              "timestamp": "2026-10-26T18:00:00Z",
              "action": "Restock Batch",
              "quantityChange": 250.0,
              "balanceAfter": 500.0,
              "staffName": "Abhishek",
              "notes": "Invoice: INV-492"
            }
          ]
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 5.2 Inventory Summary Metrics
- **Endpoint:** `GET /inventory/summary`
- **Screen:** `StockTabView`
- **Roles:** Kitchen, Manager, Admin
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "totalItemsCount": 18,
      "lowAlertCount": 4,
      "outOfStockCount": 0,
      "totalStockValue": 128450.00,
      "lastKitchenAudit": "2026-10-26T18:00:00Z",
      "lastAuditedBy": "Barista Lead (Abhishek)"
    },
    "error": null,
    "timestamp": "2026-10-27T14:15:30Z"
  }
  ```

---

#### 5.3 Restock Item
- **Endpoint:** `POST /inventory/items/{id}/restock`
- **Path Parameter:** `id` (e.g. `stk_00`)
- **Screen:** `RestockModal` (`lib/views/stock/widgets/restock_modal.dart`)
- **Roles:** Kitchen, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "addedQuantity": 250.0,
    "invoiceNumber": "INV-8891",
    "supplierName": "Prime Safety Supplies",
    "staffName": "Abhishek (Manager)"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "itemId": "stk_00",
      "newStock": 750.0,
      "log": {
        "id": "log_9912",
        "action": "Restock Batch",
        "quantityChange": 250.0,
        "balanceAfter": 750.0,
        "timestamp": "2026-10-27T14:25:00Z"
      }
    },
    "error": null,
    "timestamp": "2026-10-27T14:25:00Z"
  }
  ```

---

#### 5.4 Issue Stock / Usage
- **Endpoint:** `POST /inventory/items/{id}/issue`
- **Path Parameter:** `id` (e.g. `stk_00`)
- **Screen:** `IssueStockModal` / `UsageModal`
- **Roles:** Kitchen, Manager
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "usedQuantity": 50.0,
    "reason": "Usage (kitchen / counter) - Daily meal prep",
    "staffName": "Abhishek (Manager)"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "itemId": "stk_00",
      "newStock": 450.0,
      "log": {
        "id": "log_9915",
        "action": "Kitchen Usage",
        "quantityChange": -50.0,
        "balanceAfter": 450.0,
        "timestamp": "2026-10-27T14:30:00Z"
      }
    },
    "error": null,
    "timestamp": "2026-10-27T14:30:00Z"
  }
  ```
- **Error Responses:**
  - `400 Bad Request` (`INSUFFICIENT_STOCK`): "Requested quantity exceeds current stock level."

---

#### 5.5 Create New Stock Item
- **Endpoint:** `POST /inventory/items`
- **Screen:** `NewStockItemModal` (`lib/views/stock/widgets/new_stock_item_modal.dart`)
- **Roles:** Manager, Admin
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "name": "Single Origin Coffee Beans",
    "category": "food",
    "unit": "kg",
    "initialStock": 10.0,
    "minLevel": 2.5,
    "costPerUnit": 850.00,
    "supplier": "Coorg Roasters",
    "staffName": "Abhishek (Manager)"
  }
  ```
- **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "data": {
      "id": "stk_88192",
      "name": "Single Origin Coffee Beans",
      "category": "food",
      "currentStock": 10.0,
      "minLevel": 2.5
    },
    "error": null,
    "timestamp": "2026-10-27T14:35:00Z"
  }
  ```

---

#### 5.6 Complete Kitchen Stocktake Audit
- **Endpoint:** `POST /inventory/audit`
- **Screen:** `StockAuditModal` (`lib/views/stock/widgets/stock_audit_modal.dart`)
- **Roles:** Manager, Chef
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "staffName": "Abhishek (Manager)",
    "notes": "Routine weekly kitchen & bar stocktake",
    "auditedAt": "2026-10-27T14:40:00Z"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "auditId": "aud_7718",
      "lastKitchenAudit": "2026-10-27T14:40:00Z",
      "lastAuditedBy": "Abhishek (Manager)"
    },
    "error": null,
    "timestamp": "2026-10-27T14:40:00Z"
  }
  ```

---

#### 5.7 Alert Manager Regarding Stock
- **Endpoint:** `POST /inventory/items/{id}/alert-manager`
- **Path Parameter:** `id`
- **Screen:** `AlertManagerModal` (`lib/views/stock/widgets/alert_manager_modal.dart`)
- **Roles:** Kitchen, Waiter
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Request Body:**
  ```json
  {
    "message": "Only 2 packets left for peak dinner service.",
    "currentStock": 500.0,
    "minLevel": 1250.0
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": { "alertDispatched": true },
    "error": null,
    "timestamp": "2026-10-27T14:42:00Z"
  }
  ```

---

#### 5.8 Item History Log
- **Endpoint:** `GET /inventory/items/{id}/history`
- **Path Parameter:** `id`
- **Screen:** `StockHistoryDialog` (`lib/views/stock/widgets/stock_history_dialog.dart`)
- **Roles:** Manager, Admin
- **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "logs": [
        {
          "id": "log_01",
          "timestamp": "2026-10-26T18:00:00Z",
          "action": "Restock Batch",
          "quantityChange": 250.0,
          "balanceAfter": 500.0,
          "staffName": "Abhishek",
          "notes": "Invoice: INV-492"
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:45:00Z"
  }
  ```

---

### 6. Staff Leaves & Attendance Module

#### 6.1 Monthly Working Days & Attendance Summary
- **Endpoint:** `GET /attendance/monthly-summary`
- **Screen:** `LeavesTabView` (`lib/views/leaves/leaves_tab_view.dart`)
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `year` (Required, integer): e.g. `2024`
  - `month` (Required, string): e.g. `October`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "year": 2024,
      "month": "October",
      "daysInMonth": 31,
      "totalAbsentLeaveDays": 3,
      "absentDays": 1,
      "leaveDays": 2,
      "absentCount": 1,
      "leaveCount": 2,
      "eligibleWorkDays": 26,
      "presentDays": 21,
      "attendanceRate": 91.3
    },
    "error": null,
    "timestamp": "2026-10-27T14:50:00Z"
  }
  ```

---

#### 6.2 Shift Check-In
- **Endpoint:** `POST /attendance/check-in`
- **Screen:** `LeavesTabView`
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "stationName": "Barista Station 01",
    "timestamp": "2026-10-27T08:30:00Z"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "checkedIn": true,
      "checkInTime": "2026-10-27T08:30:00Z",
      "station": "Barista Station 01"
    },
    "error": null,
    "timestamp": "2026-10-27T08:30:01Z"
  }
  ```

---

#### 6.3 Shift Check-Out
- **Endpoint:** `POST /attendance/check-out`
- **Screen:** `LeavesTabView`
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "timestamp": "2026-10-27T17:00:00Z"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "checkedIn": false,
      "shiftDurationSeconds": 30600,
      "shiftDurationFormatted": "08h 30m 00s"
    },
    "error": null,
    "timestamp": "2026-10-27T17:00:01Z"
  }
  ```

---

#### 6.4 List Leave Applications & Audit
- **Endpoint:** `GET /leaves`
- **Screen:** `LeavesTabView`
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "applications": [
        {
          "id": "LV-8812",
          "applicantName": "Kavita Nair",
          "applicantRole": "Head Barista",
          "staffId": "Staff #N-104",
          "initials": "KN",
          "startDate": "2024-10-28",
          "endDate": "2024-10-29",
          "days": 2,
          "type": "paidLeave",
          "reason": "Annual Family Function & Travel",
          "status": "approved",
          "reviewedBy": "Chef Julian V.",
          "appliedAt": "2024-10-20T10:00:00Z"
        },
        {
          "id": "LV-8815",
          "applicantName": "Sarah Jenkins",
          "applicantRole": "Floor Captain",
          "staffId": "Staff #N-082",
          "initials": "SJ",
          "startDate": "2024-11-02",
          "endDate": "2024-11-03",
          "days": 2,
          "type": "casualLeave",
          "reason": "Emergency Dental Procedure",
          "status": "pending",
          "reviewedBy": "Awaiting General Manager",
          "appliedAt": "2024-10-22T14:30:00Z"
        }
      ]
    },
    "error": null,
    "timestamp": "2026-10-27T14:55:00Z"
  }
  ```

---

#### 6.5 Apply for Leave
- **Endpoint:** `POST /leaves`
- **Screen:** `ApplyLeaveModal` (`lib/views/leaves/widgets/apply_leave_modal.dart`)
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "startDate": "2026-11-10",
    "endDate": "2026-11-12",
    "type": "paidLeave",
    "reason": "Family wedding celebration",
    "applicantName": "Abhishek",
    "applicantRole": "WAITER",
    "staffId": "Staff #usr_001"
  }
  ```
- **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "data": {
      "id": "LV-9921",
      "applicantName": "Abhishek",
      "status": "pending",
      "reviewedBy": "Awaiting Floor Manager Confirmation",
      "appliedAt": "2026-10-27T15:00:00Z"
    },
    "error": null,
    "timestamp": "2026-10-27T15:00:00Z"
  }
  ```

---

#### 6.6 Cancel / Recall Leave Application
- **Endpoint:** `DELETE /leaves/{id}`
- **Path Parameter:** `id` (e.g. `LV-9921`)
- **Screen:** `LeavesTabView`
- **Roles:** Applicant, Manager
- **Headers:** `Authorization: Bearer <token>`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "id": "LV-9921",
      "cancelled": true,
      "message": "Leave application recalled successfully."
    },
    "error": null,
    "timestamp": "2026-10-27T15:05:00Z"
  }
  ```

---

### 7. Staff Profile & Duty Badge Module

#### 7.1 Detailed Staff Profile
- **Endpoint:** `GET /staff/profile`
- **Screen:** `ProfileView` (`lib/views/profile/profile_view.dart`)
- **Roles:** All Staff
- **Headers:** `Authorization: Bearer <token>`
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "name": "Abhishek",
      "isActive": true,
      "role": "Employee",
      "designation": "Waiter",
      "account": {
        "username": "Abhishek",
        "role": "Employee",
        "tableOrdersPos": "Allowed",
        "inventory": "Allowed",
        "printBill": "Restricted"
      },
      "employment": {
        "fullName": "Abhishek B Ambady",
        "designation": "Waiter",
        "phone": "9876543210",
        "email": "abc@gmail.com",
        "department": "Dining & Service",
        "joinedDate": "15 Jan 2023",
        "basicSalary": "20000",
        "leaveQuota": "12 paid / 12 casual days per year",
        "address": "12/482 Neram Lane, Panampilly Nagar, Kochi, Kerala 682036"
      },
      "bank": {
        "accountHolder": "Abhishek",
        "bankName": "Federal Bank",
        "accountNumber": "982374982739",
        "ifsc": "AL432892",
        "branch": "Kochi",
        "upiId": "4894938@icici"
      }
    },
    "error": null,
    "timestamp": "2026-10-27T15:10:00Z"
  }
  ```

---

#### 7.2 Update Staff Duty Status (Active / Inactive)
- **Endpoint:** `PATCH /staff/profile/status`
- **Screen:** `ProfileView`
- **Roles:** Staff, Manager
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "isActive": false
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "isActive": false,
      "statusText": "Inactive",
      "updatedAt": "2026-10-27T15:12:00Z"
    },
    "error": null,
    "timestamp": "2026-10-27T15:12:00Z"
  }
  ```

---

## Suggested Relational Schema (PostgreSQL Recommendation)

```sql
-- Outlets & Terminals
CREATE TABLE outlets (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users / Staff
CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    username VARCHAR(64) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(32),
    role VARCHAR(32) NOT NULL, -- manager, cashier, waiter, kitchen_staff
    is_active BOOLEAN DEFAULT TRUE,
    department VARCHAR(128),
    joined_date DATE,
    basic_salary NUMERIC(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bank Details
CREATE TABLE user_bank_details (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES users(id),
    account_holder VARCHAR(255) NOT NULL,
    bank_name VARCHAR(128) NOT NULL,
    account_number VARCHAR(64) NOT NULL,
    ifsc VARCHAR(32) NOT NULL,
    branch VARCHAR(128),
    upi_id VARCHAR(128)
);

-- Tables
CREATE TABLE dining_tables (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(64) NOT NULL,
    zone VARCHAR(32) NOT NULL, -- indoor, outdoor, takeaway
    seats INT DEFAULT 4,
    status VARCHAR(32) DEFAULT 'vacant', -- vacant, occupied, preparing, billed
    total NUMERIC(10,2) DEFAULT 0.00,
    customer_name VARCHAR(128)
);

-- Menu Categories & Dishes
CREATE TABLE menu_categories (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(128) NOT NULL,
    display_order INT DEFAULT 0
);

CREATE TABLE menu_dishes (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    category_id VARCHAR(64) REFERENCES menu_categories(id),
    name VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    price NUMERIC(10,2) NOT NULL,
    food_type VARCHAR(32) NOT NULL, -- veg, egg, nonVeg
    is_available BOOLEAN DEFAULT TRUE
);

-- Orders & Hybrid Sync
CREATE TABLE orders (
    id VARCHAR(64) PRIMARY KEY, -- client UUID v4
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    local_no VARCHAR(64) NOT NULL,
    server_order_no VARCHAR(64) NOT NULL,
    table_id VARCHAR(64),
    customer_name VARCHAR(128),
    dining_mode VARCHAR(32) NOT NULL,
    order_note TEXT,
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    status VARCHAR(32) DEFAULT 'preparing',
    rev INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(64) REFERENCES orders(id) ON DELETE CASCADE,
    dish_id VARCHAR(64) REFERENCES menu_dishes(id),
    name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    item_note TEXT
);

CREATE TABLE print_jobs (
    id VARCHAR(64) PRIMARY KEY, -- client UUID v4
    order_id VARCHAR(64) REFERENCES orders(id) ON DELETE CASCADE,
    printer_id VARCHAR(64) NOT NULL,
    type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL, -- pending, printing, printed, fallbackRequested, serverPrinted
    attempts INT DEFAULT 0,
    last_error TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory / Stock
CREATE TABLE stock_items (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL,
    unit VARCHAR(32) NOT NULL,
    current_stock NUMERIC(12,2) NOT NULL,
    min_level NUMERIC(12,2) NOT NULL,
    cost_per_unit NUMERIC(10,2) NOT NULL,
    supplier VARCHAR(255),
    packets_count INT,
    amount_per_packet NUMERIC(10,2),
    cost_per_packet NUMERIC(10,2),
    min_packets INT,
    last_audited TIMESTAMP WITH TIME ZONE
);

CREATE TABLE stock_logs (
    id VARCHAR(64) PRIMARY KEY,
    item_id VARCHAR(64) REFERENCES stock_items(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    action VARCHAR(64) NOT NULL,
    quantity_change NUMERIC(12,2) NOT NULL,
    balance_after NUMERIC(12,2) NOT NULL,
    staff_name VARCHAR(255) NOT NULL,
    notes TEXT
);

-- Attendance & Leaves
CREATE TABLE attendance_punches (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id),
    type VARCHAR(32) NOT NULL, -- check_in, check_out
    station_name VARCHAR(128),
    punch_time TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE leave_applications (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id),
    applicant_name VARCHAR(255) NOT NULL,
    applicant_role VARCHAR(64) NOT NULL,
    staff_id VARCHAR(64) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days INT NOT NULL,
    type VARCHAR(32) NOT NULL, -- paidLeave, casualLeave, compensatoryOff, sickLeave
    reason TEXT NOT NULL,
    status VARCHAR(32) DEFAULT 'pending', -- pending, approved, rejected
    reviewed_by VARCHAR(255),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Implementation Plan Overview

1. **Step 1: Core API Layer & Infrastructure**
   - Base configuration & endpoints in `lib/core/constants/api_endpoints.dart`.
   - `ApiResponse<T>` envelope and error mapping in `lib/core/network/api_response.dart`.
   - Native RFC 4122 v4 UUID generator in `lib/features/printing/utils/uuid_generator.dart` with unit tests.
2. **Step 2: Hybrid Kitchen Printing Subsystem**
   - Models (`PrintJob`, `PrintStatus`, `OrderRecord`, `PrinterConfig`).
   - Sockets `SocketPrinterService` with typed errors.
   - `TicketBuilder` for ESC/POS binary format.
   - `LocalOrderRepository` in `SharedPreferences`.
   - `PrintQueue` FIFO sequential per-printer execution.
   - `SyncService` single-flight worker with `Idempotency-Key` and backoff.
   - `StartupRecovery` and `HybridPrintManager`.
3. **Step 3: Repositories & ViewModel Integration**
   - `TableRepository` and `OrderRepository` integrated into `TableViewModel`.
   - `StockRepository` integrated into `StockViewModel`.
   - `LeavesRepository` integrated into `LeavesViewModel`.
   - `StaffRepository` integrated into `ProfileView`.
   - `DashboardRepository` integrated into `NeramDrawer`.
   - Wire `CartDetailsModal` and `ChangePasswordDialog`.
4. **Step 4: Platform Permissions**
   - Android: `ACCESS_NETWORK_STATE` in `AndroidManifest.xml`.
   - iOS: `NSLocalNetworkUsageDescription` in `Info.plist`.
5. **Step 5: Testing & Verification**
   - Unit tests for UUID generator, envelopes, queue, sync service, and repositories.
   - Run `flutter analyze` and `flutter test`.
   - Produce final `API_SPEC.md` and `openapi.yaml`.

