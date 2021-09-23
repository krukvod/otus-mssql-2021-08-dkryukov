/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName from warehouse.stockitems
where StockitemName like '%urgent%' or StockitemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierId, s.SupplierName 
from [Purchasing].[Suppliers] s
left join [Purchasing].[PurchaseOrders] po
on s.SupplierId = po.SupplierID
where po.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select o.OrderID, convert(varchar(10),o.OrderDate,104) as OrderDate,
	datename(mm, o.OrderDate) as mm, datepart(QQ,o.OrderDate) as qq, 
	case when datepart(mm,o.OrderDate) <= 4 then 1
		when datepart(mm,o.OrderDate) >= 5 and datepart(mm,o.OrderDate) <= 8 then  2
		when datepart(mm,o.OrderDate) >= 9 then 3
	else 0 end as ytr,
	c.CustomerName
from [Sales].[Orders] o
join [Sales].[OrderLines] ol
on o.OrderId = ol.OrderID
join [Sales].[Customers] c
on o.CustomerId = c.CustomerID
where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null)
order by qq, ytr, o.OrderDate

select o.OrderID, convert(varchar(10),o.OrderDate,104) as OrderDate,
	datename(mm, o.OrderDate) as mm, datepart(QQ,o.OrderDate) as qq, 
	case when datepart(mm,o.OrderDate) <= 4 then 1
		when datepart(mm,o.OrderDate) >= 5 and datepart(mm,o.OrderDate) <= 8 then  2
		when datepart(mm,o.OrderDate) >= 9 then 3
	else 0 end as ytr,
	c.CustomerName
from [Sales].[Orders] o
join [Sales].[OrderLines] ol
on o.OrderId = ol.OrderID
join [Sales].[Customers] c
on o.CustomerId = c.CustomerID
where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null)
order by qq, ytr, o.OrderDate
offset (1000) rows FETCH NEXT 100 rows only
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select dm.DeliveryMethodName, po.ExpectedDeliveryDate, s.SupplierName, p.FullName
from [Purchasing].[PurchaseOrders] po
join [Purchasing].[Suppliers] s
on po.SupplierID = s.SupplierID
join [Application].[DeliveryMethods] dm
on po.DeliveryMethodID = dm.DeliveryMethodID
join [Application].[People] p
on po.[ContactPersonID] = p.PersonID
where po.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
	and dm.DeliveryMethodName like '%Air Freight%'
	and isnull(po.IsOrderFinalized,0) = 1
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 o.OrderID, o.OrderDate, c.CustomerName, p.FullName
from [Sales].[Orders] o
join [Application].[People] p
on o.SalespersonPersonID = p.PersonID
join [Sales].[Customers] c
on o.CustomerID = c.CustomerID
order by o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct c.CustomerID, c.CustomerName, c.PhoneNumber
from [Sales].[Customers] c
join [Sales].[Orders] o
on c.CustomerID = o.CustomerID
join [Sales].[OrderLines] ol
on o.OrderID = ol.OrderID
join [Warehouse].[StockItems] si
on ol.StockItemID = si.StockItemID
where si.StockItemName = 'Chocolate frogs 250g'
/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(i.InvoiceDate) as yy, month(i.InvoiceDate) as mm, 
	avg(il.UnitPrice) as avg_price, sum(il.Quantity * il.UnitPrice) as sum_price
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il
on i.InvoiceID = il.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)


/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(i.InvoiceDate) as yy, month(i.InvoiceDate) as mm, 
	sum(il.Quantity * il.UnitPrice) as sum_price
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il
on i.InvoiceID = il.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)
having sum(il.Quantity * il.UnitPrice) > 10000


