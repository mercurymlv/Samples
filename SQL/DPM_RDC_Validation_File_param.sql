--#Start Week
--@'2020-06-15'
--set qry parm to  :
--AQT QUERYPARM, PARM=startdate,DESC="Start Week",VALUE='2020-05-25',



select distinct xdps.STORE_NUMBER, xdps.CUSTOMER_NUMBER,xdps.PARTY_SITE_NUMBER, hca.CUSTOMER_CLASS_CODE, xdps.SOURCING_GROUP_CODE, xdpm.DP_NAME, xdpm.ORGANIZATION_CODE, 

xcs.SCHEDULE_TYPE, xcs.SCH_START_DATE "ODS Start", xcs.SCH_END_DATE "ODS End", 

nvl2(xcs.CUST_SCHED_ID,(DECODE (mon_week_1,'Y',1,0)+ DECODE (tue_week_1,'Y',1,0)+ DECODE (wed_week_1,'Y',1,0)+ DECODE (thu_week_1,'Y',1,0)+ DECODE (fri_week_1,'Y',1,0)+ DECODE (sat_week_1,'Y',1,0)+ DECODE (sun_week_1,'Y',1,0)+ DECODE (mon_week_2,'Y',1,0)+ DECODE 
(tue_week_2,'Y',1,0)+ DECODE (wed_week_2,'Y',1,0)+ DECODE (thu_week_2,'Y',1,0)+ DECODE (fri_week_2,'Y',1,0)+ DECODE 
(sat_week_2,'Y',1,0)+ DECODE (sun_week_2,'Y',1,0) )/2, xcs.CUST_SCHED_ID) "Freq",



xcs.COPY_WEEK1_TO_WEEK2_FLAG "Copy wk1/2 flag",

DECODE (xcs.mon_week_1,'Y','M',null) ||
DECODE (xcs.tue_week_1,'Y','T',null) ||
DECODE (xcs.wed_week_1,'Y','W',null) ||
DECODE (xcs.thu_week_1,'Y','R',null) ||
DECODE (xcs.fri_week_1,'Y','F',null) ||
DECODE (xcs.sat_week_1,'Y','S',null) ||
DECODE (xcs.sun_week_1,'Y','U',null) "Week 1 Deliveries",

DECODE (xcs.mon_week_2,'Y','M',null) ||
DECODE (xcs.tue_week_2,'Y','T',null) ||
DECODE (xcs.wed_week_2,'Y','W',null) ||
DECODE (xcs.thu_week_2,'Y','R',null) ||
DECODE (xcs.fri_week_2,'Y','F',null) ||
DECODE (xcs.sat_week_2,'Y','S',null) ||
DECODE (xcs.sun_week_2,'Y','U',null) "Week 2 Deliveries",


next_day(trunc(sysdate)-7,'MONDAY') || ' - Wk# ' || (MOD(abs(((next_day(trunc(sysdate)-7,'MONDAY'))- xcs.SCH_START_DATE))/7,2)+1)  "Wk 1 or 2?",

xdps.ITLT "Additional Transit",
to_char(trunc(sysdate) + xdps.delivery_start_date / (24 * 60 * 60),'HH24:MI:SS') "Delivery Window Start",
to_char(trunc(sysdate) + xdps.delivery_end_date / (24 * 60 * 60), 'HH24:MI:SS') "Delivery Window End", 


xdps.PARTY_NAME,  hl.ADDRESS1, hl.ADDRESS2, hl.CITY, nvl(hl.STATE, hl.PROVINCE) "State/Prov", hl.POSTAL_CODE "Postal Code", hl.COUNTRY,


xdps.X_DOCK_LOCATION, xdps.RECEIPT_DAY_CDC,

--using nvl2 to return only xdock routing if the store has a xdock CDC assigned or carrier routing if the store is not xdock
nvl2(xdps.X_DOCK_LOCATION, xdock_route."car", nvl(xcrh.CARRIER_CODE,stateroute."car"))"Carrier",
nvl2(xdps.X_DOCK_LOCATION, xdock_route."mode", nvl(xcrh.MODE_OF_TRANSPORT_CODE,stateroute."mode")) "Mode",
nvl2(xdps.X_DOCK_LOCATION, xdock_route."term", nvl(xcrh.TERMINAL,stateroute."term")) "Terminal",
nvl2(xdps.X_DOCK_LOCATION, xdock_route."service", nvl(xcrh.SERVICE_LEVEL,stateroute."service")) "Service Level"


--select count(*)

from apps.XXOM_DSTRB_POINT_STORES_V xdps
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE = xdsr.STORE_GROUP and xdps.DSTRB_POINT_ID = xdsr.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID = xdpm.DSTRB_POINT_ID
join apps.hz_cust_accounts hca on xdps.CUSTOMER_NUMBER= hca.ACCOUNT_NUMBER
--join apps.hz_cust_site_uses_all hcsu on xdps.SITE_ID= hcsu.CUST_ACCT_SITE_ID

