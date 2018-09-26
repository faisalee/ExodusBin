# ExodusBin
Binaries for the Exodus (MySQL to MariaDB)

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

##Paths with reference to the current folder. Do not use "/" at the end of the path
#LogPath=/home/faisal/Work/Java/Exodus/src/logs
#DDLPath=/home/faisal/Work/Java/Exodus/src/ddl
#ExportPath=/home/faisal/Work/Java/Exodus/src/export

#Path for Windows
LogPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\logs
DDLPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\ddl
ExportPath=C:\\Users\\faisa\\OneDrive\\Work\\Java\\Exodus\\src\\export
```

For first time, change the `DryRun=NO` to `YES` so that we can be sure of our setup.

Other important paramneters

- `UsersToMigrate`
  - This is a SQL compatible syntax that defines which DB users are to be migrated
- `DatabaseToMigrate`
  - List of databases *Case Sensitive* to be migrated, again this is compatible with SQL syntax
- `TablesToMigrate`
  - Is ths list of tables that we want to migrate, this is also case sensitive if you want to migrate a specific list of tables, normally for all tables just use the following to migrate all the tables
    - `TablesToMigrate = TABLE_NAME LIKE '%'`
- `SkipTableMigration`
  - This defines the list of tables that you want to skip from the Migration process, this only useful if you have specify "%" for `TablesToMigrate`

*One important thing to take note is, don't select MySQL internal tables and databases for migration for instance `mysql`, `sys` etc.!*

#### Exodus Execution

You will need Java JRE 8 or higher to run this, I am using Java 10.0.2 

```
C:\> java -version
java version "10.0.2" 2018-07-17
Java(TM) SE Runtime Environment 18.3 (build 10.0.2+13)
Java HotSpot(TM) 64-Bit Server VM 18.3 (build 10.0.2+13, mixed mode)
```

- For Windows, edit the `WindowsExec.cmd` script and modify the CLASSPATH to point to your `bin\resources` folder depending on where you extracted the ZIP file.

- For Windows, edit the `exec` script and modify the CLASSPATH to point to your `bin/resources` folder depending on where you extracted the ZIP file.

*remember to keep the first dot `.` in the CLASSPATH as it needs to points back to your current path.*

Make sure `java -version` works for your session and then execute either of the above two scripts depending on your environment.

This script can run from a third machine which has access to both MySQL and MariaDB databases.

