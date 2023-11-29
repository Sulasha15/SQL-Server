----TEMP TABLES

--Temporary Tables are most likely as Permanent Tables. Temporary Tables are Created in TempDB and are automatically deleted as soon as
--the last connection is terminated.
--Temporary Tables helps us to store and process intermediate results.
--Temporary tables are very useful when we need to store temporary data.

----Exercise
----Refactor your solution to the exercise from the section on CTEs (average sales/purchases minus top 10) using temp tables in place of CTEs.

SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

		  INTO #PurchaseDetails

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
	
SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

		  INTO #SalesDetails

FROM AdventureWorks2019.Sales.SalesOrderHeader
		

SELECT

	OrderMonth,
	TotalPurchases = SUM(TotalDue)

	INTO #RemoveTop10Purchase

FROM #PurchaseDetails

	WHERE OrderRank > 10

	GROUP BY OrderMonth


SELECT

	OrderMonth,
	TotalSales = SUM(TotalDue)

	INTO #RemoveTop10Sales

FROM #SalesDetails

	WHERE OrderRank > 10

	GROUP BY OrderMonth

SELECT
		A.OrderMonth,
		A.TotalSales,
		B.TotalPurchases

FROM #RemoveTop10Sales A
	 JOIN #RemoveTop10Purchase B
		ON A.OrderMonth = b.OrderMonth

ORDER BY 1

----best practise to drop table once session is completed so that it can we resused
DROP TABLE #PurchaseDetails
DROP TABLE #SalesDetails
DROP TABLE #RemoveTop10Purchase
DROP TABLE #RemoveTop10Sales

--------TEMP TABLE USING CREATE AND INSERT

----Exercise
----Rewrite your solution  using CREATE and INSERT instead of SELECT INTO.

CREATE TABLE #PurchaseDetails
			(
				 OrderDate DATE
				,OrderMonth DATE
				,TotalDue MONEY
				,OrderRank INT
			)

INSERT INTO #PurchaseDetails
			(
				 OrderDate		 
			    ,OrderMonth
				,TotalDue 
				,OrderRank
			)
		SELECT 
			   OrderDate
			  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
			  ,TotalDue
			  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
	
CREATE TABLE #RemoveTop10Purchase
	(
		OrderMonth DATE,
		TotalPurchases INT
	)

INSERT INTO #RemoveTop10Purchase
	(
		OrderMonth,
		TotalPurchases 
	)
	SELECT
			OrderMonth,
			TotalPurchases = SUM(TotalDue)

	FROM #PurchaseDetails

	WHERE OrderRank > 10

	GROUP BY OrderMonth

CREATE TABLE #SalesDetails
	(
		 OrderDate DATE
		,OrderMonth DATE
		,TotalDue MONEY
		,OrderRank INT
	)

INSERT INTO #SalesDetails
		(
				   OrderDate
				  ,OrderMonth
				  ,TotalDue 
				  ,OrderRank
		)
	SELECT

		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		
	FROM AdventureWorks2019.Sales.SalesOrderHeader

CREATE TABLE  #RemoveTop10Sales
	(
	OrderMonth DATE,
	TotalSales INT
	)

INSERT INTO  #RemoveTop10Sales
	(
	OrderMonth,
	TotalSales
	)
	SELECT

			OrderMonth,
			TotalSales = SUM(TotalDue)
	 
	FROM #SalesDetails

	WHERE OrderRank > 10

	GROUP BY OrderMonth

SELECT

		A.OrderMonth,
		A.TotalSales,
		B.TotalPurchases

FROM #RemoveTop10Sales A
	 JOIN #RemoveTop10Purchase B
		ON A.OrderMonth = b.OrderMonth

ORDER BY 1

DROP TABLE #PurchaseDetails
DROP TABLE #SalesDetails
DROP TABLE #RemoveTop10Purchase
DROP TABLE #RemoveTop10Sales

-------USING TRUNCATE TO REUSE THE TEMP TABLE CREATED

---Exercise
---Leverage TRUNCATE to re-use temp tables in your solution to "CREATE and INSERT" exercise.

CREATE TABLE #OrderDetails ----create a temp order details table
		(
			 OrderDate DATE
			,OrderMonth DATE
			,TotalDue MONEY
			,OrderRank INT
		 
		)

