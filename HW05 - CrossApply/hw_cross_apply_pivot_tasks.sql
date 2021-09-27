/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select OrderDate, [Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT]
from (
select convert(varchar(10),o.OrderDate, 104) as OrderDate, --c.CustomerID, --c.CustomerName, 
	substring(c.CustomerName, charindex('(',c.CustomerName) + 1, len (c.CustomerName) - charindex('(',c.CustomerName)-1) as CustomerName
from Sales.Orders o
join Sales.Customers c
on o.CustomerID = c.CustomerID
where c.CustomerID between 2 and 6
) sel
pivot (count(CustomerName) for CustomerName in ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT]) ) as pt
 

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
select CustomerName, AddressLine
from (
select c.CustomerName, c.DeliveryAddressLine1, c.DeliveryAddressLine2, c.PostalAddressLine1, c.PostalAddressLine2
from Sales.Customers c
where c.CustomerName like 'Tailspin Toys%'
) sel
unpivot (AddressLine for Addres in ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])) upt

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
select CountryID, CountryName, Code
from (
select CountryID, CountryName, IsoAlpha3Code, convert(nvarchar(3),IsoNumericCode) as IsoNumericCodeStr
from Application.Countries
) sel
unpivot (Code for IsoCode in (IsoAlpha3Code, IsoNumericCodeStr)) upt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select * from (
select c.CustomerID, c.CustomerName, ol.StockItemID, ol.UnitPrice, o.OrderDate,
	ROW_NUMBER () over (partition by c.CustomerId order by ol.UnitPrice desc) as n
from Sales.Customers c
join Sales.Orders o
on c.CustomerID = o.CustomerID
join Sales.OrderLines ol
on o.OrderID = ol.OrderID
) as sel
where n <= 2

