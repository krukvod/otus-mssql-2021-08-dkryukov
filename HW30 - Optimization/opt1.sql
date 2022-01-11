set statistics io on;

/*
Пробую ограничить сразу выбор записей, перенеся отбор по сумме из условия в первоначальную выборку в select в подзапрос.
К нему уже начинаю подцеплять остальные записи
*/
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
from (SELECT ordTotal.CustomerID, SUM(Total.UnitPrice*Total.Quantity) as summa
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        --WHERE ordTotal.CustomerID = Inv.CustomerID
		group by ordTotal.CustomerID
		having SUM(Total.UnitPrice*Total.Quantity) > 250000
		) ordt
		join Sales.Orders AS ord
		on ordt.CustomerID = ord.CustomerID
    JOIN Sales.OrderLines AS det
      ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
		 /*
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
		*/
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID