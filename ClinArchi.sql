-- =============================================================================
-- ClinArchi — PostgreSQL Schema (full replacement)
-- Drop old Laravel tables, then create the full ClinArchi data model
-- =============================================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;
 
-- =============================================================================
-- 0. DROP OLD LARAVEL TABLES + any previous ClinArchi tables (clean slate)
-- =============================================================================

DROP TABLE IF EXISTS public.failed_jobs             CASCADE;
DROP TABLE IF EXISTS public.migrations              CASCADE;
DROP TABLE IF EXISTS public.password_reset_tokens   CASCADE;
DROP TABLE IF EXISTS public.personal_access_tokens  CASCADE;
DROP TABLE IF EXISTS public.projects                CASCADE;
DROP TABLE IF EXISTS public.users                   CASCADE;

DROP TABLE IF EXISTS public.room_details            CASCADE;
DROP TABLE IF EXISTS public.unit_values             CASCADE;
DROP TABLE IF EXISTS public.project_departments     CASCADE;
DROP TABLE IF EXISTS public.unit_fields             CASCADE;
DROP TABLE IF EXISTS public.units                   CASCADE;
DROP TABLE IF EXISTS public.departments             CASCADE;
DROP TABLE IF EXISTS public.moroccan_cities         CASCADE;

DROP FUNCTION IF EXISTS public.set_updated_at()    CASCADE;

-- =============================================================================
-- 1. MOROCCAN CITIES  (reference / dropdown list)
-- =============================================================================

CREATE TABLE public.moroccan_cities (
    id   SERIAL       PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO public.moroccan_cities (name) VALUES
    ('Casablanca'), ('Rabat'),       ('Marrakech'),   ('Fes'),         ('Tanger'),
    ('Agadir'),     ('Meknes'),      ('Oujda'),       ('Kenitra'),     ('Tetouan'),
    ('Safi'),       ('El Jadida'),   ('Beni Mellal'), ('Nador'),       ('Mohammedia'),
    ('Settat'),     ('Khemisset'),   ('Berrechid'),   ('Khouribga'),   ('Taza'),
    ('Laayoune'),   ('Dakhla'),      ('Tiznit'),      ('Guelmim'),     ('Ouarzazate'),
    ('Errachidia'), ('Larache'),     ('Al Hoceima'),  ('Taroudant'),   ('Chefchaouen'),
    ('Essaouira'),  ('Ifrane'),      ('Azrou'),       ('Sidi Kacem');

-- =============================================================================
-- 2. DEPARTMENTS  (the 9 type cards shown in the sidebar)
-- =============================================================================

CREATE TABLE public.departments (
    id           SERIAL      PRIMARY KEY,
    code         VARCHAR(60) NOT NULL UNIQUE,   -- exact JS key, e.g. 'HOSPITALISATION'
    label        VARCHAR(100) NOT NULL,
    color_hex    CHAR(7)     NOT NULL,           -- badge / accent colour  e.g. '#1D4ED8'
    light_hex    CHAR(7)     NOT NULL,           -- light bg colour        e.g. '#EFF6FF'
    icon         VARCHAR(10) NOT NULL,
    -- floor-plan rendering meta (PLAN_META in the app)
    floor_color  CHAR(7)     NOT NULL,
    wf_color     CHAR(7)     NOT NULL,
    furniture    VARCHAR(10) NOT NULL CHECK (furniture IN ('beds','equip','chairs','desks','shelves')),
    sort_order   SMALLINT    NOT NULL DEFAULT 0
);

INSERT INTO public.departments
    (code, label, color_hex, light_hex, icon, floor_color, wf_color, furniture, sort_order)
VALUES
    ('HOSPITALISATION',             'Hospitalisation',             '#1D4ED8','#EFF6FF','🛏','#C2E8ED','#A0CCCC','beds',    1),
    ('PLATEAU TECHNIQUE',           'Plateau Technique',           '#5B21B6','#F5F3FF','⚕','#CFC8F0','#A090D0','equip',   2),
    ('AMBULATOIRE',                 'Ambulatoire',                 '#065F46','#ECFDF5','🚶','#C2EDD0','#80BCA0','chairs',  3),
    ('ONCOLOGIE',                   'Oncologie',                   '#991B1B','#FFF1F2','☢','#F0C8C2','#CC8880','chairs',  4),
    ('ADMINISTRATION',              'Administration',              '#78350F','#FFFBEB','🏢','#EDEAD0','#CCBA5A','desks',   5),
    ('LOGISTIQUE',                  'Logistique',                  '#1E293B','#F8FAFC','📦','#D8D8D8','#AAAAAA','shelves', 6),
    ('PHARMACIE',                   'Pharmacie',                   '#9D174D','#FFF0F3','💊','#F0C8DC','#CC88A8','shelves', 7),
    ('HOSPITALISATION GREFFE',      'Hospitalisation Greffe',      '#115E59','#F0FDFA','💉','#B8EDE4','#60C0B0','beds',    8),
    ('HOSPITALISATION HEMATOLOGIE', 'Hospitalisation Hematologie', '#0C4A6E','#F0F9FF','🩸','#C2D8EE','#7AAAD8','beds',    9);

-- =============================================================================
-- 3. UNITS  (functional units inside each department)
-- =============================================================================

CREATE TABLE public.units (
    id            SERIAL       PRIMARY KEY,
    department_id INTEGER      NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    unit_key      VARCHAR(40)  NOT NULL,   -- e.g. 'ward', 'or', 'icu_adult'
    name          VARCHAR(120) NOT NULL,
    sort_order    SMALLINT     NOT NULL DEFAULT 0,
    UNIQUE (department_id, unit_key)
);

-- HOSPITALISATION
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('ward','Unite d''Hospitalisation',1), ('day_medicine','Hopital de Jour - Medecine',2), ('day_surgical','Hopital de Jour - Chirurgie',3))
AS v(k,n,s) WHERE d.code = 'HOSPITALISATION';

