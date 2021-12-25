use WideWorldImporters
GO

if OBJECT_ID('GetInfoFromQueue') is not null drop proc GetInfoFromQueue
GO

CREATE PROCEDURE GetInfoFromQueue
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerID INT,
			@DateFrom datetime,
			@DateTo datetime,
			@xml XML,
			@p1 varchar(5000); 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.QueueTrgtWWI; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT @CustomerID = R.Iv.value('@CustomerID','INT'),
		@DateFrom = R.Iv.value('@DateFrom','Datetime'),
		@DateTo = R.Iv.value('@DateTo','Datetime')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	exec CreateReport_proc @CustomerId, @dateFrom, @dateTo;

	SELECT @Message AS ReceivedRequestMessage, @MessageType; 
	
	-- Confirm and Send a reply
	
	IF @MessageType=N'//WWI/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage>Report created</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 
	
	COMMIT TRAN;
END