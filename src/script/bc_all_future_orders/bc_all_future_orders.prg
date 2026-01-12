/*************************************************************************
 
        Script Name:    1co_mpage_template.prg
 
        Description:    Clinical Office - mPage Edition
                        Custom CCL Pre/Post Blank Template
 
        Date Written:   May 7, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1co_mpage_entry. Do not attempt to run stand alone. If you
 wish to test the development of your custom script from the CCL back-end,
 please run with 1co_mpage_test.
 
 Possible Payload values:
 
    "customScript": {
        "script": [
            "name": "your custom script name:GROUP1",
            "id": "identifier for your output, omit if you won't be returning data",
            "run": "pre or post",
            "parameters": {
                "your custom parameters for your job"
            }
        ],
        "clearPatientSource": true
    }
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    05/07/18 J. Simpson     Initial Development
 002    05/07/23 C. Cummings    Future Order Mpage Updates
 *************************************************************************/
drop program bc_all_future_orders:group1 go
create program bc_all_future_orders:group1
 
/*
	The parameters for your script are stored in the PAYLOAD record structure. This
	structure contains the entire payload for the current CCL execution so parameters
	for other Clinical Office jobs may be present (e.g. person, encounter, etc.).
 
	Your payload parameters are stored in payload->customscript->script[script number].parameters.
 
	The script number for your script has been assigned to a variable called nSCRIPT.
 
	For example, if you had a parameter called fromDate in your custom parameters for your script
	you would access it as follows:
 
	set dFromDate = payload->customscript->script[nscript]->parameters.fromdate
 
	**** NOTE ****
	If you plan on running multiple pre/post scripts in the same payload, please ensure that
	you do not have the same parameter with different data types between jobs. For example, if
	you ran two pre/post jobs at the same time with a parameter called fromDate and in one job
	you passed a valid JavaScript date such as  "fromDate": "2018-05-07T14:44:51.000+00:00" and
	in the other job you passed "fromDate": "05-07-2018" the second instance of the parameter
	would cause an error.
*/
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; This is the point where you would add your custom CCL code to collect data. If you did not
; choose to clear the patient source, you will have the encounter/person data passed from the
; mpage available for use in the PATIENT_SOURCE record structure.
;
; There are two branches you can use, either VISITS or PATIENTS. The format of the
; record structure is:
;
; 1 patient_source
;	2 visits[*]
;		3 person_id			= f8
;		3 encntr_id			= f8
;	2 patients[*]
;		3 person_id			= f8
;
; Additionally, you can alter the contents of the PATIENT_SOURCE structure to allow encounter
; or person records to be available for standard Clinical Office scripts. For example, your custom
; script may collect a list of visits you wish to have populated in your mPage. Instead of
; manually collecting your demographic information, simply add your person_id/encntr_id combinations
; to the PATIENT_SOURCE record structure and ensure that the standard Clinical Office components
; are being called within your payload. (If this is a little unclear, please see the full
; documentation on http://www.clinicaloffice.com).
 
; ------------------------------------------------------------------------------------------------
;								BEGIN YOUR CUSTOM CODE HERE
; ------------------------------------------------------------------------------------------------
 
; Define the custom record structure you wish to have sent back in the JSON to the mPage. The name
; of the record structure can be anything you want but you must make sure it matches the structure
; name used in the add_custom_output subroutine at the bottom of this script.

execute bc_all_all_date_routines

free record rCustom
record rCustom (
	1 user_id						= f8
	1 position_cd					= f8
	1 activate_button_ind			= vc
    1 live_ind						= vc
    1 support_message				= vc
	1 support_tool_ind				= vc
	1 lastRefesh					= vc
	1 encounter_type				= vc
	1 encounter_location			= vc
	1 order_type					= i4
	1 order_type_meaning			= vc
	1 selected_catalog_type			= f8
	1 content_service_url			= vc
	1 webshere_host					= vc
	1 fully_qualified_domain		= vc
    1 ord_location_cnt				= i4
    1 ord_location_list[*]
     2 label						= vc
     2 value						= vc
    1 provider_cnt					= i4
    1 provider_list[*]
     2 label						= vc
     2 value						= vc
	1 counts
	 2 lab							= i2
	 2 cardiology					= i2
	 2 radiology					= i2
	 2 all							= i2
	1 order_cnt						= i4
	1 order_list[*]
	 2 data
	 		3 params					= vc
	 		3 lookback					= vc
	 		3 lookforward				= vc
			3 order_id					= f8
			3 catalog_cd				= f8
			3 template_order_id			= f8
			3 protocol_order_id			= f8
			3 order_mnemonic			= vc
			3 orig_order_date			= dq8
			3 orig_order_date_vc		= vc
			3 requested_start_date		= dq8
			3 requested_start_date_vc	= vc
			3 ordering_provider			= vc
			3 order_details				= vc
			3 ordering_location			= vc
			3 specimen_type				= vc
			3 orig_spec_type			= vc
			3 collection_priority		= vc
			3 grace_period				= vc
			3 catalog_type				= vc
			3 order_comment				= vc
			3 order_comment_ind			= i2
			3 nurse_collect_ind			= f8
			3 note		
			 4 lab_requisition			= vc
			 4 ind						= i2
			 4 marker					= vc
			3 powerplan
			 4 description				= vc
			 4 ind						= i2
			 4 dot_ind					= i2
			 4 dot_earliest_dt_tm		= dq8
			 4 pathway_id				= f8
			 4 pw_group_nbr				= f8
			 4 pathway_group_id			= f8
			 4 pw_cat_group_id			= f8
			3 hover_info				= vc
			3 hover_ind					= i2
			3 hidden_data
			 4 due_status_flag			= i2
			 4 row_class				= vc
			 4 need_lab_collect			= i2
			 4 need_date_update			= i2
			 4 specimen_type_cd			= f8
			3 lookback_month			= i2
			3 lookforward_month			= i2
			3 months					= f8
			3 typical_lab				= vc
	 2 expanded						= vc
	 2 children[*]
		3 expanded						= vc
		3 data
			4 order_id					= f8
			4 catalog_cd				= f8
			4 template_order_id			= f8
			4 protocol_order_id			= f8
			4 order_mnemonic			= vc
			4 orig_order_date			= dq8
			4 orig_order_date_vc		= vc
			4 requested_start_date		= dq8
			4 requested_start_date_vc	= vc
			4 ordering_provider			= vc
			4 order_details				= vc
			4 ordering_location			= vc
			4 specimen_type				= vc
			4 orig_spec_type			= vc
			4 collection_priority		= vc
			4 grace_period				= vc
			4 catalog_type				= vc
			4 order_comment				= vc
			4 order_comment_ind			= i2
			4 nurse_collect_ind			= f8
			4 note		
			 5 lab_requisition			= vc
			 5 ind						= i2
			 5 marker					= vc
			4 powerplan
			 5 description				= vc
			 5 ind						= i2
			 5 dot_ind					= i2
			 5 dot_earliest_dt_tm		= dq8
			 5 pathway_id				= f8
			 5 pathway_group_id			= f8
			 5 pw_group_nbr				= f8
			 5 pw_cat_group_id			= f8
			4 hover_ind					= i2
			4 hover_info				= vc
			4 lookback_month			= i2
			4 lookforward_month			= i2
			4 months					= f8
			4 typical_lab				= vc
			4 typical_lab2				= i2
			4 hidden_data
			 5 due_status_flag			= i2
			 5 row_class				= vc
			 5 need_lab_collection		= i2
			 5 need_date_update			= i2
			 5 specimen_type_cd			= f8
)

;remove once live
set rCustom->live_ind = "true"
;set rCustom->support_message = "This MPage is not yet enabled.  Need to add additional instructions here."
;go to exit_script

record t_rec
(
	1 files
	 2 records_attachment = vc
) with protect

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

declare ordCnt = i4 		with noconstant(0), protect 
declare pCnt = i4 			with noconstant(0), protect
declare iCnt = i4 			with noconstant(0), protect
declare oCnt = i4 			with noconstant(0), protect
declare tCnt = i4			with noconstant(0), protect
declare person_id = f8 		with noconstant(0), protect 
declare encntr_id = f8 		with noconstant(0), protect 
declare prsnl_id = f8 		with noconstant(0), protect 
declare position_cd = f8 	with noconstant(0), protect 
declare epr_reltn_cd = f8 	with noconstant(0) ,protect
declare lookforward = vc 	with noconstant("1,M"), protect
declare lookback = vc		with noconstant("1,M"), protect
declare months = f8			with noconstant(0.0), protect
declare earliest_dt_tm = dq8 with noconstant(0.0), protect


free define rtl3
define rtl3 is "cust_script:bc_all_future_orders_spec.json" 

free record common_lab_specimens 
record common_lab_specimens	
	(
		1 cnt = i2
		1 qual[*]
		 2 specimen_type = vc
		 2 specimen_type_cd = f8
	) 

select into "nl:"
from rtl3t r
where r.line > ""
head report 
	i = 0
detail
	if (cnvtreal(trim(r.line)) > 0.0)
		i += 1
		stat = alterlist(common_lab_specimens->qual,i)
		common_lab_specimens->qual[i].specimen_type_cd	= cnvtreal(trim(r.line))
		common_lab_specimens->qual[i].specimen_type = uar_get_code_display(common_lab_specimens->qual[i].specimen_type_cd)
	endif
foot report
	common_lab_specimens->cnt = i
with nocounter 

call echorecord(common_lab_specimens) 

free record nonlab_powerplans 
record nonlab_powerplans	
	(
		1 cnt = i2
		1 qual[*]
		 2 description = vc
		 2 pathway_id = f8
	) 

free define rtl3 
define rtl3 is "cust_script:bc_all_future_orders_pp.json" 

select into "nl:"
from rtl3t r
where r.line > ""
head report 
	i = 0
detail
	i += 1
	stat = alterlist(nonlab_powerplans->qual,i)
	nonlab_powerplans->qual[i].description	= trim(r.line)
foot report
	nonlab_powerplans->cnt = i
with nocounter 

free define rtl3 
define rtl3 is "cust_script:bc_all_future_orders_pp_id.json" 

select into "nl:"
from rtl3t r
where r.line > ""
head report 
	i = nonlab_powerplans->cnt
detail
	i += 1
	stat = alterlist(nonlab_powerplans->qual,i)
	nonlab_powerplans->qual[i].pathway_id	= cnvtreal(trim(r.line))
foot report
	nonlab_powerplans->cnt = i
with nocounter 

call echorecord(nonlab_powerplans)

free define rtl3
define rtl3 is "cust_script:bc_all_future_orders_positions.json" 

free record activate_positions 
record activate_positions	
	(
		1 cnt = i2
		1 qual[*]
		 2 position = vc
		 2 position_cd = f8
	) 

select into "nl:"
from rtl3t r
where r.line > ""
head report 
	i = 0
detail
	if (cnvtreal(trim(r.line)) > 0.0)
		i += 1
		stat = alterlist(activate_positions->qual,i)
		activate_positions->qual[i].position_cd	= cnvtreal(trim(r.line))
		activate_positions->qual[i].position = uar_get_code_display(activate_positions->qual[i].position_cd)
	endif
foot report
	activate_positions->cnt = i
with nocounter 

call echorecord(activate_positions) 
	
	
if (validate(payload->customscript->script[nscript]->parameters.lookback))
 if (payload->customscript->script[nscript]->parameters.lookback > " ")
	set lookback = payload->customscript->script[nscript]->parameters.lookback
 endif
endif

if (validate(payload->customscript->script[nscript]->parameters.lookforward))
 if (payload->customscript->script[nscript]->parameters.lookforward > " ")
	set lookforward = payload->customscript->script[nscript]->parameters.lookforward
 endif
endif

if (validate(payload->customscript->script[nscript]->parameters.orderType))
	set rCustom->order_type = payload->customscript->script[nscript]->parameters.orderType
endif


set rCustom->order_type_meaning = "GENERAL LAB" ; default

if (rCustom->order_type = 1)
	set rCustom->order_type_meaning = "CARDIOLOGY"
else
	set rCustom->order_type_meaning = "GENERAL LAB"
endif

set rCustom->selected_catalog_type = uar_get_code_by("MEANING",6000,rCustom->order_type_meaning)

declare _Memory_Reply_String_Temp = vc

set _Memory_Reply_String_Temp = _Memory_Reply_String

/*
select into "nl:"
from
	 orders o
	,encounter e
	,order_action oa
	,order_detail od1
	,prsnl p1
plan o
	where 	o.person_id 		= chart_id->person_id
	and   	o.order_status_cd 	in(
										value(uar_get_code_by("MEANING",6004,"FUTURE"))
									)
	and		o.catalog_type_cd	in(
										value(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
									)
	and 	o.active_ind 		= 1
join e
	where 	e.encntr_id 		= o.originating_encntr_id
	and 	e.active_ind 		= 1
join oa
	where 	oa.order_id 		= o.order_id
	and    	oa.action_type_cd	in(
										value(uar_get_code_by("MEANING",6003,"ORDER"))
									)
join p1
	where	p1.person_id		= oa.order_provider_id
join od1
	where 	od1.order_id			= outerjoin(o.order_id)
	and		(
					(od1.oe_field_meaning	= outerjoin("ORDERLOC"))
				or	(od1.oe_field_meaning	= outerjoin("SPECIMEN TYPE"))
				or	(od1.oe_field_meaning	= outerjoin("COLLPRI"))
			)
order by
	 o.order_id
	,od1.oe_field_id
	,od1.action_sequence desc
head report
	ordcnt = 0
head o.order_id
	ordcnt += 1
	stat = alterlist(rCustom->order_list,ordcnt)
	rCustom->order_list[ordcnt].order_id					= o.order_id
	rCustom->order_list[ordcnt].order_mnemonic				= o.order_mnemonic
	rCustom->order_list[ordcnt].ordering_provider			= p1.name_full_formatted
	rCustom->order_list[ordcnt].orig_order_date				= o.orig_order_dt_tm
	rCustom->order_list[ordcnt].requested_start_date		= o.current_start_dt_tm
	rCustom->order_list[ordcnt].order_details				= o.clinical_display_line
head od1.oe_field_id
	case (od1.oe_field_meaning)
		of "ORDERLOC":		rCustom->order_list[ordcnt].ordering_location			= od1.oe_field_display_value
		of "SPECIMEN TYPE":	rCustom->order_list[ordcnt].specimen_type				= od1.oe_field_display_value
		of "COLLPRI":		rCustom->order_list[ordcnt].collection_priority			= od1.oe_field_display_value
	endcase
foot report
	rCustom->order_cnt = ordcnt
with nocounter
*/

select into "nl:"
from
	 encounter e
	,encntr_prsnl_reltn epr
	,prsnl p
plan e
	where e.encntr_id = chart_id->encntr_id
join epr
	where epr.encntr_id = e.encntr_id
	and   epr.active_ind = 1
	and   cnvtdatetime(sysdate) between epr.beg_effective_dt_tm and epr.end_effective_dt_tm
join p
	where p.person_id = epr.prsnl_person_id
	and   p.person_id = chart_id->prsnl_id
order by
	 e.encntr_id
	,epr.beg_effective_dt_tm desc
head e.encntr_id
	person_id = e.person_id
	encntr_id = e.encntr_id
	epr_reltn_cd = epr.encntr_prsnl_r_cd
	position_cd = p.position_cd
	prsnl_id = p.person_id
	rCustom->encounter_location = uar_get_code_display(e.loc_nurse_unit_cd)
	rCustom->encounter_type = uar_get_code_display(e.encntr_type_cd)
	rCustom->position_cd = p.position_cd
	rCustom->user_id = p.person_id
	
	if (uar_get_code_display(p.position_cd) in("DBA","DBA Lite","DBC - PowerChart"))
		rCustom->support_tool_ind = "true"
	else
		rCustom->support_tool_ind = "false"
	endif
	
	pCnt = 0
	pCnt = locateval(	 iCnt
						,1
						,activate_positions->cnt
						,rCustom->position_cd
						,activate_positions->qual[iCnt].position_cd
					)
					
	if (pCnt > 0)
		rCustom->activate_button_ind = "true"
	endif
	
with nocounter

; Collect the content service URL for dynamic asset paths
select into "nl:"
from dm_info d
plan d
    where d.info_domain = "INS"
    and d.info_name = "CONTENT_SERVICE_URL"
head report
    rCustom->content_service_url = trim(d.info_char)
with counter

; Parse the content_service_url to extract host and domain
if (rCustom->content_service_url != "")
    declare vURL = vc with noconstant(trim(rCustom->content_service_url)), protect
    declare nProtocolLen = i4 with noconstant(0), protect
    declare nStart = i4 with noconstant(0), protect
    declare nEnd = i4 with noconstant(0), protect
    declare nLastSlash = i4 with noconstant(0), protect

    ; Find end of 'http://' or 'https://'
    if (substring(1,8,vURL) = "https://")
        set nProtocolLen = 8
    elseif (substring(1,7,vURL) = "http://")
        set nProtocolLen = 7
    else
        set nProtocolLen = 0
    endif

    ; Host starts after the protocol
    set nStart = nProtocolLen + 1

    ; Find the next '/' after the protocol to mark end of host
    set nEnd = findstring("/", vURL, nStart)
    if (nEnd > 0)
        set rCustom->webshere_host = substring(1, nEnd - 1, vURL)
    else
        set rCustom->webshere_host = vURL
    endif

    ; Extract fully qualified domain (last path segment)
    set nLastSlash = nEnd
    while (findstring("/", vURL, nLastSlash+1) > 0)
        set nLastSlash = findstring("/", vURL, nLastSlash+1)
    endwhile
    if (nLastSlash > 0 and nLastSlash < textlen(vURL))
        set rCustom->fully_qualified_domain = substring(nLastSlash+1, textlen(vURL)-nLastSlash, vURL)
    endif
endif

call echo(build2("content_service_url=",rCustom->content_service_url))
call echo(build2("webshere_host=",rCustom->webshere_host))
call echo(build2("fully_qualified_domain=",rCustom->fully_qualified_domain))

call echo(build2("person_id=",person_id)) 
call echo(build2("encntr_id=",encntr_id)) 
call echo(build2("prsnl_id=",prsnl_id)) 
call echo(build2("position_cd=",position_cd)) 
call echo(build2("epr_reltn_cd=",epr_reltn_cd)) 
call echo(build2("lookback=",lookback)) 
call echo(build2("lookforward=",lookforward)) 

execute mp_cpoe_get_future_orders 
									 "MINE"
									,value(person_id)
									,value(prsnl_id)
									,value(encntr_id)
									,value(position_cd)
									,value(epr_reltn_cd)
									,lookback
									,lookforward 
		with replace("RECORD_DATA","TEMP_RECORD_DATA")

if (validate(temp_record_data) = 0)
	go to end_program
else 
	;call echorecord(temp_record_data)
	set stat = 0
endif

set _Memory_Reply_String = _Memory_Reply_String_Temp

/*
>>>Begin EchoRecord RECORD_DATA   ;RECORD_DATA
 1 STATUS_DATA
  2 STATUS=C1   {S}
  2 SUBEVENTSTATUS[1]
   3 OPERATIONNAME=C25   {}
   3 OPERATIONSTATUS=C1   {}
   3 TARGETOBJECTNAME=C25   {}
   3 TARGETOBJECTVALUE=VC0   {}
 1 PATIENTS[1,1*]
  2 PATIENT_ID=F8   {21105199.0000000000                     }
  2 ORDERS[1,57*]
   3 ORDER_ID=F8   {763598587.0000000000                    }
   3 MNEMONIC=VC15   {Plethysmography}
   3 CATALOG_TYPE_CD=F8   {636078.0000000000                       }
   3 CLINICAL_DISPLAY_LINE=VC248   {Schedule as: Outpatient, Reason For Exam: test, Priority: Routine, Interpreter R}
                                   {equired? No, Scheduling Location: BCH PF Lab, Scheduling Priority Next Available}
                                   { Appointment, Requested Start Date/Time 29-Jun-2021, Order for future visit, 22-}
                                   {Jun-2021}
   3 CLIN_DISP_LINE_TRUNCATED_IND= I2   {0}
   3 ORDER_COMMENT=VC0   {}
   3 RESPONSIBLE_PROVIDER_ID=F8   {0.0000000000                            }
   3 RESPONSIBLE_PROVIDER_NAME=VC0   {}
   3 START_DT_TM=DQ8   {69899076000000000    (2021-06-29 17:00:00.00) utc(1)}
   3 BEGIN_DUE_DT_TM=DQ8   {69899076000000000    (2021-06-29 17:00:00.00) utc(1)}
   3 END_DUE_DT_TM=DQ8   {69899076000000000    (2021-06-29 17:00:00.00) utc(1)}
   3 ORIGINAL_ORDER_DT_TM=DQ8   {69892998540000000    (2021-06-22 16:10:54.00) utc(1)}
   3 ORIGINAL_ORDER_TZ= I4   {0}
   3 DUE_STATUS_FLAG= I4   {2}
   3 PLAN_INFORMATION[1,1*]
    4 PLAN_NAME=VC110   {PED RESP AMB Respirology Clinics Triage, PED RESP AMB Respirology Clinics Triage}
                        {, LAB - Chloride Sweat Testing}
   3 ORDER_SET_INFORMATION[0,0*]
   3 ORDERING_LOCATION_INFORMATION[1,1*]
    4 ORDERING_LOCATION_CD=F8   {2600547579.0000000000                   }
    4 ORDERING_LOCATION_DISPLAY=VC14   {BCH Cystic Fib}
*/

for (pCnt = 1 to size(temp_record_data->patients,5))
	select into "nl:"
		 start_dt_tm = format(temp_record_data->patients[pCnt].orders[d1.seq].start_dt_tm,"YYYYMMDD;;q")
		,responsible_provider_name=substring(1,100,temp_record_data->patients[pCnt].orders[d1.seq].responsible_provider_name)
		,due_status_flag = temp_record_data->patients[pCnt].orders[d1.seq].due_status_flag
	from
		(dummyt d1 with seq=size(temp_record_data->patients[pCnt].orders,5))
	plan d1
		;where temp_record_data->patients[pCnt].orders[d1.seq].catalog_type_cd in(value(uar_get_code_by("MEANING",6000,"GENERAL LAB")))
	order by
		 start_dt_tm
		,responsible_provider_name
		,due_status_flag desc
	head report
		glCNT = 0
		radCNT = 0
		carCNT = 0
	detail
		case (uar_get_code_meaning(temp_record_data->patients[pCnt].orders[d1.seq].catalog_type_cd))
			of "GENERAL LAB": glCNT += 1
			of "RADIOLOGY": radCNT += 1
			of "CARDIOLOGY": carCNT += 1
		endcase
	foot report
		rCustom->counts.cardiology = carCNT
		rCustom->counts.lab = glCNT
		rCustom->counts.radiology = radCNT
	with nocounter
endfor

call echo(build2("transfering order details"))
for (pCnt = 1 to size(temp_record_data->patients,5))
	select into "nl:"
		 start_dt_tm = format(temp_record_data->patients[pCnt].orders[d1.seq].start_dt_tm,"YYYYMMDD;;q")
		,responsible_provider_name=substring(1,100,temp_record_data->patients[pCnt].orders[d1.seq].responsible_provider_name)
		,due_status_flag = temp_record_data->patients[pCnt].orders[d1.seq].due_status_flag
	from
		(dummyt d1 with seq=size(temp_record_data->patients[pCnt].orders,5))
	plan d1
		where temp_record_data->patients[pCnt].orders[d1.seq].catalog_type_cd ;in(value(uar_get_code_by("MEANING",6000,"GENERAL LAB")))
																			  = rCustom->selected_catalog_type
	order by
		 start_dt_tm
		,responsible_provider_name
		,due_status_flag desc
	head report
		oCnt = 0
		dCnt = 0
	head start_dt_tm
		null
	head responsible_provider_name	
		oCnt = 0
		dCnt = (dCnt + 1)
		stat = alterlist(rCustom->order_list,dCnt)
		rCustom->order_list[dCnt].data.requested_start_date			= temp_record_data->patients[pCnt].orders[d1.seq].start_dt_tm
		rCustom->order_list[dCnt].data.ordering_provider			= responsible_provider_name
		rCustom->order_list[dCnt].data.lookback = lookback
		rCustom->order_list[dCnt].data.lookforward = lookforward
		;rCustom->order_list[dCnt].data.params = cnvtrectojson(payload)
	detail
		oCnt += 1
		tCnt = (tCnt + 1)
		stat = alterlist(rCustom->order_list[dCnt].children,oCnt)
		rCustom->order_list[dCnt].children[oCnt].data.order_id						
			= temp_record_data->patients[pCnt].orders[d1.seq].order_id
		rCustom->order_list[dCnt].children[oCnt].data.catalog_type						
			= uar_get_code_display(temp_record_data->patients[pCnt].orders[d1.seq].catalog_type_cd)
		rCustom->order_list[dCnt].children[oCnt].data.order_mnemonic				
			= temp_record_data->patients[pCnt].orders[d1.seq].mnemonic
		rCustom->order_list[dCnt].children[oCnt].data.ordering_provider				
			= temp_record_data->patients[pCnt].orders[d1.seq].responsible_provider_name
		rCustom->order_list[dCnt].children[oCnt].data.orig_order_date				
			= temp_record_data->patients[pCnt].orders[d1.seq].original_order_dt_tm
		rCustom->order_list[dCnt].children[oCnt].data.requested_start_date			
			= temp_record_data->patients[pCnt].orders[d1.seq].start_dt_tm
		rCustom->order_list[dCnt].children[oCnt].data.hidden_data.due_status_flag	
			= temp_record_data->patients[pCnt].orders[d1.seq].due_status_flag
		rCustom->order_list[dCnt].children[oCnt].data.hidden_data.row_class			
			= temp_record_data->patients[pCnt].orders[d1.seq].clinical_display_line
		rCustom->order_list[dCnt].children[oCnt].data.order_comment					
			= temp_record_data->patients[pCnt].orders[d1.seq].order_comment
		rCustom->order_list[dCnt].children[oCnt].data.order_details					
			= temp_record_data->patients[pCnt].orders[d1.seq].clinical_display_line
		rCustom->order_list[dCnt].children[oCnt].data.grace_period			= concat(
																			 sCST_DATE(temp_record_data->patients[pCnt].orders[d1.seq].begin_due_dt_tm)
																			," - "
																			,sCST_DATE(temp_record_data->patients[pCnt].orders[d1.seq].end_due_dt_tm)
																			)																	
	
		if (size(temp_record_data->patients[pCnt].orders[d1.seq].plan_information,5))
			rCustom->order_list[dCnt].children[oCnt].data.powerplan.description 
				= temp_record_data->patients[pCnt].orders[d1.seq].plan_information[1].plan_name
			rCustom->order_list[dCnt].children[oCnt].data.powerplan.ind = 1
		endif
		
		if (rCustom->order_list[dCnt].children[oCnt].data.order_comment > "")
			rCustom->order_list[dCnt].children[oCnt].data.order_comment_ind = 1
		endif
			
	foot report
		rCustom->order_cnt = dCnt
	with nocounter
endfor



call echo(build2("finding order details"))
select into "nl:"
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
	,order_detail od1
	,orders o
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
join o
	where   o.order_id				= rCustom->order_list[d1.seq].children[d2.seq].data.order_id
join od1
	where 	od1.order_id			= o.order_id
	and 	od1.action_sequence = (select max(od.action_sequence)
                                         from order_detail   od
                                        where od.order_id = od1.order_id
                                          and od.oe_field_id = od1.oe_field_id )
order by
	 od1.order_id
	,od1.oe_field_id
	,od1.action_sequence desc
head report
	null
head od1.order_id
	call echo(build2("checking order:",trim(o.order_mnemonic),":",o.order_id))
	rCustom->order_list[d1.seq].children[d2.seq].data.protocol_order_id = o.protocol_order_id
	rCustom->order_list[d1.seq].children[d2.seq].data.template_order_id = o.template_order_id
	rCustom->order_list[d1.seq].children[d2.seq].data.catalog_cd = o.catalog_cd
;head od1.oe_field_id
detail
	call echo(build2("->detail:",od1.oe_field_meaning,"=",od1.oe_field_display_value))
	case (od1.oe_field_meaning)
		of "ORDERLOC":		rCustom->order_list[d1.seq].children[d2.seq].data.ordering_location			= od1.oe_field_display_value
		of "SPECIMEN TYPE":	rCustom->order_list[d1.seq].children[d2.seq].data.specimen_type				= od1.oe_field_display_value
							rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type			= od1.oe_field_display_value
							rCustom->order_list[d1.seq].children[d2.seq].data.hidden_data.specimen_type_cd	= od1.oe_field_value
		of "COLLPRI":		rCustom->order_list[d1.seq].children[d2.seq].data.collection_priority		= od1.oe_field_display_value
		of "SPECINX":		rCustom->order_list[d1.seq].children[d2.seq].data.note.lab_requisition		= od1.oe_field_display_value
							rCustom->order_list[d1.seq].children[d2.seq].data.note.ind					= 1
							rCustom->order_list[d1.seq].children[d2.seq].data.note.marker				= "X"
		of "NURSECOLLECT":	rCustom->order_list[d1.seq].children[d2.seq].data.nurse_collect_ind			= od1.oe_field_value
	endcase
;foot od1.oe_field_id
;	null
foot od1.order_id
	if (
			   (cnvtupper(rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type) != "*BLOOD*")
			and (cnvtupper(rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type) != "SERUM")
		)
		rCustom->order_list[d1.seq].children[d2.seq].data.specimen_type = "nonblood"
	else
		rCustom->order_list[d1.seq].children[d2.seq].data.specimen_type = "blood"
	endif
foot report
	null
with nocounter


call echo(build2("building ordering provider list"))
select into "nl:"
	ordering_provider = substring(1,200,rCustom->order_list[d1.seq].children[d2.seq].data.ordering_provider)
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
order by
	ordering_provider
head report
	pCnt = 0
	;pCnt += 1
	;stat = alterlist(rCustom->provider_list,pCnt)
	;rCustom->provider_list[pCnt].label = "Any Provider"
	;rCustom->provider_list[pCnt].value = ""
head ordering_provider
	pCnt += 1
	stat = alterlist(rCustom->provider_list,pCnt)
	rCustom->provider_list[pCnt].label = rCustom->order_list[d1.seq].children[d2.seq].data.ordering_provider
	rCustom->provider_list[pCnt].value = rCustom->order_list[d1.seq].children[d2.seq].data.ordering_provider
foot report
	rCustom->provider_cnt = pCnt
with nocounter

call echo(build2("building ordering location list"))
select into "nl:"
	ordering_location = substring(1,200,rCustom->order_list[d1.seq].children[d2.seq].data.ordering_location)
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
order by
	ordering_location
head report
	pCnt = 0
	;pCnt += 1
	;stat = alterlist(rCustom->ord_location_list,pCnt)
	;rCustom->ord_location_list[pCnt].label = "All Locations"
	;rCustom->ord_location_list[pCnt].value = ""
head ordering_location
	pCnt += 1
	stat = alterlist(rCustom->ord_location_list,pCnt)
	rCustom->ord_location_list[pCnt].label = rCustom->order_list[d1.seq].children[d2.seq].data.ordering_location
	rCustom->ord_location_list[pCnt].value = rCustom->order_list[d1.seq].children[d2.seq].data.ordering_location
foot report
	rCustom->ord_location_cnt = pCnt
with nocounter

for (ordCnt = 1 to size(rCustom->order_list,5))
set rCustom->order_list[ordCnt].expanded = ""
 for (dCnt = 1 to size(rCustom->order_list[ordCnt].children,5))
 	set rCustom->order_list[ordCnt].children[dCnt].expanded = ""
	if (rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.due_status_flag = 1)
		set rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.row_class = "orderDue"
		;set rCustom->order_list[ordCnt].children[dCnt].expanded = "true"
		set rCustom->order_list[ordCnt].data.hidden_data.row_class = "orderDue"
		;set rCustom->order_list[ordCnt].expanded = "true"
		set rCustom->order_list[ordCnt].data.hidden_data.due_status_flag = 1
	elseif (rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.due_status_flag = 2)
		set rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.row_class = "orderOverdue"
	elseif (rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.due_status_flag = 0)
		set rCustom->order_list[ordCnt].children[dCnt].data.hidden_data.row_class = "orderUpcoming"
	endif
	
	set rCustom->order_list[ordCnt].children[dCnt].data.requested_start_date_vc 
		= sCST_DATE(rCustom->order_list[ordCnt].children[dCnt].data.requested_start_date)
	set rCustom->order_list[ordCnt].children[dCnt].data.orig_order_date_vc 
		= sCST_DATE(rCustom->order_list[ordCnt].children[dCnt].data.orig_order_date)
	
	set months = 0.0
	set months = (datetimediff(	 rCustom->order_list[ordCnt].children[dCnt].data.requested_start_date
								,cnvtdatetime(sysdate)
							  ) / 30.0)
	set rCustom->order_list[ordCnt].children[dCnt].data.months = months
	
 	set rCustom->order_list[ordCnt].data.requested_start_date_vc 
		= sCST_DATE(rCustom->order_list[ordCnt].requested_start_date)
	
	endfor
endfor



call echo(build2("adding powerplan details"))
select into "nl:"
	order_id = rCustom->order_list[d1.seq].children[d2.seq].data.order_id
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
	,orders o
	,act_pw_comp apc
	,pathway_comp pc
	,pathway p
	,pathway_catalog pcat
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
	where rCustom->order_list[d1.seq].children[d2.seq].data.order_id > 0.0
	and rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.ind = 1
join o
	where o.order_id = rCustom->order_list[d1.seq].children[d2.seq].data.order_id
join apc
	where apc.parent_entity_id = o.order_id
join p
	where p.pathway_id = apc.pathway_id
join pc
	where pc.pathway_comp_id = apc.pathway_comp_id
join pcat
	where pcat.pathway_catalog_id = pc.pathway_catalog_id
order by
	order_id
head report
	call echo(build2("inside powerplan order check"))
head order_id
	call echo(build2("->order:",rCustom->order_list[d1.seq].children[d2.seq].data.order_mnemonic,":",order_id))
	rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.description = p.pw_group_desc
	rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.ind = 1
	call echo(build2("-->Powerplan:",trim(p.pw_group_desc)," that is ",p.type_mean))
	call echo(build2("-->pathway_group_id:",p.pathway_group_id))
	call echo(build2("-->pathway_id:",p.pathway_id))
	;if (p.type_mean = "DOT")
		
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pathway_id = p.pathway_id
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_group_nbr = p.pw_group_nbr
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pathway_group_id = p.pathway_group_id
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_cat_group_id = p.pw_cat_group_id
	;endif
	
foot report
	call echo(build2("leaving powerplan order check"))
with nocounter,time=30



call echo(build2("adding child details from parents"))
select into "nl:"
	order_id = rCustom->order_list[d1.seq].children[d2.seq].data.order_id
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
	,orders o
	,act_pw_comp apc
	,pathway_comp pc
	,pathway p
	,pathway_catalog pcat
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
	where rCustom->order_list[d1.seq].children[d2.seq].data.protocol_order_id > 0.0
join o
	where o.order_id = rCustom->order_list[d1.seq].children[d2.seq].data.protocol_order_id
join apc
	where apc.parent_entity_id = o.order_id
join p
	where p.pathway_id = apc.pathway_id
join pc
	where pc.pathway_comp_id = apc.pathway_comp_id
join pcat
	where pcat.pathway_catalog_id = pc.pathway_catalog_id
order by
	order_id
head report
	call echo(build2("inside protocol order check"))
head order_id
	call echo(build2("->order:",rCustom->order_list[d1.seq].children[d2.seq].data.order_mnemonic,":",order_id))
	rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.description = p.pw_group_desc
	rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.ind = 1
	call echo(build2("-->Powerplan:",trim(p.pw_group_desc)," that is ",p.type_mean))
	call echo(build2("-->pathway_group_id:",p.pathway_group_id))
	call echo(build2("-->pathway_id:",p.pathway_id))
	;if (p.type_mean = "DOT")
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.dot_ind = 1
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pathway_id = p.pathway_id
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_group_nbr = p.pw_group_nbr
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pathway_group_id = p.pathway_group_id
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_cat_group_id = p.pw_cat_group_id
	;endif
	
foot report
	call echo(build2("leaving protocol order ceck"))
with nocounter


call echo(build2("finding earliest_dt_tm DOT Orders"))
select into "nl:"
	order_id = rCustom->order_list[d1.seq].children[d2.seq].data.order_id
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
	,pathway p 
	,act_pw_comp apc
	,orders o
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2
	where rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.dot_ind = 1
join p
	where p.pathway_group_id = rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pathway_group_id
	and   p.type_mean = "DOT"
join apc
	where apc.pathway_id = p.pathway_id
join o
	where o.order_id = apc.parent_entity_id
	and   o.order_status_cd = value(uar_get_code_by("MEANING",6004,"FUTURE"))
	and   o.protocol_order_id = rCustom->order_list[d1.seq].children[d2.seq].data.protocol_order_id
order by
	 p.pathway_group_id
	,o.protocol_order_id
	,order_id
	,o.current_start_dt_tm
head report
	call echo(build2("inside earliest_dt_tm DOT Orders"))
head p.pathway_group_id
	call echo(build2("p.pathway_group_id=",p.pathway_group_id))
head o.protocol_order_id	
	earliest_dt_tm = o.current_start_dt_tm
	call echo(build2("o.protocol_order_id=",o.protocol_order_id))
	call echo(build2("o.order_mnemonic=",o.order_mnemonic))
	call echo(build2("earliest_dt_tm=",format(cnvtdatetime(earliest_dt_tm),";;q")))
head order_id
	call echo(build2("DOT checking order:"
		,rCustom->order_list[d1.seq].children[d2.seq].data.order_mnemonic
		,":",rCustom->order_list[d1.seq].children[d2.seq].data.catalog_cd))
	call echo(build2("o.catalog_cd:",o.catalog_cd))
	;if (o.catalog_cd = rCustom->order_list[d1.seq].children[d2.seq].data.catalog_cd)
		rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.dot_earliest_dt_tm = earliest_dt_tm	
	;endif
foot o.protocol_order_id	
	earliest_dt_tm = 0.0
foot p.pathway_group_id
	earliest_dt_tm = 0.0
foot report
	call echo(build2("leaving earliest_dt_tm DOT Orders"))
with nocounter,uar_code(d,1),format(date,"dd-mmm-yyyy hh:mm:ss;;q"),time=30

select into "nl:"
	order_id = rCustom->order_list[d1.seq].children[d2.seq].data.order_id
from
	 (dummyt d1 with seq=rCustom->order_cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(rCustom->order_list[d1.seq].children,5))
join d2	
order by
	order_id
head report
	hoverInd = 0
head order_id
	hoverInd = 0
;detail
	if (rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.ind = 1)
		rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(	
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
																				
																				,"<u>PowerPlan:</u> "
																				,rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.description 
																			)
	endif
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.dot_ind = 1)
	 if (rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.dot_earliest_dt_tm > 0.0)
	  if (rCustom->order_list[d1.seq].children[d2.seq].data.hover_info > " ")
	  	rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(	
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
	  																			,"<br><br>")
	  endif
		rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(	
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
																				,"<u>Earliest DoT "
																				,rCustom->order_list[d1.seq].children[d2.seq].data.order_mnemonic
																				," Future Order:</u> "
																				
																				,sCST_DT_TM(
																				  rCustom->order_list[d1.seq].children[d2.seq].
																				  data.powerplan.dot_earliest_dt_tm)
																			)
	 endif
	endif
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.note.ind = 1)
	 if (rCustom->order_list[d1.seq].children[d2.seq].data.hover_info > " ")
	  	rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(	
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
	  																			,"<br><br>")
	 endif
		rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
																				,"<u>Lab Requisition Note:</u> "
																				,rCustom->order_list[d1.seq].children[d2.seq].data.note.lab_requisition 
																			)
	endif
	if (rCustom->order_list[d1.seq].children[d2.seq].data.order_comment_ind = 1)
	 if (rCustom->order_list[d1.seq].children[d2.seq].data.hover_info > " ")
	  	rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(	
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
	  																			,"<br><br>")
	 endif
		rCustom->order_list[d1.seq].children[d2.seq].data.hover_info = build2(
																				 rCustom->order_list[d1.seq].children[d2.seq].data.hover_info
																				,"<u>Comment:</u> "
																				,rCustom->order_list[d1.seq].children[d2.seq].data.order_comment 
																			)
	endif
