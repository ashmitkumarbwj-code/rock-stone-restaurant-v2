-- ============================================================================
-- ROCK & STONE RESTAURANT 2.0 — DATABASE SEED DATA
-- Strictly 100% Pure Vegetarian Restaurant
-- All sample dishes marked is_published = FALSE awaiting owner menu approval
-- ============================================================================

-- 1. Insert Default Roles
INSERT INTO roles (id, name) VALUES
('a0000000-0000-0000-0000-000000000001', 'admin'),
('a0000000-0000-0000-0000-000000000002', 'manager'),
('a0000000-0000-0000-0000-000000000003', 'kitchen_staff'),
('a0000000-0000-0000-0000-000000000004', 'customer')
ON CONFLICT (name) DO NOTHING;

-- 2. Insert Default Restaurant Settings
INSERT INTO restaurant_settings (
    id, restaurant_name, address, phone, email, fssai_licence, gstin,
    hours_open, hours_close, hours_dine_in_cutoff,
    is_pure_veg_certified, is_ordering_enabled, tax_gst_percent,
    delivery_radius_km, min_delivery_order, delivery_fee, packaging_fee
) VALUES (
    1,
    'Rock & Stone Restaurant',
    'V.P.O. Tatal, Near Indian Oil Petrol Pump, P/O Khel, Tehsil Nurpur, Kangra, HP 176205',
    '+91 76781 29577',
    'ashmitkumarbwj@gmail.com',
    '10925004000220',
    '02DKLPP2797H1ZR',
    '10:00:00',
    '22:30:00',
    '22:00:00',
    TRUE,
    TRUE,
    5.00,
    8.00,
    200.00,
    40.00,
    25.00
) ON CONFLICT (id) DO UPDATE SET
    restaurant_name = EXCLUDED.restaurant_name,
    address = EXCLUDED.address,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    fssai_licence = EXCLUDED.fssai_licence,
    gstin = EXCLUDED.gstin;

-- 3. Insert Menu Categories
INSERT INTO menu_categories (id, name, description, display_order, is_active) VALUES
('c0000000-0000-0000-0000-000000000001', 'Himachali Specialties', 'Traditional Kangra Dham recipes cooked in brassware', 1, TRUE),
('c0000000-0000-0000-0000-000000000002', 'Tandoor & Starters', 'Smoky clay tandoor paneer and vegetable delicacies', 2, TRUE),
('c0000000-0000-0000-0000-000000000003', 'Main Course', 'Rich gravies, slow-cooked dals, and paneer curries', 3, TRUE),
('c0000000-0000-0000-0000-000000000004', 'Breads', 'Fresh clay oven naan, laccha paratha, and tandoori roti', 4, TRUE),
('c0000000-0000-0000-0000-000000000005', 'Beverages', 'Kangra valley organic teas, lassi, and mountain coolers', 5, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Pure Vegetarian Sample Dishes (Marked UNPUBLISHED awaiting owner sign-off)
INSERT INTO menu_items (
    id, category_id, name, description, price, image_url,
    is_available, is_featured, is_pure_veg, is_published, dietary_tags
) VALUES
(
    'm0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'Kangra Madra (Himachali Speciality)',
    'Slow-cooked white chickpeas in rich spiced curd gravy, infused with cardamom, cloves, and whole spices.',
    280.00,
    'assets/images/pure-veg-thali.jpg',
    TRUE, TRUE, TRUE, FALSE, ARRAY['Traditional', 'Gluten-Free']
),
(
    'm0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000002',
    'Clay Tandoor Paneer Tikka',
    'Fresh Himalayan paneer cubes marinated in rich Kashmiri spices and mustard oil, roasted to smoky perfection.',
    320.00,
    'assets/images/paneer-tikka.jpg',
    TRUE, TRUE, TRUE, FALSE, ARRAY['High Protein', 'Gluten-Free']
),
(
    'm0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000003',
    'Dal Dhauladhar (Signature Dal Makhani)',
    'Whole black lentils slow simmered overnight with fresh churned butter and mountain cream.',
    260.00,
    'assets/images/pure-veg-thali.jpg',
    TRUE, TRUE, TRUE, FALSE, ARRAY['Rich & Creamy']
),
(
    'm0000000-0000-0000-0000-000000000004',
    'c0000000-0000-0000-0000-000000000001',
    'Sepu Vadi in Spinach Gravy',
    'Traditional split-urad dumplings prepared in steamed curd & mild aromatic spinach gravy.',
    290.00,
    'assets/images/pure-veg-thali.jpg',
    TRUE, TRUE, TRUE, FALSE, ARRAY['Himachali Dham']
)
ON CONFLICT (id) DO NOTHING;