/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select si.yy, si.mm, si.StockItemName, sum(si.sum_price) as sum_price, si.min_date,  sum(si.cc) as count_cc
from (
select year(i.InvoiceDate) as yy, month(i.InvoiceDate) as mm, 
	si.StockItemName, sum(il.Quantity * il.UnitPrice) as sum_price, 
	count(il.StockItemID) as cc, 
	(select min(InvoiceDate) as min_Date 
		from Sales.invoices i2
		join [Sales].[InvoiceLines] il2
		on i2.InvoiceID = il2.InvoiceID
		join [Warehouse].[StockItems] si2
		on il2.StockItemID = si2.StockItemId
		where si2.StockItemName = si.StockItemName group by si2.StockItemID) as min_Date
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il
on i.InvoiceID = il.InvoiceID
join [Warehouse].[StockItems] si
on il.StockItemID = si.StockItemID
group by year(i.InvoiceDate), month(i.InvoiceDate), si.StockItemName, il.Quantity
having il.Quantity < 50
) si
group by si.yy, si.mm, si.StockItemName, si.min_date
order by si.yy, si.mm, si.StockItemName


-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

select *
from (values(2013, 1), (2013, 2), (2013, 3), (2013, 4), (2013, 5), (2013, 6), 
	(2013, 7), (2013, 8), (2013, 9), (2013, 10), (2013, 11), (2013, 12),
	(2014, 1), (2014, 2), (2014, 3), (2014, 4), (2014, 5), (2014, 6), 
	(2014, 7), (2014, 8), (2014, 9), (2014, 10), (2014, 11), (2014, 12),
	(2015, 1), (2015, 2), (2015, 3), (2015, 4), (2015, 5), (2015, 6), 
	(2015, 7), (2015, 8), (2015, 9), (2015, 10), (2015, 11), (2015, 12),
	(2016, 1), (2016, 2), (2016, 3), (2016, 4), (2016, 5), (2016, 6)
	--(2016, 7), (2016, 8), (2016, 9), (2016, 10), (2016, 11), (2016, 12)
) as tbl (yy, mm)
left join (select year(i.InvoiceDate) as yy, month(i.InvoiceDate) as mm, 
	sum(il.Quantity * il.UnitPrice) as sum_price
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il
on i.InvoiceID = il.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)
having sum(il.Quantity * il.UnitPrice) > 10000
) sel
on tbl.yy = sel.yy and tbl.mm = sel.mm
order by tbl.yy, tbl.mm



select tbl.yy, tbl.mm, sel.StockItemName, sel.sum_price, sel.min_Date, sel.count_cc
from (values(2013, 1), (2013, 2), (2013, 3), (2013, 4), (2013, 5), (2013, 6), 
	(2013, 7), (2013, 8), (2013, 9), (2013, 10), (2013, 11), (2013, 12),
	(2014, 1), (2014, 2), (2014, 3), (2014, 4), (2014, 5), (2014, 6), 
	(2014, 7), (2014, 8), (2014, 9), (2014, 10), (2014, 11), (2014, 12),
	(2015, 1), (2015, 2), (2015, 3), (2015, 4), (2015, 5), (2015, 6), 
	(2015, 7), (2015, 8), (2015, 9), (2015, 10), (2015, 11), (2015, 12),
	(2016, 1), (2016, 2), (2016, 3), (2016, 4), (2016, 5), (2016, 6)
	--(2016, 7), (2016, 8), (2016, 9), (2016, 10), (2016, 11), (2016, 12)
) as tbl (yy, mm)
left join (
select si.yy, si.mm, si.StockItemName, sum(si.sum_price) as sum_price, si.min_date,  sum(si.cc) as count_cc
from (
select year(i.InvoiceDate) as yy, month(i.InvoiceDate) as mm, 
	si.StockItemName, sum(il.Quantity * il.UnitPrice) as sum_price, 
	count(il.StockItemID) as cc, 
	(select min(InvoiceDate) as min_Date 
		from Sales.invoices i2
		join [Sales].[InvoiceLines] il2
		on i2.InvoiceID = il2.InvoiceID
		join [Warehouse].[StockItems] si2
		on il2.StockItemID = si2.StockItemId
		where si2.StockItemName = si.StockItemName group by si2.StockItemID) as min_Date
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il
on i.InvoiceID = il.InvoiceID
join [Warehouse].[StockItems] si
on il.StockItemID = si.StockItemID
group by year(i.InvoiceDate), month(i.InvoiceDate), si.StockItemName, il.Quantity
having il.Quantity < 50
) si
group by si.yy, si.mm, si.StockItemName, si.min_date
) sel
on tbl.yy = sel.yy and tbl.mm = sel.mm
order by tbl.yy, tbl.mm, sel.StockItemName