-- PLATEAU TECHNIQUE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES
    ('icu_adult','Reanimation adultes (USI)',1), ('icu_peds','Reanimation pediatrique',2),
    ('nicu','Neonatologie (USIN)',3),            ('or','Blocs Operatoires',4),
    ('delivery','Salle d''Accouchement',5),      ('imaging','Imagerie Medicale',6),
    ('emergency','Service des Urgences',7),      ('labs','Laboratoires',8)
) AS v(k,n,s) WHERE d.code = 'PLATEAU TECHNIQUE';

-- AMBULATOIRE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('consultations','Consultations et Explorations',1), ('dental','Service Dentaire',2), ('hemodialysis','Hemodialyse',3))
AS v(k,n,s) WHERE d.code = 'AMBULATOIRE';

-- ONCOLOGIE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('nuclear_med','Medecine Nucleaire',1), ('radiotherapy','Radiotherapie',2), ('chemo','Chimiotherapie',3))
AS v(k,n,s) WHERE d.code = 'ONCOLOGIE';

-- ADMINISTRATION
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('front_office','Accueil et Front Office',1), ('back_office','Direction et Back Office',2))
AS v(k,n,s) WHERE d.code = 'ADMINISTRATION';

-- LOGISTIQUE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('support','Locaux Techniques et Support',1))
AS v(k,n,s) WHERE d.code = 'LOGISTIQUE';

-- PHARMACIE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('pharmacy','Pharmacie',1))
AS v(k,n,s) WHERE d.code = 'PHARMACIE';

-- HOSPITALISATION GREFFE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('transplant','Service Greffe',1))
AS v(k,n,s) WHERE d.code = 'HOSPITALISATION GREFFE';

-- HOSPITALISATION HEMATOLOGIE
INSERT INTO public.units (department_id, unit_key, name, sort_order)
SELECT d.id, v.k, v.n, v.s FROM public.departments d,
(VALUES ('hematology','Hospitalisation Hematologie',1))
AS v(k,n,s) WHERE d.code = 'HOSPITALISATION HEMATOLOGIE';

-- =============================================================================
-- 4. UNIT FIELDS  (every input / checkbox inside each unit card)
--
--  beds_per_unit  : how many beds this field counts per quantity (NULL = none)
--  rooms_per_unit : how many rooms this field counts per quantity (NULL = none)
--  area_m2        : net m2 per unit of this field
--  min_value      : minimum allowed input value
--  default_value  : pre-filled value (NULL = empty)
-- =============================================================================

CREATE TABLE public.unit_fields (
    id             SERIAL        PRIMARY KEY,
    unit_id        INTEGER       NOT NULL REFERENCES public.units(id) ON DELETE CASCADE,
    field_key      VARCHAR(40)   NOT NULL,
    label          VARCHAR(150)  NOT NULL,
    field_type     VARCHAR(10)   NOT NULL CHECK (field_type IN ('number', 'checkbox')),
    beds_per_unit  SMALLINT      DEFAULT NULL,
    rooms_per_unit SMALLINT      DEFAULT NULL,
    area_m2        NUMERIC(6,1)  DEFAULT NULL,
    min_value      SMALLINT      NOT NULL DEFAULT 0,
    default_value  SMALLINT      DEFAULT NULL,
    sort_order     SMALLINT      NOT NULL DEFAULT 0,
    UNIQUE (unit_id, field_key)
);