foot order_id
	if (hoverInd = 1)
		rCustom->order_list[d1.seq].children[d2.seq].data.hover_ind = 1
	endif

	pCnt = 0
	pCnt = locateval(	 iCnt
						,1
						,common_lab_specimens->cnt
						;,rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type
						,rCustom->order_list[d1.seq].children[d2.seq].data.hidden_data.specimen_type_cd
						;,common_lab_specimens->qual[iCnt].specimen_type
						,common_lab_specimens->qual[iCnt].specimen_type_cd
					)
	if (pCnt = 0)
	/*
	if (rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type in(
		"Blood",
		"Urine",
		"Whole Blood",
		"Blood Spot",
		"Feces",
		"Arterial Blood",
		"Cystic Fibrosis Cough Swab",
		"Cystic Fibrosis Sputum",
		"Cystic Fibrosis Throat Swab",
		"Sputum",
		"Cord Blood",
		"Nasopharyngeal Swab",
		"Saline gargle",
		"Urine Indwelling catheter",
		"Rectal Swab",
		"Sweat",
		"Saliva",
		"Nasopharyngeal Flocked Swab",
		"Urine Cystoscopy",
		"Urine, Midstream",
		"Venous Blood",
		"Urine  (specify site)",
		"Buccal Swab",
		"Feces - Collected in SAF",
		"Urine special collection for Schistosoma",
		"Pinworm Paddle",
		"Urine, Ileal Conduit",
		"Urine, In and Out Catheter",
		"Urine, Pedi Bag",
		"Urine, Vesicostomy",
		"Urine, Nephrostomy",
		"Urine, Post prostatic massage",
		"Urine, Suprapubic Aspirate",
		"Urine, Uterostomy",
		"Insects/Arthropods please specify source",
		"Tick please specify source",
		"Worm submitted for identification",
		"skin scrapings for scabies  please speci",
		"Cord Blood Product",
		"Saliva Swab"
		))
		*/
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab = "true"
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab2 = 1
	else
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab = "truefalse"
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab2 = 0
	endif
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.orig_spec_type = "")
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab = "true"
		rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab2 = 1
	endif
	
	/*
	if (rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.description > " ")
		pCnt = 0
		pCnt = locateval(	 iCnt
							,1
							,nonlab_powerplans->cnt
							,rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.description
							,nonlab_powerplans->qual[iCnt].description
						)
		if (pCnt > 0)
			rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab = "truefalse"
			rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab2 = 0
		endif
	endif
	*/
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_cat_group_id > 0.0)
		pCnt = 0
		pCnt = locateval(	 iCnt
							,1
							,nonlab_powerplans->cnt
							,rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.pw_cat_group_id
							,nonlab_powerplans->qual[iCnt].pathway_id
						)
		if (pCnt > 0)
			rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab = "truefalse"
			rCustom->order_list[d1.seq].children[d2.seq].data.typical_lab2 = 0
		endif
	endif
	
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.nurse_collect_ind = 1.0)
		if (		(rCustom->encounter_type = "Lab Recurring")
				and	(rCustom->encounter_location = "*Lab*")
				and (rCustom->order_list[d1.seq].children[d2.seq].data.catalog_type = "Laboratory")
			)
			rCustom->order_list[d1.seq].children[d2.seq].data.hidden_data.need_lab_collection = 1
		endif
	endif
	
	if (rCustom->order_list[d1.seq].children[d2.seq].data.requested_start_date >= cnvtdatetime(sysdate))
		if (
					(rCustom->order_list[d1.seq].children[d2.seq].data.powerplan.ind = 1)
				and	(rCustom->encounter_type = "Lab Recurring")
				and	(rCustom->encounter_location = "*Lab*")
				and (rCustom->order_list[d1.seq].children[d2.seq].data.catalog_type = "Laboratory")
			)
			rCustom->order_list[d1.seq].children[d2.seq].data.hidden_data.need_date_update = 1
		endif
	endif
	
	/*
	if ((rCustom->order_list[d1.seq].children[d2.seq].data.catalog_type = "Laboratory")
		and	(rCustom->encounter_type = "Lab Recurring")
				and	(rCustom->encounter_location = "*Lab*"))
		rCustom->order_list[d1.seq].children[d2.seq].data.hidden_data.need_date_update = 1
	endif
	*/
	
foot report
	null
with nocounter



#exit_script

set rCustom->lastRefesh = format(cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM:SS;;q")



; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
call echorecord((rCustom))

;call echojson(rCustom,concat("cclscratch:",t_rec->files.records_attachment))

#end_program
 
end go
