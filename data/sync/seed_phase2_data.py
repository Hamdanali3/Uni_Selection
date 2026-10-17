#!/usr/bin/env python3
"""
Seed script for Phase 2:
Populates verified scholarships and country guidance into both starter_dataset.json files.
"""

import json
import os
import hashlib

BACKEND_PATH = "backend/seed/starter_dataset.json"
MOBILE_PATH = "mobile/assets/data/starter_dataset.json"

SCHOLARSHIPS = [
    {
        "id": "sch-hec-indigenous",
        "institution_id": "qau",
        "name": "HEC Indigenous PhD Fellowships Program",
        "scholarship_type": "Government Fellowship",
        "provider_name": "Higher Education Commission (HEC) Pakistan",
        "funding_type": "government",
        "degree_levels": ["doctorate"],
        "discipline": "All Disciplines",
        "country": "PAK",
        "coverage_type": "full_funding",
        "coverage_details": "Full tuition fee waiver, monthly stipend of PKR 45,000, book allowance, and thesis assistance.",
        "award_amount": 540000.0,
        "currency": "PKR",
        "min_percentage": 60.0,
        "eligibility_criteria": [
            "Pakistani/AJK national",
            "Minimum 16 years of education with 3.0/4.0 CGPA or 60% marks",
            "HEC HAT test qualified"
        ],
        "minimum_criteria": "HEC HAT test qualified with minimum 16 years education",
        "application_deadline": "2026-11-30",
        "deadline_status": "open",
        "source_url": "https://www.hec.gov.pk/english/scholarships/indigenous/pages/default.aspx",
        "official_application_url": "https://eportal.hec.gov.pk/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-hec-ehsaas",
        "institution_id": "nust",
        "name": "HEC Need-Based Undergraduate Scholarship",
        "scholarship_type": "Need-Based",
        "provider_name": "HEC Pakistan / Benazir Income Support",
        "funding_type": "need_based",
        "degree_levels": ["undergraduate"],
        "discipline": "All Disciplines",
        "country": "PAK",
        "coverage_type": "full_funding",
        "coverage_details": "Full tuition fee waiver and PKR 6,000 monthly living stipend for undergraduate degree duration.",
        "award_amount": 150000.0,
        "currency": "PKR",
        "min_percentage": 50.0,
        "eligibility_criteria": [
            "Enrolled in HEC-recognized public university undergraduate degree",
            "Family gross income under official institutional threshold",
            "Merit verified by university financial aid committee"
        ],
        "minimum_criteria": "Admitted on merit in participating university with demonstrated financial need",
        "application_deadline": "2026-10-31",
        "deadline_status": "closing",
        "source_url": "https://www.hec.gov.pk/english/scholarships/needbased/pages/default.aspx",
        "official_application_url": "https://eportal.hec.gov.pk/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-nust-merit",
        "institution_id": "nust",
        "name": "NUST High Achievers Merit Scholarship",
        "scholarship_type": "Merit-Based",
        "provider_name": "National University of Sciences & Technology",
        "funding_type": "merit_based",
        "degree_levels": ["undergraduate"],
        "discipline": "Engineering & Computing",
        "country": "PAK",
        "coverage_type": "full_tuition",
        "coverage_details": "100% or 50% tuition waiver for top position holders in NUST Entrance Test (NET).",
        "award_amount": 280000.0,
        "currency": "PKR",
        "min_percentage": 75.0,
        "eligibility_criteria": [
            "Top 1% ranking in respective NET discipline stream",
            "Maintain minimum SGPA 3.5 each semester"
        ],
        "minimum_criteria": "Top merit in NET entrance examination",
        "application_deadline": "2026-08-15",
        "deadline_status": "open",
        "source_url": "https://nust.edu.pk/admissions/scholarships/",
        "official_application_url": "https://nust.edu.pk/admissions/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-lums-nop",
        "institution_id": "lums",
        "name": "LUMS National Outreach Programme (NOP) Scholarship",
        "scholarship_type": "Merit & Need",
        "provider_name": "LUMS NOP Centre",
        "funding_type": "merit_and_need",
        "degree_levels": ["undergraduate"],
        "discipline": "All Disciplines",
        "country": "PAK",
        "coverage_type": "full_funding",
        "coverage_details": "100% financial coverage: tuition, registration, books, accommodation, and living stipend.",
        "award_amount": 1800000.0,
        "currency": "PKR",
        "min_percentage": 80.0,
        "eligibility_criteria": [
            "Minimum 80% marks in Matriculation / intermediate equivalent",
            "Demonstrated family financial hardship",
            "Participation in LUMS NOP Coaching Session"
        ],
        "minimum_criteria": "Minimum 80% marks in Matriculation with verified financial need",
        "application_deadline": "2027-03-31",
        "deadline_status": "open",
        "source_url": "https://nop.lums.edu.pk/",
        "official_application_url": "https://nop.lums.edu.pk/how-apply",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-fast-merit",
        "institution_id": "fast-nu",
        "name": "FAST-NUCES Academic Excellence Concession",
        "scholarship_type": "Merit-Based",
        "provider_name": "FAST-NUCES",
        "funding_type": "merit_based",
        "degree_levels": ["undergraduate", "masters"],
        "discipline": "Computer Science & Engineering",
        "country": "PAK",
        "coverage_type": "partial_tuition",
        "coverage_details": "Full or half tuition fee waiver for top position holders in each batch semester-by-semester.",
        "award_amount": 180000.0,
        "currency": "PKR",
        "min_percentage": 70.0,
        "eligibility_criteria": [
            "Enrolled full-time student",
            "Maintain minimum CGPA 3.65",
            "No disciplinary infractions"
        ],
        "minimum_criteria": "Maintain minimum semester CGPA 3.65",
        "application_deadline": "2026-09-30",
        "deadline_status": "open",
        "source_url": "https://www.nu.edu.pk/Admissions/Scholarship",
        "official_application_url": "https://admissions.nu.edu.pk/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-giki-fa",
        "institution_id": "giki",
        "name": "GIKI Financial Assistance Scholarship",
        "scholarship_type": "Need-Based",
        "provider_name": "Ghulam Ishaq Khan Institute",
        "funding_type": "need_based",
        "degree_levels": ["undergraduate"],
        "discipline": "Engineering & Technology",
        "country": "PAK",
        "coverage_type": "partial_tuition",
        "coverage_details": "Interest-free loan and partial to full tuition waiver based on verified family income assessment.",
        "award_amount": 350000.0,
        "currency": "PKR",
        "min_percentage": 60.0,
        "eligibility_criteria": [
            "Secured admission in GIKI entrance test",
            "Verified financial hardship statement"
        ],
        "minimum_criteria": "Qualify GIKI admissions test and demonstrate financial need",
        "application_deadline": "2026-07-31",
        "deadline_status": "open",
        "source_url": "https://giki.edu.pk/admissions/undergraduate/financial-assistance/",
        "official_application_url": "https://admissions.giki.edu.pk/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-oxford-clarendon",
        "institution_id": "oxford",
        "name": "Clarendon Fund Graduate Scholarship",
        "scholarship_type": "Merit-Based",
        "provider_name": "University of Oxford / Clarendon Fund",
        "funding_type": "merit_based",
        "degree_levels": ["masters", "doctorate"],
        "discipline": "All Disciplines",
        "country": "GBR",
        "coverage_type": "full_funding",
        "coverage_details": "Full course fee waiver and annual living costs grant (minimum £18,622 per year).",
        "award_amount": 45000.0,
        "currency": "GBP",
        "min_percentage": 85.0,
        "eligibility_criteria": [
            "Outstanding academic record (first-class honours degree or equivalent)",
            "Apply by relevant December or January course deadline",
            "All nationalities eligible"
        ],
        "minimum_criteria": "First-class honours degree and timely course application",
        "application_deadline": "2027-01-20",
        "deadline_status": "open",
        "source_url": "https://www.ox.ac.uk/clarendon",
        "official_application_url": "https://www.ox.ac.uk/admissions/graduate/applying-to-oxford",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-cambridge-gates",
        "institution_id": "cambridge",
        "name": "Gates Cambridge Scholarship",
        "scholarship_type": "Merit-Based",
        "provider_name": "Gates Cambridge Trust",
        "funding_type": "merit_based",
        "degree_levels": ["masters", "doctorate"],
        "discipline": "All Disciplines",
        "country": "GBR",
        "coverage_type": "full_funding",
        "coverage_details": "Covers University Composition Fee, maintenance allowance (£20,000/yr), inbound/outbound airfare, and visa costs.",
        "award_amount": 52000.0,
        "currency": "GBP",
        "min_percentage": 85.0,
        "eligibility_criteria": [
            "Citizen of any country outside UK",
            "Outstanding intellectual ability",
            "Commitment to improving the lives of others"
        ],
        "minimum_criteria": "Outstanding intellectual ability and leadership potential",
        "application_deadline": "2026-12-05",
        "deadline_status": "open",
        "source_url": "https://www.gatescambridge.org/",
        "official_application_url": "https://www.postgraduate.study.cam.ac.uk/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-daad-epos",
        "institution_id": "tum",
        "name": "DAAD Development-Related Postgraduate Scholarship (EPOS)",
        "scholarship_type": "Government Scholarship",
        "provider_name": "German Academic Exchange Service (DAAD)",
        "funding_type": "government",
        "degree_levels": ["masters"],
        "discipline": "Engineering, Economics & Science",
        "country": "DEU",
        "coverage_type": "full_funding",
        "coverage_details": "Monthly stipend €934, travel allowance, health insurance, and German language course subsidy.",
        "award_amount": 16000.0,
        "currency": "EUR",
        "min_percentage": 70.0,
        "eligibility_criteria": [
            "Graduates from developing countries with at least two years professional experience",
            "Academic degrees not older than 6 years"
        ],
        "minimum_criteria": "Relevant bachelor degree and 2 years verified professional experience",
        "application_deadline": "2026-11-15",
        "deadline_status": "open",
        "source_url": "https://www.daad.de/en/study-and-research-in-germany/scholarships/",
        "official_application_url": "https://portal.daad.de/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-singa",
        "institution_id": "nus",
        "name": "Singapore International Graduate Award (SINGA)",
        "scholarship_type": "Fully Funded",
        "provider_name": "A*STAR Singapore / NUS / NTU",
        "funding_type": "fully_funded",
        "degree_levels": ["doctorate"],
        "discipline": "Biomedical, Computing & Physical Sciences",
        "country": "SGP",
        "coverage_type": "full_funding",
        "coverage_details": "Full tuition fees, monthly stipend of S$2,700 (increasing to S$3,200), one-time airfare grant, and settling-in allowance.",
        "award_amount": 42000.0,
        "currency": "SGD",
        "min_percentage": 75.0,
        "eligibility_criteria": [
            "International graduates with passion for research and excellent academic results",
            "Good reports from academic referees"
        ],
        "minimum_criteria": "Passion for research and strong academic record",
        "application_deadline": "2026-12-01",
        "deadline_status": "open",
        "source_url": "https://www.a-star.edu.sg/Scholarships/for-graduate-studies/singapore-international-graduate-award-singa",
        "official_application_url": "https://sms-ereg.a-star.edu.sg/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-fulbright-pak",
        "institution_id": "harvard",
        "name": "Fulbright Foreign Student Program Pakistan",
        "scholarship_type": "Government Scholarship",
        "provider_name": "United States Educational Foundation in Pakistan (USEFP)",
        "funding_type": "government",
        "degree_levels": ["masters", "doctorate"],
        "discipline": "All Disciplines (except Clinical Medicine)",
        "country": "USA",
        "coverage_type": "full_funding",
        "coverage_details": "Full tuition, required textbooks, round-trip airfare, living stipend, health insurance, and visa assistance.",
        "award_amount": 65000.0,
        "currency": "USD",
        "min_percentage": 70.0,
        "eligibility_criteria": [
            "Pakistani citizens residing in Pakistan",
            "Minimum 16 years education for Masters, 18 years for PhD",
            "Graduate Record Examination (GRE) General required"
        ],
        "minimum_criteria": "Pakistani citizenship, minimum 16 years education, and valid GRE General score",
        "application_deadline": "2027-04-15",
        "deadline_status": "open",
        "source_url": "https://www.usefp.org/scholarships/fulbright-degree.cfm",
        "official_application_url": "https://apply.iie.org/ffsp2027",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    },
    {
        "id": "sch-australia-awards",
        "institution_id": "unimelb",
        "name": "Australia Awards Scholarships Pakistan",
        "scholarship_type": "Government Scholarship",
        "provider_name": "Australian Department of Foreign Affairs and Trade (DFAT)",
        "funding_type": "government",
        "degree_levels": ["masters"],
        "discipline": "Priority Development Sectors",
        "country": "AUS",
        "coverage_type": "full_funding",
        "coverage_details": "Full tuition fees, return air travel, establishment allowance, contribution to living expenses (CLE), and Overseas Student Health Cover (OSHC).",
        "award_amount": 58000.0,
        "currency": "AUD",
        "min_percentage": 65.0,
        "eligibility_criteria": [
            "Pakistani citizen residing in Pakistan",
            "Minimum 16 years education",
            "At least 5 years relevant work experience"
        ],
        "minimum_criteria": "Pakistani citizenship, 16 years education, and 5 years work experience",
        "application_deadline": "2027-04-30",
        "deadline_status": "open",
        "source_url": "https://www.dfat.gov.au/people-to-people/australia-awards/australia-awards-scholarships",
        "official_application_url": "https://oasis.dfat.gov.au/",
        "last_checked_at": "2026-10-15",
        "verification_status": "verified",
        "language": "English",
        "status": "published"
    }
]

