use MarketplaceDK;
GO

if OBJECT_ID('delivery_of_goods_to_warehouse_proc') is not null
	drop procedure delivery_of_goods_to_warehouse_proc;
go

create procedure delivery_of_goods_to_warehouse_proc
	@item_id bigint
	, @count decimal(9,2)
	, @seller bigint
	, @res varchar(max) out
-- Поставка товара на склад
as
begin
	/*
	declare @item_id bigint
	, @count decimal(9,2)
	, @seller bigint
	, @res varchar(max)

	set @seller = 101;
	set @item_id = 21290;
	set @count = 10;
	*/
	begin try;
		begin tran;
			if not exists(select 1 from ref_items where id = @item_id)
			begin
				set @res = 'item not found';
				--rollback;				
			end
			else 
			begin

				if not exists (select 1 from warehouse where seller_id = @seller and item_id = @item_id)
				begin
					insert into warehouse (seller_id, item_id, count)
					values (@seller, @item_id, @count);

					set @res = 'item added to the warehouse';
				end
				else
				begin
					update warehouse
					set count = isnull(count,0) + @count
					where seller_id = @seller and item_id = @item_id;

					set @res = 'item count updated';
				end
			end
		commit;
	end try
	begin catch
		rollback;
		set @res = ERROR_MESSAGE(); --'Error:' + convert(varchar(max), @@error);
	end catch;
	   		
	--print @res;

end
GO