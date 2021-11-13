select * from sys.dm_clr_properties

sp_configure 'show advanced options', 1 
reconfigure
GO

sp_configure 'clr strict security', 0
reconfigure
GO

ALTER DATABASE [WideWorldImporters]
SET TRUSTWORTHY ON
GO

-- drop assembly ClassLibraryCmd

create ASSEMBLY ClassLibraryCmd FROM 'd:\temp\ClassLibraryCmd\bin\Debug\ClassLibraryCmd.dll'
WITH PERMISSION_SET = UNSAFE;  


SELECT * FROM sys.assemblies
GO

-- drop function FCmd_f 

create FUNCTION FCmd_f (@cmd nvarchar(max), @args nvarchar(max))  
RETURNS table (txt nvarchar(4000))
AS EXTERNAL NAME [ClassLibraryCmd].[ClassLibraryCmd.Class1].FCmd;
GO 

select * FROM FCmd_f ('ping', '-n 2 google.com')
GO

SELECT dbo.fn_SayHello('OTUS Student')
