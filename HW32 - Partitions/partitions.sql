--select * from sales.orders
drop table if exists Sales.OrdersPartitioned;
GO

--if OBJECT_ID('schmOrderYearPartition') is not null 
drop partition scheme schmOrderYearPartition
GO

--if OBJECT_ID('fnOrderYearPartition') is not null 
drop partition function fnOrderYearPartition
GO

CREATE PARTITION FUNCTION [fnOrderYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20130101','20140101','20150101','20160101');																																																									
GO

CREATE PARTITION SCHEME [schmOrderYearPartition] AS PARTITION [fnOrderYearPartition] 
ALL TO ([PRIMARY]);
GO

CREATE TABLE [Sales].[OrdersPartitioned](
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
) ON [schmOrderYearPartition]([OrderDate]);
GO

ALTER TABLE [Sales].[OrdersPartitioned] ADD CONSTRAINT PK_Sales_OrderPartitioned 
PRIMARY KEY CLUSTERED  (OrderDate, OrderId, CustomerID)
ON [schmOrderYearPartition]([OrderDate]);
GO

INSERT INTO Sales.OrdersPartitioned
select *
FROM Sales.Orders;

SELECT  $PARTITION.fnOrderYearPartition(OrderDate) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(OrderDate)
		,MAX(OrderDate) 
FROM Sales.OrdersPartitioned
GROUP BY $PARTITION.fnOrderYearPartition(OrderDate) 
ORDER BY Partition ;  

