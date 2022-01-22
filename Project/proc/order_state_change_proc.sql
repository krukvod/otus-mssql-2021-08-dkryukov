use MarketplaceDK;
GO

if OBJECT_ID('order_state_change_proc') is not null
	drop procedure order_state_change_proc;
go

create procedure order_state_change_proc
	@id bigint
	, @state bigint
	, @res varchar(max) out
-- �������� ������
as
begin
	declare @state_cur bigint, @state_name nvarchar(50);
	
	--select * from ref_order_status;
	
	if exists (select 1 from ref_order_status where id = @state)
	-- ���� ���������� ������, �� ���������, ����� ������
	begin
		set @state_cur = (select top 1 status_id  from orders where id = @id);
		select @state_name = status_name from ref_order_status where id = @state;


		if (@state_cur = 5) -- �������
		begin
			set @res = '��������� � ��������� ������ ������, ��� ��� ����� � ������� "�������"';
		end
		else
		begin
			if (@state = 5) -- �������
			begin
				if @state_cur = 0 or @state_cur = 1
				-- ������������ ��� �������
					update orders
					set status_id = @state
					where id = @id;

				else
					set @res = '��������� � ��������� ������ ������, ��� ��� ����� �� ��������� � ������� "�����������" ��� "�������"';
			end;

			if (@state = 4) -- ���������
			begin
				if @state_cur = 2 or @state_cur = 3
				-- ��������� ��� ���������
					update orders
					set status_id = @state
					where id = @id;

				else
					set @res = '��������� � ��������� ������ ������, ��� ��� ����� � ������� "���������" ��� "���������"';
			end;

			if (@state = 3) -- ���������
			begin
				if @state_cur = 2 
				-- ���������
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = '��������� � ��������� ������ ������, ��� ��� ����� �� ��������� � ������� "���������"';
			end;

			if (@state = 2) -- ���������
			begin
				if @state_cur = 1 	-- ������� 
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = '��������� � ��������� ������ ������, ��� ��� ����� �� ��������� � ������� "�������"';
			end;
		
			if (@state = 1) -- ���������
			begin
				if @state_cur = 0 	-- ������� 
					update orders
					set status_id = @state
					where id = @id;
				else
					set @res = '��������� � ��������� ������ ������, ��� ��� ����� �� ��������� � ������� "�����������"';
			end;
			if (isnull(@res,'') = '')
				set @res = '����� ��������� � ������ "' + @state_name + '"';
		end;
	end
	else
		set @res = '����������� ������ �� �������';
	--print @res;
end
GO