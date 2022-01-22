use MarketplaceDK;
GO

if OBJECT_ID('client_create_proc') is not null
	drop procedure client_create_proc;
go

create procedure client_create_proc 
	@client_name nvarchar(150)
	, @user_login nvarchar(50) = NULL
	, @client_type_id bigint
	, @address nvarchar(500)
	, @inn nvarchar(12) = NULL
	, @kpp nvarchar(9) = NULL
	, @schet nvarchar(25) = NULL
	, @bank nvarchar(1000) = NULL
	, @res varchar(max) out
-- Процедура создает запись клиента (покупателя или продавца)
as
begin

	declare @user_ bigint;
	/*
	declare @client_name nvarchar(150)
	, @user_login nvarchar(50) = NULL
	, @client_type_id bigint
	, @address nvarchar(500)
	, @inn nvarchar(12) = NULL
	, @kpp nvarchar(9) = NULL
	, @schet nvarchar(25) = NULL
	, @bank nvarchar(1000) = NULL
	, @res varchar(max)
	
	set @client_name = 'client1'
	set @user_login = 'user1'
	set @client_type_id = 2
	set @address = 'address for client 1'
	set @inn = null
	set @kpp = null
	set @schet = null
	set @bank = null
	set @res = ''
	*/	
	begin try;
		begin tran;
			select @user_ = id from users where user_login =  @user_login;

			if not exists (select 1 from clients where client_name = @client_name and client_type_id = @client_type_id)
			begin
				insert into clients (client_name, user_, client_type_id, address, inn, kpp, schet, bank)
				values (@client_name, @user_, @client_type_id, @address, @inn, @kpp, @schet, @bank);

				set @res = 'client created successfully';
			end
			else
				set @res = 'client with this client_type already exists';
		commit;
	end try
	begin catch
		rollback;
		set @res = ERROR_MESSAGE();
	end catch;

	--print @res

end
GO