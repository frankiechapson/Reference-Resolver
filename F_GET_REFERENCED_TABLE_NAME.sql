create or replace function F_GET_REFERENCED_TABLE_NAME ( I_SOURCE_TABLE_NAME  in varchar2
                                                       , I_SOURCE_COLUMN_NAME in varchar2
                                                       ) return varchar2 deterministic is

/* *******************************************************************************************************************

    This function returns with the Referenced Table Name by the column of the source table.
    
    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2018.01.16 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************************* */



    V_TABLE_NAME        varchar2(100);

begin
    -- has FK constraint?
    for L_R in ( select UC.TABLE_NAME
                      , DBC.COLUMN_NAME
                   from USER_CONSTRAINTS   UC
                      , USER_CONS_COLUMNS DBC
                  where UC.CONSTRAINT_TYPE  = 'P' 
                    and UC.STATUS           = 'ENABLED'               
                    and DBC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
                    and UC.CONSTRAINT_NAME in ( select UCB.R_CONSTRAINT_NAME
                                                  from USER_CONSTRAINTS   UCB
                                                     , USER_CONS_COLUMNS DBCB
                                                 where DBCB.CONSTRAINT_NAME = UCB.CONSTRAINT_NAME 
                                                   and UCB.TABLE_NAME       = upper( I_SOURCE_TABLE_NAME  )
                                                   and DBCB.COLUMN_NAME     = upper( I_SOURCE_COLUMN_NAME )
                                             )
                ) 
    loop
        V_TABLE_NAME := L_R.TABLE_NAME;
    end loop;

    if V_TABLE_NAME is null then
        -- try some other standard way...
        if substr( upper( I_SOURCE_COLUMN_NAME ), -3 ) = '_ID' then

            select min( TABLE_NAME )
              into V_TABLE_NAME
              from USER_TABLES
             where TABLE_NAME like substr( upper( I_SOURCE_COLUMN_NAME ), 1, length(I_SOURCE_COLUMN_NAME) - 3 )||'%';

        elsif substr( upper( I_SOURCE_COLUMN_NAME ), -5 ) = '_CODE' then

            select min( TABLE_NAME )
              into V_TABLE_NAME
              from USER_TABLES
             where TABLE_NAME like substr( upper( I_SOURCE_COLUMN_NAME ), 1, length(I_SOURCE_COLUMN_NAME) - 5 )||'%';

        end if;

    end if;

    return V_TABLE_NAME;

end;
/

                                  