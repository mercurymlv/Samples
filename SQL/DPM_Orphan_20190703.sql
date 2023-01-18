select nvl2(xdps.SITE_ID, 'ODS is active but MCL is not','ODS is active but MCL not defined') "Description", xcs.STORE_NUMBER "Store Number", xcs.CUSTOMER_NUMBER "Cust Number", xcs.SITE_NUMBER "Site Number", xdpm.DSTRB_POINT_NUMBER "DP Number", xdpm.DP_NAME "DP Name", xcs.SCHEDULE_TYPE "Sched Type", xcs.IN_STORE_DEL_SCH_START_DATE "ODS Start" , xcs.IN_STORE_DEL_SCH_END_DATE "ODS End",
'==' "==",
xdps.STORE_NUMBER "Store Number", xdps.SOURCING_GROUP_CODE "Src Group", xdps.CUSTOMER_NUMBER "Cust Number", xdps.PARTY_SITE_NUMBER "Site Number", PROPOSED_OPEN_DATE "Proposed Open", ACTUAL_OPEN_DATE "Actual Open", xcsah.CLOSE_DATE "Close Date", xdpm2.DSTRB_POINT_NUMBER "DP Number", xdpm2.DP_NAME "DP Name", xdps.START_DATE "MCL Start", xdps.END_DATE "MCL End"

from APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xcs.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
left outer join apps.xxom_dstrb_point_stores_v xdps on xcs.CUSTOMER_SITE_ID= xdps.SITE_ID and xcs.DSTRB_POINT_ID= xdps.DSTRB_POINT_ID
left outer join apps.xxom_dstrb_point_mstr xdpm2 on xdps.DSTRB_POINT_ID= xdpm2.DSTRB_POINT_ID
left outer join XXSBUX.XXCDH_STORE_ATTRIBS_HDR xcsah on xdps.STORE_NUMBER= xcsah.STORE_NUMBER

where 1=1
and xcs.schedule_type = 'Standard'
and trunc(sysdate)<= nvl(xcs.in_store_del_sch_end_date,to_date ('01/01/3999', 'MM/DD/YYYY'))
and (trunc(sysdate) > nvl(xdps.end_date,to_date ('01/01/3999','MM/DD/YYYY')) 
    or xdps.SITE_ID is null)

UNION


select 

--this uses concatenation to compare if there are multiple schedules
--the first value is if they have an active schedule or not, 
--the second is if they have an open end-dated schedule (either current or future)
case nvl2(xcs.CUST_SCHED_ID,'Y','N') || nvl2(xcsnull.CUST_SCHED_ID,'Y','N')
    when 'YN' then 'MCL active, no future schedule'
    when 'NY' then 'MCL active, only future schedule'
    when 'NN' then 'MCL active, no schedules'
    else ''
end "Description",

xcs.STORE_NUMBER "Store Number", xcs.CUSTOMER_NUMBER "Cust Number", xcs.SITE_NUMBER "Site Number", xdpm2.DSTRB_POINT_NUMBER "DP Number", xdpm2.DP_NAME "DP Name", xcs.SCHEDULE_TYPE "Sched Type", xcs.IN_STORE_DEL_SCH_START_DATE "ODS Start" , xcs.IN_STORE_DEL_SCH_END_DATE "ODS End",
'==' "==",
xdps.STORE_NUMBER "Store Number", xdps.SOURCING_GROUP_CODE "Src Group", xdps.CUSTOMER_NUMBER "Cust Number", xdps.PARTY_SITE_NUMBER "Site Number", xcsah.PROPOSED_OPEN_DATE "Proposed Open", xcsah.ACTUAL_OPEN_DATE "Actual Open", xcsah.CLOSE_DATE "Close Date", 

xdpm.DSTRB_POINT_NUMBER "DP Number", xdpm.DP_NAME "DP Name", xdps.START_DATE "MCL Start", xdps.END_DATE "MCL End"


from apps.xxom_dstrb_point_stores_v xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
--use left outer join because DSDs will be null
left outer join apps.mtl_parameters mp on xdpm.ORGANIZATION_ID= mp.ORGANIZATION_ID

--select any active schedule
left outer join APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcs on xdps.SITE_ID=xcs.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID=xcs.DSTRB_POINT_ID and xcs.SCHEDULE_TYPE='Standard' and xcs.IN_STORE_DEL_SCH_START_DATE < trunc(sysdate) and (xcs.IN_STORE_DEL_SCH_END_DATE > trunc(sysdate) or xcs.IN_STORE_DEL_SCH_END_DATE is null)

--join any schedule that has a null end-date
--may be the same as the active schedule - we want to make sure each store has at least one
--open end-dated standard schedule whether it is active or future
left outer join APPS.XXOM_CUSTOMER_SCHEDULE_MNT_V xcsnull on xdps.SITE_ID=xcsnull.CUSTOMER_SITE_ID and xdps.DSTRB_POINT_ID=xcsnull.DSTRB_POINT_ID and xcsnull.SCHEDULE_TYPE='Standard' and xcsnull.IN_STORE_DEL_SCH_END_DATE is null

left outer join apps.XXOM_DSTRB_POINT_MSTR xdpm2 on xcs.DSTRB_POINT_ID=xdpm2.DSTRB_POINT_ID
--to get open and closed dates
left outer join XXSBUX.XXCDH_STORE_ATTRIBS_HDR xcsah on xdps.STORE_NUMBER= xcsah.STORE_NUMBER
--to get fixed ODS flag
left outer join apps.hz_cust_site_uses_all hcsu on xdps.SITE_ID= hcsu.CUST_ACCT_SITE_ID




where 1=1

--MCL end-date has to be in future or blank, doesn't look at start date
and (xdps.end_date > trunc(sysdate) or xdps.end_date is null)

--This is the fixed ODS flag on the customer site record
and upper(hcsu.ATTRIBUTE21) = 'YES'
--Exclude ZD5 drop ship - they don't use ODS, DSDs are typically null, so use nvl
and nvl(mp.ORGANIZATION_CODE,'DSD') <> 'ZD5' 


--these will be null if there is no active or future ODS because we used a left outer join on the ODS table
and (xcs.CUST_SCHED_ID is null or xcsnull.CUST_SCHED_ID is null)


