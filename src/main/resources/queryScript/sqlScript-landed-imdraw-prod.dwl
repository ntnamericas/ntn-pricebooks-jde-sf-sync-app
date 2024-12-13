%dw 2.0
output text/plain
--- 
"WITH 

DRDL01_IBPRP4 AS (
	-- Step 1: Retrieve DRDL01 values for IBPRP4 from UDC 41/P4
    SELECT Y1.DRDL01 AS DRDLO1, Y1.DRKY
    FROM TESTCTL.F0005 Y1
    WHERE TRIM(Y1.DRSY) = '41' AND TRIM(Y1.DRRT) = 'P4'  AND
    ( TRIM(Y1.DRUPMJ) >= $(vars.productsJobRun.date) AND TRIM(Y1.DRUPMT) >= $(vars.previousProductsJobRun.time))
),


IBLTLV_IBLITM AS (
	-- Step 2: Get IBLITM and IBLTLV from F4102 based on criteria
    SELECT IBLITM, IBLTLV
    FROM TESTDTA.F4102
    WHERE  (TRIM(IBUPMJ) >= $(vars.productsJobRun.date) AND TRIM(IBTDAY) >= $(vars.previousProductsJobRun.time))
	--AND TRIM(IBLITM) = '6203[TB00]'
),

IMDRAW_IMSRTX_IBLTLV AS (
	-- Step 3: Retrieve IMDRAW and IMSRTX from F4101 where IMLITM matches IBLITM
    SELECT TT10.IMDRAW, TT10.IMSRTX, TT10.IMLITM
    FROM TESTDTA.F4101 TT10
    INNER JOIN IBLTLV_IBLITM TT11 ON TRIM(TT10.IMLITM) = TRIM(TT11.IBLITM)
),


IMLITM_IMSRTX_IBLTLV AS (
	-- Step 4: Filter F4101 records based on IMSRTX, retrieve IMLITM and IMPRP1
    SELECT TT13.IMLITM, TT13.IMPRP1
    FROM TESTDTA.F4101 TT13
    INNER JOIN IMDRAW_IMSRTX_IBLTLV TT14 ON TRIM(TT13.IMSRTX) = TRIM(TT14.IMSRTX)
),


MINMAX_IBLTLV_IMSRTX AS (
	-- Step 5: Find min and max IBLTLV values for each IBLITM in F4102 where IBMCU = '1801'
    SELECT TT16.IBLITM, MIN(TT16.IBLTLV) AS MIN_IBLTLV, MAX(TT16.IBLTLV) AS MAX_IBLTLV
    FROM TESTDTA.F4102 TT16
    INNER JOIN IMLITM_IMSRTX_IBLTLV TT17 ON TRIM(TT16.IBLITM) = TRIM(TT17.IMLITM)
    WHERE TRIM(TT16.IBMCU) = '1801'
    GROUP BY TT16.IBLITM
),
IMLITM_IMDRAW_IBLTLV AS (
    ---In F4101, query all IMLITM where IMDRAW = (variable) IMDRAW and where IMPRP1 = IBPRP1 and IMSRP4 = IBSRP4.Create a result set / collection of LITM for DRAW
    SELECT TRIM(TT12.IMLITM) AS IMLITM
    FROM TESTDTA.F4101 TT12
    LEFT JOIN IMDRAW_IMSRTX_IBLTLV TT13
    ON TRIM(TT12.IMDRAW)=TRIM(TT13.IMDRAW)
    
),
IBPRP5_IMDRAW AS (
    ---loop through DRAW collection and get value of IBPRP5 where IBLITM = IMLITM and IBMCU=1801.Hold value of PRP5
    SELECT TRIM(TT18.IBPRP5) AS IBPRP5, TRIM(TT18.IBLITM) AS IBLITM
    FROM TESTDTA.F4102 TT18
    JOIN IMLITM_IMDRAW_IBLTLV TT19 ON
    TRIM(TT18.IBLITM) = (TT19.IMLITM)
    WHERE TRIM(TT18.IBMCU)='1801'
),
IBPRP5_IMSRTX AS (
    --- Loop through SRTX collection and get value of IBPRP5 where IBLITM = IMLITM and IBMCU=1801
    SELECT TRIM(TT20.IBPRP5) AS IBPRP5, TRIM(TT20.IBLITM) AS IBLITM
    FROM TESTDTA.F4102 TT20
    JOIN MINMAX_IBLTLV_IMSRTX TT19 ON
    TRIM(TT20.IBLITM) = TRIM(TT19.IBLITM)
    WHERE TRIM(TT20.IBMCU) = '1801'
),
DRAW_COST AS (
  -- Calculate SUM(IGPCST) in F41291 for DRAW collection
  SELECT T1.IBLITM, SUM((T3.IGPCST)/1000000000) AS Total_Cost_Draw
  FROM IBPRP5_IMDRAW T1
  JOIN TESTDTA.F41291 T3 ON TRIM(T1.IBPRP5) = TRIM(T3.IGPRP5)
  WHERE TRIM(T3.IGLVLA) != " ++ "'\$'" ++ "
    AND TRIM(T3.IGEFFF) > 124140 AND TRIM(T3.IGEFFT) < 123280
  GROUP BY T1.IBLITM
),
SRTX_COST AS (
  -- Calculate SUM(IGPCST) in F41291 for SRTX collection
  SELECT T1.IBLITM, SUM((T3.IGPCST)/1000000000) AS Total_Cost_SRTX
  FROM IBPRP5_IMSRTX T1
  JOIN TESTDTA.F41291 T3 ON TRIM(T1.IBPRP5) = TRIM(T3.IGPRP5)
  WHERE TRIM(T3.IGLVLB) != " ++ "'\$'" ++ "
    AND TRIM(T3.IGEFFF) > 124140 AND TRIM(T3.IGEFFT) < 124280
  GROUP BY T1.IBLITM
)