-- ── ward ─────────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields
    (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,min_value,default_value,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.mn::SMALLINT, v.dv::SMALLINT, v.so::SMALLINT
FROM public.units u,
(VALUES
    ('single_rooms',   'Chambres simples',                 'number',   1,    1,    18.0, 0, NULL, 1),
    ('isolation_rooms','Chambres d''isolement (avec sas)', 'number',   1,    1,    22.0, 0, NULL, 2),
    ('double_rooms',   'Chambres doubles',                 'number',   2,    1,    28.0, 0, NULL, 3),
    ('triple_rooms',   'Chambres triples',                 'number',   3,    1,    36.0, 0, NULL, 4),
    ('en_suite',       'WC + douche privatif',             'checkbox', NULL, NULL, NULL, 0, NULL, 5),
    ('instances',      'Nombre d''unites identiques',      'number',   NULL, NULL, NULL, 1, 1,    6)
) AS v(fk,lb,ft,b,r,m2,mn,dv,so) WHERE u.unit_key = 'ward';

-- ── day_medicine ─────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('day_beds',        'Lits de jour',            'number', 1,    1,   14.0, 1),
    ('treatment_chairs','Fauteuils de traitement', 'number', NULL, 1,    6.0, 2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'day_medicine';

-- ── day_surgical ─────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('day_beds',     'Lits de jour',            'number', 1,    1,   14.0, 1),
    ('recovery_bays','Places de reveil (SSPI)', 'number', NULL, 1,   12.0, 2),
    ('prep_bays',    'Places de preparation',   'number', NULL, 1,   10.0, 3)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'day_surgical';

-- ── icu_adult ─────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('icu_beds',      'Lits de reanimation', 'number', 1, 1,    25.0, 1),
    ('isolation_beds','Lits d''isolement',   'number', 1, 1,    28.0, 2),
    ('open_bays',     'Lits espace ouvert',  'number', 1, NULL, 20.0, 3)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'icu_adult';

-- ── icu_peds ─────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES ('picu_beds','Lits pediatriques','number',1,1,22.0,1))
AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'icu_peds';

-- ── nicu ─────────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('incubators','Places incubateurs','number',1,1,   6.0,1),
    ('open_crib', 'Berceaux ouverts',  'number',1,NULL,4.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'nicu';

-- ── or ───────────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('standard',    'Salles standard',        'number',NULL,1,55.0,1),
    ('hyperaseptic','Salles hyperaseptiques', 'number',NULL,1,65.0,2),
    ('obstetric',   'Salles obstetricales',   'number',NULL,1,55.0,3),
    ('pacu',        'Places SSPI',            'number',NULL,1,12.0,4)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'or';

-- ── delivery ─────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('delivery_rooms', 'Salles d''accouchement','number',NULL,1,30.0,1),
    ('postpartum_beds','Lits post-partum',       'number',1,  1,16.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'delivery';

-- ── imaging ──────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('xray',  'Tables de radiologie',  'number',NULL,1,30.0,1),
    ('ct_32', 'Scanner 32 barrettes',  'number',NULL,1,55.0,2),
    ('ct_128','Scanner 128 barrettes', 'number',NULL,1,60.0,3),
    ('mri_15','IRM 1,5T',              'number',NULL,1,70.0,4)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'imaging';

-- ── emergency ────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('triage',   'Box de triage',       'number',NULL,1,12.0,1),
    ('consult',  'Box de consultation', 'number',NULL,1,14.0,2),
    ('treatment','Box de traitement',   'number',NULL,1,16.0,3),
    ('obs_beds', 'Lits d''observation', 'number',1,   1,14.0,4),
    ('resus',    'Box de reanimation',  'number',NULL,1,20.0,5)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'emergency';

-- ── labs ─────────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('biochemistry',  'Biochimie',             'checkbox',NULL,1,40.0,1),
    ('hematology',    'Hematologie',           'checkbox',NULL,1,35.0,2),
    ('microbiology',  'Microbiologie',         'checkbox',NULL,1,35.0,3),
    ('blood_bank',    'Banque de sang',        'checkbox',NULL,1,30.0,4),
    ('sampling_rooms','Salles de prelevement', 'number',  NULL,1,16.0,5)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'labs';

-- ── consultations ────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('standard', 'Consultation standard',      'number',NULL,1,16.0,1),
    ('gynae',    'Consultation gynecologie',   'number',NULL,1,18.0,2),
    ('ophthalmo','Consultation ophtalmologie', 'number',NULL,1,16.0,3),
    ('ent',      'Consultation ORL',           'number',NULL,1,16.0,4),
    ('gastro',   'Exploration gastro',         'number',NULL,1,35.0,5)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'consultations';

-- ── dental ───────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('chairs',   'Fauteuils dentaires',    'number',NULL,1,14.0,1),
    ('oral_surg','Salle chirurgie buccale','number',NULL,1,30.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'dental';

-- ── hemodialysis ─────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('open_chairs','Fauteuils espace ouvert','number',NULL,1, 6.0,1),
    ('boxes',      'Boxes individuels',       'number',NULL,1,14.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'hemodialysis';

-- ── nuclear_med ──────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('spect_ct','Salles SPECT-TDM','number',NULL,1,55.0,1),
    ('pet_scan', 'Salles TEP-SCAN', 'number',NULL,1,60.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'nuclear_med';

-- ── radiotherapy ─────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('linac_bunkers', 'Bunkers accelerateurs','number',NULL,1,80.0,1),
    ('brachy_bunkers','Bunkers curietherapie', 'number',NULL,1,60.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'radiotherapy';

-- ── chemo ────────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('open_chairs','Fauteuils espace ouvert','number',NULL,1, 6.0,1),
    ('boxes',      'Boxes individuels',       'number',NULL,1,14.0,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'chemo';

-- ── front_office ─────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('admission_desks','Guichets d''admission',  'number',NULL,1,   10.0,1),
    ('billing_offices','Bureaux facturation',     'number',NULL,1,   14.0,2),
    ('waiting_seats',  'Places salle d''attente', 'number',NULL,NULL, 2.0,3)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'front_office';

-- ── back_office ──────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('general_mgmt', 'Bureaux direction', 'number',NULL,1,20.0,1),
    ('hr',           'Bureaux RH',        'number',NULL,1,14.0,2),
    ('meeting_rooms','Salles de reunion', 'number',NULL,1,30.0,3)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'back_office';

-- ── support ──────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('sterilization', 'Sterilisation centrale',   'checkbox',NULL,1,80.0,1),
    ('kitchen',       'Cuisine',                  'checkbox',NULL,1,60.0,2),
    ('laundry',       'Buanderie / Blanchisserie','checkbox',NULL,1,40.0,3),
    ('morgue',        'Morgue',                   'checkbox',NULL,1,30.0,4),
    ('delivery_bays', 'Quais de livraison',        'number', NULL,1,20.0,5),
    ('changing_rooms','Vestiaires personnel',      'number', NULL,1,15.0,6)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'support';

-- ── pharmacy ─────────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('dispensing',   'Guichets de dispensation',  'number',  NULL,1,12.0,1),
    ('storage_rooms','Locaux de stockage',         'number',  NULL,1,20.0,2),
    ('prep_rooms',   'Salles preparation sterile', 'number',  NULL,1,25.0,3),
    ('cytotoxic',    'Salle cytotoxiques',         'checkbox',NULL,1,30.0,4)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'pharmacy';

-- ── transplant ───────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('single_rooms','Chambres individuelles avec sas','number',  1,   1,   28.0,1),
    ('en_suite',    'WC + douche privatif',            'checkbox',NULL,NULL,NULL,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'transplant';

-- ── hematology ───────────────────────────────────────────────────────────────
INSERT INTO public.unit_fields (unit_id,field_key,label,field_type,beds_per_unit,rooms_per_unit,area_m2,sort_order)
SELECT u.id, v.fk, v.lb, v.ft, v.b::SMALLINT, v.r::SMALLINT, v.m2::NUMERIC(6,1), v.so::SMALLINT FROM public.units u,
(VALUES
    ('single_rooms','Chambres individuelles avec sas','number',  1,   1,   28.0,1),
    ('en_suite',    'WC + douche privatif',            'checkbox',NULL,NULL,NULL,2)
) AS v(fk,lb,ft,b,r,m2,so) WHERE u.unit_key = 'hematology';

-- =============================================================================
-- 5. PROJECTS  (one row per saved / generated project)
-- =============================================================================

CREATE TABLE public.projects (
    id               BIGSERIAL     PRIMARY KEY,
    name             VARCHAR(255)  NOT NULL,
    city             VARCHAR(100)  NOT NULL REFERENCES public.moroccan_cities(name)
                         ON UPDATE CASCADE,
    num_floors       SMALLINT      NOT NULL DEFAULT 1 CHECK (num_floors BETWEEN 1 AND 5),
    num_sous_sols    SMALLINT      NOT NULL DEFAULT 0 CHECK (num_sous_sols BETWEEN 0 AND 3),
    parking          VARCHAR(10)   NOT NULL DEFAULT 'non'
                         CHECK (parking IN ('non','oui_ss','oui_ext')),
    terrain_surface  NUMERIC(10,2) DEFAULT NULL,   -- m2, optional
    -- Computed summary totals (from computeSummary)
    total_beds       INTEGER       NOT NULL DEFAULT 0,
    total_rooms      INTEGER       NOT NULL DEFAULT 0,
    total_area_net   INTEGER       NOT NULL DEFAULT 0,   -- m2 net
    total_area_gross INTEGER       NOT NULL DEFAULT 0,   -- m2 brut (~net x 1.35)
    -- AI-generated report text
    report           TEXT          DEFAULT NULL,
    -- Generated-on info (mirrors the history entry)
    generated_date   VARCHAR(20)   DEFAULT NULL,   -- e.g. '31/03/2026'
    generated_time   VARCHAR(10)   DEFAULT NULL,   -- e.g. '14:35'
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- =============================================================================
-- 6. PROJECT_DEPARTMENTS  (which departments are active in a project
--                          + computed totals per department)
-- =============================================================================

CREATE TABLE public.project_departments (
    id             BIGSERIAL  PRIMARY KEY,
    project_id     BIGINT     NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    department_id  INTEGER    NOT NULL REFERENCES public.departments(id),
    -- Per-department computed totals (mirrors summary.byType[type])
    total_beds     INTEGER    NOT NULL DEFAULT 0,
    total_rooms    INTEGER    NOT NULL DEFAULT 0,
    total_area     INTEGER    NOT NULL DEFAULT 0,  -- m2 net
    -- Floor assignment (0 = RDC, 1 = R+1, …) computed by distributeDepts()
    assigned_floor SMALLINT   DEFAULT NULL,
    UNIQUE (project_id, department_id)
);

-- =============================================================================
-- 7. UNIT_VALUES  (the actual numbers/checkboxes the user filled in)
-- =============================================================================

CREATE TABLE public.unit_values (
    id                    BIGSERIAL  PRIMARY KEY,
    project_department_id BIGINT     NOT NULL REFERENCES public.project_departments(id) ON DELETE CASCADE,
    unit_id               INTEGER    NOT NULL REFERENCES public.units(id),
    field_id              INTEGER    NOT NULL REFERENCES public.unit_fields(id),
    -- number fields  → quantity entered (0 = empty / not filled)
    -- checkbox fields → 1 = checked, 0 = unchecked
    int_value             INTEGER    NOT NULL DEFAULT 0,
    UNIQUE (project_department_id, unit_id, field_id)
);

-- =============================================================================
-- 8. ROOM_DETAILS  (pre-computed detail rows for the Surfaces tab,
--                  mirrors summary.byType[type].roomDetail[])
-- =============================================================================

CREATE TABLE public.room_details (
    id                    BIGSERIAL    PRIMARY KEY,
    project_department_id BIGINT       NOT NULL REFERENCES public.project_departments(id) ON DELETE CASCADE,
    unit_id               INTEGER      NOT NULL REFERENCES public.units(id),
    field_id              INTEGER      NOT NULL REFERENCES public.unit_fields(id),
    quantity              INTEGER      NOT NULL DEFAULT 0,
    area_per_unit         NUMERIC(6,1) NOT NULL,
    total_area            NUMERIC(8,1) NOT NULL
);

-- =============================================================================
-- 9. INDEXES
-- =============================================================================

CREATE INDEX idx_units_dept          ON public.units(department_id);
CREATE INDEX idx_fields_unit         ON public.unit_fields(unit_id);
CREATE INDEX idx_pd_project          ON public.project_departments(project_id);
CREATE INDEX idx_pd_department       ON public.project_departments(department_id);
CREATE INDEX idx_uv_pd               ON public.unit_values(project_department_id);
CREATE INDEX idx_uv_unit             ON public.unit_values(unit_id);
CREATE INDEX idx_uv_field            ON public.unit_values(field_id);
CREATE INDEX idx_rd_pd               ON public.room_details(project_department_id);
CREATE INDEX idx_projects_city       ON public.projects(city);
CREATE INDEX idx_projects_created    ON public.projects(created_at DESC);

-- =============================================================================
-- 10. UPDATED_AT TRIGGER
-- =============================================================================

CREATE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_projects_updated_at
BEFORE UPDATE ON public.projects
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
