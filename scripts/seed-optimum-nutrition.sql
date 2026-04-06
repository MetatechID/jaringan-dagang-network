-- ============================================================
-- Seed: Optimum Nutrition Official Store (Clean Re-seed)
-- Products sourced from Tokopedia Official Store + NaturalFarm.id
-- Prices in IDR from actual Indonesian marketplace data
-- ============================================================

BEGIN;

-- 0. Clean up existing ON data (cascade deletes products -> skus, product_images)
DELETE FROM products WHERE store_id = (SELECT id FROM stores WHERE subscriber_id = 'optimumnutrition.jaringan-dagang.id');
DELETE FROM stores WHERE subscriber_id = 'optimumnutrition.jaringan-dagang.id';
DELETE FROM subscribers WHERE subscriber_id = 'optimumnutrition.jaringan-dagang.id';
-- Clean up old categories that might conflict
DELETE FROM categories WHERE beckn_category_id LIKE 'health-supplements-%';

-- 1. Create subscriber (BPP entry in registry)
INSERT INTO subscribers (subscriber_id, subscriber_url, type, domain, city, signing_public_key, encryption_public_key, status, valid_from, valid_until, created_at, updated_at)
VALUES (
    'optimumnutrition.jaringan-dagang.id',
    'https://jaringan-dagang-seller-api.metatech.id/beckn',
    'BPP',
    'retail',
    'std:021',  -- Jakarta
    'placeholder-signing-key',
    'placeholder-encryption-key',
    'SUBSCRIBED',
    NOW(),
    NOW() + INTERVAL '1 year',
    NOW(),
    NOW()
);

-- 2. Create store
INSERT INTO stores (id, subscriber_id, subscriber_url, name, description, logo_url, domain, city, status, created_at, updated_at)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'optimumnutrition.jaringan-dagang.id',
    'https://jaringan-dagang-seller-api.metatech.id/beckn',
    'Optimum Nutrition Official',
    'World''s #1 Sports Nutrition Brand. Gold Standard Whey Protein, Serious Mass, Amino Energy, Creatine, BCAA & more. Official store for Indonesia.',
    'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-5-lb-double-rich-chocolate-69ae478c2c8df.jpeg',
    'retail',
    'std:021',  -- Jakarta
    'active',
    NOW(),
    NOW()
);

-- 3. Create categories for supplements
INSERT INTO categories (id, name, beckn_category_id, created_at, updated_at) VALUES
    ('c0010001-0001-4000-a000-000000000001', 'Whey Protein',   'health-supplements-whey-protein',   NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000002', 'Mass Gainer',    'health-supplements-mass-gainer',    NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000003', 'Amino Acids',    'health-supplements-amino-acids',    NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000004', 'Creatine',       'health-supplements-creatine',       NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000005', 'Pre-Workout',    'health-supplements-pre-workout',    NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000006', 'BCAA',           'health-supplements-bcaa',           NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000007', 'Plant Protein',  'health-supplements-plant-protein',  NOW(), NOW()),
    ('c0010001-0001-4000-a000-000000000008', 'Vitamins & Supplements', 'health-supplements-vitamins', NOW(), NOW());

-- 4. Create 11 products (consolidating flavor/size variants as SKUs)

-- Product 1: Gold Standard 100% Whey (9 SKU variants)
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000001',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Gold Standard 100% Whey Protein',
    '24g protein per serving with 5.5g naturally occurring BCAAs. Made with whey protein isolate, whey concentrate, and hydrolyzed whey. World''s best-selling whey protein powder. Supports muscle recovery and growth after workouts.',
    'c0010001-0001-4000-a000-000000000001',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "protein_per_serving": "24g", "bcaa": "5.5g", "fat": "1.4g", "sugar": "0.7g"}',
    NOW(), NOW()
);

-- Product 2: Platinum Hydro Whey
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000002',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Platinum Hydro Whey',
    'Advanced hydrolyzed whey protein isolate. 30g protein and 9g BCAAs per serving. Fastest-absorbing whey protein for serious athletes. Ultra-pure, ultra-fast.',
    'c0010001-0001-4000-a000-000000000001',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "protein_per_serving": "30g", "bcaa": "9g", "type": "Hydrolyzed Isolate"}',
    NOW(), NOW()
);

-- Product 3: Serious Mass
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000003',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Serious Mass',
    '1,250 calories and 50g protein per serving. Contains BCAA, glutamine, creatine, and carb powder. High-calorie weight gainer for building muscle mass. Ideal for hard gainers looking to bulk up.',
    'c0010001-0001-4000-a000-000000000002',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "calories_per_serving": 1250, "protein_per_serving": "50g", "type": "Weight Gainer"}',
    NOW(), NOW()
);

-- Product 4: Essential Amino Energy
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000004',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Essential Amino Energy',
    '5g amino acids and 100mg natural caffeine from green tea and coffee per serving. Zero sugar. Supports energy, focus, and recovery anytime. Can be used as a pre-workout or afternoon pick-me-up.',
    'c0010001-0001-4000-a000-000000000003',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "amino_acids": "5g", "caffeine": "100mg", "sugar": "0g", "source": "Green Tea & Coffee"}',
    NOW(), NOW()
);

