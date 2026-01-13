# CST Future Orders Edge - Technical Documentation

## Overview

The **CST Future Orders Edge** MPage is a Clinical Office:MPage Edition application for displaying and managing future orders within Cerner/Oracle Health environments. Built with Angular 16+ and deployed as a Web Component (`<cst-future-orders-edge>`), it runs exclusively in Microsoft Edge WebView and integrates with the Cerner Component Framework in Edge mode.

### Purpose and Use Cases

- **View Future Orders**: Display patient future orders grouped by provider and requested start date
- **Filter Orders**: Filter by time range (lookback/lookforward), specimen type, provider, and ordering location
- **Activate Orders**: Allow authorized users to activate selected future orders directly from the MPage
- **Order Type Switching**: Toggle between Labs and Cardiology order views
- **User Preferences**: Persist user time filter preferences using `dm_info`

---

## Architecture

### Component Hierarchy

```
src/app/
├── app.component.ts              # Root component, MPage initialization
├── app.module.ts                 # Main module with Web Component setup (lines 86-98)
├── app-routing.module.ts         # Routing config (useHash: true)
├── component/
│   └── orders-table/             # Main orders display component
│       ├── orders-table.component.ts
│       ├── orders-table.component.html
│       └── orders-table.component.scss
└── service/
    └── futureorder.service.ts    # CCL script execution and data management
```

### Web Component Architecture

The application uses **Angular Elements** to create a custom web component:

```typescript
// app.module.ts:90-97
ngDoBootstrap() {
  const element = createCustomElement(AppComponent, {
    injector: this.injector
  });

  if (!customElements.get('cst-future-orders-edge')) {
    customElements.define('cst-future-orders-edge', element);
  }
}
```

**Key Points:**
- `AppModule` uses `ngDoBootstrap()` instead of traditional bootstrap
- Creates `<cst-future-orders-edge>` custom element
- Uses `ViewEncapsulation.None` for Cerner framework compatibility

### MPage Service Integration

**URL Parameter Parsing** (`app.component.ts:35-39`):
```typescript
this.activatedRoute.queryParams.subscribe(params => {
  this.mPage.personId = params['personId'] ? parseInt(params['personId']) : this.mPage.personId;
  this.mPage.encntrId = params['encounterId'] ? parseInt(params['encounterId']) : this.mPage.encntrId;
  this.mPage.prsnlId = params['userId'] ? parseInt(params['userId']) : this.mPage.prsnlId;
});
```

**Instance Configuration** (`app.component.ts:43`):
```typescript
this.mPage.setMaxInstances(2, true, 'CHART', false);
```

---

## CCL Integration

### Main CCL Script: `bc_all_future_orders:group1`

**Location**: `src/script/bc_all_future_orders/bc_all_future_orders.prg`

#### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lookback` | string | Time range to look back (e.g., "1,M" for 1 month) |
| `lookforward` | string | Time range to look forward (e.g., "1,M" for 1 month) |
| `orderType` | number | 0 = Labs, 1 = Cardiology |

#### CCL Execution Pattern

```typescript
// futureorder.service.ts:24-44
this.futureOrderService.load({
  customScript: {
    script: [
      {
        name: 'bc_all_future_orders:group1',
        run: 'pre',
        id: 'futureorders',
        parameters: {
          'lookback': lookback,
          'lookforward': lookforward,
          'orderType': orderType
        }
      }
    ]
  }
}, undefined, (() => {
  this.FutureOrdersLoading = false;
  this.LastRefesh = this.futureOrderService.get('futureorders').lastrefesh;
  this.refresh = true;
  this.isLoaded = true;
}));
```

#### rCustom Record Structure

The CCL script returns data via the `rCustom` record structure (`bc_all_future_orders.prg:117-247`):

