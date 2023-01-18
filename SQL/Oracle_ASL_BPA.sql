

select msi.SEGMENT1 "Item Number", msi.DESCRIPTION "Item Description", msi.INVENTORY_ITEM_STATUS_CODE "GMO Status",

pv.VENDOR_NAME "Supplier",
pv.SEGMENT1 "Supplier #",
pvsa.VENDOR_SITE_CODE "Supplier Site", hou.NAME "BU",
nvl(to_char(pas.STATUS),'No ASL') "ASL Status", pasl.CREATION_DATE "ASL Create Date", 
psa.MIN_ORDER_QTY "Min Order Qty", pasl.ATTRIBUTE4 "Max Order Qty", psa.PROCESSING_LEAD_TIME "Lead Time",

nvl(bpa."PO_Type",'No active BPA') "PO Type", 
bpa.BPA "BPA #",
bpa.BPA_UOM "Unit",
bpa."BPA_Price" "Unit Price",
bpa."curr_code" "Currency Code",
bpa."BPA_Start" "BPA Start",
bpa."BPA_End" "BPA End"


from apps.mtl_system_items_b msi
join apps.mtl_parameters mtl on msi.ORGANIZATION_ID=mtl.ORGANIZATION_ID
left outer join apps.po_approved_supplier_list pasl on msi.INVENTORY_ITEM_ID=pasl.ITEM_ID and pasl.USING_ORGANIZATION_ID=-1
left outer join apps.po_vendors pv on pasl.VENDOR_ID= pv.VENDOR_ID
left outer join apps.po_vendor_sites_all pvsa on pasl.VENDOR_SITE_ID= pvsa.VENDOR_SITE_ID
left outer join apps.PO_ASL_STATUSES pas on pasl.ASL_STATUS_ID=pas.STATUS_ID
left outer join apps.po_asl_attributes psa on pasl.ASL_ID= psa.ASL_ID
left outer join apps.hr_operating_units hou on pvsa.ORG_ID= hou.ORGANIZATION_ID

--join to the BPA, use left outer join so that 'null' indicates a missing BPA. I'm using a sub-query because the criterial for 
--selecting the active BPA is complex
left outer join (select  pha.VENDOR_ID "vendid", pha.VENDOR_SITE_ID "siteid", pla.ITEM_ID "itemid", pha.TYPE_LOOKUP_CODE "PO_Type", pha.SEGMENT1 "BPA" , pha.CURRENCY_CODE "curr_code" , pha.START_DATE "BPA_Start", pha.END_DATE "BPA_End",pla.EXPIRATION_DATE "Exp_Date", pha.CLOSED_CODE "Closed_Code", pha.ORG_ID "BPA_Org", pla.CLOSED_CODE, pla.UNIT_MEAS_LOOKUP_CODE "BPA_UOM", pla.UNIT_PRICE "BPA_Price"
from apps.po_headers_all pha
join apps.po_lines_all pla on pha.PO_HEADER_ID= pla.PO_HEADER_ID
where 1=1
and pha.TYPE_LOOKUP_CODE='BLANKET'
and pha.START_DATE <= trunc(sysdate)
and pha.END_DATE >= trunc(sysdate)
and (pla.EXPIRATION_DATE >= trunc(sysdate) or pla.EXPIRATION_DATE is null)
and (pla.CLOSED_CODE ='OPEN' or pla.CLOSED_CODE is null)
) bpa on pasl.VENDOR_ID=bpa."vendid" and pasl.VENDOR_SITE_ID=bpa."siteid" and msi.INVENTORY_ITEM_ID=bpa."itemid"
---***end BPA sub-query


where 1=1

and mtl.ORGANIZATION_CODE = 'GMO'

--and msi.SEGMENT1 in (011092356,011092355)

and pv.SEGMENT1='938361'
and pvsa.VENDOR_SITE_CODE='SMYRNA01'

--Target items
---and msi.SEGMENT1 in (011092356,011092355)


