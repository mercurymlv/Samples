
----This query looks at markets that use a DSD or have an exception for lunch - this could be the Penske CDCs or Mercato or extra ordering lead-time
--It has multiple parts: check if DSD does not match CDC ODS or is missing for Penske markets and to check if Mercato DSD ODS is missing; check lead-times for Mercato and virtuals


--the DSD ODS should sync to the CDC ODS for regular lunch in Penske markets - this first query will return records where
--the DSD ODS is not synced to the CDC ODS

----***Please note***This query is not very clean because it's difficult to dynamically link the DSD to it's respective CDC
--therefore, I am "hard-wiring" the connection by DP Number.
--this will probably break down in the future if multiple CDCs start using the same DSD

--also, Mercato DSDs are excluded because the ODS is different on purpose - including both delivery days (e.g.
--a 3.5x CDC store can have 7x DSD) and order days (i.e. Mercato is always 3-day lead-time)

--Mercato will be handled in a separate query


select 'Lunch DSD ODS Does Not Match' "Error Msg", 


to_number(xcs.STORE_NUMBER) "Store Number", xcs.DSTRB_POINT_NUMBER "Lunch DSD DP", xcs.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk 1/2", xcs.SCHEDULE_TYPE "Sched Type", xcs.IN_STORE_DEL_SCH_START_DATE "ODS Start", xcs.IN_STORE_DEL_SCH_END_DATE "ODS End",

to_number(xcs2.STORE_NUMBER) "Store Number", xcs2.DSTRB_POINT_NUMBER "Regular CDC", xcs2.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk 1/2", xcs2.SCHEDULE_TYPE "Sched Type", xcs2.IN_STORE_DEL_SCH_START_DATE "ODS Start", xcs2.IN_STORE_DEL_SCH_END_DATE "ODS End"


---start with the ODS file - this will look at the DSD ODS first
from APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm on xcs.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
--join the MCL so that can see sourcing group (i.e. if they are Mercato or not)
join APPS.XXOM_DSTRB_POINT_STORES_V xdps_DSD on xcs.DSTRB_POINT_ID= xdps_DSD.DSTRB_POINT_ID and xcs.CUSTOMER_SITE_ID= xdps_DSD.SITE_ID

---join the DSD ODS to the CDC ODS
join APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs2 on xcs.CUSTOMER_SITE_ID= xcs2.CUSTOMER_SITE_ID 

--only works if there is a 1:1 relationship between DSD and CDC
--add/edit these lines as new lunch DSDs launch, retire or change
--you can add Mercato DSDs if they also support regular lunch - we will filter those stores out later
and case xcs.DSTRB_POINT_NUMBER
--When 'DSD1000' then 'CDC1027' --Taylor Farms to Atlanta
When 'DSD1194' then 'CDC1027' --FFG to Atlanta
When 'DSD1000' then 'CDC1027' --Taylor Farms to Atlanta
when 'DSD1025' then 'CDC1005' --Greencore to Cleveland
when 'DSD1066' then 'CDC1070' --FFG to Dallas
when 'DSD1094' then 'CDC1071' --FFG to Phoenix
when 'DSD1061' then 'CDC1071' --Taylor Farms to Phoenix
when 'DSD1172' then 'CDC1036' --FFG to San Diego
when 'DSD1215' then 'CDC1035' --Taylor Farms to Sacramento
when 'DSD1408' then 'CDC1054' --Taylor Farms to Houston
end =xcs2.DSTRB_POINT_NUMBER 

--the last part of this join statement only includes records where the 2 ODS schedules (DSD and CDC) overlap.
--for schedule changes, the old DSD will not match the new standard and that is expected - we don't want to include these records
and (xcs.IN_STORE_DEL_SCH_START_DATE <= nvl(xcs2.IN_STORE_DEL_SCH_END_DATE,to_date ('01/01/3999', 'MM/DD/YYYY')) and nvl(xcs.IN_STORE_DEL_SCH_END_DATE,to_date ('01/01/3999', 'MM/DD/YYYY')) >= xcs2.IN_STORE_DEL_SCH_START_DATE)
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm2 on xcs2.DSTRB_POINT_ID=xdpm2.DSTRB_POINT_ID

where 1=1


--add/edit these lines as new lunch DSDs launch, retire or change
--you can add Mercato DSDs if they also support regular lunch - we will filter those stores out later
and xcs.DSTRB_POINT_NUMBER in ('DSD1061','DSD1000','DSD1025','DSD1066','DSD1094','DSD1172','DSD1215','DSD1408','DSD1194')

