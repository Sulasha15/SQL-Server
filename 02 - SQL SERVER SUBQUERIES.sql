---SCALAR SUBQUERIES

-----scalar subqueries to be used in where clause as we cannot use window functions there
--A scalar subquery is a subquery that selects only one column or expression and returns one row.
--A scalar subquery can be used anywhere in an SQL query that a column or expression can be used.
--A scalar subquery can be used in the following contexts:
--The select list of a query (that is, the expressions between the SELECT and FROM keywords)
--In a WHERE or ON clause of a containing query
--The JOIN clause of a query
--WHERE clause that contains CASE, IF, COALESCE, and NULLIF expressions
--Source to an UPDATE statement when the subquery refers to more than the modified table
--Qualifier to a DELETE statement where the subquery identifies the rows to delete
--The VALUES clause of an INSERT statement
--As an operand in any expression
--Scalar subqueries can be used to compute several different types of aggregations (max and avg) all in the same SQL statement.
--Scalar subqueries can also be used for inserting into tables, based on values from other tables. 
--A scalar subquery cannot be used as a parameter to a stored procedure call.

--Exercise 1
--Create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
--BusinessEntityID
--JobTitle
--VacationHours
--Also include a derived column called "MaxVacationHours" that returns the maximum amount of vacation hours for any one employee, in any given row.

--Exercise 2
--Add a new derived field to your query from Exercise 1, which returns the percent an individual employees' vacation hours are,
--of the maximum vacation hours for any employee. For example, the record for the employee with the most vacation hours should have a value of
---1.00, or 100%, in this column.

--Exercise 3
--Refine your output with a criterion in the WHERE clause that filters out any employees whose vacation hours are less then 80% of
--the maximum amount of vacation hours for any one employee.
--In other words, return only employees who have at least 80% as much vacation time as the employee with the most vacation time.

select
	   
	   BusinessEntityID,
       JobTitle,
       VacationHours,
       MaxVacationHours =
						   (select max(VacationHours) from AdventureWorks2019.HumanResources.Employee),

       PerctVacationHours = (VacationHours * 1.0) /
                            (select max(VacationHours) from AdventureWorks2019.HumanResources.Employee)

from AdventureWorks2019.HumanResources.Employee

where (
		(VacationHours * 1.0) /  (select max(VacationHours) from AdventureWorks2019.HumanResources.Employee)
      ) >= 0.8

----CORELATED SUBQUERIES

 --Correlated subqueries are used for row-by-row processing. Each subquery is executed once for every row of the outer query.
 --A correlated subquery is evaluated once for each row processed by the parent statement. The parent statement can be a SELECT, UPDATE, or DELETE statement.

--Exercise 1
--Write a query that outputs all records from the Purchasing.PurchaseOrderHeader table. Include the following columns from the table:
--PurchaseOrderID
--VendorID
--OrderDate
--TotalDue
--Add a derived column called NonRejectedItems which returns, for each purchase order ID in the query output,
---the number of line items from the Purchasing.PurchaseOrderDetail table which did not have any rejections
----(i.e., RejectedQty = 0). Use a correlated subquery to do this.

--Exercise 2
--Modify your query to include a second derived field called MostExpensiveItem.
--This field should return, for each purchase order ID, the UnitPrice of the most expensive item for that order
--in the Purchasing.PurchaseOrderDetail table.
--Use a correlated subquery to do this as well.

select a.PurchaseOrderID,
       a.VendorID,
       a.OrderDate,
       a.TotalDue,
       NonRejectedItems =
			   (
				   select count(*)

				   from Purchasing.PurchaseOrderDetail b

				   where a.PurchaseOrderID = b.PurchaseOrderID
						 and b.RejectedQty = 0
			   ),
       MostExpensiveItem =
			   (
				   select MAX(b.UnitPrice)

				   from Purchasing.PurchaseOrderDetail b

				   where a.PurchaseOrderID = b.PurchaseOrderID
			   )
from AdventureWorks2019.Purchasing.PurchaseOrderHeader a

-------EXISTS

--The EXISTS condition in SQL is used to check whether the result of a correlated nested query is empty (contains no tuples) or not.
--The result of EXISTS is a boolean value True or False. It can be used in a SELECT, UPDATE, INSERT or DELETE statement. 
----you want to apply criteria to the fields from secondary table but don't need those fields in o/p
-----you want to apply criteris to fields from secondary table while ensuring multiple match in secondary table won't
--duplicate data from primary table in your o/p
----- check secondary table to make sure some type does not exists

-------Exercise 1
--Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity
--greater than 500. 

