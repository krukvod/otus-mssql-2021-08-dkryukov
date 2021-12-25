use WideWorldImporters
GO

if OBJECT_ID('SendInfoToQueue') is not null drop proc SendInfoToQueue
GO

CREATE PROCEDURE SendInfoToQueue
	@invoiceId bigint, @DateFrom datetime, @dateTo datetime
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG CONVERSATION @InitDlgHandle
	FROM SERVICE
	[//WWI/ServiceInit]
	TO SERVICE
	'//WWI/ServiceTrgt'
	ON CONTRACT
	[//WWI/Contract]
	WITH ENCRYPTION=OFF; 

	
	--Prepare the Message
	SELECT @RequestMessage = --N'<RequestMessage>Message for Target service.</RequestMessage>';
	(SELECT CustomerID, @DateFrom as DateFrom, @DateTo as DateTo
							  FROM Sales.Invoices AS Inv
							  WHERE InvoiceID = @invoiceId
							  FOR XML AUTO, root('RequestMessage')); 
	

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/RequestMessage]
	(@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage, @InitDlgHandle;
	
	COMMIT TRAN 
END
GO