```ccl
record rCustom (
    1 user_id                    = f8
    1 position_cd                = f8
    1 activate_button_ind        = vc
    1 live_ind                   = vc
    1 support_message            = vc
    1 support_tool_ind           = vc
    1 lastRefesh                 = vc
    1 encounter_type             = vc
    1 encounter_location         = vc
    1 order_type                 = i4
    1 order_type_meaning         = vc
    1 selected_catalog_type      = f8
    1 content_service_url        = vc     ; Dynamic asset URL base
    1 webshere_host              = vc     ; WebSphere host for assets
    1 fully_qualified_domain     = vc     ; Domain for mpage-content path
    1 ord_location_cnt           = i4
    1 ord_location_list[*]
     2 label                     = vc
     2 value                     = vc
    1 provider_cnt               = i4
    1 provider_list[*]
     2 label                     = vc
     2 value                     = vc
    1 counts
     2 lab                       = i2
     2 cardiology                = i2
     2 radiology                 = i2
     2 all                       = i2
    1 order_cnt                  = i4
    1 order_list[*]
     2 data
         3 order_id              = f8
         3 catalog_cd            = f8
         3 order_mnemonic        = vc
         3 orig_order_date       = dq8
         3 requested_start_date  = dq8
         3 ordering_provider     = vc
         3 order_details         = vc
         3 ordering_location     = vc
         3 specimen_type         = vc
         3 powerplan
          4 description          = vc
          4 ind                  = i2
          4 dot_ind              = i2
          4 pathway_id           = f8
         3 hidden_data
          4 due_status_flag      = i2
          4 row_class            = vc
     2 children[*]
        3 data
            ; Similar structure to parent data
)
```

#### External CCL Dependencies

The script calls:
- `bc_all_all_date_routines` - Date formatting subroutines (line 114)
- `mp_cpoe_get_future_orders` - Cerner standard future orders retrieval (lines 581-590)

#### Configuration Files (JSON)

Located in `cust_script:`:
- `bc_all_future_orders_spec.json` - Common lab specimen type codes
- `bc_all_future_orders_pp.json` - Non-lab PowerPlan descriptions
- `bc_all_future_orders_pp_id.json` - Non-lab PowerPlan IDs
- `bc_all_future_orders_positions.json` - Positions authorized to activate orders

### Dynamic Asset URL Resolution

The CCL queries `dm_info` for `CONTENT_SERVICE_URL` to dynamically resolve asset paths (`bc_all_future_orders.prg:521-571`):

```ccl
; Collect the content service URL for dynamic asset paths
select into "nl:"
from dm_info d
plan d
    where d.info_domain = "INS"
    and d.info_name = "CONTENT_SERVICE_URL"
head report
    rCustom->content_service_url = trim(d.info_char)
with counter
```

The URL is then parsed to extract:
- `webshere_host` - e.g., `https://lb-wodr-phsacd-nonprod-0.phsacd.ohaihs.com`
- `fully_qualified_domain` - e.g., `e0783.phsacd.ohaihs.com`

---

## Angular Service Layer

### FutureorderService

**Location**: `src/app/service/futureorder.service.ts`

#### Key Properties and Getters

| Property/Getter | Type | Description |
|-----------------|------|-------------|
| `futureOrdersLoaded` | boolean | Whether CCL data has loaded |
| `futureOrders` | any[] | Order list for TreeTable display |
| `providerList` | any[] | Unique providers for filter dropdown |
| `orderingList` | any[] | Unique locations for filter dropdown |
| `orderCounts` | any | Counts by order type (lab, cardiology, radiology) |
| `supportToolEndabled` | boolean | Whether support tools are available |
| `activateButtonEndabled` | boolean | Whether user can activate orders |
| `assetBaseUrl` | string | Dynamic base URL for image assets |

#### Asset URL Computation

```typescript
// futureorder.service.ts:131-137
public get assetBaseUrl(): string {
  if (this.webshereHost && this.fullyQualifiedDomain) {
    return `${this.webshereHost}/mpage-content/${this.fullyQualifiedDomain}/custom_mpage_content/cst-future-orders-edge/assets`;
  }
  return '';
}
```

---

## UI Components

### Orders Table Component

**Location**: `src/app/component/orders-table/`

#### Features

1. **Time Filter Toolbar**
   - Lookback/Lookforward number inputs
   - Unit dropdowns (Months, Weeks, Days)
   - Persists to `dm_info` with domain `'CST Future Order Mpage'`

2. **Filter Dropdowns**
   - Specimen Type (Blood/Non-Blood)
   - Provider (populated from CCL response)
   - Ordering Location (populated from CCL response)

3. **Order Search**
   - Global text search across order mnemonics

4. **Typical Labs Checkbox**
   - Filters orders to common lab specimen types

5. **Order Type Tabs**
   - Labs tab with count badge
   - Cardiology tab with count badge

6. **TreeTable Display**
   - Grouped by Provider + Start Date
   - Child rows show individual orders
   - Selection checkboxes for activation
   - Visual indicators for PowerPlans and comments

7. **Activate Button**
   - Visible for authorized positions
   - Uses `PowerOrdersMPageUtils` for order activation

#### User Preference Persistence

