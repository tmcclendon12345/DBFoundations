--*************************************************************************--
-- Title: Assignment06
-- Author: TylerMcClendon
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,TylerMcClendon,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TylerMcClendon')
	 Begin 
	  Alter Database [Assignment06DB_TylerMcClendon] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TylerMcClendon;
	 End
	Create Database Assignment06DB_TylerMcClendon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TylerMcClendon;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO

Create View dbo.Categories_view
With SCHEMABINDING
AS
SELECT
	CategoryID,
	CategoryName
FROM dbo.Categories;
GO

Create View dbo.Employees_view
WITH SCHEMABINDING
AS
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM dbo.Employees;
GO

Create View dbo.Products_View
with SCHEMABINDING
AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM dbo.Products;
GO

Create View dbo.inventories_view
With SCHEMABINDING
AS
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	[COUNT]
FROM dbo.inventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories To Public;
Deny Select On dbo.Products To Public;
Deny Select On dbo.Employees To Public;
Deny Select On dbo.Inventories To Public;

Grant Select On dbo.Categories_view To Public;
Grant Select On dbo.Products_view To Public;
Grant Select On dbo.Employees_view To Public;
Grant Select On dbo.Inventories_view To Public;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View dbo.ProductsByCategories_view
As
Select 
    C.CategoryName,
    P.ProductName,
    P.UnitPrice
From dbo.Products_view P
Join dbo.Categories_view C
    On P.CategoryID = C.CategoryID
Go

Select * from dbo.ProductsByCategories_view
ORder by CategoryName, ProductName;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View dbo.InventoriesByProductsByDates_view
As
Select
    P.ProductName,
    I.InventoryDate,
    I.[Count]
From dbo.Inventories_view I
Join dbo.Products_view P
    On I.ProductID = P.ProductID
GO
Select * From dbo.InventoriesByProductsByDates_view
Order By
    ProductName,
    InventoryDate,
    [Count];
Go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View dbo.InventoriesByEmployeesByDates_view
As
Select 
    I.InventoryDate,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
From dbo.Inventories_view I
Join dbo.Employees_view E
    On I.EmployeeID = E.EmployeeID
Group By 
    I.InventoryDate,
    E.EmployeeFirstName,
    E.EmployeeLastName

GO
Select * from dbo.InventoriesByEmployeesByDates_view
Order By 
    InventoryDate;
Go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View dbo.InventoriesByProductsByCategories_view
As
Select
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.[Count]
From dbo.Inventories_view I
Join dbo.Products_view P
    On I.ProductID = P.ProductID
Join dbo.Categories_view C
    On P.CategoryID = C.CategoryID
GO
Select * From dbo.InventoriesByProductsByCategories_view
Order By
    CategoryName,
    ProductName,
    InventoryDate,
    [Count];
Go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View dbo.InventoriesByProductsByEmployees_view
As
Select
    I.InventoryDate,
    C.CategoryName,
    P.ProductName,
    I.[Count],
    E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
From dbo.Inventories_view I
Join dbo.Products_view P
    On I.ProductID = P.ProductID
Join dbo.Categories_view C
    On P.CategoryID = C.CategoryID
Join dbo.Employees_view E
    On I.EmployeeID = E.EmployeeID
GO
Select * from dbo.InventoriesByProductsByEmployees_view
Order By
    InventoryDate,
    CategoryName,
    ProductName,
    EmployeeName;
Go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View dbo.InventoriesForChaiAndChangByEmployees_view
As
Select
    I.InventoryDate,
    C.CategoryName,
    P.ProductName,
    I.[Count],
    E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
From dbo.Inventories_view I
Join dbo.Products_view P
    On I.ProductID = P.ProductID
Join dbo.Categories_view C
    On P.CategoryID = C.CategoryID
Join dbo.Employees_view E
    On I.EmployeeID = E.EmployeeID
Where P.ProductID In (
        Select ProductID 
        From dbo.Products_view 
        Where ProductName In ('Chai', 'Chang')
    )
GO
Select * from dbo.InventoriesForChaiAndChangByEmployees_view
Order By
    InventoryDate,
    CategoryName,
    ProductName;
Go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Create View dbo.EmployeesByManager_view
As
Select
    E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName,
    M.EmployeeFirstName + ' ' + M.EmployeeLastName As ManagerName
From dbo.Employees_view E
Left Join dbo.Employees_view M
    On E.ManagerID = M.EmployeeID
	GO
Select * from dbo.EmployeesByManager_view
Order By
    ManagerName,
    EmployeeName;
Go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View dbo.InventoriesByProductsByCategoriesByEmployees_view
As
Select
    C.CategoryName,
    P.ProductName,
    I.InventoryID,
    I.InventoryDate,
    I.[Count],
    E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName,
    M.EmployeeFirstName + ' ' + M.EmployeeLastName As ManagerName
From dbo.Inventories_view I
Join dbo.Products_view P
    On I.ProductID = P.ProductID
Join dbo.Categories_view C
    On P.CategoryID = C.CategoryID
Join dbo.Employees_view E
    On I.EmployeeID = E.EmployeeID
Left Join dbo.Employees_view M
    On E.ManagerID = M.EmployeeID

GO
Select * from dbo.InventoriesByProductsByCategoriesByEmployees_view
Order By
    CategoryName,
    ProductName,
    InventoryID,
    EmployeeName;
Go


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[Categories_view]
Select * From [dbo].[Products_View]
Select * From [dbo].[inventories_view]
Select * From [dbo].[Employees_view]

Select * From [dbo].[ProductsByCategories_view]
Select * From [dbo].[InventoriesByProductsByDates_view]
Select * From [dbo].[InventoriesByEmployeesByDates_view]
Select * From [dbo].[InventoriesByProductsByCategories_view]
Select * From [dbo].[InventoriesByProductsByEmployees_view]
Select * From [dbo].[InventoriesForChaiAndChangByEmployees_view]
Select * From [dbo].[EmployeesByManager_view]
Select * From [dbo].[InventoriesByProductsByCategoriesByEmployees_view]

/***************************************************************************************/