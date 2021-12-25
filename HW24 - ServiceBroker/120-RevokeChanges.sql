drop table dbo.reporttable;
GO

DROP SERVICE [//WWI/ServiceTrgt]
GO

DROP SERVICE [//WWI/ServiceInit]
GO

DROP QUEUE [dbo].[QueueTrgtWWI]
GO 

DROP QUEUE [dbo].[QueueSrcWWI]
GO

DROP CONTRACT [//WWI/Contract]
GO

DROP MESSAGE TYPE [//WWI/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  dbo.SendInfoToQueue;

DROP PROCEDURE IF EXISTS  dbo.GetInfoFromQueue;

DROP PROCEDURE IF EXISTS  dbo.ConfirmQueue;