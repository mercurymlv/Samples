--#Start Week
--@'2018-12-10'
--set qry parm to  :
--AQT QUERYPARM, PARM=startdate,DESC="Start Week",VALUE='2020-05-11',
--
--

select distinct 

xcs.STORE_NUMBER "Store Number" , xcs.CUSTOMER_NUMBER "Customer Number", xcs.SITE_NUMBER "Site Number", 

hp.PARTY_NAME "Name", hl.ADDRESS1, hl.ADDRESS2, hl.CITY, nvl(hl.STATE, hl.PROVINCE) "State/Prov",  hl.POSTAL_CODE "Postal Code", hl.COUNTRY "Country",


 

xdpm.DP_NAME "DP Name", '' "Add Delete Change", 'N' "Copy Wk1 to Wk2", 'Alternate' "Schedule Type", to_date(:startdate,'YYYY-MM-DD') "ISD Start-Date" , to_date(:startdate,'YYYY-MM-DD')+6 "ISD End-Date",

--mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1 "Week",


--Monday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_1_OPLT - xcs.MON_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_2_OPLT - xcs.MON_WEEK_2_ITLT) 
"Monday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_2_ITLT) 
"Monday Ship",



--Tuesday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_1_OPLT - xcs.TUE_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_2_OPLT - xcs.TUE_WEEK_2_ITLT) 
"Tuesday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_2_ITLT) 
"Tuesday Ship",



--Wednesday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_1_OPLT - xcs.WED_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_2_OPLT - xcs.WED_WEEK_2_ITLT) 
"Wednesday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_2_ITLT) 
"Wednesday Ship",



--Thursday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_1_OPLT - xcs.THU_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_2_OPLT - xcs.THU_WEEK_2_ITLT) 
"Thursday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_2_ITLT) 
"Thursday Ship",


--Friday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_1_OPLT - xcs.FRI_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_2_OPLT - xcs.FRI_WEEK_2_ITLT) 
"Friday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_2_ITLT) 
"Friday Ship",




--Saturday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_1_OPLT - xcs.SAT_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_2_OPLT - xcs.SAT_WEEK_2_ITLT) 
"Saturday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_2_ITLT) 
"Saturday Ship",




--Sunday
decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_1_OPLT - xcs.SUN_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_2_OPLT - xcs.SUN_WEEK_2_ITLT) 
"Sunday Order",

decode(mod((to_date(:startdate,'YYYY-MM-DD')- xcs.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,
	1,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_1_ITLT,
	2,trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_2_ITLT) 
"Sunday Ship",



'' "Remarks",

xdps.SOURCING_GROUP_CODE "Sourcing Group", xdps.X_DOCK_LOCATION "X-dock CDC", xdps.RECEIPT_DAY_CDC "CDC Receipt Day", xdpscdc.INSTORE_XDOCK_DAY "X-dock Instore", 

xdps.ITLT "Add'l ITLT",

TO_CHAR (TRUNC (SYSDATE) + xdps.delivery_start_date / (24 * 60 * 60), 'HH24:MI') "Delivery Window Start",
TO_CHAR (TRUNC (SYSDATE) + xdps.delivery_end_date/ (24 * 60 * 60), 'HH24:MI') "Delivery Window End",

xdps.BAKERY_TEMP "Bakery Temp",

'' "Cup Size",

hca.CUSTOMER_CLASS_CODE "Customer Class",


xcs.COPY_WEEK1_TO_WEEK2_FLAG, xcs.SCHEDULE_TYPE, xcs.IN_STORE_DEL_SCH_START_DATE, xcs.IN_STORE_DEL_SCH_END_DATE,

xcs.CUST_SCHED_ID



----Monday
--
--trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_1_OPLT - xcs.MON_WEEK_1_ITLT "Monday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))- xcs.MON_WEEK_1_ITLT "Monday Ship",
--
----Tuesday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_1_OPLT - xcs.TUE_WEEK_1_ITLT "Tuesday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 1 - xcs.TUE_WEEK_1_ITLT "Tuesday Ship",
--
----Wednesday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_1_OPLT - xcs.WED_WEEK_1_ITLT "Wednesday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 2 - xcs.WED_WEEK_1_ITLT "Wednesday Ship",
--
----Thursday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_1_OPLT - xcs.THU_WEEK_1_ITLT "Thursday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 3 - xcs.THU_WEEK_1_ITLT "Thursday Ship",
--
----Friday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_1_OPLT - xcs.FRI_WEEK_1_ITLT "Friday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 4 - xcs.FRI_WEEK_1_ITLT "Friday Ship",
--
----Saturday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_1_OPLT - xcs.SAT_WEEK_1_ITLT "Saturday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 5 - xcs.SAT_WEEK_1_ITLT "Saturday Ship",
--
----Sunday
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_1_OPLT - xcs.SUN_WEEK_1_ITLT "Sunday Order",
--trunc(to_date(:startdate,'YYYY-MM-DD'))+ 6 - xcs.SUN_WEEK_1_ITLT "Sunday Ship"
--


from APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs
join apps.XXOM_DSTRB_POINT_MSTR_V xdpm on xcs.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
left join apps.XXOM_DSTRB_POINT_STORES_v xdps on xcs.CUSTOMER_SITE_ID= xdps.SITE_ID and xdpm.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID
left join apps.XXOM_DSTRB_POINT_MSTR xdpmcdc on xdps.X_DOCK_LOCATION=xdpmcdc.DSTRB_POINT_NUMBER
left join apps.XXOM_DSTRB_POINT_STORES_v xdpscdc on xdpmcdc.DSTRB_POINT_ID= xdpscdc.DSTRB_POINT_ID and xcs.CUSTOMER_SITE_ID= xdpscdc.SITE_ID
join apps.hz_cust_accounts hca on xcs.CUSTOMER_NUMBER=hca.ACCOUNT_NUMBER
join apps.hz_party_sites hps on xcs.SITE_NUMBER=hps.PARTY_SITE_NUMBER
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.LOCATION_ID= hl.LOCATION_ID


where 1=1



--and xcs.STORE_NUMBER in (101,122,15253)
and xdpm.DSTRB_POINT_NUMBER in ('CDC1014','CDC1015')
--and xdpm.DSTRB_POINT_NUMBER in ('RDC1001','RDC1002','RDC1013','RDC1004','RDC1005')
--and (xdpm.DP_NAME like '%Mile Hi%' or xdpm.DP_NAME like '%GSF%')
--and xdpm.DSTRB_POINT_TYPE_CODE in ('DSD','CDC')



--and xcs.STORE_NUMBER=21013
--and xcs.SCHEDULE_TYPE in ('Promotional','Alternate')
and xcs.SCHEDULE_TYPE = 'Standard'

--and xcs.IN_STORE_DEL_SCH_START_DATE in ('2014-12-29','2015-01-05')


and xcs.IN_STORE_DEL_SCH_START_DATE <= to_date(:startdate,'YYYY-MM-DD')

and (xcs.IN_STORE_DEL_SCH_END_DATE > to_date(:startdate,'YYYY-MM-DD') or xcs.IN_STORE_DEL_SCH_END_DATE is null)