INSERT INTO  #OrderDetails ----------insert sales data
		(
			 OrderDate
			,OrderMonth
			,TotalDue 
			,OrderRank
		  
		)
		SELECT

		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		 
		FROM AdventureWorks2019.Sales.SalesOrderHeader



CREATE TABLE #ExcludeTop10Orders -----create temp table to maintain sales/purchase records excluding top 10
	(
		OrderMonth DATE,
		OrderType VARCHAR(10),
		TotalDue INT
	)

INSERT INTO #ExcludeTop10Orders -----insert sales records excluding top 10
	(
		OrderMonth,
		OrderType,
		TotalDue
	)
	SELECT

			OrderMonth,
			OrderType = 'Sales',
			TotalDue = SUM(TotalDue)

	from #OrderDetails

	WHERE OrderRank > 10

	GROUP BY OrderMonth

-----empty data 
TRUNCATE TABLE #OrderDetails

	
INSERT INTO #OrderDetails ----------insert purchase data
		(
			 OrderDate
			,OrderMonth
			,TotalDue 
			,OrderRank
		)
		SELECT 

			   OrderDate
			  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
			  ,TotalDue
			  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		
		FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader


INSERT INTO #ExcludeTop10Orders ---insert purchase records excluding top 10
		(
			OrderMonth,
			OrderType,
			TotalDue
		)
		SELECT
				OrderMonth,
				OrderType = 'Purchase',
				TotalDue = SUM(TotalDue)
	 
		FROM #OrderDetails

		WHERE OrderRank > 10

		GROUP BY OrderMonth

SELECT

		A.OrderMonth,
		TotalSales = A.TotalDue,
		TotalPurchase = B.TotalDue

FROM #ExcludeTop10Orders A
	 JOIN #ExcludeTop10Orders B
		ON A.OrderMonth = b.OrderMonth

WHERE a.OrderType='Sales' and b.OrderType='Purchase'
		

ORDER BY 1

DROP TABLE #OrderDetails
DROP TABLE #ExcludeTop10Orders

---UPDATE 

----Starter Code

CREATE TABLE #SalesOrders
	(
		SalesOrderID INT,
		OrderDate DATE,
		TaxAmt MONEY,
		Freight MONEY,
		TotalDue MONEY,
		TaxFreightPercent FLOAT,
		TaxFreightBucket VARCHAR(32),
		OrderAmtBucket VARCHAR(32),
		OrderCategory VARCHAR(32),
		OrderSubcategory VARCHAR(32)
	)

INSERT INTO #SalesOrders
	(
		SalesOrderID,
		OrderDate,
		TaxAmt,
		Freight,
		TotalDue,
		OrderCategory
	)
	SELECT SalesOrderID,
		   OrderDate,
		   TaxAmt,
		   Freight,
		   TotalDue,
		   OrderCategory = 'Non-holiday Order'

	FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]

	WHERE YEAR(OrderDate) = 2013


UPDATE #SalesOrders
SET TaxFreightPercent = (TaxAmt + Freight) / TotalDue,
    OrderAmtBucket = CASE
                         WHEN TotalDue < 100 THEN
                             'Small'
                         WHEN TotalDue < 1000 THEN
                             'Medium'
                         ELSE
                             'Large'
                     END


UPDATE #SalesOrders
SET TaxFreightBucket = CASE
                           WHEN TaxFreightPercent < 0.1 THEN
                               'Small'
                           WHEN TaxFreightPercent < 0.2 THEN
                               'Medium'
                           ELSE
                               'Large'
                       END


UPDATE #SalesOrders
	SET OrderCategory = 'Holiday'

FROM #SalesOrders

WHERE DATEPART(QUARTER, OrderDate) = 4

--Exercise
--Using the code in the "Update - Exercise Starter Code.sql" file in the resources for this section (which is the same as the example presented in the video),
--update the value in the "OrderSubcategory" field as follows:
--The value in the field should consist of the following string values concatenated together in this order:
--The value in the "OrderCategory" field
--A space
--A hyphen
--Another space
--The value in the "OrderAmtBucket" field
--The values in the field should look like the following:

UPDATE #SalesOrders
SET OrderSubcategory = OrderCategory + '-' + OrderAmtBucket

SELECT * FROM #SalesOrders

DROP TABLE #SalesOrders