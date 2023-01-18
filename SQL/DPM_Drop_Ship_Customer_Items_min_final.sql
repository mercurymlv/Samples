

select xdps.CUSTOMER_NUMBER "Customer Number", xdps.PARTY_SITE_NUMBER "Customer Site" , xdps.SOURCING_GROUP_CODE "Customer Source Group", xdps.PARTY_NAME "Customer Name", xdps.CUSTOMER_ADDRESS "Customer Address", xdps.STATE "State", xdps.CITY "City", msi.SEGMENT1 "Item Number",  msi.DESCRIPTION "Item Description", xdpi.START_DATE "DPM Start Date" , xdpi.END_DATE "DPM End Date",xdpm.DSTRB_POINT_NUMBER "DP Number" , xdpm.DP_NAME "DP Name", pv.VENDOR_NAME "Supplier" , pv.SEGMENT1 "Supplier #",  pvsa.VENDOR_SITE_CODE "Supplier Site", pvsa.VENDOR_SITE_ID "Supplier Site ID"


--start with the DPM Master Order Guide
from apps.XXOM_DSTRB_POINT_ITEMS xdpi

join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdpi.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
join apps.mtl_parameters mtl on xdpm.ORGANIZATION_ID=mtl.ORGANIZATION_ID
left outer join apps.mtl_system_items_b msi on xdpi.ITEM_ID= msi.INVENTORY_ITEM_ID and msi.ORGANIZATION_ID=mtl.MASTER_ORGANIZATION_ID
join apps.po_vendors pv on xdpm.VENDOR_ID= pv.VENDOR_ID
join apps.po_vendor_sites_all pvsa on xdpm.VENDOR_SITE_ID=pvsa.VENDOR_SITE_ID

--these lines join the customer tables to the items, so that you get a full list of every item for every customer
join apps.XXOM_DSTRB_POINT_STORES_V xdps on xdpi.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE= xdsr.STORE_GROUP and xdpi.DSTRB_POINT_ID= xdsr.DSTRB_POINT_ID


--this is a sub-query that determines item-sourcing if the same item number is available from multiple suppliers
--basically, it builds of list of customers and items and the 'minimum' precedence' for each item
--this list is joined to the main query and selects by precedence to ensure that we are only
--returning the item with the lowest DPM sourcing precedence
join
(select xdps.SITE_ID "siteid", xdpi.ITEM_ID "itemid", min(xdsr.SOURCING_PRECEDENCE)"prec"
from apps.XXOM_DSTRB_POINT_ITEMS xdpi
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdpi.DSTRB_POINT_ID=xdpm.DSTRB_POINT_ID
join apps.XXOM_DSTRB_POINT_STORES xdps on xdpi.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID
join apps.XXOM_DP_SOURCING_RULES xdsr on xdps.SOURCING_GROUP_CODE= xdsr.STORE_GROUP and xdpi.DSTRB_POINT_ID= xdsr.DSTRB_POINT_ID
where 1=1
--139 is ZD5
and xdpm.ORGANIZATION_ID=139
and trunc(xdpi.START_DATE)<=sysdate
and (trunc(xdpi.END_DATE) >= sysdate or xdpi.END_DATE is null)
group by xdps.SITE_ID, xdpi.ITEM_ID) dsi on xdpi.ITEM_ID= dsi."itemid" and xdps.SITE_ID = dsi."siteid" and xdsr.SOURCING_PRECEDENCE = dsi."prec"


where 1=1

--only return DPM DPs that use ZD5 - this should only be the drop-ship DPs
and mtl.ORGANIZATION_CODE='ZD5'
 

order by xdps.SITE_ID , pv.VENDOR_NAME, pvsa.VENDOR_SITE_CODE
