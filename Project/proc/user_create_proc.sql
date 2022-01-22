use MarketplaceDK;
GO

if OBJECT_ID('user_create_proc') is not null
	drop procedure user_create_proc;
go

create procedure user_create_proc 
	  @user_nm nvarchar(50)
	, @user_login nvarchar(50)
	, @user_pass nvarchar(50)
	, @res nvarchar(max) out
-- Процедура создания пользователя
as
begin
	declare @res1 nvarchar(3000), @res2 nvarchar(3000);
/*
	declare @user_nm nvarchar(50)
	, @user_login nvarchar(50)
	, @user_pass nvarchar(50)

	set @user_login = 'user3';
	set @user_pass = 'pass3';
	set @user_nm = 'user3'
	*/
	begin try;
		begin tran;
			if not exists (select 1 from sys.server_principals where name = @user_login)
			begin
				exec ('CREATE LOGIN ' + @user_login + ' WITH PASSWORD = ''' + @user_pass + '''');
				--print @@error;
				set @res1 = 'login created successfully;';
			end
			else
				set @res1 = 'login already exists;';
		commit;
	end try
	begin catch
		rollback;
		set @res1 = ERROR_MESSAGE();
	end catch;
	
	begin try;
		begin tran;
			if not exists (select 1 from sys.database_principals  where name = @user_login)
			begin
				exec ('CREATE USER ' + @user_login + ' FOR LOGIN ' + @user_login);
				--print @@error;
				exec ('EXEC sp_addrolemember ''db_datawriter'', ' + @user_login );
				exec ('EXEC sp_addrolemember ''db_datareader'', ' + @user_login );

				set @res1 = isnull(@res1,' ')+'user created successfully';
			end
			else
				--print 'user already exists';
				set @res1 = isnull(@res1,' ')+'user already exists';
		commit;
	end try
	begin catch
		rollback;
		--print @@error;
		set @res1 = ERROR_MESSAGE();
	end catch;
	
	begin try;
		begin tran;
			if not exists (select 1 from users where user_login = @user_login)
			begin
				insert into users(user_nm, user_login, user_password, isActive)
				values (@user_nm, @user_login, @user_pass, 1);
				set @res2 = 'rows added in table users';
			end
			else
				set @res2 = 'row in table user already exists';
		commit;
	end try
	begin catch
		rollback;
		set @res2 = ERROR_MESSAGE();
	end catch;
	   		
	set @res = isnull(@res1,'') + ';' + isnull(@res2, '');
end
GO