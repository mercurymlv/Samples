
select distinct hp.ATTRIBUTE21 "Store Number", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", mp.ORGANIZATION_CODE "ORG Code", xdps.SOURCING_GROUP_CODE "Source Group", Case hca.SALES_CHANNEL_CODE when 'LS' then 'LS' when 'INT' then 'COS' else hca.SALES_CHANNEL_CODE end "Sales Code",  hou.NAME "Site Org", hp.PARTY_NAME "Party Name" ,hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site Number",  hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City",  nvl(hl.state, hl.PROVINCE) "State/Prov" , hl.postal_code "Postal Code", hl.country "Country", xcsah.LATITUDE "Latitude", xcsah.LONGITUDE "Longitude",

xcsah.PROPOSED_OPEN_DATE "Proposed Open Date", xcsah.ACTUAL_OPEN_DATE "Actual Open Date", 



--these lines look at the ODS schedules to determine delivery frequency, some stores, such as new stores
--will not have ODS yet, if that is the case, they will be displayed as 'null'
--we calcuate the frequency by adding up the number of "Y"s. 
--the "Y" corresponds to the 'check' box on the ODS form in Oracle, basically, we're counting the number of delivery days
--filled out on the ODS over the 2 week schedule then divide by 2
nvl2(xcs.CUST_SCHED_ID,(DECODE (mon_week_1,'Y',1,0)+ DECODE (tue_week_1,'Y',1,0)+ DECODE (wed_week_1,'Y',1,0)+ DECODE (thu_week_1,'Y',1,0)+ DECODE (fri_week_1,'Y',1,0)+ DECODE (sat_week_1,'Y',1,0)+ DECODE (sun_week_1,'Y',1,0)+ DECODE (mon_week_2,'Y',1,0)+ DECODE 
(tue_week_2,'Y',1,0)+ DECODE (wed_week_2,'Y',1,0)+ DECODE (thu_week_2,'Y',1,0)+ DECODE (fri_week_2,'Y',1,0)+ DECODE 
(sat_week_2,'Y',1,0)+ DECODE (sun_week_2,'Y',1,0) )/2, xcs.CUST_SCHED_ID) "CDC Freq",


----Oracle expresses time as # of seconds from midnight, these
----lines take the total seconds and divide down to the decimal number of hours
----and then cast it as a time-format
TO_CHAR (TRUNC (SYSDATE) + xdps.delivery_start_date / (24 * 60 * 60), 'HH24:MI') "Delivery Window Start",
TO_CHAR (TRUNC (SYSDATE) + xdps.delivery_end_date/ (24 * 60 * 60), 'HH24:MI') "Delivery Window End",

xdps.BAKERY_TEMP "Bakery Temp", 

decode(hca.SALES_CHANNEL_CODE,'LS','LS Store',prog_lunch.PROGRAM_DESC) "Lunch?", 
decode(hca.SALES_CHANNEL_CODE,'LS','LS Store', prog_warm.PROGRAM_DESC) "Warming?",


xdpbg_3PL.CHARGE "3PL Provider Fee", 
xdpbg.CHARGE "Customer Drop Fee", 


xcs.SCH_START_DATE "CDC ODS Start", xcs.SCH_END_DATE "CDC ODS End", xcs.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk1 to Wk2 Flag", 

--This formula is used to tell which week (1 or 2) the every-other-day stores are currently in. I can't put a system date in the header,
--so it is a concatenated string: The date is the Monday of the week when the report is run and which week number is current.
--
--The formula follows this logic: first figure out Monday's date (of the current week) - the "next day" function does this (we add a
-- -7 to make sure it is the immediate previous Monday. Next, substract the 2 dates to get the total number of days between them. Take the 
--absolute value because the start-date may be in the future. Divide by 7 to get the total number of weeks between the 2 dates - it will be a 
--whole number because, by definition, we are using 2 Monday dates. Take the modulus of the number of weeks using 2 as the divisor - the 
--modulus is the remainder - if we divide by 2 the only possible remainders are 0 and 1. 0 indicates there are an even amount of weeks 
--between the 2 dates, so we are in "week 1", and 1 indicates "week2". finally, add 1 to it so that it comes out either 1 or 2 
--(instead of 0 or 1)
next_day(trunc(sysdate)-7,'MONDAY') || ' - Wk# ' || (MOD(abs(((next_day(trunc(sysdate)-7,'MONDAY'))- xcs.SCH_START_DATE))/7,2)+1)  "Wk 1 or 2?",

