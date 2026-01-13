# CST Future Orders Edge - Quick Reference Guide

## Overview

The CST Future Orders Edge MPage displays and manages future orders within Cerner PowerChart. Built as an Angular Web Component using Clinical Office:MPage Edition, it allows clinical staff to view, filter, and activate future orders for patients.

**Key Capabilities:**
- View future orders grouped by provider and start date
- Filter by time range, specimen type, provider, and location
- Activate orders with appropriate permissions
- Toggle between Labs and Cardiology views
- Persist user filter preferences

---

## User Interface

### Filter Toolbar

| Control | Function |
|---------|----------|
| Look Back | Days/Weeks/Months to search in the past |
| Look Forward | Days/Weeks/Months to search in the future |
| Specimen Type | Filter by Blood or Non-Blood specimens |
| Provider | Filter by ordering provider |
| Ordering Location | Filter by order origin location |
| Order Search | Free-text search across order names |
| Typical Labs Checkbox | Show only commonly activated lab orders |

### Order Type Tabs

- **Labs** - General laboratory orders with count badge
- **Cardiology** - Cardiology orders with count badge

### Order Display

Orders are displayed in a hierarchical tree table:
- **Parent rows**: Group header showing date and provider
- **Child rows**: Individual orders with details

**Visual Indicators:**
- PowerPlan icon - Order is part of a PowerPlan
- Comment icon - Order has comments attached
- Highlighted rows - Orders currently due

### Actions

- **Select orders** using checkboxes
- **Activate** button processes selected orders (authorized users only)
- **Support Tools** link opens additional utilities (authorized users only)

---

## CCL Backend

### Main Script: bc_all_future_orders

Retrieves future orders using the standard Cerner `mp_cpoe_get_future_orders` utility and enriches the data with additional context.

**Input Parameters:**
- `lookback` - Time range back (e.g., "1,M" for 1 month)
- `lookforward` - Time range forward (e.g., "1,M" for 1 month)
- `orderType` - 0 for Labs, 1 for Cardiology

**Output Data:**
- Order list with mnemonic, dates, provider, location, specimen type
- PowerPlan associations and Day of Treatment information
- Provider and location lists for filter dropdowns
- Order counts by type
- User permission flags

### Configuration Files

The script uses JSON configuration files for customization:

| File | Purpose |
|------|---------|
| bc_all_future_orders_spec.json | Specimen type codes for "typical" labs |
| bc_all_future_orders_pp.json | PowerPlan descriptions to exclude |
| bc_all_future_orders_pp_id.json | PowerPlan IDs to exclude |
| bc_all_future_orders_positions.json | Position codes authorized to activate |

### Supporting Scripts

| Script | Purpose |
|--------|---------|
| bc_all_all_date_routines | Date formatting subroutines |
| bc_all_future_ord_lb_set | Order activation processing |
| bc_all_future_ord_support_tool | Support tools report |

---

## Data Flow

```
User Action
    ↓
Angular Component (orders-table)
    ↓
FutureorderService.loadFutureOrders()
    ↓
CustomService.load() → CCL Proxy
    ↓
bc_all_future_orders:group1
    ↓
mp_cpoe_get_future_orders (Cerner standard)
    ↓
JSON Response → Angular TreeTable
```

---

## Common Usage Patterns

### Loading Orders with Default Filters

```typescript
// Service call with 1 month lookback/forward, Labs
this.futureOrderDS.loadFutureOrders('1,M', '1,M', 0);
```

### Filtering by Provider

```typescript
// TreeTable filter call
this.treetable.filter(providerName, 'orderingProvider', 'equals');
```

### Activating Orders

```typescript
// Uses Cerner PowerOrders MPage Utils
PowerOrdersMPagesUtils.CreateMOEW(personId, encntrId, 0, 2, 127)
  .then((hMOEW) => {
    return PowerOrdersMPagesUtils.InvokeActivateAction(hMOEW, orderId, activateDate);
  })
  .then(() => {
    return PowerOrdersMPagesUtils.SignOrders(hMOEW);
  });
```

### Persisting User Preferences

```typescript
// Save filter settings to dm_info
this.customService.executeDmInfoAction('timeFilterPref', 'w', [{
  infoDomain: 'CST Future Order Mpage',
  infoName: 'timeFilters',
  infoChar: JSON.stringify(filterSettings),
  infoDomainId: prsnlId
}]);
```

---

## Configuration

### Environment Requirements

- Microsoft Edge WebView controller (not Internet Explorer)
- Cerner preferences set to Edge mode
- Valid Clinical Office:MPage Edition license

### Proxy Setup (Development)

Run `1co_show_service_dir` in Discern Visual Developer and update proxy.conf.json:

```json
{
  "/cclproxy/*": {
    "target": "YOUR_CCLPROXY_URL",
    "secure": false,
    "changeOrigin": true
  }
}
```

### Build Commands

```bash
# Development server
ng serve

# Production build
ng build --configuration production && node concat.js

# Run tests
ng test
```

---

## Best Practices

- **Time Filters**: Default to reasonable ranges (1 month) to balance data volume and relevance
- **Typical Labs**: Keep enabled by default to reduce noise from special collection orders
- **Activation**: Select orders carefully before activating; action cannot be undone from this MPage
- **Support Tools**: Use for troubleshooting when orders don't appear as expected

---

## Key Technologies

| Technology | Usage |
|------------|-------|
| Angular 16 | Application framework |
| Angular Elements | Web Component packaging |
| PrimeNG | UI component library (TreeTable, Dropdown, etc.) |
| Clinical Office MPage Core | Cerner integration layer |
| CCL | Backend data retrieval |
| Luxon | Date/time formatting |
