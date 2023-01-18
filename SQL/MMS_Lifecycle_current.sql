Select stran.STORE_NUMBER , tbl2.OWNERSHIP_TYPE "BU", stt.TRANSITION_DESCRIPTION, stran.TRANSITION_START_DATE , stran.TRANSITION_END_DATE, tbltran.STARTING_PHASE , tbltran.ENDING_PHASE , tbltran.OPEN_FOR_BUSINESS 

from MM4R3LIB.STRTRN stran
join MM4R3LIB.TBLTRN tbltran on stran.TRANSITION_ID= tbltran.TRANSITION_ID
join MM4R3LIB.TBLTRNTL stt on stran.TRANSITION_ID=stt.TRANSITION_ID and stt.LANGUAGE_ID='ENG'
join MM4R3LIB.TBLSTR tbl on stran.STORE_NUMBER= tbl.STRNUM
join MM4R3LIB.TBLSTR2 tbl2 on tbl.STRNUM= tbl2.STORE_NUMBER
where 1=1



---Legal Entity desc in MM4R3LIB.GLCNTL
and tbl.STCOMP in (100,128,142,150,152,160,302)

and stran.TRANSITION_START_DATE <= curdate()
and (stran.TRANSITION_END_DATE >= curdate() or stran.TRANSITION_END_DATE = '0001-01-01')

--and stran.STORE_NUMBER=3763

--and stt.TRANSITION_DESCRIPTION='Remodeling'

--Closure Complete
--Development Began
--Development Cancelled
--Development On-Hold
--Development Restarted
--Disaster Occurred
--Failed Health Inspection
--Off-Season Start
--Open to Public
--Relocating
--Remodeling
--Retail Turnover



order by stran.STORE_NUMBER

