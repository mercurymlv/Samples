
select ords.*

from
(select ord.ORDER_NUMBER , ord.FROM_LOCATION , ord.SUPPLIER , ord.SUPPLIER_SITE , ord.TO_LOCATION , CASE ord.ORDER_TYPE WHEN 'PA' THEN 'Promotional' WHEN 'PP' THEN 'Promotional' WHEN 'PR' THEN 'Promotional' WHEN 'S2' THEN 'Double Dairy' ELSE 'Standard' END  AS "Schedule_Type", ord.ORDER_PRIORITY , ord.ORDER_STATUS , ord.LOCAL_CREATION_TIMESTAMP , ord.SOURCE_CUTOFF_TIMESTAMP , ord.SOURCE_SHIP_BY_DATE , ord.LOCAL_EXPECTED_DELIVERY_DATE , ord.CREATED_BY_USER , ord.CREATED_BY_PROGRAM , ord.SHORT_COMMENT

from MM4R3LIB.ORDHDR2 ord

where 1=1
and ord.ORDER_TYPE not in ('NS','SH','ST')
and ord.ORDER_STATUS in ('NW','AP','CA','DA','OP','SA','SV','PR')
and ORDER_PRIORITY not in (1,5)
and LEGAL_ENTITY in (100, 302, 128, 142)) ords

where 1=1

and not exists(
select *
from MM4R3LIB.ORDDLVSC ods
where 1=1
and ords.TO_LOCATION= ods.STORE_NUMBER
and ords.FROM_LOCATION=ods.DISTRIBUTION_CENTER
and ords.SUPPLIER=ods.SUPPLIER_ID
and ords.SUPPLIER_SITE=ods.SUPPLIER_SITE_ID
and ords."Schedule_Type"=ods.SCHEDULE_TYPE
and date(ords.SOURCE_CUTOFF_TIMESTAMP)= ods.ORDER_BY_DATE
and ords.SOURCE_SHIP_BY_DATE = ods.ORDER_SHIP_BY_DATE
and ords.LOCAL_EXPECTED_DELIVERY_DATE= ods.ORDER_DELIVER_BY_DATE
)