select
	   
	   a.PurchaseOrderID,
       a.OrderDate,
       a.SubTotal,
       a.TaxAmt

from AdventureWorks2019.Purchasing.PurchaseOrderHeader a

where exists
		(
			select 1

			from Purchasing.PurchaseOrderDetail b

			where b.OrderQty > 500
				  and a.PurchaseOrderID = b.PurchaseOrderID
		)
order by a.PurchaseOrderID;

-------Exercise 2
--Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity
--greater than 500, AND a unit price greater than $50.00.

select a.*

from AdventureWorks2019.Purchasing.PurchaseOrderHeader a

where exists
		(
			select 1
			from Purchasing.PurchaseOrderDetail b
			where b.OrderQty > 500
				  and b.UnitPrice > 50
				  and a.PurchaseOrderID = b.PurchaseOrderID
		)
order by a.PurchaseOrderID

----Q: Select all records from the Purchasing.PurchaseOrderHeader table such that NONE of the items within the order have a rejected quantity
--greater than 0.

select a.*

from AdventureWorks2019.Purchasing.PurchaseOrderHeader a

where not exists
		(
			select 1
			from Purchasing.PurchaseOrderDetail b
			where b.RejectedQty > 0
				  and a.PurchaseOrderID = b.PurchaseOrderID
		)
order by a.PurchaseOrderID

--FOR XML PATH WITH STUFF

--STUFF() : 
--In SQL Server, stuff() function is used to delete a sequence of given length of characters from the source string and
--inserting the given sequence of characters from the specified starting index. 
--Syntax: STUFF (source_string, start, length, add_string)
--Where:- 
--1. source_string: Original string to be modified. 
--2. start: The starting index from where the given length of characters will be deleted and new sequence of characters will be inserted. 
--3. length: The numbers of characters to be deleted from the starting index in the original string. 
--4. add_string: The new set of characters (string) to be inserted in place of deleted characters from the starting index. 
--Note: It is not necessary to have the length of the new string and number of characters to be deleted the same. 

----FOR XML PATH
----We use the FOR XML PATH SQL Statement to concatenate multiple column data into a single row

--Exercise 1
--Create a query that displays all rows from the Production.ProductSubcategory table, and includes the following fields:
--The "Name" field from Production.ProductSubcategory, which should be aliased as "SubcategoryName"
--A derived field called "Products" which displays, for each Subcategory in Production.ProductSubcategory,
--a semicolon-separated list of all products from Production.Product contained within the given subcategory
--Hint: Production.ProductSubcategory and Production.Product are related by the "ProductSubcategoryID" field.

select SubCategoryName = Name,
       Products = stuff(
						  (
							  select ';' + b.Name

							  from Production.Product b

							  where A.ProductSubcategoryID = B.ProductSubcategoryID

							  for xml path('')
						  )
						  ,1,1,''
                       )
from AdventureWorks2019.Production.ProductSubcategory a

--Exercise 2
--Modify the query from Exercise 1 such that only products with a ListPrice value greater than $50 are listed in the "Products" field.
--Hint: Assuming you used a correlated subquery in Exercise 1, keep in mind that you can apply additional criteria to it,
--just as with any other correlated subquery.
--NOTE: Your query should still include ALL product subcategories, but only list associated products greater than $50.
--But since there are certain product subcategories that don't have any associated products greater than $50,
--some rows in your query output may have a NULL value in the product field.

select SubCategoryName = Name,
       Products = stuff(
						  (
							  select ';' + b.Name

							  from Production.Product b

							  where A.ProductSubcategoryID = B.ProductSubcategoryID
									and b.ListPrice > 50

							  for xml path('')
						  )
						  ,1,1,''
                       )
from AdventureWorks2019.Production.ProductSubcategory a

--PIVOT


--Exercise 1
--Using PIVOT, write a query against the HumanResources.Employee table
--that summarizes the average amount of vacation time for Sales Representatives, Buyers, and Janitors

select 
	   
	   [Janitor],
       [Buyer],
       [Sales Representative]

from

	(select JobTitle, VacationHours from HumanResources.Employee) B
	pivot
	(
		avg(VacationHours)
		for JobTitle in ([Janitor], [Buyer], [Sales Representative])
	) A

--Exercise 2
--Modify your query from Exercise 1 such that the results are broken out by Gender. Alias the Gender field as "Employee Gender" in your output.

select 

	   [Janitor],
       [Buyer],
       [Sales Representative],
       EmployeeGender = Gender
from

		(select JobTitle, VacationHours, Gender from HumanResources.Employee) B
		pivot
		(
			avg(VacationHours)
			for JobTitle in ([Janitor], [Buyer], [Sales Representative])
		) A