xcs.MON_WEEK_1, xcs.TUE_WEEK_1, xcs.WED_WEEK_1, xcs.THU_WEEK_1, xcs.FRI_WEEK_1, xcs.SAT_WEEK_1, xcs.SUN_WEEK_1, xcs.MON_WEEK_2, xcs.TUE_WEEK_2, xcs.WED_WEEK_2, xcs.THU_WEEK_2, xcs.FRI_WEEK_2, xcs.SAT_WEEK_2, xcs.SUN_WEEK_2,

--Location Master attributes (as published to the CDH tables)
decode (xcsah.DELIV_ENTRY_KEY, 'MU', 'Master', 'UK', 'Unique', '') "Key Type",
xcsah.DELIV_PARK_AVAIL_FLAG "Delivery Parking Avail", 
xcsah.MULTI_LEVEL_DELIV_FLAG "Multi-level Delivery",
xcsah.AMBIENT_DELIVERY_ZONE "Ambient Delivery Zone",
xcsah.SEC_CLRNC_REQD_FLAG "Security Clearance Req",

xdps.STORE_KEY_DP "CDC Has Key", xdps.OVERRIDE_TEMP_CLOSE "Override Closures",


-- DSD stuff - from subquery
DSDSub."DPName" "Dairy DSD Name", DSDSub."DPNumber" "Dairy DSD Number", DSDSub."DSDFreq" "Dairy DSD Freq", 

-- RDC stuff - from subquery
RDCSub."DPName" "RDC Name", RDCSub."RDCFreq" "RDC Freq", RDCSub."XdockCDC" "Xdock CDC", RDCSub."CDCReceipt" "CDC Receipt Day", RDCSub."ISD" "Xdock In-Store"


from apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on xdpm.ORGANIZATION_ID = mp.ORGANIZATION_ID
left outer join XXSBUX.XXCDH_STORE_ATTRIBS_HDR xcsah on hp.ATTRIBUTE21 = xcsah.STORE_NUMBER
left outer join apps.XXOM_CUSTOMER_SCHEDULE xcs on xdps.SITE_ID = xcs.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID = xcs.DSTRB_POINT_ID and xcs.SCHEDULE_TYPE = 'Standard' and xcs.SCH_START_DATE <= trunc(SYSDATE) and(xcs.SCH_END_DATE > trunc(SYSDATE) or xcs.SCH_END_DATE is null)

--join the billing charge table twice - this one is for fee to customer
left outer join apps.xxom_dstrb_point_bill_chrg xdpbg on xdps.SITE_ID = xdpbg.SITE_ID and xdps.DSTRB_POINT_ID = xdpbg.DSTRB_POINT_ID and xdpbg.CHARGE_TYPE_CODE = 'STANDARD' and xdpbg.START_DATE <= trunc(SYSDATE) and (xdpbg.END_DATE > trunc(SYSDATE) or xdpbg.END_DATE is null) 

--join the billing charge table twice - this one is for fee charged by 3PL provider
left outer join apps.xxom_dstrb_point_bill_chrg xdpbg_3PL on xdps.SITE_ID = xdpbg_3PL.SITE_ID and xdps.DSTRB_POINT_ID = xdpbg_3PL.DSTRB_POINT_ID and xdpbg_3PL.CHARGE_TYPE_CODE = '3PL PROVIDER' and xdpbg_3PL.START_DATE <= trunc(SYSDATE) and (xdpbg_3PL.END_DATE > trunc(SYSDATE) or xdpbg_3PL.END_DATE is null)

