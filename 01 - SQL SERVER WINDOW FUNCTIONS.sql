----WINDOWS FUNCTIONS

--Window functions applies aggregate and ranking functions over a particular window (set of rows).
--OVER clause is used with window functions to define that window. OVER clause does two things : 
--Partitions rows into form set of rows. (PARTITION BY clause is used) 
--Orders rows within those partitions into a particular order. (ORDER BY clause is used) 
-- If partitions aren’t done, then ORDER BY orders all rows of table. 

-------EXERCISE OVER()

--Exercise 1
--Create a query with the following columns:
--FirstName and LastName, from the Person.Person table
--JobTitle, from the HumanResources.Employee table
--Rate, from the HumanResources.EmployeePayHistory table
--A derived column called "AverageRate" that returns the average of all values in the "Rate" column, in each row

--HINT: All the above tables can be joined on BusinessEntityID
--All the tables can be inner joined, and you do not need to apply any criteria.

--Exercise 2
--Enhance your query from Exercise 1 by adding a derived column called
--"MaximumRate" that returns the largest of all values in the "Rate" column, in each row.

--Exercise 3
--Enhance your query from Exercise 2 by adding a derived column called
--"DiffFromAvgRate" that returns the result of the following calculation:
--An employees's pay rate, MINUS the average of all values in the "Rate" column.

--Exercise 4
--Enhance your query from Exercise 3 by adding a derived column called
--"PercentofMaxRate" that returns the result of the following calculation:
--An employees's pay rate, DIVIDED BY the maximum of all values in the "Rate" column, times 100.


select

  a.FirstName, 
  a.LastName, 
  b.JobTitle, 
  c.Rate, 
  AverageRate = AVG(c.Rate) over(), ----1
  MaximumRate = MAX(c.Rate) over(), ----2
  DiffFromAvgRate = (c.Rate)- AVG(c.Rate) over(), -----3
  PercentOfMaxRate = (
						(c.Rate)/ MAX(c.Rate) over()
					 )* 100 ----------4

from 

  [AdventureWorks2019].[Person].[Person] a 
  join [AdventureWorks2019].[HumanResources].[Employee] b 
		on a.BusinessEntityID = b.BusinessEntityID 
  join [AdventureWorks2019].[HumanResources].EmployeePayHistory c 
		on a.BusinessEntityID = c.BusinessEntityID;

-----EXERCISE OVER(PARTITON BY)

--Exercise 1
--Create a query with the following columns:
--“Name” from the Production.Product table, which can be alised as “ProductName”
--“ListPrice” from the Production.Product table
--“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”*
--“Name” from the Production.ProductCategory table, which can be alised as “ProductCategory”**
--Join Production.ProductSubcategory to Production.Product on “ProductSubcategoryID”
--Join Production.ProductCategory to ProductSubcategory on “ProductCategoryID”
--All the tables can be inner joined, and you do not need to apply any criteria.

--Exercise 2
--Enhance your query from Exercise 1 by adding a derived column called
--"AvgPriceByCategory " that returns the average ListPrice for the product category in each given row.

--Exercise 3
--Enhance your query from Exercise 2 by adding a derived column called
--"AvgPriceByCategoryAndSubcategory" that returns the average ListPrice for the product category AND subcategory in each given row.

--Exercise 4:
--Enhance your query from Exercise 3 by adding a derived column called
--"ProductVsCategoryDelta" that returns the result of the following calculation:
--A product's list price, MINUS the average ListPrice for that product’s category.


select 

  ProductName = a.Name, 
  a.ListPrice, 
  ProductSubcategory = b.Name, 
  ProductCategory = c.Name, 
  AvgPriceByCategory = avg(a.ListPrice) over(partition by c.Name), ---2
  AvgPriceByCategoryAndSubcategory = avg(a.ListPrice) over(partition by b.Name, c.Name), ----3
  ProductVsCategoryDelta = a.ListPrice - avg(a.ListPrice) over(partition by c.Name) ----4

