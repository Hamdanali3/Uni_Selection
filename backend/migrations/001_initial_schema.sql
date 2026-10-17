-- UniSelection PostgreSQL Initial Schema Migration (001_initial_schema.sql)
-- Version: 1.0 (Phase 1 Baseline)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Countries
CREATE TABLE IF NOT EXISTS countries (
    id VARCHAR(3) PRIMARY KEY, -- ISO 3-letter code (PAK, GBR, USA, etc.)
    name VARCHAR(100) NOT NULL UNIQUE,
    is_national BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Cities
CREATE TABLE IF NOT EXISTS cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id VARCHAR(3) NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    province_state VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Sources (Verification registry)
CREATE TABLE IF NOT EXISTS sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    provider VARCHAR(150) NOT NULL,
    url TEXT NOT NULL,
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('Regulator', 'Official Portal', 'Prospectus PDF', 'Direct Confirmation')),
    accessed_at TIMESTAMPTZ DEFAULT now(),
    editor_id VARCHAR(100) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Categories (Data-driven academic classification)
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_name VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Disciplines
CREATE TABLE IF NOT EXISTS disciplines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Institutions
CREATE TABLE IF NOT EXISTS institutions (
    id VARCHAR(50) PRIMARY KEY, -- Canonical slug (nust, lums, giki, etc.)
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    country_id VARCHAR(3) NOT NULL REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    institution_type VARCHAR(30) NOT NULL CHECK (institution_type IN ('Public', 'Private', 'Autonomous')),
    hec_recognized BOOLEAN DEFAULT TRUE,
    official_website TEXT NOT NULL,
    admissions_url TEXT,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(50),
    logo_url TEXT,
    overview TEXT,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'in_review', 'published', 'archived')),
    source_id UUID REFERENCES sources(id),
    last_verified_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Institution Categories (Many-to-Many)
CREATE TABLE IF NOT EXISTS institution_categories (
    institution_id VARCHAR(50) NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (institution_id, category_id)
);

-- 8. Campuses
CREATE TABLE IF NOT EXISTS campuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id VARCHAR(50) NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    city_id UUID NOT NULL REFERENCES cities(id),
    address TEXT,
    is_main_campus BOOLEAN DEFAULT FALSE,
    hec_recognized BOOLEAN DEFAULT TRUE,
    official_url TEXT,
    status VARCHAR(20) DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. Programmes
CREATE TABLE IF NOT EXISTS programmes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id VARCHAR(50) NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
    campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    degree_level VARCHAR(30) NOT NULL CHECK (degree_level IN ('Undergraduate', 'Postgraduate', 'Doctorate', 'Associate')),
    discipline_id UUID NOT NULL REFERENCES disciplines(id),
    duration_years NUMERIC(3, 1) NOT NULL CHECK (duration_years > 0),
    study_mode VARCHAR(30) DEFAULT 'Full-Time',
    official_url TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    last_verified_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 10. Eligibility Rules
CREATE TABLE IF NOT EXISTS eligibility_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    programme_id UUID NOT NULL REFERENCES programmes(id) ON DELETE CASCADE,
    rule_type VARCHAR(50) NOT NULL,
    min_percentage NUMERIC(5, 2),
    required_subjects TEXT,
    accepted_entry_tests TEXT,
    rule_explanation TEXT NOT NULL,
    caveat TEXT NOT NULL DEFAULT 'Guidance only based on published rules. Admission is competitive and subject to official quota and merit lists.',
    effective_session VARCHAR(20) NOT NULL,
    source_url TEXT NOT NULL,
    last_verified_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 11. Admissions (Cycles and Deadlines)
CREATE TABLE IF NOT EXISTS admissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id VARCHAR(50) NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
    programme_id UUID REFERENCES programmes(id) ON DELETE CASCADE,
    session_name VARCHAR(50) NOT NULL,
    opening_date DATE,
    closing_date DATE,
    entry_test_date DATE,
    admission_status VARCHAR(30) NOT NULL CHECK (admission_status IN ('Upcoming', 'Open', 'Closed', 'Under Review')),
    source_url TEXT NOT NULL,
    last_verified_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 12. Fee Records
CREATE TABLE IF NOT EXISTS fee_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    programme_id UUID NOT NULL REFERENCES programmes(id) ON DELETE CASCADE,
    academic_session VARCHAR(20) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'PKR',
    billing_basis VARCHAR(30) NOT NULL CHECK (billing_basis IN ('Per Semester', 'Per Year', 'Per Credit Hour', 'Full Programme')),
    tuition_fee NUMERIC(12, 2) NOT NULL,
    admission_fee_onetime NUMERIC(12, 2) DEFAULT 0,
    security_deposit NUMERIC(12, 2) DEFAULT 0,
    notes TEXT,
    source_url TEXT NOT NULL,
    last_verified_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 13. Profiles (Authenticated Users)
CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY, -- Maps to auth.users.id
    display_name VARCHAR(100),
    intended_degree_level VARCHAR(30),
    preferred_location VARCHAR(100),
    preferred_disciplines TEXT[],
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 14. Saved Items (Shortlist)
CREATE TABLE IF NOT EXISTS saved_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    entity_type VARCHAR(30) NOT NULL CHECK (entity_type IN ('institution', 'programme')),
    entity_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 15. Admin Audit Log
CREATE TABLE IF NOT EXISTS admin_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    entity VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50) NOT NULL,
    changes JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 16. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_institutions_country ON institutions(country_id);
CREATE INDEX IF NOT EXISTS idx_institutions_status ON institutions(status);
CREATE INDEX IF NOT EXISTS idx_institutions_name ON institutions(name);
CREATE INDEX IF NOT EXISTS idx_campuses_institution ON campuses(institution_id);
CREATE INDEX IF NOT EXISTS idx_programmes_institution ON programmes(institution_id);
CREATE INDEX IF NOT EXISTS idx_programmes_discipline ON programmes(discipline_id);
CREATE INDEX IF NOT EXISTS idx_programmes_level ON programmes(degree_level);
CREATE INDEX IF NOT EXISTS idx_admissions_institution ON admissions(institution_id);
CREATE INDEX IF NOT EXISTS idx_fee_records_programme ON fee_records(programme_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_user ON saved_items(user_id);
