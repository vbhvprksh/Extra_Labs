# /*

# MODULE 5 : RECOVERY MODELS AND BACKUP STRATEGIES

PART 1 : RECOVERY MODELS AND DATABASE BACKUPS

Topics Covered

1. Understanding Recovery Models
2. SIMPLE Recovery Model
3. FULL Recovery Model
4. BULK_LOGGED Recovery Model
5. Switching Recovery Models
6. Performing Full Database Backup
7. Verifying Backup Files
8. Backup Best Practices
9. Troubleshooting Backup Issues

Execute entire script as SysAdmin

Prerequisites

Create folder manually

C:\SQLBackups\

SQL Server Service Account must have

Read and Write permissions

on

C:\SQLBackups\

===============================================================================
*/

USE master;
GO

# /*

# STEP 1 : CREATE DATABASE

Why are we creating this database?

This database will be used to demonstrate

different recovery models and backup strategies.

Recovery Model determines

How transactions are logged

Whether Point-In-Time recovery is possible

Whether Transaction Log backups are supported

Equivalent SSMS Navigation

Databases

Right Click

New Database

Database Name

BackupLab

===============================================================================
*/

CREATE DATABASE BackupLab;
GO

/******************************************************************************

VERIFY DATABASE CREATION

Catalog View

sys.databases

Expected Result

## name

BackupLab

## recovery_model_desc

SIMPLE

Note

New databases are created in

SIMPLE recovery model

by default.

UI Verification

SSMS

Databases

Refresh

BackupLab

Right Click

Properties

Options

Recovery Model

SIMPLE

******************************************************************************/

SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLab';
GO

# /*

# STEP 2 : CHANGE RECOVERY MODEL TO FULL

FULL Recovery Model

Characteristics

Supports Point-In-Time Restore

Supports Log Backups

Supports Tail Log Backups

Minimal data loss

Suitable For

Production Databases

Financial Systems

ERP Systems

Mission Critical Applications

Important

After changing to FULL

A Full Backup must be taken

before log backups become possible.

Equivalent UI

SSMS

Databases

BackupLab

Right Click

Properties

Options

Recovery Model

Select

FULL

Click OK

===============================================================================
*/

ALTER DATABASE BackupLab

SET RECOVERY FULL;
GO

/******************************************************************************

VERIFY RECOVERY MODEL

Expected Result

## name

BackupLab

## recovery_model_desc

FULL

UI Verification

Databases

BackupLab

Properties

Options

Recovery Model

FULL

******************************************************************************/

SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLab';
GO

# /*

# STEP 3 : CHANGE RECOVERY MODEL TO BULK_LOGGED

BULK_LOGGED Recovery Model

Purpose

Reduces transaction log growth

during large bulk operations.

Examples

BULK INSERT

SELECT INTO

Index Rebuild

BCP Import

Advantages

Smaller log backups

Disadvantages

Point-In-Time restore

not supported

during bulk operations.

Equivalent UI

BackupLab

Properties

Options

Recovery Model

Bulk Logged

===============================================================================
*/

ALTER DATABASE BackupLab

SET RECOVERY BULK_LOGGED;
GO

/******************************************************************************

VERIFY RECOVERY MODEL

Expected Result

BULK_LOGGED

******************************************************************************/

SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLab';
GO

# /*

# STEP 4 : CHANGE RECOVERY MODEL TO SIMPLE

SIMPLE Recovery Model

Characteristics

Transaction log automatically truncated

No log backups allowed

Cannot restore to specific time

Suitable For

Development Databases

Testing Environments

Reporting Databases

Equivalent UI

BackupLab

Properties

Options

Recovery Model

Simple

===============================================================================
*/

ALTER DATABASE BackupLab

SET RECOVERY SIMPLE;
GO

/******************************************************************************

VERIFY CURRENT RECOVERY MODEL

Expected Result

recovery_model_desc

---

SIMPLE

UI Verification

Databases

BackupLab

Properties

Options

Recovery Model

Simple

******************************************************************************/

SELECT

recovery_model_desc

FROM sys.databases

WHERE name='BackupLab';
GO

# /*

# STEP 5 : PERFORM FULL DATABASE BACKUP

What is a Full Backup?

A Full Backup contains

All data pages

System metadata

Objects

Indexes

Stored Procedures

Backup Location

C:\SQLBackups\BackupLab.bak

WITH INIT

Overwrites existing backup file

instead of appending.

Equivalent UI

BackupLab

Right Click

Tasks

Back Up

Backup Type

Full

Destination

Disk

Add

C:\SQLBackups\BackupLab.bak

Click OK

===============================================================================
*/

BACKUP DATABASE BackupLab

TO DISK='C:\SQLBackups\BackupLab.bak'

WITH INIT;
GO

/******************************************************************************

EXPECTED RESULT

Processed xxx pages

BACKUP DATABASE successfully processed.

Backup file created

BackupLab.bak

Common Errors

Cannot open backup device

Cause

Folder missing

Fix

Create

C:\SQLBackups\

Cause

SQL Server service lacks permissions

Fix

Grant Full Control

to SQL Server Service Account

******************************************************************************/

# /*

# STEP 6 : VERIFY BACKUP FILE

RESTORE HEADERONLY

Reads metadata from backup

without restoring database.

Information Returned

Backup Name

Backup Type

Backup Start Date

Database Version

Recovery Model

Backup Size

Equivalent UI

Not available in SSMS GUI

Execute TSQL only

===============================================================================
*/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\BackupLab.bak';
GO

/******************************************************************************

EXPECTED RESULT

## BackupType

1

## BackupName

BackupLab

## DatabaseName

BackupLab

BackupStartDate

BackupFinishDate

BackupType Values

1 = Full Backup

2 = Transaction Log Backup

5 = Differential Backup

******************************************************************************/

# /*

# STEP 7 : COMPARISON OF RECOVERY MODELS

+----------------------------------------------------------+
| Recovery Model | Log Backup | PITR | Log Growth |
+----------------------------------------------------------+
| SIMPLE         | No         | No   | Low        |
| FULL           | Yes        | Yes  | High       |
| BULK_LOGGED    | Yes        | Limited | Medium  |
+----------------------------------------------------------+

PITR

Point In Time Restore

===============================================================================
*/

# /*

# STEP 8 : BEST PRACTICES

Always take Full Backups regularly

Use FULL Recovery for Production

Schedule Log Backups every 15 minutes

Test restores periodically

Store backups on separate disks

Keep multiple backup generations

Use CHECKSUM option

Example

BACKUP DATABASE BackupLab

TO DISK='C:\SQLBackups\BackupLab.bak'

WITH INIT,CHECKSUM;

===============================================================================
*/
GO

# /*

# STEP 9 : MINI LAB EXERCISES

Exercise 1

Switch database to FULL

Take Full Backup

Exercise 2

Take Differential Backup

Exercise 3

Create second database

FinanceDB

Exercise 4

Check recovery model

Exercise 5

Perform backup verification

Exercise 6

Try backup to invalid path

Observe error message

===============================================================================
*/
GO

# /*

STEP 10 : CLEANUP

Run only if cleanup is required

===============================================================================
*/

USE master;
GO

ALTER DATABASE BackupLab

SET SINGLE_USER

WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE BackupLab;
GO

/******************************************************************************

EXPECTED RESULT

BackupLab

Removed

UI Verification

SSMS

Databases

Refresh

BackupLab

disappears

Backup File

BackupLab.bak

still remains

Delete manually if needed.

******************************************************************************/

GO