--We filter out the Mercato stores by source group name
--this could be problematic later since it's just a naming convention
and xdps_DSD.SOURCING_GROUP_CODE not like '%Mercato%'

--ignore old ODS schedules (i.e. end-date in the past) - irrelevant
and (xcs.IN_STORE_DEL_SCH_END_DATE > trunc(sysdate) or xcs.IN_STORE_DEL_SCH_END_DATE is null)


--check if all parts of ODS match - i.e. the checkmark that indicates a delivery, OPLT and ITLT
--I thought it would be easier to concatenate the fields together first
--I used the nvl because there are alot of nulls and I don't want to ignore them, nvl substitutes them with -1 instead
--this is the DSD ODS
and xcs.MON_WEEK_1 || nvl( xcs.MON_WEEK_1_OPLT,-1) || nvl( xcs.MON_WEEK_1_ITLT,-1) || xcs.TUE_WEEK_1 || nvl( xcs.TUE_WEEK_1_OPLT,-1) || nvl( xcs.TUE_WEEK_1_ITLT,-1) || xcs.WED_WEEK_1 || nvl( xcs.WED_WEEK_1_OPLT,-1) || nvl( xcs.WED_WEEK_1_ITLT,-1) || xcs.THU_WEEK_1 || nvl( xcs.THU_WEEK_1_OPLT,-1) || nvl( xcs.THU_WEEK_1_ITLT,-1) || xcs.FRI_WEEK_1 || nvl( xcs.FRI_WEEK_1_OPLT,-1) || nvl( xcs.FRI_WEEK_1_ITLT,-1) || xcs.SAT_WEEK_1 || nvl( xcs.SAT_WEEK_1_OPLT,-1) || nvl( xcs.SAT_WEEK_1_ITLT,-1) || xcs.SUN_WEEK_1 || nvl( xcs.SUN_WEEK_1_OPLT,-1) || nvl( xcs.SUN_WEEK_1_ITLT,-1) ||

--include week2 too
xcs.MON_WEEK_2 || nvl( xcs.MON_WEEK_2_OPLT,-1) || nvl( xcs.MON_WEEK_2_ITLT,-1) || xcs.TUE_WEEK_2 || nvl( xcs.TUE_WEEK_2_OPLT,-1) || nvl( xcs.TUE_WEEK_2_ITLT,-1) || xcs.WED_WEEK_2 || nvl( xcs.WED_WEEK_2_OPLT,-1) || nvl( xcs.WED_WEEK_2_ITLT,-1) || xcs.THU_WEEK_2 || nvl( xcs.THU_WEEK_2_OPLT,-1) || nvl( xcs.THU_WEEK_2_ITLT,-1) || xcs.FRI_WEEK_2 || nvl( xcs.FRI_WEEK_2_OPLT,-1) || nvl( xcs.FRI_WEEK_2_ITLT,-1) || xcs.SAT_WEEK_2 || nvl( xcs.SAT_WEEK_2_OPLT,-1) || nvl( xcs.SAT_WEEK_2_ITLT,-1) || xcs.SUN_WEEK_2 || nvl( xcs.SUN_WEEK_2_OPLT,-1) || nvl( xcs.SUN_WEEK_2_ITLT,-1)