from 

  AdventureWorks2019.Production.Product a 
  join AdventureWorks2019.Production.ProductSubcategory b 
	on a.ProductSubcategoryID = b.ProductSubcategoryID 
  join AdventureWorks2019.Production.ProductCategory c 
	on b.ProductCategoryID = c.ProductCategoryID -----------1

----ROW_NUMBER()

--It assigns consecutive integers to all the rows within partition. Within a partition, no two rows can have same row number. 
--Note
--ORDER BY() should be specified compulsorily while using rank window functions. 

-------EXERCISE ROWNUM()

--Exercise 1
--Create a query with the following columns
--“Name” from the Production.Product table, which can be alised as “ProductName”
--“ListPrice” from the Production.Product table
--“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”*
--“Name” from the Production.ProductCategory table, which can be alised as “ProductCategory”**
--Join Production.ProductSubcategory to Production.Product on “ProductSubcategoryID”
--Join Production.ProductCategory to ProductSubcategory on “ProductCategoryID”
--All the tables can be inner joined, and you do not need to apply any criteria.

--Exercise 2
--Enhance your query from Exercise 1 by adding a derived column called
--"Price Rank " that ranks all records in the dataset by ListPrice, in descending order.
--That is to say, the product with the most expensive price should have a rank of 1,
--and the product with the least expensive price should have a rank equal to the number of records in the dataset.

--Exercise 3
--Enhance your query from Exercise 2 by adding a derived column called
--"Category Price Rank" that ranks all products by ListPrice – within each category - in descending order.
--In other words, every product within a given category should be ranked relative to other products in the same category.

--Exercise 4
--Enhance your query from Exercise 3 by adding a derived column called
--"Top 5 Price In Category" that returns the string “Yes” if a product has one of the top 5 list prices in its product category,
--and “No” if it does not. You can try incorporating your logic from Exercise 3 into a CASE statement to make this work.


SELECT 

  ProductName = a.Name, 
  a.ListPrice, 
  ProductSubcategory = b.Name, 
  ProductCategory = c.Name,

  PriceRank = ROW_NUMBER() OVER(ORDER BY a.ListPrice DESC), ------------2
  CategoryPriceRank = ROW_NUMBER() OVER(PARTITION BY c.Name ORDER BY a.ListPrice DESC), ------3
  Top5PriceInCategory =
	CASE 
		 WHEN (ROW_NUMBER() OVER(PARTITION BY c.Name ORDER BY a.ListPrice DESC)) <= 5
			THEN 'Yes'
		 ELSE 'No' 
	END -----------4

FROM 

  AdventureWorks2019.Production.Product a 
  join AdventureWorks2019.Production.ProductSubcategory b 
		ON a.ProductSubcategoryID = b.ProductSubcategoryID 
  join AdventureWorks2019.Production.ProductCategory c 
		ON b.ProductCategoryID = c.ProductCategoryID -------1

--RANK()

--As the name suggests, the rank function assigns rank to all the rows within every partition.
--Rank is assigned such that rank 1 given to the first row and rows having same value are assigned same rank. For the next rank after two same rank values, one rank value will be skipped. 
 

--DENSE_RANK()

--It assigns rank to each row within partition. Just like rank function first row is assigned rank 1 and rows having same value have same rank.
--The difference between RANK() and DENSE_RANK() is that in DENSE_RANK(), for the next rank after two same rank, consecutive integer is used,
--no rank is skipped. 


------EXERCISE RANK(), DENSE_RANK()

--Exercise 1
--Using your solution query to Exercise 4 from the ROW_NUMBER exercises as a staring point,
--add a derived column called “Category Price Rank With Rank” that uses the RANK function to rank all products by ListPrice – within each category -
--in descending order. Observe the differences between the “Category Price Rank” and “Category Price Rank With Rank” fields.

--Exercise 2
--Modify your query from Exercise 2 by adding a derived column called "Category Price Rank With Dense Rank" that that uses the
--DENSE_RANK function to rank all products by ListPrice – within each category - in descending order.
--Observe the differences among the “Category Price Rank”, “Category Price Rank With Rank”, and “Category Price Rank With Dense Rank” fields.

