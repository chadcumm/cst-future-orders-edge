# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Clinical Office:MPage Edition** application for displaying future orders in Cerner/Oracle Health environments. It's an Angular 16+ application that runs exclusively in Microsoft Edge WebView (not Internet Explorer compatible) and integrates with the Cerner Component Framework in Edge mode.

The application is deployed as a **Web Component** (`<cst-future-orders-edge>`) using Angular Elements, allowing it to be embedded within Cerner's MPage framework.

## Critical Requirements

- **License Required**: A valid Clinical Office:MPage Edition license must be configured on the development machine for the project to compile
- **Runtime Environment**: Only works with Microsoft Edge WebView controller; fails in Internet Explorer
- **Cerner Integration**: Must have Cerner preferences set to Edge mode

## Development Commands

### Development Server
```bash
ng serve
```
- Runs on `http://localhost:4200/`
- Angular Proxy is enabled by default via `src/proxy.conf.json`
- Allows real-time development with live Cerner data without recompiling
- **Important**: Development machine must be able to access Discern MPage web services

### Build
```bash
ng build --configuration production && node concat.js
```
- Production build with post-processing concatenation step
- `concat.js` merges `runtime.js`, `main.js`, and `polyfills.js` into single `cst-future-orders-edge.js` bundle
- Output goes to `dist/cst-future-orders-edge/`
- `baseHref` is set to `./index.html` for Cerner compatibility
- `outputHashing` is disabled (`none`) for consistent file names

### Development Build (watch mode)
```bash
ng build --watch --configuration development
```

### Testing
```bash
ng test
```
- Uses Karma test runner with Jasmine
- 7 spec files in the codebase

### Component Generation
```bash
ng generate component component-name
ng generate directive|pipe|service|class|guard|interface|enum|module
```

## Architecture

### Web Component Architecture

The application uses **Angular Elements** to create a custom web component:

1. **Bootstrap**: `AppModule` uses `ngDoBootstrap()` instead of traditional bootstrap
2. **Custom Element**: Creates `<cst-future-orders-edge>` custom element (app.module.ts:86-98)
3. **Shadow DOM**: Component explicitly logs "Component using ShadowDOM" (app.component.ts:45)
4. **Encapsulation**: Uses `ViewEncapsulation.None` to allow styles to work with Cerner framework

### Cerner Integration Points

**MPage Service Integration**:
- Query parameters: `personId`, `encounterId`, `userId` are parsed from URL and assigned to mPage service (app.component.ts:35-39)
- `mPage.setMaxInstances(2, true, 'CHART', false)` configures instance limits (app.component.ts:43)
- All initialization must occur within `setTimeout(..., 0)` wrapper (app.component.ts:42-49)

**CCL Script Execution**:
- Uses `CustomService` to execute CCL scripts via `bc_all_future_orders:group1` (futureorder.service.ts:26-38)
- Script parameters: `lookback`, `lookforward`, `orderType`
- Script returns: `providerList`, `ordLocationList`, `orderList`, `counts`, configuration flags

**Data Persistence**:
- Uses `executeDmInfoAction` to persist user preferences (orders-table.component.ts:75-80)
- Domain: `'CST Future Order Mpage'`
- Stores time filter preferences as JSON

### Proxy Configuration

The `src/proxy.conf.json` proxies `/cclproxy/*` requests to Cerner servers. To configure:

1. Run `1co_show_service_dir` in Discern Visual Developer in your Cerner dev environment
2. Replace the `target` value with the `cclproxy` value returned
3. Current example: `http://phsacdeanp.cerncd.com/discern/b0783.phsa_cd.cerncd.com/mpages/reports`

### UI Framework Stack

**Angular Material**:
- Luxon date adapter configured with custom date format: `dd-MMM-yyyy` (app.module.ts:29-40)
- Material theme defined in `src/theme.scss` (editable via https://materialtheme.arcsine.dev)
- Uses `NoopAnimationsModule` (no animations)

**PrimeNG**:
- Primary UI library for data tables and components
- TreeTable component for hierarchical order display
- Other components: Button, Tooltip, InputText, Dropdown, Toolbar, Checkbox, Accordion, TabView
- PrimeFlex for layout utilities
- Requires `p-component` class on host element (app.component.ts:18)

### Component Structure

```
src/app/
├── app.component.ts          # Root component, handles mPage initialization
├── app.module.ts             # Main module with Web Component setup
├── app-routing.module.ts     # Routing config (useHash: true for Cerner)
├── component/
│   └── orders-table/         # Main orders display component
│       ├── orders-table.component.ts
│       ├── orders-table.component.html
│       └── orders-table.component.scss
└── service/
    └── futureorder.service.ts # CCL script execution and data management
```

### Styling

- Global styles: `src/styles.scss`
- Material theme: `src/theme.scss`
- Styles are bundled separately as `styles.css` and `material-theme.css`
- Both imported by app component (app.component.ts:14)

### TypeScript Configuration

- Target: ES2022
- Strict mode enabled with exceptions:
  - `strictNullChecks: false` (angular compiler option)
- Uses experimental decorators
- Angular strict templates enabled

## Key Dependencies

- `@clinicaloffice/clinical-office-mpage-core`: Core Cerner MPage integration library
- `@angular/material` + `@angular/material-luxon-adapter`: Material UI with Luxon dates
- `primeng` + `primeflex` + `primeicons`: PrimeNG component library
- `luxon`: Date/time manipulation
- `fast-sort`: Sorting utilities
- `concat` + `fs-extra`: Build-time file concatenation

## File Naming Conventions

- Components: `kebab-case.component.ts`
- Services: `kebab-case.service.ts`
- All have corresponding `.spec.ts` test files
- SCSS styling (configured in angular.json:10)
