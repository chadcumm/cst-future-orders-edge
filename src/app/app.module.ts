import { NgModule, ErrorHandler, Injector,  CUSTOM_ELEMENTS_SCHEMA, APP_INITIALIZER} from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ClinicalOfficeMpageModule, MaterialModule, ErrorHandlerService, ConfigService } from '@clinicaloffice/clinical-office-mpage-core'
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { MatLuxonDateModule, LuxonDateAdapter } from '@angular/material-luxon-adapter';
import { DateAdapter, MAT_DATE_FORMATS, MAT_DATE_LOCALE } from '@angular/material/core';
import { MAT_FORM_FIELD_DEFAULT_OPTIONS } from '@angular/material/form-field';
import { createCustomElement } from '@angular/elements';
import { ButtonModule } from 'primeng/button';
import { OrdersTableComponent } from './component/orders-table/orders-table.component';
import { TreeTableModule } from 'primeng/treetable';
import { TooltipModule } from 'primeng/tooltip';

export const configFactory = (configService: ConfigService) => {
  return () => configService.loadConfig();
}

// Custom date formats
export const CUSTOM_DATE_FORMATS = {
  parse: {
    dateInput: ['dd-MMM-yyyy'],
  },
  display: {
    dateInput: 'dd-MMM-yyyy',
    dateTimeLabel: 'dd-MMM-yyyy HH:mm',
    monthYearLabel: 'MMM yyyy',
    dateA11yLabel: 'LL',
    monthYearA11yLabel: 'MMMM yyyy',
  }
}

@NgModule({
  declarations: [
    AppComponent,
    OrdersTableComponent
  ],
  imports: [
    BrowserModule,
    NoopAnimationsModule,
    ClinicalOfficeMpageModule,
    MaterialModule,
    AppRoutingModule,
    FormsModule,
    ReactiveFormsModule,
    MatLuxonDateModule,
    ButtonModule,
    TreeTableModule,
    TooltipModule
  ],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: configFactory,
      deps: [ConfigService],
      multi: true
    },
    { provide: ErrorHandler, useClass: ErrorHandlerService },
    { provide: DateAdapter, useClass: LuxonDateAdapter, deps: [MAT_DATE_LOCALE] },
//    { provide: MAT_FORM_FIELD_DEFAULT_OPTIONS, useValue: { appearance: 'outline' } },
    {
      provide: MAT_DATE_FORMATS, useValue: CUSTOM_DATE_FORMATS
    }
  ]
//  bootstrap: [AppComponent]
})
export class AppModule {

  constructor(private injector: Injector) {}

  ngDoBootstrap() {
    const element = createCustomElement(AppComponent, {
      injector: this.injector
    });
    
    if (!customElements.get('cst-future-orders-edge')) {
      customElements.define('cst-future-orders-edge', element);
    }
  }

}
