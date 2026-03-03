-- Active: 1761824567854@@127.0.0.1@5432@university_db_optimization
CREATE TYPE user_role AS ENUM ('admin', 'faculty', 'student');
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other');
CREATE TYPE semester_type AS ENUM ('fall', 'spring', 'summer');
CREATE TYPE enrollment_status_type AS ENUM ('enrolled', 'dropped', 'withdrawn', 'failed');
CREATE TYPE attendance_status_type AS ENUM ('present', 'absent', 'late');

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_code VARCHAR(10) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    established_date DATE,
    office_location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    profile_image TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender gender_type,
    phone_number VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    profile_id INTEGER UNIQUE NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    department_id INTEGER REFERENCES departments(department_id) ON DELETE SET NULL,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    enrollment_year INTEGER NOT NULL,
    gpa NUMERIC(3,2) DEFAULT 0.00,
    cgpa NUMERIC(3,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faculty (
    faculty_id SERIAL PRIMARY KEY,
    profile_id INTEGER UNIQUE NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    department_id INTEGER REFERENCES departments(department_id) ON DELETE SET NULL,
    faculty_number VARCHAR(20) UNIQUE NOT NULL,
    designation VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    office_number VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE administrators (
    admin_id SERIAL PRIMARY KEY,
    profile_id INTEGER UNIQUE NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    admin_number VARCHAR(20) UNIQUE NOT NULL,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    is_super_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    department_id INTEGER REFERENCES departments(department_id) ON DELETE SET NULL,
    credits INTEGER NOT NULL CHECK (credits > 0 AND credits <= 5),
    course_level VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sections (
    section_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    section_code VARCHAR(10) NOT NULL,
    faculty_id INTEGER REFERENCES faculty(faculty_id) ON DELETE SET NULL,
    semester semester_type NOT NULL,
    academic_year INTEGER NOT NULL,
    classroom VARCHAR(20),
    schedule JSONB,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    max_capacity INTEGER DEFAULT 30,
    current_enrollment INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, section_code, academic_year, semester)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    section_id INTEGER NOT NULL REFERENCES sections(section_id) ON DELETE CASCADE,
    enrollment_status enrollment_status_type DEFAULT 'enrolled',
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, section_id)
);

CREATE TABLE grades (
    grade_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER UNIQUE NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    grade VARCHAR(2) NOT NULL,
    grade_points NUMERIC(3,2) NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status attendance_status_type NOT NULL,
    notes TEXT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(enrollment_id, attendance_date)
);

CREATE TABLE course_prerequisites (
    prerequisite_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    prerequisite_course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    minimum_grade VARCHAR(2) DEFAULT 'C',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, prerequisite_course_id),
    CHECK (course_id != prerequisite_course_id)
);
