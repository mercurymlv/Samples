
--select count(*)

select

drh.DELIVERY_ID,
drh.SHIPMENT_PRIORITY,

drh.SHIP_FROM_ORG_CODE,

drh.STORE_NUMBER,
drh.SHIP_TO_ACCOUNT_NUMBER,
drh.SITE_NUMBER,
drh.SHIP_TO_COMPANY_NAME,
drh.BUSINESS_UNIT,

drh.SCAC,
drh.TRANSPORT_MODE,
drh.SERVICE_LEVEL ,
drh.TERMINAL,
drh.RETAIN_CARRIER,
drh.CROSSDOCK_VIA,
drh.CROSSDOCK_DELIVERY_DAY,
drh.CROSSDOCK_SEQ,

to_date(drh.SCHEDULE_SHIP_DATE,'yyyy-mm-dd HH24:MI:SS') "Ship Date",
to_date(drh.DELIVERY_DATE,'yyyy-mm-dd HH24:MI:SS') "Delivery Date",
to_char(to_date(drh.DELIVERY_DATE,'yyyy-mm-dd HH24:MI:SS'),'Day') "In-store Day",

drl.ORDER_NUMBER, drl.ORDER_LINE_NUM, 
drl.ITEM_NUMBER,
msi.DESCRIPTION,
drl.PICK_QUANTITY,
drl.PICK_QUANTITY_UOM


from
apps.xxom_3pl_dlvry_hdrs_pub drh
join apps.xxom_3pl_dlvry_lines_pub drl on drh.DELIVERY_ID= drl.DELIVERY_ID
join  apps.mtl_system_items_b msi on drl.ITEM_NUMBER= msi.SEGMENT1 and msi.ORGANIZATION_ID=101
--join apps.hz_party_sites hps on drh.SITE_NUMBER= hps.PARTY_SITE_NUMBER
--join apps.hz_cust_accounts hca on drh.SHIP_TO_ACCOUNT_NUMBER= hca.ACCOUNT_NUMBER
--join apps.hz_cust_acct_sites_all hcas on hca.CUST_ACCOUNT_ID= hcas.CUST_ACCOUNT_ID and hps.PARTY_SITE_ID= hcas.PARTY_SITE_ID
--join ar.hz_cust_site_uses_all hcsu on hcas.CUST_ACCT_SITE_ID= hcsu.CUST_ACCT_SITE_ID and hcsu.SITE_USE_CODE='SHIP_TO' and hcsu.PRIMARY_FLAG='Y'
--left outer join mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID

where 1=1


--and drh.DELIVERY_ID=1025948515
--and drh.BUSINESS_UNIT = 'FS'
--and drl.ITEM_NUMBER in (11048627,11048860,11057337)


--and drh.SHIP_FROM_ORG_CODE = 'F22'
--
--and drh.STORE_NUMBER in (101)
--and drh.DELIVERY_DATE > '2015-05-01'

order by drh.STORE_NUMBER, drh.DELIVERY_DATE, drl.ORDER_NUMBER, drl.ORDER_LINE_NUM
