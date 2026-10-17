-- ============================================================================
-- Migration 004: Phase 2 Schema Extensions & Security RLS Hardening
--
-- Modules Covered:
--   P2-01: Enhanced Scholarships & Financial Aid Directory
--   P2-08: Cloud-Backed User Discrepancy Reporting
--   P2-11: Data Quality & Governance Dashboards
--   P2-12: Bounded International Country Guidance
--   P2-16: Security, Privacy & Row Level Security (RLS) Policies
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Enhanced Scholarships Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scholarships (
    id TEXT PRIMARY KEY,
    institution_id TEXT NOT NULL REFERENCES public.institutions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    scholarship_type TEXT NOT NULL DEFAULT 'Merit-Based',
    provider_name TEXT,
    funding_type TEXT NOT NULL DEFAULT 'merit_based', -- merit_based, need_based, government, fully_funded, partial_fee
    degree_levels TEXT[] DEFAULT ARRAY['undergraduate']::TEXT[],
    discipline TEXT,
    country TEXT,
    coverage_type TEXT NOT NULL DEFAULT 'full_tuition', -- full_tuition, partial_tuition, full_funding, stipend_only
    coverage_details TEXT NOT NULL DEFAULT 'See official university website',
    award_amount NUMERIC(14, 2),
    currency TEXT DEFAULT 'PKR',
    min_percentage NUMERIC(5, 2),
    eligibility_criteria TEXT[] DEFAULT ARRAY[]::TEXT[],
    minimum_criteria TEXT DEFAULT 'High academic standing',
    application_deadline TIMESTAMPTZ,
    deadline_status TEXT NOT NULL DEFAULT 'unknown', -- open, closing, closed, unknown
    source_url TEXT,
    official_application_url TEXT,
    last_checked_at TIMESTAMPTZ,
    verification_status TEXT NOT NULL DEFAULT 'unverified', -- verified, unverified, stale
    language TEXT DEFAULT 'English',
    status TEXT NOT NULL DEFAULT 'published', -- published, draft, archived
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scholarships_institution_id ON public.scholarships(institution_id);
CREATE INDEX IF NOT EXISTS idx_scholarships_funding_type ON public.scholarships(funding_type);
CREATE INDEX IF NOT EXISTS idx_scholarships_coverage_type ON public.scholarships(coverage_type);
CREATE INDEX IF NOT EXISTS idx_scholarships_status ON public.scholarships(status);
CREATE INDEX IF NOT EXISTS idx_scholarships_country ON public.scholarships(country);

-- ----------------------------------------------------------------------------
-- 2. Cloud Discrepancy Reports Table (P2-08)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.discrepancy_reports (
    id TEXT PRIMARY KEY,
    entity_id TEXT NOT NULL,
    entity_type TEXT NOT NULL, -- institution, campus, programme, fee_record, admission, scholarship
    field_name TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT NOT NULL,
    risk_level TEXT NOT NULL DEFAULT 'medium', -- low, medium, high
    diff_reason TEXT NOT NULL,
    reporter_id TEXT DEFAULT 'anonymous_student',
    status TEXT NOT NULL DEFAULT 'pending', -- pending, approved, rejected, resolved
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    reviewed_by TEXT,
    resolution_notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_discrepancy_reports_entity ON public.discrepancy_reports(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_discrepancy_reports_status ON public.discrepancy_reports(status);
CREATE INDEX IF NOT EXISTS idx_discrepancy_reports_created ON public.discrepancy_reports(created_at DESC);

-- ----------------------------------------------------------------------------
-- 3. Bounded International Country Guidance Table (P2-12)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.country_guidance (
    country_code TEXT PRIMARY KEY, -- ISO 3166-1 alpha-3
    country_name TEXT NOT NULL,
    flag_emoji TEXT DEFAULT '🌐',
    overview_text TEXT NOT NULL,
    academic_year TEXT,
    application_window TEXT,
    visa_type_name TEXT,
    visa_authority_url TEXT,
    immigration_portal_url TEXT,
    language_of_instruction TEXT DEFAULT 'English',
    language_requirements TEXT,
    official_links JSONB NOT NULL DEFAULT '[]'::jsonb,
    last_reviewed_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'published',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_country_guidance_status ON public.country_guidance(status);

-- ----------------------------------------------------------------------------
-- 4. Row-Level Security (RLS) Hardening (P2-16)
-- ----------------------------------------------------------------------------

-- Enable RLS on all Phase 2 tables
ALTER TABLE public.scholarships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discrepancy_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.country_guidance ENABLE ROW LEVEL SECURITY;

-- Scholarships RLS:
-- Public / Anon can only read published scholarships.
CREATE POLICY "Public students can read published scholarships"
    ON public.scholarships
    FOR SELECT
    TO anon, authenticated
    USING (status = 'published');

-- Admins / Service role can perform all mutations on scholarships.
CREATE POLICY "Admins have full access to scholarships"
    ON public.scholarships
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Discrepancy Reports RLS (Privacy-Preserving User Submissions):
-- Any student (anonymous or authenticated) can submit a discrepancy report.
CREATE POLICY "Students can submit discrepancy reports"
    ON public.discrepancy_reports
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Anonymous students CANNOT read or list reports submitted by others.
-- Only service_role / editorial admins can view and resolve reports.
CREATE POLICY "Editorial admins can review discrepancy reports"
    ON public.discrepancy_reports
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Country Guidance RLS:
-- Public read for published country guidance.
CREATE POLICY "Public students can read published country guidance"
    ON public.country_guidance
    FOR SELECT
    TO anon, authenticated
    USING (status = 'published');

CREATE POLICY "Admins have full access to country guidance"
    ON public.country_guidance
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);
