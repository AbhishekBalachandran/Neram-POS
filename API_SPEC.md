# NERAM POS — Complete Backend API Specification & Contract

**Version:** 1.0.0  
**Environment Base URL:** `https://api.nerampos.com/v1` (Production) / `https://dev-api.nerampos.com/v1` (Development)  
**Protocol:** HTTPS / JSON (RESTful)  
**Standard Character Encoding:** UTF-8  

---

## 1. Global Architectural Conventions

### 1.1 Authentication & Authorization
All secured endpoints expect an HTTP `Authorization` Bearer header:
```http
Authorization: Bearer <access_token>
```
* **Token Lifetime:** Access Token (15–60 minutes), Refresh Token (30 days, rotated on use).
* **Clock Skew Tolerance:** 60 seconds.

### 1.2 Outlet / Branch Scoping
Every non-auth request MUST include the outlet identifier either in the HTTP header:
```http
X-Outlet-Id: outlet_001
```
or via the authenticated JWT token payload claims (`claims.outletId`).

### 1.3 Standard Response Formats
#### Success Response (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully"
}
```
#### Error Response (`400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `500 Server Error`)
```json
{
  "success": false,
  "error": {
    "code": "ORDER_ALREADY_EXISTS",
    "message": "Human readable explanation of what went wrong",
    "details": {
      "field": "orderId",
      "reason": "Duplicate client-generated orderId"
    }
  }
}
```

---

## 2. Authentication & Staff Profile Endpoints

### 2.1 `POST /auth/login`
Staff authentication via username and password.

* **Headers:** `Content-Type: application/json`
* **Request Body:**
```json
{
  "username": "abhishek",
  "password": "sample_password"
}
```
* **Responses:**
  * `200 OK`:
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "usr_abhishek_001",
        "name": "Abhishek",
        "email": "abhishek@nerampos.com",
        "role": "manager",
        "outletId": "outlet_001"
      },
      "token": {
        "accessToken": "eyJhbGciOiJIUzI1NiIs...",
        "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
        "expiresIn": 3600
      }
    }
  }
  ```
  * `401 Unauthorized`: Invalid credentials.

---

### 2.2 `POST /auth/refresh`
Refresh expired JWT access token using long-lived refresh token.

* **Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```
* **Responses:**
  * `200 OK`:
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 3600
    }
  }
  ```
  * `401 Unauthorized`: Expired or revoked refresh token.

---

### 2.3 `POST /auth/logout`
Revoke active session and refresh token.

* **Headers:** `Authorization: Bearer <token>`
* **Responses:** `200 OK`
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 2.4 `POST /auth/change-password`
Change current staff password.

* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "currentPassword": "OldPassword123!",
  "newPassword": "NewPassword456!"
}
```
* **Responses:**
  * `200 OK`: Password updated successfully.
  * `400 Bad Request`: Current password incorrect or new password does not satisfy security policy.

---

### 2.5 `GET /auth/profile`
Retrieve active staff member's authenticated profile.

* **Headers:** `Authorization: Bearer <token>`
* **Responses:**
  * `200 OK`:
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "usr_abhishek_001",
        "name": "Abhishek B Ambady",
        "email": "abc@gmail.com",
        "role": "employee",
        "designation": "Waiter",
        "phone": "9876543210",
        "department": "Service",
        "joinedDate": "2024-01-15",
        "basicSalary": 20000,
        "leaveQuota": "12 paid / 12 casual days per year",
        "outletId": "outlet_001",
        "isActive": true
      }
    }
  }
  ```

---

### 2.6 `PATCH /staff/profile/status`
Toggle or update staff active/inactive duty badge.

* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "isActive": true
}
```
* **Responses:** `200 OK` with updated status.

---

## 3. Hybrid Printing & Order Sync Engine (Crucial Core Integration)

### 3.1 Architecture & Invariants
1. **Client-Generated UUIDs:** `orderId` and each `jobId` are client-generated RFC 4122 v4 UUIDs created when the draft order sheet is opened. Immediate double-taps reuse the exact same UUIDs.
2. **Idempotency:** The sync endpoint `POST /orders/sync` is an idempotent upsert keyed by `orderId`. Retrying with identical `orderId` MUST return `200 OK` with the existing server record, NEVER duplicate the order.
3. **Status Transitions:**
   * `printed` and `serverPrinted` are terminal/final states. They MUST NEVER be overwritten by `pending` or `failed`.
   * A job that arrives at the server with status `fallbackRequested` and is not marked `printed` or `serverPrinted` MUST be placed on the backend server's printer queue exactly once.

