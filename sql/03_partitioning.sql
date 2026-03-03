-- 1. Rename the original monolithic table
ALTER TABLE grades RENAME TO grades_old;

-- 2. Create the new partitioned table architecture
CREATE TABLE grades (
    grade_id SERIAL,
    enrollment_id INTEGER NOT NULL,
    grade VARCHAR(2) NOT NULL,
    grade_points NUMERIC(3,2) NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (grade_id, created_at)
) PARTITION BY RANGE (created_at);

-- 3. Create partitions for academic years
CREATE TABLE grades_y2023 PARTITION OF grades FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE grades_y2024 PARTITION OF grades FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE grades_y2025 PARTITION OF grades FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE grades_default PARTITION OF grades DEFAULT;

-- 4. Migrate existing data from the old table into the partitioned structure
INSERT INTO grades SELECT * FROM grades_old;

-- 5. Add back the foreign key constraint (requires referencing the correct columns)
ALTER TABLE grades ADD CONSTRAINT fk_grades_enrollment
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE;