--Exercise 3
--Examine the code you wrote to define the “Top 5 Price In Category” field back in the ROW_NUMBER exercises.
--Now that you understand the differences among ROW_NUMBER, RANK, and DENSE_RANK,
--consider which of these functions would be most appropriate to return a true top 5 products by price,
---assuming we want to see the top 5 distinct prices AND we want “ties” (by price) to all share the same rank.

SELECT 

	   ProductName = a.Name,
       a.ListPrice,
       ProductSubcategory = b.Name,
       ProductCategory = c.Name,

       PriceRank = ROW_NUMBER() OVER (ORDER BY a.ListPrice DESC),
       CategoryPriceRank = ROW_NUMBER() OVER (partition by c.Name ORDER BY a.ListPrice DESC),
       [Category Price Rank With Rank] = RANK() OVER (PARTITION BY c.Name ORDER BY a.ListPrice DESC), -----1
       [Category Price Rank With Dense Rank] = DENSE_RANK() OVER (PARTITION BY c.Name ORDER BY a.ListPrice DESC), ------2
       Top5PriceInCategory = CASE
                                 WHEN DENSE_RANK() OVER (partition by c.Name ORDER BY a.ListPrice DESC) <= 5 
									THEN
										'Yes'
                                 ELSE
										'No'
                             END -------------3
FROM

	AdventureWorks2019.Production.Product a
    JOIN AdventureWorks2019.Production.ProductSubcategory b
        ON a.ProductSubcategoryID = b.ProductSubcategoryID
    JOIN AdventureWorks2019.Production.ProductCategory c
        ON b.ProductCategoryID = c.ProductCategoryID

--LAG and LEAD

--The LAG function has the ability to fetch data from a previous row, while LEAD fetches data from a subsequent row. 
--The LAG/LEAD function has also two optional parameters:
--The offset. The default is 1, but you can jump back more rows by specifying a bigger offset. You cannot specify a negative value.
--A default value. When there is no previous row (in the case of LAG), NULL is returned. You can see this in the screenshot in the first row.
--You can specify a default value to be returned instead of NULL.

------EXERCISE LAG and LEAD

--Exercise 1
--Create a query with the following columns:
--“PurchaseOrderID” from the Purchasing.PurchaseOrderHeader table
--“OrderDate” from the Purchasing.PurchaseOrderHeader table
--“TotalDue” from the Purchasing.PurchaseOrderHeader table
--“Name” from the Purchasing.Vendor table, which can be aliased as “VendorName”
--Join Purchasing.Vendor to Purchasing.PurchaseOrderHeader on BusinessEntityID = VendorID
--Apply the following criteria to the query:
--Order must have taken place on or after 2013
--TotalDue must be greater than $500

--Exercise 2
--Modify your query from Exercise 1 by adding a derived column called
--"PrevOrderFromVendorAmt", that returns the “previous” TotalDue value (relative to the current row) within the group of all orders
----with the same vendor ID. We are defining “previous” based on order date.

--Exercise 3
--Modify your query from Exercise 2 by adding a derived column called
--"NextOrderByEmployeeVendor", that returns the “next” vendor name (the “name” field from Purchasing.Vendor) within the group of all orders
---that have the same EmployeeID value in Purchasing.PurchaseOrderHeader. Similar to the last exercise, we are defining “next” based on order date.

--Exercise 4
--Modify your query from Exercise 3 by adding a derived column called "Next2OrderByEmployeeVendor" that returns, within the group of all orders
---that have the same EmployeeID, the vendor name offset TWO orders into the “future” relative to the order in the current row.
---The code should be very similar to Exercise 3, but with an extra argument passed to the Window Function used.

SELECT 
	   A.PurchaseOrderID,
       A.OrderDate,
       A.TotalDue,
       [Vendor Name] = B.Name,

       PrevOrderFromVendorAmt = LAG(A.TotalDue) OVER (PARTITION BY a.VendorID ORDER BY a.OrderDate),-----2
       NextOrderByEmployeeVendor = LEAD(B.Name) OVER (PARTITION BY a.EmployeeID ORDER BY a.OrderDate),-----3
       Next2OrderByEmployeeVendor = LEAD(B.Name, 2) OVER (PARTITION BY a.EmployeeID ORDER BY a.OrderDate)-----4

