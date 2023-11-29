------PROGRAMMING IN SQL

-----VARIABLES

--A local variable is an object that can hold a single data value of a specific type. Variables in batches and scripts are typically used:
--As a counter either to count the number of times a loop is performed or to control how many times the loop is performed.
--To hold a data value to be tested by a control-of-flow statement.
--To save a data value to be returned by a stored procedure return code or function return value.

--Exercise 1
--Refactor the provided code to utilize variables instead of embedded scalar subqueries.

SELECT
	   BusinessEntityID
      ,JobTitle
      ,VacationHours
	  ,MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee)
	  ,PercentOfMaxVacationHours = (VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee)

FROM AdventureWorks2019.HumanResources.Employee

WHERE (VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee) >= 0.8

-----Solution

DECLARE @MaxVacationHours smallint

SELECT @MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee)

SELECT
	   BusinessEntityID
      ,JobTitle
      ,VacationHours
	  ,MaxVacationHours = @MaxVacationHours
	  ,PercentOfMaxVacationHours = (VacationHours * 1.0) / @MaxVacationHours

FROM AdventureWorks2019.HumanResources.Employee

WHERE (VacationHours * 1.0)/@MaxVacationHours >= 0.8

----------Exercise 2
--Let's say your company pays once per month, on the 15th.
--If it's already the 15th of the current month (or later), the previous pay period will run from the 15th of the previous month,
--to the 14th of the current month.
--If on the other hand it's not yet the 15th of the current month, the previous pay period will run from the
--15th two months ago to the 14th on the previous month.
--Set up variables defining the beginning and end of the previous pay period in this scenario.
--Select the variables to ensure they are working properly.
--Hint: In addition to incorporating date logic, you will probably also need to use CASE statements in one of your variable definitions.

DECLARE @Today DATE

SET @Today = CAST(GETDATE() AS DATE)

DECLARE  @Current14 DATE 

SET @Current14 = DATEFROMPARTS(YEAR(@Today),MONTH(@Today),14)

DECLARE @PayEnd DATE

SET @PayEnd =
				CASE
					WHEN DAY(@Today) < 15 THEN DATEADD(MONTH,-1,@Current14)
					ELSE @Current14
				END

DECLARE @PayStart DATE

SET @PayStart =  DATEADD(DAY,1,DATEADD(MONTH,-1,@PayEnd))

SELECT @Today
SELECT @PayStart
SELECT @PayEnd

-------USER DEFINED FUNCTIONS

--SQL Server user-defined functions are routines that accept parameters, perform an action, such as a complex calculation,
--and return the result of that action as a value. The return value can either be a single scalar value or a result set.

--SCALAR FUNCTIONS

--User-defined scalar functions return a single data value of the type defined in the RETURNS clause.
--For an inline scalar function, the returned scalar value is the result of a single statement.
--For a multistatement scalar function, the function body can contain a series of Transact-SQL statements that return the single value.
--The return type can be any data type except text, ntext, image, cursor, and timestamp.

--- EXERCISE SCALAR FUNCTIONS

--Exercise 1
--Create a user-defined function that returns the percent that one number is of another.
--For example, if the first argument is 8 and the second argument is 10, the function should return the string "80.00%".
--The function should solve the "integer division" problem by allowing you to divide an integer by another integer, and yet get an accurate decimal result.
--Hints:
--Remember that you can implicitly convert an integer to a decimal by multiplying it by 1.0.
--You can format a decimal (say, 0.1) as a percent (10%) with the following code: FORMAT(0.1, 'P').
--Remember that the the return value of the function should be a text string.


USE AdventureWorks2019
GO

CREATE FUNCTION dbo.ufn_PerctNumtoNum(@Num int, @Deno int)

RETURNS VARCHAR(8)

AS

BEGIN

		DECLARE @Decimal FLOAT = (@Num*1.0) / @Deno

		RETURN FORMAT(@Decimal,'P')

END

--Exercise 2
--Store the maximum amount of vacation time for any individual employee in a variable.
--Then create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
--BusinessEntityID
--JobTitle
--VacationHours
--Then add a derived field called "PercentOfMaxVacation", which returns the percent an individual employees
--vacation hours are of the maximum vacation hours for any employee.
--For example, the record for the employee with the most vacation hours should have a value of 100.00%, in this column.
--The derived field should make use of your user-defined function from the previous exercise,
--as well as your variable that stored the maximum vacation hours for any employee.

DECLARE @MaxVacationHr INT = (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee)

SELECT 
		BusinessEntityID,
		JobTitle,
		VacationHours,
		PercentOfMaxVacation = dbo.ufn_PerctNumtoNum(VacationHours, @MaxVacationHr)

FROM AdventureWorks2019.HumanResources.Employee

--DROP FUNCTION

DROP FUNCTION dbo.ufn_PerctNumtoNum;

--------TABLE VALUED FUNCTION

--User-defined table-valued functions (TVFs) return a table data type. For an inline table-valued function, there is no function body;
--the table is the result set of a single SELECT statement.

--Exercise
--Create a table-valued function called ufn_ProductsByPriceRange, assigned to the Production schema.
--Your solution should meet the following requirements:
--The function should return a result set consisting of all products from the Production.Product table with a “ListPrice”
--between a user-specified minimum and a user-specified maximum.
--(This of course means your function will need to take two parameters; one for the minimum list price, and one for the maximum list price.)
--The result set returned by the function should include the “ProductID”, “Name”, and “ListPrice” columns.

