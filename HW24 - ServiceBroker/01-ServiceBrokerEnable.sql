
USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER; 

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];
GO

USE [WideWorldImporters]
GO

drop table if exists [dbo].[reporttable]

CREATE TABLE [dbo].[reporttable](
	[CustomerID] [int] NULL,
	[OrderDate] [date] NULL,
	[StockItemID] [int] NULL,
	[Quantity] [int] NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NULL,
	[ConfirmForProcessing] [datetime] NULL
) ON [USERDATA]
GO