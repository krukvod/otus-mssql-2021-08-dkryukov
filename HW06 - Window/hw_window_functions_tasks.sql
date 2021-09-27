/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

drop table if exists #tmp_tmp

select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.UnitPrice*il.Quantity) as summa
into #tmp_tmp
from Sales.Invoices i
join Sales.InvoiceLines il
on i.InvoiceID = il.InvoiceID
join Sales.Customers c
on  i.CustomerID = c.CustomerID
where i.InvoiceDate >= '2015-01-01'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate

select InvoiceID, CustomerName, InvoiceDate, summa,
	(select  sum(summa) from #tmp_tmp s1 
		where year(s1.InvoiceDate) <= year(sel.InvoiceDate)
			and month(s1.InvoiceDate) <= month(sel.InvoiceDate)
	)
from #tmp_tmp sel
order by invoiceDate, CustomerName


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select InvoiceID, CustomerName, InvoiceDate, summa,
	sum(summa) over (order by month(InvoiceDate))
from (
select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.UnitPrice*il.Quantity) as summa
	
from Sales.Invoices i
join Sales.InvoiceLines il
on i.InvoiceID = il.InvoiceID
join Sales.Customers c
on  i.CustomerID = c.CustomerID
where i.InvoiceDate >= '2015-01-01'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
) sel
order by invoiceDate, CustomerName

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select StockItemName, cc, mm, n
	--ROW_NUMBER() over (partition by mm order by cc desc) as n
from (
select si.StockItemName, count(il.StockItemID) as cc, month(i.InvoiceDate) as mm,
	ROW_NUMBER() over (partition by month(i.InvoiceDate) order by count(il.StockItemID) desc) as n
from Sales.Invoices i
join Sales.InvoiceLines il
on i.InvoiceId = il.InvoiceID
join Warehouse.StockItems si
on il.StockItemID = si.StockItemID
where year(i.InvoiceDate) = 2016
group by si.StockItemName, month(i.InvoiceDate)
) sel
where n <= 2
order by mm, cc, StockItemName

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select StockItemID, StockItemName, Brand, UnitPrice,
	rank() over(order by left(stockItemName,1)) as nomer,
	count(StockItemID) over() as all_count,
	count(StockItemID) over(order by left(stockItemName,1)) as count_by_first_letter,
	LEAD(StockItemID) OVER (ORDER BY StockItemName) AS next_id,
	lag(StockItemID) OVER (ORDER BY StockItemName) AS prev_id,
	--FIRST_VALUE(StockItemName) OVER (ORDER BY StockItemName ROWS BETWEEN 2 PRECEDING and CURRENT ROW) 
	lag(StockItemName,2, 'No items') OVER (ORDER BY StockItemName) AS Name_2_Rows_back,
	ntile(30) over (partition by TypicalWeightPerUnit order by TypicalWeightPerUnit) as groups
from Warehouse.StockItems
order by StockItemName -- left(stockItemName,1)

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

select p.PersonID, p.FullName, c.CustomerId, c.CustomerName
from 
join Sales.Orders o
on p.PersonId = o.SalespersonPersonID
join Sales.Customers c
on o.CustomerID = c.CustomerID

select p.PersonID, p.FullName, c.CustomerId, c.CustomerName, sel.OrderDate, sel.summa
from Application.People p
left join (
select o.SalespersonPersonID, o.CustomerID, o.OrderDate, sum(ol.UnitPrice * ol.Quantity) as summa,
	row_number() over(partition by o.SalespersonPersonID order by o.OrderDate desc) as n
from Sales.Orders o
join Sales.OrderLines ol
on o.OrderID = ol.OrderID
group by o.SalespersonPersonID, o.CustomerID, o.OrderDate
) sel
on p.PersonId = sel.SalespersonPersonID
join Sales.Customers c
on sel.CustomerID = c.CustomerID
where sel.n = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select sel.CustomerId, c.CustomerName, sel.StockItemId, sel.UnitPrice, sel.OrderDate 
from (
select o.CustomerID, ol.StockItemID, ol.UnitPrice, o.OrderDate,
	ROW_NUMBER() over(partition by o.CustomerID order by o.OrderDate desc) as n
from Sales.Orders o
join Sales.OrderLines ol
on o.OrderID = ol.OrderID
) sel
join Sales.Customers c
on sel.CustomerId = c.CustomerID
where sel.n <= 2


--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 