--Here is the CDC ODS - check when it is not equal to the DSD
--because of every-other-day stores, I am using a decode to make sure it's comparing the correct week1/2
--the decode checks if there is an even or odd number of weeks between the 2 start-dates
--if even, then compare week1 (DSD) vs week1 (CDC)
--if odd, then compare 1 vs 2 instead
<> decode(MOD(abs(xcs.IN_STORE_DEL_SCH_START_DATE - xcs2.IN_STORE_DEL_SCH_START_DATE)/7,2)+1,

1,
xcs2.MON_WEEK_1 || nvl( xcs2.MON_WEEK_1_OPLT,-1) || nvl( xcs2.MON_WEEK_1_ITLT,-1) || xcs2.TUE_WEEK_1 || nvl( xcs2.TUE_WEEK_1_OPLT,-1) || nvl( xcs2.TUE_WEEK_1_ITLT,-1) || xcs2.WED_WEEK_1 || nvl( xcs2.WED_WEEK_1_OPLT,-1) || nvl( xcs2.WED_WEEK_1_ITLT,-1) || xcs2.THU_WEEK_1 || nvl( xcs2.THU_WEEK_1_OPLT,-1) || nvl( xcs2.THU_WEEK_1_ITLT,-1) || xcs2.FRI_WEEK_1 || nvl( xcs2.FRI_WEEK_1_OPLT,-1) || nvl( xcs2.FRI_WEEK_1_ITLT,-1) || xcs2.SAT_WEEK_1 || nvl( xcs2.SAT_WEEK_1_OPLT,-1) || nvl( xcs2.SAT_WEEK_1_ITLT,-1) || xcs2.SUN_WEEK_1 || nvl( xcs2.SUN_WEEK_1_OPLT,-1) || nvl( xcs2.SUN_WEEK_1_ITLT,-1) ||

xcs2.MON_WEEK_2 || nvl( xcs2.MON_WEEK_2_OPLT,-1) || nvl( xcs2.MON_WEEK_2_ITLT,-1) || xcs2.TUE_WEEK_2 || nvl( xcs2.TUE_WEEK_2_OPLT,-1) || nvl( xcs2.TUE_WEEK_2_ITLT,-1) || xcs2.WED_WEEK_2 || nvl( xcs2.WED_WEEK_2_OPLT,-1) || nvl( xcs2.WED_WEEK_2_ITLT,-1) || xcs2.THU_WEEK_2 || nvl( xcs2.THU_WEEK_2_OPLT,-1) || nvl( xcs2.THU_WEEK_2_ITLT,-1) || xcs2.FRI_WEEK_2 || nvl( xcs2.FRI_WEEK_2_OPLT,-1) || nvl( xcs2.FRI_WEEK_2_ITLT,-1) || xcs2.SAT_WEEK_2 || nvl( xcs2.SAT_WEEK_2_OPLT,-1) || nvl( xcs2.SAT_WEEK_2_ITLT,-1) || xcs2.SUN_WEEK_2 || nvl( xcs2.SUN_WEEK_2_OPLT,-1) || nvl( xcs2.SUN_WEEK_2_ITLT,-1),

2,
xcs2.MON_WEEK_2 || nvl( xcs2.MON_WEEK_2_OPLT,-1) || nvl( xcs2.MON_WEEK_2_ITLT,-1) || xcs2.TUE_WEEK_2 || nvl( xcs2.TUE_WEEK_2_OPLT,-1) || nvl( xcs2.TUE_WEEK_2_ITLT,-1) || xcs2.WED_WEEK_2 || nvl( xcs2.WED_WEEK_2_OPLT,-1) || nvl( xcs2.WED_WEEK_2_ITLT,-1) || xcs2.THU_WEEK_2 || nvl( xcs2.THU_WEEK_2_OPLT,-1) || nvl( xcs2.THU_WEEK_2_ITLT,-1) || xcs2.FRI_WEEK_2 || nvl( xcs2.FRI_WEEK_2_OPLT,-1) || nvl( xcs2.FRI_WEEK_2_ITLT,-1) || xcs2.SAT_WEEK_2 || nvl( xcs2.SAT_WEEK_2_OPLT,-1) || nvl( xcs2.SAT_WEEK_2_ITLT,-1) || xcs2.SUN_WEEK_2 || nvl( xcs2.SUN_WEEK_2_OPLT,-1) || nvl( xcs2.SUN_WEEK_2_ITLT,-1) ||
xcs2.MON_WEEK_1 || nvl( xcs2.MON_WEEK_1_OPLT,-1) || nvl( xcs2.MON_WEEK_1_ITLT,-1) || xcs2.TUE_WEEK_1 || nvl( xcs2.TUE_WEEK_1_OPLT,-1) || nvl( xcs2.TUE_WEEK_1_ITLT,-1) || xcs2.WED_WEEK_1 || nvl( xcs2.WED_WEEK_1_OPLT,-1) || nvl( xcs2.WED_WEEK_1_ITLT,-1) || xcs2.THU_WEEK_1 || nvl( xcs2.THU_WEEK_1_OPLT,-1) || nvl( xcs2.THU_WEEK_1_ITLT,-1) || xcs2.FRI_WEEK_1 || nvl( xcs2.FRI_WEEK_1_OPLT,-1) || nvl( xcs2.FRI_WEEK_1_ITLT,-1) || xcs2.SAT_WEEK_1 || nvl( xcs2.SAT_WEEK_1_OPLT,-1) || nvl( xcs2.SAT_WEEK_1_ITLT,-1) || xcs2.SUN_WEEK_1 || nvl( xcs2.SUN_WEEK_1_OPLT,-1) || nvl( xcs2.SUN_WEEK_1_ITLT,-1),0)



