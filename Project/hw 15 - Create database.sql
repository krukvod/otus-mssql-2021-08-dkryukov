USE master;
GO
IF DB_ID (N'MarketplaceDK') IS NOT NULL
DROP DATABASE MarketplaceDK;
GO

create database MarketplaceDK
ON primary
( name = MarketplaceDK,
    filename = 'd:\temp\MarketplaceDK.mdf',
    SIZE = 10,
    FILEGROWTH = 5 )
LOG ON
( name = MarketplaceDK_log,
    FILENAME = 'd:\temp\MarketplaceDK_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 5) ;
GO