@echo off
cls
set CLASSPATH=.;C:\Work\Java\Exodus\bin\resources\mariadb-java-client-2.3.0.jar;C:\Work\Java\Exodus\bin\resources\mysql-connector-java-8.0.12.jar

mkdir resources>nul 2>nul
mkdir ddl>nul 2>nul
mkdir logs>nul 2>nul
mkdir export>nul 2>nul

copy *.jar resources>nul 2>nul
copy *.xml resources>nul 2>nul
copy *.properties resources>nul 2>nul

@echo on
java -Xms6196m -Xmx12240m mariadb.migration.Exodus
