/*
Insert, Update, Merge

÷ель:
¬ этом ƒ« вы научитесь работать с запис€ми и потренируетесь писать запросы.
*/
-- 1. ƒовставл€ть в базу п€ть записей использу€ insert в таблицу Customers или Suppliers
insert into Purchasing.Suppliers (SupplierName, SupplierCategoryID, PrimaryContactPersonID,
	AlternateContacTPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy) 
	values ('Supplier1', 2, 29, 30, 10, 18634, 18634, 10, '(111) 111-0101', '(111) 111-0101', 'http://www.supplier1.com', 'DeliveryAddressLine1_Supplier1', 27906, 'PostalAddressLine1_Supplier1', 27906, 1),
		('Supplier2', 8, 29, 30, 10, 13870, 13870, 10, '(222) 222-0202', '(222) 222-0202', 'http://www.supplier2.com', 'DeliveryAddressLine1_Supplier2', 27202, 'PostalAddressLine1_Supplier2', 27202, 1),
		('Supplier3', 7, 29, 30, 10, 7899, 7899, 10, '(333) 333-0303', '(333) 333-0303', 'http://www.supplier3.com', 'DeliveryAddressLine1_Supplier3', 27154, 'PostalAddressLine1_Supplier3', 27154, 1),
		('Supplier4', 9, 29, 30, 10, 18634, 18634, 10, '(444) 444-0404', '(444) 444-0404', 'http://www.supplier4.com', 'DeliveryAddressLine1_Supplier4', 27677, 'PostalAddressLine1_Supplier4', 27677, 1),
		('Supplier5', 6, 29, 30, 10, 30378, 30378, 10, '(555) 555-0505', '(555) 555-0505', 'http://www.supplier5.com', 'DeliveryAddressLine1_Supplier5', 27006, 'PostalAddressLine1_Supplier5', 27006, 1);

-- 2. ”далите одну запись из Customers, котора€ была вами добавлена
delete from Purchasing.Suppliers where SupplierId = 18

-- 3. »зменить одну запись, из добавленных через UPDATE
update Purchasing.Suppliers 
set PhoneNumber = '(444) 404-0444'
where SupplierId = 19


-- 4. Ќаписать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
merge Purchasing.Suppliers as target
using (select * from (values(21,'Supplier3', 7, 29, 30, 10, 7899, 7899, 10, '(333) 333-0303', '(333) 333-0303', 'http://www.supplier3.com', 'DeliveryAddressLine1_Supplier3', 27154, 'PostalAddressLine1_Supplier3', 27154, 1),
		(19, 'Supplier4_1', 9, 29, 30, 10, 18634, 18634, 10, '(444) 444-0404', '(444) 444-0404', 'http://www.supplier4.com', 'DeliveryAddressLine1_Supplier4', 27677, 'PostalAddressLine1_Supplier4', 27677, 1),
		(20, 'Supplier5', 6, 29, 30, 10, 18634, 30378, 10, '(555) 515-0505', '(555) 555-0505', 'http://www.supplier5_1.com', 'DeliveryAddressLine1_Supplier5', 27006, 'PostalAddressLine1_Supplier5', 27006, 1)
) as t (SupplierId, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
	AlternateContacTPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
) as source
on target.SupplierId = source.SupplierID
when matched then 
	update set
	target.SupplierName = source.SupplierName, 
	target.SupplierCategoryID = source.SupplierCategoryID, 
	target.PrimaryContactPersonID = source.PrimaryContactPersonID,
	target.AlternateContacTPersonID = source.AlternateContacTPersonID, 
	target.DeliveryMethodID = source.DeliveryMethodID, 
	target.DeliveryCityID = source.DeliveryCityID, 
	target.PostalCityID = source.PostalCityID, 
	target.PaymentDays = source.PaymentDays,
	target.PhoneNumber = source.PhoneNumber, 
	target.FaxNumber = source.FaxNumber, 
	target.WebsiteURL = source.WebsiteURL, 
	target.DeliveryAddressLine1 = source.DeliveryAddressLine1, 
	target.DeliveryPostalCode = source.DeliveryPostalCode, 
	target.PostalAddressLine1 = source.PostalAddressLine1, 
	target.PostalPostalCode = source.PostalPostalCode, 
	target.LastEditedBy = source.LastEditedBy
when not matched
	then insert (SupplierId, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
	AlternateContacTPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
	values (source.SupplierId, source.SupplierName, source.SupplierCategoryID, source.PrimaryContactPersonID,
	source.AlternateContacTPersonID, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, source.PaymentDays,
	source.PhoneNumber, source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryPostalCode, source.PostalAddressLine1, source.PostalPostalCode, LastEditedBy);

-- 5. Ќапишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Purchasing.Suppliers" out  "c:\temp\Suppliers.txt" -T -w -t; -S DESKTOP-UV0TSBM -U sa -P y011277'

select top 0 * into Purchasing.Suppliers_tmp from Purchasing.Suppliers

BULK INSERT [WideWorldImporters].Purchasing.Suppliers_tmp
				   FROM "c:\temp\Suppliers.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = ';',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

					  
select * from Purchasing.Suppliers_tmp;
