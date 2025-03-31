import {  ChangeDetectionStrategy, 
  Component, 
  OnInit, 
  //DoCheck, 
  //ChangeDetectorRef, 
  ViewChild,
  AfterViewInit
 } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';
import { FutureorderService } from 'src/app/service/futureorder.service';
import { TreeNode,PrimeIcons,FilterService } from 'primeng/api';
import { ThisReceiver } from '@angular/compiler';
import { TreeTable, TTBody } from 'primeng/treetable';
import { MpageArrayInputComponent, mPageService, CustomService } from '@clinicaloffice/clinical-office-mpage-core';
import { JsonPipe } from '@angular/common';
import { DropdownChangeEvent } from 'primeng/dropdown';

interface Specimens {
label: string,
value: string 
}

interface LookOptions {
label: string,
value: string 
}

interface TimeFilters {
lookbackNumber: number,
lookbackOption: LookOptions,
lookforwardNumber: number,
lookforwardOption: LookOptions
}

@Component({
selector: 'app-orders-table',
templateUrl: './orders-table.component.html',
styleUrls: ['./orders-table.component.scss']
})


export class OrdersTableComponent implements OnInit, AfterViewInit {

@ViewChild("tt") treetable!: TreeTable;
@ViewChild("specimenInput") specimenInput!: any;
@ViewChild("providerInput") providerInput!: any;
@ViewChild("locationInput") locationInput!: any;

timeFilterGroup = new FormGroup({selLookback: new FormControl()});

TypicalLabs($event:any) :void {
//console.log("TypicalLabs")
//console.log($event) 
if ($event.checked == true) {
//console.log("checked - show common")
this.treetable.filter('true','typicalLab','equals')
} else {
//console.log("unchecked - show all")
this.treetable.filter('true','typicalLab','contains')
}
}

TimeFilter($event:any) :void {
//console.log("Time Filter")
this.timefilters = [
{'lookbackNumber': this.lookbackNumber,
'lookbackOption': this.selectedLookback,
'lookforwardNumber': this.lookforwardNumber,
'lookforwardOption': this.selectedLookforward}
]

console.log(JSON.stringify(this.timefilters[0]))


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

let vLookback = `${this.lookbackNumber},${this.selectedLookback.value}`
let vLookforward = `${this.lookforwardNumber},${this.selectedLookforward.value}`
//console.log(`going to table refresh with ${vLookback} and ${vLookforward}`)
this.tableRefresh(vLookback,vLookforward,this.orderType)
}


cols!: any[];
level: number = 0;
specimens: Specimens[] = [];
loobackOptions: LookOptions[] = [];
lookbackNumber: number = 1;

lookforwardOptions: LookOptions[] = [];
lookforwardNumber: number = 1;

timefilters: TimeFilters[] = [];

expanded: boolean = false;

orderCounts!: any

selectedSpecimen!: Specimens
selectedProvider!: any
selectedLocation!: any
selectedLookback!: LookOptions
selectedLookforward!: LookOptions

typicalLab: boolean = true;

loading: boolean = false;

files!: TreeNode[];

selectedOrders: any[] = [];

orderType: number = 0;

constructor(
public futureOrderDS: FutureorderService,
//public cdr: ChangeDetectorRef,
public filterService: FilterService,
public mPage: mPageService,
public customService: CustomService
) { 

this.specimens = [
{label: "Blood", value:"blood"},
{label: "Non-Blood", value:"nonblood"}
]

this.loobackOptions = [
{label: "Months", value: 'M'},
{label: "Weeks", value: 'W'},
{label: "Days", value: 'D'}
]

this.lookforwardOptions = [
{label: "Months", value: 'M'},
{label: "Weeks", value: 'W'},
{label: "Days", value: 'D'}
]

this.cols = [

{ field: 'orderMnemonic', header: 'Order' , sort: false},
//{ field: 'orderingProvider', header: 'Provider', width: '150px', sort: false },
{ field: 'orderingLocation', header: 'Ordering Location' , width: '170px', sort: false},
{ field: 'origOrderDateVc', header: 'Order Date', width: '170px', sort: false },
{ field: 'note.marker', header: 'Lab Req Note', width: '120px', sort: true },
{ field: 'orderDetails', header: 'Details', sort: true },
];
}
ngAfterViewInit(): void {
console.log("support="+this.futureOrderDS.supportToolEndabled)
console.log("activateButton="+this.futureOrderDS.activateButtonEndabled)
this.treetable.filter('true','typicalLab','equals')
}

ngDoCheck(): void {  
if (this.futureOrderDS.refresh === true) {
setTimeout(() => {
this.futureOrderDS.refresh = false;
});
//this.cdr.detectChanges();
}

}

ngOnInit(): void {


this.files = this.futureOrderDS.futureOrders
this.orderCounts = this.futureOrderDS.orderCounts
this.loading = false;


this.customService.executeDmInfoAction('timeFilterPref', 'r', [
{
  infoDomain: 'CST Future Order Mpage',
  infoName: 'timeFilters',
  infoDate: new Date(),
  infoChar: '',
  infoNumber: 0,
  infoLongText: '',
  infoDomainId: this.mPage.prsnlId
}
], () => { this.useTimeFilterCallback() });

//console.log(this.files)
}


useTimeFilterCallback(): void {
if (this.customService.isLoaded('timeFilterPref')) {
this.timefilters = JSON.parse(this.customService.get('timeFilterPref').dmInfo[0].infoChar)

//console.log(JSON.stringify(this.timefilters))

this.selectedLookforward = this.timefilters[0].lookforwardOption//{label: 'Weeks', value: 'weeks'}
this.selectedLookback = this.timefilters[0].lookbackOption
this.lookbackNumber = this.timefilters[0].lookbackNumber
this.lookforwardNumber = this.timefilters[0].lookforwardNumber

let vLookback = `${this.lookbackNumber},${this.selectedLookback.value}`
let vLookforward = `${this.lookforwardNumber},${this.selectedLookforward.value}`
console.log(`going to table refresh with ${vLookback} and ${vLookforward}`)
this.tableRefresh(vLookback,vLookforward,this.orderType)
}
}

tabChange(event: any): void {

//console.log(`tabChange: ${event}`)
//console.log(event)
//TO-DO Need to clear all filters when switching tabs
//To-DO need to clear out the list of selected orders after activate. 

//this.treetable.filter('', 'specimenType', 'notEquals')
//this.treetable.filter('', 'orderingProvider', 'notEquals')
//this.treetable.filter('', 'orderingLocation', 'notEquals')
//this.selectedLocation = '';
//this.selectedProvider = '';
//this.selectedSpecimen = {label: '', value:''};

this.specimenInput.clear();
this.locationInput.clear();
this.providerInput.clear();

let vLookback = `${this.lookbackNumber},${this.selectedLookback.value}`
let vLookforward = `${this.lookforwardNumber},${this.selectedLookforward.value}`
this.orderType = event
if (this.orderType == 1) {
this.typicalLab = false;
this.treetable.filter('true','typicalLab','contains')
} else {
this.typicalLab = true;
this.treetable.filter('true','typicalLab','equals')
}

this.tableRefresh(vLookback,vLookforward,this.orderType)

}

tableRefresh(lookback?:string, lookforward?:string, orderType?:number): void{
this.loading = true;
this.files = [];
this.futureOrderDS.refresh = true
this.futureOrderDS.loadFutureOrders(lookback,lookforward,orderType)
if (this.futureOrderDS.refresh == true) {
setTimeout(() => {
this.futureOrderDS.refresh = false;
this.files = [...this.futureOrderDS.futureOrders];
this.orderCounts = this.futureOrderDS.orderCounts
//.log(this.futureOrderDS.LastRefesh)
//console.log(this.files)
//this.cdr.detectChanges();
this.loading = false;
}, 1500);
}

}

_window() {
return window;
}

activaterOrders($event:any) :void {
console.log($event) 
this.mPage.putLog(`ActivateOrders Started`)
console.log(this.selectedOrders)
console.log(this.mPage.encntrId)
//need to add in updates to order details

for (let ord of this.selectedOrders) {
if (ord.data.hiddenData.needLabCollection == 1) {
  //window.alert("needs collection flipped")
  // @ts-ignore
  var OEFRequest = window.external.XMLCclRequest();						
  OEFRequest.open("GET","bc_cmc_test",false);
  OEFRequest.send("~MINE~,"+ord.data.orderId+",~NURSECOLLECT~")
}
}

for (let ord of this.selectedOrders) {
if (ord.data.hiddenData.needDateUpdate == 1) {
// window.alert("needs collection date time updated")
// @ts-ignore
var OEFRequest = window.external.XMLCclRequest();						
OEFRequest.open("GET","bc_cmc_test",false);
OEFRequest.send("~MINE~,"+ord.data.orderId+",~COLLECTIONDATE~")
}
}


var d=new Date();
var twoDigit=function(num: string | number){(String(num).length<2)?num=String("0"+num):num=String(num);
return num;
};
var activateDate=""+d.getFullYear()+twoDigit((d.getMonth()+1))+twoDigit(d.getDate())+twoDigit(d.getHours())+twoDigit(d.getMinutes())+twoDigit(d.getSeconds())+"99";
console.log(activateDate)
// @ts-ignore
var PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS");
var hMoew = null;
hMoew = PowerOrdersMPageUtils.CreateMOEW(this.mPage.personId, this.mPage.encntrId, 0, 2, 127)

for (let ord of this.selectedOrders) {

if (ord.data.orderId > 0) {
this.mPage.putLog(`Order ID: ${ord.data.orderId}`)
this.mPage.putLog("~MINE~,"+ord.data.orderId+","+this.mPage.encntrId+","+ord.data.hiddenData.needLabCollection+","+ord.data.hiddenData.needDateUpdate) 
//console.log("~MINE~,"+ord.data.orderId+","+this.mPage.encntrId+","+ord.data.hiddenData.needLabCollection+","+ord.data.hiddenData.needDateUpdate) 
// @ts-ignore
var OEFRequest = window.external.XMLCclRequest();						
OEFRequest.open("GET","bc_all_future_ord_lb_set",false);
OEFRequest.send("~MINE~,"+ord.data.orderId+","+this.mPage.encntrId+","+ord.data.hiddenData.needLabCollection+","+ord.data.hiddenData.needDateUpdate)

var success=PowerOrdersMPageUtils.InvokeActivateAction(hMoew,ord.data.orderId,activateDate);
}
}

if(success){
PowerOrdersMPageUtils.SignOrders(hMoew);   
let vLookback = `${this.lookbackNumber},${this.selectedLookback.value}`
let vLookforward = `${this.lookforwardNumber},${this.selectedLookforward.value}` 
this.tableRefresh(vLookback,vLookforward,this.orderType)
}

this.selectedOrders = [];
this.mPage.putLog("Ending ActivateOrders")
PowerOrdersMPageUtils.DestroyMOEW(hMoew);
}   




logChange($event:any) :void {
console.log($event) 
console.log("logChange")
} 

rowClick(node:any) :void {
//console.log("start rowclick")
//console.log(node) 
//console.log(this.selectedOrders)
this.treetable.toggleNodeWithCheckbox(node)
//console.log("end rowclick")
} 

toggleVisibility(isChecked: boolean)
{
console.log(isChecked);
}

exapandNodes(nodes: any, event?: any) {
/*if (event.value.value === "") {
console.log("empty")
}*/

console.log(event); 

for(let node of nodes) 
{ 
if (node.children) {
  node.expanded = true;
for (let cn of node.children) {
    this.exapandNodes(node.children);
}
}
}
}

collapseNodes1(nodes: any, event?: any) {
/*if (event.value.value === "") {
console.log("empty")
}*/

console.log(event); 

for(let node of nodes) 
{ 
if (node.children) {
node.expanded = false;
for (let cn of node.children) {
  this.exapandNodes(node.children);
}
}
}
}

onExpandOneLevel() {
console.log(this.files);
if (this.expanded === false) {
if (this.level === 0) {
this.expandNodes(this.files);
} else {
this.traverse(
this.files,
(o, prop, value) => {
if (prop === "children") {
  this.expandNodes(value);
}
},
this.level
);
}

this.level++;
this.files = [...this.files];
this.expanded = true
}
}

onCollapseOneLevel() {

console.log(this.files);

if (this.expanded === true) {

this.level--;

if (this.level === 0) {
this.collapseNodes(this.files);
} else {
this.traverse(
this.files,
(o, prop, value) => {
if (prop === "children") {
  this.collapseNodes(value);
}
},
this.level
);
}

this.files = [...this.files];
this.expanded = false;
}

}

expandNodes(nodes: TreeNode<any>[]) {
for (let node of nodes) {

node.expanded = true;

}
}

collapseNodes(nodes: TreeNode<any>[]) {
for (let node of nodes) {
node.expanded = false;
}
}

traverse(
o: any,
fn: (obj: any, prop: string, value: any) => void,
maxLvl: number,
currentLvl: number = 0
) {
if (currentLvl > maxLvl) return;

for (const i in o) {
fn.apply(this, [o, i, o[i]]);

if (o[i] !== null && typeof o[i] === "object") {
let currentNew = currentLvl + 1;
this.traverse(o[i], fn, maxLvl, currentNew);
}
}
}

rowTrackBy(index:number, row:any){
if(row.node.data.id){
return row.node.data.id;
}else{
return row.node.data.title;
}
}

onNodeExpand(event: any) {
//console.log(event.node.children)
//this.expandNodes(event.node.children)
this.onExpandThisLevel(event.node)
}

onExpandThisLevel(event: any) {

//if (this.expanded === false) {
if (this.level === 2) {
console.log("expanded")
this.expandNodes(this.files);
} else {
console.log("traverse")
this.traverse(
this.files,
(o, prop, value) => {
if (prop === "children") {
  this.expandNodes(value);
}
},
this.level
);
}

this.level++;
this.files = [...this.files];
this.expanded = true
}
//}

OpenSupportTools(event: any) {
console.log("starging OpenSupportTools")

const el = document.getElementById('applink');
// @ts-ignore
el.href = "javascript:APPLINK(0,'discernreportviewer.exe','/PARAMS=%22MINE%22 /PROGRAM=bc_all_future_ord_support_tool /LEFT=100 /TOP=100 /WIDTH=1024 /HEIGHT=800')"
// @ts-ignore
el.click();
}

filterSpecimen(event: any): void {
  this.treetable.filter(event.value, 'specimenType', 'equals');
}

filterProvider(event: any): void {
  this.treetable.filter(event.value, 'orderingProvider', 'equals');
}

filterLocation(event: any): void {
  this.treetable.filter(event.value, 'orderingLocation', 'equals');
}

}