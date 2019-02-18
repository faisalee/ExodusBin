# ExodusBin
Binaries for the Exodus (MySQL to MariaDB)

Demo/Turorial: https://youtu.be/QFbfcIXoBo8

#### Database Setup
Download the entire bin folder as a ZIP using the "CLONE" function. Once downloaded edit /bin/dbdetails.xml with the connection details for both source and target databases. 

Make sure the user used to connect to the Target (MariaDB) database uses a user with `ALL` and `WITH GRANT OPTION` privileges as it will try to create database and users based on the source (MySQL)

Here is an extract from my own setup for the migration user on MariaDB.
```
MariaDB [(none)]> show grants for migration;
+-------------------------------------------------------------------------------------------------------------------------------------+
| Grants for migration@%                                                                                                              |
+-------------------------------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'migration'@'%' IDENTIFIED BY PASSWORD '*9677B3E0EA32E863BCE766756E363CF03A6C7E4C' WITH GRANT OPTION |
+-------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.000 sec)

MariaDB [(none)]>
```

This user will be a temporary one, once migration is done, this user can be removed once no longer needed.

For the source user, we don't need `WITH GRANT OPTION` but `ALL ON *.*` is needed as it needs to read the schema and structure from all the tables and databases on the source.

Following is my setup for the migraiton user on MySQL database;
```
mysql> show grants for migration;
+------------------------------------------------+
| Grants for migration@%                         |
+------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'migration'@'%' |
+------------------------------------------------+
1 row in set (0.00 sec)

mysql>
```

#### Exodus Configuration

Edit the /bin/Exodus.properties file and modify the following section as needed. Start with 1 `ThreadCount` Change the `LogPath`, `DDLPath` and `ExportPath` according to the setup, the folders are already there in the donloaded ZIP file, just need to edit the paths to specify complete path from `/` for Linux and `C:\\` for Windows. 

- Take note, we have to user doubble back slash `\\` for paths  in Windows

```
# ThreadCount is for parallel Table loading, each thread will take care of ONE table.
ThreadCount=1

TargetDB=MariaDB
TargetConnectParams=useUnicode=yes&characterEncoding=utf8&rewriteBatchedStatements=true
#useBatchMultiSend=true&useServerPrepStmts=false&

#TransactionSize is the size of the Batch, COMMIT will be executed after each batch submission to the Database.
TransactionSize=10000

#This is only applicable for data migration, if set to YES, on a batch failure, the same batch will be re-tried in Single ROW mode (YES/NO)
RetryOnErrors=YES

#This will truncate the tables that were partially migrated previously, With this property enabled, migration can be re-run and it will continue from the last table (YES/NO)
OverwritePartiallyMigratedTables=YES

##Paths with reference to the current folder. Do not use "/" at the end of the path
LogPath=/home/faisal/Work/Java/Exodus/src/logs
DDLPath=/home/faisal/Work/Java/Exodus/src/ddl
ExportPath=/home/faisal/Work/Java/Exodus/src/export

#Path for Windows
#LogPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\logs
#DDLPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\ddl
#ExportPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\export

#WHERE Clause Additional Criteria, following is an Example
SCHEMANAME.TABLENAME.WHERECriteria = COL1 = 74196328 AND COL2 LIKE 'SOMETHING%'

#Additional Criteria like LIMIT or ORDER BY etc., following is an Example
SCHEMANAME.TABLEname.AdditionalCriteria = LIMIT 13

#This dictates if Table structure and data migration will be done, use NO to skip
MigrateData=YES

#Create (YES/NO) for Additional Objects while Migrating
CreateViews=YES
CreatePLSQL=YES
CreateTriggers=YES

#This dictates of user Grants will be migrated or not, use NO to skip Grants migration
UserGrants=YES
```

For first time, change the `DryRun=NO` to `YES` so that we can be sure of our setup.

The TargetConnectParams has now `rewriteBatchedStatements=true` this will rewrite bulk statements automatically for much faster writes!

`WHERECriteria` and `AdditionalCriteria` have been added to take care of extra WHERE clause for individual tables and additional expression like `ORDER BY` or `LIMIT n`

Other important paramneters

- `ThreadCount`
  - Default is 1, this controls how many tables will be migrated in parallel.
- `TransactionSize`
  - Records will be sent to the MariaDB using batches, this parameter decides how many records in each batch. Commit/Rollback is done after each batch. In case of any errors while processing a batch, the entire batch will face a rollback.
- `RetryOnErrors`
  - In case of any error during the batch processing, if this parameter is set to YES, the batch will be re-processed in single transaction mode. This will force to write the successful records and only the records having problems will be rollbacked.
- `UsersToMigrate`
  - This is a SQL compatible syntax that defines which DB users are to be migrated.
- `OverwritePartiallyMigratedTables`
  - In case migration process was broken or killed during a table was being migrated, That table will be marked as partially migrated. With this parameter set to YES, that table will be overwritten when the migration is re-run, else, the migration will throw failure errors.
- `DatabaseToMigrate`
  - List of databases *Case Sensitive* to be migrated, again this is compatible with SQL syntax
- `TablesToMigrate`
  - Is ths list of tables that we want to migrate, this is also case sensitive if you want to migrate a specific list of tables, normally for all tables just use the following to migrate all the tables
    - `TablesToMigrate = TABLE_NAME LIKE '%'`
- `SkipTableMigration`
  - This defines the list of tables that you want to skip from the Migration process, this only useful if you have specify "%" for `TablesToMigrate`
- `CreateViews`
  - YES/NO will decide if Views will be migrated or not.
- `CreatePLSQL`
  - YES/NO will decide if PL/SQL (Stored Procedures / Stored Functions) will be migrated or not.
- `CreateTriggers`
  - YES/NO will decide if Triggers will be migrated or not.
- `UserGrants`
  - YES/NO will decide if User Grants will be migrated or not.
- `MigrateData`
  - YES/NO will decide if Table's DDL and Data will be migrated or not.

*One important thing to take note is, don't select MySQL internal tables and databases for migration for instance `mysql`, `sys` etc.!*

#### Exodus Execution

You will need Java JRE 8 or higher to run this, I am using Java 1.8.0_192

```
C:\>java -version
java version "1.8.0_192"
Java(TM) SE Runtime Environment (build 1.8.0_192-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.192-b12, mixed mode)
```

- For Windows, edit the `WindowsExec.cmd` script and modify the CLASSPATH to point to your `bin\resources` folder depending on where you extracted the ZIP file.

- For Linux/Mac, edit the `exec` script and modify the CLASSPATH to point to your `bin/resources` folder depending on where you extracted the ZIP file.

*remember to keep the first dot `.` in the CLASSPATH as it needs to points back to your current path.*

Make sure `java -version` works for your session and then execute either of the above two scripts depending on your environment.

This script can run from a third machine which has access to both MySQL and MariaDB databases.

