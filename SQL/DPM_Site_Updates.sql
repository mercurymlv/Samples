select 'Site not Fixed ODS' as "Error Message",

cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", 

hca.CUSTOMER_CLASS_CODE "Customer Class",
hp.STATUS "Party Status",
hca.STATUS "Acct Status",
hcsu.STATUS "Site Status",
hcsu.PRIMARY_FLAG "Site Primary Flag",
hcsu.ATTRIBUTE21 "Fixed ODS Flag",
hou.NAME "Site Org",
mp.ORGANIZATION_CODE "Default Warehouse",

otheracct."otracct" "Other active account",

xdpm.DP_NAME "DP Name",
xdpm.DSTRB_POINT_NUMBER "DP Number",
xdps.SOURCING_GROUP_CODE "Source Group",

hp.PARTY_NAME "Name" ,
hl.address1 "Address 1",
hl.address2 "Address 2",
hl.city "City",
hl.postal_code "Postal Code",
nvl(hl.state, hl.PROVINCE) "State/Province",
hl.country "Country"


from

apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
join apps.mtl_parameters mp2 on xdpm.ORGANIZATION_ID = mp2.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID
left outer join
(
select distinct hp.ATTRIBUTE21 "strnam", hca.ACCOUNT_NUMBER || ' - ' || hp.PARTY_NAME "otracct"
from apps.XXOM_DSTRB_POINT_STORES_V xdpsv
join apps.hz_parties hp on xdpsv.STORE_NUMBER= hp.ATTRIBUTE21 and hp.STATUS='A'
join apps.hz_cust_accounts hca on hp.PARTY_ID= hca.PARTY_ID and xdpsv.CUSTOMER_NUMBER <> hca.ACCOUNT_NUMBER and hca.STATUS='A'
) otheracct on hp.ATTRIBUTE21=otheracct."strnam"

where 1=1
and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
and (hcsu.ATTRIBUTE21 <> 'YES' or hcsu.ATTRIBUTE21 is null)

and hcsu.SITE_USE_CODE='SHIP_TO'
--drop ship doesn't use ODS
and mp2.ORGANIZATION_CODE <> 'ZD5'
and hca.CUSTOMER_CLASS_CODE in ('CO_STORE','LS_STORE', 'FRN_CAFE', 'LS_LCNS')
--bulk does not use fixed-ODS - order priority is not compatable
and xdps.SOURCING_GROUP_CODE not like '%Bulk%'


union


select 'Inactive Status' as "Error Message",  cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", otheracct."otracct" "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" , hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID
left outer join
(
select distinct hp.ATTRIBUTE21 "strnam", hca.ACCOUNT_NUMBER || ' - ' || hp.PARTY_NAME "otracct"
from apps.XXOM_DSTRB_POINT_STORES_V xdpsv
join apps.hz_parties hp on xdpsv.STORE_NUMBER= hp.ATTRIBUTE21 and hp.STATUS='A'
join apps.hz_cust_accounts hca on hp.PARTY_ID= hca.PARTY_ID and xdpsv.CUSTOMER_NUMBER <> hca.ACCOUNT_NUMBER and hca.STATUS='A'
) otheracct on hp.ATTRIBUTE21=otheracct."strnam"

where 1=1
and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
and hcsu.SITE_USE_CODE='SHIP_TO'
and (hcas.STATUS='I' or hca.STATUS='I' or  hps.STATUS='I' or  hp.STATUS='I' or  hcsu.STATUS='I')



union



select 'Site not Primary' as "Error Message", cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", otheracct."otracct" "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" , hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID
left outer join
(
select distinct hp.ATTRIBUTE21 "strnam", hca.ACCOUNT_NUMBER || ' - ' || hp.PARTY_NAME "otracct"

from apps.XXOM_DSTRB_POINT_STORES_V xdpsv
join apps.hz_parties hp on xdpsv.STORE_NUMBER= hp.ATTRIBUTE21 and hp.STATUS='A'
join apps.hz_cust_accounts hca on hp.PARTY_ID= hca.PARTY_ID and xdpsv.CUSTOMER_NUMBER <> hca.ACCOUNT_NUMBER and hca.STATUS='A'
) otheracct on hp.ATTRIBUTE21=otheracct."strnam"

where 1=1
and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
and hcsu.SITE_USE_CODE='SHIP_TO'
and hcsu.PRIMARY_FLAG <> 'Y'
--bulk does not necessarily need the site to be primary
and xdps.SOURCING_GROUP_CODE not like '%Bulk%'



union



select 'ODS Site does not match MCL' as "Error Message", cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", '-----' "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" ,hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_CUSTOMER_SCHEDULE xcs
left outer join apps.XXOM_DSTRB_POINT_STORES xdps on xcs.CUSTOMER_SITE_ID=xdps.SITE_ID and xcs.DSTRB_POINT_ID= xdps.DSTRB_POINT_ID and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xcs.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xcs.CUSTOMER_SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID

where 1=1
and xdps.SITE_ID is null
and (xcs.SCH_END_DATE > sysdate or xcs.SCH_END_DATE is null)



union



select 'Billing Site does not match MCL' as "Error Message", cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", '-----' "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" ,hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_DSTRB_POINT_BILL_CHRG xdpbc
left outer join apps.XXOM_DSTRB_POINT_STORES xdps on xdpbc.SITE_ID=xdps.SITE_ID and xdpbc.DSTRB_POINT_ID=xdps.DSTRB_POINT_ID and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdpbc.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdpbc.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID

