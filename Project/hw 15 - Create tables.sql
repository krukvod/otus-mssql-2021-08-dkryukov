use MarketplaceDK
GO

-- sp_client_type
IF OBJECT_ID ('sp_client_type') is null
CREATE TABLE [sp_client_type]
(
 [id]           bigint IDENTITY (1, 1) NOT NULL ,
 [cl_type_name] varchar(50) NOT NULL ,


 CONSTRAINT [PK_sp_client_type] PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

-- sp_item_category
IF OBJECT_ID ('sp_item_category') is null
CREATE TABLE [sp_item_category]
(
 [category_name] varchar(150) NOT NULL ,
 [parent_id]     bigint NULL ,
 [id]            bigint IDENTITY (1, 1) NOT NULL ,
 
 CONSTRAINT [PK_sp_item_category] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [fk_sp_item_category_parent_id_id] FOREIGN KEY ([parent_id])  REFERENCES [sp_item_category]([id])
);
GO


CREATE NONCLUSTERED INDEX [Idx_sp_item_category_parent_id] ON [sp_item_category] 
 (
  [parent_id] ASC
 )

GO

-- sp_items
IF OBJECT_ID ('sp_items') is null
CREATE TABLE [sp_items]
(
 [id]        bigint IDENTITY (1, 1) NOT NULL ,
 [item_code] varchar(50) NOT NULL ,
 [item_name] varchar(500) NOT NULL ,
 [descr]     varchar(2000) NOT NULL ,
 [weight]    decimal(9,2) NOT NULL ,
 [height]    decimal(9,2) NOT NULL ,
 [depth]     decimal(9,2) NOT NULL ,
 [width]     decimal(9,2) NOT NULL ,
 [category1] bigint NOT NULL ,
 [category2] bigint NOT NULL ,
 [category3] bigint NOT NULL ,
 
 CONSTRAINT [PK_sp_items] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [FK_sp_item_category_id1] FOREIGN KEY ([category1])  REFERENCES [sp_item_category]([id]),
 CONSTRAINT [FK_sp_item_category_id2] FOREIGN KEY ([category2])  REFERENCES [sp_item_category]([id]),
 CONSTRAINT [FK_sp_item_Category_id3] FOREIGN KEY ([category3])  REFERENCES [sp_item_category]([id])
);
GO


CREATE NONCLUSTERED INDEX [Idx_sp_items_category1] ON [sp_items]  (  [category1] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_Idx_sp_items_category2] ON [sp_items]  (  [category2] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_Idx_sp_items_category3] ON [sp_items]  (  [category3] ASC )
GO

-- sp_order_status
IF OBJECT_ID ('sp_order_status') is null
CREATE TABLE [sp_order_status]
(
 [id]          bigint IDENTITY (1, 1) NOT NULL ,
 [status_name] varchar(50) NOT NULL ,
 
 CONSTRAINT [PK_sp_order_status] PRIMARY KEY CLUSTERED ([id] ASC)
);
GO


-- users
IF OBJECT_ID ('users') is null
CREATE TABLE [users]
(
 [id]         bigint IDENTITY (1, 1) NOT NULL ,
 [user_nm]    varchar(50) NOT NULL ,
 [user_login] varchar(50) NOT NULL ,
 [isActive]   bit NOT NULL ,
 
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

-- clients
IF OBJECT_ID ('clients') is null
CREATE TABLE [clients]
(
 [id]             bigint IDENTITY (1, 1) NOT NULL ,
 [client_name]    varchar(150) NOT NULL ,
 [user_]          bigint NOT NULL ,
 [client_type_id] bigint NOT NULL ,
 [address]        varchar(500) NOT NULL ,
 [inn]            int NOT NULL ,
 [kpp]            int NOT NULL ,
 [schet]          int NOT NULL ,
 [bank]           varchar(1000) NOT NULL ,
 
 CONSTRAINT [PK_clients] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [FK_sp_client_type_id] FOREIGN KEY ([client_type_id])  REFERENCES [sp_client_type]([id]),
 CONSTRAINT [FK_users_id] FOREIGN KEY ([user_])  REFERENCES [users]([id])
);
GO

CREATE NONCLUSTERED INDEX [Idx_clients_client_type_id] ON [clients]  (  [client_type_id] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_clients_user] ON [clients]  (  [user_] ASC )
GO


-- orders
IF OBJECT_ID ('orders') is null
CREATE TABLE [orders]
(
 [num]         varchar(20) NOT NULL ,
 [date]        datetime2(7) NOT NULL ,
 [address]     varchar(500) NOT NULL ,
 [status_id]   bigint NOT NULL ,
 [customer_id] bigint NOT NULL ,
 [id]          bigint IDENTITY (1, 1) NOT NULL ,
 
 CONSTRAINT [PK_orders] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [FK_clients_id_customer_id] FOREIGN KEY ([customer_id])  REFERENCES [clients]([id]),
 CONSTRAINT [FK_sp_order_status_id] FOREIGN KEY ([status_id])  REFERENCES [sp_order_status]([id])
);
GO

CREATE NONCLUSTERED INDEX [Idx_orders_status_id] ON [orders]  (  [status_id] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_orders_customer_id] ON [orders]  (  [customer_id] ASC )
GO

-- order_details
IF OBJECT_ID ('order_details') is null
CREATE TABLE [order_details]
(
 [id]            bigint IDENTITY (1, 1) NOT NULL ,
 [order_header]  bigint NOT NULL ,
 [seller_id]     bigint NOT NULL ,
 [item_count]    decimal(9,2) NOT NULL check (item_count > 0),
 [item_price]    decimal(9,2) NOT NULL ,
 [item_summa]    as [item_count]*[item_price] PERSISTED,
 [item_id]       bigint NOT NULL ,
 
 CONSTRAINT [PK_order_details] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [FK_client_id_order_details_seller_id] FOREIGN KEY ([seller_id])  REFERENCES [clients]([id]),
 CONSTRAINT [FK_orders_header] FOREIGN KEY ([order_header])  REFERENCES [orders]([id]),
 CONSTRAINT [FK_sp_items_id] FOREIGN KEY ([item_id])  REFERENCES [sp_items]([id])
);
GO


CREATE NONCLUSTERED INDEX [Idx_order_details_item_id] ON [order_details]  (  [item_id] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_order_details_seller_id] ON [order_details]  (  [seller_id] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_order_details_order_header] ON [order_details]  (  [order_header] ASC )
GO

-- warehouse
IF OBJECT_ID ('warehouse') is null
CREATE TABLE [warehouse]
(
 [id]        bigint IDENTITY (1, 1) NOT NULL ,
 [count]     decimal(9,2) NOT NULL ,
 [seller_id] bigint NOT NULL ,
 [item_id]   bigint NOT NULL ,
 [price]     decimal(9,2) NOT NULL check (price > 0),
 
 CONSTRAINT [PK_warehouse] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [FK_clients_id_warehouse_seller_id] FOREIGN KEY ([seller_id])  REFERENCES [clients]([id]),
 CONSTRAINT [FK_sp_items_id_warehouse_item_id] FOREIGN KEY ([item_id])  REFERENCES [sp_items]([id])
);
GO

CREATE NONCLUSTERED INDEX [Idx_warehouse_item_id] ON [warehouse] (  [item_id] ASC )
GO

CREATE NONCLUSTERED INDEX [Idx_warehouse_seller_id] ON [warehouse]  (  [seller_id] ASC )
GO
