-- UniSelection PostgreSQL Starter Seed Script (001_starter_seed.sql)
-- Inserts Countries, Cities, Categories, Disciplines, and starter Institutions

-- 1. Countries
INSERT INTO countries (id, name, is_national) VALUES
('PAK', 'Pakistan', true),
('GBR', 'United Kingdom', false),
('USA', 'United States', false),
('CAN', 'Canada', false),
('DEU', 'Germany', false),
('AUS', 'Australia', false),
('SGP', 'Singapore', false),
('TUR', 'Turkey', false),
('MYS', 'Malaysia', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Cities
INSERT INTO cities (id, country_id, name, province_state) VALUES
('b1010000-0000-0000-0000-000000000001', 'PAK', 'Islamabad', 'Islamabad Capital Territory'),
('b1010000-0000-0000-0000-000000000002', 'PAK', 'Lahore', 'Punjab'),
('b1010000-0000-0000-0000-000000000003', 'PAK', 'Karachi', 'Sindh'),
('b1010000-0000-0000-0000-000000000004', 'PAK', 'Topi, Swabi', 'Khyber Pakhtunkhwa'),
('b1010000-0000-0000-0000-000000000005', 'GBR', 'Oxford', 'England'),
('b1010000-0000-0000-0000-000000000006', 'USA', 'Cambridge / Boston', 'Massachusetts'),
('b1010000-0000-0000-0000-000000000007', 'DEU', 'Munich', 'Bavaria')
ON CONFLICT (id) DO NOTHING;

-- 3. Categories
INSERT INTO categories (id, slug, name, icon_name, description) VALUES
('c1010000-0000-0000-0000-000000000001', 'engineering', 'Engineering & Technology', 'engineering', 'Accredited engineering disciplines.'),
('c1010000-0000-0000-0000-000000000002', 'computing-it', 'Computing & Artificial Intelligence', 'computer', 'Computer science, software engineering, AI, cyber security.'),
('c1010000-0000-0000-0000-000000000003', 'medical-health', 'Medical & Health Sciences', 'local_hospital', 'MBBS, BDS, pharmacy, allied health.'),
('c1010000-0000-0000-0000-000000000004', 'business-management', 'Business & Management', 'business_center', 'BBA, accounting, finance, economics.'),
('c1010000-0000-0000-0000-000000000005', 'natural-sciences', 'Natural & Applied Sciences', 'science', 'Physics, chemistry, math, biotech.'),
('c1010000-0000-0000-0000-000000000006', 'social-humanities', 'Social Sciences & Humanities', 'menu_book', 'Law, psychology, international relations.')
ON CONFLICT (id) DO NOTHING;

-- 4. Disciplines
INSERT INTO disciplines (id, category_id, name) VALUES
('d1010000-0000-0000-0000-000000000001', 'c1010000-0000-0000-0000-000000000002', 'Computer Science'),
('d1010000-0000-0000-0000-000000000002', 'c1010000-0000-0000-0000-000000000002', 'Software Engineering'),
('d1010000-0000-0000-0000-000000000003', 'c1010000-0000-0000-0000-000000000001', 'Electrical Engineering'),
('d1010000-0000-0000-0000-000000000004', 'c1010000-0000-0000-0000-000000000003', 'Medicine (MBBS)'),
('d1010000-0000-0000-0000-000000000005', 'c1010000-0000-0000-0000-000000000004', 'Business Administration (BBA)')
ON CONFLICT (id) DO NOTHING;

-- 5. Institutions (Key Starters)
INSERT INTO institutions (id, name, short_name, country_id, city_id, institution_type, hec_recognized, official_website, admissions_url, status, last_verified_at) VALUES
('nust', 'National University of Sciences & Technology', 'NUST', 'PAK', 'b1010000-0000-0000-0000-000000000001', 'Public', true, 'https://nust.edu.pk', 'https://ugadmissions.nust.edu.pk', 'published', '2026-09-20'),
('lums', 'Lahore University of Management Sciences', 'LUMS', 'PAK', 'b1010000-0000-0000-0000-000000000002', 'Private', true, 'https://lums.edu.pk', 'https://admissions.lums.edu.pk', 'published', '2026-09-18'),
('giki', 'Ghulam Ishaq Khan Institute of Engineering Sciences and Technology', 'GIKI', 'PAK', 'b1010000-0000-0000-0000-000000000004', 'Autonomous', true, 'https://giki.edu.pk', 'https://giki.edu.pk/admissions', 'published', '2026-09-15'),
('fast-nu', 'National University of Computer and Emerging Sciences', 'FAST-NUCES', 'PAK', 'b1010000-0000-0000-0000-000000000001', 'Private', true, 'https://nu.edu.pk', 'https://admissions.nu.edu.pk', 'published', '2026-09-22'),
('aku', 'Aga Khan University', 'AKU', 'PAK', 'b1010000-0000-0000-0000-000000000003', 'Private', true, 'https://aku.edu', 'https://www.aku.edu/admissions', 'published', '2026-09-12'),
('oxford', 'University of Oxford', 'Oxford', 'GBR', 'b1010000-0000-0000-0000-000000000005', 'Public', true, 'https://ox.ac.uk', 'https://www.ox.ac.uk/admissions', 'published', '2026-09-01'),
('mit', 'Massachusetts Institute of Technology', 'MIT', 'USA', 'b1010000-0000-0000-0000-000000000006', 'Private', true, 'https://mit.edu', 'https://mitadmissions.org', 'published', '2026-09-08')
ON CONFLICT (id) DO NOTHING;

-- 6. Institution Categories Junction
INSERT INTO institution_categories (institution_id, category_id) VALUES
('nust', 'c1010000-0000-0000-0000-000000000001'),
('nust', 'c1010000-0000-0000-0000-000000000002'),
('lums', 'c1010000-0000-0000-0000-000000000004'),
('lums', 'c1010000-0000-0000-0000-000000000002'),
('giki', 'c1010000-0000-0000-0000-000000000001'),
('fast-nu', 'c1010000-0000-0000-0000-000000000002'),
('aku', 'c1010000-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;
