/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
*/

DECLARE @xmlDoc  xml

SELECT @xmlDoc = BulkColumn
FROM OPENROWSET
(BULK 'C:\Temp\StockItems.xml', 
 SINGLE_CLOB)
as data 

select @xmldoc

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDoc

SELECT *
FROM OPENXML(@docHandle, N'StockItems/Item')
WITH ( 
	[StockItemName] nvarchar(100)  '@Name',
	[SupplierID] int 'SupplierID',
	UnitPackageID int 'Package/UnitPackageID',
    OuterPackageID int 'Package/OuterPackageID',
    QuantityPerOuter int 'Package/QuantityPerOuter',
    TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit',
	LeadTimeDays int 'LeadTimeDays', 
	IsChillerStock bit 'IsChillerStock', 
	TaxRate decimal(18,2) 'TaxRate', 
	UnitPrice decimal(18,2) 'UnitPrice'
)

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

select StockItemName as [@Name],
	SupplierID as [SupplierId],
	UnitPackageID as [Packcage/UnitPackageID],
	OuterPackageID as [Packcage/OuterPackageID],
    QuantityPerOuter as [Packcage/QuantityPerOuter],
    TypicalWeightPerUnit as [Packcage/TypicalWeightPerUnit],
	LeadTimeDays as [LeadTimeDays],
    IsChillerStock as [IsChillerStock],
    TaxRate as [TaxRate],
    UnitPrice as [UnitPrice]
from Warehouse.StockItems
order by StockItemName
for xml path('Item'), root('StockItems')

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select StockItemId, StockItemName,  
	json_value(CustomFields,'$.CountryOfManufacture') as CustomFields,
	json_value(CustomFields,'$.Tags[0]') as FirstTag
from Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

select StockItemId, StockItemName, CustomFields,
	JSON_QUERY(CustomFields , '$.Tags') AS tags_res, tags.value
from Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields , '$.Tags') tags
WHERE tags.value = 'Vintage'


