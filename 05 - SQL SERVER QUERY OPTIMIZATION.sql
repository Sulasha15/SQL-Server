-----------OPTIMISING USING UPDATE STATEMENT

--Exercise
--Making use of temp tables and UPDATE statements, re-write an optimized version of the query 

SELECT 
	   A.BusinessEntityID
      ,A.Title
      ,A.FirstName
      ,A.MiddleName
      ,A.LastName
	  ,B.PhoneNumber
	  ,PhoneNumberType = C.Name
	  ,D.EmailAddress

FROM AdventureWorks2019.Person.Person A
	LEFT JOIN AdventureWorks2019.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID
	LEFT JOIN AdventureWorks2019.Person.PhoneNumberType C
		ON B.PhoneNumberTypeID = C.PhoneNumberTypeID
	LEFT JOIN AdventureWorks2019.Person.EmailAddress D
		ON A.BusinessEntityID = D.BusinessEntityID

--Solution

CREATE TABLE #master
		(
			  BusinessEntityID int,
			  Title varchar(5),
			  FirstName varchar(25),
			  MiddleName varchar(25),
			  LastName varchar(25),
			  PhoneNumber varchar(25),
			  PhoneNumberTypeID int,
			  PhoneNumberType varchar(10),
			  EmailAddress nvarchar(50)
		)

INSERT INTO #master
		(
			   BusinessEntityID 
			  ,Title 
			  ,FirstName 
			  ,MiddleName 
			  ,LastName	  
		)
		SELECT BusinessEntityID, Title, FirstName, MiddleName, LastName FROM AdventureWorks2019.Person.Person;


UPDATE #master

	SET PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID

FROM #master A
	JOIN AdventureWorks2019.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID

UPDATE #master
	SET PhoneNumberType = c.Name

FROM #master A
	JOIN AdventureWorks2019.Person.PhoneNumberType C
		ON A.PhoneNumberTypeID = c.PhoneNumberTypeID

UPDATE #master

	SET EmailAddress = D.EmailAddress

FROM #master A
	JOIN AdventureWorks2019.Person.EmailAddress D
		ON A.BusinessEntityID = D.BusinessEntityID

SELECT * FROM #master

DROP TABLE #master

----AN IMPROVED EXISTS WITH UPDATE

--Exercise
--Re-write the query using temp tables and UPDATEs instead of EXISTS.
--In addition to the three columns in the original query, you should also include a fourth column called "RejectedQty",
--which has one value for rejected quantity from the Purchasing.PurchaseOrderDetail table.

SELECT
       A.PurchaseOrderID,
	   A.OrderDate,
	   A.TotalDue

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

WHERE EXISTS (
	SELECT
	1
	FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail B
	WHERE A.PurchaseOrderID = B.PurchaseOrderID
		AND B.RejectedQty > 5
)

ORDER BY 1

---Solution

CREATE TABLE #Purchase
	(
		PurchaseOrderID INT,
		OrderDate DATE,
		TotalDue MONEY,
		RejectedQty INT
	)

INSERT INTO #Purchase
	(
		PurchaseOrderID,
		OrderDate,
		TotalDue
	)
	SELECT PurchaseOrderID, OrderDate, TotalDue FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader

UPDATE #Purchase
	
	SET RejectedQty = B.RejectedQty

FROM #Purchase A
	JOIN AdventureWorks2019.Purchasing.PurchaseOrderDetail B
		ON A.PurchaseOrderID = B.PurchaseOrderID

WHERE B.RejectedQty > 5


SELECT * FROM #Purchase WHERE RejectedQty IS NOT NULL

DROP TABLE #Purchase

---OPTIMIZING USING INDEX

--Indexing is a procedure that returns your requested data faster from the defined table.
--Without indexing, the SQL server has to scan the whole table for your data.
--By indexing, SQL server will do the exact same thing you do when searching for content in a book by checking the index page.
--In the same way, a table’s index allows us to locate the exact data without scanning the whole table.

---CLUSTERED INDEX

