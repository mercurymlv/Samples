


select IM.STORE_NUMBER, IM.ITEM_NUMBER , invmst.IDESCR, OSG.STORE_GROUP, IM.DEFAULT_ORDER_METHOD , IM.STATUS, IM.SOURCE, IM.SOURCE_TYPE, IM.SUPL_SITE, IM.CHANGE_TS

from MM4R3LIB.ITMSTR IM
join MM4R3LIB.ORDSTRGP OSG on IM.STORE_NUMBER= OSG.STORE_NUMBER
join MM4R3LIB.invmst invmst on IM.ITEM_NUMBER= invmst.INUMBR


where 1=1


and IM.STORE_NUMBER in (19240,14807,9568,22722,2730,2878,11135,22426,3437,22428,2920,11364,10984,10058,6611,6835,10334,10416,2936,10849)


and IM.STATUS='A'


--and IM.SOURCE=58933


--and IM.ITEM_NUMBER in (11011644,11008594,11007221,11007222,11007223,1237515,1237514,1237505,1237504,192269,504168,11002137,11022911,11022914,11022917,11008677,11011177,11011169,11011168,11011170,11015834,11031059,11031984,11031985,11029622,11031986,11038880,11020717,11031636,11033209,11023995,11002905,11031656,11011171,11037544,11037542,11032991,11032989,11032990,11039031,11039034,11033926,11033923,11033924,11033922,11035636,11039032,11039029,11039039,11039040,11039041,11039042,11008663,11024402)

--and IM.SOURCE_TYPE='V'

order by IM.ITEM_NUMBER









