import { ChangeDetectionStrategy, Component, HostListener, OnInit, ViewChild, ViewEncapsulation } from '@angular/core';
import { ActivatedRoute } from "@angular/router";
import { mPageLogComponent, mPageService, EncounterService, PersonService } from '@clinicaloffice/clinical-office-mpage-core';
import { CUSTOM_DATE_FORMATS } from './app.module';
import { ButtonModule } from 'primeng/button';
import { FutureorderService } from './service/futureorder.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['../theme.scss', '../styles.scss'],
  providers: [FutureorderService],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.ShadowDom
})
export class AppComponent implements OnInit {

  @ViewChild(mPageLogComponent) activityLog!: mPageLogComponent

  constructor(
    public activatedRoute: ActivatedRoute,
    public mPage: mPageService,
    public futureOrdersService: FutureorderService,
    public encounterService: EncounterService,
    public personService: PersonService
  ) {

  }

  ngOnInit(): void {
    // Grab any parameters in the URL (Used in Cerner Components)
    this.activatedRoute.queryParams.subscribe(params => {
      this.mPage.personId = params['personId'] ? parseInt(params['personId']) : this.mPage.personId;
      this.mPage.encntrId = params['encounterId'] ? parseInt(params['encounterId']) : this.mPage.encntrId;
      this.mPage.prsnlId = params['userId'] ? parseInt(params['userId']) : this.mPage.prsnlId;
    });

    // Perform MPage Initialization
    setTimeout((e: any) => {
      this.mPage.setMaxInstances(2, true, 'CHART', false);

      this.mPage.putLog('Component using ShadowDOM');

      // Add your initialization code here - do not place outside setTimeout function
      this.futureOrdersService.loadFutureOrders();
    }, 0);
  }

}
