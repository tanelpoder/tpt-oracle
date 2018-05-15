-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Advanced Oracle SQL Tuning

-- when testing purposes on 11g+
ALTER SESSION SET "_optimizer_use_feedback"=FALSE;

--exec dbms_outln.drop_unused;
exec dbms_outln.drop_by_cat('TEMP_SWAP_OUTLINE');
exec dbms_outln.drop_by_cat('TEMP_SWAP_OUTLINE_BAD');
exec dbms_outln.drop_by_cat('TEMP_SWAP_OUTLINE_GOOD');
-- this command will drop all default outlines!!!
exec dbms_outln.drop_by_cat('DEFAULT');

delete from ol$;
delete from ol$hints;
delete from ol$nodes;
COMMIT;

ALTER SYSTEM FLUSH SHARED_POOL;

-- bad original query
SELECT
    ch.channel_desc
  , co.country_iso_code co
  , cu.cust_city
  , p.prod_category
  , sum(s.quantity_sold)
  , sum(s.amount_sold)
FROM
    sh.sales     s
  , sh.customers cu
  , sh.countries co
  , sh.products  p
  , sh.channels  ch
WHERE
    -- join
    s.cust_id     = cu.cust_id
AND cu.country_id = co.country_id
AND s.prod_id     = p.prod_id
AND s.channel_id  = ch.channel_id
    -- filter
AND ch.channel_class = 'Direct'
AND co.country_iso_code = 'US'
AND p.prod_category = 'Electronics'
GROUP BY
    ch.channel_desc
  , co.country_iso_code
  , cu.cust_city
  , p.prod_category
/
/

@hash
-- manually tuned query
SELECT /*+ CARDINALITY(cu 55500) CARDINALITY(s 918000) */
    ch.channel_desc
  , co.country_iso_code co
  , cu.cust_city
  , p.prod_category
  , sum(s.quantity_sold)
  , sum(s.amount_sold)
FROM
    sh.sales     s
  , sh.customers cu
  , sh.countries co
  , sh.products  p
  , sh.channels  ch
WHERE
    -- join
    s.cust_id     = cu.cust_id
AND cu.country_id = co.country_id
AND s.prod_id     = p.prod_id
AND s.channel_id  = ch.channel_id
    -- filter
AND ch.channel_class = 'Direct'
AND co.country_iso_code = 'US'
AND p.prod_category = 'Electronics'
GROUP BY
    ch.channel_desc
  , co.country_iso_code
  , cu.cust_city
  , p.prod_category
/
/

@hash



-- orig:  2689079980 1ka5g0kh4h6pc 0
-- tuned: 3053916470 1fzf3vqv0f49q 0

-- workaround bug: Bug 5454975 : ORA-3113 WHEN EXECUTING DBMS_OUTLN.CREATE_OUTLINE 
ALTER SESSION SET create_stored_outlines = TRUE;
-- make sure you use right SQL hash values and child cursor numbers here!
EXEC DBMS_OUTLN.CREATE_OUTLINE(2689079980, 0, 'TEMP_SWAP_OUTLINE_BAD');
EXEC DBMS_OUTLN.CREATE_OUTLINE(3053916470, 0, 'TEMP_SWAP_OUTLINE_GOOD');
ALTER SESSION SET create_stored_outlines = FALSE;

COL outline_name_bad NEW_VALUE outline_name_bad
COL outline_name_good NEW_VALUE outline_name_good

-- get outline names
SELECT category,name outline_name_bad,owner,signature,enabled,timestamp,version FROM dba_outlines WHERE category = 'TEMP_SWAP_OUTLINE_BAD';
SELECT category,name outline_name_good,owner,signature,enabled,timestamp,version FROM dba_outlines WHERE category = 'TEMP_SWAP_OUTLINE_GOOD';

-- change the outlines to the same category for modification
ALTER OUTLINE &outline_name_bad  CHANGE CATEGORY TO temp_swap_outline;
ALTER OUTLINE &outline_name_good CHANGE CATEGORY TO temp_swap_outline;

CREATE PRIVATE OUTLINE bad  FROM &outline_name_bad; 
CREATE PRIVATE OUTLINE good FROM &outline_name_good; 

-- these ol$ and ol$hints tables are actually just GTTs (private to your session - private outlines)
-- do NOT modify the real ol$ and ol$hints tables in OUTLN schema directly!!!
SAVEPOINT before_ol_update;
UPDATE ol$ SET hintcount=(SELECT hintcount FROM ol$ WHERE ol_name='GOOD') where ol_name='BAD';
DELETE FROM ol$      WHERE ol_name='GOOD';
DELETE FROM ol$hints WHERE ol_name='BAD';
UPDATE ol$hints SET ol_name='BAD' where ol_name='GOOD';

COMMIT;

-- this just invalidate outline 
EXEC DBMS_OUTLN_EDIT.REFRESH_PRIVATE_OUTLINE('BAD');

ALTER SESSION SET use_private_outlines = TRUE;
-- run the original query again now - it should show "outline "BAD" used for this statement
-- ...
ALTER SESSION SET use_private_outlines = FALSE;

-- now publish the outline for use by others:
CREATE OR REPLACE OUTLINE &outline_name_bad FROM PRIVATE bad FOR CATEGORY temp_swap_outline;
ALTER SESSION SET use_stored_outlines = temp_swap_outline;
-- run the query again, it should show the original production outline used, but with the new plan ...

-- change the outline to DEFAULT category so that any session with use_stored_outlines = TRUE would use it
ALTER OUTLINE &outline_name_bad CHANGE CATEGORY TO "DEFAULT";
ALTER SESSION SET use_stored_outlines = TRUE;
-- optional...
ALTER OUTLINE &outline_name_bad RENAME TO outline_1ka5g0kh4h6pc;

SELECT
    ch.channel_desc
  , co.country_iso_code co
  , cu.cust_city
  , p.prod_category
  , sum(s.quantity_sold)
  , sum(s.amount_sold)
FROM
    sh.sales     s
  , sh.customers cu
  , sh.countries co
  , sh.products  p
  , sh.channels  ch
WHERE
    -- join
    s.cust_id     = cu.cust_id
AND cu.country_id = co.country_id
AND s.prod_id     = p.prod_id
AND s.channel_id  = ch.channel_id
    -- filter
AND ch.channel_class = 'Direct'
AND co.country_iso_code = 'US'
AND p.prod_category = 'Electronics'
GROUP BY
    ch.channel_desc
  , co.country_iso_code
  , cu.cust_city
  , p.prod_category
/
@x


