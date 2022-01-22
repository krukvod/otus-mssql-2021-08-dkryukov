use MarketplaceDK;
GO

if OBJECT_ID('order_state_change_proc') is not null
	drop procedure order_state_change_proc;
go

create procedure order_state_change_proc
	@id bigint
	, @state bigint
	, @res varchar(max) out
-- Создание заказа
as
begin
	declare @state_cur bigint, @state_name nvarchar(50);
	
	--select * from ref_order_status;
	
	if exists (select 1 from ref_order_status where id = @state)
	-- Если существует статус, то проверяем, иначе ошибка
	begin
		set @state_cur = (select top 1 status_id  from orders where id = @id);
		select @state_name = status_name from ref_order_status where id = @state;


		if (@state_cur = 5) -- Отменен
		begin
			set @res = 'Перевести в указанный статус нельзя, так как заказ в статусе "Отменен"';
		end
		else
		begin
			if (@state = 5) -- Отменен
			begin
				if @state_cur = 0 or @state_cur = 1
				-- Сформирована или Оплачен
					update orders
					set status_id = @state
					where id = @id;

				else
					set @res = 'Перевести в указанный статус нельзя, так как заказ не находится в статусе "Сформирован" или "Оплачен"';
			end;

			if (@state = 4) -- Возвращен
			begin
				if @state_cur = 2 or @state_cur = 3
				-- Отправлен или Доставлен
					update orders
					set status_id = @state
					where id = @id;

				else
					set @res = 'Перевести в указанный статус нельзя, так как заказ в статусе "Отправлен" или "Доставлен"';
			end;

			if (@state = 3) -- Доставлен
			begin
				if @state_cur = 2 
				-- Отправлен
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = 'Перевести в указанный статус нельзя, так как заказ не находится в статусе "Отправлен"';
			end;

			if (@state = 2) -- Отправлен
			begin
				if @state_cur = 1 	-- Оплачен 
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = 'Перевести в указанный статус нельзя, так как заказ не находится в статусе "Оплачен"';
			end;
		
			if (@state = 1) -- Отправлен
			begin
				if @state_cur = 0 	-- Оплачен 
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = 'Перевести в указанный статус нельзя, так как заказ не находится в статусе "Сформирован"';
			end;
			if (isnull(@res,'') = '')
				set @res = 'Заказ переведен в статус "' + @state_name + '"';
		end;
	end
	else
		set @res = 'Неправильно указан ИД статуса';
	--print @res;
end
GO