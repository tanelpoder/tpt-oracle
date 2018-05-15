-- descxx.sql requires the display_raw function which is included in the comment section below.
-- the display_raw function is taken from Greg Rahn's blog as I'm too lazy to write one myself
--     http://structureddata.org/2007/10/16/how-to-display-high_valuelow_value-columns-from-user_tab_col_statistics/
--

PROMPT Install DISPLAY_RAW helper function into the current schema?
PAUSE Press ENTER to install, CTRL+C to cancel...

create or replace function display_raw (rawval raw, type varchar2)
return varchar2
is
   cn     number;
   cv     varchar2(128);
   cd     date;
   cnv    nvarchar2(128);
   cr     rowid;
   cc     char(128);
begin
   if (type = 'NUMBER') then
      dbms_stats.convert_raw_value(rawval, cn);
      return to_char(cn);
   elsif (type = 'VARCHAR2') then
      dbms_stats.convert_raw_value(rawval, cv);
      return to_char(cv);
   elsif (type = 'DATE') then
      dbms_stats.convert_raw_value(rawval, cd);
      return to_char(cd);
   elsif (type = 'NVARCHAR2') then
      dbms_stats.convert_raw_value(rawval, cnv);
      return to_char(cnv);
   elsif (type = 'ROWID') then
      dbms_stats.convert_raw_value(rawval, cr);
      return to_char(cnv);
   elsif (type = 'CHAR') then
      dbms_stats.convert_raw_value(rawval, cc);
      return to_char(cc);
   else
      return 'UNKNOWN DATATYPE';
   end if;
end;
/

grant execute on display_raw to public;
create public synonym display_raw for display_raw;

