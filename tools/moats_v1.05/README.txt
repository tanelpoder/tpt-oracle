
Mother Of All Tuning Scripts (MOATS) README
===========================================

Copyright Information
=====================
MOATS v1.04, September 2010
(c) Adrian Billington www.oracle-developer.net
(c) Tanel Poder       www.e2sn.com

Contents
========
1.0 Introduction
2.0 Supported Versions
3.0 Installation & Removal
   3.1 Prerequisites
      3.1.1 System Privileges
      3.1.2 Object Privileges
   3.2 Installation
   3.3 Removal
4.0 Usage
   4.1 SQL*Plus Setup
      4.1.1 Window Size
      4.1.2 SQL*Plus Settings
   4.2 MOATS TOP Usage
      4.2.1 Using MOATS.TOP directly
      4.2.2 Using the TOP view
   4.3 Other MOATS APIs
5.0 Roadmap
6.0 Disclaimer
7.0 Acknowledgements

 
1.0 Introduction
================
MOATS is a simple tuning tool that samples active sessions and reports top database activity in regular screen refreshes at specified intervals (similar to the TOP utility for UNIX). MOATS is designed to run in sqlplus only and has recommended display settings to enable screen refreshes.

Examples of how this application might be used:

   -- To report top session and instance activity at 5 second intervals...
   -- --------------------------------------------------------------------

   SQL> set arrays 36 lines 110 head off tab off

   SQL> SELECT * FROM TABLE(moats.top(5));


   -- Sample output...
   -- --------------------------------------------------------------------

   MOATS: The Mother Of All Tuning Scripts v1.0 by Adrian Billington & Tanel Poder
          http://www.oracle-developer.net & http://www.e2sn.com

   + INSTANCE SUMMARY ------------------------------------------------------------------------------------------+
   | Instance: ora112           | Execs/s:     2.0 | sParse/s:     0.0 | LIOs/s:  219637.3 | Read MB/s:     0.0 |
   | Cur Time: 13-Aug 19:25:14  | Calls/s:     0.0 | hParse/s:     0.0 | PhyRD/s:      0.5 | Write MB/s:    0.0 |
   | History:  0h 0m 26s        | Commits/s:   0.0 | ccHits/s:     1.5 | PhyWR/s:      2.9 | Redo MB/s:     0.0 |
   +------------------------------------------------------------------------------------------------------------+

   + TOP SQL_ID (child#) -----+ TOP SESSIONS ---------+      + TOP WAITS -------------------------+ WAIT CLASS -+
   |  50% | bwx4var9q4y9f (0) | 71                    |      | 100% | latch: cache buffers chains | Concurrency |
   |  50% | bq2qr0bhjyv1c (0) | 133                   |      |  50% | SQL*Net message to client   | Network     |
   |  50% | 799uuu8tpf6rk (0) | 6                     |      |                                    |             |
   +--------------------------------------------------+      +--------------------------------------------------+

   + TOP SQL_ID ----+ PLAN_HASH_VALUE + SQL TEXT ---------------------------------------------------------------+
   | bwx4var9q4y9f  | 2119813036      | select  /*+ full(a) full(b) use_nl(a b) */  count(*) from  sys.obj$ a,  |
   |                |                 | ys.obj$ b where  a.name = b.name and rownum <= 1000002                  |
   + ---------------------------------------------------------------------------------------------------------- +
   | bq2qr0bhjyv1c  | 644658511       | select moats_ash_ot( systimestamp, saddr, sid, serial#, audsid, paddr,  |
   |                |                 | er#,                                  username, command, ownerid, taddr |
   + ---------------------------------------------------------------------------------------------------------- +
   | 799uuu8tpf6rk  | 2119813036      | select  /*+ full(a) full(b) use_nl(a b) */  count(*) from  sys.obj$ a,  |
   |                |                 | ys.obj$ b where  a.name = b.name and rownum <= 1000001                  |
   + ---------------------------------------------------------------------------------------------------------- +

   
2.0 Supported Versions
======================
MOATS supports all Oracle versions of 10g Release 2 and above. 


3.0 Installation & Removal
==========================
MOATS requires several database objects to be created. The privileges, installation and removal steps are described below.

3.1 Prerequisites
-----------------
It is recommended that this application is installed in a "TOOLS" schema, but whichever schema is used requires the following privileges. Note that any or all of these grants can be assigned to either the MOATS target schema itself or a role that is granted to the MOATS target schema.

3.1.1 System Privileges
-----------------------   
   * CREATE TYPE
   * CREATE TABLE
   * CREATE VIEW
   * CREATE PROCEDURE

3.1.2 Object Privileges
-----------------------
   * EXECUTE ON DBMS_LOCK
   * SELECT ON V_$SESSION    ***
   * SELECT ON V_$STATNAME   ***
   * SELECT ON V_$SYSSTAT    ***
   * SELECT ON V_$LATCH      ***
   * SELECT ON V_$TIMER      ***
   * SELECT ON V_$SQL        ***
 
  *** Note: 
         a) SELECT ANY DICTIONARY can be granted in place of the specific V$ view grants above
         b) Supplied scripts will grant/revoke all of the above to/from the MOATS target schema/role.