----Clustered index is the type of indexing that establishes a physical sorting order of rows.
--Suppose you have a table Student_info which contains ROLL_NO as a primary key,
--then Clustered index which is self-created on that primary key will sort the Student_info table as per ROLL_NO.
--Clustered index is like Dictionary; in the dictionary, sorting order is alphabetical and there is no separate index page. 

--NON CLUSTERED INDEX

--Non-Clustered index is an index structure separate from the data stored in a table that reorders one or more selected columns.
--The non-clustered index is created to improve the performance of frequently used queries not covered by a clustered index.
--It’s like a textbook; the index page is created separately at the beginning of that book.

--Exercise
--Using indexes, further optimize your solution to the "Optimizing With UPDATE" exercise.

CREATE TABLE #PersonContactInfo
(
	   BusinessEntityID INT
      ,Title VARCHAR(8)
      ,FirstName VARCHAR(50)
      ,MiddleName VARCHAR(50)
      ,LastName VARCHAR(50)
	  ,PhoneNumber VARCHAR(25)
	  ,PhoneNumberTypeID VARCHAR(25)
	  ,PhoneNumberType VARCHAR(25)
	  ,EmailAddress VARCHAR(50)
)

INSERT INTO #PersonContactInfo
(
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName
)

SELECT
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName

FROM AdventureWorks2019.Person.Person


UPDATE A
SET
	PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID


UPDATE A
SET	PhoneNumberType = B.Name

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.PhoneNumberType B
		ON A.PhoneNumberTypeID = B.PhoneNumberTypeID


UPDATE A
SET	EmailAddress = B.EmailAddress

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.EmailAddress B
		ON A.BusinessEntityID = B.BusinessEntityID


SELECT * FROM #PersonContactInfo

DROP TABLE #PersonContactInfo

----Solution

CREATE TABLE #PersonContactInfo
(
	   BusinessEntityID INT
      ,Title VARCHAR(8)
      ,FirstName VARCHAR(50)
      ,MiddleName VARCHAR(50)
      ,LastName VARCHAR(50)
	  ,PhoneNumber VARCHAR(25)
	  ,PhoneNumberTypeID VARCHAR(25)
	  ,PhoneNumberType VARCHAR(25)
	  ,EmailAddress VARCHAR(50)
)

INSERT INTO #PersonContactInfo
(
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName
)

SELECT
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName

FROM AdventureWorks2019.Person.Person

CREATE CLUSTERED INDEX PCI_idx ON #PersonContactInfo(BusinessEntityID)

UPDATE A
SET
	PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID

CREATE NONCLUSTERED INDEX PCI_idx2 ON #PersonContactInfo(PhoneNumberTypeID)

UPDATE A
SET	PhoneNumberType = B.Name

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.PhoneNumberType B
		ON A.PhoneNumberTypeID = B.PhoneNumberTypeID


UPDATE A
SET	EmailAddress = B.EmailAddress

FROM #PersonContactInfo A
	JOIN AdventureWorks2019.Person.EmailAddress B
		ON A.BusinessEntityID = B.BusinessEntityID

SELECT * FROM #PersonContactInfo

DROP TABLE #PersonContactInfo

-----CREATING A CALENDAR LOOKUP TABLE

--DROP TABLE AdventureWorks2019.dbo.MyCalendar

CREATE TABLE AdventureWorks2019.dbo.MyCalendar
	(
		DateValue DATE,
		DayOfWeekNumber INT,
		DayOfWeekName VARCHAR(20),
		DayOfMonthNumber INT,
		MonthNumber INT,
		YearNumber INT,
		WeekendFlag TINYINT,
		HoliayFlag TINYINT
	)

WITH Dates AS

	(
	SELECT CAST('01-01-2011' AS DATE) AS Mydate

	UNION ALL

	SELECT DATEADD(DAY,1,Mydate)
	from Dates
	where MyDate < CAST('12-31-2030' as date)
	) 

INSERT INTO AdventureWorks2019.dbo.MyCalendar
	(
	DateValue
	)

SELECT * FROM Dates
OPTION (maxrecursion 10000)

