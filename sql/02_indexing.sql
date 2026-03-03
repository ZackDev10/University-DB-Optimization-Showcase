SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM enrollments
WHERE section_id = 10;

DROP INDEX IF EXISTS idx_enrollments_section_id;

CREATE INDEX idx_enrollments_section_id ON enrollments(section_id);

ANALYZE;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM enrollments
WHERE section_id = 10;

