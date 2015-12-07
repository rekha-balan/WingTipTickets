/****** Object:  StoredProcedure [dbo].[Sp_Delete_Tenant]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Delete_Tenant]
	@TenantId int
AS
BEGIN
	BEGIN TRANSACTION DeleteTenant

	BEGIN TRY
		DELETE FROM UserAccount
		WHERE TenantId = @TenantId

		DELETE FROM CreditCard
		WHERE TenantId = @TenantId

		DELETE FROM Tenant 
		WHERE TenantId = @TenantId

		COMMIT TRANSACTION DeleteTenant;
	END TRY

	BEGIN CATCH
	  ROLLBACK TRANSACTION DeleteTenant
	END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Fetch_ProvisioningPipelineTasks]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Fetch_ProvisioningPipelineTasks]
	@ProvisioningOptionId int
AS
BEGIN
	SELECT		P.[ProvisioningPipelineId],
				P.[Position],
				P.[SequenceNo],
				T.[Description] AS 'TaskDescription',
				T.[Code] AS 'TaskCode'
	FROM		ProvisioningPipelineTasks P
	JOIN		ProvisioningTask T ON P.ProvisioningTaskId = T.ProvisioningTaskId
	WHERE		ProvisioningOptionId = @ProvisioningOptionId
	ORDER BY	P.SequenceNo
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Fetch_Tenant_ById]    Script Date: 2015-09-24 11:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenant_ById]
	@TenantId int
AS
BEGIN
	SELECT		T.[TenantId],
				T.[ThemeId],
				H.[Description] AS 'Theme',
				H.[Code] AS 'ThemeCode',
				T.[ProvisioningOptionId],
				T.[AzureServicesProvisioned],
				O.[Description] AS 'ProvisioningOption',
				O.[Code] AS 'ProvisioningOptionCode',
				T.[SiteName],
				T.[DataCenter],
				T.[OrganizationId],
				T.[SubscriptionId],
				A.[Username]
	FROM		[Tenant] T
	LEFT JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	LEFT JOIN	[Theme] H ON T.ThemeId = H.ThemeId
	LEFT JOIN	[UserAccount] A ON T.TenantId = A.TenantId
	WHERE		T.TenantId = @TenantId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Fetch_Tenant_ByUsername]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenant_ByUsername]
	@Username varchar(150)
AS
BEGIN
	SELECT		T.[TenantId],
				T.[ThemeId],
				H.[Description] AS 'Theme',
				H.[Code] AS 'ThemeCode',
				T.[ProvisioningOptionId],
				T.[AzureServicesProvisioned],
				O.[Description] AS 'ProvisioningOption',
				O.[Code] AS 'ProvisioningOptionCode',
				T.[SiteName],
				T.[DataCenter],
				T.[OrganizationId],
				T.[SubscriptionId]
	FROM		[Tenant] T
	LEFT JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	LEFT JOIN	[Theme] H ON T.ThemeId = H.ThemeId
	LEFT JOIN	[UserAccount] A ON T.TenantId = A.TenantId
	WHERE		A.Username = @Username
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Fetch_Tenants]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenants]
AS
BEGIN
	SELECT	T.[TenantId],
			T.[ThemeId],
			H.[Description] AS 'Theme',
			T.[ProvisioningOptionId],
			T.[AzureServicesProvisioned],
			O.[Description] AS 'ProvisioningOption',
			O.[Code] as 'ProvisioningOptionCode',
			T.[SiteName],
			T.[DataCenter]
	FROM	[Tenant] T
	JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	JOIN	[Theme] H ON T.ThemeId = H.ThemeId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Fetch_UserAccount]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Fetch_UserAccount]
	@Username varchar(150)
AS
BEGIN
	SELECT	[UserAccountId],
			[TenantId],
			[Firstname],
			[lastname],
			[Username],
			[Password],
			[CachedData],
			[UpdateDate]
	FROM	UserAccount
	WHERE	Username = @Username
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Insert_CreditCard]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Insert_CreditCard]
	@TenantId int,
	@CardNumber varchar(20),
	@ExpirationDate varchar(20),
	@CardVerificationValue varchar(3)
AS
BEGIN
	INSERT INTO CreditCard
	(
		[TenantId], 
		[CardNumber], 
		[ExpirationDate], 
		[CardVerificationValue]
	)
	VALUES
	(
		@TenantId,
		@CardNumber,
		@ExpirationDate,
		@CardVerificationValue
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Insert_Tenant]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Insert_Tenant]
	@ProvisioningOptionId int,
	@ThemeId int,
	@SiteName varchar(100),
	@DataCenter varchar(150),
	@OrganizationId varchar(50),
	@SubscriptionId varchar(50)
AS
BEGIN
	INSERT INTO Tenant 
	(
		[ProvisioningOptionId],
		[ThemeId],
		[SiteName],
		[DataCenter],
		[AzureServicesProvisioned],
		[OrganizationId],
		[SubscriptionId]
	)
	VALUES
	(
		@ProvisioningOptionId,
		@ThemeId,
		@SiteName,
		@DataCenter,
		0,
		@OrganizationId,
		@SubscriptionId
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Insert_UserAccount]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Insert_UserAccount]
	@FirstName varchar(150),
	@LastName varchar(150),
	@UserName varchar(150),
	@CachedData varbinary(Max),
	@UpdateDate datetime
AS
BEGIN
	INSERT INTO UserAccount
	(
		[Firstname],
		[Lastname],
		[Username],
		[CachedData], 
		[UpdateDate]
	)
	VALUES
	(
		@FirstName,
		@LastName,
		@Username,
		@CachedData,
		@UpdateDate
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Update_Tenant]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Update_Tenant]
	@TenantId int,
	@ProvisioningOptionId int,
	@ThemeId int,
	@SiteName varchar(100),
	@DataCenter varchar(150),
	@OrganizationId varchar(50),
	@SubscriptionId varchar(50)
AS
BEGIN
	UPDATE	Tenant 
	SET		[ProvisioningOptionId] = @ProvisioningOptionId,
			[ThemeId] = @ThemeId,
			[SiteName] = @SiteName,
			[DataCenter] = @DataCenter,
			[OrganizationId] = @OrganizationId,
			[SubscriptionId] = @SubscriptionId
	WHERE	[TenantId] = @TenantId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Update_Tenant_AzureServicesProvisioned]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Update_Tenant_AzureServicesProvisioned]
	@TenantId int,
	@AzureServicesProvisioned bit
AS
BEGIN
	UPDATE Tenant 
	SET	AzureServicesProvisioned = @AzureServicesProvisioned
	WHERE TenantId = @TenantId
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Update_UserAccount]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Update_UserAccount]
	@TenantId int,
	@Username varchar(150),
	@FirstName varchar(150),
	@LastName varchar(150)
AS
BEGIN
	UPDATE	UserAccount
	SET		TenantId = @TenantId,
			Firstname = @FirstName,
			Lastname = @LastName
	WHERE	Username = @Username
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Update_UserAccount_CacheData]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Update_UserAccount_CacheData]
	@Username varchar(150),
	@CachedData varbinary(Max),
	@UpdateDate datetime
AS
BEGIN
	UPDATE	UserAccount
	SET		CachedData = @CachedData,
			UpdateDate = @UpdateDate
	WHERE	Username = @Username
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_Upsert_UserAccount]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Upsert_UserAccount]
	@Username varchar(150),
	@CachedData varbinary(Max),
	@UpdateDate datetime
AS
BEGIN
	DECLARE @UserAccountId int

	SELECT  @UserAccountId = UserAccountId
	FROM	UserAccount
	WHERE	Username = @Username

	IF (@UserAccountId IS NOT NULL)
	BEGIN
		UPDATE	UserAccount
		SET		CachedData = @CachedData,
				UpdateDate = @UpdateDate
		WHERE	UserAccountId = @UserAccountId
	END
	ELSE
	BEGIN
		INSERT INTO UserAccount
		(
			[Username],
			[CachedData], 
			[UpdateDate]
		)
		VALUES
		(
			@Username,
			@CachedData,
			@UpdateDate
		)

		SELECT @UserAccountId = SCOPE_IDENTITY()
	END

	SELECT @UserAccountId as RecordId
END
GO

/****** Object:  Table [dbo].[CreditCard]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CreditCard](
	[CreditCardId] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NULL,
	[CardNumber] [varchar](20) NULL,
	[ExpirationDate] [varchar](20) NULL,
	[CardVerificationValue] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[CreditCardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Location]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Location](
	[LocationId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProvisioningOption]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProvisioningOption](
	[ProvisioningOptionId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProvisioningOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProvisioningPipelineTasks]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProvisioningPipelineTasks](
	[ProvisioningPipelineId] [int] IDENTITY(1,1) NOT NULL,
	[ProvisioningOptionId] [int] NULL,
	[ProvisioningTaskId] [int] NULL,
	[Position] [varchar](20) NOT NULL,
	[SequenceNo] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProvisioningPipelineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProvisioningTask]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProvisioningTask](
	[ProvisioningTaskId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProvisioningTaskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tenant]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tenant](
	[TenantId] [int] IDENTITY(1,1) NOT NULL,
	[ThemeId] [int] NULL,
	[ProvisioningOptionId] [int] NULL,
	[DataCenter] [varchar](150) NULL,
	[AzureServicesProvisioned] [bit] NOT NULL,
	[SiteName] [varchar](100) NULL,
	[OrganizationId] [varchar](50) NULL,
	[SubscriptionId] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Theme]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Theme](
	[ThemeId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](10) NULL,
	[SiteName] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ThemeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserAccount]    Script Date: 2015-09-23 02:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserAccount](
	[UserAccountId] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NULL,
	[Firstname] [varchar](150) NULL,
	[Lastname] [varchar](150) NULL,
	[Username] [varchar](150) NULL,
	[Password] [varchar](20) NULL,
	[CachedData] [varbinary](max) NULL,
	[UpdateDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

SET IDENTITY_INSERT [dbo].[Location] ON
GO

INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (1, N'North Central US', N'North Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (2, N'North Europe', N'North Europe')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (3, N'West Europe', N'West Europe')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (4, N'East US', N'East US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (5, N'East Asia', N'East Asia')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (6, N'Southeast Asia', N'Southeast Asia')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (7, N'West US', N'West US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (8, N'Central US', N'Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (9, N'Japan West', N'Japan West')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (10, N'Japan East', N'Japan East')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (11, N'South Central US', N'South Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (12, N'East US 2', N'East US 2')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (13, N'Brazil South', N'Brazil South')
GO

SET IDENTITY_INSERT [dbo].[Location] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningOption] ON 
GO

INSERT [dbo].[ProvisioningOption] ([ProvisioningOptionId], [Description], [Code]) VALUES (1, N'Standard', N'S')
INSERT [dbo].[ProvisioningOption] ([ProvisioningOptionId], [Description], [Code]) VALUES (2, N'Premium', N'P')
GO

SET IDENTITY_INSERT [dbo].[ProvisioningOption] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningPipelineTasks] ON 
GO

INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (1, 1, 1, N'', 1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (2, 1, 2, N'', 2)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (3, 1, 3, N'primary', 3)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (4, 1, 3, N'secondary', 4)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (5, 1, 5, N'primary', 5)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (6, 1, 6, N'primary', 6)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (7, 1, 13, N'', 7)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (8, 1, 11, N'primary', 8)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (9, 1, 7, N'primary', 9)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (10, 1, 8, N'primary', 10)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (11, 1, 9, N'primary', 11)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (12, 1, 7, N'secondary', 12)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (13, 1, 8, N'secondary', 13)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (14, 1, 9, N'secondary', 14)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (15, 1, 10, N'', 15)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (16, 1, 12, N'primary', 16)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo]) VALUES (17, 1, 12, N'secondary', 17)
GO

SET IDENTITY_INSERT [dbo].[ProvisioningPipelineTasks] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningTask] ON 
GO

INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (1, N'Resource Group', N'SharedResourceGroup')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (2, N'Storage Account', N'SharedStorageAccount')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (3, N'Database', N'StandardSqlServer')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (4, N'Database', N'PremiumSqlServer')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (5, N'Database Schema', N'SharedSqlServerSchema')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (6, N'Database Population', N'SharedSqlServerPopulate')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (7, N'Website Hosting Plan', N'SharedWebHostingPlan')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (8, N'Website', N'SharedWebsite')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (9, N'Website Deployment', N'SharedWebsiteDeployment')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (10, N'Traffic Manager', N'SharedTrafficManager')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (11, N'Search Service', N'SearchService')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (12, N'Auditing', N'SharedSqlAuditing')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (13, N'DocumentDb', N'SharedDocumentDb')
GO

SET IDENTITY_INSERT [dbo].[ProvisioningTask] OFF
GO
SET IDENTITY_INSERT [dbo].[Theme] ON 
GO

INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (1, N'Classical', N'S', N'WallaWallaSymphony')
INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (2, N'Pop', N'P', N'JulieAndThePlantes')
INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (3, N'Rock', N'R', N'TheArchieBoyleBand')
GO

SET IDENTITY_INSERT [dbo].[Theme] OFF
GO

ALTER TABLE [dbo].[CreditCard]  WITH CHECK ADD  CONSTRAINT [FK_CreditCard_Tenant] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Tenant] ([TenantId])
GO

ALTER TABLE [dbo].[CreditCard] CHECK CONSTRAINT [FK_CreditCard_Tenant]
GO

ALTER TABLE [dbo].[ProvisioningPipelineTasks]  WITH CHECK ADD FOREIGN KEY([ProvisioningOptionId])
REFERENCES [dbo].[ProvisioningOption] ([ProvisioningOptionId])
GO

ALTER TABLE [dbo].[ProvisioningPipelineTasks]  WITH CHECK ADD FOREIGN KEY([ProvisioningTaskId])
REFERENCES [dbo].[ProvisioningTask] ([ProvisioningTaskId])
GO

ALTER TABLE [dbo].[Tenant]  WITH CHECK ADD  CONSTRAINT [FK_Tenant_ProvisioningOption] FOREIGN KEY([ProvisioningOptionId])
REFERENCES [dbo].[ProvisioningOption] ([ProvisioningOptionId])
GO

ALTER TABLE [dbo].[Tenant] CHECK CONSTRAINT [FK_Tenant_ProvisioningOption]
GO

ALTER TABLE [dbo].[Tenant]  WITH CHECK ADD  CONSTRAINT [FK_Tenant_Theme] FOREIGN KEY([ThemeId])
REFERENCES [dbo].[Theme] ([ThemeId])
GO

ALTER TABLE [dbo].[Tenant] CHECK CONSTRAINT [FK_Tenant_Theme]
GO

ALTER TABLE [dbo].[UserAccount]  WITH CHECK ADD  CONSTRAINT [FK_UserAccount_Tenant] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Tenant] ([TenantId])
GO

ALTER TABLE [dbo].[UserAccount] CHECK CONSTRAINT [FK_UserAccount_Tenant]
GO