--SELECT * FROM AdventureWorks2019.dbo.MyCalendar

UPDATE

	AdventureWorks2019.dbo.MyCalendar

SET 
	DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
	DayOfWeekName = FORMAT(DateValue,'dddd') ,
	DayOfMonthNumber =  DAY(DateValue),
	MonthNumber = MONTH(DateValue),
	YearNumber = YEAR(DateValue)

FROM AdventureWorks2019.dbo.MyCalendar

UPDATE

	AdventureWorks2019.dbo.MyCalendar

SET
	WeekendFlag = 
	CASE 
		WHEN DayOfWeekNumber in (1,7) THEN 1
		ELSE 0
	END

--Exercise 1
--Update your calendar lookup table with a few holidays of your choice that always fall on the same day of the year - for example, New Year's.
	
UPDATE AdventureWorks2019.dbo.MyCalendar

	SET HoliayFlag = 
			CASE
				WHEN DayOfMonthNumber = 1 AND MonthNumber = 1 THEN 1
				WHEN DayOfMonthNumber = 4 AND MonthNumber = 7 THEN 1
				WHEN DayOfMonthNumber = 11 AND MonthNumber = 11 THEN 1
				WHEN DayOfMonthNumber = 25 AND MonthNumber = 12 THEN 1
				ELSE 0
			END

--Exercise 2
--Using your updated calendar table, pull all purchasing orders that were made on a holiday. It's fine to simply select all columns via SELECT *.

SELECT A.*

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

JOIN AdventureWorks2019.dbo.MyCalendar B
	ON A.OrderDate = B.DateValue

WHERE B.HoliayFlag =1

--Exercise 3
--Again using your updated calendar table, now pull all purchasing orders that were made on a holiday that also fell on a weekend.

SELECT A.*

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

JOIN AdventureWorks2019.dbo.MyCalendar B
	ON A.OrderDate = B.DateValue

WHERE B.HoliayFlag =1 and B.WeekendFlag = 1

------------CREATING A VIEW ON QUERY

--Views in SQL are kind of virtual tables. A view also has rows and columns as they are in a real table in the database.
--We can create a view by selecting fields from one or more tables present in the database.
--A View can either have all the rows of a table or specific rows based on certain condition.

--Exercise 1
--Create a view named vw_Top10MonthOverMonth in your AdventureWorks database, based on the query below. Assign the view to the Sales schema.
--HINT: You will need to make a slight tweak to the query code before it can be successfully converted to a view.

WITH Sales AS 

	(
	SELECT OrderDate,
           OrderMonth = DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1),
           TotalDue,
           OrderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
                                          ORDER BY TotalDue DESC
                                         )
    FROM AdventureWorks2019.Sales.SalesOrderHeader
   ),

Top10Sales AS 

	(SELECT OrderMonth,
           Top10Total = SUM(TotalDue)
    FROM Sales
    WHERE OrderRank <= 10
    GROUP BY OrderMonth
   )

SELECT A.OrderMonth,
       A.Top10Total,
       PrevTop10Total = B.Top10Total

FROM Top10Sales A
    LEFT JOIN Top10Sales B
        ON A.OrderMonth = DATEADD(MONTH, 1, B.OrderMonth)

ORDER BY 1

---Solution

--DROP VIEW Sales.V_Top10vsPrevTop10

create view Sales.V_Top10vsPrevTop10 as 

WITH Sales AS

	(
	SELECT
		OrderDate
		,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		,TotalDue
		,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
	FROM AdventureWorks2019.Sales.SalesOrderHeader
	),
 
Top10Sales AS

	(
		SELECT
		OrderMonth,
		Top10Total = SUM(TotalDue)
		FROM Sales
		WHERE OrderRank <= 10
		GROUP BY OrderMonth
	)
 
 
SELECT

		A.OrderMonth,
		A.Top10Total,
		PrevTop10Total = B.Top10Total
 
FROM Top10Sales A
	LEFT JOIN Top10Sales B
		ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)

select * from Sales.V_Top10vsPrevTop10