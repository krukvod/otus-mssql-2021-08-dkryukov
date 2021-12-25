declare @ID bigint = 230;

SELECT InvoiceId, InvoiceConfirmedForProcessing, *
FROM Sales.Invoices
WHERE InvoiceID = @ID;

--Send message
EXEC SendInfoToQueue
	@invoiceId = @ID, @DateFrom = '20130101', @DateTo = '20131231';

SELECT CAST(message_body AS XML),*
FROM dbo.QueueTrgtWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.QueueSrcWWI;

--Target
EXEC GetInfoFromQueue;

--Initiator
EXEC ConfirmQueue;

/*
select @@TRANCOUNT

if @@TRANCOUNT > 0 commit tran;
*/