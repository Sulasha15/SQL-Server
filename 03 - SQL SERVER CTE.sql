--------COMMON TABLE EXPRESSION

-----used for single query o/p for small to medium dataset
--A Common Table Expression (CTE) is a construct used to temporarily store the result set of a specified query such that
--it can be referenced by sub-sequent queries. The result of a CTE is not persisted on the disk but instead,
--its lifespan lasts till the execution of the query (or queries) referencing it.
--Users can take advantage of CTEs such that complex queries are split into easier to maintain and read sub-queries.
--Additionally, Common Table Expressions can be referenced multiple times within a single query

-----Exercise
--For this exercise, assume the CEO of our fictional company decided that the top 10 orders per month are actually outliers that need to be clipped out
--of our data before doing meaningful analysis.
--Further, she would like the sum of sales AND purchases (minus these "outliers") listed side by side, by month.
--We've got a query that already does this (see the file "CTEs - Exercise Starter Code.sql" in the resources for this section),
--but it's messy and hard to read. Re-write it using a CTE so other analysts can read and understand the code.

SELECT A.OrderMonth,
       A.TotalSales,
       B.TotalPurchases
FROM
		(
			SELECT OrderMonth,
				   TotalSales = SUM(TotalDue)
			FROM
			(
				SELECT OrderDate,
					   OrderMonth = DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1),
					   TotalDue,
					   OrderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
													  ORDER BY TotalDue DESC
													 )
				FROM AdventureWorks2019.Sales.SalesOrderHeader
			) S
			WHERE OrderRank > 10
			GROUP BY OrderMonth
		) A
JOIN   
		(
			SELECT OrderMonth,
				   TotalPurchases = SUM(TotalDue)
			FROM
			(
				SELECT OrderDate,
					   OrderMonth = DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1),
					   TotalDue,
					   OrderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
													  ORDER BY TotalDue DESC
													 )
				FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
			) P
			WHERE OrderRank > 10
			GROUP BY OrderMonth
		) B
ON A.OrderMonth = B.OrderMonth

ORDER BY 1

----Solution using CTE

WITH

PurchaseDetails AS
		(
			SELECT 
				   OrderDate
				  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
				  ,TotalDue
				  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

			FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
		),

SalesDetails AS
		(
			SELECT 
			   OrderDate
			  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
			  ,TotalDue
			  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
			FROM AdventureWorks2019.Sales.SalesOrderHeader
		),

RemoveTop10Purchase AS
		(
			SELECT
				OrderMonth,
				TotalPurchases = SUM(TotalDue)

			FROM PurchaseDetails

			WHERE OrderRank > 10

			GROUP BY OrderMonth
		),

RemoveTop10Sales AS
		(
			SELECT
				OrderMonth,
				TotalSales = SUM(TotalDue)

			FROM SalesDetails

			WHERE OrderRank > 10

			GROUP BY OrderMonth
		)

SELECT
		A.OrderMonth,
		A.TotalSales,
		B.TotalPurchases

FROM RemoveTop10Sales A
	 JOIN RemoveTop10Purchase B
		ON A.OrderMonth = b.OrderMonth

ORDER BY 1

-------RECURSIVE CTE

--Exercise 1
--Use a recursive CTE to generate a list of all odd numbers between 1 and 100.

WITH OddNumSeries AS

	   (
	    SELECT 1 AS MyNumber

		UNION ALL

		SELECT MyNumber + 1
			FROM OddNumSeries
				WHERE MyNumber < 200
	   )

SELECT MyNumber
	FROM OddNumSeries
		WHERE MyNumber % 2 = 1

OPTION (MAXRECURSION 200)

--Exercise 2
--Use a recursive CTE to generate a date series of all FIRST days of the month (1/1/2021, 2/1/2021, etc.) from 1/1/2020 to 12/1/2029.

WITH DateSeries AS
		(
		SELECT CAST('01-01-2020' AS DATE) AS MyDate

		UNION ALL

		SELECT DATEADD(MONTH, 1, MyDate)
			FROM DateSeries
				WHERE MyDate < CAST('12-01-2029' as date)
	   )

SELECT MyDate
	FROM DateSeries
		
OPTION (MAXRECURSION 200)