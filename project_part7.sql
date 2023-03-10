---- Connecting sys as sysdba
connect sys/sys as sysdba;

-- Setting the spool file
SPOOL C:\BD2\project_part7_spool.txt

-- Showing the actual time when the script was run
SELECT to_char(sysdate,'DD Month YYYY Day HH:MI"SS') FROM dual;

-- QUESTION 1

-- Connecting to the schema

DROP USER des03 CASCADE;

@C:\BD1\7Northwoods.sql

SET SERVEROUTPUT ON

-- Declaring a procedure

CREATE OR REPLACE PROCEDURE p7q1 AS

	-- First step
	CURSOR faculty_cursor IS
	SELECT f_id, f_last, f_first, f_rank
	FROM faculty;

	CURSOR student_cursor (par_fid student.f_id%TYPE) IS
	SELECT UNIQUE s_id, s_last, s_first, s_dob, s_class
	FROM student
	WHERE f_id = par_fid;

	BEGIN
	

	-- Starting the first loop
	FOR faculty IN faculty_cursor LOOP
		DBMS_OUTPUT.PUT_LINE('*****************************************************************************');
		DBMS_OUTPUT.PUT_LINE('ID: ' || faculty.f_id || '. Last Name: ' || faculty.f_last || '. First Name: ' || faculty.f_first || '. Rank: ' || faculty.f_rank || '.');
		DBMS_OUTPUT.PUT_LINE('*****************************************************************************');

			FOR student IN student_cursor(faculty.f_id) LOOP
				DBMS_OUTPUT.PUT_LINE('- ID: ' || student.s_id || '. Last Name: ' || student.s_last || '. First Name: ' || student.s_first || '.' );
				DBMS_OUTPUT.PUT_LINE('- Date of birth: ' || student.s_dob || '. Class: ' || student.s_class || '.');
			END LOOP;
	END LOOP;

	END;
/

EXEC p7q1;


-- Preparing the schema

connect sys/sys as sysdba;

DROP USER des04 CASCADE;
 
@C:\BD1\7Software.sql

SET SERVEROUTPUT ON

-- Declaring a procedure

CREATE OR REPLACE PROCEDURE p7q2 AS

	CURSOR cons_cursor IS
	SELECT c_id, c_last, c_first
	FROM consultant;

	v_consultant_row cons_cursor%ROWTYPE;

	CURSOR skill_cursor (pc_c_id consultant.c_id%TYPE) IS
	SELECT skill_description, certification
	FROM consultant_skill cs, skill s
	WHERE c_id = pc_c_id AND cs.skill_id = s.skill_id;

	v_skill_cursor skill_cursor%ROWTYPE;

	BEGIN

-- Step 2: Opening the cursor

		OPEN cons_cursor;

-- Step 3: Fetch the cursor

		FETCH cons_cursor INTO v_consultant_row;

		WHILE cons_cursor%FOUND LOOP
			DBMS_OUTPUT.PUT_LINE('******************************************************************************');
			DBMS_OUTPUT.PUT_LINE('Consultant ID: ' || v_consultant_row.c_id || '.');
			DBMS_OUTPUT.PUT_LINE('Consultant First Name: ' || v_consultant_row.c_last || '. Consultant Last Name: ' || v_consultant_row.c_last || '.');
			DBMS_OUTPUT.PUT_LINE('******************************************************************************');

			-- Inner cursor

			OPEN skill_cursor (v_consultant_row.c_id);

			FETCH skill_cursor INTO v_skill_cursor;

			WHILE skill_cursor%FOUND LOOP

				DBMS_OUTPUT.PUT_LINE('Certification: ' || v_skill_cursor.certification || '. Description: ' || v_skill_cursor.skill_description || '.');

			FETCH skill_cursor INTO v_skill_cursor;

			END LOOP;

			CLOSE skill_cursor;
	
		FETCH cons_cursor INTO v_consultant_row;

		END LOOP;

-- Step 4: Close the cursor

		CLOSE cons_cursor;

	END;

/

EXEC p7q2;


-- QUESTION 3

-- Preparing the schema

connect sys/sys as sysdba;

DROP USER des02 CASCADE;

@C:\BD1\7clearwater.sql

SET SERVEROUTPUT ON

-- Declaring the procedure 

CREATE OR REPLACE PROCEDURE p7q3 AS

	BEGIN
		FOR item IN (SELECT UNIQUE iv.item_id, item_desc, cat_id FROM inventory iv, item it WHERE iv.item_id = it.item_id) LOOP

			DBMS_OUTPUT.PUT_LINE('***********************************************************************');
			DBMS_OUTPUT.PUT_LINE('Item ID: ' || item.item_id || '. Item Description: ' || item.item_desc || '. Category ID: ' || item.cat_id || '.');
			DBMS_OUTPUT.PUT_LINE('***********************************************************************');

			FOR inventory IN (SELECT color, inv_size, inv_price, inv_qoh FROM inventory WHERE item.item_id = inventory.item_id) LOOP

				DBMS_OUTPUT.PUT_LINE('Color: ' || inventory.color || '. Size: ' || inventory.inv_size || '. Price: $' || inventory.inv_price || '. Quantity on hand: ' || inventory.inv_qoh || '.');

			END LOOP;

		END LOOP;
	
	END;

/

EXEC p7q3;


-- QUESTION 4

-- Declaring the procedure 

CREATE OR REPLACE PROCEDURE p7q4 AS

-- Declaring the cursor

	v_value NUMBER;
	v_temp NUMBER;

	BEGIN

		FOR item IN (SELECT UNIQUE iv.item_id, item_desc, cat_id FROM inventory iv, item it WHERE iv.item_id = it.item_id) LOOP

			v_temp := 0;

			FOR inventory IN (SELECT color, inv_size, inv_price, inv_qoh FROM inventory WHERE item.item_id = inventory.item_id) LOOP

				v_value := inventory.inv_price * inventory.inv_qoh;
				v_temp := v_temp + v_value;

			END LOOP;

			DBMS_OUTPUT.PUT_LINE('***********************************************************************');
			DBMS_OUTPUT.PUT_LINE('Item ID: ' || item.item_id || '. Item Description: ' || item.item_desc || '.');
			DBMS_OUTPUT.PUT_LINE('Item Value: $' || v_temp || '.');
			DBMS_OUTPUT.PUT_LINE('Category ID: ' || item.cat_id || '.');
			DBMS_OUTPUT.PUT_LINE('***********************************************************************');

			FOR inventory IN (SELECT color, inv_size, inv_price, inv_qoh FROM inventory WHERE item.item_id = inventory.item_id) LOOP

				v_value := inventory.inv_price * inventory.inv_qoh;

				DBMS_OUTPUT.PUT_LINE('Color: ' || inventory.color || '. Size: ' || inventory.inv_size || '. Price: $' || inventory.inv_price || '. Quantity on hand: ' || inventory.inv_qoh || '.');

			END LOOP;

		END LOOP;
	
	END;
/

EXEC p7q4;

SPOOL OFF;