--these are Location Master programs as published to the CDH tables
--we've joined the table multiple times because we're looking for different programs
left outer join XXSBUX.XXCDH_STORE_PROGRAMS prog_lunch on hp.ATTRIBUTE21=prog_lunch.STORE_NUMBER and prog_lunch.PROGRAM_CODE='LU' and to_date(prog_lunch.PROGRAM_START_DATE,'yyyy-mm-dd')<=trunc(sysdate) and (to_date(prog_lunch.PROGRAM_END_DATE,'yyyy-mm-dd')>trunc(sysdate) or to_date(prog_lunch.PROGRAM_END_DATE,'yyyy-mm-dd') is null)
left outer join XXSBUX.XXCDH_STORE_PROGRAMS prog_warm on hp.ATTRIBUTE21=prog_warm.STORE_NUMBER and prog_warm.PROGRAM_CODE='WA' and to_date(prog_warm.PROGRAM_START_DATE,'yyyy-mm-dd')<=trunc(sysdate) and (to_date(prog_warm.PROGRAM_END_DATE,'yyyy-mm-dd')>trunc(sysdate) or to_date(prog_warm.PROGRAM_END_DATE,'yyyy-mm-dd') is null)



--***this is a subquery that returns Dairy DSD information (if applicable - it will return null if they don't use a dairy DSD)
--there are many different types of DSD providers (dairy, lunch, beer/wine), to dynamically determine which ones
--are specifically for dairy, we're only include DSD's that have at least one item in specific JDA categories
left outer join (select distinct xdps.SITE_ID "SiteID", xdpm.DP_NAME "DPName", xdpm.DSTRB_POINT_NUMBER "DPNumber",
nvl2(xcs.CUST_SCHED_ID,(DECODE (xcs.mon_week_1,'Y',1,0)+ DECODE (xcs.tue_week_1,'Y',1,0)+ DECODE (xcs.wed_week_1,'Y',1,0)+ DECODE (xcs.thu_week_1,'Y',1,0)+ DECODE (xcs.fri_week_1,'Y',1,0)+ DECODE (xcs.sat_week_1,'Y',1,0)+ DECODE (xcs.sun_week_1,'Y',1,0)+ DECODE (xcs.mon_week_2,'Y',1,0)+ DECODE(xcs.tue_week_2,'Y',1,0)+ DECODE (xcs.wed_week_2,'Y',1,0)+ DECODE (xcs.thu_week_2,'Y',1,0)+ DECODE (xcs.fri_week_2,'Y',1,0)+ DECODE(xcs.sat_week_2,'Y',1,0)+ DECODE (xcs.sun_week_2,'Y',1,0))/2, xcs.CUST_SCHED_ID) "DSDFreq"
from apps.XXOM_DSTRB_POINT_STORES_v xdps
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_ITEMS_v xdpi on xdpm.DSTRB_POINT_ID = xdpi.DSTRB_POINT_ID
join apps.mtl_system_items_b msi on xdpi.ITEM_ID = msi.INVENTORY_ITEM_ID and msi.ORGANIZATION_ID = (Select ORGANIZATION_ID from APPS.MTL_PARAMETERS where ORGANIZATION_CODE = 'GMO')
join apps.mtl_item_categories_v mic on msi.inventory_item_id = mic.inventory_item_id and msi.ORGANIZATION_ID=mic.ORGANIZATION_ID and mic.CATEGORY_SET_NAME='JDA HIERARCHY SBUX' and mic.SEGMENT1='010' and mic.SEGMENT2='400' and mic.SEGMENT3='010'
left outer join apps.XXOM_CUSTOMER_SCHEDULE xcs on xdps.SITE_ID = xcs.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID = xcs.DSTRB_POINT_ID and xcs.SCHEDULE_TYPE = 'Standard' and xcs.SCH_START_DATE <= trunc(SYSDATE) and(xcs.SCH_END_DATE > trunc(SYSDATE) or xcs.SCH_END_DATE is null)
where 1=1
and xdpm.DSTRB_POINT_TYPE_CODE = 'DSD') DSDSub on xdps.SITE_ID = DSDSub."SiteID"
---***end DSD subquery



--***RDC Subquery start
-- return main RDC (may use multiple) and attributes (frequency, xdock, etc...)
left outer join (select  xdps.SITE_ID "SiteID" , xdpm.DP_NAME "DPName", 
nvl2(xcs.CUST_SCHED_ID,(DECODE (xcs.mon_week_1,'Y',1,0)+ DECODE (xcs.tue_week_1,'Y',1,0)+ DECODE (xcs.wed_week_1,'Y',1,0)+ DECODE (xcs.thu_week_1,'Y',1,0)+ DECODE (xcs.fri_week_1,'Y',1,0)+ DECODE (xcs.sat_week_1,'Y',1,0)+ DECODE (xcs.sun_week_1,'Y',1,0)+ DECODE (xcs.mon_week_2,'Y',1,0)+ DECODE(xcs.tue_week_2,'Y',1,0)+ DECODE (xcs.wed_week_2,'Y',1,0)+ DECODE (xcs.thu_week_2,'Y',1,0)+ DECODE (xcs.fri_week_2,'Y',1,0)+ DECODE(xcs.sat_week_2,'Y',1,0)+ DECODE (xcs.sun_week_2,'Y',1,0))/2, xcs.CUST_SCHED_ID) "RDCFreq",

 xdps.X_DOCK_LOCATION "XdockCDC", xdps.RECEIPT_DAY_CDC "CDCReceipt", CDCMCL.ISD "ISD" 
from apps.XXOM_DSTRB_POINT_STORES_v xdps
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE = xdsr.STORE_GROUP and xdps.DSTRB_POINT_ID = xdsr.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID = xdpm.DSTRB_POINT_ID
--sub: Precedence
-- use DPM sourcing precedence to identify main RDC in case of multiple
join (select xdps.SITE_ID "SiteID", min (xdsr.SOURCING_PRECEDENCE) "Prec" 
from apps.XXOM_DSTRB_POINT_STORES_v xdps
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID = xdpm.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE = xdsr.STORE_GROUP and xdps.DSTRB_POINT_ID = xdsr.DSTRB_POINT_ID and xdsr.START_DATE <= trunc (sysdate) and (xdsr.END_DATE >= trunc (sysdate) or xdsr.END_DATE is null)
where 1=1
and xdpm.DSTRB_POINT_TYPE_CODE = 'RDC' 
and xdpm.DP_NAME not like '%Virtual%'
and xdpm.ORGANIZATION_CODE like 'F%'
group by xdps.SITE_ID) RDCPrec on xdps.SITE_ID = RDCPrec."SiteID"  and xdsr.SOURCING_PRECEDENCE = RDCPrec."Prec"
--end: prec
left outer join (select xdps.SITE_ID "SiteID", xdpm.DSTRB_POINT_NUMBER "DPNum", xdps.INSTORE_XDOCK_DAY "ISD"
from apps.XXOM_DSTRB_POINT_STORES_v xdps join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID = xdpm.DSTRB_POINT_ID) CDCMCL on xdps.X_DOCK_LOCATION = CDCMCL."DPNum" and xdps.SITE_ID = CDCMCL."SiteID" 
left outer join apps.XXOM_CUSTOMER_SCHEDULE xcs on xdps.SITE_ID = xcs.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID = xcs.DSTRB_POINT_ID and xcs.SCHEDULE_TYPE = 'Standard' and xcs.SCH_START_DATE <= trunc (sysdate) and (xcs.SCH_END_DATE >= trunc (sysdate) or xcs.SCH_END_DATE is null)) RDCSub on xdps.SITE_ID = RDCSub."SiteID"
--***RDC Subquery end



where 1=1
and hcsu.SITE_USE_CODE='SHIP_TO'
and xdps.START_DATE <= trunc(SYSDATE)
and(xdps.END_DATE > trunc(SYSDATE) or xdps.END_DATE is null)
and xdpm.DSTRB_POINT_TYPE_CODE = 'CDC'
and xdpm.DP_NAME not like '%Virtual%'


order by xdpm.DP_NAME, hp.ATTRIBUTE21