---

### 3.2 `POST /orders/sync`
Primary background synchronization endpoint.

* **Headers:**
  * `Authorization: Bearer <token>`
  * `Idempotency-Key: <orderId>` (UUID v4)
  * `X-Outlet-Id: outlet_001`
* **Request Body:**
```json
{
  "orderId": "b8f04128-6622-4467-9c92-358055655aa9",
  "localNo": "#ORD-2849",
  "payload": {
    "tableId": "T-01",
    "tableName": "Table T-01",
    "diningMode": "dineIn",
    "customerName": "Dine-In",
    "orderNote": "Extra spicy",
    "items": [
      {
        "id": "dish_1",
        "name": "Crispy Corn Pepper Fry",
        "quantity": 2,
        "price": 8.50,
        "note": "Crispy fried"
      },
      {
        "id": "dish_4",
        "name": "Butter Chicken Handi",
        "quantity": 1,
        "price": 14.50,
        "note": ""
      }
    ],
    "subtotal": 31.50,
    "tax": 1.58,
    "total": 33.08
  },
  "jobs": [
    {
      "jobId": "c4d32a01-8b21-4322-9011-2859102488aa",
      "printerId": "kitchen_main",
      "type": "kot",
      "status": "printed",
      "attempts": 1,
      "lastError": null
    },
    {
      "jobId": "e1f23b02-9c32-4433-8122-3960213599bb",
      "printerId": "bar_counter",
      "type": "kot",
      "status": "fallbackRequested",
      "attempts": 3,
      "lastError": "Socket connection timed out"
    }
  ],
  "synced": false,
  "rev": 2,
  "createdAt": "2026-10-27T14:45:00.000Z",
  "deviceId": "pos_tablet_counter_01"
}
```

* **Backend Processing Rules:**
  1. Look up existing order by `orderId`.
  2. If none exists, create new order record and assign `serverOrderId` (e.g. `srv_ord_98231`) and sequential server order number.
  3. For each job in `jobs[]`:
     * If the database status is already `printed` or `serverPrinted`, retain it.
     * If the incoming job status is `fallbackRequested` and DB is not `printed`/`serverPrinted`, enqueue job into backend ESC/POS printer daemon to print on the LAN printer directly from the server. Once printed, mark job `serverPrinted`.
     * If incoming job status is `printed`, update DB status to `printed`.
  4. Return `200 OK` with merged job statuses.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "orderId": "b8f04128-6622-4467-9c92-358055655aa9",
    "serverOrderId": "srv_ord_98231",
    "serverOrderNo": "ORD-2026-08912",
    "rev": 2,
    "jobs": [
      {
        "jobId": "c4d32a01-8b21-4322-9011-2859102488aa",
        "printerId": "kitchen_main",
        "status": "printed"
      },
      {
        "jobId": "e1f23b02-9c32-4433-8122-3960213599bb",
        "printerId": "bar_counter",
        "status": "serverPrinted"
      }
    ],
    "synced": true,
    "syncedAt": "2026-10-27T14:45:01.210Z"
  }
}
```

---

### 3.3 `GET /printers`
Fetch configured network thermal printers for the outlet.

* **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "printers": [
      {
        "id": "kitchen_main",
        "name": "Main Kitchen KOT Printer",
        "ip": "192.168.1.100",
        "port": 9100,
        "role": "kitchen",
        "categories": ["Starters", "Main Course", "Egg Preparations", "Soups", "Breads & Rice"]
      },
      {
        "id": "bar_counter",
        "name": "Bar & Beverage Printer",
        "ip": "192.168.1.101",
        "port": 9100,
        "role": "bar",
        "categories": ["Beverages", "Desserts"]
      },
      {
        "id": "billing_counter",
        "name": "Front Desk Cashier Printer",
        "ip": "192.168.1.102",
        "port": 9100,
        "role": "billing",
        "categories": []
      }
    ]
  }
}
```

---

## 4. Tables, Dine-In & Live Orders Endpoints

### 4.1 `GET /tables`
Retrieve all tables and current occupancy state.

