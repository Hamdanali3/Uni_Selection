-- ==============================================================================
-- UniSelection — Migration 003: Global University Intelligence & Data Synchronization
-- Version: 1.3
-- Scope Reference: Module M23 of UniSelection_Phase_1_Master_Scope_v1.3.md
-- ==============================================================================

-- 1. Data Sources Registry
CREATE TABLE IF NOT EXISTS data_sources (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL, -- statutory_authority, official_portal, open_registry, aggregator
    authority_tier INT NOT NULL DEFAULT 3, -- 1=statutory, 2=official_inst, 3=global_registry, 4=aggregator
    official_url TEXT NOT NULL,
    access_method VARCHAR(50) NOT NULL, -- rest_api, html_polite, csv_bulk, manual_audit
    license_type VARCHAR(100) NOT NULL,
    refresh_interval_days INT NOT NULL DEFAULT 7,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Source Connectors Configuration
CREATE TABLE IF NOT EXISTS source_connectors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id VARCHAR(50) REFERENCES data_sources(id) ON DELETE CASCADE,
    connector_type VARCHAR(50) NOT NULL, -- rest_json, html_xpath, csv_stream, feed
    base_url TEXT NOT NULL,
    rate_limit_rps NUMERIC(4,2) DEFAULT 1.0,
    timeout_seconds INT DEFAULT 15,
    retry_count INT DEFAULT 3,
    headers_template JSONB DEFAULT '{}'::jsonb,
    status VARCHAR(50) DEFAULT 'operational', -- operational, degraded, format_drift, unreachable, disabled
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Source Field Authority Mappings
CREATE TABLE IF NOT EXISTS source_field_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- institution, campus, programme, admission, fee, scholarship
    field_name VARCHAR(50) NOT NULL,
    primary_source_id VARCHAR(50) REFERENCES data_sources(id),
    fallback_source_id VARCHAR(50) REFERENCES data_sources(id),
    authority_rule TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Synchronization Runs History
CREATE TABLE IF NOT EXISTS sync_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id VARCHAR(50) REFERENCES data_sources(id),
    trigger_type VARCHAR(50) DEFAULT 'scheduled', -- scheduled, manual, event_webhook
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'running', -- running, completed, failed, partially_completed
    records_discovered INT DEFAULT 0,
    records_ingested INT DEFAULT 0,
    records_updated INT DEFAULT 0,
    change_proposals_created INT DEFAULT 0,
    error_log TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Source Content Snapshots & Fingerprints (ETag / SHA-256)
CREATE TABLE IF NOT EXISTS source_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id VARCHAR(50) REFERENCES data_sources(id),
    resource_url TEXT NOT NULL,
    etag VARCHAR(255),
    last_modified VARCHAR(255),
    content_hash VARCHAR(64) NOT NULL, -- SHA-256
    byte_size INT,
    fetched_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Granular Change Events & Diff Proposals
CREATE TABLE IF NOT EXISTS source_change_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sync_run_id UUID REFERENCES sync_runs(id) ON DELETE SET NULL,
    source_id VARCHAR(50) REFERENCES data_sources(id),
    entity_type VARCHAR(50) NOT NULL, -- institution, campus, programme, admission, fee, scholarship
    entity_id VARCHAR(100) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    diff_reason TEXT,
    confidence_score NUMERIC(5,2) DEFAULT 100.0,
    risk_level VARCHAR(20) DEFAULT 'low', -- low, medium, high, critical
    status VARCHAR(30) DEFAULT 'pending', -- pending, auto_published, approved, rejected, deferred
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. High-Risk Human Review Queue
CREATE TABLE IF NOT EXISTS review_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    change_event_id UUID REFERENCES source_change_events(id) ON DELETE CASCADE,
    assigned_to UUID,
    decision VARCHAR(30), -- approved, rejected, deferred, edited
    decision_notes TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Persistent External Identifiers (ROR, OpenAlex, HEC, CRICOS, UKPRN)
CREATE TABLE IF NOT EXISTS institution_identifiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id VARCHAR(50) REFERENCES institutions(id) ON DELETE CASCADE,
    id_type VARCHAR(50) NOT NULL, -- ROR, OpenAlex, HEC_DAI_ID, CRICOS, UKPRN, IPEDS
    id_value VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    source_id VARCHAR(50) REFERENCES data_sources(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_inst_id_type_val UNIQUE (institution_id, id_type, id_value)
);

-- 9. Institution Aliases and Transliterations
CREATE TABLE IF NOT EXISTS institution_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id VARCHAR(50) REFERENCES institutions(id) ON DELETE CASCADE,
    alias_name VARCHAR(255) NOT NULL,
    alias_type VARCHAR(50) DEFAULT 'acronym', -- acronym, former_name, transliteration, colloquial
    language VARCHAR(10) DEFAULT 'en',
    source_id VARCHAR(50) REFERENCES data_sources(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Scholarships and Financial Aid
CREATE TABLE IF NOT EXISTS scholarships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id VARCHAR(50) REFERENCES institutions(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    provider_name VARCHAR(255),
    funding_type VARCHAR(50) NOT NULL, -- fully_funded, partial_tuition, merit_stipend, need_based
    award_amount NUMERIC(12,2),
    currency VARCHAR(3) DEFAULT 'PKR',
    degree_level VARCHAR(50), -- undergraduate, postgraduate, doctorate, all
    application_deadline DATE,
    eligibility_criteria TEXT,
    official_portal_url TEXT NOT NULL,
    source_id VARCHAR(50) REFERENCES data_sources(id),
    last_verified_at DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'published', -- published, in_review, draft, expired
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Data Quality and Discrepancy Tracking
CREATE TABLE IF NOT EXISTS data_quality_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    issue_type VARCHAR(50) NOT NULL, -- stale_verification, missing_official_link, conflicting_data, unresolved_duplicate, broken_url
    severity VARCHAR(20) DEFAULT 'medium', -- low, medium, high, critical
    description TEXT NOT NULL,
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- 12. Add Provenance Columns to Existing Core Tables
DO $$
BEGIN
    -- institutions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='institutions' AND column_name='source_id') THEN
        ALTER TABLE institutions ADD COLUMN source_id VARCHAR(50) REFERENCES data_sources(id);
        ALTER TABLE institutions ADD COLUMN last_checked_at TIMESTAMPTZ DEFAULT NOW();
        ALTER TABLE institutions ADD COLUMN confidence_score NUMERIC(5,2) DEFAULT 100.0;
        ALTER TABLE institutions ADD COLUMN data_freshness_status VARCHAR(20) DEFAULT 'current';
    END IF;

    -- campuses
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='campuses' AND column_name='source_id') THEN
        ALTER TABLE campuses ADD COLUMN source_id VARCHAR(50) REFERENCES data_sources(id);
        ALTER TABLE campuses ADD COLUMN last_checked_at TIMESTAMPTZ DEFAULT NOW();
        ALTER TABLE campuses ADD COLUMN confidence_score NUMERIC(5,2) DEFAULT 100.0;
        ALTER TABLE campuses ADD COLUMN data_freshness_status VARCHAR(20) DEFAULT 'current';
    END IF;

    -- programmes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='programmes' AND column_name='source_id') THEN
        ALTER TABLE programmes ADD COLUMN source_id VARCHAR(50) REFERENCES data_sources(id);
        ALTER TABLE programmes ADD COLUMN last_checked_at TIMESTAMPTZ DEFAULT NOW();
        ALTER TABLE programmes ADD COLUMN confidence_score NUMERIC(5,2) DEFAULT 100.0;
        ALTER TABLE programmes ADD COLUMN data_freshness_status VARCHAR(20) DEFAULT 'current';
    END IF;

    -- admissions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='admissions' AND column_name='source_id') THEN
        ALTER TABLE admissions ADD COLUMN source_id VARCHAR(50) REFERENCES data_sources(id);
        ALTER TABLE admissions ADD COLUMN last_checked_at TIMESTAMPTZ DEFAULT NOW();
        ALTER TABLE admissions ADD COLUMN confidence_score NUMERIC(5,2) DEFAULT 100.0;
        ALTER TABLE admissions ADD COLUMN data_freshness_status VARCHAR(20) DEFAULT 'current';
    END IF;

    -- fee_records
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fee_records' AND column_name='source_id') THEN
        ALTER TABLE fee_records ADD COLUMN source_id VARCHAR(50) REFERENCES data_sources(id);
        ALTER TABLE fee_records ADD COLUMN last_checked_at TIMESTAMPTZ DEFAULT NOW();
        ALTER TABLE fee_records ADD COLUMN confidence_score NUMERIC(5,2) DEFAULT 100.0;
        ALTER TABLE fee_records ADD COLUMN data_freshness_status VARCHAR(20) DEFAULT 'current';
    END IF;