union


----The second part of the SQL checks for when DSD ODS for regular lunch stores is missing (Penske markets). The best way I could think to
--approach this was to start with the lunch DSD MCL then check to see if they have CDC ODS and then check to see if DSD is missing
--that way, it filters out all of the new stores that don't have CDC ODS yet (i.e. the DSD ODS isn't entering until
--we know CDC so that we can mirror it


select 'Lunch DSD ODS Missing' "Error Msg", 

to_number(xdps_DSD.STORE_NUMBER) "Store Number", xdpm_DSD.DSTRB_POINT_NUMBER "Lunch DSD DP", null "Copy Wk 1/2", null "Sched Type", null "ODS Start", null "ODS End",

to_number(xcs_CDC.STORE_NUMBER) "Store Number", xdpm_CDC.DSTRB_POINT_NUMBER "Regular CDC",  xcs_CDC.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk 1/2", xcs_CDC.SCHEDULE_TYPE "Sched Type", xcs_CDC.IN_STORE_DEL_SCH_START_DATE "ODS Start", xcs_CDC.IN_STORE_DEL_SCH_END_DATE "ODS End"


--Start with the DSD MCL
from APPS.XXOM_DSTRB_POINT_STORES_V xdps_DSD
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm_DSD on xdps_DSD.DSTRB_POINT_ID=xdpm_DSD.DSTRB_POINT_ID

--join the CDC ODS
--the CDC list below are just the Penske CDCs, this list will need to be updated as CDCs open/close
--filter so that we're only looking for active Standard schedules

join APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs_CDC on xdps_DSD.SITE_ID= xcs_CDC.CUSTOMER_SITE_ID and xcs_CDC.DSTRB_POINT_NUMBER in ('CDC1027','CDC1005','CDC1070','CDC1071','CDC1036','CDC1035','CDC1054') and xcs_CDC.SCHEDULE_TYPE='Standard' and (xcs_CDC.IN_STORE_DEL_SCH_END_DATE>=trunc(sysdate) or xcs_CDC.IN_STORE_DEL_SCH_END_DATE is null)
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm_CDC on xcs_CDC.DSTRB_POINT_ID=xdpm_CDC.DSTRB_POINT_ID

--use a left outer join for the DSD ODS - it will return nulls for when the DSD ODS is missing
--filter so that we're only looking for active Standard schedules
left outer join  APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs_DSD on xdps_DSD.DSTRB_POINT_ID= xcs_DSD.DSTRB_POINT_ID and xdps_DSD.SITE_ID= xcs_DSD.CUSTOMER_SITE_ID and xcs_DSD.SCHEDULE_TYPE='Standard' and xcs_DSD.IN_STORE_DEL_SCH_START_DATE <= trunc(sysdate) and (xcs_DSD.IN_STORE_DEL_SCH_END_DATE>=trunc(sysdate) or xcs_DSD.IN_STORE_DEL_SCH_END_DATE is null)


where 1=1

--this is the DSD MCL - only look for the lunch DSDs
--don't add Mercato DSDs here unless they also support core lunch
and xdpm_DSD.DSTRB_POINT_NUMBER in ('DSD1061','DSD1000','DSD1025','DSD1066','DSD1094','DSD1172','DSD1215','DSD1408','DSD1194')


--only include active rules
and (xdps_DSD.END_DATE >= trunc(sysdate) or xdps_DSD.END_DATE is null)


--this is the DSD ODS - we did a left outer join, so the nulls indicate the stores that are missing ODS
--these are the only records we want to return
and xcs_DSD.CUST_SCHED_ID is null




union


----The third part of the SQL is to check for when Mercato DSD ODS is missing
--unlike the other parts, there is no relation to CDC, so we're just straight-up checking the DSD MCL vs. the ODS
--since Mercato ODS is uniform we presume that it will be entered automatically when the store is set up, so 
--no need to worry about new stores


select 'Mercato DSD ODS Missing' "Error Msg", 

to_number(xdps_mer.STORE_NUMBER) "Store Number", xdpm_mer.DSTRB_POINT_NUMBER "Lunch DSD DP", null "Copy Wk 1/2", null "Sched Type", null "ODS Start", null "ODS End",

null "Store Number", null "Regular CDC",  null "Copy Wk 1/2", null "Sched Type", null "ODS Start", null "ODS End"


