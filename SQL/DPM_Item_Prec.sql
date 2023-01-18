


select xdps.STORE_NUMBER , xdpi.ITEM_NUMBER , xdpi.ITEM_DESCRIPTION, xdpm.DSTRB_POINT_NUMBER , xdpm.DP_NAME, xdpm.ORGANIZATION_CODE 


from apps.XXOM_DSTRB_POINT_ITEMS_v xdpi
join apps.XXOM_DSTRB_POINT_MSTR_V xdpm on xdpi.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_STORES_V xdps on xdpi.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE= xdsr.STORE_GROUP and xdpi.DSTRB_POINT_ID= xdsr.DSTRB_POINT_ID




----***This sub-query returns the sourcing precedence per item per store
----***join this sub-query back to the main item list by precence to get 
----***the effective DC for each item per store
join (select xdps.SITE_ID "siteid", xdpi.ITEM_ID "itemid", min(xdsr.SOURCING_PRECEDENCE)"prec"
from apps.XXOM_DSTRB_POINT_ITEMS_v xdpi
join apps.XXOM_DSTRB_POINT_MSTR_v xdpm on xdpi.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_STORES_V xdps on xdpi.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE= xdsr.STORE_GROUP and xdpi.DSTRB_POINT_ID= xdsr.DSTRB_POINT_ID
where 1=1
and (xdpi.END_DATE >= trunc(sysdate) or xdpi.END_DATE is null)
group by xdps.SITE_ID, xdpi.ITEM_ID) itmprec on xdpi.ITEM_ID= itmprec."itemid" and xdps.SITE_ID = itmprec."siteid" and xdsr.SOURCING_PRECEDENCE = itmprec."prec"

where 1=1


----***Query by Store Number
--and xdps.STORE_NUMBER=101

----***Query by Item Number per store
--and xdpi.ITEM_NUMBER = '000007360'




--order by xdpi.ITEM_NUMBER

