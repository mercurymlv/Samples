
--select count(*)

select

drh.DELIVERY_ID,
drh.SHIPMENT_PRIORITY,

drh.SHIP_FROM_ORG_CODE,
ood.ORGANIZATION_NAME,

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
to_char(to_date(drh.DELIVERY_DATE,'yyyy-mm-dd HH24:MI:SS'),'Day') "In-store Day"

--
--drl.ITEM_NUMBER,
--msi.DESCRIPTION,
--drl.PICK_QUANTITY,
--drl.PICK_QUANTITY_UOM
--

from
apps.xxom_3pl_dlvry_hdrs_pub drh
--join xxom_3pl_dlvry_lines_pub drl on drh.DELIVERY_ID= drl.DELIVERY_ID
--join  apps.mtl_system_items_b msi on drl.ITEM_NUMBER= msi.SEGMENT1 and msi.ORGANIZATION_ID=140
join apps.org_organization_definitions ood on drh.SHIP_FROM_ORG_CODE= ood.ORGANIZATION_CODE
--join apps.hz_party_sites hps on drh.SITE_NUMBER= hps.PARTY_SITE_NUMBER
--join apps.hz_cust_accounts hca on drh.SHIP_TO_ACCOUNT_NUMBER= hca.ACCOUNT_NUMBER
--join apps.hz_cust_acct_sites_all hcas on hca.CUST_ACCOUNT_ID= hcas.CUST_ACCOUNT_ID and hps.PARTY_SITE_ID= hcas.PARTY_SITE_ID
--join ar.hz_cust_site_uses_all hcsu on hcas.CUST_ACCT_SITE_ID= hcsu.CUST_ACCT_SITE_ID and hcsu.SITE_USE_CODE='SHIP_TO' and hcsu.PRIMARY_FLAG='Y'
--left outer join mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID

where 1=1

--and drh.DELIVERY_ID='1022191566'

--and drh.BUSINESS_UNIT = 'FS'
--and drl.ITEM_NUMBER=11018181

--and drh.SHIPMENT_PRIORITY='STANDARD'


--and drh.SHIP_FROM_ORG_CODE in ('F22','F26','F21','F24','F27')

--and drh.STORE_NUMBER in (3048,3775,15244,15450,15939,16054,16859,17348,17647,18560,18627,18897,19052,19245,19455,19775,19824,20075,21135,22265,22286,22358,22359,22364,23945,26456,27317,27858,29472,48767,49271,50471,50504,52617,52769,53066,53330,53616,54688,55340,56500,70007,70323,72108,72207,72257,75108,75226,75233,75244,75254,75330,75338,75341,75343,75344,75348,75364,75398,75422,75453,75469,75476,75557,75573,75753,75797,75828,75882,75975,78091)
--and drh.DELIVERY_DATE > '2015-05-01'

and to_date(drh.SCHEDULE_SHIP_DATE,'yyyy-mm-dd HH24:MI:SS') = '2018-11-22'


order by drh.STORE_NUMBER, drh.SHIP_FROM_ORG_CODE, drh.DELIVERY_DATE

