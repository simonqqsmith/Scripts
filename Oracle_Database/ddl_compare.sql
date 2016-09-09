---------------------------------------------------------
-- ddl_compare.sql
--
-- Author: Simon Smith
--
-- Purpose: Compares the DDL of two schema
--
-- Usage: Replace TEST1 and TEST2 in the final query with the schemas to be compared and run @ddl_compare.sql
--
---------------------------------------------------------
CREATE TYPE tableddl_ty AS OBJECT (
table_name  VARCHAR2(30),
orig_schema VARCHAR2(30),
orig_ddl    CLOB,
comp_schema VARCHAR2(30),
comp_ddl    CLOB);
/

CREATE TYPE tableddl_ty_tb AS TABLE OF tableddl_ty;
/
CREATE OR REPLACE FUNCTION tableddl_fc (input_values SYS_REFCURSOR)
RETURN tableddl_ty_tb PIPELINED IS

PRAGMA AUTONOMOUS_TRANSACTION;

-- variables to be passed in by sys_refcursor */
table_name  VARCHAR2(30);
orig_schema VARCHAR2(30);
comp_schema VARCHAR2(30);

-- setup output record of TYPE tableddl_ty
out_rec tableddl_ty := tableddl_ty(NULL,NULL,NULL,NULL,NULL);

/* setup handles to be used for setup and fetching metadata information handles are used
to keep track of the different objects (DDL) we will be referencing in the PL/SQL code */
hOpenOrig0  NUMBER;
hOpenOrig   NUMBER;
hOpenComp   NUMBER;
hModifyOrig NUMBER;
hTransDDL   NUMBER;
dmsf        PLS_INTEGER;

/*
CLOBs to hold DDL
Orig_ddl0 will hold the baseline DDL for the object to be compared
Orig_ddl1 will also hold the baseline DDL for the object to be compared against
but will also go through some translations before being compared
against Comp_ddl2
Comp_ddl2 will contain the DDL to be compared against the baseline
*/
Orig_ddl0  CLOB;
Orig_ddl1  CLOB;
Comp_ddl2  CLOB;

ret        NUMBER;
BEGIN
  /* Strip off Attributes not concerned with in DDL. If you are concerned with
     TABLESPACE, STORAGE, or SEGMENT information just comment out these few lines. */
  dmsf := dbms_metadata.session_transform;
  dbms_metadata.set_transform_param(dmsf, 'TABLESPACE', FALSE);
  dbms_metadata.set_transform_param(dmsf, 'STORAGE', FALSE);
  dbms_metadata.set_transform_param(dmsf, 'SEGMENT_ATTRIBUTES', FALSE);

  -- Loop through each of the rows passed in by the reference cursor
  LOOP
    /* Fetch the input cursor into PL/SQL variables */
    FETCH input_values INTO table_name, orig_schema, comp_schema;
    EXIT WHEN input_values%NOTFOUND;

    /* Here is the first use of our handles for pointing to the original table DDL
       It names the object_type (TABLE), provides the name of the object (our PL/SQL
       variable table_name), and states the schema it is from */
    hOpenOrig0 := dbms_metadata.open('TABLE');
    dbms_metadata.set_filter(hOpenOrig0,'NAME',table_name);
    dbms_metadata.set_filter(hOpenOrig0,'SCHEMA',orig_schema);

    /* Setup handle again for the original table DDL that will undergo transformation
       We setup two handles for the original object DDL because we want to be able to
       Manipulate one set for comparison but output the original DDL to the user */
    hOpenOrig := dbms_metadata.open('TABLE');
    dbms_metadata.set_filter(hOpenOrig,'NAME',table_name);
    dbms_metadata.set_filter(hOpenOrig,'SCHEMA',orig_schema);

    -- Setup handle for table to compare original against
    hOpenComp := dbms_metadata.open('TABLE');
    dbms_metadata.set_filter(hOpenComp,'NAME',table_name);
    dbms_metadata.set_filter(hOpenComp,'SCHEMA',comp_schema);

    /* Modify the transformation of "orig_schema" to take on ownership of "comp_schema"
       If we didn't do this, when we compared the original to the comp objects there
       would always be a difference because the schema_owner is in the DDL generated */
    hModifyOrig := dbms_metadata.add_transform(hOpenOrig,'MODIFY');
    dbms_metadata.set_remap_param(hModifyOrig,'REMAP_SCHEMA',orig_schema,comp_schema);

    -- This states to created DDL instead of XML to be compared
    hTransDDL := dbms_metadata.add_transform(hOpenOrig0,'DDL');
    hTransDDL := dbms_metadata.add_transform(hOpenOrig ,'DDL');
    hTransDDL := dbms_metadata.add_transform(hOpenComp ,'DDL');

    -- Get the DDD and store into the CLOB PL/SQL variables
    Orig_ddl0 := dbms_metadata.fetch_clob(hOpenOrig0);
    Orig_ddl1 := dbms_metadata.fetch_clob(hOpenOrig);

    /* Here we are providing for those instances where the baseline object does not
       exist in the Comp_schema. */
    BEGIN
      Comp_ddl2 := dbms_metadata.fetch_clob(hOpenComp);
    EXCEPTION
      WHEN OTHERS THEN
        comp_ddl2 := 'DOES NOT EXIST';
    END;

    -- Now simply compare the two DDL statements and output row if not equal
    ret := dbms_lob.compare(Orig_ddl1, Comp_ddl2);
    IF ret != 0 THEN
      out_rec.table_name := table_name;
      out_rec.orig_schema := orig_schema;
      out_rec.orig_ddl := Orig_ddl0;
      out_rec.comp_schema := comp_schema;
      out_rec.comp_ddl := Comp_ddl2;
      PIPE ROW(out_rec);
    END IF;

    -- Cleanup and release the handles
    dbms_metadata.close(hOpenOrig0);
    dbms_metadata.close(hOpenOrig);
    dbms_metadata.close(hOpenComp);
  END LOOP;
  RETURN;
END TABLEDDL_FC;
/

/* Set schema names and compare. In this case TEST2 is compared with TEST1 */

SELECT *
FROM TABLE(tableddl_fc(CURSOR(SELECT table_name, owner, 'TEST2'
FROM dba_tables where owner = 'TEST1')));

