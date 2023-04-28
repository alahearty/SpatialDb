--create database college
--create database college_db;
-- Create Schema
CREATE SCHEMA college_schema;
Drop table if exists college_schema.person cascade;
Drop table if exists college_schema.address cascade;
Drop table if exists college_schema.faculty cascade;
Drop table if exists college_schema.department cascade;
Drop table if exists college_schema.lecturer cascade;
Drop table if exists college_schema.student cascade;
Drop table if exists college_schema.course cascade;
Drop table if exists college_schema.student_course cascade;
Drop table if exists college_schema.lecturer_course cascade;
DROP VIEW if exists college_schema.lecturer_details cascade;
DROP VIEW if exists college_schema.course_summary cascade;

-- Create the 'person' table with the common attributes
CREATE TABLE college_schema.person (
    id integer not null PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    phone VARCHAR(40) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE
);

CREATE INDEX idx_phone_email ON college_schema.person (phone,email);

-- Create the 'address' table as a child of 'person'
CREATE TABLE college_schema.address (
    id integer not null PRIMARY KEY,
    street VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    person_id INTEGER NOT NULL,
    CONSTRAINT fk_address_person_id FOREIGN KEY (person_id) REFERENCES college_schema.person(id) ON DELETE CASCADE
);

-- Create the 'faculty' table
CREATE TABLE college_schema.faculty (
    id integer not null PRIMARY KEY,
    faculty_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- Create the 'department' table
CREATE TABLE college_schema.department (
    id integer not null PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    faculty_id INTEGER REFERENCES college_schema.faculty(id)
);

-- Create the 'lecturer' table as a child of 'person'
CREATE TABLE college_schema.lecturer (
   id integer not null PRIMARY KEY,
   salary NUMERIC(10,2),
   department_id INTEGER REFERENCES college_schema.department(id),
   person_id INTEGER NOT NULL,
CONSTRAINT fk_lecturer_person_id FOREIGN KEY (id) REFERENCES college_schema.person(id) ON DELETE CASCADE
) INHERITS (college_schema.person);

-- Create the 'student' table as a child of 'person'
CREATE TABLE college_schema.student (
    id integer not null PRIMARY KEY,
    dob DATE NOT NULL,
    admitted_year DATE NOT NULL,
	person_id INTEGER NOT NULL,
	CONSTRAINT fk_student_person_id FOREIGN KEY (id) REFERENCES college_schema.person(id) ON DELETE CASCADE
) INHERITS (college_schema.person);


-- Create the 'course' table
CREATE TABLE college_schema.course (
    id integer not null PRIMARY KEY,
    course_title VARCHAR(50),
    duration INTERVAL NOT NULL,
    credit_unit VARCHAR(50) NOT NULL,
    description TEXT,
    dept_id INTEGER REFERENCES college_schema.department(id) ON DELETE CASCADE
);

CREATE INDEX idx_admitted_year ON college_schema.student (admitted_year);

-- Create the 'student_course' table
CREATE TABLE college_schema.student_course (
    student_id INTEGER REFERENCES college_schema.student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES college_schema.course(id) ON DELETE CASCADE,
    PRIMARY KEY(student_id, course_id)
);

-- Create the 'lecturer_course' table
CREATE TABLE college_schema.lecturer_course (
    lecturer_id INTEGER REFERENCES college_schema.lecturer(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES college_schema.course(id) ON DELETE CASCADE,
    PRIMARY KEY(lecturer_id, course_id)
);



CREATE OR REPLACE FUNCTION college_schema.insert_student(p_first_name VARCHAR(50), p_last_name VARCHAR(50), p_phone VARCHAR(40), p_email VARCHAR(50), p_dob DATE, p_admitted_year DATE, p_dept_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_person_id INTEGER;
    v_student_id INTEGER;
BEGIN
    -- Insert into person table
    INSERT INTO college_schema.person(first_name, last_name, phone, email)
    VALUES (p_first_name, p_last_name, p_phone, p_email)
    RETURNING id INTO v_person_id;
    
    -- Insert into student table
    INSERT INTO college_schema.student(id, dob, admitted_year, person_id)
    VALUES (v_person_id, p_dob, p_admitted_year, v_person_id)
    RETURNING id INTO v_student_id;
    
    -- Insert into department table
    UPDATE college_schema.department
    SET faculty_id = (SELECT faculty_id FROM college_schema.department WHERE id = p_dept_id)
    WHERE id = p_dept_id;
    
    -- Insert into lecturer_course table
    INSERT INTO college_schema.student_course(student_id, course_id)
    SELECT v_student_id, id FROM college_schema.course WHERE dept_id = p_dept_id;
END;
$$ LANGUAGE plpgsql;

--Here is Example of How You use Views 
CREATE VIEW college_schema.student_details AS
SELECT p.full_name, p.phone, p.email, s.dob, s.admitted_year, d.dept_name, c.course_title
FROM college_schema.student s
JOIN college_schema.person p ON s.id = p.id
JOIN college_schema.department d ON s.id = d.id
JOIN college_schema.student_course sc ON s.id = sc.student_id
JOIN college_schema.course c ON sc.course_id = c.id;

CREATE VIEW college_schema.lecturer_details AS
SELECT p.full_name, p.phone, p.email, l.salary, d.dept_name, c.course_title
FROM college_schema.lecturer l
JOIN college_schema.person p ON l.person_id = p.id
JOIN college_schema.department d ON l.department_id = d.id
JOIN college_schema.lecturer_course lc ON l.id = lc.lecturer_id
JOIN college_schema.course c ON lc.course_id = c.id;

--MATERIALIZED VIEW 
CREATE MATERIALIZED VIEW college_schema.course_summary AS
SELECT d.dept_name, c.course_title, COUNT(DISTINCT sc.student_id) AS num_students
FROM college_schema.course c
JOIN college_schema.department d ON c.dept_id = d.id
JOIN college_schema.student_course sc ON c.id = sc.course_id
GROUP BY d.dept_name, c.course_title;


CREATE OR REPLACE PROCEDURE college_schema.proc_insert_student(
	id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(40),
    email VARCHAR(50),
    dob DATE,
    admitted_year DATE
) 
AS $$
DECLARE
    person_id INTEGER;
BEGIN
    INSERT INTO college_schema.person (id, first_name, last_name, phone, email)
    VALUES (first_name, last_name, phone, email)
    RETURNING id INTO person_id;
    INSERT INTO college_schema.student (id, dob, admitted_year)
    VALUES (person_id, dob, admitted_year);
END;
$$ LANGUAGE plpgsql;