* **Headers:** `Authorization: Bearer <token>`, `X-Outlet-Id: outlet_001`
* **Response (`200 OK`):**
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
      }
    ]
  }
}
```

---

### 4.2 `POST /tables/transfer`
Transfer an active table session (and associated orders) from one table to another.

* **Request Body:**
```json
{
  "fromTableId": "T-01",
  "toTableId": "T-04",
  "reason": "Customer requested bigger booth"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Table transferred successfully"
}
```

---

### 4.3 `GET /menu/categories`
Retrieve dish category list.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    "Starters",
    "Egg Preparations",
    "Soups",
    "Main Course",
    "Breads & Rice",
    "Beverages",
    "Desserts"
  ]
}
```

---

### 4.4 `GET /menu/items`
Retrieve active restaurant catalog items.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
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
}
```

---

### 4.5 `GET /orders/active`
Retrieve list of currently open dining & takeaway orders.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
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
}
```

---

### 4.6 `POST /orders/{id}/bill`
Generate customer bill and transition table state to `billed`.

* **Path Parameters:** `id` (e.g. `#ORD-2849`)
* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "orderId": "#ORD-2849",
    "status": "billed",
    "billedAt": "2026-10-27T14:50:00.000Z"
  }
}
```

---

### 4.7 `POST /orders/{id}/settle`
Settle payment and clear table state to `vacant`.

* **Request Body:**
```json
{
  "paymentMethod": "UPI",
  "amountPaid": 48.50,
  "transactionRef": "UPI/2026/982374"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Order settled successfully and table released"
}
```

---

### 4.8 `DELETE /orders/{id}`
Cancel an active order.

* **Request Body:**
```json
{
  "reason": "Customer left"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Order cancelled successfully"
}
```

---

## 5. Stocks & Inventory Management Endpoints

### 5.1 `GET /inventory/items`
Retrieve full inventory catalog items with stock ratios and audit logs.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "stk_gloves_01",
      "name": "Gloves Nitrile Black Disposable",
      "category": "consumables",
      "unit": "boxes",
      "currentStock": 4.0,
      "minLevel": 5.0,
      "costPerUnit": 450.0,
      "supplier": "SafeGrip Healthcare Supplies",
      "packetsCount": 4,
      "amountPerPacket": 100.0,
      "costPerPacket": 450.0,
      "minPackets": 5,
      "lastAudited": "2026-10-26T10:00:00.000Z",
      "logs": [
        {
          "id": "log_01",
          "timestamp": "2026-10-26T10:00:00.000Z",
          "action": "Restock Batch",
          "quantityChange": 2.0,
          "balanceAfter": 4.0,
          "staffName": "Abhishek (Manager)",
          "notes": "Invoice #PO-9821"
        }
      ]
    }
  ]
}
```

---

### 5.2 `POST /inventory/items`
Register a new stock item in the catalog.

* **Request Body:**
```json
{
  "name": "Arabica Coffee Beans A-Grade",
  "category": "food",
  "unit": "kg",
  "currentStock": 25.0,
  "minLevel": 10.0,
  "costPerUnit": 850.0,
  "supplier": "Coorg Plantation Direct"
}
```
* **Response (`201 Created`):** Returns created item with assigned ID.

---

### 5.3 `POST /inventory/items/{id}/restock`
Record incoming shipment/batch of existing item.

* **Path Parameter:** `id` (e.g. `stk_gloves_01`)
* **Request Body:**
```json
{
  "addedQuantity": 10.0,
  "invoiceNumber": "INV-2026-081",
  "supplierName": "SafeGrip Supplies",
  "staffName": "Abhishek (Manager)"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "itemId": "stk_gloves_01",
    "newBalance": 14.0
  }
}
```

---

### 5.4 `POST /inventory/items/{id}/issue`
Record kitchen or bar consumption/usage.

* **Request Body:**
```json
{
  "usedQuantity": 2.0,
  "reason": "Bar shift operational prep",
  "staffName": "Abhishek (Manager)"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "itemId": "stk_gloves_01",
    "newBalance": 12.0
  }
}
```

---

### 5.5 `POST /inventory/items/{id}/alert-manager`
Update minimum safety stock thresholds or trigger manager restock alerts.

* **Request Body:**
```json
{
  "minLevel": 8.0,
  "minPackets": 8
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Alert threshold updated"
}
```

---

### 5.6 `POST /inventory/audit`
Submit weekly physical stock audit reconciliation.

