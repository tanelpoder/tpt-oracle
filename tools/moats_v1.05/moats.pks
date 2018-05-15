create or replace package moats as

   -- --------------------------------------------------------------------------
   -- MOATS v1.0 (c) Tanel Poder & Adrian Billington, 2010
   --
   -- See supplied README.txt for usage and disclaimers.
   --
   -- http://www.e2sn.com
   -- http://www.oracle-developer.net
   -- --------------------------------------------------------------------------

   -- Pipelined function to show TOP instance summary activity. The refresh rate
   -- defines how many ASH/SYSSTAT samples to take and is roughly equivalent to
   -- the number of seconds between screen refreshes...
   -- --------------------------------------------------------------------------
   function top (
            p_refresh_rate    in integer default null,
            p_ash_window_size in integer default null
            ) return moats_output_ntt pipelined;

   -- Helper procedure to size window to TOP output...
   -- --------------------------------------------------------------------------
   procedure format_window;

   -- Internal Use Only
   -- -----------------
   -- All functions and procedures from this point onwards are for internal use
   -- only in v1.01. Some of these will be exposed in future versions of MOATS.

   -- Pipelined function to return dynamic samples, queries, aggregations etc
   -- of active session data. The refresh rate defines (in seconds) how many
   -- ASH samples to take before running the query components...
   -- --------------------------------------------------------------------------
   function ash (
            p_refresh_rate in integer  default null,
            p_select       in varchar2 default null,
            p_where        in varchar2 default null,
            p_group_by     in varchar2 default null,
            p_order_by     in varchar2 default null
            ) return moats_output_ntt pipelined;

   -- Until 11g you can't bind UDTs into DBMS_SQL cursors, so this is an
   -- internal workaround. Can also be used to query all of the collected ASH
   -- samples. Note that gc_all_rows returns all ASH records between the two
   -- snapshots and gc_deltas returns only the lower and upper snapshots...
   -- --------------------------------------------------------------------------
   gc_all_rows constant pls_integer := 0;
   gc_deltas   constant pls_integer := 1;

   function get_ash (
            p_lower_snap in pls_integer default null,
            p_upper_snap in pls_integer default null,
            p_return_set in pls_integer default moats.gc_all_rows
            ) return moats_ash_ntt pipelined;

   -- Constants, get/set for moats parameters such as polling rate, ASH size...
   -- --------------------------------------------------------------------------
   gc_ash_polling_rate constant pls_integer := 0;
   gc_ash_threshold    constant pls_integer := 1;
   gc_top_refresh_rate constant pls_integer := 2;
   gc_ash_window_size  constant pls_integer := 3;

   procedure set_parameter(
             p_parameter_code  in pls_integer,
             p_parameter_value in integer
             );

   function get_parameter(
            p_parameter_code in pls_integer
            ) return integer;

   procedure restore_default_parameters;

   -- Debugging...
   -- --------------------------------------------------------------------------
   procedure show_snaps;

end moats;
/

