INSERT INTO departments (department_code, department_name, description, established_date, office_location)
SELECT
  'DEPT' || LPAD(id::TEXT, 3, '0'),
  'Department of ' ||
  (ARRAY['Computer Science', 'Mathematics', 'Physics', 'Biology', 'Chemistry'])[(id % 5) + 1],
  'Study of ' ||
  (ARRAY['computers', 'numbers', 'physics', 'life', 'chemicals'])[(id % 5) + 1],
  '2000-01-01'::DATE + (id * 30 || ' days')::INTERVAL,
  'Building ' || CHR(65 + ((id - 1) % 26)) || ', Room ' || LPAD(id::TEXT, 3, '0')
FROM generate_series(1, 50) id
ON CONFLICT (department_code) DO NOTHING;

INSERT INTO users (username, email, password_hash, role, profile_image)
SELECT
  'user' || LPAD(id::TEXT, 6, '0'),
  CASE
    WHEN id <= 100 THEN 'admin' || id::TEXT || '@university.edu'
    WHEN id <= 1000 THEN 'faculty' || id::TEXT || '@university.edu'
    ELSE 'student' || id::TEXT || '@student.university.edu'
  END,
  '$2a$10$jdqfPO0BPkW20qPEvFx.ue1iI8bjehbexVQTFHZSzxaYEINyiMKqS',
  CASE
    WHEN id <= 100 THEN 'admin'::user_role
    WHEN id <= 1000 THEN 'faculty'::user_role
    ELSE 'student'::user_role
  END,
  'https://ui-avatars.com/api/?name=User' || id
FROM generate_series(1, 10000) id
ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, first_name, last_name, date_of_birth, gender, phone_number, address)
SELECT
  u.user_id,
  CASE
    WHEN u.role = 'admin' THEN 'Admin' || (u.user_id % 10)
    WHEN u.role = 'faculty' THEN 'Professor' || (u.user_id % 50)
    ELSE 'Student' || (u.user_id % 100)
  END,
  CASE
    WHEN u.role = 'admin' THEN 'User' || u.user_id
    WHEN u.role = 'faculty' THEN 'Faculty' || u.user_id
    ELSE 'Learner' || u.user_id
  END,
  CASE
    WHEN u.role = 'admin' THEN '1970-01-01'::DATE
    WHEN u.role = 'faculty' THEN '1980-01-01'::DATE
    ELSE '2000-01-01'::DATE
  END,
  CASE (u.user_id % 3)
    WHEN 0 THEN 'male'::gender_type
    WHEN 1 THEN 'female'::gender_type
    ELSE 'other'::gender_type
  END,
  '+1-555-' || LPAD((u.user_id % 900 + 100)::TEXT, 3, '0') || '-' || LPAD((u.user_id % 9000 + 1000)::TEXT, 4, '0'),
  'Address ' || u.user_id || ', Campus City'
FROM users u
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO faculty (profile_id, department_id, faculty_number, designation, hire_date, office_number)
SELECT
  up.profile_id,
  (SELECT department_id FROM departments LIMIT 1 OFFSET (up.profile_id % 50)),
  'FAC' || LPAD((2000 + (up.profile_id % 24))::TEXT, 4, '0') || LPAD(up.profile_id::TEXT, 4, '0'),
  CASE (up.profile_id % 5)
    WHEN 0 THEN 'Professor'
    WHEN 1 THEN 'Associate Professor'
    WHEN 2 THEN 'Assistant Professor'
    WHEN 3 THEN 'Lecturer'
    ELSE 'Adjunct Professor'
  END,
  '2000-01-01'::DATE + ((up.profile_id * 30) || ' days')::INTERVAL,
  'OFF' || LPAD((up.profile_id % 500 + 100)::TEXT, 3, '0')
FROM user_profiles up
JOIN users u ON up.user_id = u.user_id
WHERE u.role = 'faculty'
ORDER BY up.profile_id
LIMIT 900
ON CONFLICT (faculty_number) DO NOTHING;

INSERT INTO students (profile_id, department_id, student_number, enrollment_year, gpa, cgpa)
SELECT
  up.profile_id,
  (SELECT department_id FROM departments LIMIT 1 OFFSET (up.profile_id % 50)),
  'STU' ||
  CASE (up.profile_id % 5)
    WHEN 0 THEN '2020'
    WHEN 1 THEN '2021'
    WHEN 2 THEN '2022'
    WHEN 3 THEN '2023'
    ELSE '2024'
  END ||
  LPAD((up.profile_id - 1000)::TEXT, 4, '0'),
  CASE (up.profile_id % 5)
    WHEN 0 THEN 2020
    WHEN 1 THEN 2021
    WHEN 2 THEN 2022
    WHEN 3 THEN 2023
    ELSE 2024
  END,
  ROUND((2.5 + (random() * 1.5))::NUMERIC, 2),
  ROUND((2.6 + (random() * 1.5))::NUMERIC, 2)
FROM user_profiles up
JOIN users u ON up.user_id = u.user_id
WHERE u.role = 'student'
ORDER BY up.profile_id
LIMIT 9000
ON CONFLICT (student_number) DO NOTHING;

INSERT INTO administrators (profile_id, admin_number, position, hire_date, is_super_admin)
SELECT
  up.profile_id,
  'ADMIN' || LPAD(up.profile_id::TEXT, 4, '0'),
  CASE (up.profile_id % 8)
    WHEN 0 THEN 'System Administrator'
    WHEN 1 THEN 'Registrar'
    WHEN 2 THEN 'Academic Dean'
    WHEN 3 THEN 'Department Chair'
    WHEN 4 THEN 'Finance Director'
    WHEN 5 THEN 'HR Manager'
    WHEN 6 THEN 'IT Director'
    ELSE 'Operations Manager'
  END,
  '2015-01-01'::DATE + ((up.profile_id * 60) || ' days')::INTERVAL,
  (up.profile_id <= 10)