END $$;

-- ==============================================================================
-- 13. Row Level Security (RLS) Policies
-- ==============================================================================

ALTER TABLE data_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE source_connectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE source_field_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE source_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE source_change_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE institution_identifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE institution_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE scholarships ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_quality_issues ENABLE ROW LEVEL SECURITY;

-- Public Read Policies
CREATE POLICY "Public read active data sources"
    ON data_sources FOR SELECT
    USING (is_active = TRUE);

CREATE POLICY "Public read institution identifiers"
    ON institution_identifiers FOR SELECT
    USING (TRUE);

CREATE POLICY "Public read institution aliases"
    ON institution_aliases FOR SELECT
    USING (TRUE);

CREATE POLICY "Public read published scholarships"
    ON scholarships FOR SELECT
    USING (status = 'published');

-- Deny Anonymous Writes to All Intelligence Tables
CREATE POLICY "Deny anonymous insert to data_sources" ON data_sources FOR INSERT USING (FALSE);
CREATE POLICY "Deny anonymous update to data_sources" ON data_sources FOR UPDATE USING (FALSE);
CREATE POLICY "Deny anonymous delete to data_sources" ON data_sources FOR DELETE USING (FALSE);

CREATE POLICY "Deny anonymous write to source_connectors" ON source_connectors FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to source_field_mappings" ON source_field_mappings FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to sync_runs" ON sync_runs FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to source_snapshots" ON source_snapshots FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to source_change_events" ON source_change_events FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to review_queue" ON review_queue FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to data_quality_issues" ON data_quality_issues FOR ALL USING (FALSE);
CREATE POLICY "Deny anonymous write to scholarships" ON scholarships FOR INSERT USING (FALSE);

