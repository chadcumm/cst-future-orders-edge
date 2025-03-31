import { Injectable } from '@angular/core';
import { CustomService } from '@clinicaloffice/clinical-office-mpage-core';

@Injectable({
  providedIn: 'root'
})
export class FutureorderService {

  public FutureOrdersLoading: boolean = false;
  public LastRefesh: string = "";
  public refresh = false;
  public isLoaded = false;

  constructor(
      private futureOrderService: CustomService
      
      ) { }

  public loadFutureOrders(lookback?:string, lookforward?:string, orderType?:number ): void{
    this.FutureOrdersLoading = true;
    this.isLoaded = false;

    console.log(`loadFutureOrders: ${lookback} and ${lookforward} for orderType=${orderType}`)
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
              'orderType' : orderType
            }
          }
        ]
      }
    }, undefined, (() => { 
      this.FutureOrdersLoading = false 
      this.LastRefesh = this.futureOrderService.get('futureorders').lastrefesh
      this.refresh = true;
      this.isLoaded = true;
    }));
  }

  //Returns Provider Data
  public get providerList(): any[]  {
    //console.log(this.futureOrderService.get('futureorders'))
    return this.futureOrderService.get('futureorders').providerList
    //return(this.orderJSON[0].orderList)
  }

  //Returns Ordering Location Data
  public get orderingList(): any[]  {
      //console.log(this.futureOrderService.get('futureorders'))
      return this.futureOrderService.get('futureorders').ordLocationList
      //return(this.orderJSON[0].orderList)
  }

  //Returns Orders Data
  public get futureOrders(): any[]  {
    //console.log(this.futureOrderService.get('futureorders'))
    return this.futureOrderService.get('futureorders').orderList
    //return(this.orderJSON[0].orderList)
  }

  // Determine if Future Ordres have been loaded
  public get futureOrdersLoaded(): boolean {
    return this.futureOrderService.isLoaded('futureorders');
    //return this.isLoaded
    //return true;
  }

  //Returns Orders Data
  public get orderCounts(): any[]  {
    //console.log(this.futureOrderService.get('futureorders'))
    return this.futureOrderService.get('futureorders').counts
    //return(this.orderJSON[0].orderList)
  }

   //Returns Support Tool Indicated
   public get supportToolEndabled(): boolean  {
    //console.log(this.futureOrderService.get('futureorders').supportToolInd)
    if (this.futureOrderService.get('futureorders').supportToolInd == 'true') {
        return true
    } else {
        return false
    }
  }

  //Returns Support Tool Indicated
  public get activateButtonEndabled(): boolean  {
    //console.log(this.futureOrderService.get('futureorders').supportToolInd)
    if (this.futureOrderService.get('futureorders').activateButtonInd == 'true') {
        return true
    } else {
        return false
    }
  }

       //Returns Support Tool Indicated
   public get liveEnabled(): boolean  {
    //console.log(this.futureOrderService.get('futureorders').supportToolInd)
    if (this.futureOrderService.get('futureorders').liveInd == 'false') {
        return true
    } else {
        return false
    }
  }

    public get supportMessage(): string {
      return this.futureOrderService.get('futureorders').supportMessage
    }
    
    //return this.futureOrderService.get('futureorders').supportToolInd
    //return(this.orderJSON[0].orderList)

}