FROM user_profiles up
JOIN users u ON up.user_id = u.user_id
WHERE u.role = 'admin'
ORDER BY up.profile_id
ON CONFLICT (admin_number) DO NOTHING;

WITH course_numbers AS (
  SELECT generate_series(1, 500) as course_num
)
INSERT INTO courses (course_code, course_name, description, department_id, credits, course_level)
SELECT
  'CS' || LPAD(course_num::TEXT, 3, '0'),
  'Course ' || course_num,
  'Description for course ' || course_num,
  (SELECT department_id FROM departments ORDER BY department_id LIMIT 1 OFFSET ((course_num - 1) % 50)),
  CASE (course_num % 4)
    WHEN 0 THEN 1
    WHEN 1 THEN 2
    WHEN 2 THEN 3
    ELSE 4
  END,
  CASE (course_num % 3)
    WHEN 0 THEN 'Undergraduate'
    WHEN 1 THEN 'Graduate'
    ELSE 'PhD'
  END
FROM course_numbers
ON CONFLICT (course_code) DO NOTHING;

WITH section_numbers AS (
  SELECT generate_series(1, 2000) as sec_num
)
INSERT INTO sections (course_id, section_code, faculty_id, semester, academic_year, classroom, schedule, start_date, end_date)
SELECT
  (SELECT course_id FROM courses ORDER BY course_id LIMIT 1 OFFSET ((sec_num - 1) % 500)),
  CHR(65 + ((sec_num - 1) % 5)),
  (SELECT faculty_id FROM faculty ORDER BY faculty_id LIMIT 1 OFFSET ((sec_num - 1) % 900)),
  CASE (sec_num % 3)
    WHEN 0 THEN 'fall'::semester_type
    WHEN 1 THEN 'spring'::semester_type
    ELSE 'summer'::semester_type
  END,
  CASE (sec_num % 5)
    WHEN 0 THEN 2020
    WHEN 1 THEN 2021
    WHEN 2 THEN 2022
    WHEN 3 THEN 2023
    ELSE 2024
  END,
  'ROOM' || LPAD(((sec_num - 1) % 500 + 100)::TEXT, 3, '0'),
  '{"days": ["Mon", "Wed", "Fri"], "time": "09:00-10:30"}'::JSONB,
  CASE (sec_num % 3)
    WHEN 0 THEN '2024-09-01'::DATE
    WHEN 1 THEN '2024-01-15'::DATE
    ELSE '2024-06-01'::DATE
  END,
  CASE (sec_num % 3)
    WHEN 0 THEN '2024-12-15'::DATE
    WHEN 1 THEN '2024-05-15'::DATE
    ELSE '2024-08-15'::DATE
  END
FROM section_numbers
ON CONFLICT (course_id, section_code, academic_year, semester) DO NOTHING;

INSERT INTO enrollments (student_id, section_id, enrollment_status)
SELECT
  s.student_id,
  sec.section_id,
  'enrolled'::enrollment_status_type
FROM students s
CROSS JOIN sections sec
WHERE (s.student_id * 17 + sec.section_id * 13) % 100 < 5
  AND NOT EXISTS (
    SELECT 1 FROM enrollments e
    WHERE e.student_id = s.student_id
      AND e.section_id = sec.section_id
  )
ORDER BY random()
LIMIT 50000
ON CONFLICT (student_id, section_id) DO NOTHING;

INSERT INTO grades (enrollment_id, grade, grade_points, created_at)
SELECT
  e.enrollment_id,
  CASE ((e.enrollment_id * 17) % 12)
    WHEN 0 THEN 'A+' WHEN 1 THEN 'A' WHEN 2 THEN 'A-' WHEN 3 THEN 'B+' WHEN 4 THEN 'B' WHEN 5 THEN 'B-' WHEN 6 THEN 'C+' WHEN 7 THEN 'C' WHEN 8 THEN 'C-' WHEN 9 THEN 'D+' WHEN 10 THEN 'D' ELSE 'F'
  END,
  CASE ((e.enrollment_id * 17) % 12)
    WHEN 0 THEN 4.3 WHEN 1 THEN 4.0 WHEN 2 THEN 3.7 WHEN 3 THEN 3.3 WHEN 4 THEN 3.0 WHEN 5 THEN 2.7 WHEN 6 THEN 2.3 WHEN 7 THEN 2.0 WHEN 8 THEN 1.7 WHEN 9 THEN 1.3 WHEN 10 THEN 1.0 ELSE 0.0
  END,
  CURRENT_TIMESTAMP
FROM enrollments e
WHERE e.enrollment_status = 'enrolled'::enrollment_status_type
  AND NOT EXISTS (SELECT 1 FROM grades g WHERE g.enrollment_id = e.enrollment_id)
ORDER BY random()
LIMIT 35000
ON CONFLICT (enrollment_id) DO NOTHING;

SELECT
  table_name,
  COUNT(*) as record_count
FROM (
  SELECT 'departments' as table_name FROM departments
  UNION ALL SELECT 'users' FROM users
  UNION ALL SELECT 'user_profiles' FROM user_profiles
  UNION ALL SELECT 'students' FROM students
  UNION ALL SELECT 'faculty' FROM faculty
  UNION ALL SELECT 'administrators' FROM administrators
  UNION ALL SELECT 'courses' FROM courses
  UNION ALL SELECT 'sections' FROM sections
  UNION ALL SELECT 'enrollments' FROM enrollments
  UNION ALL SELECT 'grades' FROM grades
) tables
GROUP BY table_name
ORDER BY record_count DESC;