* **Request Body:**
```json
{
  "staffName": "Abhishek (Manager)",
  "notes": "Sunday closing physical count",
  "timestamp": "2026-10-27T18:00:00.000Z"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Audit recorded"
}
```

---

## 6. Attendance & Leaves Management Endpoints

### 6.1 `GET /attendance/monthly-summary`
Retrieve monthly attendance metrics for working days calculator.

* **Query Parameters:** `year=2024&month=October`
* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "year": 2024,
    "month": "October",
    "totalMonthDays": 31,
    "absentDays": 1,
    "leaveDays": 2,
    "presentDays": 23,
    "offDays": 5
  }
}
```

---

### 6.2 `POST /attendance/check-in`
Punch in for work shift.

* **Request Body:**
```json
{
  "timestamp": "2026-10-27T08:30:00.000Z",
  "station": "Active"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Checked in successfully"
}
```

---

### 6.3 `POST /attendance/check-out`
Punch out of work shift.

* **Request Body:**
```json
{
  "timestamp": "2026-10-27T17:30:00.000Z"
}
```
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Checked out successfully"
}
```

---

### 6.4 `GET /leaves`
Retrieve all leave applications for the outlet.

* **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "LV-8812",
      "applicantName": "Kavita Nair",
      "applicantRole": "Head Barista",
      "staffId": "Staff #N-104",
      "initials": "KN",
      "startDate": "2024-10-28T00:00:00.000Z",
      "endDate": "2024-10-29T00:00:00.000Z",
      "days": 2,
      "type": "paidLeave",
      "reason": "Annual Family Function & Travel",
      "status": "approved",
      "reviewedBy": "Chef Julian V.",
      "appliedAt": "2024-10-20T00:00:00.000Z"
    }
  ]
}
```

---

### 6.5 `POST /leaves`
Submit a new leave application.

* **Request Body:**
```json
{
  "id": "LV-9021",
  "applicantName": "Abhishek B Ambady",
  "applicantRole": "Waiter",
  "staffId": "Staff #N-001",
  "initials": "AA",
  "startDate": "2024-11-05T00:00:00.000Z",
  "endDate": "2024-11-06T00:00:00.000Z",
  "days": 2,
  "type": "casualLeave",
  "reason": "Personal medical appointment",
  "status": "pending",
  "reviewedBy": "Awaiting Manager Dispatch",
  "appliedAt": "2026-10-27T15:00:00.000Z"
}
```
* **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Leave application submitted"
}
```

---

### 6.6 `DELETE /leaves/{id}`
Cancel an existing leave request.

* **Path Parameter:** `id` (e.g. `LV-9021`)
* **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Leave application cancelled"
}
```

---

## 7. Recommended Relational Database Schema (PostgreSQL)

```sql
-- 1. Outlets
CREATE TABLE outlets (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Staff
CREATE TABLE staff (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL,
    designation VARCHAR(64),
    phone VARCHAR(32),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Printers
CREATE TABLE printers (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    port INT DEFAULT 9100,
    role VARCHAR(32) NOT NULL,
    categories JSONB DEFAULT '[]'::jsonb
);

-- 4. Orders & Sync
CREATE TABLE orders (
    order_id UUID PRIMARY KEY,
    server_order_no VARCHAR(64) UNIQUE,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    local_no VARCHAR(64) NOT NULL,
    table_id VARCHAR(32),
    dining_mode VARCHAR(32) NOT NULL,
    customer_name VARCHAR(255),
    payload JSONB NOT NULL,
    rev INT DEFAULT 1,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Print Jobs
CREATE TABLE print_jobs (
    job_id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
    printer_id VARCHAR(64) REFERENCES printers(id),
    job_type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL, -- pending, printing, printed, fallbackRequested, serverPrinted
    attempts INT DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Inventory Items
CREATE TABLE inventory_items (
    id VARCHAR(64) PRIMARY KEY,
    outlet_id VARCHAR(64) REFERENCES outlets(id),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL,
    unit VARCHAR(32) NOT NULL,
    current_stock NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    min_level NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    cost_per_unit NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    supplier VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Leave Applications
CREATE TABLE leave_applications (
    id VARCHAR(64) PRIMARY KEY,
    staff_id VARCHAR(64) REFERENCES staff(id),
    applicant_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days INT NOT NULL,
    leave_type VARCHAR(32) NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    reviewed_by VARCHAR(255),
    applied_at TIMESTAMPTZ DEFAULT NOW()
);
```