SELECT
    T1.IBPRP1,
    T1.IBMCU,
    T1.IBPRP4,
    T1.IBLITM,
    T1.IBSRP4,
    T1.IBSRP2,
    T1.IBSRP1,
    T1.IBPRP5,
    T1.IBPRP7,
    T1.IBSTKT,
    T2.IMLITM,
    T2.IMSRTX,
    T16.IMDRAW AS IMDRAW_IBLTLV,
    T16.IMSRTX AS IMSRTX_IBLTLV,
    T17.IMLITM AS IMLITM_IBLTLV,
    MIN(DRAW_COST.Total_Cost_Draw) AS Landed_Cost_Min_Draw,    -- Minimum Landed Cost for DRAW collection
    MAX(DRAW_COST.Total_Cost_Draw) AS Landed_Cost_Max_Draw    -- Minimum Landed Cost for DRAW collection

FROM TESTDTA.F4102 T1
INNER JOIN TESTDTA.F4101 T2 
    ON TRIM(T1.IBLITM) = TRIM(T2.IMLITM) AND TRIM(T1.IBMCU) = '1801'
LEFT JOIN IMDRAW_IMSRTX_IBLTLV T16 
    ON TRIM(T16.IMLITM) = TRIM(T2.IMLITM)
LEFT JOIN IMLITM_IMSRTX_IBLTLV T17 
    ON TRIM(T17.IMLITM) = TRIM(T2.IMLITM)
LEFT JOIN DRAW_COST ON TRIM(T2.IMLITM) = DRAW_COST.IBLITM
LEFT JOIN SRTX_COST ON TRIM(T2.IMLITM) = SRTX_COST.IBLITM
 
WHERE 
    ((T2.IMUPMJ >= $(vars.productsJobRun.date) AND T2.IMTDAY >= $(vars.previousProductsJobRun.time)) 
	OR (T12.DRUPMJ >= $(vars.productsJobRun.date) AND T12.DRUPMT >= $(vars.previousProductsJobRun.time)))
    --T2.IMLITM = '6203[TB00]'
GROUP BY
    T1.IBPRP4, T1.IBLITM, T1.IBSTKT, T1.IBSRP4, T1.IBMCU, T1.IBSRP2, T1.IBSRP1, T2.IMLITM,
    T2.IMSRTX, T1.IBPRP1, T1.IBPRP5, T1.IBPRP7, T16.IMDRAW, T16.IMSRTX, T17.IMLITM
"