FROM 
		[AdventureWorks2019].Purchasing.PurchaseOrderHeader A
		join [AdventureWorks2019].Purchasing.Vendor B
			on A.VendorID = B.BusinessEntityID

WHERE YEAR(A.OrderDate) >= 2013
      AND A.TotalDue > 500; -------1

----------FIRST_VALUE

--The FIRST_VALUE function returns nicely the first value for each group.

-----EXERCISE FIRST_VALUE()

--Exercise 1
--Create a query that returns all records - and the following columns - from the HumanResources.Employee table:
--a. BusinessEntityID (alias this as “EmployeeID”)
--b. JobTitle
--c. HireDate
--d. VacationHours
--To make the effect of subsequent steps clearer, also sort the query output by "JobTitle" and HireDate, both in ascending order.
--Now add a derived column called “FirstHireVacationHours” that displays – for a given job title –
--the amount of vacation hours possessed by the first employee hired who has that same job title.
--For example, if 5 employees have the title “Data Guru”, and the one of those 5 with the oldest hire date has 99 vacation hours, “FirstHireVacationHours” should display “99” for all 5 of those employees’ corresponding records in the query.

SELECT
	   EmploueeID = a.BusinessEntityID,
       a.JobTitle,
       a.HireDate,
       a.VacationHours,
       FirstHireVacationHours = FIRST_VALUE(a.VacationHours) OVER (PARTITION BY a.JobTitle ORDER BY a.HireDate)
FROM 
	  AdventureWorks2019.HumanResources.Employee a

ORDER BY a.JobTitle, a.HireDate ASC;

--Exercise 2
--Create a query with the following columns:
--a. “ProductID” from the Production.Product table
--b. “Name” from the Production.Product table (alias this as “ProductName”)
--c. “ListPrice” from the Production.ProductListPriceHistory table
--d. “ModifiedDate” from the Production.ProductListPriceHistory
--You can join the Production.Product and Production.ProductListPriceHistory tables on "ProductID".
--Note that the Production.ProductListPriceHistory table contains a distinct record for every different price a product has been listed at.
--This means that a single product ID may have several records in this table – one for every list price it has had.
--Also note that the “ModifiedDate” field in this table displays the effective date of each of these prices.
--So if there are 3 rows in the table for product ID 12345, the row with the oldest modified date also contains the first price
--in the associated product’s history. Conversely, the row with the most recent modified date also contains the current price of the product.
--To make the effect of subsequent steps clearer, also sort the query output by ProductID and ModifiedDate, both in ascending order.
--Now add a derived column called “HighestPrice” that displays – for a given product – the highest price that product has been listed at.
--So even if there are 4 records for a given product, this column should only display the all-time highest list price for that product
--in each of those 4 rows.
--Similarly, create another derived column called “LowestCost” that displays the all-time lowest price for a given product.
--Finally, create a third derived column called “PriceRange” that reflects, for a given product,
--the difference between its highest and lowest ever list prices.

SELECT 
	   a.ProductID,
       ProductName = a.Name,
       b.ListPrice,
       b.ModifiedDate,
       HighestPrice = FIRST_VALUE(b.ListPrice) OVER (PARTITION BY a.ProductID ORDER BY b.ListPrice DESC),
       LowestCost = FIRST_VALUE(b.ListPrice) OVER (PARTITION BY a.ProductID ORDER BY b.ListPrice ASC),
       PriceRange = FIRST_VALUE(b.ListPrice) OVER (PARTITION BY a.ProductID ORDER BY b.ListPrice DESC)
                    - FIRST_VALUE(b.ListPrice) OVER (PARTITION BY a.ProductID ORDER BY b.ListPrice ASC)

FROM [AdventureWorks2019].Production.Product a
    JOIN AdventureWorks2019.Production.ProductListPriceHistory b
        ON a.ProductID = b.ProductID