where 1=1
and (xdpbc.END_DATE > sysdate or xdpbc.END_DATE is null)
and hcsu.SITE_USE_CODE='SHIP_TO'
and xdps.SITE_ID is null


union


select 'CDC Customer with default warehouse' as "Error Message", cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", otheracct."otracct" "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" , hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID
left outer join
(
select distinct hp.ATTRIBUTE21 "strnam", hca.ACCOUNT_NUMBER || ' - ' || hp.PARTY_NAME "otracct"
from apps.XXOM_DSTRB_POINT_STORES_V xdpsv
join apps.hz_parties hp on xdpsv.STORE_NUMBER= hp.ATTRIBUTE21 and hp.STATUS='A'
join apps.hz_cust_accounts hca on hp.PARTY_ID= hca.PARTY_ID and xdpsv.CUSTOMER_NUMBER <> hca.ACCOUNT_NUMBER and hca.STATUS='A'
) otheracct on hp.ATTRIBUTE21=otheracct."strnam"

where 1=1
and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
and hcsu.SITE_USE_CODE='SHIP_TO'
and xdpm.DSTRB_POINT_TYPE_CODE in ('CDC','KIT')
and hcsu.WAREHOUSE_ID is not null
--bulk uses a default warehouse; CDC is only source
and xdps.SOURCING_GROUP_CODE not like '%Bulk%'


union

select 'Default Warehouse does not match DPM' as "Error Message", cast(hp.ATTRIBUTE21 as int) "Store Number", hca.ACCOUNT_NUMBER "Account", hps.PARTY_SITE_NUMBER "Site", hca.CUSTOMER_CLASS_CODE "Customer Class", hp.STATUS "Party Status", hca.STATUS "Acct Status", hcsu.STATUS "Site Status", hcsu.PRIMARY_FLAG "Site Primary Flag", hcsu.ATTRIBUTE21 "Fixed ODS Flag", hou.NAME "Site Org", mp.ORGANIZATION_CODE "Default Warehouse", otheracct."otracct" "Other active account", xdpm.DP_NAME "DP Name", xdpm.DSTRB_POINT_NUMBER "DP Number", xdps.SOURCING_GROUP_CODE "Source Group", hp.PARTY_NAME "Name" , hl.address1 "Address 1", hl.address2 "Address 2", hl.city "City", hl.postal_code "Postal Code", nvl(hl.state, hl.PROVINCE) "State/Province" , hl.country "Country"

from

apps.XXOM_DSTRB_POINT_STORES xdps
join apps.XXOM_DSTRB_POINT_MSTR xdpm on xdps.DSTRB_POINT_ID= xdpm.DSTRB_POINT_ID
join apps.hz_cust_acct_sites_all hcas on xdps.SITE_ID= hcas.CUST_ACCT_SITE_ID
join apps.hz_cust_accounts hca on hcas.CUST_ACCOUNT_ID= hca.CUST_ACCOUNT_ID
join apps.hz_party_sites hps on hcas.PARTY_SITE_ID= hps.PARTY_SITE_ID
join apps.hz_parties hp on hps.PARTY_ID= hp.PARTY_ID
join apps.hz_locations hl on hps.location_id=hl.location_id
join apps.hz_cust_site_uses_all hcsu on hcas.cust_acct_site_id = hcsu.cust_acct_site_id
join apps.hr_operating_units hou on hcsu.ORG_ID=hou.ORGANIZATION_ID
join apps.mtl_parameters mp2 on xdpm.ORGANIZATION_ID = mp2.ORGANIZATION_ID
left outer join apps.mtl_parameters mp on hcsu.WAREHOUSE_ID= mp.ORGANIZATION_ID
left outer join
(
select distinct hp.ATTRIBUTE21 "strnam", hca.ACCOUNT_NUMBER || ' - ' || hp.PARTY_NAME "otracct"
from apps.XXOM_DSTRB_POINT_STORES_V xdpsv
join apps.hz_parties hp on xdpsv.STORE_NUMBER= hp.ATTRIBUTE21 and hp.STATUS='A'
join apps.hz_cust_accounts hca on hp.PARTY_ID= hca.PARTY_ID and xdpsv.CUSTOMER_NUMBER <> hca.ACCOUNT_NUMBER and hca.STATUS='A'
) otheracct on hp.ATTRIBUTE21=otheracct."strnam"

where 1=1
and (xdps.END_DATE > sysdate or xdps.END_DATE is null)
and hcsu.SITE_USE_CODE='SHIP_TO'
--ignore drop ship
and mp2.ORGANIZATION_CODE <> 'ZD5'
and hcsu.WAREHOUSE_ID is not null
and hcsu.WAREHOUSE_ID <> xdpm.ORGANIZATION_ID

order by 2


--Created by Matthew Valdez
--Report mission statement:
--
--This report checks the sites active on the DPM Master Customer List (MCL) for:
--Site is not flagged as fixed-ODS
--Party, account or site is inactive
--Site is not primary
--CDC customer has default warehouse in CM - multisource customer should be blank
--Default warehouse in CM does not match DPM DP assignment
--
--This report will assist the DPM Admin in identifying any site that has been updated by Customer Master. 
--It uses indirect logic - i.e. if the current DPM site has any of these errors, there is probably a new
--site with correct settings or the customer has become inactive. DPM Admin should try adding a new MCL entry for --each customer to see if a new site is available.
--
--Report also checks if site on ODS schedule or Billing Charge does not have entry in MCL; the site should be updated to match a valid MCL site.