```typescript
// orders-table.component.ts:75-85
this.customService.executeDmInfoAction('timeFilterPref', 'w', [
  {
    infoDomain: 'CST Future Order Mpage',
    infoName: 'timeFilters',
    infoDate: new Date(),
    infoChar: JSON.stringify(this.timefilters),
    infoNumber: 0,
    infoLongText: '',
    infoDomainId: this.mPage.prsnlId
  }
]);
```

#### Order Activation Flow

```typescript
// orders-table.component.ts:355-378
InvokeActivateActionPromise(orders: any, activateDate: string) {
  window.external.DiscernObjectFactory("POWERORDERS").then((PowerOrdersMPagesUtils) => {
    PowerOrdersMPagesUtils.CreateMOEW(this.mPage.personId, this.mPage.encntrId, 0, 2, 127).then((m_hMOEW: any) => {
      const activatePromises = orders.map((ord: any) => {
        if (ord.data.orderId > 0) {
          return PowerOrdersMPagesUtils.InvokeActivateAction(m_hMOEW, ord.data.orderId, activateDate);
        }
        return Promise.resolve();
      });

      Promise.all(activatePromises).then(() => {
        return PowerOrdersMPagesUtils.SignOrders(m_hMOEW).then(() => {
          PowerOrdersMPagesUtils.DestroyMOEW(m_hMOEW);
          this.tableRefresh(vLookback, vLookforward, this.orderType);
        });
      });
    });
  });
}
```

---

## Build and Deployment

### Development Commands

```bash
# Start development server
ng serve

# Production build with concatenation
ng build --configuration production && node concat.js

# Development build with watch
ng build --watch --configuration development

# Run tests
ng test
```

### Build Process

1. Angular production build creates `dist/cst-future-orders-edge/`
2. `concat.js` merges `runtime.js`, `main.js`, and `polyfills.js` into single `cst-future-orders-edge.js`
3. `baseHref` is set to `./index.html` for Cerner compatibility
4. `outputHashing` is disabled for consistent file names

### Proxy Configuration

**Location**: `src/proxy.conf.json`

```json
{
  "/cclproxy/*": {
    "target": "http://phsacdeanp.cerncd.com/discern/b0783.phsa_cd.cerncd.com/mpages/reports",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug",
    "pathRewrite": {
      "^/cclproxy": ""
    }
  }
}
```

To configure for your environment:
1. Run `1co_show_service_dir` in Discern Visual Developer
2. Replace the `target` value with the returned `cclproxy` URL

---

## UI Framework Stack

### Angular Material
- Luxon date adapter with custom format: `dd-MMM-yyyy`
- Theme defined in `src/theme.scss`
- Uses `NoopAnimationsModule`

### PrimeNG Components Used
- `TreeTableModule` - Hierarchical order display
- `ButtonModule` - Action buttons
- `DropdownModule` - Filter dropdowns
- `InputTextModule` - Search and number inputs
- `ToolbarModule` - Filter bar layout
- `TooltipModule` - Order hover information
- `CheckboxModule` - Typical labs filter

---

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@clinicaloffice/clinical-office-mpage-core` | >=0.0.1 | Cerner MPage integration |
| `@angular/elements` | ^16.0.0 | Web Component creation |
| `@angular/material` | ^16.0.0 | Material UI components |
| `@angular/material-luxon-adapter` | ^16.0.0 | Date handling |
| `primeng` | ^16.4.4 | UI components |
| `primeflex` | ^4.0.0 | CSS utilities |
| `luxon` | ^3.3.0 | Date/time manipulation |
| `fast-sort` | ^3.4.0 | Array sorting |

---

## Troubleshooting

### Common Issues

**Issue**: Component not loading in Cerner
- **Solution**: Verify Edge mode is enabled in Cerner preferences; this component does not work in Internet Explorer

**Issue**: CCL script not returning data
- **Solution**: Check that `bc_all_future_orders:group1` is compiled and the configuration JSON files exist in `cust_script:`

**Issue**: Images not displaying
- **Solution**: Verify `CONTENT_SERVICE_URL` is configured in `dm_info` with `info_domain = "INS"`

**Issue**: Activate button not visible
- **Solution**: User's position code must be in `bc_all_future_orders_positions.json`

**Issue**: Development proxy not connecting
- **Solution**: Update `src/proxy.conf.json` target URL using `1co_show_service_dir` output

---

## Related Scripts

| Script | Purpose |
|--------|---------|
| `bc_all_future_orders:group1` | Main data retrieval |
| `bc_all_all_date_routines` | Date formatting utilities |
| `bc_all_future_ord_lb_set` | Order activation helper |
| `bc_cmc_test` | Order field modification |
| `bc_all_future_ord_support_tool` | Support tools report |