--sub: Select Lowest RDC Precedence
join (select xdps.SITE_ID "SiteID", xdps.SOURCING_GROUP_CODE "src", min (xdsr.SOURCING_PRECEDENCE) "Prec" 
from apps.XXOM_DSTRB_POINT_STORES_v xdps
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdps.DSTRB_POINT_ID = xdpm.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE = xdsr.STORE_GROUP and xdps.DSTRB_POINT_ID = xdsr.DSTRB_POINT_ID and xdsr.START_DATE <= trunc (to_date(:startdate,'YYYY-MM-DD')) and (xdsr.END_DATE >= trunc(to_date(:startdate,'YYYY-MM-DD')) or xdsr.END_DATE is null)
where 1=1
and xdpm.DSTRB_POINT_TYPE_CODE = 'RDC' 
and xdpm.DP_NAME not like '%Virtual%'
--and xdpm.ORGANIZATION_CODE not in ('RRP','PS2','PR2')
and xdpm.ORGANIZATION_CODE like 'F%'
group by xdps.SITE_ID, xdps.SOURCING_GROUP_CODE) RDCPrec on xdps.SITE_ID = RDCPrec."SiteID"  and xdps.SOURCING_GROUP_CODE= RDCPrec."src" and xdsr.SOURCING_PRECEDENCE = RDCPrec."Prec"
--end: precedence

join apps.XXOM_CUSTOMER_SCHEDULE xcs on xdps.SITE_ID= xcs.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID= xcs.DSTRB_POINT_ID
join apps.hz_party_sites hps on xdps.PARTY_SITE_NUMBER= hps.PARTY_SITE_NUMBER
join apps.hz_locations hl on hps.LOCATION_ID= hl.LOCATION_ID

--subquery: Left outer join to pull in routing from RDC to xdock CDC
--technically the subquery should join where customer site OU matches xdock CDC site OU (such as if Siren Retail and US ship to same xdock)
--i'm selecting 'distinct' instead to cut down on processing time
left outer join (select distinct xcrh.SHIP_FROM_ORGANIZATION "rdcorg",xdpm.DSTRB_POINT_NUMBER "xdockcdc", xcrh.CARRIER_CODE "car", xcrh.MODE_OF_TRANSPORT_CODE "mode", xcrh.TERMINAL "term", xcrh.SERVICE_LEVEL "service"
	from apps.XXOM_DSTRB_POINT_MSTR_v xdpm
	left outer join apps.hr_locations_all ha on xdpm.ORGANIZATION_ID= ha.INVENTORY_ORGANIZATION_ID
	left outer join APPS.PO_LOCATION_ASSOCIATIONS_ALL PLA on ha.LOCATION_ID=PLA.LOCATION_ID
	join apps.xxom_carr_route_hdr_inq_v xcrh on PLA.ADDRESS_ID= xcrh.SITE_ID
	where 1=1
	and xdpm.DSTRB_POINT_TYPE_CODE = 'CDC'
	and xdpm.VIRTUAL_DP_FLAG='N'
	and xcrh.MODE_OF_TRANSPORT_CODE in ('TRUCK','OCEAN')
	and xcrh.SHIPMENT_PRIORITY is null
	and (xcrh.START_DATE <= trunc(to_date(:startdate,'YYYY-MM-DD')) or xcrh.START_DATE is null)
	and (xcrh.END_DATE >= trunc(to_date(:startdate,'YYYY-MM-DD')) or xcrh.END_DATE is null)
) xdock_route on xdpm.ORGANIZATION_CODE= xdock_route."rdcorg" and xdps.X_DOCK_LOCATION= xdock_route."xdockcdc"
--end sub: RDC-xdock CDC routing

--left outer join to pull in ship-to site-level carrier routing
-- i'm using 999 to compare against weight breaks to pull in normal routing, i.e. how would a 1000lb order ship?
left outer join apps.xxom_carr_route_hdr_inq_v xcrh on xdps.PARTY_SITE_NUMBER=xcrh.SITE_NUMBER and xdpm.ORGANIZATION_CODE= xcrh.SHIP_FROM_ORGANIZATION  and xcrh.MIN_WEIGHT <999 and xcrh.MAX_WEIGHT >999 /* and xcrh.MODE_OF_TRANSPORT_CODE in ('LTL','OCEAN','TRUCK') */ and xcrh.shipment_priority_code is null and (xcrh.START_DATE <= to_date(:startdate,'YYYY-MM-DD') or xcrh.START_DATE is null) and (xcrh.END_DATE > to_date(:startdate,'YYYY-MM-DD') or xcrh.END_DATE is null)


--subquery: Left outer join to pull in RDC-to-state routing
left outer join (
select xcrh.SHIP_FROM_ORGANIZATION "rdcorg", nvl(xcrh.STATE, xcrh.PROVINCE) "stprov", xcrh.CARRIER_CODE "car", xcrh.MODE_OF_TRANSPORT_CODE "mode", xcrh.TERMINAL "term", xcrh.SERVICE_LEVEL "service"
from apps.xxom_carr_route_hdr_inq_v xcrh
where 1=1
and xcrh.SHIP_FROM_ORGANIZATION in ('F22','F26','F21','F24','F27','FE1')
and nvl(xcrh.STATE, xcrh.PROVINCE) is not null
and xcrh.SHIPMENT_PRIORITY is null
and (xcrh.MIN_WEIGHT <999 and xcrh.MAX_WEIGHT >999)
and (xcrh.START_DATE <= trunc(to_date(:startdate,'YYYY-MM-DD')) or xcrh.START_DATE is null)
and (xcrh.END_DATE >= trunc(to_date(:startdate,'YYYY-MM-DD')) or xcrh.END_DATE is null)
) stateroute on xdpm.ORGANIZATION_CODE= stateroute."rdcorg" and nvl(hl.STATE, hl.PROVINCE)= stateroute."stprov"
--end sub: RDC-state routing





where 1=1

and xcs.SCHEDULE_TYPE='Standard'
and xcs.SCH_START_DATE <= to_date(:startdate,'YYYY-MM-DD')
and (xcs.SCH_END_DATE > trunc(to_date(:startdate,'YYYY-MM-DD')) or xcs.SCH_END_DATE is null)





