/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @str nvarchar(max), @customer varchar(max)

select @customer = isnull(@customer,'') + QUOTENAME(CustomerName) + ',' --for xml path('')  
from Sales.Customers 
order by CustomerName

set @customer = left(@customer,len(@customer)-1)


--select @customer 

set @str = N'select OrderDate, ' + @customer + 
' from (

select convert(varchar(10),dateadd(dd, 1, eomonth(dateadd(mm,-1, o.OrderDate))), 104) as OrderDate,  
	c.CustomerName, 
	month(o.OrderDate) as mm, year(o.OrderDate) as yy
from Sales.Orders o
join Sales.Customers c
on o.CustomerID = c.CustomerID) sel
pivot (count(CustomerName) for CustomerName in (' + @customer + ') ) as pt
order by OrderDate'
 
-- print @str
 
--EXEC (@str)
exec sp_executesql @str