COUNTRY_GUIDANCES = [
    {
        "country_code": "GBR",
        "country_name": "United Kingdom",
        "flag_emoji": "🇬🇧",
        "overview_text": "The UK is one of the top destinations for Pakistani students, featuring world-leading universities, standardized 1-year Master's programs, and the 2-year Graduate Route post-study work visa.",
        "academic_year": "September – June",
        "application_window": "October (Oxbridge/Medicine) – January (General UCAS/Postgrad)",
        "visa_type_name": "Student Visa (formerly Tier 4)",
        "visa_authority_url": "https://www.gov.uk/student-visa",
        "immigration_portal_url": "https://www.gov.uk/browse/visas-immigration/student-visas",
        "language_of_instruction": "English",
        "language_requirements": "IELTS Academic (typically 6.0 - 7.5), PTE Academic, or approved English proficiency waiver",
        "official_links": [
            {
                "label": "British Council Pakistan",
                "url": "https://www.britishcouncil.pk/study-uk",
                "description": "Official UK higher education counselling and IELTS test operations in Pakistan."
            },
            {
                "label": "UCAS (Universities & Colleges Admissions Service)",
                "url": "https://www.ucas.com/",
                "description": "Centralized undergraduate application portal for UK higher education."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "USA",
        "country_name": "United States",
        "flag_emoji": "🇺🇸",
        "overview_text": "The United States offers over 4,000 accredited universities, extensive STEM OPT extensions (up to 3 years total work authorization), and comprehensive merit and teaching/research assistantship opportunities.",
        "academic_year": "Late August – May",
        "application_window": "November (Early Action/Decision) – January (Regular Decision)",
        "visa_type_name": "F-1 Nonimmigrant Student Visa",
        "visa_authority_url": "https://travel.state.gov/content/travel/en/us-visas/study/student-visa.html",
        "immigration_portal_url": "https://studyinthestates.dhs.gov/",
        "language_of_instruction": "English",
        "language_requirements": "TOEFL iBT (80 - 100+), IELTS Academic (6.5 - 7.5), or Duolingo English Test",
        "official_links": [
            {
                "label": "EducationUSA Pakistan (USEFP)",
                "url": "https://www.usefp.org/educationusa/",
                "description": "Official US Department of State advising network with centres in Islamabad, Lahore, and Karachi."
            },
            {
                "label": "Common App Portal",
                "url": "https://www.commonapp.org/",
                "description": "Undergraduate admissions platform connecting to over 1,000 US colleges."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "CAN",
        "country_name": "Canada",
        "flag_emoji": "🇨🇦",
        "overview_text": "Canada provides internationally recognized degrees with pathways to Post-Graduation Work Permits (PGWP) of up to 3 years, transparent provincial healthcare access, and diverse multicultural campuses.",
        "academic_year": "September – April",
        "application_window": "December – March for Fall Intake",
        "visa_type_name": "Study Permit",
        "visa_authority_url": "https://www.canada.ca/en/immigration-refugees-citizenship/services/study-canada/study-permit.html",
        "immigration_portal_url": "https://www.canada.ca/en/immigration-refugees-citizenship/services/study-canada.html",
        "language_of_instruction": "English / French",
        "language_requirements": "IELTS Academic (minimum 6.0 per band), PTE Core/Academic, or TOEFL iBT",
        "official_links": [
            {
                "label": "EduCanada Official Portal",
                "url": "https://www.educanada.ca/",
                "description": "Official Government of Canada website for international students."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "AUS",
        "country_name": "Australia",
        "flag_emoji": "🇦🇺",
        "overview_text": "Australia is home to the Group of Eight research institutions, offering robust student protections under the ESOS Act, generous temporary graduate post-study work rights, and high standard of student living.",
        "academic_year": "Late February – November (Two Semesters)",
        "application_window": "October – December (Semester 1 Intake) & April – May (Semester 2 Intake)",
        "visa_type_name": "Student Visa (Subclass 500)",
        "visa_authority_url": "https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/student-500",
        "immigration_portal_url": "https://www.studyinaustralia.gov.au/",
        "language_of_instruction": "English",
        "language_requirements": "IELTS Academic (6.0 - 7.0), PTE Academic, or TOEFL iBT",
        "official_links": [
            {
                "label": "Study Australia Official Portal",
                "url": "https://www.studyaustralia.gov.au/",
                "description": "Australian Government official resource for international students."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "DEU",
        "country_name": "Germany",
        "flag_emoji": "🇩🇪",
        "overview_text": "Germany is renowned for zero or nominal tuition fees at public universities, world-class engineering and technical education, and an 18-month job-seeker visa upon graduation.",
        "academic_year": "October – September (Winter and Summer Semesters)",
        "application_window": "Mid-May – July 15 (Winter Semester)",
        "visa_type_name": "National Visa for Study (Visum zur Studienaufnahme)",
        "visa_authority_url": "https://pakistan.diplo.de/pk-en/service/visa-einreise",
        "immigration_portal_url": "https://www.make-it-in-germany.com/en/study-training/studies-in-germany",
        "language_of_instruction": "German / English (over 2,000 international degree programmes in English)",
        "language_requirements": "IELTS 6.5+ for English-taught degrees; TestDaF/Goethe C1 for German-taught degrees",
        "official_links": [
            {
                "label": "DAAD (German Academic Exchange Service)",
                "url": "https://www.daad.de/en/",
                "description": "Official statutory portal for study, degree databases, and German scholarships."
            },
            {
                "label": "Uni-Assist Portal",
                "url": "https://www.uni-assist.de/en/",
                "description": "Central processing service for international university applications in Germany."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "SGP",
        "country_name": "Singapore",
        "flag_emoji": "🇸🇬",
        "overview_text": "Singapore stands as Asia's premier education and research hub, with universities like NUS and NTU consistently ranked among the world's top 20, combined with high safety and modern infrastructure.",
        "academic_year": "August – May",
        "application_window": "October – February for August Intake",
        "visa_type_name": "Student's Pass (STP)",
        "visa_authority_url": "https://www.ica.gov.sg/reside/STP/apply",
        "immigration_portal_url": "https://www.ica.gov.sg/",
        "language_of_instruction": "English",
        "language_requirements": "IELTS (6.5+), TOEFL iBT (90+), or SAT/ACT for undergraduate admissions",
        "official_links": [
            {
                "label": "Singapore Ministry of Education",
                "url": "https://www.moe.gov.sg/post-secondary/admissions",
                "description": "Statutory guidance on university admissions and tuition grants in Singapore."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "TUR",
        "country_name": "Turkey",
        "flag_emoji": "🇹🇷",
        "overview_text": "Turkey offers affordable European Higher Education Area (EHEA) Bologna-compliant degrees, extensive English-taught options, and the prominent Türkiye Bursları government scholarship program.",
        "academic_year": "September – June",
        "application_window": "January – February (Türkiye Bursları) & May – July (Direct University)",
        "visa_type_name": "Student Residence Permit (Öğrenci İkamet İzni)",
        "visa_authority_url": "https://e-ikamet.goc.gov.tr/",
        "immigration_portal_url": "https://en.goc.gov.tr/",
        "language_of_instruction": "Turkish / English",
        "language_requirements": "IELTS / TOEFL or University English Proficiency Exam",
        "official_links": [
            {
                "label": "Study in Türkiye Official Portal",
                "url": "https://www.studyinturkiye.gov.tr/",
                "description": "Council of Higher Education (YÖK) official international student gateway."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "MYS",
        "country_name": "Malaysia",
        "flag_emoji": "🇲🇾",
        "overview_text": "Malaysia is a leading regional education destination with affordable cost of living, branch campuses of UK and Australian universities (e.g. Nottingham, Monash), and high cultural familiarity for Pakistani students.",
        "academic_year": "September – June (Multiple intakes: March, July, October)",
        "application_window": "Rolling applications 2-3 months prior to intake start",
        "visa_type_name": "Student Pass (via EMGS)",
        "visa_authority_url": "https://educationmalaysia.gov.my/",
        "immigration_portal_url": "https://www.imi.gov.my/",
        "language_of_instruction": "English / Malay",
        "language_requirements": "IELTS (5.5 - 6.5) or MUET (Malaysian University English Test)",
        "official_links": [
            {
                "label": "Education Malaysia Global Services (EMGS)",
                "url": "https://educationmalaysia.gov.my/",
                "description": "Official one-stop agency for international student visas and applications."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "NZL",
        "country_name": "New Zealand",
        "flag_emoji": "🇳🇿",
        "overview_text": "New Zealand offers high-quality education across its 8 public universities, stunning natural living environments, and up to 3-year post-study work rights under the Pastoral Care Code.",
        "academic_year": "Late February – November",
        "application_window": "October – December for Semester 1 (February Intake)",
        "visa_type_name": "Fee Paying Student Visa",
        "visa_authority_url": "https://www.immigration.govt.nz/new-zealand-visas/visas/visa/fee-paying-student-visa",
        "immigration_portal_url": "https://www.studywithnewzealand.govt.nz/",
        "language_of_instruction": "English",
        "language_requirements": "IELTS Academic (6.0 - 6.5) or PTE Academic",
        "official_links": [
            {
                "label": "Study with New Zealand",
                "url": "https://www.studywithnewzealand.govt.nz/",
                "description": "Official New Zealand government agency for international education."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "CHE",
        "country_name": "Switzerland",
        "flag_emoji": "🇨🇭",
        "overview_text": "Switzerland boasts top scientific institutions like ETH Zurich and EPFL, exceptionally low tuition fees at public universities, and leadership in cutting-edge research and innovation.",
        "academic_year": "September – June",
        "application_window": "November – April for Autumn Intake",
        "visa_type_name": "National Visa D for Study",
        "visa_authority_url": "https://www.sem.admin.ch/sem/en/home/themen/einreise/visumantragsformular.html",
        "immigration_portal_url": "https://www.studyinswitzerland.plus/",
        "language_of_instruction": "German / French / English",
        "language_requirements": "IELTS (7.0+) or TOEFL (100+) for English-taught master's degrees",
        "official_links": [
            {
                "label": "swissuniversities Official Portal",
                "url": "https://www.swissuniversities.ch/en/",
                "description": "Rector's Conference of Swiss Higher Education Institutions."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "SAU",
        "country_name": "Saudi Arabia",
        "flag_emoji": "🇸🇦",
        "overview_text": "Saudi Arabia offers fully funded research opportunities through institutions like KAUST and King Fahd University of Petroleum & Minerals (KFUPM), providing generous stipends and modern facilities.",
        "academic_year": "September – June",
        "application_window": "October – January for Fall Intake",
        "visa_type_name": "Educational Visa (Study Visa)",
        "visa_authority_url": "https://visa.mofa.gov.sa/",
        "immigration_portal_url": "https://www.studyinsaudi.moe.gov.sa/",
        "language_of_instruction": "English / Arabic",
        "language_requirements": "TOEFL iBT (79+) or IELTS (6.5+) for English programs",
        "official_links": [
            {
                "label": "Study in Saudi Portal",
                "url": "https://www.studyinsaudi.moe.gov.sa/",
                "description": "Ministry of Education platform for international student scholarships in KSA."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "FRA",
        "country_name": "France",
        "flag_emoji": "🇫🇷",
        "overview_text": "France provides heavily state-subsidized tuition at public universities, world-renowned Grandes Écoles, extensive post-study visas, and comprehensive student housing assistance (CAF).",
        "academic_year": "September – June",
        "application_window": "October – December via Études en France",
        "visa_type_name": "Long-Stay Student Visa (VLS-TS)",
        "visa_authority_url": "https://france-visas.gouv.fr/en/web/france-visas/student",
        "immigration_portal_url": "https://www.campusfrance.org/en",
        "language_of_instruction": "French / English (over 1,600 programs taught in English)",
        "language_requirements": "IELTS (6.0 - 6.5) for English programs, DELF/DALF B2/C1 for French programs",
        "official_links": [
            {
                "label": "Campus France Pakistan",
                "url": "https://www.pakistan.campusfrance.org/",
                "description": "Official agency for French higher education promotion in Islamabad and Lahore."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    },
    {
        "country_code": "CHN",
        "country_name": "China",
        "flag_emoji": "🇨🇳",
        "overview_text": "China is a major destination under the CPEC framework, featuring world-class Project 985/Double First Class universities, Chinese Government Scholarships (CSC), and strong engineering/medical faculties.",
        "academic_year": "September – July",
        "application_window": "January – April for Autumn Intake",
        "visa_type_name": "X1 Student Visa (Long Term Study > 180 days)",
        "visa_authority_url": "http://pk.china-embassy.gov.cn/eng/lsfw/va/",
        "immigration_portal_url": "https://www.campuschina.org/",
        "language_of_instruction": "Chinese / English",
        "language_requirements": "HSK 4/5 for Chinese-taught programs; IELTS 6.0+ for English-taught programs",
        "official_links": [
            {
                "label": "China Scholarship Council (CSC)",
                "url": "https://www.campuschina.org/",
                "description": "Official Ministry of Education portal for Chinese Government Scholarships."
            }
        ],
        "last_reviewed_at": "2026-10-15",
        "status": "published"
    }
]

def update_dataset(path: str):
    print(f"[*] Updating {path}...")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    data["scholarships"] = SCHOLARSHIPS
    data["country_guidance"] = COUNTRY_GUIDANCES

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    print(f"    New SHA-256: {h.hexdigest()}")

if __name__ == "__main__":
    update_dataset(BACKEND_PATH)
    update_dataset(MOBILE_PATH)
    print("[V] Both datasets updated successfully!")
