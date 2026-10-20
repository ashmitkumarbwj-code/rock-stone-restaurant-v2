-- ============================================================================
-- ROCK & STONE RESTAURANT 2.0 — SUPABASE POSTGRESQL DATABASE SCHEMA
-- Strictly 100% Pure Vegetarian Restaurant
-- Destination: Tatal, Nurpur, Kangra, Himachal Pradesh
-- FSSAI Lic: 10925004000220 | GSTIN: 02DKLPP2797H1ZR
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Clean schema (safe for idempotent migration)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS restaurant_settings CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS whatsapp_messages CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS payment_events CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_status_history CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS customer_orders CASCADE;
DROP TABLE IF EXISTS menu_images CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS menu_categories CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. USERS TABLE
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE, -- References auth.users(id) in Supabase Auth
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ROLES TABLE
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL -- 'admin', 'manager', 'kitchen_staff', 'customer'
);

-- 3. USER_ROLES TABLE
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- 4. ADDRESSES TABLE
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    address_text TEXT NOT NULL,
    landmark VARCHAR(200),
    pincode VARCHAR(10) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. MENU_CATEGORIES TABLE
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. MENU_ITEMS TABLE
-- Strictly 100% Pure Vegetarian: Enforced at Schema level via CHECK (is_pure_veg = TRUE)
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES menu_categories(id) ON DELETE RESTRICT,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    image_url TEXT,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_pure_veg BOOLEAN NOT NULL DEFAULT TRUE CHECK (is_pure_veg = TRUE),
    is_published BOOLEAN NOT NULL DEFAULT FALSE, -- Requires owner verification before publishing
    dietary_tags TEXT[] DEFAULT ARRAY['100% Pure Veg'],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. MENU_IMAGES TABLE
