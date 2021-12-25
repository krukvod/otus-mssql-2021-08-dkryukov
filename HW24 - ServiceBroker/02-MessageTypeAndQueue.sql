--Create Message Types for Request and Reply messages
USE WideWorldImporters
GO

-- For Request
CREATE MESSAGE TYPE
[//WWI/RequestMessage]
VALIDATION=WELL_FORMED_XML;

-- For Reply
CREATE MESSAGE TYPE
[//WWI/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO

CREATE CONTRACT [//WWI/Contract]
      ([//WWI/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/ReplyMessage]
         SENT BY TARGET
      );
GO

CREATE QUEUE QueueTrgtWWI;

CREATE SERVICE [//WWI/ServiceTrgt]
       ON QUEUE QueueTrgtWWI
       ([//WWI/Contract]);
GO


CREATE QUEUE QueueSrcWWI;

CREATE SERVICE [//WWI/ServiceInit]
       ON QUEUE QueueSrcWWI
       ([//WWI/Contract]);
GO