ORDER BY a.ProductID, b.ModifiedDate;

------SUBQUERIES

--Exercise 1
--Write a query that displays the three most expensive orders, per vendor ID, from the Purchasing.PurchaseOrderHeader table.
--There should ONLY be three records per Vendor ID, even if some of the total amounts due are identical.
--"Most expensive" is defined by the amount in the "TotalDue" field.

--Exercise 2
--Modify your query from the first problem, such that the top three purchase order amounts are returned,
--regardless of how many records are returned per Vendor Id.
--In other words, if there are multiple orders with the same total due amount,
--all should be returned as long as the total due amount for these orders is one of the top three.

SELECT 
	   A.PurchaseOrderID,
       A.VendorID,
       A.OrderDate,
       A.TaxAmt,
       A.Freight,
       A.TotalDue
FROM
	(
		SELECT 
				   A.PurchaseOrderID,
				   A.VendorID,
				   A.OrderDate,
				   A.TaxAmt,
				   A.Freight,
				   A.TotalDue,
				   ---PurchaseOrderRank = ROW_NUMBER() OVER(PARTITION BY VendorID ORDER BY TotalDue DESC)-----1
				   PurchaseOrderRank = DENSE_RANK() OVER (PARTITION BY a.VendorID ORDER BY a.TotalDue DESC)-----2

		FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

	) A

WHERE PurchaseOrderRank <= 3;

-------ROWS BETWEEN

--ROWS BETWEEN is used to calculating the running measure / aggregation in Analytical Functions. Whenever you use window functions you specify the rows which shall be considered for calculating measures. If you don’t specify anything then by default all the rows in the partition participate in calculating measures.
--Some common aggregation function SUM() , MIN(),MAX() , COUNT() , AVG() .
--Note– if you don’t specify anything in over() clause for partitioning, then by default all rows in dataset consider as an single partition .
--RANGE must always be from start to end i.e. Start must be before End.
--Some Common Specifications
--PRECEDING: All rows before current row are considered.
--FOLLOWING: All rows after the current row are considered.
--CURRENT ROW: Range starts or ends at CURRENT ROW.

--Exercise 1
--Create a query with the following columns:
--“OrderMonth”, a derived column (you’ll have to create this one yourself) featuring the month number corresponding with the Order Date in a given row
--“OrderYear”, a derived column featuring the year corresponding with the Order Date in a given row
--“SubTotal” from the Purchasing.PurchaseOrderHeader table
--Exercise 2
--Modify your query from Exercise 1 by adding a derived column called "Rolling3MonthTotal", that displays
-- for a given row - a running total of “SubTotal” for the prior three months (including the current row).
--Exercise 3
--Modify your query from Exercise 3 by adding another derived column called "MovingAvg6Month", that calculates 
---a rolling average of “SubTotal” for the previous 6 months, relative to the month in the “current” row.
--Note that this average should NOT include the current row.
--Exercise 4
--Modify your query from Exercise 3 by adding (yet) another derived column called “MovingAvgNext2Months” ,
---that calculates a rolling average of “SubTotal” for the month in the current row and the next two months after that.
---This moving average will provide a kind of "forecast" for Subtotal by month.

SELECT

		OrderMonth,
		OrderYear,
		SubTotal,
		Rolling3MonthTotal = SUM(SubTotal) OVER(ORDER BY OrderYear, OrderMonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
		MovingAvg6Month = AVG(SubTotal) OVER(ORDER BY OrderYear, OrderMonth ROWS BETWEEN 6 PRECEDING AND 1 PRECEDING),
		MovingAvgNext2Months = AVG(SubTotal) OVER(ORDER BY OrderYear, OrderMonth ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)

FROM (
		SELECT

				OrderMonth = MONTH(OrderDate),
				OrderYear = YEAR(OrderDate),
				SubTotal = SUM(SubTotal)

		FROM Purchasing.PurchaseOrderHeader

		GROUP BY MONTH(OrderDate), YEAR(OrderDate)
     ) X