-- UniSelection PostgreSQL RLS Policies Migration (002_rls_policies.sql)
-- Version: 1.0 (Phase 1 Baseline)

-- 1. Enable RLS on all tables
ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE disciplines ENABLE ROW LEVEL SECURITY;
ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE institution_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE programmes ENABLE ROW LEVEL SECURITY;
ALTER TABLE eligibility_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

-- 2. Public Read Policies for Published Data (Allow Anonymous & Authenticated SELECT)
CREATE POLICY "Public read countries" ON countries FOR SELECT USING (true);
CREATE POLICY "Public read cities" ON cities FOR SELECT USING (true);
CREATE POLICY "Public read sources" ON sources FOR SELECT USING (true);
CREATE POLICY "Public read categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public read disciplines" ON disciplines FOR SELECT USING (true);

CREATE POLICY "Public read published institutions" ON institutions
    FOR SELECT USING (status = 'published');

CREATE POLICY "Public read institution categories" ON institution_categories
    FOR SELECT USING (true);

CREATE POLICY "Public read published campuses" ON campuses
    FOR SELECT USING (status = 'published');

CREATE POLICY "Public read published programmes" ON programmes
    FOR SELECT USING (status = 'published');

CREATE POLICY "Public read eligibility rules" ON eligibility_rules
    FOR SELECT USING (true);

CREATE POLICY "Public read admissions" ON admissions
    FOR SELECT USING (true);

CREATE POLICY "Public read fee records" ON fee_records
    FOR SELECT USING (true);

-- 3. User Private Data Policies (Profiles and Saved Items)
-- Profile: user can select, insert, and update their own profile
CREATE POLICY "Users read own profile" ON profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Saved Items: user can read, insert, and delete their own saved shortlist items
CREATE POLICY "Users read own saved items" ON saved_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own saved items" ON saved_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own saved items" ON saved_items
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Admin and Editor Role Guarding (Service Role / Admin claims)
-- In Supabase, the service_role key bypasses RLS automatically.
-- For authenticated editor/admin users with JWT claim app_metadata->>'role' = 'admin':
CREATE POLICY "Admins full access institutions" ON institutions
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access programmes" ON programmes
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access campuses" ON campuses
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access eligibility_rules" ON eligibility_rules
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access admissions" ON admissions
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access fee_records" ON fee_records
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins full access sources" ON sources
    FOR ALL USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );

CREATE POLICY "Admins read audit logs" ON admin_audit_log
    FOR SELECT USING (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') = 'admin'
    );

CREATE POLICY "Admins insert audit logs" ON admin_audit_log
    FOR INSERT WITH CHECK (
        coalesce(auth.jwt()->'app_metadata'->>'role', '') IN ('admin', 'editor')
    );