-- Admin / Service-Role Full Access Policies
CREATE POLICY "Service role full access on data_sources"
    ON data_sources FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on source_connectors"
    ON source_connectors FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on sync_runs"
    ON sync_runs FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on source_snapshots"
    ON source_snapshots FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on source_change_events"
    ON source_change_events FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on review_queue"
    ON review_queue FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on institution_identifiers"
    ON institution_identifiers FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on institution_aliases"
    ON institution_aliases FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on scholarships"
    ON scholarships FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "Service role full access on data_quality_issues"
    ON data_quality_issues FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

-- Indexes for Fast Query Performance
CREATE INDEX IF NOT EXISTS idx_inst_identifiers_inst_id ON institution_identifiers(institution_id);
CREATE INDEX IF NOT EXISTS idx_inst_identifiers_val ON institution_identifiers(id_value);
CREATE INDEX IF NOT EXISTS idx_inst_aliases_inst_id ON institution_aliases(institution_id);
CREATE INDEX IF NOT EXISTS idx_scholarships_inst_id ON scholarships(institution_id);
CREATE INDEX IF NOT EXISTS idx_scholarships_status ON scholarships(status);
CREATE INDEX IF NOT EXISTS idx_change_events_status ON source_change_events(status);
CREATE INDEX IF NOT EXISTS idx_change_events_entity ON source_change_events(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_sync_runs_source_status ON sync_runs(source_id, status);
