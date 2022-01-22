use MarketplaceDK;
GO

if OBJECT_ID('order_create_proc') is not null
	drop procedure order_create_proc;
go

create procedure order_create_proc
	@num nvarchar(20)
	, @date datetime2
	, @address nvarchar(500)
	, @customer_id bigint
	, @res varchar(max) out
-- Создание заказа
as
begin
	declare @table_tmp table (id bigint);
	declare @order_id bigint = -1;


			if not exists(select 1 from clients where id = @customer_id)
			begin
				set @res = 'client not found';							
			end
			else 
			begin
				if not exists (select 1 from basket where customer_id = @customer_id)
				begin
					set @res = 'basket is empty';
				end
				else
				begin
					begin try;
						begin tran;
							if not exists (select 1 from orders where customer_id = @customer_id and num = @num)
							-- Если нет заказа, то вставляем
							begin
								insert into orders --(customer_id, num, date, address, status_id)
								output inserted.id into @table_tmp
								values (@num, @date, @address, 0, @customer_id);
						
								if (@@ROWCOUNT > 0)
								begin
									set @order_id = (select top 1 id from @table_tmp);
									set @res = 'order created. Order ID ' + convert(varchar(10),@order_id);
								end
								else
									set @res = 'order id is empty';
							end
							else
							begin
								if exists (select 1 from orders where customer_id = @customer_id and num = @num and status_id = 0)
								-- Если есть заказ, но в статусе формируется, то обновляем
								begin
									select @order_id = id from orders where customer_id = @customer_id and num = @num;

									update orders
									set date = @date,
										address = @address
									where id = @order_id;

									set @res = 'order updated. Order ID ' + convert(varchar(10),@order_id);
								end
								else
									if exists (select 1 from orders where customer_id = @customer_id and num = @num and status_id <> 0)
										set @res = 'order status is wrong to update';

							end

							if (@order_id <> -1)
							begin
								delete from order_details where order_header = @order_id;

								insert into order_details (order_header, seller_id, item_id, item_price, item_count)
								select @order_id, seller_id, item_id, item_price, item_count
								from basket
								where customer_id = @customer_id;
							end
						commit;
					end try
					begin catch
						rollback;
						set @res = ERROR_MESSAGE(); --'Error:' + convert(varchar(max), @@error);
					end catch;
				end
			end
	   		
	--print @res;
end
GO