--start with the DSD MCL
from APPS.XXOM_DSTRB_POINT_STORES_V xdps_mer
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm_mer on xdps_mer.DSTRB_POINT_ID=xdpm_mer.DSTRB_POINT_ID

--left outer join the ODS - a null will indicate that the ODS is missing
--filter so that we're only looking for active Standard schedules
left outer join  APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs_mer on xdps_mer.DSTRB_POINT_ID= xcs_mer.DSTRB_POINT_ID and xdps_mer.SITE_ID=xcs_mer.CUSTOMER_SITE_ID and xcs_mer.SCHEDULE_TYPE='Standard' and (xcs_mer.IN_STORE_DEL_SCH_END_DATE>=trunc(sysdate) or xcs_mer.IN_STORE_DEL_SCH_END_DATE is null)

where 1=1

--only include the Mercato DSDs here
--this will need to be updated as DSDs are added and removed
--you can include DSDs that also support core lunch - we'll filter out the non-Mercato stores later
and xdpm_mer.DSTRB_POINT_NUMBER in ('DSD1029','DSD1500','DSD1501','DSD1215','DSD1172','DSD1502')


--only include active rules
and (xdps_mer.END_DATE >= trunc(sysdate) or xdps_mer.END_DATE is null)

--filter out any stores not in Mercato sourcing groups - they will be handled in a different part of the query
--this could be problematic later since it's just a naming convention
and xdps_mer.SOURCING_GROUP_CODE like '%Mercato%'

--This is the Mercato ODS, because we did a left outer join any null means ODS is missing
--these are the records we want to return
and xcs_mer.CUST_SCHED_ID is null



union

----The forth part of the SQL is to check that Mercato DSD ODS has the correct 3-day lead-time
--unlike the other parts, there is no relation to CDC, so we're just checking the ODS itself
--since Mercato ODS is uniform we presume that it will be entered automatically when the store is set up, so 
--no need to worry about new stores

select 'Mercato DSD Leadtime Error' "Error Msg", 

to_number(xcs_mer.STORE_NUMBER) "Store Number", xdpm_mer.DSTRB_POINT_NUMBER "Lunch DSD DP", xcs_mer.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk 1/2", xcs_mer.SCHEDULE_TYPE "Sched Type", xcs_mer.IN_STORE_DEL_SCH_START_DATE "ODS Start", xcs_mer.IN_STORE_DEL_SCH_END_DATE "ODS End",

null "Store Number", null "Regular CDC",  null "Copy Wk 1/2", null "Sched Type", null "ODS Start", null "ODS End"


--start with the DSD ODS
from APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs_mer
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm_mer on xcs_mer.DSTRB_POINT_ID= xdpm_mer.DSTRB_POINT_ID
--join to the MCL to find Mercato stores only
join APPS.XXOM_DSTRB_POINT_STORES_V xdps_mer on xcs_mer.DSTRB_POINT_ID= xdps_mer.DSTRB_POINT_ID and xcs_mer.CUSTOMER_SITE_ID= xdps_mer.SITE_ID

where 1=1

--only include the Mercato DSDs here
--this will need to be updated as DSDs are added and removed
--you can include DSDs that also support core lunch - we'll filter out the non-Mercato stores later
and xdpm_mer.DSTRB_POINT_NUMBER in ('DSD1029','DSD1500','DSD1501','DSD1215','DSD1172','DSD1502')


--and xcs_mer.SCHEDULE_TYPE 'Standard'

--ignore old schedules
and (xcs_mer.IN_STORE_DEL_SCH_END_DATE>=trunc(sysdate) or xcs_mer.IN_STORE_DEL_SCH_END_DATE is null)
--filter out any stores not in Mercato sourcing groups - they will be handled in a different part of the query
--this could be problematic later since it's just a naming convention
and xdps_mer.SOURCING_GROUP_CODE like '%Mercato%'