--DROP FUNCTION Production.ufn_ProductsByPriceRange;

CREATE FUNCTION Production.ufn_ProductsByPriceRange(@MinPrice INT, @MaxPrice INT)

RETURNS TABLE

AS

RETURN
		(

		SELECT 
			ProductID,
			Name,
			ListPrice

		FROM AdventureWorks2019.Production.Product

		WHERE ListPrice BETWEEN @MinPrice AND @MaxPrice

		)

select * from Production.ufn_ProductsByPriceRange(100,1000)

------------STORED PROCEDURE

--A stored procedure is a prepared SQL code that you can save, so the code can be reused over and over again.
--So if you have an SQL query that you write over and over again, save it as a stored procedure, and then just call it to execute it.
--You can also pass parameters to a stored procedure, so that the stored procedure can act based on the parameter value(s) that is passed.

--Exercise
--Create a stored procedure called "OrdersAboveThreshold" that pulls in all sales orders with a total due amount above a threshold
--specified in a parameter called "@Threshold". The value for threshold will be supplied by the caller of the stored procedure.
--The proc should have two other parameters: "@StartYear" and "@EndYear" (both INT data types),
--also specified by the called of the procedure. All order dates returned by the proc should fall between these two years.

----DROP PROCEDURE dbo.OrdersAboveThreshold;

CREATE PROCEDURE dbo.OrdersAboveThreshold(@StartYear INT,@EndYear INT, @Threshold FLOAT)

AS

BEGIN

		SELECT 
				SalesOrderID,
				OrderDate,
				TotalDue

		FROM 
				AdventureWorks2019.Sales.SalesOrderHeader A
				join AdventureWorks2019.dbo.MyCalendar B
				on A.OrderDate = B.DateValue

		WHERE 
				TotalDue > @Threshold
				AND B.YearNumber BETWEEN @StartYear AND @EndYear

END

EXEC dbo.OrdersAboveThreshold 1000,2012,2013

--CONTROL FLOW WITH IF STATEMENTS

--Exercise
--Modify the stored procedure you created for the stored procedures exercise (dbo.OrdersAboveThreshold)
--to include an additional parameter called "@OrderType" (data type INT).
--If the user supplies a value of 1 to this parameter, your modified proc should return the same output as previously.
--If however the user supplies a value of 2, your proc should return purchase orders instead of sales orders.
--Use IF/ELSE blocks to accomplish this.

ALTER PROCEDURE [dbo].[OrdersAboveThreshold](@Threshold MONEY, @StartYear INT,@EndYear INT, @OrderType INT)

AS

BEGIN

	IF @OrderType = 1

			BEGIN
					SELECT SalesOrderID, OrderDate, TotalDue

					FROM AdventureWorks2019.Sales.SalesOrderHeader A

					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear
			END
	ELSE

			BEGIN

				   SELECT PurchaseOrderID, OrderDate, TotalDue

					FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear
			END


END

EXEC [dbo].[OrdersAboveThreshold] 1000,2012,2013,1

-----MULTIPLE IF STATEMENTS

--Exercise
--Modify your "dbo.OrdersAboveThreshold" stored procedure once again, such that if a user supplies a value of 3 to the @OrderType parameter,
--the proc should return all sales AND purchase orders above the specified threshold, with order dates between the specified years.
--In this scenario, include an "OrderType" column to the procedure output.
--This column should have a value of "Sales" for records from the SalesOrderHeader table, and "Purchase" for records from the PurchaseOrderHeader table.
--Hints:
--Convert your ELSE block to an IF block, so that you now have 3 independent IF blocks.
--Make sure that your IF criteria are all mutually exclusive.
--Use UNION ALL to "stack" the sales and purchase data.
--Alias SalesOrderId/PurchaseOrderID as "OrderID" in their respective UNION-ed queries.

ALTER PROCEDURE [dbo].[OrdersAboveThreshold](@Threshold MONEY, @StartYear INT,@EndYear INT, @OrderType INT)

AS

BEGIN

	IF @OrderType = 1

			BEGIN
					SELECT SalesOrderID, OrderDate, TotalDue

					FROM AdventureWorks2019.Sales.SalesOrderHeader A

					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear
			END

	IF @OrderType = 2

			BEGIN

				   SELECT PurchaseOrderID, OrderDate, TotalDue

					FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear
			END

	IF @OrderType = 3

			BEGIN
				
				
					SELECT OrderID = SalesOrderID,
					OrderType='Sales',
					OrderDate,
					TotalDue

					FROM AdventureWorks2019.Sales.SalesOrderHeader A
					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear

				UNION ALL

				
					SELECT OrderID = PurchaseOrderID,
					OrderType='Purchase',
					OrderDate,
					TotalDue
				
					FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A
					join AdventureWorks2019.dbo.MyCalendar B
					on A.OrderDate = B.DateValue

					WHERE TotalDue > @Threshold
					AND B.YearNumber BETWEEN @StartYear AND @EndYear
			END

END

EXEC [dbo].[OrdersAboveThreshold] 1000,2012,2013,3