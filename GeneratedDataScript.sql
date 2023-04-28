DO $$
DECLARE
  i integer := 1;
BEGIN
  FOR i IN 1..10 LOOP
  
    INSERT INTO college_schema.person (id, first_name, last_name, phone, email)
    VALUES (i, 'Dummy', 'Person', '555-0'|| i ||'0'|| i ||'0', 'dummy' || i || '@email.com');
	
	INSERT INTO college_schema.faculty (id,faculty_name, description)
	VALUES (i, 'Social Science'|| i ||'0', 'Faculty of All Social Sciences');
	
	INSERT INTO college_schema.address (id,street, city, state, person_id)
    VALUES (i, '123 Main St', 'Anytown', 'CA', i);

	INSERT INTO college_schema.department (id, dept_name, description, faculty_id)
	VALUES (i, 'Computer Science'|| i, 'Department of Computer Science', i);
	INSERT INTO college_schema.student (id, first_name, last_name, phone, email,  dob, admitted_year, person_id)
    VALUES (i, 'Dummy', 'Student' || i ||'B', '555-0'|| i ||'0'|| i ||'5', 'dummy' || i || '@email.com', '2000-01-01', '2021-09-01', i);

	INSERT INTO college_schema.lecturer (id, first_name, last_name, phone, email, salary, department_id, person_id)
	VALUES (i, 'John', 'Doe', '555-0'|| i ||'0'|| i ||'2', 'johndoe' || i || '@email.com', 50000.00, i, i);

    INSERT INTO college_schema.course (id, course_title, duration, credit_unit, description, dept_id)
    VALUES (i, 'Introduction to Computer Science'|| i ||'A', '3 months', '3', 'Introduction to Computer Science course', i);

    INSERT INTO college_schema.student_course (student_id, course_id)
    VALUES (i, i);

    INSERT INTO college_schema.lecturer_course (lecturer_id, course_id)
    VALUES (i, i);
  END LOOP;
END $$;
