create or replace function sp.agg_concat (input varchar2) return varchar2
    parallel_enable aggregate using sp.concat_agg_t;
/