--check every delivery to see if total LT is less than 2
and (xcs_mer.MON_WEEK_1_OPLT + xcs_mer.MON_WEEK_1_ITLT <=2 or
	xcs_mer.TUE_WEEK_1_OPLT + xcs_mer.TUE_WEEK_1_ITLT <=2 or
	xcs_mer.WED_WEEK_1_OPLT + xcs_mer.WED_WEEK_1_ITLT <=2 or
	xcs_mer.THU_WEEK_1_OPLT + xcs_mer.THU_WEEK_1_ITLT <=2 or
	xcs_mer.FRI_WEEK_1_OPLT + xcs_mer.FRI_WEEK_1_ITLT <=2 or
	xcs_mer.SAT_WEEK_1_OPLT + xcs_mer.SAT_WEEK_1_ITLT <=2 or
	xcs_mer.SUN_WEEK_1_OPLT + xcs_mer.SUN_WEEK_1_ITLT <=2 or
	xcs_mer.MON_WEEK_2_OPLT + xcs_mer.MON_WEEK_2_ITLT <=2 or
	xcs_mer.TUE_WEEK_2_OPLT + xcs_mer.TUE_WEEK_2_ITLT <=2 or
	xcs_mer.WED_WEEK_2_OPLT + xcs_mer.WED_WEEK_2_ITLT <=2 or
	xcs_mer.THU_WEEK_2_OPLT + xcs_mer.THU_WEEK_2_ITLT <=2 or
	xcs_mer.FRI_WEEK_2_OPLT + xcs_mer.FRI_WEEK_2_ITLT <=2 or
	xcs_mer.SAT_WEEK_2_OPLT + xcs_mer.SAT_WEEK_2_ITLT <=2 or
	xcs_mer.SUN_WEEK_2_OPLT + xcs_mer.SUN_WEEK_2_ITLT <=2)




union



----The final part of the SQL is to check that "Virtual Lunch" ODS has the correct 3-day lead-time

select 'Virtual Lunch Leadtime Error' "Error Msg", 

to_number(xcs_vl.STORE_NUMBER) "Store Number", xdpm_vl.DSTRB_POINT_NUMBER "Lunch DSD DP", xcs_vl.COPY_WEEK1_TO_WEEK2_FLAG "Copy Wk 1/2", xcs_vl.SCHEDULE_TYPE "Sched Type", xcs_vl.IN_STORE_DEL_SCH_START_DATE "ODS Start", xcs_vl.IN_STORE_DEL_SCH_END_DATE "ODS End",

null "Store Number", null "Regular CDC",  null "Copy Wk 1/2", null "Sched Type", null "ODS Start", null "ODS End"


--start with the Virtual Lunch ODS
from APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs_vl
join APPS.XXOM_DSTRB_POINT_MSTR_V xdpm_vl on xcs_vl.DSTRB_POINT_ID= xdpm_vl.DSTRB_POINT_ID

where 1=1

--only include the virtual lunch DPs here
and xdpm_vl.DP_NAME like '%Virtual Lunch%'

and xdpm_vl.DSTRB_POINT_NUMBER not in ('CDC1248','CDC1247')


--ignore old schedules
and (xcs_vl.IN_STORE_DEL_SCH_END_DATE>=trunc(sysdate) or xcs_vl.IN_STORE_DEL_SCH_END_DATE is null)

--check every delivery to see if total LT is less than 2
and (xcs_vl.MON_WEEK_1_OPLT + xcs_vl.MON_WEEK_1_ITLT <=2 or
	xcs_vl.TUE_WEEK_1_OPLT + xcs_vl.TUE_WEEK_1_ITLT <=2 or
	xcs_vl.WED_WEEK_1_OPLT + xcs_vl.WED_WEEK_1_ITLT <=2 or
	xcs_vl.THU_WEEK_1_OPLT + xcs_vl.THU_WEEK_1_ITLT <=2 or
	xcs_vl.FRI_WEEK_1_OPLT + xcs_vl.FRI_WEEK_1_ITLT <=2 or
	xcs_vl.SAT_WEEK_1_OPLT + xcs_vl.SAT_WEEK_1_ITLT <=2 or
	xcs_vl.SUN_WEEK_1_OPLT + xcs_vl.SUN_WEEK_1_ITLT <=2 or
	xcs_vl.MON_WEEK_2_OPLT + xcs_vl.MON_WEEK_2_ITLT <=2 or
	xcs_vl.TUE_WEEK_2_OPLT + xcs_vl.TUE_WEEK_2_ITLT <=2 or
	xcs_vl.WED_WEEK_2_OPLT + xcs_vl.WED_WEEK_2_ITLT <=2 or
	xcs_vl.THU_WEEK_2_OPLT + xcs_vl.THU_WEEK_2_ITLT <=2 or
	xcs_vl.FRI_WEEK_2_OPLT + xcs_vl.FRI_WEEK_2_ITLT <=2 or
	xcs_vl.SAT_WEEK_2_OPLT + xcs_vl.SAT_WEEK_2_ITLT <=2 or
	xcs_vl.SUN_WEEK_2_OPLT + xcs_vl.SUN_WEEK_2_ITLT <=2)

order by 1,2





