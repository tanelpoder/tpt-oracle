--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------


================================================================================
SESSPACK v0.05 readme
================================================================================

About:

	Sesspack can be best described as session level statspack for Oracle.
	It collects less data than statspack, "only" the session level wait events
	and v$sesstat info and stores it in its repository.

	However Sesspack allows you to select the sampled sessions very flexibly,
	you can sample all sessions in an instance or only few, based on various
	conditions like SID, username, osuser, program, client machine, currently 
	effective module and action etc.

	Sesspack doesn't add extra instrumentation overhead to the database, it 
	just queries v$session_event, v$sesstat and few other views when executed.

	Note that with large number of sessions (1000+) you may want to sample
	sessions selectively to save disk space and reduce snapshot CPU usage

	For further information, see http://www.tanelpoder.com


Installation:

	1) Using SQLPLUS, log on as user who can *grant* access on V$ views (SYS for example)

	2) Create a user if want to have sesspack object in separate schema and grant connect to it

	3) run install_sesspack.sql <username> <password> <connect_string>

	   e.g. @install_sesspack sesspack mypassword prod01

	4) check sesspack_install.log

Usage example:

	Note that the reports require fairly wide linesize (120+)

	1) exec sesspack.snap_orauser('<USERNAME>')
	2) do some work
	3) exec sesspack.snap_orauser('<USERNAME>')
	4) @list
	5) @sr sid,program 1 2

	This will take snapshot 1 and 2 of user <USERNAME>


Reference:

  Taking snapshots:

	sesspack.snap_me			- snaps current session stats
	sesspack.snap_sid			- snaps given SIDs stats
	sesspack.snap_orauser('<orauser>')	- snaps all given ORACLE user's sessions's stats
	sesspack.snap_osuser('<osuser>')	- snaps all given OS user's sessions's stats
	sesspack.snap_program('<program>')	- snaps all given programs session stats
	sesspack.snap_machine('<machine>')	- snaps all given machines session stats 
	sesspack.snap_spid('spid')		- snaps all given SPID session stats 
	sesspack.snap_cpid('cpid')		- snaps all given client PID session stats 
	sesspack.snap_all			- snaps all session stats
	sesspack.snap_bg			- snaps background processes sessions stats
	sesspack.snap_fg			- snaps foreground processes sessions stats

	sesspack.snap_sidlist_internal('select sid from v$sesstat where <your custom conditions>')
						- snaps all SIDs returned by custom SQL

  Reporting performance data:

	list.sql	shows you snapshots with brief descriptions

	sr.sql	<grouping_col> <x> <y>	

			shows you the session event deltas between selected snapshots, grouped by a column

                Columns can be:

				1
				SID
				AUDSID
				SERIAL#
				USERNAME
				PROGRAM
				TERMINAL
				MACHINE
				OSUSER
				PROCESS

		To get a session-level resource usage breakdown, use:

			@sr sid <start> <end>

		To get resource usage summed and rolled up by client program nama, use:

			@sr program <start> <end>

		To get resource usage on sid level but you also want to see other data columns in output, 
		you can combine the columns:

			@sr program,module <start> <end>

		To sum up all measured resource consumption in the snap, use dummy column 1:

			@sr 1 <start> <end>



  Purging old data:

	1) exec sesspack.purge_data;	-- purges all data older than a week
	   or 
           exec sesspack.purge_data(<days_to_keep);
	2) commit;


  Customization:

	For disk space reasons ony the sesspack.snap_me procedure gathers all v$sesstat statistics.
	Other procedures gather session statistics based on 



Roadmap/Notes/bugs/issues:


v0.05
========

	fixes in gathering snaps & sr report
	Schema - large tables compressed IOTs
	performance report allows grouping by any field
	purge capability


v0.04
========
	customizable template-based session stats sampling
	more snap procedures

v0.03b
========
	Using V$SESSION_TIME_MODEL for getting if 10g+

v0.03
========
	Multi-session snapshots should work ok now
	I realized that standard-snapshots can't include all v$sesstat contents in snapshot by default - too much data generated
	This is ok though, as we usually need only CPU time from there anyway.

V0.02
========
	Lots.
	Test first with only single Oracle user session - with multiple simultaneous logged on sessions there's some cartesian join somewhere



