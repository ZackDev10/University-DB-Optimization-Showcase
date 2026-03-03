-- Materialized views for complex, repetitive analytical queries.

-- 1. Department Enrollment Statistics
-- Aggregates total students, active courses, and average grades per department.
CREATE MATERIALIZED VIEW mv_department_stats AS
SELECT
    d.department_id,
    d.department_code,
    d.department_name,
    COUNT(DISTINCT s.student_id) AS total_enrolled_students,
    COUNT(DISTINCT c.course_id) AS total_active_courses,
    ROUND(AVG(g.grade_points), 2) AS average_department_gpa
FROM departments d
LEFT JOIN students s ON d.department_id = s.department_id
LEFT JOIN courses c ON d.department_id = c.department_id AND c.is_active = TRUE
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY d.department_id, d.department_code, d.department_name;


-- Create an index to speed up querying the materialized view itself
CREATE UNIQUE INDEX idx_mv_dept_stats_id ON mv_department_stats(department_id);


-- 2. Comprehensive Student Transcripts
-- Pre-joins student profiles, courses, enrollments, and grades for quick transcript generation.
CREATE MATERIALIZED VIEW mv_student_transcripts AS
SELECT
    st.student_id,
    st.student_number,
    up.first_name,
    up.last_name,
    c.course_code,
    c.course_name,
    c.credits,
    sec.academic_year,
    sec.semester,
    g.grade,
    g.grade_points
FROM students st
JOIN user_profiles up ON st.profile_id = up.profile_id
JOIN enrollments e ON st.student_id = e.student_id
JOIN sections sec ON e.section_id = sec.section_id
JOIN courses c ON sec.course_id = c.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
WHERE e.enrollment_status = 'enrolled';

DROP INDEX IF EXISTS idx_mv_transcript_student_id;
DROP INDEX IF EXISTS idx_mv_transcript_academic_year;
-- Create indexes for fast student lookups
CREATE INDEX idx_mv_transcript_student_id ON mv_student_transcripts(student_id);
CREATE INDEX idx_mv_transcript_academic_year ON mv_student_transcripts(academic_year);

-- Test querying the materialized views
--Before
EXPLAIN (ANALYZE, BUFFERS) SELECT d.department_id, d.department_code, d.department_name, COUNT(DISTINCT s.student_id) AS total_enrolled, COUNT(DISTINCT c.course_id) AS total_courses, ROUND(AVG(g.grade_points), 2) AS avg_gpa FROM departments d LEFT JOIN students s ON d.department_id = s.department_id LEFT JOIN courses c ON d.department_id = c.department_id AND c.is_active = TRUE LEFT JOIN enrollments e ON s.student_id = e.student_id LEFT JOIN grades g ON e.enrollment_id = g.enrollment_id GROUP BY d.department_id, d.department_code, d.department_name;

--After
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM mv_department_stats;
