<#
.Synopsis
    Azure SQL database operation.
 .DESCRIPTION
    This script is used to create object in azure sql database.
 .EXAMPLE
    Deploy-DBSchema 'ServerName', 'UserName', 'Password', 'Location', 'DatabaseEdition', 'DatabaseName'
 .INPUTS    
    1. ServerName
        Azure sql database server name for connection.
    2. UserName
        Username for sql database connection.
    3. Password
        Password for sql database connection.
    4. Location
        Location ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast') for object creation
    5. DatabaseEdition
        DatabaseEdition ('Basic','Standard', 'Premium') for object creation    
    6. DatabaseName
        Azure sql database name.    

 .OUTPUTS
    Message creation of DB schema.
 .NOTES
    All parameters are mandatory.
 .COMPONENT
    The component this cmdlet belongs to Azure Sql.
 .ROLE
    The role this cmdlet belongs to the person having azure sql access.
 .FUNCTIONALITY
    The functionality that best describes this cmdlet.
#>
function Deploy-DBSchema
{
    [CmdletBinding()]
    Param
    (        
        #Azure SQL server name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $ServerName,

        #Azure SQL database server location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for AzureSQL server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $ServerLocation,

        #Azure SQL database server location
        [Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('Basic','Standard', 'Premium')?")]
        [ValidateSet('Basic','Standard', 'Premium')]
        [String]
        $DatabaseEdition,
	
        #Azure SQL db user name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $UserName,

        #Azure SQL db password for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $Password,
                
		#Azure SQL Database name.
        [Parameter(Mandatory=$true)]
        [String]        
        $DatabaseName
    )
    Process
    {
        
    	#Add-AzureAccount

        #
        # ****** Check Server exists ******
        #
        $dbServerExists=$true
        Try 
        {
            Write-Host "### Checking whether Azure SQL Database Server $ServerName already exists. ###" -foregroundcolor "yellow"
            $existingDbServer=Get-AzureSqlDatabaseServer -ServerName $ServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue
            If($existingDbServer.ServerName -eq $ServerName) 
            {
                Write-Host "### Azure SQL Database Server: $ServerName exists. ###" -foregroundcolor "yellow"
                $dbServerExists=$true
            }
            else
            {
                Write-Host "### Existing Azure SQL Database Server: $ServerName does not exist. ###" -foregroundcolor "red"
                $dbServerExists=$false
	        }
        }
        Catch
        {
	            Write-Host "Get-AzureSqlDatabaseServer failed.."
                $dbServerExists=$false
        }
    
        #
        # ****** Check Database exists ******
        #

        $dbExists=$true
        if(!$dbServerExists) 
        {
            $dbExists=$false
        }
        else
        {
	        Try
        {
                $azureSqlDatabaseExists = Get-AzureSqlDatabase -ServerName $ServerName -DatabaseName $DatabaseName  -ErrorVariable azureSqlDatabaseExistsErrors -ErrorAction SilentlyContinue

                if($azureSqlDatabaseExists.Count -gt 0)
                {
                    Write-Host $DatabaseName " Database already exists on the server '" $ServerName "'"  -foregroundcolor "red"
                }

                elseif($azureSqlDatabaseExists.Count -eq 0)
                {
                    $dbExists=$false
                    $MaxDatabaseSizeGB=5
                    Write-Host " "
                    Write-Host "### Creating database ' " $DatabaseName " ' ###"
                    New-AzureSqlDatabase -ServerName $ServerName -DatabaseName "$DatabaseName" -Edition "$DatabaseEdition"
                    Write-Host "Success: New database $DatabaseName created" -foregroundcolor "green"

                    $ConnectionString = "Server=tcp:$ServerName.database.windows.net;
					Database=$DatabaseName;
					User ID=$UserName;
					Password=$Password;
					Trusted_Connection=False;
					Encrypt=True;"
                    
                    $Connection = New-object system.data.SqlClient.SqlConnection($ConnectionString)
                    $Command = New-Object System.Data.SqlClient.SqlCommand('',$Connection)
                    #Open the connection with db server.
                    $Connection.Open()
                    If(!$Connection)
                    {
                        throw "Failed to open connection $ConnectionString"
                    }
                    Write-Host "Success: Connection opened to database.. '" $DatabaseName "'"

           
                    If ($DatabaseName -eq $DatabaseName)
                    {
                        Write-Host "Creating Customer tables..."
                        $Command.CommandText = 'CREATE TABLE Customers
												(
													[CustomerId] INT PRIMARY KEY IDENTITY,
													[FirstName] VARCHAR(50),
													[LastName] VARCHAR(50),
													[Email] VARCHAR(100),
													[ContactNbr] VARCHAR(30),
													[Password] VARCHAR(50),
													[CreditCardNbr] VARCHAR(50),
													[LastKnownLocation] GEOGRAPHY,
													[Address] VARCHAR(50),
													[CityId] INT,
													[Fax] VARCHAR(30)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'Customers' created. "

		                $Command.CommandText = 'CREATE TABLE Organizers
												(
													[OrganizerId] INT PRIMARY KEY IDENTITY,
													[FirstName] VARCHAR(50),
													[LastName] VARCHAR(50),
													[Email] VARCHAR(100),
													[ContactNbr] NUMERIC(15,0),
													[Password] VARCHAR(50),
													[Address] VARCHAR(50),
													[CityId] INT,
													[Fax] VARCHAR(30)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'Organizers' created. "

		                $Command.CommandText = 'CREATE TABLE CustomerCreditCard
												(
													[CustomerCreditCardI] INT PRIMARY KEY IDENTITY,
													[CustomerId] INT,
													[NameOnCard] VARCHAR(50),
													[CardType] VARCHAR(25),
													[CardNumber] VARCHAR(30),
													[ExpiryMonth] INT,
													[ExpiryYear] INT,
													[SecurityCode] VARCHAR(25)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'CustomerCreditCard' created. "
		                                    
		                Write-Host "Creating Concert tables..."
		                
                        $Command.CommandText = 'CREATE TABLE Concerts
												(
													[ConcertId] INT PRIMARY KEY IDENTITY,
													[ConcertName] VARCHAR(150),
													[Description] VARCHAR(250),
													[ConcertDate] DATETIME,
													[Duration] INT,
													[VenueId] INT,
													[PerformerId] INT,
													[SaveToDbServerType] INT DEFAULT 0,
													[RowVersion] ROWVERSION
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'Concerts' created. "

		                $Command.CommandText = 'CREATE TABLE Performers
												(
													[PerformerId] INT PRIMARY KEY IDENTITY,
													[FirstName] VARCHAR(50),
													[LastName] VARCHAR(50),
													[Skills] VARCHAR(100),
													[ContactNbr] NUMERIC(15,0),
													[ShortName] VARCHAR(30),
													[RowVersion] ROWVERSION
												)'

		                $Result = $Command.ExecuteNonQuery()
                    
		                Write-Host "Creating Venue tables ..."
		                $Command.CommandText = 'CREATE TABLE Country
												(
													[CountryId] INT PRIMARY KEY IDENTITY,
													[CountryName] VARCHAR(50),
													[Description] VARCHAR(100)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'Country' created. "

		                $Command.CommandText = 'CREATE TABLE States
												(
													[StateId] INT PRIMARY KEY IDENTITY,
													[StateName] VARCHAR(50),
													[Description] VARCHAR(100),
													[CountryId] INT
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'States' created. "

		                $Command.CommandText = 'CREATE TABLE City
												(
													[CityId] INT PRIMARY KEY IDENTITY,
													[CityName] VARCHAR(50),
													[Description] VARCHAR(100),
													[StateId] INT
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'City' created. "

		                $Command.CommandText = 'CREATE TABLE Venues
												(
													[VenueId] INT PRIMARY KEY IDENTITY,
													[VenueName] VARCHAR(50),
													[Capacity] INT,
													[Description] VARCHAR(100),
													[CityId] INT,
													[RowVersion] ROWVERSION
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'Venues' created. "

		                $Command.CommandText = 'CREATE TABLE SeatSection
												(
													[SeatSectionId] INT PRIMARY KEY IDENTITY,
													[SeatCount] INT,
													[VenueId] INT,
													[Description] VARCHAR(100)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'SeatSection' created."

		                $Command.CommandText = 'CREATE TABLE WebSiteActionLog
												(
													[WebSiteActionLogId] INT PRIMARY KEY IDENTITY,
													[VenueId] INT,
													[Action] VARCHAR(100),
													[UpdatedBy] INT,
													[UpdatedDate] DATETIME
												)'

		                $Result = $Command.ExecuteNonQuery()
                    
		                Write-Host "Creating Tickets tables... "
		                $Command.CommandText = 'CREATE TABLE TicketLevels
												(
													[TicketLevelId] INT PRIMARY KEY IDENTITY,
													[TicketLevel] VARCHAR(25),
													[Description] VARCHAR(100),
													[SeatSectionId] INT,
													[ConcertId] INT,
													[TicketPrice] NUMERIC(10,2)
												)'

		                $Result = $Command.ExecuteNonQuery()

		                Write-Host "Success: Table 'TicketLevels' created."

		                $Command.CommandText = 'CREATE TABLE Tickets
												(
													[TicketId] INT PRIMARY KEY IDENTITY,
													[CustomerId] INT,
													[Name] VARCHAR(50),
													[TicketLevelId] INT,
													[ConcertId] INT,
													[PurchaseDate] DATETIME
												)'

		            $Result = $Command.ExecuteNonQuery()

		            Write-Host "Success: Table 'Tickets' created."
                    
		$Command.CommandText = 'CREATE VIEW ConcertSearch AS
								SELECT c.ConcertId, c.ConcertName, CONVERT(DATETIMEOFFSET, c.ConcertDate) AS ConcertDate, 
									   c.VenueId, v.VenueName, i.CityName AS VenueCity, s.StateName AS VenueState, p.CountryName AS VenueCountry, 
									   a.PerformerId, a.ShortName AS PerformerName,
									   c.ConcertName + '' featuring '' + a.ShortName + '' playing at '' + v.VenueName + '' in '' + i.CityName + '' on '' + DATENAME(M, c.ConcertDate) + '' '' + DATENAME(D, c.ConcertDate) AS FullTitle,
									   (SELECT MAX(RowVersion) FROM (SELECT c.RowVersion UNION SELECT v.RowVersion UNION SELECT a.RowVersion) r) AS RowVersion
								FROM Concerts c
								JOIN Venues v ON c.VenueId = v.VenueId
								JOIN City i ON v.CityId = i.CityId
								JOIN States s ON i.StateId = s.StateId
								JOIN Country p ON s.CountryId = p.CountryId
								JOIN Performers a ON c.PerformerId = a.PerformerId'

		$Result = $Command.ExecuteNonQuery()

		Write-Host "Success: View 'ConcertSearch' created."
                    }

	        $Connection.Close()
	        $Connection=$null
        }
        Write-Host " "
        Write-Host "SUCCESS: ALL Database tables created and database connection closed. " -foregroundcolor "yellow"
        Write-Host " "    
    }
                   
        Catch
        {
            Write-Error "Error -- $Error "
            $dbExists=$false
        }
    }
    }
    }