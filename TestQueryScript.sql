
SELECT * FROM college_schema.lecturer
JOIN college_schema.lecturer_course ON college_schema.lecturer.id = college_schema.lecturer_course.lecturer_id
JOIN college_schema.course ON college_schema.course.id = college_schema.lecturer_course.course_id
WHERE college_schema.lecturer.id = 1;

SELECT full_name, phone, email, salary, course_title, duration, credit_unit  FROM college_schema.lecturer
JOIN college_schema.lecturer_course ON college_schema.lecturer.id = college_schema.lecturer_course.lecturer_id
JOIN college_schema.course ON college_schema.course.id = college_schema.lecturer_course.course_id
WHERE college_schema.lecturer.id = 1;