-- Product 5: Superior Amino 2222 Tablets
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000005',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Superior Amino 2222 Tablets',
    '2,222mg amino acids per tablet with 64mg micronized BCAA blend. Full spectrum of amino acids to support muscle recovery and protein synthesis. Convenient tablet form.',
    'c0010001-0001-4000-a000-000000000003',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "amino_per_tablet": "2222mg", "bcaa_blend": "64mg", "form": "Tablet", "count": 320}',
    NOW(), NOW()
);

-- Product 6: Micronized Creatine Powder
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000006',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Micronized Creatine Powder',
    '5g pure creatine monohydrate per serving. Supports muscle mass, strength, and recovery. Micronized for better mixability. Unflavored, stackable with any supplement.',
    'c0010001-0001-4000-a000-000000000004',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "creatine_per_serving": "5g", "type": "Monohydrate", "form": "Powder"}',
    NOW(), NOW()
);

-- Product 7: Creatine 2500 Capsules
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000007',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Creatine 2500 Capsules',
    '2.5g creatine monohydrate per serving (2 capsules). Fast-release capsule technology. Convenient alternative to powder form. Supports strength and power output.',
    'c0010001-0001-4000-a000-000000000004',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "creatine_per_serving": "2.5g", "form": "Capsule", "count": 100}',
    NOW(), NOW()
);

-- Product 8: Gold Standard Pre-Workout
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000008',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Gold Standard Pre-Workout',
    'Pre-training energy formula with creatine, beta-alanine, caffeine, and B-vitamins. Enhances energy, focus, and endurance for intense workouts. Taken 30 minutes before training.',
    'c0010001-0001-4000-a000-000000000005',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "type": "Pre-Workout", "form": "Powder"}',
    NOW(), NOW()
);

-- Product 9: BCAA Boost
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000009',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'BCAA Boost',
    'BCAA blend with leucine, isoleucine, and valine plus L-citrulline and electrolytes. Supports muscle recovery, reduces fatigue, and maintains hydration during workouts.',
    'c0010001-0001-4000-a000-000000000006',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "bcaa": true, "citrulline": true, "electrolytes": true}',
    NOW(), NOW()
);

-- Product 10: Gold Standard 100% Plant Protein
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000010',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Gold Standard 100% Plant Protein',
    '24g plant-based protein per serving. Vegan and vegetarian friendly. Complete amino acid profile from plant sources. Great taste without artificial sweeteners.',
    'c0010001-0001-4000-a000-000000000007',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "protein_per_serving": "24g", "vegan": true, "type": "Plant Protein"}',
    NOW(), NOW()
);

-- Product 11: Tribulus 625
INSERT INTO products (id, store_id, name, description, category_id, status, attributes, created_at, updated_at) VALUES
(
    'f0010001-0001-4000-b000-000000000011',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Tribulus 625 mg Capsules',
    '625mg tribulus terrestris extract per capsule. Natural testosterone support supplement. Supports male health, vitality, and athletic performance.',
    'c0010001-0001-4000-a000-000000000008',
    'ACTIVE',
    '{"brand": "Optimum Nutrition", "tribulus": "625mg", "form": "Capsule", "type": "Testosterone Support"}',
    NOW(), NOW()
);

-- 5. Create SKUs (prices from Tokopedia/NaturalFarm Indonesia in IDR)
-- price = current sale price, original_price = MSRP before discount

-- Gold Standard 100% Whey - 9 size/flavor variants
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '1 lb Double Rich Chocolate', 'ON-WHEY-1LB-DRC',  430000.00,  695000.00, 100,  454, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '1 lb Vanilla',              'ON-WHEY-1LB-VAN',  430000.00,  695000.00, 100,  454, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '2 lb Double Rich Chocolate', 'ON-WHEY-2LB-DRC',  659000.00, 1150000.00,  80,  907, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '2 lb Vanilla Ice Cream',     'ON-WHEY-2LB-VAN',  659000.00, 1150000.00,  80,  907, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '5 lb Double Rich Chocolate', 'ON-WHEY-5LB-DRC', 1379000.00, 2250000.00,  50, 2270, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '5 lb Vanilla Ice Cream',     'ON-WHEY-5LB-VAN', 1379000.00, 2250000.00,  50, 2270, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '5 lb Strawberry',            'ON-WHEY-5LB-STR', 1379000.00, 2250000.00,  40, 2270, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '10 lb Double Rich Chocolate','ON-WHEY-10LB-DRC', 2629000.00, 4200000.00,  30, 4540, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'Size', '10 lb Vanilla Ice Cream',    'ON-WHEY-10LB-VAN', 2629000.00, 4200000.00,  30, 4540, NOW(), NOW());

-- Platinum Hydro Whey
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000002', 'Size', '3.52 lb Vanilla', 'ON-HYDRO-352-VAN', 1599000.00, 2500000.00, 40, 1600, NOW(), NOW());

