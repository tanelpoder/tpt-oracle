COL vault_name FOR A20 WRAP

SELECT
    vault_name
--  , create_time
  , ROUND(ef_space_used      / (1024*1024*1024)) ef_used_gb
  , ROUND(ef_space_prov      / (1024*1024*1024)) ef_prov_gb 
  , ef_iops_prov                                 ef_iops
  , ROUND(hc_space_used      / (1024*1024*1024)) hc_used_gb
  , ROUND(hc_space_prov      / (1024*1024*1024)) hc_prov_gb
  , hc_iops_prov
  , ROUND(xt_space_used      / (1024*1024*1024)) xt_used_gb
  , ROUND(xt_space_prov      / (1024*1024*1024)) xt_prov_gb
  , xt_iops_prov
  , ROUND(flash_cache_prov   / (1024*1024*1024)) fc_prov_gb
  , ROUND(xrmem_cache_prov   / (1024*1024*1024)) xm_prov_gb
--  , con_id
FROM
    v$exa_vault
ORDER BY
    vault_name
/