3.2 Installation
----------------
MOATS can be installed using sqlplus or any tools that fully support sqlplus commands. To install MOATS:

1) Ensure that the MOATS owner schema has the required privileges described in Section 3.1 above. A script named moats_privs_grant.sql is supplied if required (this will need to be run as a user with admin grant rights on SYS objects. This script will prompt for the name of the target MOATS schema).

2) To install MOATS, login as the target schema and run the moats_install.sql script. A warning will prompt for a continue/cancel option.

3.3 Removal
-----------
To remove MOATS, login as the MOATS owner schema and run the moats_remove.sql script. A warning will prompt for a continue/cancel option.

To revoke all related privileges from the MOATS owner schema, a script named moats_privs_revoke.sql is supplied if required (this will need to be run as a user with admin grant rights on SYS objects. This script will prompt for the name of the target MOATS schema).

4.0 Usage
=========
MOATS is simple to use. It is designed for sqlplus only and makes use of sqlplus and PL/SQL functionality to provide real-time screen refreshes. To make the most of MOATS v1.0, follow the steps below.

4.1 SQL*Plus Setup
------------------
MOATS TOP output is of a fixed size so needs some specific settings.

4.1.1 Setting Window Size
-------------------------
The MOATS.FORMAT_WINDOW procedure is a visual aid to setting the right screen size for MOATS. To run it, login to sqlplus and do the following:

   * set serveroutput on format wrapped
   * exec moats.format_window
   * resize window to the dotted lines at the top and bottom of the FORMAT_WINDOW output

Window size should be at least 110 x 36 but the FORMAT_WINDOW procedure is the best way to get accurate and optimal settings for MOATS.

4.1.2 SQL*Plus Settings
-----------------------
MOATS comes with a moats_settings.sql file that does the following:

   * set arrays 36
   * set lines 110
   * set head off
   * set tab off
   * set serveroutput on format wrapped

These are optimal sqlplus settings for the MOATS TOP utility and need to be set before running it (see Usage below).

4.2 MOATS TOP Usage
-------------------
MOATS.TOP is a pipelined function that outputs instance performance statistics at a given refresh interval. Before running TOP, the moats_settings.sql script (or equivalent) should be run in the sqlplus session. The following example refreshes the instance statistics at the default 10 seconds:

4.2.1 Using MOATS.TOP directly
------------------------------

   +-------------------------------------+
   | SQL> @moats_settings.sql            |
   |                                     |
   | SQL> SELECT *                       |
   |  2   FROM   TABLE(moats.top);       |
   +-------------------------------------+

To use a non-default refresh rate, supply it as follows:

   +-------------------------------------+
   | SQL> SELECT *                       |
   |  2   FROM   TABLE(moats.top(5));    |
   +-------------------------------------+

This example uses a 5 second refresh rate.

To stop MOATS.TOP refreshes, use a Ctrl-C interrupt.

4.2.2 Using the TOP view
------------------------
A view named TOP is included with MOATS for convenience.

   +-------------------------------------+
   | SQL> @moats_settings.sql            |
   |                                     |
   | SQL> SELECT * FROM top;             |
   +-------------------------------------+

To set a non-default value for refresh rate, set the MOATS refresh rate parameter, as follows.

   +--------------------------------------------------------------+
   | SQL> @moats_settings.sql                                     |
   |                                                              |
   | SQL> exec moats.set_parameter(moats.gc_top_refresh_rate, 3); |
   |                                                              |
   | SQL> SELECT * FROM top;                                      |
   +--------------------------------------------------------------+

This example uses a 3 second refresh rate.

4.3 Other MOATS APIs
--------------------
MOATS contains several other public APIs that are currently for internal use only. These will be fully described and "released" with future MOATS versions but are currently only supported for use by MOATS.TOP. They include pipelined functions to query the active session data that MOATS gathers. 

5.0 Roadmap
===========
There is no fixed roadmap at the time of writing. Features that Tanel and Adrian would like to add (but are not limited to) the following:

   * formally expose the active session query functions for custom-reporting
   * add drill-down functionality for SQL statements of interest in the TOP output

6.0 Disclaimer
==============
This software is supplied in good faith and is free for download, but any subsequent use is entirely at the end-users' risk. Adrian Billington/oracle-developer.net and Tanel Poder/www.e2sn.com do not accept any responsibility for problems arising as a result of using MOATS. All users are strongly advised to read the installation and removal scripts prior to running them and test the application in an appropriate environment.

7.0 Acknowledgements
====================
Many thanks to Randolf Geist for his contributions to the latest version of MOATS, including several bug-fixes to the original alpha version.