-- Serious Mass
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000003', 'Size', '6 lb Chocolate',  'ON-SMASS-6LB-CHO',  769000.00, 1200000.00, 50, 2720, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000003', 'Size', '12 lb Chocolate', 'ON-SMASS-12LB-CHO', 1375000.00, 1800000.00, 30, 5440, NOW(), NOW());

-- Essential Amino Energy
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000004', 'Flavor', '270g Grape', 'ON-AE-270-GRP', 340000.00, 799000.00, 60, 300, NOW(), NOW());

-- Superior Amino 2222
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000005', 'Size', '320 Tablets', 'ON-AMINO2222-320', 639000.00, 950000.00, 50, 500, NOW(), NOW());

-- Micronized Creatine Powder
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000006', 'Size', '300g', 'ON-CREATINE-300', 359000.00, 550000.00, 80, 330, NOW(), NOW());

-- Creatine 2500 Capsules
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000007', 'Size', '100 Capsules', 'ON-CREAT2500-100', 435000.00, 675000.00, 60, 200, NOW(), NOW());

-- Gold Standard Pre-Workout
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000008', 'Flavor', '300g Fruit Punch', 'ON-PREWK-300-FP', 489000.00, 955000.00, 50, 330, NOW(), NOW());

-- BCAA Boost - 2 flavors
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000009', 'Flavor', '390g Watermelon',  'ON-BCAA-390-WM', 470000.00, 999000.00, 50, 420, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000009', 'Flavor', '390g Mango Peach', 'ON-BCAA-390-MP', 470000.00, 999000.00, 50, 420, NOW(), NOW());

-- Gold Standard Plant Protein
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000010', 'Flavor', '1.63 lb / 740g Vanilla', 'ON-PLANT-163-VAN', 629000.00, 1300000.00, 40, 740, NOW(), NOW());

-- Tribulus 625
INSERT INTO skus (id, product_id, variant_name, variant_value, sku_code, price, original_price, stock, weight_grams, created_at, updated_at) VALUES
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000011', 'Size', '100 Capsules', 'ON-TRIB625-100', 369000.00, 500000.00, 60, 150, NOW(), NOW());

-- 6. Create product images (real product images from NaturalFarm CDN)
INSERT INTO product_images (id, product_id, url, position, is_primary, created_at, updated_at) VALUES
    -- Gold Standard Whey - 6 images covering all flavor/size variants
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-5-lb-double-rich-chocolate-69ae478c2c8df.jpeg', 0, true, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-5-lb-vanilla-ice-cream-69ba2919ab4b7.jpeg', 1, false, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-5-lb-strawberry-69b91aab6c86e.jpeg', 2, false, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-2-lb-chocolate-69a9300e55ce0.jpeg', 3, false, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-1-lb-double-rich-chocolate-69b0dcc8e05c3.jpeg', 4, false, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000001', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-whey-gold-standard-10-lb-double-rich-chocolate-69a92bde53bb7.jpeg', 5, false, NOW(), NOW()),

    -- Platinum Hydro Whey
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000002', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-platinum-hydro-whey-vanilla-352-lb-69ae48beb3e25.jpeg', 0, true, NOW(), NOW()),

    -- Serious Mass
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000003', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-serious-mass-6-lb-chocolate-69a7eea4a0b13.jpeg', 0, true, NOW(), NOW()),

    -- Essential Amino Energy
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000004', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-amino-energy-270-gr-grape-exp-date-12-26-69b0e4db06062.jpeg', 0, true, NOW(), NOW()),

    -- Superior Amino 2222
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000005', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-amino-2222-tablet-320-tablets-69a55751928f9.jpeg', 0, true, NOW(), NOW()),

    -- Micronized Creatine Powder
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000006', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-creatine-powder-300-gr-69a6937fb0742.jpeg', 0, true, NOW(), NOW()),

    -- Creatine 2500 Capsules
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000007', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-creatine-2500-100-capsules-69a690795146b.jpeg', 0, true, NOW(), NOW()),

    -- Gold Standard Pre-Workout
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000008', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-pre-workout-fruit-punch-300-gr-69a7de9a6be46.jpeg', 0, true, NOW(), NOW()),

    -- BCAA Boost - 2 flavor images
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000009', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-bcaa-boost-watermelon-390-gr-69a63e9740ccc.jpeg', 0, true, NOW(), NOW()),
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000009', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-bcaa-boost-mango-peach-390-gr-69a63e568a381.jpeg', 1, false, NOW(), NOW()),

    -- Gold Standard Plant Protein
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000010', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-gold-standard-plant-protein-vanilla-163-lb-740-gr-69a6a3deaa19d.jpeg', 0, true, NOW(), NOW()),

    -- Tribulus 625
    (gen_random_uuid(), 'f0010001-0001-4000-b000-000000000011', 'https://naturalfarm.sgp1.cdn.digitaloceanspaces.com/uploads/products/optimum-nutrition-tribulus-625-mg-caps-69a9281aa8644.jpeg', 0, true, NOW(), NOW());

COMMIT;
