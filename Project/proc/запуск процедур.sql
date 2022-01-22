use MarketplaceDK
GO
-- Создание пользователя
declare @user nvarchar(50), @pass nvarchar(50), @res nvarchar(max);

set @user = 'user1';
set @pass = 'pass1';
set @res = '';

select * from users where user_login = @user;

exec user_create_proc 
	  @user_nm = @user
	, @user_login = @user
	, @user_pass = @pass
	, @res = @res out;

select @res;

select * from users where user_login = @user;
GO

-- Создание клиента
declare @client_name nvarchar(150)
	, @user_login nvarchar(50) = NULL
	, @client_type_id bigint
	, @address nvarchar(500)
	, @inn nvarchar(12) = NULL
	, @kpp nvarchar(9) = NULL
	, @schet nvarchar(25) = NULL
	, @bank nvarchar(1000) = NULL
	, @res varchar(max)
;	
	
	set @client_name = 'client other fam second_name';
	set @user_login = 'user3';
	set @client_type_id = 2;
	set @address = 'address for ' + @client_name;
	--set @inn = '111111111111';
	--set @kpp = '121212121';
	--set @schet = '1111111111111111111111111';
	--set @bank = 'bank data for ' + @client_name;
	set @res = '';

select * from clients where client_name = @client_name;

exec client_create_proc
	  @client_name = @client_name
	, @user_login = @user_login
	, @client_type_id = @client_type_id
	, @address = @address
	, @inn = @inn
	, @kpp = @kpp
	, @schet = @schet
	, @bank = @bank
	, @res = @res out
;

select @res;

select * from clients where client_name = @client_name;
GO

-- Поставка товара на склад
declare @item_id bigint
	, @count decimal(9,2)
	, @seller bigint
	, @res varchar(max)

declare @dog table (
	item bigint
	, count decimal(9,2)
)
;

insert into @dog 
values (21291, 10)
, (21292, 10)
, (21293, 10)
, (21294, 10)
;
	set @seller = 101;
--	set @item_id = 21290;
--	set @count = 10;

select * from warehouse where seller_id = @seller order by item_id;

declare dog_cur cursor for
select item, count
from @dog
order by item

open dog_cur; 

fetch next from dog_cur into @item_id, @count;

while @@FETCH_STATUS = 0
begin
	set @res = '';
	print 'Item ID ' + convert(varchar(10), @item_id);
	
	exec delivery_of_goods_to_warehouse_proc
		@item_id = @item_id
		, @count = @count
		, @seller = @seller
		, @res = @res out;
	
	print @res;

	fetch next from dog_cur into @item_id, @count;
end

close dog_cur;
deallocate dog_cur;


select * from warehouse where seller_id = @seller order by item_id;
GO

-- Оформление заказа
declare @customer bigint, @num nvarchar(20), @dat datetime2, @res varchar(max), @adress nvarchar(500);

set @customer = 15;
set @num = '3-oz';
set @dat = getdate();
set @adress = 'какой-то адресс клиента ___ dfsf sfc';
set @res = '';

delete from basket where customer_id = @customer;

insert into basket (customer_id, seller_id, item_id, item_count)
values (@customer, 129, 29886, 2),
(@customer, 155, 30124, 4),
(@customer, 155, 30123, 6)
;

update basket
set item_price = price
from ref_items i
where basket.item_id = i.id and basket.customer_id = @customer;


select * from orders where customer_id = @customer and date = @dat;

exec order_create_proc
	@num = @num
	, @date = @dat
	, @address = @adress
	, @customer_id = @customer
	, @res = @res out
;

select @res;

select * 
from orders o
join order_details d
on o.id = d.order_header
where o.customer_id = @customer and o.date = @dat;
GO

-- Перевод заказа по статусам
/*
id	status_name
0	Сформирован
1	Оплачен
2	Отправлен
3	Доставлен
4	Возвращен
5	Отменен
*/

declare @order_id bigint, @state bigint, @res varchar(max);

--select * from orders 
set @order_id = 11;
set @state = 5;
set @res = '';

select * from orders where id = @order_id;

exec order_state_change_proc 
	@id = @order_id
	, @state = @state
	, @res = @res out;

select @res;

select * from orders where id = @order_id;
