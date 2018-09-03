
# Reference Resolver

## Oracle SQL, PL/SQL solution to resolve Table References

### Why? ###

Because for example if you use the Single Record Viewer, you can see a lot of foreign key values and these are not too readable.
It would be better if we can see the referenced data as well.

Here is a way to do this.


### How? ###

First of all we need LOVs for every referenced table. If we already have LOV (from APEX or) views, we can use them such as (example):

    CREATE OR REPLACE VIEW LOVS_VW as
        select 'TABLE1' as TABLE_NAME, NAME as TEXT, to_char(ID) as ROW_KEY from TABLE1_LOV_VW union all
        select 'TABLE2', NAME, to_char(ID) from TABLE2_LOV_VW union all
        select 'TABLE3', NAME, CODE from TABLE3_LOV_VW 
        ...

if we do not have yet, then we have to make one (example):

    CREATE OR REPLACE VIEW LOVS_VW as
        select 'CUSTOMERS' as TABLE_NAME, NAME||' ( '||CRM_ID||' )' as TEXT, to_char(ID) as ROW_KEY from CUSTOMERS union all
        select 'PERSONS', FISRT_NAME||' '||LAST_NAME, to_char(ID) from PERSONS union all
        select 'FILE_STATUSES', STATUS_NAME, CODE from FILE_STATUSES 
        ...


After this, we can resolve any referenced table data row.

    select TEXT from LOVS_VW where TABLE_NAME = 'PERSONS' and ROW_KEY = 666;

If we want to use this in the Single Record View, we have to add a new column and we need a new function F_GET_REFERENCED_TABLE_NAME:

    select COLUMN_NAME
         , COL_VALUE
         , ( select TEXT from LOVS_VW where TABLE_NAME = F_GET_REFERENCED_TABLE_NAME ( 'PERSONS', COLUMN_NAME) and ROW_KEY = COL_VALUE and COL_VALUE is not null ) as RESOLVED
      from table( F_GET_SINGLE_RECORD_VIEW( 'PERSONS', 666 ) )

This enclosed F_GET_REFERENCED_TABLE_NAME function returns with the Referenced Table Name by the column of the source table.