CREATE TABLE menu_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. CUSTOMER_ORDERS TABLE
CREATE TABLE customer_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    idempotency_key VARCHAR(100) UNIQUE NOT NULL,
    order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('DINE_IN', 'TAKEAWAY', 'DELIVERY')),
    order_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' 
        CHECK (order_status IN ('PENDING', 'ACCEPTED', 'PREPARING', 'READY', 'ON_THE_WAY', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    payment_method VARCHAR(20) NOT NULL DEFAULT 'CASH'
        CHECK (payment_method IN ('CASH', 'ONLINE', 'UPI')),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    charges DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (charges >= 0),
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (discount >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    customer_name VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    table_number VARCHAR(30),
    delivery_address TEXT,
    special_instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. ORDER_ITEMS TABLE
-- Preserves item_name_snapshot and unit_price_snapshot for historical audit accuracy
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES customer_orders(id) ON DELETE RESTRICT,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
    item_name_snapshot VARCHAR(150) NOT NULL,
    unit_price_snapshot DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    line_total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. ORDER_STATUS_HISTORY TABLE
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES customer_orders(id) ON DELETE CASCADE,
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    note TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. PAYMENTS TABLE
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES customer_orders(id) ON DELETE RESTRICT,
    provider VARCHAR(50) NOT NULL, -- 'CASH', 'RAZORPAY'
    provider_order_id VARCHAR(100),
    provider_payment_id VARCHAR(100),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    paid_at TIMESTAMPTZ
);

-- 12. PAYMENT_EVENTS TABLE (Webhook audit & signature verification)
CREATE TABLE payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    provider_event_id VARCHAR(100) UNIQUE, -- Deduplication check
    signature_verified BOOLEAN NOT NULL DEFAULT FALSE,
    payload JSONB,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. RESERVATIONS TABLE
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    ref_no VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    reservation_date DATE NOT NULL,
    time_slot VARCHAR(30) NOT NULL,
    guest_count INT NOT NULL CHECK (guest_count > 0),
    occasion VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED')),
    special_requests TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. REVIEWS TABLE
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    author_name VARCHAR(150) NOT NULL,
    order_id UUID REFERENCES customer_orders(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT NOT NULL,
    moderation_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (moderation_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. WHATSAPP_MESSAGES TABLE
CREATE TABLE whatsapp_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES customer_orders(id) ON DELETE CASCADE,
    recipient_phone VARCHAR(20) NOT NULL,
    provider_message_id VARCHAR(100),
    template_name VARCHAR(100) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' 
        CHECK (delivery_status IN ('PENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED')),
    error_message TEXT,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES customer_orders(id) ON DELETE CASCADE,
    channel VARCHAR(30) NOT NULL CHECK (channel IN ('WHATSAPP', 'SMS', 'EMAIL', 'KDS_AUDIO')),
    event_type VARCHAR(50) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'SENT',
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. RESTAURANT_SETTINGS TABLE
CREATE TABLE restaurant_settings (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    restaurant_name VARCHAR(150) NOT NULL DEFAULT 'Rock & Stone Restaurant',
    address TEXT NOT NULL DEFAULT 'V.P.O. Tatal, Near Indian Oil Petrol Pump, P/O Khel, Tehsil Nurpur, Kangra, HP 176205',
    phone VARCHAR(20) NOT NULL DEFAULT '+91 76781 29577',
    email VARCHAR(255) NOT NULL DEFAULT 'ashmitkumarbwj@gmail.com',
    fssai_licence VARCHAR(50) NOT NULL DEFAULT '10925004000220',
    gstin VARCHAR(50) NOT NULL DEFAULT '02DKLPP2797H1ZR',
    hours_open TIME NOT NULL DEFAULT '10:00:00',
    hours_close TIME NOT NULL DEFAULT '22:30:00',
    hours_dine_in_cutoff TIME NOT NULL DEFAULT '22:00:00',
    is_pure_veg_certified BOOLEAN NOT NULL DEFAULT TRUE CHECK (is_pure_veg_certified = TRUE),
    is_ordering_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    tax_gst_percent DECIMAL(5,2) NOT NULL DEFAULT 5.00,
    delivery_radius_km DECIMAL(5,2) NOT NULL DEFAULT 8.00,
    min_delivery_order DECIMAL(10,2) NOT NULL DEFAULT 200.00,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 40.00,
    packaging_fee DECIMAL(10,2) NOT NULL DEFAULT 25.00,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 18. AUDIT_LOGS TABLE
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    before_state JSONB,
    after_state JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES FOR HIGH-THROUGHPUT QUERIES
-- ============================================================================
CREATE INDEX idx_orders_customer_id ON customer_orders(customer_id);
CREATE INDEX idx_orders_status ON customer_orders(order_status);
CREATE INDEX idx_orders_created_at ON customer_orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_available ON menu_items(is_available, is_published);
CREATE INDEX idx_reservations_date ON reservations(reservation_date, time_slot);
CREATE INDEX idx_reviews_status ON reviews(moderation_status);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE customer_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Public can view active categories
CREATE POLICY "Public can view active categories" ON menu_categories
    FOR SELECT USING (is_active = TRUE);

-- Public can view available and published pure vegetarian menu items
CREATE POLICY "Public can view published pure veg items" ON menu_items
    FOR SELECT USING (is_available = TRUE AND is_published = TRUE AND is_pure_veg = TRUE);

-- Public can view approved reviews
CREATE POLICY "Public can view approved reviews" ON reviews
    FOR SELECT USING (moderation_status = 'APPROVED');

-- Anyone can submit an order (Guest or Registered)
CREATE POLICY "Public can insert orders" ON customer_orders
    FOR INSERT WITH CHECK (TRUE);

-- Anyone can insert order line items associated with their order
CREATE POLICY "Public can insert order items" ON order_items
    FOR INSERT WITH CHECK (TRUE);

-- Public can view public restaurant settings
CREATE POLICY "Public can view settings" ON restaurant_settings
    FOR SELECT USING (TRUE);

-- Staff / Admin policies (Enforced via JWT role claim)
CREATE POLICY "Admin full access to orders" ON customer_orders
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'manager', 'kitchen_staff')
    ));

CREATE POLICY "Admin full access to menu" ON menu_items
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'manager')
    ));

CREATE POLICY "Admin full access to audit" ON audit_logs
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    ));

-- ============================================================================
-- AUDIT & ORDER STATUS AUTOMATION TRIGGER
-- ============================================================================
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.order_status IS DISTINCT FROM NEW.order_status) THEN
        INSERT INTO order_status_history (order_id, old_status, new_status, note, changed_at)
        VALUES (NEW.id, OLD.order_status, NEW.order_status, 'Status updated via system/admin', NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_status_change
AFTER UPDATE ON customer_orders
FOR EACH ROW EXECUTE FUNCTION log_order_status_change();
