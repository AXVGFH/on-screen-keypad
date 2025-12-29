
-- كود بديل أبسط لحذف جميع الجداول
--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public;
-- init.sql - مصحح ومبسط
-- إعدادات أولية آمنة
ALTER SYSTEM SET listen_addresses = '*';
ALTER SYSTEM SET max_connections = 200;
SELECT pg_reload_conf();

-- الانتظار قليلاً لتطبيق الإعدادات
SELECT pg_sleep(2);

-- 1. إعادة تعيين الصلاحيات الأساسية
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- 2. إنشاء/تعديل المستخدم anon
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE USER anon WITH PASSWORD 'anon';
    ELSE
        ALTER USER anon WITH PASSWORD 'anon';
    END IF;
    
    -- صلاحيات الاتصال
    GRANT CONNECT ON DATABASE postgres TO anon;
    
    -- صلاحيات schema
    GRANT USAGE ON SCHEMA public TO anon;
    
    -- تمكين LOGIN
    ALTER USER anon WITH LOGIN;
    
    -- صلاحيات كاملة للجداول الحالية
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;
    
    -- صلاحيات التسلسلات
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
    
    -- صلاحيات للجداول المستقبلية
    ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT ON SEQUENCES TO anon;
    
    RAISE NOTICE '✅ تم إعداد المستخدم anon بنجاح';
END $$;

-- 3. صلاحيات لجميع المستخدمين (PUBLIC)
GRANT USAGE ON SCHEMA public TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT USAGE, SELECT ON SEQUENCES TO PUBLIC;

-- 4. إنشاء جدول تجريبي
CREATE TABLE IF NOT EXISTS public.test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. بيانات تجريبية
INSERT INTO public.test_table (name) 
VALUES ('Test 1'), ('Test 2'), ('Test 3')
ON CONFLICT DO NOTHING;

-- 6. تأكيد التهيئة
SELECT '✅ تم تهيئة قاعدة البيانات بنجاح' AS message;

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
    CREATE USER anon WITH PASSWORD 'anon';
  END IF;
END
$$;
-- منح صلاحية التسجيل
ALTER USER anon WITH LOGIN;

-- منح الصلاحيات على schema public
GRANT USAGE ON SCHEMA public TO anon;

-- منح الصلاحيات على جميع الجداول الحالية
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;

-- منح الصلاحيات على جميع التسلسلات الحالية
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;

-- تعديل الإعدادات الافتراضية للجداول المستقبلية
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon;

-- تعديل الإعدادات الافتراضية للتسلسلات المستقبلية
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO anon;

-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.


-- إصلاح كامل للمستخدم anon مع جميع الصلاحيات المطلوبة
DO $$
BEGIN
    -- إنشاء المستخدم إذا لم يكن موجوداً
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE USER anon WITH PASSWORD 'anon';
    END IF;
    
    -- منح صلاحيات الاتصال
    GRANT CONNECT ON DATABASE postgres TO anon;
    
    -- منح صلاحيات الـ schema
    GRANT USAGE ON SCHEMA public TO anon;
    GRANT CREATE ON SCHEMA public TO anon;
    
    -- منح صلاحيات الجداول
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;
    
    -- منح صلاحيات التسلسلات
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
    
    -- منح صلاحيات الدوال
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon;
    
    -- صلاحيات للجداول والتسلسلات المستقبلية
    ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT ON SEQUENCES TO anon;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT EXECUTE ON FUNCTIONS TO anon;
    
    RAISE NOTICE 'تم إعداد المستخدم anon بنجاح مع جميع الصلاحيات';
END $$;
-- منح جميع الصلاحيات لجميع المستخدمين على جميع الجداول الحالية والمستقبلية

-- 1. منح صلاحيات على الـ schema
GRANT USAGE ON SCHEMA public TO PUBLIC;

-- 2. منح صلاحيات CRUD كاملة على جميع الجداول الحالية
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO PUBLIC;

-- 3. منح صلاحيات على جميع التسلسلات الحالية
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

-- 4. منح صلاحيات تنفيذ جميع الدوال
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO PUBLIC;

-- 5. منح صلاحيات للجداول المستقبلية (Default Privileges)
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO PUBLIC;

-- 6. منح صلاحيات للتسلسلات المستقبلية
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT USAGE, SELECT ON SEQUENCES TO PUBLIC;

-- 7. منح صلاحيات للدوال المستقبلية
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT EXECUTE ON FUNCTIONS TO PUBLIC;

-- 8. منح صلاحيات إنشاء جداول مؤقتة (لجلسات العمل)
GRANT TEMPORARY ON DATABASE postgres TO PUBLIC;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "job_details" (
    "id" SERIAL PRIMARY KEY,
    "id_job" INTEGER,
    "users_manager" INTEGER,
    "useradd" INTEGER,
    "useredit" INTEGER,
    "userdelete" INTEGER,
    "user_view" INTEGER,
    "jobs_manager" INTEGER,
    "jobadd" INTEGER,
    "jobedit" INTEGER,
    "jobdelete" INTEGER,
    "job_view" INTEGER,
    "viewprofit" INTEGER,
    "customers_d" INTEGER,
    "customeradd" INTEGER,
    "customeredit" INTEGER,
    "customerdelete" INTEGER,
    "customer_view" INTEGER,
    "supplies_d" INTEGER,
    "supplieradd" INTEGER,
    "supplieredit" INTEGER,
    "supplierdelete" INTEGER,
    "supplier_view" INTEGER,
    "sales_d" INTEGER,
    "saleaddpos" INTEGER,
    "saleadd" INTEGER,
    "saleedit" INTEGER,
    "saledelete" INTEGER,
    "sale_view" INTEGER,
    "return_sales_d" INTEGER,
    "return_saleadd" INTEGER,
    "return_saleedit" INTEGER,
    "return_saledelete" INTEGER,
    "return_sale_view" INTEGER,
    "deliveries_d" INTEGER,
    "deliveryadd" INTEGER,
    "deliveryedit" INTEGER,
    "deliverydelete" INTEGER,
    "delivery_view" INTEGER,
    "purchases_d" INTEGER,
    "purchaseadd" INTEGER,
    "purchaseedit" INTEGER,
    "purchasedelete" INTEGER,
    "purchase_view" INTEGER,
    "return_purchases_d" INTEGER,
    "return_purchaseadd" INTEGER,
    "return_purchaseedit" INTEGER,
    "return_purchasedelete" INTEGER,
    "return_purchase_view" INTEGER,
    "expansives_d" INTEGER,
    "expansiveadd" INTEGER,
    "expansiveedit" INTEGER,
    "expansivedelete" INTEGER,
    "expansive_view" INTEGER,
    "expansive_categories_d" INTEGER,
    "expansive_categoryadd" INTEGER,
    "expansive_categoryedit" INTEGER,
    "expansive_categorydelete" INTEGER,
    "expansive_category_view" INTEGER,
    "items_d" INTEGER,
    "itemadd" INTEGER,
    "itemedit" INTEGER,
    "itemdelete" INTEGER,
    "item_view" INTEGER,
    "accounttype_d" INTEGER,
    "accounttypeadd" INTEGER,
    "accounttypeedit" INTEGER,
    "accounttypedelete" INTEGER,
    "accounttype_view" INTEGER,
    "account_d" INTEGER,
    "accountadd" INTEGER,
    "accountedit" INTEGER,
    "accountdelete" INTEGER,
    "iaccount_view" INTEGER,
    "accounttran_d" INTEGER,
    "accounttranadd" INTEGER,
    "accounttranedit" INTEGER,
    "accounttrandelete" INTEGER,
    "iaccounttran_view" INTEGER,
    "accountde_d" INTEGER,
    "accountdeadd" INTEGER,
    "accountdeedit" INTEGER,
    "accountdedelete" INTEGER,
    "iaccountde_view" INTEGER,
    "stock_d" INTEGER,
    "stockadd" INTEGER,
    "stockedit" INTEGER,
    "stockdelete" INTEGER,
    "stock_view" INTEGER,
    "tax_d" INTEGER,
    "taxadd" INTEGER,
    "taxedit" INTEGER,
    "taxdelete" INTEGER,
    "tax_view" INTEGER,
    "paytype_d" INTEGER,
    "paycity_d" INTEGER,
    "paytypeadd" INTEGER,
    "paytypeedit" INTEGER,
    "paytypedelete" INTEGER,
    "avaliblestock" INTEGER,
    "paycityadd" INTEGER,
    "paycityedit" INTEGER,
    "paycitydelete" INTEGER,
    "symbol_d" INTEGER,
    "symboladd" INTEGER,
    "symboledit" INTEGER,
    "symboldelete" INTEGER,
    "symbol_view" INTEGER,
    "stockchange_d" INTEGER,
    "stockchangeadd" INTEGER,
    "stockchangeedit" INTEGER,
    "stockchangedelete" INTEGER,
    "stockchange_view" INTEGER,
    "stocktransfer_d" INTEGER,
    "stocktransferadd" INTEGER,
    "stocktransferedit" INTEGER,
    "stocktransferdelete" INTEGER,
    "stocktransfer_view" INTEGER,
    "itemstype_d" INTEGER,
    "itemtypeadd" INTEGER,
    "itemtypeedit" INTEGER,
    "itemtypedelete" INTEGER,
    "item_typeview" INTEGER,
    "items_brands_d" INTEGER,
    "items_brandadd" INTEGER,
    "items_brandedit" INTEGER,
    "items_branddelete" INTEGER,
    "items_brand_view" INTEGER,
    "items_subcategories_d" INTEGER,
    "items_subcategoryadd" INTEGER,
    "items_subcategoryedit" INTEGER,
    "items_subcategorydelete" INTEGER,
    "items_subcategory_view" INTEGER,
    "items_maincategories_d" INTEGER,
    "items_maincategoryadd" INTEGER,
    "items_maincategoryedit" INTEGER,
    "items_maincategorydelete" INTEGER,
    "items_maincategory_view" INTEGER,
    "items_countries_d" INTEGER,
    "items_countryadd" INTEGER,
    "items_countryedit" INTEGER,
    "items_countrydelete" INTEGER,
    "items_country_view" INTEGER,
    "items_cities_d" INTEGER,
    "items_cityadd" INTEGER,
    "items_cityedit" INTEGER,
    "items_citydelete" INTEGER,
    "items_city_view" INTEGER,
    "barcode_printer" INTEGER,
    "setting" INTEGER,
    "setting_company" INTEGER,
    "report_profitandloss_view" INTEGER,
    "report_users_view" INTEGER,
    "report_supplier_view" INTEGER,
    "report_customer_view" INTEGER,
    "report_sales_view" INTEGER,
    "report_return_sales_view" INTEGER,
    "report_purchase_view" INTEGER,
    "report_return_purchase_view" INTEGER,
    "report_delivery_view" INTEGER,
    "report_item_view" INTEGER,
    "report_expansive_view" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS "Notifications" (
    "id" SERIAL PRIMARY KEY,
    "title" TEXT,
    "message" TEXT,
    "isRead" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "account" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "balance" REAL,
    "note" TEXT,
    "userid" INTEGER,
    "account_id" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "account_type" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "date" TEXT,
    "userid" INTEGER,
    "note" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "accountdebitcode" (
    "id" SERIAL PRIMARY KEY,
    "code" TEXT,
    "balance" REAL,
    "note" TEXT,
    "userid" INTEGER,
    "accountdebit_id" INTEGER,
    "accounttransf_id" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "accounts_cash" (
    "id" SERIAL PRIMARY KEY,
    "price" REAL,
    "id_account" INTEGER,
    "userid" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "accounttrans" (
    "id" SERIAL PRIMARY KEY,
    "code" TEXT,
    "balance" REAL,
    "note" TEXT,
    "userid" INTEGER,
    "accountdebit_id" INTEGER,
    "accounttransf_id" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "additions" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "price" REAL,
    "note" TEXT,
    "userid" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "additions_items" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "itemid" INTEGER,
    "additionid" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "addon_options" (
    "id" SERIAL PRIMARY KEY,
    "addon_id" INTEGER,
    "name" TEXT NOT NULL,
    "extra_price" REAL DEFAULT 0.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "addons" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "price" REAL DEFAULT 0.0,
    "has_options" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "batch_balance" (
    "id" SERIAL PRIMARY KEY,
    "item_id" INTEGER NOT NULL,
    "stock_id" INTEGER NOT NULL,
    "expirydate" TEXT,
    "quantity" REAL DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "batches" (
    "id" SERIAL PRIMARY KEY,
    "item_id" INTEGER NOT NULL,
    "stock_id" INTEGER NOT NULL,
    "purchase_detail_id" INTEGER NOT NULL,
    "expiry_date" TEXT,
    "quantity" REAL DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "batches1" (
    "id" SERIAL PRIMARY KEY,
    "item_id" INTEGER NOT NULL,
    "stock_id" INTEGER NOT NULL,
    "purchase_detail_id" INTEGER NOT NULL UNIQUE,
    "expiry_date" TEXT,
    "quantity" REAL NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "brand" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "date" TEXT,
    "userid" INTEGER,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "change_stock" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "note" TEXT,
    "id_stock" INTEGER,
    "date" TEXT,    "invoice_code" TEXT UNIQUE NOT NULL,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "change_stock_details" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "id_stock" INTEGER,
    "purchase_detail_id" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "unit_name" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "change_type" (
    "id" SERIAL PRIMARY KEY,
    "type" TEXT,
    "note" TEXT,
    "userid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "city" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "country_id" INTEGER,
    "user_id" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "citypay" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "date" TEXT,
    "price" REAL,
    "country_id" INTEGER,
    "city_id" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "country" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "date" TEXT,
    "userid" INTEGER,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "customer_pay" (
    "id" SERIAL PRIMARY KEY,
    "code" TEXT,
    "pay" REAL,
    "note" TEXT,
    "userid" INTEGER,
    "customer_id" INTEGER,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "customers" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "number_phone" TEXT,
    "cityid" INTEGER,
    "countryid" INTEGER,
    "address" TEXT,
    "is_active" INTEGER,
    "date" TEXT,
    "userid" INTEGER,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
   
CREATE TABLE IF NOT EXISTS "delivery" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "number_phone" TEXT,
    "address" TEXT,
    "userid" INTEGER,
    "is_active" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "expansive" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "for_who" TEXT,
    "price" REAL,
    "note" TEXT,
    "category_id" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "account_id" INTEGER,
    "userid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "expansive_category" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "userid" INTEGER,
    "note" TEXT,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "inventory" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "userid" INTEGER,
    "countryid" INTEGER,
    "cityid" INTEGER,
    "date" TEXT,
    "phoneNumber" TEXT,
    "adress" TEXT,
    "email" TEXT,
    "note" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "item_addons" (
    "id" SERIAL PRIMARY KEY,
    "item_id" INTEGER,
    "addon_id" INTEGER,
    "is_required" INTEGER DEFAULT 0,
    "max_select" INTEGER DEFAULT 1,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "item_units" (
    "id" SERIAL PRIMARY KEY,
    "item_id" INTEGER NOT NULL,
    "unit_name" TEXT NOT NULL,
    "base_qty" REAL NOT NULL,
    "sell_price" REAL NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "items" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "id_subcategory" INTEGER,
    "id_maincategory" INTEGER,
    "id_brand" INTEGER,
    "id_country" INTEGER,
    "id_taxs" INTEGER,
    "userid" INTEGER,
    "is_item" INTEGER DEFAULT 1,
    "is_active" INTEGER,
    "alert_qty" REAL,
    "id_itemtype" INTEGER,
    "discount_type" INTEGER,
    "discount_value" REAL,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "date" TEXT,
    "barcode" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "image" TEXT,
    "is_wholesale" INTEGER DEFAULT 0,
    "has_units" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "items_maincategory" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "is_active" INTEGER,
    "userid" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "jobs" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "description" TEXT,
    "is_active" INTEGER DEFAULT 1,
    "id_jobdetail" INTEGER,
    "datetime" TEXT,
    "time" TEXT,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "ketchine" (
    "id" SERIAL PRIMARY KEY,
    "invoice_code" TEXT,
    "userid" INTEGER,
    "id_customer" INTEGER,
    "id_delivery" INTEGER,
    "note" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "id_stock" INTEGER,
    "account_id" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "id_table" INTEGER,
    "status" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "ketchine_detals" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "purchase_detail_id" INTEGER,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "note" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "my_table" (
    "id" SERIAL PRIMARY KEY,
    "date" TEXT NOT NULL,
    "carace" TEXT,
    "name" TEXT NOT NULL,
    "userid" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "papers" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "width" REAL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "pay_types" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "date" TEXT,
    "note" TEXT,
    "is_active" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "payments" (
    "id" SERIAL PRIMARY KEY,
    "code" TEXT,
    "type" TEXT,
    "price" REAL,
    "note" TEXT,
    "date" TEXT,
    "paytype_id" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "purchase_details" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "purchase_detail_id" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "unit_name" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "purchase_details_timer" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "purchase_detail_id" INTEGER,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "purchases" (
    "id" SERIAL PRIMARY KEY,
    "invoice_code" TEXT UNIQUE NOT NULL,
    "userid" INTEGER,
    "id_supplier" INTEGER,
    "charge_price" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "date" TEXT,
    "id_stock" INTEGER,
    "time" TEXT,
    "account_id" INTEGER,
    "taxid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "purchases_timer" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "id_supplier" INTEGER,
    "id_stock" INTEGER,
    "note" TEXT,
    "date" TEXT,
    "time" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "return_purchase_detals" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "purchase_detail_id" INTEGER,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "unit_name" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "return_purchases" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "id_supplier" INTEGER,
    "invoice_code" TEXT UNIQUE NOT NULL,
    "purchase_id" INTEGER,
    "charge_price" REAL,
    "note" TEXT,
    "date" TEXT,
    "id_stock" INTEGER,
    "time" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "account_id" INTEGER,
    "taxid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "return_sales" (
    "id" SERIAL PRIMARY KEY,    "invoice_code" TEXT UNIQUE NOT NULL,
    "sales_id" INTEGER,
    "userid" INTEGER,
    "id_customer" INTEGER,
    "id_delivery" INTEGER,
    "date" TEXT,
    "note" TEXT,
    "time" TEXT,
    "account_id" INTEGER,
    "id_stock" INTEGER,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "return_sales_detals" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "purchase_detail_id" INTEGER,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "note" TEXT,
    "unit_name" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "sales" (
    "id" SERIAL PRIMARY KEY,
    "invoice_code" TEXT,
    "userid" INTEGER,
    "id_customer" INTEGER,
    "id_delivery" INTEGER,
    "note" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "id_stock" INTEGER,
    "account_id" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "status" TEXT,
    "id_table" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "sales_detals" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "purchase_detail_id" INTEGER,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "note" TEXT,
    "unit_name" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "sales_detals_timers" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "purchase_detail_id" INTEGER,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "sales_view" (
    "id" SERIAL PRIMARY KEY,
    "invoice_code" TEXT,
    "userid" INTEGER,
    "id_customer" INTEGER,
    "id_delivery" INTEGER,
    "note" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "id_stock" INTEGER,
    "account_id" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "sales_view_detals" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "price" REAL,
    "sell" REAL,
    "purchase_detail_id" INTEGER,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "salestimers" (
    "id" SERIAL PRIMARY KEY,    "invoice_code" TEXT UNIQUE NOT NULL,
    "id_customer" INTEGER,
    "note" TEXT,
    "id_stock" INTEGER,
"userid" INTEGER,
    "date" TEXT,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "setting" (
    "id" SERIAL PRIMARY KEY,
    "language" TEXT,
    "story_name" TEXT,
    "story_phone" TEXT,
    "story_email" TEXT,
    "story_fb" TEXT,
    "story_instgram" TEXT,
    "story_x" TEXT,
    "story_adress" TEXT,
    "story_logo" TEXT,
    "sales_qty_real" REAL,
    "sales_price_real" REAL,
    "sales_footer_text" TEXT,
    "sales_rules_text" TEXT,
    "show_rules_pos" INTEGER,
    "show_rules_invoice" INTEGER,
    "show_footer_pos" INTEGER,
    "show_footer_invoice" INTEGER,
    "symbol_before_after_price" INTEGER,
    "symbol" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "stock" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_inventory" INTEGER,
    "qty" REAL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "stock_users" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "id_stock" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "subcategory" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "maincategory_id" INTEGER,
    "is_active" INTEGER,
    "userid" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "suppliers" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "number_phone" TEXT,
    "address" TEXT,
    "cityid" INTEGER,
    "countryid" INTEGER,
    "userid" INTEGER,
    "is_active" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "symbols" (
    "id" SERIAL PRIMARY KEY,
    "currency_symbol" TEXT,
    "cny" TEXT,
    "country" TEXT,
    "date" TEXT,
    "time" TEXT,
    "userid" INTEGER,
    "is_active" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
    

CREATE TABLE IF NOT EXISTS "tables" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "corace" TEXT,
    "date" TEXT,
    "userid" INTEGER,
    "type" TEXT,
    "value" REAL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "taxs" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "note" TEXT,
    "date" TEXT,
    "userid" INTEGER,
    "type" INTEGER,
    "value" REAL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "taxs_min" (
    "id" SERIAL PRIMARY KEY,
    "code" TEXT,
    "paytype_id" INTEGER,
    "id_taxs" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "transf_stock" (
    "id" SERIAL PRIMARY KEY,
    "userid" INTEGER,
    "id_from_stock" INTEGER,
    "id_to_stock" INTEGER,
    "date" TEXT,    "invoice_code" TEXT UNIQUE NOT NULL,
    "note" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "transf_stock_details" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER,
    "id_invoice_code" INTEGER,
    "qty" REAL,
    "value_dic" REAL,
    "type_dic" INTEGER,
    "taxid" INTEGER,
    "purchase_detail_id" INTEGER,
    "price" REAL,
    "sell" REAL,
    "expirydate" TEXT,
    "barcode1" TEXT,
    "barcode2" TEXT,
    "barcode3" TEXT,
    "barcode4" TEXT,
    "barcode5" TEXT,
    "barcode6" TEXT,
    "unit_name" TEXT,
    "unit_base_qty" REAL DEFAULT 1.0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "type_items" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "note" TEXT,
    "date" TEXT,
    "time" TEXT,
    "userid" INTEGER,
    "is_active" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "users" (
    "id" SERIAL PRIMARY KEY,
    "password" TEXT,
    "username" TEXT,
    "defaultstock" TEXT,
    "name" TEXT,
    "id_job" INTEGER,
    "image" TEXT,
    "userid" INTEGER,
    "is_active" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "wholesale_prices" (
    "id" SERIAL PRIMARY KEY,
    "id_item" INTEGER NOT NULL,
    "min_qty" REAL NOT NULL,
    "sell_price" REAL NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);




DO $$ 
BEGIN 
  IF EXISTS (SELECT 1 FROM "users" WHERE "id" = 0) THEN
    UPDATE "users" SET
      "password" = 'RIm2joXk/pziVWCe+CC1fw==',
      "username" = 'المسؤول',
      "defaultstock" = NULL,
      "name" = 'المسؤول',
      "id_job" = 0,
      "image" = NULL,
      "userid" = 0,
      "is_active" = 1,
      "date" = NULL,
      "time" = NULL
    WHERE "id" = 0;
  ELSE
    INSERT INTO "users" ("id","password","username","defaultstock","name","id_job","image","userid","is_active","date","time") 
    VALUES 
    (0,'RIm2joXk/pziVWCe+CC1fw==','المسؤول',NULL,'المسؤول',0,NULL,0,1,NULL,NULL);
  END IF;
END $$;




INSERT INTO "jobs" ("id","name","description","is_active","id_jobdetail","datetime","time","date") VALUES 
(0,'المسؤول',NULL,1,0,NULL,NULL,NULL);

INSERT INTO "job_details" ("id","id_job","users_manager","useradd","useredit","userdelete","user_view","jobs_manager","jobadd","jobedit","jobdelete","job_view","viewprofit","customers_d","customeradd","customeredit","customerdelete","customer_view","supplies_d","supplieradd","supplieredit","supplierdelete","supplier_view","sales_d","saleaddpos","saleadd","saleedit","saledelete","sale_view","return_sales_d","return_saleadd","return_saleedit","return_saledelete","return_sale_view","deliveries_d","deliveryadd","deliveryedit","deliverydelete","delivery_view","purchases_d","purchaseadd","purchaseedit","purchasedelete","purchase_view","return_purchases_d","return_purchaseadd","return_purchaseedit","return_purchasedelete","return_purchase_view","expansives_d","expansiveadd","expansiveedit","expansivedelete","expansive_view","expansive_categories_d","expansive_categoryadd","expansive_categoryedit","expansive_categorydelete","expansive_category_view","items_d","itemadd","itemedit","itemdelete","item_view","accounttype_d","accounttypeadd","accounttypeedit","accounttypedelete","accounttype_view","account_d","accountadd","accountedit","accountdelete","iaccount_view","accounttran_d","accounttranadd","accounttranedit","accounttrandelete","iaccounttran_view","accountde_d","accountdeadd","accountdeedit","accountdedelete","iaccountde_view","stock_d","stockadd","stockedit","stockdelete","stock_view","tax_d","taxadd","taxedit","taxdelete","tax_view","paytype_d","paycity_d","paytypeadd","paytypeedit","paytypedelete","avaliblestock","paycityadd","paycityedit","paycitydelete","symbol_d","symboladd","symboledit","symboldelete","symbol_view","stockchange_d","stockchangeadd","stockchangeedit","stockchangedelete","stockchange_view","stocktransfer_d","stocktransferadd","stocktransferedit","stocktransferdelete","stocktransfer_view","itemstype_d","itemtypeadd","itemtypeedit","itemtypedelete","item_typeview","items_brands_d","items_brandadd","items_brandedit","items_branddelete","items_brand_view","items_subcategories_d","items_subcategoryadd","items_subcategoryedit","items_subcategorydelete","items_subcategory_view","items_maincategories_d","items_maincategoryadd","items_maincategoryedit","items_maincategorydelete","items_maincategory_view","items_countries_d","items_countryadd","items_countryedit","items_countrydelete","items_country_view","items_cities_d","items_cityadd","items_cityedit","items_citydelete","items_city_view","barcode_printer","setting","setting_company","report_profitandloss_view","report_users_view","report_supplier_view","report_customer_view","report_sales_view","report_return_sales_view","report_purchase_view","report_return_purchase_view","report_delivery_view","report_item_view","report_expansive_view") VALUES 
(0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


-- رسالة نجاح
DO $$ 
BEGIN
  RAISE NOTICE '✅ تم إنشاء النظام بنجاح!';
    RAISE NOTICE '📊 تم إنشاء % وظائف و % مستخدمين و % صلاحية', 
  (SELECT COUNT(*) FROM jobs),
   (SELECT COUNT(*) FROM users),
      (SELECT COUNT(*) FROM job_details);
END $$;

COMMIT;


-- =============================================
-- إنشاء نظام إدارة متكامل
-- =============================================

-- جدول الوظائف
CREATE TABLE IF NOT EXISTS "jobs" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT,
    "description" TEXT,
    "is_active" INTEGER DEFAULT 1,
    "id_jobdetail" INTEGER,
    "datetime" TEXT,
    "time" TEXT,
    "date" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS "users" (
    "id" SERIAL PRIMARY KEY,
    "password" TEXT,
    "username" TEXT,
    "defaultstock" TEXT,
    "name" TEXT,
    "id_job" INTEGER,
    "image" TEXT,
    "userid" INTEGER,
    "is_active" INTEGER,
    "date" TEXT,
    "time" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول تفاصيل الصلاحيات
CREATE TABLE IF NOT EXISTS "job_details" (
    "id" SERIAL PRIMARY KEY,
    "id_job" INTEGER,
    "users_manager" INTEGER,
    "useradd" INTEGER,
    "useredit" INTEGER,
    "userdelete" INTEGER,
    "user_view" INTEGER,
    "jobs_manager" INTEGER,
    "jobadd" INTEGER,
    "jobedit" INTEGER,
    "jobdelete" INTEGER,
    "job_view" INTEGER,
    "viewprofit" INTEGER,
    "customers_d" INTEGER,
    "customeradd" INTEGER,
    "customeredit" INTEGER,
    "customerdelete" INTEGER,
    "customer_view" INTEGER,
    "supplies_d" INTEGER,
    "supplieradd" INTEGER,
    "supplieredit" INTEGER,
    "supplierdelete" INTEGER,
    "supplier_view" INTEGER,
    "sales_d" INTEGER,
    "saleaddpos" INTEGER,
    "saleadd" INTEGER,
    "saleedit" INTEGER,
    "saledelete" INTEGER,
    "sale_view" INTEGER,
    "return_sales_d" INTEGER,
    "return_saleadd" INTEGER,
    "return_saleedit" INTEGER,
    "return_saledelete" INTEGER,
    "return_sale_view" INTEGER,
    "deliveries_d" INTEGER,
    "deliveryadd" INTEGER,
    "deliveryedit" INTEGER,
    "deliverydelete" INTEGER,
    "delivery_view" INTEGER,
    "purchases_d" INTEGER,
    "purchaseadd" INTEGER,
    "purchaseedit" INTEGER,
    "purchasedelete" INTEGER,
    "purchase_view" INTEGER,
    "return_purchases_d" INTEGER,
    "return_purchaseadd" INTEGER,
    "return_purchaseedit" INTEGER,
    "return_purchasedelete" INTEGER,
    "return_purchase_view" INTEGER,
    "expansives_d" INTEGER,
    "expansiveadd" INTEGER,
    "expansiveedit" INTEGER,
    "expansivedelete" INTEGER,
    "expansive_view" INTEGER,
    "expansive_categories_d" INTEGER,
    "expansive_categoryadd" INTEGER,
    "expansive_categoryedit" INTEGER,
    "expansive_categorydelete" INTEGER,
    "expansive_category_view" INTEGER,
    "items_d" INTEGER,
    "itemadd" INTEGER,
    "itemedit" INTEGER,
    "itemdelete" INTEGER,
    "item_view" INTEGER,
    "accounttype_d" INTEGER,
    "accounttypeadd" INTEGER,
    "accounttypeedit" INTEGER,
    "accounttypedelete" INTEGER,
    "accounttype_view" INTEGER,
    "account_d" INTEGER,
    "accountadd" INTEGER,
    "accountedit" INTEGER,
    "accountdelete" INTEGER,
    "iaccount_view" INTEGER,
    "accounttran_d" INTEGER,
    "accounttranadd" INTEGER,
    "accounttranedit" INTEGER,
    "accounttrandelete" INTEGER,
    "iaccounttran_view" INTEGER,
    "accountde_d" INTEGER,
    "accountdeadd" INTEGER,
    "accountdeedit" INTEGER,
    "accountdedelete" INTEGER,
    "iaccountde_view" INTEGER,
    "stock_d" INTEGER,
    "stockadd" INTEGER,
    "stockedit" INTEGER,
    "stockdelete" INTEGER,
    "stock_view" INTEGER,
    "tax_d" INTEGER,
    "taxadd" INTEGER,
    "taxedit" INTEGER,
    "taxdelete" INTEGER,
    "tax_view" INTEGER,
    "paytype_d" INTEGER,
    "paycity_d" INTEGER,
    "paytypeadd" INTEGER,
    "paytypeedit" INTEGER,
    "paytypedelete" INTEGER,
    "avaliblestock" INTEGER,
    "paycityadd" INTEGER,
    "paycityedit" INTEGER,
    "paycitydelete" INTEGER,
    "symbol_d" INTEGER,
    "symboladd" INTEGER,
    "symboledit" INTEGER,
    "symboldelete" INTEGER,
    "symbol_view" INTEGER,
    "stockchange_d" INTEGER,
    "stockchangeadd" INTEGER,
    "stockchangeedit" INTEGER,
    "stockchangedelete" INTEGER,
    "stockchange_view" INTEGER,
    "stocktransfer_d" INTEGER,
    "stocktransferadd" INTEGER,
    "stocktransferedit" INTEGER,
    "stocktransferdelete" INTEGER,
    "stocktransfer_view" INTEGER,
    "itemstype_d" INTEGER,
    "itemtypeadd" INTEGER,
    "itemtypeedit" INTEGER,
    "itemtypedelete" INTEGER,
    "item_typeview" INTEGER,
    "items_brands_d" INTEGER,
    "items_brandadd" INTEGER,
    "items_brandedit" INTEGER,
    "items_branddelete" INTEGER,
    "items_brand_view" INTEGER,
    "items_subcategories_d" INTEGER,
    "items_subcategoryadd" INTEGER,
    "items_subcategoryedit" INTEGER,
    "items_subcategorydelete" INTEGER,
    "items_subcategory_view" INTEGER,
    "items_maincategories_d" INTEGER,
    "items_maincategoryadd" INTEGER,
    "items_maincategoryedit" INTEGER,
    "items_maincategorydelete" INTEGER,
    "items_maincategory_view" INTEGER,
    "items_countries_d" INTEGER,
    "items_countryadd" INTEGER,
    "items_countryedit" INTEGER,
    "items_countrydelete" INTEGER,
    "items_country_view" INTEGER,
    "items_cities_d" INTEGER,
    "items_cityadd" INTEGER,
    "items_cityedit" INTEGER,
    "items_citydelete" INTEGER,
    "items_city_view" INTEGER,
    "barcode_printer" INTEGER,
    "setting" INTEGER,
    "setting_company" INTEGER,
    "report_profitandloss_view" INTEGER,
    "report_users_view" INTEGER,
    "report_supplier_view" INTEGER,
    "report_customer_view" INTEGER,
    "report_sales_view" INTEGER,
    "report_return_sales_view" INTEGER,
    "report_purchase_view" INTEGER,
    "report_return_purchase_view" INTEGER,
    "report_delivery_view" INTEGER,
    "report_item_view" INTEGER,
    "report_expansive_view" INTEGER,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- 1. علاقات الجداول الأساسية للمخزون والمشتريات
ALTER TABLE purchase_details 
ADD CONSTRAINT purchase_details_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES purchases(id);

ALTER TABLE purchase_details 
ADD CONSTRAINT purchase_details_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

ALTER TABLE return_purchase_detals 
ADD CONSTRAINT return_purchase_detals_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES return_purchases(id);

ALTER TABLE return_purchase_detals 
ADD CONSTRAINT return_purchase_detals_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

-- 2. علاقات المبيعات
ALTER TABLE sales_detals 
ADD CONSTRAINT sales_detals_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES sales(id);

ALTER TABLE sales_detals 
ADD CONSTRAINT sales_detals_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

ALTER TABLE return_sales_detals 
ADD CONSTRAINT return_sales_detals_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES return_sales(id);

ALTER TABLE return_sales_detals 
ADD CONSTRAINT return_sales_detals_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

-- 3. علاقات التحويل والتسوية
ALTER TABLE transf_stock_details 
ADD CONSTRAINT transf_stock_details_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES transf_stock(id);

ALTER TABLE transf_stock_details 
ADD CONSTRAINT transf_stock_details_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

ALTER TABLE change_stock_details 
ADD CONSTRAINT change_stock_details_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES change_stock(id);

ALTER TABLE change_stock_details 
ADD CONSTRAINT change_stock_details_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

-- 4. علاقات الدُفعات (Batches)
ALTER TABLE batches 
ADD CONSTRAINT batches_item_id_fkey 
FOREIGN KEY (item_id) REFERENCES items(id);

ALTER TABLE batches 
ADD CONSTRAINT batches_stock_id_fkey 
FOREIGN KEY (stock_id) REFERENCES inventory(id);

ALTER TABLE batches 
ADD CONSTRAINT batches_purchase_detail_id_fkey 
FOREIGN KEY (purchase_detail_id) REFERENCES purchase_details(id);

-- 5. علاقات المخزون
ALTER TABLE inventory 
ADD CONSTRAINT inventory_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE inventory 
ADD CONSTRAINT inventory_countryid_fkey 
FOREIGN KEY (countryid) REFERENCES country(id);

ALTER TABLE inventory 
ADD CONSTRAINT inventory_cityid_fkey 
FOREIGN KEY (cityid) REFERENCES city(id);

-- 6. علاقات الأصناف
ALTER TABLE items 
ADD CONSTRAINT items_id_maincategory_fkey 
FOREIGN KEY (id_maincategory) REFERENCES items_maincategory(id);

ALTER TABLE items 
ADD CONSTRAINT items_id_subcategory_fkey 
FOREIGN KEY (id_subcategory) REFERENCES subcategory(id);

ALTER TABLE items 
ADD CONSTRAINT items_id_brand_fkey 
FOREIGN KEY (id_brand) REFERENCES brand(id);

ALTER TABLE items 
ADD CONSTRAINT items_id_country_fkey 
FOREIGN KEY (id_country) REFERENCES country(id);

ALTER TABLE items 
ADD CONSTRAINT items_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE items 
ADD CONSTRAINT items_id_taxs_fkey 
FOREIGN KEY (id_taxs) REFERENCES taxs(id);

ALTER TABLE items 
ADD CONSTRAINT items_id_itemtype_fkey 
FOREIGN KEY (id_itemtype) REFERENCES type_items(id);

-- 7. علاقات الفواتير
ALTER TABLE purchases 
ADD CONSTRAINT purchases_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE purchases 
ADD CONSTRAINT purchases_taxid_fkey 
FOREIGN KEY (taxid) REFERENCES taxs(id);

ALTER TABLE return_purchases 
ADD CONSTRAINT return_purchases_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE sales 
ADD CONSTRAINT sales_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE sales 
ADD CONSTRAINT sales_taxid_fkey 
FOREIGN KEY (taxid) REFERENCES taxs(id);

ALTER TABLE return_sales 
ADD CONSTRAINT return_sales_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE transf_stock 
ADD CONSTRAINT transf_stock_id_from_stock_fkey 
FOREIGN KEY (id_from_stock) REFERENCES inventory(id);

ALTER TABLE transf_stock 
ADD CONSTRAINT transf_stock_id_to_stock_fkey 
FOREIGN KEY (id_to_stock) REFERENCES inventory(id);

ALTER TABLE change_stock 
ADD CONSTRAINT change_stock_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- 8. علاقات المدفوعات
ALTER TABLE payments 
ADD CONSTRAINT payments_paytype_id_fkey 
FOREIGN KEY (paytype_id) REFERENCES pay_types(id);

-- 9. علاقات الفئات والتصنيفات
ALTER TABLE items_maincategory 
ADD CONSTRAINT items_maincategory_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- ALTER TABLE subcategory
-- ADD CONSTRAINT subcategory_id_maincategory_fkey 
-- FOREIGN KEY (id_maincategory) REFERENCES items_maincategory(id);

-- 10. علاقات الجداول الإضافية
ALTER TABLE salestimer 
ADD CONSTRAINT salestimer_id_customer_fkey 
FOREIGN KEY (id_customer) REFERENCES customers(id);

ALTER TABLE salestimer 
ADD CONSTRAINT salestimer_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE sales_detals_timers 
ADD CONSTRAINT sales_detals_timers_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

ALTER TABLE sales_detals_timers 
ADD CONSTRAINT sales_detals_timers_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES salestimer(id);

ALTER TABLE sales_view 
ADD CONSTRAINT sales_view_id_customer_fkey 
FOREIGN KEY (id_customer) REFERENCES customers(id);

ALTER TABLE sales_view 
ADD CONSTRAINT sales_view_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE sales_view_detals 
ADD CONSTRAINT sales_view_detals_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

--ALTER TABLE sales_view_detals 
--ADD CONSTRAINT sales_view_detals_id_invoice_code_fkey 
--FOREIGN KEY (id_invoice_code) REFERENCES sales_view(id);

-- 11. علاقات المطاعم والكافتيريا
ALTER TABLE ketchine 
ADD CONSTRAINT ketchine_id_customer_fkey 
FOREIGN KEY (id_customer) REFERENCES customers(id);

ALTER TABLE ketchine 
ADD CONSTRAINT ketchine_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

ALTER TABLE ketchine_detals 
ADD CONSTRAINT ketchine_detals_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

ALTER TABLE ketchine_detals 
ADD CONSTRAINT ketchine_detals_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES ketchine(id);

-- العلاقة بين item_units و items
ALTER TABLE item_units
ADD CONSTRAINT item_units_item_id_fkey 
FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين wholesale_prices و items
ALTER TABLE wholesale_prices
ADD CONSTRAINT wholesale_prices_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين stock و items
ALTER TABLE stock
ADD CONSTRAINT stock_id_item_fkey 
FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين stock و inventory
ALTER TABLE stock
ADD CONSTRAINT stock_id_inventory_fkey 
FOREIGN KEY (id_inventory) REFERENCES inventory(id);

-- العلاقة بين stock_users و users
ALTER TABLE stock_users
ADD CONSTRAINT stock_users_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين stock_users و inventory
ALTER TABLE stock_users
ADD CONSTRAINT stock_users_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين accounttrans و account (لحساب المدين)
ALTER TABLE accounttrans
ADD CONSTRAINT accounttrans_accountdebit_id_fkey 
FOREIGN KEY (accountdebit_id) REFERENCES account(id);

-- العلاقة بين accounttrans و account (لحساب التحويل)
ALTER TABLE accounttrans
ADD CONSTRAINT accounttrans_accounttransf_id_fkey 
FOREIGN KEY (accounttransf_id) REFERENCES account(id);

-- العلاقة بين accounttrans و users
ALTER TABLE accounttrans
ADD CONSTRAINT accounttrans_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين account و account_type
ALTER TABLE account
ADD CONSTRAINT account_account_id_fkey 
FOREIGN KEY (account_id) REFERENCES account_type(id);

-- العلاقة بين account و users
ALTER TABLE account
ADD CONSTRAINT account_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين accountdebitcode و account (لحساب المدين)
ALTER TABLE accountdebitcode
ADD CONSTRAINT accountdebitcode_accountdebit_id_fkey 
FOREIGN KEY (accountdebit_id) REFERENCES account(id);

-- العلاقة بين accountdebitcode و account (لحساب التحويل)
ALTER TABLE accountdebitcode
ADD CONSTRAINT accountdebitcode_accounttransf_id_fkey 
FOREIGN KEY (accounttransf_id) REFERENCES account(id);

-- العلاقة بين accountdebitcode و users
ALTER TABLE accountdebitcode
ADD CONSTRAINT accountdebitcode_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين accounts_cash و account
ALTER TABLE accounts_cash
ADD CONSTRAINT accounts_cash_id_account_fkey 
FOREIGN KEY (id_account) REFERENCES account(id);

-- العلاقة بين users و jobs
ALTER TABLE users
ADD CONSTRAINT users_id_job_fkey 
FOREIGN KEY (id_job) REFERENCES jobs(id);

-- العلاقة بين jobs و job_details
ALTER TABLE jobs
ADD CONSTRAINT jobs_id_jobdetail_fkey 
FOREIGN KEY (id_jobdetail) REFERENCES job_details(id);

-- العلاقة بين expansive و expansive_category
ALTER TABLE expansive
ADD CONSTRAINT expansive_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES expansive_category(id);

-- العلاقة بين expansive و account
ALTER TABLE expansive
ADD CONSTRAINT expansive_account_id_fkey 
FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين suppliers و city
ALTER TABLE suppliers
ADD CONSTRAINT suppliers_cityid_fkey 
FOREIGN KEY (cityid) REFERENCES city(id);

-- العلاقة بين suppliers و country
ALTER TABLE suppliers
ADD CONSTRAINT suppliers_countryid_fkey 
FOREIGN KEY (countryid) REFERENCES country(id);

-- العلاقة بين suppliers و users
ALTER TABLE suppliers
ADD CONSTRAINT suppliers_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين customers و city
ALTER TABLE customers
ADD CONSTRAINT customers_cityid_fkey 
FOREIGN KEY (cityid) REFERENCES city(id);

-- العلاقة بين ketchine و customers
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_id_customer_fkey 
FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين ketchine و delivery
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_id_delivery_fkey 
FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين ketchine و inventory
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_id_stock_fkey 
FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين ketchine و account
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_account_id_fkey 
FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين ketchine و taxs
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_taxid_fkey 
FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين additions_items و items
ALTER TABLE additions_items
ADD CONSTRAINT additions_items_itemid_fkey 
FOREIGN KEY (itemid) REFERENCES items(id);

-- العلاقة بين additions_items و additions
ALTER TABLE additions_items
ADD CONSTRAINT additions_items_additionid_fkey 
FOREIGN KEY (additionid) REFERENCES additions(id);

-- العلاقة بين additions_items و users
ALTER TABLE additions_items
ADD CONSTRAINT additions_items_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE type_items
ADD CONSTRAINT type_items_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين addon_options و addons
ALTER TABLE addon_options
ADD CONSTRAINT addon_options_addon_id_fkey 
FOREIGN KEY (addon_id) REFERENCES addons(id);

-- العلاقة بين item_addons و items
ALTER TABLE item_addons
ADD CONSTRAINT item_addons_item_id_fkey 
FOREIGN KEY (item_id) REFERENCES items(id);


-- =============================================
-- العلاقات مع جدول المستخدمين (users)
-- =============================================

-- العلاقة بين account و users
ALTER TABLE account ADD CONSTRAINT account_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين account_type و users
ALTER TABLE account_type ADD CONSTRAINT account_type_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين accountdebitcode و users
ALTER TABLE accountdebitcode ADD CONSTRAINT accountdebitcode_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين accounts_cash و users
ALTER TABLE accounts_cash ADD CONSTRAINT accounts_cash_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين accounttrans و users
ALTER TABLE accounttrans ADD CONSTRAINT accounttrans_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين additions و users
ALTER TABLE additions ADD CONSTRAINT additions_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين additions_items و users
ALTER TABLE additions_items ADD CONSTRAINT additions_items_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين brand و users
ALTER TABLE brand ADD CONSTRAINT brand_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين change_stock و users
ALTER TABLE change_stock ADD CONSTRAINT change_stock_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين change_type و users
ALTER TABLE change_type ADD CONSTRAINT change_type_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين city و users
ALTER TABLE city ADD CONSTRAINT city_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);

-- العلاقة بين country و users
ALTER TABLE country ADD CONSTRAINT country_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين customer_pay و users
ALTER TABLE customer_pay ADD CONSTRAINT customer_pay_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين customers و users
ALTER TABLE customers ADD CONSTRAINT customers_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين delivery و users
ALTER TABLE delivery ADD CONSTRAINT delivery_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين expansive و users
ALTER TABLE expansive ADD CONSTRAINT expansive_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين expansive_category و users
ALTER TABLE expansive_category ADD CONSTRAINT expansive_category_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين inventory و users
ALTER TABLE inventory ADD CONSTRAINT inventory_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين items و users
ALTER TABLE items ADD CONSTRAINT items_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين items_maincategory و users
ALTER TABLE items_maincategory ADD CONSTRAINT items_maincategory_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين ketchine و users
ALTER TABLE ketchine ADD CONSTRAINT ketchine_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين my_table و users
ALTER TABLE my_table ADD CONSTRAINT my_table_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين purchases و users
ALTER TABLE purchases ADD CONSTRAINT purchases_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين purchases_timer و users
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين return_purchases و users
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين return_sales و users
ALTER TABLE return_sales ADD CONSTRAINT return_sales_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين sales و users
ALTER TABLE sales ADD CONSTRAINT sales_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين sales_view و users
ALTER TABLE sales_view ADD CONSTRAINT sales_view_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين salestimers و users
ALTER TABLE salestimers ADD CONSTRAINT salestimers_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين stock_users و users
ALTER TABLE stock_users ADD CONSTRAINT stock_users_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين subcategory و users
ALTER TABLE subcategory ADD CONSTRAINT subcategory_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين suppliers و users
ALTER TABLE suppliers ADD CONSTRAINT suppliers_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين symbols و users
ALTER TABLE symbols ADD CONSTRAINT symbols_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين tables و users
ALTER TABLE tables ADD CONSTRAINT tables_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين taxs و users
ALTER TABLE taxs ADD CONSTRAINT taxs_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين transf_stock و users
ALTER TABLE transf_stock ADD CONSTRAINT transf_stock_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين type_items و users
ALTER TABLE type_items ADD CONSTRAINT type_items_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- =============================================
-- العلاقات مع جدول الأصناف (items)
-- =============================================


-- العلاقة بين subcategory و users
ALTER TABLE subcategory ADD CONSTRAINT subcategory_maincategory_id_fkey FOREIGN KEY (maincategory_id) REFERENCES items_maincategory(id);


-- العلاقة بين additions_items و items
ALTER TABLE additions_items ADD CONSTRAINT additions_items_itemid_fkey FOREIGN KEY (itemid) REFERENCES items(id);

-- العلاقة بين batch_balance و items
ALTER TABLE batch_balance ADD CONSTRAINT batch_balance_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين batches و items
ALTER TABLE batches ADD CONSTRAINT batches_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين batches1 و items
ALTER TABLE batches1 ADD CONSTRAINT batches1_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين change_stock_details و items
ALTER TABLE change_stock_details ADD CONSTRAINT change_stock_details_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين item_addons و items
ALTER TABLE item_addons ADD CONSTRAINT item_addons_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- إضافة علاقات متعددة
--ALTER TABLE payments 
--ADD CONSTRAINT payments_sales_fkey 
--FOREIGN KEY (code) REFERENCES sales(invoice_code);

--ALTER TABLE payments 
--ADD CONSTRAINT payments_purchases_fkey 
--FOREIGN KEY (code) REFERENCES purchases(invoice_code);

--ALTER TABLE payments 
--ADD CONSTRAINT payments_return_sales_fkey 
--FOREIGN KEY (code) REFERENCES return_sales(invoice_code);

--ALTER TABLE payments 
--ADD CONSTRAINT payments_return_purchases_fkey 
--FOREIGN KEY (code) REFERENCES return_purchases(invoice_code);

--ALTER TABLE payments
--ADD CONSTRAINT payments_code_fkey
--FOREIGN KEY (code) REFERENCES sales(invoice_code);

--ALTER TABLE payments
--ADD CONSTRAINT purchases_payments_code_fkey
--FOREIGN KEY (code) REFERENCES purchases(invoice_code);

--ALTER TABLE payments
--ADD CONSTRAINT return_purchases_payments_code_fkey
--FOREIGN KEY (code) REFERENCES return_purchases(invoice_code);


--ALTER TABLE payments
--ADD CONSTRAINT return_sales_payments_code_fkey
--FOREIGN KEY (code) REFERENCES return_sales(invoice_code);

-- العلاقة بين item_units و items
ALTER TABLE item_units ADD CONSTRAINT item_units_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين ketchine_detals و items
ALTER TABLE ketchine_detals ADD CONSTRAINT ketchine_detals_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين purchase_details و items
ALTER TABLE purchase_details ADD CONSTRAINT purchase_details_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين purchase_details_timer و items
ALTER TABLE purchase_details_timer ADD CONSTRAINT purchase_details_timer_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين return_purchase_detals و items
ALTER TABLE return_purchase_detals ADD CONSTRAINT return_purchase_detals_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين return_sales_detals و items
ALTER TABLE return_sales_detals ADD CONSTRAINT return_sales_detals_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين sales_detals و items
ALTER TABLE sales_detals ADD CONSTRAINT sales_detals_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين sales_detals_timers و items
ALTER TABLE sales_detals_timers ADD CONSTRAINT sales_detals_timers_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين sales_view_detals و items
ALTER TABLE sales_view_detals ADD CONSTRAINT sales_view_detals_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين stock و items
ALTER TABLE stock ADD CONSTRAINT stock_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين transf_stock_details و items
ALTER TABLE transf_stock_details ADD CONSTRAINT transf_stock_details_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين wholesale_prices و items
ALTER TABLE wholesale_prices ADD CONSTRAINT wholesale_prices_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- =============================================
-- العلاقات مع جدول المخزون (inventory)
-- =============================================

-- العلاقة بين batch_balance و inventory
ALTER TABLE batch_balance ADD CONSTRAINT batch_balance_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES inventory(id);

-- العلاقة بين batches و inventory
ALTER TABLE batches ADD CONSTRAINT batches_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES inventory(id);

-- العلاقة بين batches1 و inventory
ALTER TABLE batches1 ADD CONSTRAINT batches1_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES inventory(id);

-- العلاقة بين change_stock و inventory
ALTER TABLE change_stock ADD CONSTRAINT change_stock_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين change_stock_details و inventory
ALTER TABLE change_stock_details ADD CONSTRAINT change_stock_details_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين inventory و country
ALTER TABLE inventory ADD CONSTRAINT inventory_countryid_fkey FOREIGN KEY (countryid) REFERENCES country(id);

-- العلاقة بين inventory و city
ALTER TABLE inventory ADD CONSTRAINT inventory_cityid_fkey FOREIGN KEY (cityid) REFERENCES city(id);

-- العلاقة بين ketchine و inventory
ALTER TABLE ketchine ADD CONSTRAINT ketchine_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين purchases و inventory
ALTER TABLE purchases ADD CONSTRAINT purchases_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين purchases_timer و inventory
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين return_purchases و inventory
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين return_sales و inventory
ALTER TABLE return_sales ADD CONSTRAINT return_sales_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين sales و inventory
ALTER TABLE sales ADD CONSTRAINT sales_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين sales_view و inventory
ALTER TABLE sales_view ADD CONSTRAINT sales_view_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين salestimers و inventory
ALTER TABLE salestimers ADD CONSTRAINT salestimers_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين stock و inventory
ALTER TABLE stock ADD CONSTRAINT stock_id_inventory_fkey FOREIGN KEY (id_inventory) REFERENCES inventory(id);

-- العلاقة بين stock_users و inventory
ALTER TABLE stock_users ADD CONSTRAINT stock_users_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين transf_stock و inventory (من المخزن)
ALTER TABLE transf_stock ADD CONSTRAINT transf_stock_id_from_stock_fkey FOREIGN KEY (id_from_stock) REFERENCES inventory(id);

-- العلاقة بين transf_stock و inventory (إلى المخزن)
ALTER TABLE transf_stock ADD CONSTRAINT transf_stock_id_to_stock_fkey FOREIGN KEY (id_to_stock) REFERENCES inventory(id);

-- =============================================
-- العلاقات مع جدول الحسابات (account)
-- =============================================

-- العلاقة بين account و account_type
ALTER TABLE account ADD CONSTRAINT account_account_id_fkey FOREIGN KEY (account_id) REFERENCES account_type(id);

-- العلاقة بين accountdebitcode و account (حساب مدين)
ALTER TABLE accountdebitcode ADD CONSTRAINT accountdebitcode_accountdebit_id_fkey FOREIGN KEY (accountdebit_id) REFERENCES account(id);

-- العلاقة بين accountdebitcode و account (حساب تحويل)
ALTER TABLE accountdebitcode ADD CONSTRAINT accountdebitcode_accounttransf_id_fkey FOREIGN KEY (accounttransf_id) REFERENCES account(id);

-- العلاقة بين accounts_cash و account
ALTER TABLE accounts_cash ADD CONSTRAINT accounts_cash_id_account_fkey FOREIGN KEY (id_account) REFERENCES account(id);

-- العلاقة بين accounttrans و account (حساب مدين)
ALTER TABLE accounttrans ADD CONSTRAINT accounttrans_accountdebit_id_fkey FOREIGN KEY (accountdebit_id) REFERENCES account(id);

-- العلاقة بين accounttrans و account (حساب تحويل)
ALTER TABLE accounttrans ADD CONSTRAINT accounttrans_accounttransf_id_fkey FOREIGN KEY (accounttransf_id) REFERENCES account(id);

-- العلاقة بين expansive و account
ALTER TABLE expansive ADD CONSTRAINT expansive_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين ketchine و account
ALTER TABLE ketchine ADD CONSTRAINT ketchine_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين purchases و account
ALTER TABLE purchases ADD CONSTRAINT purchases_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين return_purchases و account
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين return_sales و account
ALTER TABLE return_sales ADD CONSTRAINT return_sales_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين sales و account
ALTER TABLE sales ADD CONSTRAINT sales_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين sales_view و account
ALTER TABLE sales_view ADD CONSTRAINT sales_view_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- =============================================
-- العلاقات مع جدول العملاء (customers)
-- =============================================

-- العلاقة بين customer_pay و customers
ALTER TABLE customer_pay ADD CONSTRAINT customer_pay_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(id);

-- العلاقة بين customers و city
ALTER TABLE customers ADD CONSTRAINT customers_cityid_fkey FOREIGN KEY (cityid) REFERENCES city(id);

-- العلاقة بين customers و country
ALTER TABLE customers ADD CONSTRAINT customers_countryid_fkey FOREIGN KEY (countryid) REFERENCES country(id);

-- العلاقة بين ketchine و customers
ALTER TABLE ketchine ADD CONSTRAINT ketchine_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين return_sales و customers
ALTER TABLE return_sales ADD CONSTRAINT return_sales_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين sales و customers
ALTER TABLE sales ADD CONSTRAINT sales_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين sales_view و customers
ALTER TABLE sales_view ADD CONSTRAINT sales_view_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين salestimers و customers
ALTER TABLE salestimers ADD CONSTRAINT salestimers_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- =============================================
-- العلاقات مع جدول الموردين (suppliers)
-- =============================================

-- العلاقة بين suppliers و city
ALTER TABLE suppliers ADD CONSTRAINT suppliers_cityid_fkey FOREIGN KEY (cityid) REFERENCES city(id);

-- العلاقة بين suppliers و country
ALTER TABLE suppliers ADD CONSTRAINT suppliers_countryid_fkey FOREIGN KEY (countryid) REFERENCES country(id);

-- العلاقة بين purchases و suppliers
ALTER TABLE purchases ADD CONSTRAINT purchases_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- العلاقة بين purchases_timer و suppliers
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- العلاقة بين return_purchases و suppliers
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- =============================================
-- العلاقات مع جدول التوصيل (delivery)
-- =============================================

-- العلاقة بين ketchine و delivery
ALTER TABLE ketchine ADD CONSTRAINT ketchine_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين return_sales و delivery
ALTER TABLE return_sales ADD CONSTRAINT return_sales_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين sales و delivery
ALTER TABLE sales ADD CONSTRAINT sales_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين sales_view و delivery
ALTER TABLE sales_view ADD CONSTRAINT sales_view_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- =============================================
-- العلاقات مع جدول الضرائب (taxs)
-- =============================================

-- العلاقة بين items و taxs
ALTER TABLE items ADD CONSTRAINT items_id_taxs_fkey FOREIGN KEY (id_taxs) REFERENCES taxs(id);

-- العلاقة بين ketchine و taxs
ALTER TABLE ketchine ADD CONSTRAINT ketchine_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين purchases و taxs
ALTER TABLE purchases ADD CONSTRAINT purchases_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين purchases_timer و taxs
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين return_purchases و taxs
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين return_sales و taxs
ALTER TABLE return_sales ADD CONSTRAINT return_sales_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين sales و taxs
ALTER TABLE sales ADD CONSTRAINT sales_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين sales_view و taxs
ALTER TABLE sales_view ADD CONSTRAINT sales_view_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين salestimers و taxs
ALTER TABLE salestimers ADD CONSTRAINT salestimers_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين taxs_min و taxs
ALTER TABLE taxs_min ADD CONSTRAINT taxs_min_id_taxs_fkey FOREIGN KEY (id_taxs) REFERENCES taxs(id);

-- =============================================
-- العلاقات مع جدول الوظائف (jobs)
-- =============================================

-- العلاقة بين users و jobs
ALTER TABLE users ADD CONSTRAINT users_id_job_fkey FOREIGN KEY (id_job) REFERENCES jobs(id);

-- =============================================
-- العلاقات مع جدول الدول (country)
-- =============================================

-- العلاقة بين city و country
ALTER TABLE city ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);

-- العلاقة بين citypay و country
ALTER TABLE citypay ADD CONSTRAINT citypay_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);

-- العلاقة بين items و country
ALTER TABLE items ADD CONSTRAINT items_id_country_fkey FOREIGN KEY (id_country) REFERENCES country(id);

-- =============================================
-- العلاقات مع جدول المدن (city)
-- =============================================

-- العلاقة بين citypay و city
ALTER TABLE citypay ADD CONSTRAINT citypay_city_id_fkey FOREIGN KEY (city_id) REFERENCES city(id);

-- =============================================
-- العلاقات مع جدول الفئات (categories)
-- =============================================

-- العلاقة بين items و items_maincategory
ALTER TABLE items ADD CONSTRAINT items_id_maincategory_fkey FOREIGN KEY (id_maincategory) REFERENCES items_maincategory(id);

-- العلاقة بين items و subcategory
ALTER TABLE items ADD CONSTRAINT items_id_subcategory_fkey FOREIGN KEY (id_subcategory) REFERENCES subcategory(id);

-- العلاقة بين subcategory و items_maincategory
ALTER TABLE subcategory ADD CONSTRAINT subcategory_maincategory_id_fkey FOREIGN KEY (maincategory_id) REFERENCES items_maincategory(id);

-- =============================================
-- العلاقات مع جدول الماركات (brand)
-- =============================================

-- العلاقة بين items و brand
ALTER TABLE items ADD CONSTRAINT items_id_brand_fkey FOREIGN KEY (id_brand) REFERENCES brand(id);

-- =============================================
-- العلاقات مع جدول أنواع العناصر (type_items)
-- =============================================

-- العلاقة بين items و type_items
ALTER TABLE items ADD CONSTRAINT items_id_itemtype_fkey FOREIGN KEY (id_itemtype) REFERENCES type_items(id);

-- =============================================
-- العلاقات مع جدول فئات المصاريف (expansive_category)
-- =============================================

-- العلاقة بين expansive و expansive_category
ALTER TABLE expansive ADD CONSTRAINT expansive_category_id_fkey FOREIGN KEY (category_id) REFERENCES expansive_category(id);

-- =============================================
-- العلاقات مع جدول أنواع الدفع (pay_types)
-- =============================================

-- العلاقة بين payments و pay_types
ALTER TABLE payments ADD CONSTRAINT payments_paytype_id_fkey FOREIGN KEY (paytype_id) REFERENCES pay_types(id);

-- العلاقة بين taxs_min و pay_types
ALTER TABLE taxs_min ADD CONSTRAINT taxs_min_paytype_id_fkey FOREIGN KEY (paytype_id) REFERENCES pay_types(id);

-- =============================================
-- العلاقات مع جدول الإضافات (addons)
-- =============================================

-- العلاقة بين addon_options و addons
ALTER TABLE addon_options ADD CONSTRAINT addon_options_addon_id_fkey FOREIGN KEY (addon_id) REFERENCES addons(id);

-- العلاقة بين item_addons و addons
ALTER TABLE item_addons ADD CONSTRAINT item_addons_addon_id_fkey FOREIGN KEY (addon_id) REFERENCES addons(id);

-- =============================================
-- العلاقات مع جدول المشتريات (purchases)
-- =============================================

-- العلاقة بين purchase_details و purchases
ALTER TABLE purchase_details ADD CONSTRAINT purchase_details_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES purchases(id);

-- العلاقة بين purchase_details_timer و purchases
ALTER TABLE purchase_details_timer ADD CONSTRAINT purchase_details_timer_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES purchases(id);

-- العلاقة بين return_purchases و purchases
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES purchases(id);

-- =============================================
-- العلاقات مع جدول المبيعات (sales)
-- =============================================

-- العلاقة بين return_sales و sales
ALTER TABLE return_sales ADD CONSTRAINT return_sales_sales_id_fkey FOREIGN KEY (sales_id) REFERENCES sales(id);

-- العلاقة بين sales_detals و sales
ALTER TABLE sales_detals ADD CONSTRAINT sales_detals_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES sales(id);

-- العلاقة بين sales_detals_timers و sales
ALTER TABLE sales_detals_timers ADD CONSTRAINT sales_detals_timers_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES sales(id);

-- =============================================
-- العلاقات مع جدول مرتجع المشتريات (return_purchases)
-- =============================================

-- العلاقة بين return_purchase_detals و return_purchases
ALTER TABLE return_purchase_detals ADD CONSTRAINT return_purchase_detals_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES return_purchases(id);

-- =============================================
-- العلاقات مع جدول مرتجع المبيعات (return_sales)
-- =============================================

-- العلاقة بين return_sales_detals و return_sales
ALTER TABLE return_sales_detals ADD CONSTRAINT return_sales_detals_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES return_sales(id);

-- =============================================
-- العلاقات مع جدول تحويل المخزون (transf_stock)
-- =============================================

-- العلاقة بين transf_stock_details و transf_stock
ALTER TABLE transf_stock_details ADD CONSTRAINT transf_stock_details_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES transf_stock(id);

-- =============================================
-- العلاقات مع جدول تعديل المخزون (change_stock)
-- =============================================

-- العلاقة بين change_stock_details و change_stock
ALTER TABLE change_stock_details ADD CONSTRAINT change_stock_details_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES change_stock(id);

-- =============================================
-- العلاقات مع جدول المطعم (ketchine)
-- =============================================

-- العلاقة بين ketchine_detals و ketchine
ALTER TABLE ketchine_detals ADD CONSTRAINT ketchine_detals_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES ketchine(id);

-- =============================================
-- العلاقات مع جدول تفاصيل المشتريات (purchase_details)
-- =============================================

-- العلاقة بين batches و purchase_details
ALTER TABLE batches ADD CONSTRAINT batches_purchase_detail_id_fkey FOREIGN KEY (purchase_detail_id) REFERENCES purchase_details(id);


ALTER TABLE batches DROP CONSTRAINT batches_purchase_detail_id_fkey;
ALTER TABLE batches DROP CONSTRAINT sales_view_detals_id_invoice_code_fkey ;


-- العلاقة بين batches1 و purchase_details
ALTER TABLE batches1 ADD CONSTRAINT batches1_purchase_detail_id_fkey FOREIGN KEY (purchase_detail_id) REFERENCES purchase_details(id);


-- العلاقة بين account_type و users
ALTER TABLE account_type ADD CONSTRAINT account_type_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين brand و users
ALTER TABLE brand ADD CONSTRAINT brand_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين change_stock و users
ALTER TABLE change_stock ADD CONSTRAINT change_stock_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين change_type و users
ALTER TABLE change_type ADD CONSTRAINT change_type_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين city و users
ALTER TABLE city ADD CONSTRAINT city_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);

-- العلاقة بين country و users
ALTER TABLE country ADD CONSTRAINT country_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين customer_pay و users
ALTER TABLE customer_pay ADD CONSTRAINT customer_pay_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين delivery و users
ALTER TABLE delivery ADD CONSTRAINT delivery_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين my_table و users
ALTER TABLE my_table ADD CONSTRAINT my_table_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين purchases و users
ALTER TABLE purchases ADD CONSTRAINT purchases_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين purchases_timer و users
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين return_purchases و users
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين return_sales و users
ALTER TABLE return_sales ADD CONSTRAINT return_sales_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين sales و users
ALTER TABLE sales ADD CONSTRAINT sales_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين sales_view و users
ALTER TABLE sales_view ADD CONSTRAINT sales_view_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين subcategory و users
ALTER TABLE subcategory ADD CONSTRAINT subcategory_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين symbols و users
ALTER TABLE symbols ADD CONSTRAINT symbols_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين tables و users
ALTER TABLE tables ADD CONSTRAINT tables_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين taxs و users
ALTER TABLE taxs ADD CONSTRAINT taxs_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين transf_stock و users
ALTER TABLE transf_stock ADD CONSTRAINT transf_stock_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين batch_balance و items
ALTER TABLE batch_balance ADD CONSTRAINT batch_balance_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين batches1 و items
ALTER TABLE batches1 ADD CONSTRAINT batches1_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id);

-- العلاقة بين purchase_details_timer و items
ALTER TABLE purchase_details_timer ADD CONSTRAINT purchase_details_timer_id_item_fkey FOREIGN KEY (id_item) REFERENCES items(id);

-- العلاقة بين batch_balance و inventory
ALTER TABLE batch_balance ADD CONSTRAINT batch_balance_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES inventory(id);

-- العلاقة بين batches1 و inventory
ALTER TABLE batches1 ADD CONSTRAINT batches1_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES inventory(id);

-- العلاقة بين change_stock_details و inventory
ALTER TABLE change_stock_details ADD CONSTRAINT change_stock_details_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);

-- العلاقة بين purchases_timer و inventory
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_id_stock_fkey FOREIGN KEY (id_stock) REFERENCES inventory(id);


-- =============================================
-- العلاقات مع جدول الحسابات (account)
-- =============================================

-- العلاقة بين purchases و account
ALTER TABLE purchases ADD CONSTRAINT purchases_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين return_purchases و account
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين return_sales و account
ALTER TABLE return_sales ADD CONSTRAINT return_sales_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين sales و account
ALTER TABLE sales ADD CONSTRAINT sales_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- العلاقة بين sales_view و account
ALTER TABLE sales_view ADD CONSTRAINT sales_view_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);

-- =============================================
-- العلاقات مع جدول العملاء (customers)
-- =============================================

-- العلاقة بين customer_pay و customers
ALTER TABLE customer_pay ADD CONSTRAINT customer_pay_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(id);

-- العلاقة بين return_sales و customers
ALTER TABLE return_sales ADD CONSTRAINT return_sales_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);

-- العلاقة بين sales و customers
ALTER TABLE sales ADD CONSTRAINT sales_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES customers(id);


-- =============================================
-- العلاقات مع جدول الموردين (suppliers)
-- =============================================


-- العلاقة بين purchases و suppliers
ALTER TABLE purchases ADD CONSTRAINT purchases_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- العلاقة بين purchases_timer و suppliers
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- العلاقة بين return_purchases و suppliers
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES suppliers(id);

-- =============================================
-- العلاقات مع جدول التوصيل (delivery)
-- =============================================


-- العلاقة بين return_sales و delivery
ALTER TABLE return_sales ADD CONSTRAINT return_sales_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين sales و delivery
ALTER TABLE sales ADD CONSTRAINT sales_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- العلاقة بين sales_view و delivery
ALTER TABLE sales_view ADD CONSTRAINT sales_view_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES delivery(id);

-- =============================================
-- العلاقات مع جدول الضرائب (taxs)
-- =============================================


-- العلاقة بين purchases_timer و taxs
ALTER TABLE purchases_timer ADD CONSTRAINT purchases_timer_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين return_purchases و taxs
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين return_sales و taxs
ALTER TABLE return_sales ADD CONSTRAINT return_sales_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين sales_view و taxs
ALTER TABLE sales_view ADD CONSTRAINT sales_view_taxid_fkey FOREIGN KEY (taxid) REFERENCES taxs(id);


-- العلاقة بين taxs_min و taxs
ALTER TABLE taxs_min ADD CONSTRAINT taxs_min_id_taxs_fkey FOREIGN KEY (id_taxs) REFERENCES taxs(id);

-- =============================================
-- العلاقات مع جدول الوظائف (jobs)
-- =============================================

-- =============================================
-- العلاقات مع جدول الدول (country)
-- =============================================

-- العلاقة بين city و country
ALTER TABLE city ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);

-- العلاقة بين citypay و country
ALTER TABLE citypay ADD CONSTRAINT citypay_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);

-- العلاقة بين citypay و city
ALTER TABLE citypay ADD CONSTRAINT citypay_city_id_fkey FOREIGN KEY (city_id) REFERENCES city(id);

-- العلاقة بين taxs_min و pay_types
ALTER TABLE taxs_min ADD CONSTRAINT taxs_min_paytype_id_fkey FOREIGN KEY (paytype_id) REFERENCES pay_types(id);

-- العلاقة بين purchase_details_timer و purchases
ALTER TABLE purchase_details_timer ADD CONSTRAINT purchase_details_timer_id_invoice_code_fkey FOREIGN KEY (id_invoice_code) REFERENCES purchases(id);

-- العلاقة بين return_purchases و purchases
ALTER TABLE return_purchases ADD CONSTRAINT return_purchases_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES purchases(id);

ALTER TABLE sales_detals
ADD CONSTRAINT sales_detals_taxid_fkey
FOREIGN KEY (taxid) REFERENCES taxs(id);

ALTER TABLE payments
ADD CONSTRAINT payments_code_fkey
FOREIGN KEY (code) REFERENCES sales(invoice_code);

-- =============================================
-- العلاقات مع جدول المبيعات (sales)
-- =============================================

ALTER TABLE purchase_details
ADD CONSTRAINT purchase_details_taxid_fkey 
FOREIGN KEY (taxid) REFERENCES taxs(id);

-- العلاقة بين return_sales و sales
ALTER TABLE return_sales ADD CONSTRAINT return_sales_sales_id_fkey FOREIGN KEY (sales_id) REFERENCES sales(id);

-- العلاقة بين batches1 و purchase_details
ALTER TABLE batches1 ADD CONSTRAINT batches1_purchase_detail_id_fkey FOREIGN KEY (purchase_detail_id) REFERENCES purchase_details(id);
-- =============================================
-- العلاقة بين item_addons و addons
ALTER TABLE item_addons
ADD CONSTRAINT item_addons_addon_id_fkey 
FOREIGN KEY (addon_id) REFERENCES addons(id);

-- العلاقة بين ketchine و users
ALTER TABLE ketchine
ADD CONSTRAINT ketchine_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين ketchine_detals و ketchine
ALTER TABLE ketchine_detals
ADD CONSTRAINT ketchine_detals_id_invoice_code_fkey 
FOREIGN KEY (id_invoice_code) REFERENCES ketchine(invoice_code);

-- العلاقة بين customers و country
ALTER TABLE customers
ADD CONSTRAINT customers_countryid_fkey 
FOREIGN KEY (countryid) REFERENCES country(id);

-- العلاقة بين customers و users
ALTER TABLE customers
ADD CONSTRAINT customers_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين expansive و users
ALTER TABLE expansive
ADD CONSTRAINT expansive_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين expansive_category و users
ALTER TABLE expansive_category
ADD CONSTRAINT expansive_category_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);

-- العلاقة بين job_details و jobs
ALTER TABLE job_details
ADD CONSTRAINT job_details_id_job_fkey 
FOREIGN KEY (id_job) REFERENCES jobs(id);

-- العلاقة بين accounts_cash و users
ALTER TABLE accounts_cash
ADD CONSTRAINT accounts_cash_userid_fkey 
FOREIGN KEY (userid) REFERENCES users(id);



-- تأكد من وجود المفاتيح الخارجية
ALTER TABLE customers 
ADD CONSTRAINT customers_cityid_fkey 
FOREIGN KEY (cityid) REFERENCES city(id);

ALTER TABLE customers 
ADD CONSTRAINT customers_countryid_fkey 
FOREIGN KEY (countryid) REFERENCES country(id);

ALTER TABLE citypay 
ADD CONSTRAINT citypay_city_id_fkey 
FOREIGN KEY (city_id) REFERENCES city(id);

ALTER TABLE citypay 
ADD CONSTRAINT citypay_country_id_fkey 
FOREIGN KEY (country_id) REFERENCES country(id);


-- إزالة القيد الحالي
ALTER TABLE payments DROP CONSTRAINT return_purchases_payments_code_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_sales_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS return_sales_payments_code_fkey
ALTER TABLE payments DROP CONSTRAINT IF EXISTS purchases_payments_code_fkey
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_purchases_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_return_sales_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_return_purchases_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS purchases_payments_code_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS return_sales_payments_code_fkey;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_purchases_fkey;



-- 12. فهارس لأداء أفضل
CREATE INDEX IF NOT EXISTS idx_batches_item_stock ON batches(item_id, stock_id);
CREATE INDEX IF NOT EXISTS idx_batches_expiry ON batches(expiry_date);
CREATE INDEX IF NOT EXISTS idx_purchase_details_item_invoice ON purchase_details(id_item, id_invoice_code);
CREATE INDEX IF NOT EXISTS idx_sales_detals_item_invoice ON sales_detals(id_item, id_invoice_code);
CREATE INDEX IF NOT EXISTS idx_items_name ON items(name);
CREATE INDEX IF NOT EXISTS idx_items_barcode ON items(barcode);
CREATE INDEX IF NOT EXISTS idx_inventory_name ON inventory(name);
CREATE INDEX IF NOT EXISTS idx_payments_code ON payments(code);


-- ===============================================






































DROP FUNCTION IF EXISTS get_customer_info(UUID);
CREATE OR REPLACE FUNCTION get_customer_info(customer_id INTEGER DEFAULT NULL)
RETURNS TABLE (
    id INTEGER,
    name TEXT,
    number_phone TEXT,
    cityid INTEGER,
    countryid INTEGER,
    address TEXT,
    country_name TEXT,
    city_name TEXT,
    delivery_price DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.number_phone,
        c.cityid,
        c.countryid,
        c.address,
        co.name AS country_name,
        ci.name AS city_name,
        CAST(cp.price AS DECIMAL) AS delivery_price
    FROM customers c
    LEFT JOIN country co ON c.countryid = co.id
    LEFT JOIN city ci ON c.cityid = ci.id
    LEFT JOIN citypay cp ON cp.city_id = ci.id AND cp.country_id = co.id
    WHERE c.id = customer_id;
END;
$$ LANGUAGE plpgsql;






-- حساب المشتريات اليومية



-- وظيفة حساب المشتريات الأسبوعية
CREATE OR REPLACE FUNCTION calculate_weekly_purchases()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_week DATE;
    end_of_week DATE;
    charge_price_total DOUBLE PRECISION := 0;
    invoice_count_total INTEGER := 0;
    total_discount_total DOUBLE PRECISION := 0;
    total_tax_total DOUBLE PRECISION := 0;
    total_value_total DOUBLE PRECISION := 0;
    result_record RECORD;
    purchase_record RECORD;
    response JSON;
BEGIN
    -- حساب بداية ونهاية الأسبوع (الاثنين إلى الأحد)
    start_of_week := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_of_week := (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE;
    
    -- حساب المشتريات الرئيسية
    FOR purchase_record IN (
        SELECT 
            p.id,
            COUNT(DISTINCT p.id) AS invoice_count,
            COALESCE(SUM(pd.qty * pd.price), 0.0) AS total_value1,
            COALESCE(SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                        ELSE 0
                    END
                )
            ), 0.0) AS total_value,
            CASE 
                WHEN p.type_dic = 0 THEN (
                    COALESCE(SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                )
                WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN t.type = 0 THEN (
                    (COALESCE(SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) - 
                    CASE 
                        WHEN p.type_dic = 0 THEN (
                            COALESCE(SUM(
                                pd.qty * (
                                    pd.price 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.price - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                ) * CAST(t.value AS DOUBLE PRECISION) / 100
                )
                WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                ELSE 0
            END AS total_tax,
            COALESCE(
                CASE 
                    WHEN p.type_dic = 0 THEN 
                        (SUM(pd.qty * pd.price)) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                    WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                    ELSE 0.0
                END,
                0.0
            ) AS total_discount1,
            COALESCE(
                CASE 
                    WHEN t.type = 0 THEN 
                        (SUM(pd.qty * pd.price) - 
                            CASE 
                                WHEN p.type_dic = 0 THEN 
                                    (SUM(pd.qty * pd.price)) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                                WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                                ELSE 0.0
                            END
                        ) * CAST(t.value AS DOUBLE PRECISION) / 100
                    WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                    ELSE 0.0
                END,
                0.0
            ) AS total_tax1
        FROM purchases p
        INNER JOIN purchase_details pd ON p.id = pd.id_invoice_code
        INNER JOIN items i ON pd.id_item = i.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        WHERE DATE(p.date) BETWEEN start_of_week AND end_of_week
        GROUP BY p.id, p.type_dic, p.value_dic, t.type, t.value
    ) LOOP
        invoice_count_total := invoice_count_total + COALESCE(purchase_record.invoice_count, 0);
        total_discount_total := total_discount_total + COALESCE(purchase_record.total_discount, 0.0);
        total_tax_total := total_tax_total + COALESCE(purchase_record.total_tax, 0.0);
        total_value_total := total_value_total + COALESCE(purchase_record.total_value, 0.0);
    END LOOP;

    -- حساب الشحن
    SELECT COALESCE(SUM(CAST(charge_price AS DOUBLE PRECISION)), 0.0)
    INTO charge_price_total
    FROM purchases 
    WHERE DATE(date) BETWEEN start_of_week AND end_of_week;

    -- بناء الاستجابة
    response := json_build_object(
        'charge_price1', COALESCE(charge_price_total, 0.0),
        'total_tax', COALESCE(total_tax_total, 0.0),
        'invoice_count', COALESCE(invoice_count_total, 0),
        'total_discount', COALESCE(total_discount_total, 0.0),
        'total_value', COALESCE(total_value_total, 0.0)
    );

    RETURN response;
END;
$$;


-- حساب المبيعات بين تاريخين (النسخة القديمة بدون شرط الحالة)




-- حساب المشتريات الشهرية



-- حساب المشتريات السنوية




-- الحصول على البيانات المالية
CREATE OR REPLACE FUNCTION get_financial_data()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    combined_data JSON;
BEGIN
    WITH sales_data AS (
        SELECT 
            'sales' as type,
            s.invoice_code,
            sd.id_item,
            CAST(sd.qty AS DOUBLE PRECISION) as quantity,
            CAST(i.price AS DOUBLE PRECISION) as price,
            (CAST(sd.qty AS DOUBLE PRECISION) * CAST(i.price AS DOUBLE PRECISION)) as total,
            s.date
        FROM sales s
        JOIN sales_detals sd ON s.invoice_code = sd.id_invoice_code
        JOIN items i ON sd.id_item = i.id
        
        UNION ALL
        
        SELECT 
            'return_sales' as type,
            rs.invoice_code,
            rsd.id_item,
            CAST(rsd.qty AS DOUBLE PRECISION) as quantity,
            CAST(i.price AS DOUBLE PRECISION) as price,
            (CAST(rsd.qty AS DOUBLE PRECISION) * CAST(i.price AS DOUBLE PRECISION)) as total,
            rs.date
        FROM return_sales rs
        JOIN return_sales_detals rsd ON rs.invoice_code = rsd.id_invoice_code
        JOIN items i ON rsd.id_item = i.id
        
        UNION ALL
        
        SELECT 
            'purchases' as type,
            p.invoice_code,
            pd.id_item,
            CAST(pd.qty AS DOUBLE PRECISION) as quantity,
            CAST(i.price AS DOUBLE PRECISION) as price,
            (CAST(pd.qty AS DOUBLE PRECISION) * CAST(i.price AS DOUBLE PRECISION)) as total,
            p.date
        FROM purchases p
        JOIN purchase_details pd ON p.invoice_code = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        
        UNION ALL
        
        SELECT 
            'return_purchases' as type,
            rp.invoice_code,
            rpd.id_item,
            CAST(rpd.qty AS DOUBLE PRECISION) as quantity,
            CAST(i.price AS DOUBLE PRECISION) as price,
            (CAST(rpd.qty AS DOUBLE PRECISION) * CAST(i.price AS DOUBLE PRECISION)) as total,
            rp.date
        FROM return_purchases rp
        JOIN return_purchase_detals rpd ON rp.invoice_code = rpd.id_invoice_code
        JOIN items i ON rpd.id_item = i.id
    )
    SELECT json_agg(
        json_build_object(
            'type', type,
            'invoice_code', invoice_code,
            'item_id', id_item,
            'quantity', quantity,
            'price', price,
            'total', total,
            'date', date
        ) ORDER BY date
    ) INTO combined_data
    FROM sales_data;

    RETURN COALESCE(combined_data, '[]'::json);
END;
$$;



-- حساب المبيعات اليومية


-- حساب المبيعات اليومية المبسطة
CREATE OR REPLACE FUNCTION calculate_daily_sales_simple()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    today_date DATE;
    result_record RECORD;
    response JSON;
BEGIN
    today_date := CURRENT_DATE;
    
    SELECT 
        COUNT(DISTINCT s.id) AS invoice_count,
        COALESCE(SUM(sd.qty * sd.sell), 0.0) AS total_value
    INTO result_record
    FROM sales s
    INNER JOIN sales_detals sd ON s.id = sd.id_invoice_code
    INNER JOIN items i ON sd.id_item = i.id
    WHERE DATE(s.date) = today_date;

    response := json_build_object(
        'invoice_count', COALESCE(result_record.invoice_count, 0),
        'total_value', COALESCE(result_record.total_value, 0.0)
    );

    RETURN response;
END;
$$;



-- تحديث حساب المبيعات
CREATE OR REPLACE FUNCTION update_sale_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE sales 
    SET account_id = account_id_param 
    WHERE invoice_code = invoice_code_param::INTEGER;
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'تم تحديث الحساب بنجاح');
    ELSE
        RETURN json_build_object('success', false, 'message', 'لم يتم العثور على الفاتورة');
    END IF;
END;
$$;

-- تحديث حساب مرتجعات المبيعات
CREATE OR REPLACE FUNCTION update_return_sale_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE return_sales 
    SET account_id = account_id_param 
    WHERE invoice_code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'تم تحديث الحساب بنجاح');
    ELSE
        RETURN json_build_object('success', false, 'message', 'لم يتم العثور على الفاتورة');
    END IF;
END;
$$;

-- تحديث حساب المشتريات
CREATE OR REPLACE FUNCTION update_purchase_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE purchases 
    SET account_id = account_id_param 
    WHERE invoice_code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'تم تحديث الحساب بنجاح');
    ELSE
        RETURN json_build_object('success', false, 'message', 'لم يتم العثور على الفاتورة');
    END IF;
END;
$$;

-- تحديث حساب مرتجعات المشتريات
CREATE OR REPLACE FUNCTION update_return_purchase_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE return_purchases 
    SET account_id = account_id_param 
    WHERE invoice_code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'تم تحديث الحساب بنجاح');
    ELSE
        RETURN json_build_object('success', false, 'message', 'لم يتم العثور على الفاتورة');
    END IF;
END;
$$;



-- 1. تحديث حساب الإيداع (الدائن)
CREATE OR REPLACE FUNCTION update_deposit_credit_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_record RECORD;
BEGIN
    -- التحقق من عدم التحويل إلى نفس الحساب
    SELECT * INTO existing_record
    FROM accountdebitcode 
    WHERE accountdebit_id = account_id_param AND code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', false, 
            'message', 'لا يمكنك التحويل الى نفس الحساب'
        );
    END IF;

    -- تحديث الحساب
    UPDATE accountdebitcode
    SET accounttransf_id = account_id_param
    WHERE code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true, 
            'message', 'تم تحديث حساب الإيداع (الدائن) بنجاح'
        );
    ELSE
        RETURN json_build_object(
            'success', false, 
            'message', 'لم يتم العثور على السجل'
        );
    END IF;
END;
$$;

-- 2. تحديث حساب الإيداع (المدين)
CREATE OR REPLACE FUNCTION update_deposit_debit_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_record RECORD;
BEGIN
    -- التحقق من عدم التحويل إلى نفس الحساب
    SELECT * INTO existing_record
    FROM accountdebitcode 
    WHERE accounttransf_id = account_id_param AND code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', false, 
            'message', 'لا يمكنك التحويل الى نفس الحساب'
        );
    END IF;

    -- تحديث الحساب
    UPDATE accountdebitcode
    SET accountdebit_id = account_id_param
    WHERE code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true, 
            'message', 'تم تحديث حساب الإيداع (المدين) بنجاح'
        );
    ELSE
        RETURN json_build_object(
            'success', false, 
            'message', 'لم يتم العثور على السجل'
        );
    END IF;
END;
$$;

-- 3. تحديث حساب التحويل (الدائن)
CREATE OR REPLACE FUNCTION update_transfer_credit_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_record RECORD;
BEGIN
    -- التحقق من عدم التحويل إلى نفس الحساب
    SELECT * INTO existing_record
    FROM accounttrans 
    WHERE accountdebit_id = account_id_param AND code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', false, 
            'message', 'لا يمكنك التحويل الى نفس الحساب'
        );
    END IF;

    -- تحديث الحساب
    UPDATE accounttrans
    SET accounttransf_id = account_id_param
    WHERE code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true, 
            'message', 'تم تحديث حساب التحويل (الدائن) بنجاح'
        );
    ELSE
        RETURN json_build_object(
            'success', false, 
            'message', 'لم يتم العثور على السجل'
        );
    END IF;
END;
$$;

-- 4. تحديث حساب التحويل (المدين)
CREATE OR REPLACE FUNCTION update_transfer_debit_account(
    invoice_code_param TEXT,
    account_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_record RECORD;
BEGIN
    -- التحقق من عدم التحويل إلى نفس الحساب
    SELECT * INTO existing_record
    FROM accounttrans 
    WHERE accounttransf_id = account_id_param AND code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', false, 
            'message', 'لا يمكنك التحويل الى نفس الحساب'
        );
    END IF;

    -- تحديث الحساب
    UPDATE accounttrans
    SET accountdebit_id = account_id_param
    WHERE code = invoice_code_param;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true, 
            'message', 'تم تحديث حساب التحويل (المدين) بنجاح'
        );
    ELSE
        RETURN json_build_object(
            'success', false, 
            'message', 'لم يتم العثور على السجل'
        );
    END IF;
END;
$$;



-- وظيفة جلب جميع المعاملات المالية

DROP FUNCTION get_transactions(TEXT,TEXT,TEXT);
CREATE OR REPLACE FUNCTION get_transactions(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    conditionsa TEXT := '';
    args TEXT[] := '{}';
    argsa TEXT[] := '{}';
    sales_data JSON;
    return_sales_data JSON;
    purchases_data JSON;
    return_purchases_data JSON;
    expenses_data JSON;
    transfers_data JSON;
    deposits_data JSON;
    all_transactions JSON;
    filtered_data JSON;
    sql_query TEXT;
    arg_count INTEGER := 0;
BEGIN
    -- بناء شروط التاريخ
    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND s.date >= $' || (array_length(args, 1) + 1);
        args := array_append(args, from_date);
        
        conditionsa := conditionsa || ' AND s.date >= $' || (array_length(argsa, 1) + 1);
        argsa := array_append(argsa, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND s.date <= $' || (array_length(args, 1) + 1);
        args := array_append(args, to_date);
        
        conditionsa := conditionsa || ' AND s.date <= $' || (array_length(argsa, 1) + 1);
        argsa := array_append(argsa, to_date);
    END IF;

    -- إضافة شرط حالة التسليم للمبيعات
    IF conditionsa != '' THEN
        conditionsa := conditionsa || ' AND (s.status = ''delivered'' OR s.status IS NULL)';
    ELSE
        conditionsa := ' WHERE (s.status = ''delivered'' OR s.status IS NULL)';
    END IF;

    -- إزالة AND الزائدة من بداية الشروط
    IF conditions != '' THEN
        conditions := ' WHERE ' || substr(conditions, 6);
    END IF;

    -- جلب بيانات المبيعات
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                s.invoice_code AS code, 
                s.date AS trans_date, 
                a.name AS account_name, 
                a.id AS account_id, 
                u.username AS user_name,
                COALESCE(
                    COALESCE(SUM(
                        sd.qty * (
                            sd.sell 
                            - CASE 
                                WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (sd.sell - 
                                        CASE 
                                            WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) -
                    CASE 
                        WHEN s.type_dic = 0 THEN (
                            SUM(
                                sd.qty * (
                                    sd.sell 
                                    - CASE 
                                        WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (sd.sell - 
                                                CASE 
                                                    WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) * CAST(s.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN s.type_dic = 1 THEN CAST(s.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END +
                    CASE 
                        WHEN t.type = 0 THEN (
                            (SUM(
                                sd.qty * (
                                    sd.sell 
                                    - CASE 
                                        WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (sd.sell - 
                                                CASE 
                                                    WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) - 
                            CASE 
                                WHEN s.type_dic = 0 THEN (
                                    SUM(
                                        sd.qty * (
                                            sd.sell 
                                            - CASE 
                                                WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                                WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (sd.sell - 
                                                        CASE 
                                                            WHEN sd.type_dic = 0 THEN (sd.sell * CAST(sd.value_dic AS DOUBLE PRECISION) / 100)
                                                            WHEN sd.type_dic = 1 THEN CAST(sd.value_dic AS DOUBLE PRECISION)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                                )
                                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                        )
                                    ) * CAST(s.value_dic AS DOUBLE PRECISION) / 100
                                )
                                WHEN s.type_dic = 1 THEN CAST(s.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        ) * CAST(t.value AS DOUBLE PRECISION) / 100
                        )
                        WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                        ELSE 0
                    END, 0.0
                ) AS total_amount,
                s.date,
                ''sale'' AS type
            FROM sales s
            JOIN sales_detals sd ON s.id = sd.id_invoice_code
            JOIN items i ON sd.id_item = i.id
            LEFT JOIN account a ON s.account_id = a.id
            JOIN users u ON s.userid = u.id
            LEFT JOIN taxs t ON s.taxid = t.id
            LEFT JOIN taxs ti ON sd.taxid = ti.id
            ' || conditionsa || '
            GROUP BY s.invoice_code, s.date, a.name, a.id, u.username, s.type_dic, s.value_dic, t.type, t.value
            ORDER BY s.date DESC
        ) t';

    IF array_length(argsa, 1) > 0 THEN
        CASE array_length(argsa, 1)
            WHEN 1 THEN EXECUTE sql_query INTO sales_data USING argsa[1];
            WHEN 2 THEN EXECUTE sql_query INTO sales_data USING argsa[1], argsa[2];
            ELSE EXECUTE sql_query INTO sales_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO sales_data;
    END IF;

    -- جلب بيانات إرجاع المبيعات
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                rs.invoice_code AS code, 
                rs.date AS trans_date, 
                a.name AS account_name, 
                a.id AS account_id, 
                u.username AS user_name,
                COALESCE(
                    COALESCE(SUM(
                        rsd.qty * (
                            rsd.sell 
                            - CASE 
                                WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (rsd.sell - 
                                        CASE 
                                            WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) -
                    CASE 
                        WHEN rs.type_dic = 0 THEN (
                            SUM(
                                rsd.qty * (
                                    rsd.sell 
                                    - CASE 
                                        WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (rsd.sell - 
                                                CASE 
                                                    WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) * CAST(rs.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN rs.type_dic = 1 THEN CAST(rs.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END +
                    CASE 
                        WHEN t.type = 0 THEN (
                            (SUM(
                                rsd.qty * (
                                    rsd.sell 
                                    - CASE 
                                        WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (rsd.sell - 
                                                CASE 
                                                    WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) - 
                            CASE 
                                WHEN rs.type_dic = 0 THEN (
                                    SUM(
                                        rsd.qty * (
                                            rsd.sell 
                                            - CASE 
                                                WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                                WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (rsd.sell - 
                                                        CASE 
                                                            WHEN rsd.type_dic = 0 THEN (rsd.sell * CAST(rsd.value_dic AS DOUBLE PRECISION) / 100)
                                                            WHEN rsd.type_dic = 1 THEN CAST(rsd.value_dic AS DOUBLE PRECISION)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                                )
                                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                        )
                                    ) * CAST(rs.value_dic AS DOUBLE PRECISION) / 100
                                )
                                WHEN rs.type_dic = 1 THEN CAST(rs.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        ) * CAST(t.value AS DOUBLE PRECISION) / 100
                        )
                        WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                        ELSE 0
                    END, 0.0
                ) AS total_amount,
                rs.date,
                ''rsale'' AS type
            FROM return_sales rs
            JOIN return_sales_detals rsd ON rs.id = rsd.id_invoice_code
            JOIN items i ON rsd.id_item = i.id
            LEFT JOIN account a ON rs.account_id = a.id
            JOIN users u ON rs.userid = u.id
            LEFT JOIN taxs t ON rs.taxid = t.id
            LEFT JOIN taxs ti ON rsd.taxid = ti.id
            ' || COALESCE(conditions, '') || '
            GROUP BY rs.invoice_code, rs.date, a.name, a.id, u.username, rs.type_dic, rs.value_dic, t.type, t.value
            ORDER BY rs.date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO return_sales_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO return_sales_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO return_sales_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO return_sales_data;
    END IF;

    -- جلب بيانات المشتريات
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                p.invoice_code AS code, 
                p.date AS trans_date, 
                a.name AS account_name, 
                a.id AS account_id, 
                u.username AS user_name,
                COALESCE(
                    COALESCE(SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) -
                    CASE 
                        WHEN p.type_dic = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.price 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.price - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END +
                    CASE 
                        WHEN t.type = 0 THEN (
                            (SUM(
                                pd.qty * (
                                    pd.price 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.price - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.price 
                                            - CASE 
                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (pd.price - 
                                                        CASE 
                                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                                )
                                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                        )
                                    ) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                                )
                                WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        ) * CAST(t.value AS DOUBLE PRECISION) / 100
                        )
                        WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                        ELSE 0
                    END + CAST(p.charge_price AS DOUBLE PRECISION), 0.0
                ) AS total_amount,
                p.date,
                ''pur'' AS type
            FROM purchases p
            JOIN purchase_details pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            LEFT JOIN account a ON p.account_id = a.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            JOIN users u ON p.userid = u.id
            ' || COALESCE(conditions, '') || '
            GROUP BY p.invoice_code, p.date, a.name, a.id, u.username, p.type_dic, p.value_dic, t.type, t.value, p.charge_price
            ORDER BY p.date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO purchases_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO purchases_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO purchases_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO purchases_data;
    END IF;

    -- جلب بيانات إرجاع المشتريات
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                rp.invoice_code AS code, 
                rp.date AS trans_date, 
                a.name AS account_name, 
                a.id AS account_id, 
                u.username AS user_name,
                COALESCE(
                    COALESCE(SUM(
                        rpd.qty * (
                            rpd.price 
                            - CASE 
                                WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (rpd.price - 
                                        CASE 
                                            WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) -
                    CASE 
                        WHEN rp.type_dic = 0 THEN (
                            SUM(
                                rpd.qty * (
                                    rpd.price 
                                    - CASE 
                                        WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (rpd.price - 
                                                CASE 
                                                    WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) * CAST(rp.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN rp.type_dic = 1 THEN CAST(rp.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END +
                    CASE 
                        WHEN t.type = 0 THEN (
                            (SUM(
                                rpd.qty * (
                                    rpd.price 
                                    - CASE 
                                        WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (rpd.price - 
                                                CASE 
                                                    WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) - 
                            CASE 
                                WHEN rp.type_dic = 0 THEN (
                                    SUM(
                                        rpd.qty * (
                                            rpd.price 
                                            - CASE 
                                                WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                                WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (rpd.price - 
                                                        CASE 
                                                            WHEN rpd.type_dic = 0 THEN (rpd.price * CAST(rpd.value_dic AS DOUBLE PRECISION) / 100)
                                                            WHEN rpd.type_dic = 1 THEN CAST(rpd.value_dic AS DOUBLE PRECISION)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                                )
                                                WHEN CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                                ELSE 0
                                            END
                                        )
                                    ) * CAST(rp.value_dic AS DOUBLE PRECISION) / 100
                                )
                                WHEN rp.type_dic = 1 THEN CAST(rp.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        ) * CAST(t.value AS DOUBLE PRECISION) / 100
                        )
                        WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                        ELSE 0
                    END + CAST(rp.charge_price AS DOUBLE PRECISION), 0.0
                ) AS total_amount,
                rp.date,
                ''rpur'' AS type
            FROM return_purchases rp
            JOIN return_purchase_detals rpd ON rp.id = rpd.id_invoice_code
            JOIN items i ON rpd.id_item = i.id
            LEFT JOIN taxs t ON rp.taxid = t.id
            LEFT JOIN taxs ti ON rpd.taxid = ti.id
            LEFT JOIN account a ON rp.account_id = a.id
            JOIN users u ON rp.userid = u.id
            ' || COALESCE(conditions, '') || '
            GROUP BY rp.invoice_code, rp.date, a.name, a.id, u.username, rp.type_dic, rp.value_dic, t.type, t.value, rp.charge_price
            ORDER BY rp.date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO return_purchases_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO return_purchases_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO return_purchases_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO return_purchases_data;
    END IF;

    -- جلب بيانات المصاريف
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                e.id AS code, 
                e.date AS trans_date, 
                a.name AS account_name, 
                a.id AS account_id, 
                u.username AS user_name, 
                CAST(e.price AS DOUBLE PRECISION) AS total_amount, 
                e.date,
                ''expensive'' AS type
            FROM expansive e
            LEFT JOIN account a ON e.account_id = a.id
            JOIN users u ON e.userid = u.id
            ' || COALESCE(conditions, '') || '
            ORDER BY e.date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO expenses_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO expenses_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO expenses_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO expenses_data;
    END IF;

    -- جلب بيانات التحويلات
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                at.code AS code, 
                at.date AS trans_date, 
                ad.name AS account_name, 
                ad.id AS account_id, 
                atu.username AS user_name, 
                CAST(at.balance AS DOUBLE PRECISION) AS total_amount, 
                at.date, 
                ''transfer_debit'' AS type
            FROM accounttrans at
            JOIN account ad ON at.accountdebit_id = ad.id
            JOIN users atu ON at.userid = atu.id
            ' || COALESCE(conditions, '') || '
            UNION ALL
            SELECT 
                at.code AS code, 
                at.date AS trans_date, 
                atr.name AS account_name, 
                atr.id AS account_id, 
                atu.username AS user_name, 
                CAST(-at.balance AS DOUBLE PRECISION) AS total_amount, 
                at.date, 
                ''transfer_credit'' AS type
            FROM accounttrans at
            JOIN account atr ON at.accounttransf_id = atr.id
            JOIN users atu ON at.userid = atu.id
            ' || COALESCE(conditions, '') || '
            ORDER BY trans_date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO transfers_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO transfers_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO transfers_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO transfers_data;
    END IF;

    -- جلب بيانات الودائع
    sql_query := '
        SELECT json_agg(t) FROM (
            SELECT 
                at.code AS code, 
                at.date AS trans_date, 
                ad.name AS account_name, 
                ad.id AS account_id, 
                atu.username AS user_name, 
                CAST(at.balance AS DOUBLE PRECISION) AS total_amount, 
                at.date, 
                ''deposit_debit'' AS type
            FROM accountdebitcode at
            JOIN account ad ON at.accountdebit_id = ad.id
            JOIN users atu ON at.userid = atu.id
            ' || COALESCE(conditions, '') || '
            UNION ALL
            SELECT 
                at.code AS code, 
                at.date AS trans_date, 
                atr.name AS account_name, 
                atr.id AS account_id, 
                atu.username AS user_name, 
                CAST(-at.balance AS DOUBLE PRECISION) AS total_amount, 
                at.date, 
                ''deposit_credit'' AS type
            FROM accountdebitcode at
            JOIN account atr ON at.accounttransf_id = atr.id
            JOIN users atu ON at.userid = atu.id
            ' || COALESCE(conditions, '') || '
            ORDER BY trans_date DESC
        ) t';

    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO deposits_data USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO deposits_data USING args[1], args[2];
            ELSE EXECUTE sql_query INTO deposits_data;
        END CASE;
    ELSE
        EXECUTE sql_query INTO deposits_data;
    END IF;

    -- دمج جميع البيانات
   WITH CombinedData AS (
        SELECT * FROM json_array_elements(COALESCE(sales_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(return_sales_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(purchases_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(return_purchases_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(expenses_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(transfers_data, '[]'::json))
        UNION ALL
        SELECT * FROM json_array_elements(COALESCE(deposits_data, '[]'::json))
    )
    SELECT json_agg(value) INTO all_transactions
    FROM CombinedData;

    -- فلترة البيانات إذا كان هناك استعلام بحث
    IF query_text IS NOT NULL AND query_text != '' THEN
        SELECT json_agg(t) INTO filtered_data
        FROM json_array_elements(all_transactions) t
        WHERE t->>'code' ILIKE '%' || query_text || '%';
        
        RETURN COALESCE(filtered_data, '[]'::JSON);
    ELSE
        RETURN COALESCE(all_transactions, '[]'::JSON);
    END IF;

EXCEPTION
    WHEN others THEN
        RETURN json_build_object('error', SQLERRM);
END;
$$;

DROP FUNCTION get_all_return_sales(TEXT,TEXT,TEXT);
CREATE OR REPLACE FUNCTION get_all_return_sales(
    id_param TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result JSON;
    sql_query TEXT;
BEGIN
    -- بناء شروط البحث
    IF id_param IS NOT NULL AND id_param != '' THEN
        conditions := conditions || ' AND (p.invoice_code ILIKE $' || (array_length(args, 1) + 1)::TEXT 
                   || ' OR sal.invoice_code ILIKE $' || (array_length(args, 1) + 2)::TEXT || ')';
        args := array_append(args, '%' || id_param || '%');
        args := array_append(args, '%' || id_param || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || (array_length(args, 1) + 1)::TEXT;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || (array_length(args, 1) + 1)::TEXT;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions تبدأ بها
    IF conditions != '' THEN
        conditions := ' WHERE ' || substr(conditions, 5);
    END IF;

    -- بناء الاستعلام بشكل صحيح
    sql_query := '
        SELECT json_agg(results) FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                cus.name AS customername,
                cus.id AS customerid,
                s.name AS stockname,
                dy.name AS deliveryname,
                u.name AS username,
                sal.invoice_code AS invcode,
                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ), 0.0) AS "total",
                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",
                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                        + CASE 
                                            WHEN ti.type = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN ti.type = 1 THEN ti.value
                                            ELSE 0
                                        END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            FROM return_sales p
            JOIN return_sales_detals pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN users u ON p.userid = u.id
            LEFT JOIN sales sal ON p.sales_id = sal.id
            JOIN customers cus ON p.id_customer = cus.id
            LEFT JOIN delivery dy ON p.id_delivery = dy.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            ' || COALESCE(conditions, '') || '
            GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, sal.invoice_code, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) results';

    -- تنفيذ الاستعلام مع المعلمات بشكل صحيح
    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO result USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO result USING args[1], args[2];
            WHEN 3 THEN EXECUTE sql_query INTO result USING args[1], args[2], args[3];
            WHEN 4 THEN EXECUTE sql_query INTO result USING args[1], args[2], args[3], args[4];
        END CASE;
    ELSE
        EXECUTE sql_query INTO result;
    END IF;

    RETURN COALESCE(result, '[]'::JSON);
END;
$$;

-- إضافة العمود إذا كنت تريده
ALTER TABLE job_details ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- حذف الدوال القديمة إذا كانت موجودة
DROP FUNCTION IF EXISTS get_all_job_details(TEXT);
DROP FUNCTION IF EXISTS get_all_job_details(JSON);
DROP FUNCTION IF EXISTS get_all_job_details(JSON);
-- إسقاط الدالة إذا كانت موجودة أولاً
DROP FUNCTION IF EXISTS get_all_job_details(JSON);

-- إنشاء الدالة بالشكل الصحيح
CREATE OR REPLACE FUNCTION get_all_job_details(params JSON)
RETURNS JSON
LANGUAGE PLPGSQL
AS $$
DECLARE
    search_query TEXT;
    result JSON;
BEGIN
    search_query := COALESCE(params->>'search_query', '');
    
    SELECT json_agg(row_to_json(t)) INTO result
    FROM (
        SELECT 
            jd.*,
            j.name AS jobname
        FROM jobs j
        LEFT JOIN job_details jd ON j.id = jd.id_job  
        WHERE j.id::TEXT LIKE '%' || search_query || '%'
        OR j.name LIKE '%' || search_query || '%'
    ) t;
    
    RETURN COALESCE(result, '[]'::JSON);
END;
$$;

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION get_all_job_details(JSON) TO anon;
GRANT EXECUTE ON FUNCTION get_all_job_details(JSON) TO anon;

-- منح الإذن للدور anon
GRANT EXECUTE ON FUNCTION get_all_job_details(JSON) TO anon;

-- 1. وظيفة المبيعات الأسبوعية
CREATE OR REPLACE FUNCTION calculate_weekly_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_week DATE;
    end_of_week DATE;
    tax DOUBLE PRECISION := 0.0;
    paidTotal DOUBLE PRECISION := 0.0;
    dic DOUBLE PRECISION := 0.0;
    total DOUBLE PRECISION := 0.0;
    count INTEGER := 0;
    profit DOUBLE PRECISION := 0.0;
    result_record RECORD;
    response JSON;
BEGIN
    start_of_week := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_of_week := (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE;
    
    FOR result_record IN (
        SELECT 
            COUNT(DISTINCT sales.id) AS invoice_count, 
            SUM(sales_detals.qty * sales_detals.sell) AS total_value1,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = sales.invoice_code), 0.0) AS paid,
            COALESCE(SUM(
                sales_detals.qty * (
                    sales_detals.sell 
                    - CASE 
                        WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                        WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (sales_detals.sell - 
                                CASE 
                                    WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                    WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                        ELSE 0
                    END
                )
            ), 0.0) AS total_value,
            CASE 
                WHEN sales.type_dic = 0 THEN (
                    SUM(
                        sales_detals.qty * (
                            sales_detals.sell 
                            - CASE 
                                WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (sales_detals.sell - 
                                        CASE 
                                            WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ) * CAST(sales.value_dic AS DOUBLE PRECISION) / 100
                )
                WHEN sales.type_dic = 1 THEN CAST(sales.value_dic AS DOUBLE PRECISION)
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN t.type = 0 THEN (
                    (SUM(
                        sales_detals.qty * (
                            sales_detals.sell 
                            - CASE 
                                WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (sales_detals.sell - 
                                        CASE 
                                            WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ) - CASE 
                        WHEN sales.type_dic = 0 THEN (
                            SUM(
                                sales_detals.qty * (
                                    sales_detals.sell 
                                    - CASE 
                                        WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (sales_detals.sell - 
                                                CASE 
                                                    WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ) * CAST(sales.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN sales.type_dic = 1 THEN CAST(sales.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END) * CAST(t.value AS DOUBLE PRECISION) / 100
                )
                WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                ELSE 0
            END AS total_tax,
            COALESCE(SUM(
                sales_detals.qty * (
                    (
                        sales_detals.sell 
                        - CASE 
                            WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                            WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                            ELSE 0
                        END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (sales_detals.sell - 
                                    CASE 
                                        WHEN sales_detals.type_dic = 0 THEN (sales_detals.sell * CAST(sales_detals.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN sales_detals.type_dic = 1 THEN CAST(sales_detals.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                            ELSE 0
                        END
                    )
                    - sales_detals.price
                )
            ), 0.0) AS total_profit
        FROM sales 
        INNER JOIN sales_detals ON sales.id = sales_detals.id_invoice_code
        INNER JOIN items ON sales_detals.id_item = items.id
        LEFT JOIN taxs t ON sales.taxid = t.id
        LEFT JOIN taxs ti ON sales_detals.taxid = ti.id
        WHERE DATE(sales.date) BETWEEN start_of_week AND end_of_week 
        AND (sales.status = 'delivered' OR sales.status IS NULL)
        GROUP BY sales.id, sales.type_dic, sales.value_dic, t.type, t.value
    ) LOOP
        tax := tax + COALESCE(result_record.total_tax, 0.0);
        paidTotal := paidTotal + COALESCE(result_record.paid, 0.0);
        dic := dic + COALESCE(result_record.total_discount, 0.0);
        total := total + COALESCE(result_record.total_value, 0.0);
        profit := profit + COALESCE(result_record.total_profit, 0.0);
        count := count + COALESCE(result_record.invoice_count, 0);
    END LOOP;

    response := json_build_object(
        'total_tax', tax,
        'invoice_count', count,
        'total_discount', dic,
        'total_value', total,
        'total_profit', profit,
        'paid', paidTotal
    );

    RETURN response;
END;
$$;


-- 3. وظيفة إجمالي المبيعات


-- 4. وظيفة مرتجعات المبيعات
CREATE OR REPLACE FUNCTION calculate_return_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_record RECORD;
    response JSON;
BEGIN
    SELECT 
        COUNT(DISTINCT return_sales.id) AS invoice_count, 
        SUM(return_sales_detals.qty * return_sales_detals.sell) AS total_value
    INTO result_record
    FROM return_sales 
    INNER JOIN return_sales_detals ON return_sales.id = return_sales_detals.id_invoice_code
    INNER JOIN items ON return_sales_detals.id_item = items.id;

    response := json_build_object(
        'invoice_count', COALESCE(result_record.invoice_count, 0),
        'total_value', COALESCE(result_record.total_value, 0.0)
    );

    RETURN response;
END;
$$;

-- 5. وظيفة المبيعات السنوية






-- 6. وظيفة المصاريف اليومية


-- 7. وظيفة المصاريف الأسبوعية
CREATE OR REPLACE FUNCTION calculate_weekly_expenses()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_week DATE;
    end_of_week DATE;
    result_record RECORD;
    response JSON;
BEGIN
    start_of_week := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_of_week := (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE;
    
    SELECT 
        COUNT(*) AS invoice_count, 
        COALESCE(SUM(price), 0.0) AS total_value
    INTO result_record
    FROM expansive
    WHERE DATE(date) BETWEEN start_of_week AND end_of_week;

    response := json_build_object(
        'invoice_count', COALESCE(result_record.invoice_count, 0),
        'total_value', COALESCE(result_record.total_value, 0.0)
    );

    RETURN response;
END;
$$;

-- 8. وظيفة المصاريف بين تاريخين
CREATE OR REPLACE FUNCTION calculate_between_expenses(
    start_date TEXT,
    end_date TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_record RECORD;
    response JSON;
BEGIN
    SELECT 
        COUNT(*) AS invoice_count, 
        COALESCE(SUM(price), 0.0) AS total_value
    INTO result_record
    FROM expansive
    WHERE DATE(date) BETWEEN start_date::DATE AND end_date::DATE;

    response := json_build_object(
        'invoice_count', COALESCE(result_record.invoice_count, 0),
        'total_value', COALESCE(result_record.total_value, 0.0)
    );

    RETURN response;
END;
$$;




-- 1. وظيفة المبيعات الشهرية


DROP FUNCTION get_yearly_sales(TEXT,TEXT);
CREATE OR REPLACE FUNCTION get_yearly_sales(start_year TEXT, end_year TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    yearly_data JSON;
BEGIN
    WITH InvoiceItems AS (
        SELECT 
            pd.id_invoice_code,
            pd.qty * (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                        (pd.sell - 
                            CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
            ) AS item_total
        FROM sales_detals pd
        LEFT JOIN taxs ti ON pd.taxid = ti.id
    ),
    InvoiceTotals AS (
        SELECT 
            id_invoice_code,
            SUM(item_total) AS gross_total
        FROM InvoiceItems
        GROUP BY id_invoice_code
    ),
    InvoiceDiscounts AS (
        SELECT 
            p.id AS invoice_id,
            CASE 
                WHEN p.type_dic = 0 THEN (it.gross_total * p.value_dic / 100)
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS total_discount
        FROM sales p
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
    ),
    InvoiceTaxes AS (
        SELECT 
            p.id AS invoice_id,
            CASE 
                WHEN t.type = 0 THEN ((it.gross_total - id.total_discount) * t.value / 100)
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS total_tax
        FROM sales p
        LEFT JOIN taxs t ON p.taxid = t.id
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
        JOIN InvoiceDiscounts id ON p.id = id.invoice_id
    )
    SELECT json_agg(row_to_json(t))
    INTO yearly_data
    FROM (
        SELECT 
            SUBSTRING(p.date FROM 1 FOR 4)::INTEGER AS year,
            SUM(it.gross_total) AS total_sales,
            SUM(id.total_discount) AS total_discount,
            SUM(itx.total_tax) AS total_tax
        FROM sales p
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
        JOIN InvoiceDiscounts id ON p.id = id.invoice_id
        JOIN InvoiceTaxes itx ON p.id = itx.invoice_id                       
        WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER BETWEEN start_year::INTEGER AND end_year::INTEGER
            AND (p.status = 'delivered' OR p.status IS NULL)
        GROUP BY SUBSTRING(p.date FROM 1 FOR 4)::INTEGER
        ORDER BY year
    ) t;

    RETURN COALESCE(yearly_data, '[]'::json);
END;
$$;


-- 1. وظيفة إضافة دفعة جديدة أو تحديثها
CREATE OR REPLACE FUNCTION add_batch(
    item_id_param INTEGER,
    stock_id_param INTEGER,
    quantity_param DOUBLE PRECISION,
    purchase_detail_id_param INTEGER DEFAULT NULL,
    expiry_date_param TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_batch RECORD;
    new_purchase_detail_id INTEGER;
    response JSON;
BEGIN
    -- إذا كان purchase_detail_id موجودًا، نتأكد من عدم التكرار
    IF purchase_detail_id_param IS NOT NULL AND purchase_detail_id_param > 0 THEN
        SELECT * INTO existing_batch
        FROM batches 
        WHERE purchase_detail_id = purchase_detail_id_param AND stock_id = stock_id_param;
        
        IF FOUND THEN
            -- دفعة موجودة → نُضيف الكمية
            UPDATE batches 
            SET quantity = quantity + quantity_param 
            WHERE purchase_detail_id = purchase_detail_id_param AND stock_id = stock_id_param;
            
            response := json_build_object(
                'success', true,
                'message', 'تم تحديث الدفعة الموجودة',
                'action', 'updated'
            );
            RETURN response;
        END IF;
    END IF;

    -- إدخال دفعة جديدة
    IF purchase_detail_id_param IS NOT NULL AND purchase_detail_id_param > 0 THEN
        new_purchase_detail_id := purchase_detail_id_param;
    ELSE
        new_purchase_detail_id := EXTRACT(EPOCH FROM NOW())::INTEGER;
    END IF;

    INSERT INTO batches (
        item_id,
        stock_id,
        purchase_detail_id,
        expiry_date,
        quantity,
        created_at
    ) VALUES (
        item_id_param,
        stock_id_param,
        new_purchase_detail_id,
        expiry_date_param,
        quantity_param,
        NOW()
    );

    response := json_build_object(
        'success', true,
        'message', 'تم إنشاء دفعة جديدة',
        'action', 'created',
        'purchase_detail_id', new_purchase_detail_id
    );

    RETURN response;

EXCEPTION
    WHEN others THEN
        response := json_build_object(
            'success', false,
            'message', 'خطأ في إضافة الدفعة: ' || SQLERRM
        );
        RETURN response;
END;
$$;


-- 2. وظيفة تقليل كمية الدفعة
CREATE OR REPLACE FUNCTION decrease_batch(
    item_id_param INTEGER,
    stock_id_param INTEGER,
    quantity_param DOUBLE PRECISION,
    purchase_detail_id_param INTEGER DEFAULT NULL,
    check_qty BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    remaining_quantity DOUBLE PRECISION;
    batch_record RECORD;
    response JSON;
BEGIN
    IF purchase_detail_id_param IS NOT NULL AND purchase_detail_id_param > 0 THEN
        -- تقليل من دفعة معينة
        UPDATE batches 
        SET quantity = quantity - quantity_param
        WHERE item_id = item_id_param 
        AND stock_id = stock_id_param 
        AND purchase_detail_id = purchase_detail_id_param;
        
        -- تحقق أن لم تصبح سالبة
        IF check_qty THEN
            SELECT quantity INTO remaining_quantity
            FROM batches 
            WHERE purchase_detail_id = purchase_detail_id_param 
            AND stock_id = stock_id_param;
            
            IF remaining_quantity < 0 THEN
                -- تراجع عن التحديث
                UPDATE batches 
                SET quantity = quantity + quantity_param
                WHERE purchase_detail_id = purchase_detail_id_param 
                AND stock_id = stock_id_param;
                
                RAISE EXCEPTION 'الكمية لا يمكن أن تكون سالبة للدفعة: %', purchase_detail_id_param;
            END IF;
        END IF;
        
        response := json_build_object(
            'success', true,
            'message', 'تم تقليل كمية الدفعة المحددة'
        );
    ELSE
        -- إذا لم تُحدد الدفعة، استخدم FEFO
        response := sell_from_batches(
            item_id_param,
            stock_id_param,
            quantity_param,
            check_qty
        );
    END IF;

    RETURN response;

EXCEPTION
    WHEN others THEN
        response := json_build_object(
            'success', false,
            'message', 'خطأ في تقليل الدفعة: ' || SQLERRM
        );
        RETURN response;
END;
$$;

-- 3. وظيفة البيع من الدفعات (FEFO)
CREATE OR REPLACE FUNCTION sell_from_batches(
    item_id_param INTEGER,
    stock_id_param INTEGER,
    quantity_param DOUBLE PRECISION,
    check_qty BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    remaining DOUBLE PRECISION := quantity_param;
    batch_record RECORD;
    take DOUBLE PRECISION;
    response JSON;
BEGIN
    -- جلب الدفعات المرتبة حسب انتهاء الصلاحية (الأقرب أولًا)
    FOR batch_record IN (
        SELECT id, quantity, purchase_detail_id
        FROM batches
        WHERE item_id = item_id_param 
        AND stock_id = stock_id_param 
        AND quantity > 0
        ORDER BY 
            CASE WHEN expiry_date IS NULL THEN 1 ELSE 0 END,
            expiry_date ASC
    ) LOOP
        IF remaining <= 0 THEN
            EXIT;
        END IF;

        take := LEAST(remaining, batch_record.quantity);

        UPDATE batches 
        SET quantity = quantity - take
        WHERE id = batch_record.id;

        remaining := remaining - take;
    END LOOP;

    IF check_qty AND remaining > 0 THEN
        RAISE EXCEPTION 'الكمية غير كافية للبيع: % (ناقص: %)', item_id_param, remaining;
    END IF;

    response := json_build_object(
        'success', true,
        'message', 'تم البيع من الدفعات بنجاح',
        'remaining', remaining
    );

    RETURN response;

EXCEPTION
    WHEN others THEN
        response := json_build_object(
            'success', false,
            'message', 'خطأ في البيع من الدفعات: ' || SQLERRM
        );
        RETURN response;
END;
$$;

-- 4. وظيفة البيع من دفعة محددة
CREATE OR REPLACE FUNCTION sell_from_specific_batch(
    purchase_detail_id_param INTEGER,
    stock_id_param INTEGER,
    quantity_param DOUBLE PRECISION,
    check_qty BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    available_quantity DOUBLE PRECISION;
    batch_record RECORD;
    response JSON;
BEGIN
    -- التحقق من أن الدفعة موجودة
    SELECT quantity INTO available_quantity
    FROM batches 
    WHERE purchase_detail_id = purchase_detail_id_param 
    AND stock_id = stock_id_param;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'الدفعة غير موجودة: %', purchase_detail_id_param;
    END IF;

    -- التحقق من أن الكمية كافية
    IF check_qty AND available_quantity < quantity_param THEN
        RAISE EXCEPTION 'الكمية غير كافية في الدفعة: المتوفر %, المطلوب %', 
            available_quantity, quantity_param;
    END IF;

    -- تقليل الكمية من هذه الدفعة فقط
    UPDATE batches 
    SET quantity = quantity - quantity_param
    WHERE purchase_detail_id = purchase_detail_id_param 
    AND stock_id = stock_id_param;

    response := json_build_object(
        'success', true,
        'message', 'تم البيع من الدفعة المحددة بنجاح'
    );

    RETURN response;

EXCEPTION
    WHEN others THEN
        response := json_build_object(
            'success', false,
            'message', 'خطأ في البيع من الدفعة المحددة: ' || SQLERRM
        );
        RETURN response;
END;
$$;

-- 5. وظيفة إرجاع كمية إلى دفعة محددة
CREATE OR REPLACE FUNCTION return_qty_to_specific_batch(
    purchase_detail_id_param INTEGER,
    stock_id_param INTEGER,
    quantity_param DOUBLE PRECISION
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    existing_batch RECORD;
    item_id_val INTEGER;
    stock_id_val INTEGER;
    response JSON;
BEGIN
    -- تحقق من وجود الدفعة
    SELECT * INTO existing_batch
    FROM batches 
    WHERE purchase_detail_id = purchase_detail_id_param 
    AND stock_id = stock_id_param;

    IF FOUND THEN
        -- الدفعة موجودة → أضف الكمية
        UPDATE batches 
        SET quantity = quantity + quantity_param
        WHERE purchase_detail_id = purchase_detail_id_param 
        AND stock_id = stock_id_param;
        
        response := json_build_object(
            'success', true,
            'message', 'تم إضافة الكمية إلى الدفعة الموجودة'
        );
    ELSE
        -- الدفعة غير موجودة → أنشئ دفعة جديدة
        -- جلب معلومات الصنف والمخزن من تفاصيل المشتريات
        SELECT 
            pd.id_item,
            p.id_stock
        INTO 
            item_id_val,
            stock_id_val
        FROM purchase_details pd
        JOIN purchases p ON p.id = pd.id_invoice_code
        WHERE pd.id = purchase_detail_id_param;

        IF FOUND THEN
            INSERT INTO batches (
                item_id,
                stock_id,
                purchase_detail_id,
                quantity,
                created_at
            ) VALUES (
                item_id_val,
                stock_id_val,
                purchase_detail_id_param,
                quantity_param,
                NOW()
            );
            
            response := json_build_object(
                'success', true,
                'message', 'تم إنشاء دفعة جديدة وإضافة الكمية'
            );
        ELSE
            RAISE EXCEPTION 'لم يتم العثور على تفاصيل الشراء للدفعة: %', purchase_detail_id_param;
        END IF;
    END IF;

    RETURN response;

EXCEPTION
    WHEN others THEN
        response := json_build_object(
            'success', false,
            'message', 'خطأ في إرجاع الكمية: ' || SQLERRM
        );
        RETURN response;
END;
$$;

-- 1. الحصول على الدُفعات النشطة
CREATE OR REPLACE FUNCTION get_active_batches(
    item_id_param INTEGER,
    stock_id_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'purchase_detail_id', purchase_detail_id,
            'quantity', quantity,
            'expiry_date', expiry_date
        )
    ) INTO result_json
    FROM batches
    WHERE item_id = item_id_param 
        AND stock_id = stock_id_param 
        AND quantity > 0
    ORDER BY expiry_date ASC NULLS LAST;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 2. جلب الأصناف المباعة حديثاً
CREATE OR REPLACE FUNCTION fetch_recent_sold_items()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH 
    purchased_items AS (
        SELECT 
            i.id, 
            i.name, 
            i.date, 
            inv.name AS stock_name
        FROM items i
        INNER JOIN purchase_details pd ON i.id = pd.id_item
        INNER JOIN purchases p ON pd.id_invoice_code = p.id
        INNER JOIN inventory inv ON p.id_stock = inv.id
    ),
    transferred_items AS (
        SELECT 
            i.id, 
            i.name, 
            i.date, 
            inv.name AS stock_name
        FROM items i
        INNER JOIN transf_stock_details tsd ON i.id = tsd.id_item
        INNER JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        INNER JOIN inventory inv ON ts.id_from_stock = inv.id
        UNION ALL
        SELECT 
            i.id, 
            i.name, 
            i.date, 
            inv.name AS stock_name
        FROM items i
        INNER JOIN transf_stock_details tsd ON i.id = tsd.id_item
        INNER JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        INNER JOIN inventory inv ON ts.id_to_stock = inv.id
    )
    SELECT json_agg(
        json_build_object(
            'id', id,
            'name', name,
            'date', date,
            'stock_name', stock_name
        )
    ) INTO result_json
    FROM (
        SELECT DISTINCT id, name, date, stock_name
        FROM (
            SELECT * FROM purchased_items
            UNION ALL
            SELECT * FROM transferred_items
        ) AS combined_items
        ORDER BY date DESC
        LIMIT 10
    ) AS final_results;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 3. تحميل بيانات المخزون
CREATE OR REPLACE FUNCTION load_stock_data(
    _selected_stock TEXT,
    _search_users TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
    query_text TEXT;
BEGIN
    IF _selected_stock IS NULL THEN
        RETURN '[]'::json;
    END IF;

    query_text := '%' || COALESCE(_search_users, '') || '%';

    SELECT json_agg(
        json_build_object(
            'batch_id', batch_id::TEXT,
            'item_id', item_id::TEXT,
            'name', name::TEXT,
            'price', price,
            'sell', sell,
            'quantity', quantity,
            'expiry_date', expiry_date::TEXT,
            'tyname', tyname::TEXT
        )
    ) INTO result_json
    FROM (
        SELECT 
            b.id AS batch_id,
            i.id AS item_id,
            i.name,
            i.price,
            i.sell,
            b.quantity,
            b.expiry_date,
            ty.name AS tyname
        FROM batches b
        JOIN items i ON b.item_id = i.id
        LEFT JOIN type_items ty ON i.id_itemtype = ty.id
        WHERE b.stock_id = _selected_stock::INTEGER 
            AND i.name LIKE query_text
            AND b.quantity IS NOT NULL
            AND b.quantity != 0
            AND b.quantity != 0.0
            AND b.quantity > 0
        ORDER BY i.name, b.expiry_date ASC NULLS LAST
    ) AS stock_data;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 4. الحصول على الأصناف منخفضة المخزون
CREATE OR REPLACE FUNCTION get_low_stock_items154(
    show_by_batch BOOLEAN
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    IF show_by_batch THEN
        -- عرض حسب الدُفعات
        SELECT json_agg(
            json_build_object(
                'item_id', item_id,
                'item_name', item_name,
                'expiry_date', expiry_date,
                'batch_quantity', batch_quantity,
                'purchase_detail_id', purchase_detail_id,
                'stock_name', stock_name,
                'alert_qty', alert_qty,
                'username', username
            )
        ) INTO result_json
        FROM (
            SELECT 
                i.id AS item_id,
                i.name AS item_name,
                b.expiry_date AS expiry_date,
                b.quantity AS batch_quantity,
                b.purchase_detail_id,
                inv.name AS stock_name,
                i.alert_qty,
                u.name AS username
            FROM batches b
            JOIN items i ON b.item_id = i.id
            JOIN inventory inv ON b.stock_id = inv.id
            LEFT JOIN users u ON inv.userid = u.id
            WHERE 
                i.alert_qty IS NOT NULL
                AND i.alert_qty != 0
                AND i.alert_qty != 0.0
                AND i.alert_qty > 0
                AND b.quantity <= i.alert_qty
                AND b.quantity > 0
            ORDER BY b.quantity ASC
        ) AS batch_results;
    ELSE
        -- عرض الأصناف مجمعة
        SELECT json_agg(
            json_build_object(
                'item_id', item_id,
                'item_name', item_name,
                'final_quantity', final_quantity,
                'stock_name', stock_name,
                'alert_qty', alert_qty,
                'username', username
            )
        ) INTO result_json
        FROM (
            SELECT 
                i.id AS item_id,
                i.name AS item_name,
                SUM(b.quantity) AS final_quantity,
                inv.name AS stock_name,
                i.alert_qty,
                u.name AS username
            FROM batches b
            JOIN items i ON b.item_id = i.id
            JOIN inventory inv ON b.stock_id = inv.id
            LEFT JOIN users u ON inv.userid = u.id
            WHERE 
                i.alert_qty IS NOT NULL
                AND i.alert_qty != 0
                AND i.alert_qty != 0.0
                AND i.alert_qty > 0
            GROUP BY i.id, inv.id, u.name
            HAVING SUM(b.quantity) <= i.alert_qty
            ORDER BY final_quantity ASC
        ) AS aggregated_results;
    END IF;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 5. الحصول على الأصناف المنتهية الصلاحية
CREATE OR REPLACE FUNCTION get_expired_items()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            b.expiry_date AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            b.quantity AS final_quantity
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE
            b.expiry_date IS NOT NULL
            AND b.expiry_date != ''
            AND b.quantity > 0
            AND b.expiry_date::DATE <= CURRENT_DATE
        GROUP BY i.id, inv.id, u.name, b.expiry_date, b.quantity
        ORDER BY b.expiry_date ASC
    ) AS expired_results;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 6. الحصول على الأصناف القريبة من انتهاء الصلاحية
CREATE OR REPLACE FUNCTION get_items_nearing_expiry()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            b.expiry_date AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            b.quantity AS final_quantity
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE
            b.expiry_date IS NOT NULL
            AND b.expiry_date != ''
            AND b.quantity > 0
            AND b.expiry_date::DATE BETWEEN CURRENT_DATE + INTERVAL '1 day' AND CURRENT_DATE + INTERVAL '90 days'
        GROUP BY i.id, inv.id, u.name, b.expiry_date, b.quantity
        ORDER BY b.expiry_date ASC
    ) AS nearing_expiry_results;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 7. الحصول على إحصائيات حالة الدفع للمشتريات
CREATE OR REPLACE FUNCTION get_purchase_payment_status_counts()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_record RECORD;
    response JSON;
BEGIN
    SELECT 
        SUM(CASE WHEN paid = 0 THEN 1 ELSE 0.0 END) AS unpaid_count,
        SUM(CASE WHEN paid > 0 AND paid < total_amount THEN 1 ELSE 0.0 END) AS partially_paid_count,
        SUM(CASE WHEN (total_amount - paid) > 0 THEN 1 ELSE 0.0 END) AS debit_count,
        SUM(CASE WHEN paid = 0 THEN total_amount ELSE 0.0 END) AS unpaid_amount,
        SUM(CASE WHEN paid > 0 AND paid < total_amount THEN (total_amount - paid) ELSE 0.0 END) AS partial_paid_amount,
        SUM(CASE WHEN (total_amount - paid) > 0 THEN (total_amount - paid) ELSE 0.0 END) AS debit_amount
    INTO result_record
    FROM (
        SELECT 
            p.id,
            COALESCE(SUM(pd.qty * pd.price), 0.0) + COALESCE(p.charge_price, 0.0) AS subtotal,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            COALESCE(SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                        ELSE 0
                    END
                )
            ), 0.0) + COALESCE(p.charge_price, 0.0) AS total,
            CASE 
                WHEN p.type_dic = 0 THEN (
                    COALESCE(SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                )
                WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN t.type = 0 THEN (
                    (COALESCE(SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) - 
                    CASE 
                        WHEN p.type_dic = 0 THEN (
                            COALESCE(SUM(
                                pd.qty * (
                                    pd.price 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.price - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                ) * CAST(t.value AS DOUBLE PRECISION) / 100
                )
                WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                ELSE 0
            END AS total_tax
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        GROUP BY p.id, p.type_dic, p.value_dic, t.type, t.value
    ) AS purchase_calculations;

    response := json_build_object(
        'unpaid_count', COALESCE(result_record.unpaid_count, 0),
        'partially_paid_count', COALESCE(result_record.partially_paid_count, 0),
        'debit_count', COALESCE(result_record.debit_count, 0),
        'unpaid_amount', COALESCE(result_record.unpaid_amount, 0.0),
        'partial_paid_amount', COALESCE(result_record.partial_paid_amount, 0.0),
        'debit_amount', COALESCE(result_record.debit_amount, 0.0)
    );

    RETURN response;
END;
$$;

-- 8. الحصول على إحصائيات حالة الدفع للمبيعات
CREATE OR REPLACE FUNCTION get_sales_payment_status_counts()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_record RECORD;
    response JSON;
BEGIN
    SELECT 
        SUM(CASE WHEN paid = 0 THEN 1 ELSE 0.0 END) AS unpaid_count,
        SUM(CASE WHEN paid > 0 AND paid < total_amount THEN 1 ELSE 0.0 END) AS partially_paid_count,
        SUM(CASE WHEN (total_amount - paid) > 0 THEN 1 ELSE 0.0 END) AS debit_count,
        SUM(CASE WHEN paid = 0 THEN total_amount ELSE 0.0 END) AS unpaid_amount,
        SUM(CASE WHEN paid > 0 AND paid < total_amount THEN (total_amount - paid) ELSE 0.0 END) AS partial_paid_amount,
        SUM(CASE WHEN (total_amount - paid) > 0 THEN (total_amount - paid) ELSE 0.0 END) AS debit_amount
    INTO result_record
    FROM (
        SELECT 
            p.id,
            COALESCE(SUM(pd.qty * pd.sell), 0.0) AS subtotal,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            COALESCE(SUM(
                pd.qty * (
                    pd.sell 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                        ELSE 0
                    END
                )
            ), 0.0) AS total,
            CASE 
                WHEN p.type_dic = 0 THEN (
                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                )
                WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN t.type = 0 THEN (
                    (COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        )
                    ), 0.0) - 
                    CASE 
                        WHEN p.type_dic = 0 THEN (
                            COALESCE(SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                )
                            ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                ) * CAST(t.value AS DOUBLE PRECISION) / 100
                )
                WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
                ELSE 0
            END AS total_tax
        FROM sales p
        JOIN sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        GROUP BY p.id, p.type_dic, p.value_dic, t.type, t.value
    ) AS sales_calculations;

    response := json_build_object(
        'unpaid_count', COALESCE(result_record.unpaid_count, 0),
        'partially_paid_count', COALESCE(result_record.partially_paid_count, 0),
        'debit_count', COALESCE(result_record.debit_count, 0),
        'unpaid_amount', COALESCE(result_record.unpaid_amount, 0.0),
        'partial_paid_amount', COALESCE(result_record.partial_paid_amount, 0.0),
        'debit_amount', COALESCE(result_record.debit_amount, 0.0)
    );

    RETURN response;
END;
$$;



-- 1. الحصول على الأصناف المنتهية قبل تاريخ محدد
CREATE OR REPLACE FUNCTION get_items_expired_before_date(
    selected_date_param DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    ),
    unique_items AS (
        SELECT id_item, id_stock FROM purchases_qty
        UNION
        SELECT id_item, id_stock FROM transf_stock_qty
    )
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT
            i.id AS item_id,
            i.name AS item_name,
            i.expirydate AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0) AS final_quantity
        FROM
            inventory inv
            LEFT JOIN items i ON 1=1
            LEFT JOIN unique_items ui ON i.id = ui.id_item AND inv.id = ui.id_stock
            LEFT JOIN purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
            LEFT JOIN return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
            LEFT JOIN sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
            LEFT JOIN return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
            LEFT JOIN transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
            LEFT JOIN change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
            LEFT JOIN users u ON inv.userid = u.id
        WHERE
            i.expirydate IS NOT NULL AND
            i.expirydate::DATE <= selected_date_param
        GROUP BY i.id, inv.id, u.name
        ORDER BY i.expirydate ASC
    ) AS expired_items;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 2. الحصول على الأصناف المنتهية خلال 30 يوم
CREATE OR REPLACE FUNCTION get_expiring_items()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    ),
    unique_items AS (
        SELECT id_item, id_stock FROM purchases_qty
        UNION
        SELECT id_item, id_stock FROM transf_stock_qty
    )
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'username', username,
            'country_name', country_name,
            'city_name', city_name,
            'stock_name', stock_name,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT
            i.id AS item_id,
            i.name AS item_name,
            i.expirydate AS expiry_date,
            u.name AS username,
            cont.name AS country_name,
            ci.name AS city_name,
            inv.name AS stock_name,
            COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0) AS final_quantity
        FROM
            inventory inv
            LEFT JOIN items i ON 1=1
            LEFT JOIN unique_items ui ON i.id = ui.id_item AND inv.id = ui.id_stock
            LEFT JOIN purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
            LEFT JOIN return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
            LEFT JOIN sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
            LEFT JOIN return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
            LEFT JOIN transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
            LEFT JOIN change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
            LEFT JOIN country cont ON inv.countryid = cont.id
            LEFT JOIN users u ON inv.userid = u.id
            LEFT JOIN city ci ON inv.cityid = ci.id
        WHERE
            i.expirydate IS NOT NULL AND
            i.expirydate::DATE BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '30 days')
        GROUP BY i.id, inv.id, u.name, cont.name, ci.name
        ORDER BY i.expirydate ASC
    ) AS expiring_items;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 3. الحصول على الأصناف المنتهية خلال أيام معينة (بدون batches)
CREATE OR REPLACE FUNCTION get_items_expiring_within_days_no_b(
    days_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    future_date DATE;
    result_json JSON;
BEGIN
    future_date := CURRENT_DATE + (days_param || ' days')::INTERVAL;
    
    WITH
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    ),
    unique_items AS (
        SELECT id_item, id_stock FROM purchases_qty
        UNION
        SELECT id_item, id_stock FROM transf_stock_qty
    )
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT
            i.id AS item_id,
            i.name AS item_name,
            i.expirydate AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0) AS final_quantity
        FROM
            inventory inv
            LEFT JOIN items i ON 1=1
            JOIN unique_items ui ON i.id = ui.id_item AND inv.id = ui.id_stock
            LEFT JOIN purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
            LEFT JOIN return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
            LEFT JOIN sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
            LEFT JOIN return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
            LEFT JOIN transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
            LEFT JOIN change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
            LEFT JOIN users u ON inv.userid = u.id
        WHERE
            i.expirydate IS NOT NULL AND
            i.expirydate != '' AND  
            i.expirydate != 0 AND  
            i.expirydate::DATE <= future_date
        GROUP BY i.id, inv.id, u.name
        ORDER BY i.expirydate ASC
    ) AS expiring_items;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 4. الحصول على الأصناف المنتهية خلال أيام معينة (باستخدام batches)
CREATE OR REPLACE FUNCTION get_items_expiring_within_days(
    days_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    future_date DATE;
    result_json JSON;
BEGIN
    future_date := CURRENT_DATE + (days_param || ' days')::INTERVAL;
    
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            b.expiry_date AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            b.quantity AS final_quantity
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE 
            b.expiry_date IS NOT NULL
            AND b.expiry_date != ''
            AND b.expiry_date::DATE <= future_date
            AND b.quantity > 0
        ORDER BY b.expiry_date ASC
    ) AS batch_items;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 5. الحصول على الأصناف المنتهية خلال أيام معينة (مجمعة)
CREATE OR REPLACE FUNCTION get_items_expiring_within_days_grouped(
    days_param INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    future_date DATE;
    result_json JSON;
BEGIN
    future_date := CURRENT_DATE + (days_param || ' days')::INTERVAL;
    
    SELECT json_agg(
        json_build_object(
            'item_id', item_id,
            'item_name', item_name,
            'expiry_date', expiry_date,
            'stock_name', stock_name,
            'username', username,
            'final_quantity', final_quantity
        )
    ) INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            MIN(b.expiry_date) AS expiry_date,
            inv.name AS stock_name,
            u.name AS username,
            SUM(b.quantity) AS final_quantity
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE 
            b.expiry_date IS NOT NULL
            AND b.expiry_date != ''
            AND b.expiry_date::DATE <= future_date
            AND b.quantity > 0
        GROUP BY i.id, inv.id, u.name
        ORDER BY expiry_date ASC
    ) AS grouped_items;
    
    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 1. وظيفة الحصول على الأصناف منخفضة المخزون (الطريقة الأولى)
CREATE OR REPLACE FUNCTION get_low_stock_items_end()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            b.expiry_date AS expiry_date,
            b.quantity AS batch_quantity,
            b.purchase_detail_id,
            inv.name AS stock_name,
            i.alert_qty,
            inv.*,
            u.name AS username
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE 
            i.alert_qty IS NOT NULL AND
            i.alert_qty != 0 AND
            i.alert_qty != 0.0 AND
            i.alert_qty > 0
        GROUP BY i.id, inv.id, b.expiry_date, b.quantity, b.purchase_detail_id, u.name
        HAVING SUM(b.quantity) <= i.alert_qty
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 2. وظيفة الحصول على الأصناف منخفضة المخزون (الطريقة الثانية - شاملة)
CREATE OR REPLACE FUNCTION get_low_stock_items_end1()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    ),
    unique_items AS (
        SELECT id_item, id_stock
        FROM purchases_qty
        UNION
        SELECT id_item, id_stock
        FROM transf_stock_qty
    )
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT
            i.id AS item_id,
            i.name AS item_name,
            u.name AS username,
            cont.name AS contry_name,
            ci.name AS city_name,
            inv.*,
            inv.name AS stock_name,
            COALESCE(SUM(p.total_qty * i.price), 0) +
            COALESCE(SUM(rp.total_qty * i.price), 0) +
            COALESCE(SUM(s.total_qty * i.price), 0) +
            COALESCE(SUM(rs.total_qty * i.price), 0) +
            COALESCE(SUM(ts.total_qty * i.price), 0) +
            COALESCE(SUM(cs.total_qty * i.price), 0.0) AS final_price,
            COUNT(DISTINCT ui.id_item) AS final_count,
            COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0.0) AS final_quantity
        FROM
            inventory inv
            LEFT JOIN items i ON 1=1
            JOIN unique_items ui ON i.id = ui.id_item AND inv.id = ui.id_stock
            LEFT JOIN purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
            LEFT JOIN return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
            LEFT JOIN sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
            LEFT JOIN return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
            LEFT JOIN transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
            LEFT JOIN change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
            LEFT JOIN country cont ON inv.countryid = cont.id
            LEFT JOIN users u ON inv.userid = u.id
            LEFT JOIN city ci ON inv.cityid = ci.id
        WHERE
            i.alert_qty IS NOT NULL AND i.alert_qty::text != ''
        GROUP BY i.id, inv.id, u.name, cont.name, ci.name
        HAVING
            (COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0)) > 0
        ORDER BY i.id
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 3. وظيفة الحصول على الأصناف منخفضة المخزون (الطريقة الثالثة - المخزون صفر)
CREATE OR REPLACE FUNCTION get_low_stock_items_end_later()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            b.expiry_date AS expiry_date,
            b.quantity AS batch_quantity,
            b.purchase_detail_id,
            inv.name AS stock_name,
            i.alert_qty,
            inv.*,
            u.name AS username
        FROM batches b
        JOIN items i ON b.item_id = i.id
        JOIN inventory inv ON b.stock_id = inv.id
        LEFT JOIN users u ON inv.userid = u.id
        WHERE 
            i.alert_qty IS NOT NULL AND
            i.alert_qty != 0 AND
            i.alert_qty != 0.0 AND
            i.alert_qty > 0
        GROUP BY i.id, inv.id, b.expiry_date, b.quantity, b.purchase_detail_id, u.name
        HAVING SUM(b.quantity) = 0
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 4. وظيفة الحصول على الأصناف منخفضة المخزون (الطريقة الرابعة)
CREATE OR REPLACE FUNCTION get_low_stock_items()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    ),
    registered_items AS (
        SELECT DISTINCT id_item FROM purchases_qty
        UNION
        SELECT DISTINCT id_item FROM transf_stock_qty
    ),
    final_quantities AS (
        SELECT
            i.id AS item_id,
            inv.id AS stock_id,
            COALESCE(SUM(p.total_qty), 0) +
            COALESCE(SUM(rp.total_qty), 0) +
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) +
            COALESCE(SUM(ts.total_qty), 0) +
            COALESCE(SUM(cs.total_qty), 0.0) AS final_quantity
        FROM
            items i
            CROSS JOIN inventory inv
            LEFT JOIN purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
            LEFT JOIN return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
            LEFT JOIN sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
            LEFT JOIN return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
            LEFT JOIN transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
            LEFT JOIN change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
            INNER JOIN registered_items ri ON i.id = ri.id_item
        GROUP BY i.id, inv.id
    )
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT
            i.*,
            inv.name AS stock_name,
            f.final_quantity,
            COALESCE(f.final_quantity * i.price, 0) AS final_price
        FROM
            items i
            JOIN inventory inv ON inv.id = f.stock_id
            JOIN final_quantities f ON i.id = f.item_id AND inv.id = f.stock_id
        WHERE
            i.alert_qty IS NOT NULL AND 
            i.alert_qty != 0 AND 
            i.alert_qty != 0.0 AND 
            i.alert_qty::text != '' AND
            f.final_quantity < i.alert_qty
        ORDER BY i.id
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 5. وظيفة الحصول على المشتريات الشهرية


-- 6. وظيفة الحصول على المشتريات السنوية
--
-- 7. وظيفة الحصول على المشتريات اليومية

-- 9. وظيفة الحصول على جميع المصروفات
CREATE OR REPLACE FUNCTION get_all_expansive(
    query_param TEXT DEFAULT '',
    from_date_param TEXT DEFAULT NULL,
    to_date_param TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
    where_conditions TEXT := '';
    query_conditions TEXT := '';
BEGIN
    -- بناء شروط البحث
    IF query_param != '' THEN
        query_conditions := ' AND (e.name LIKE ''%' || query_param || '%'' OR ec.name LIKE ''%' || query_param || '%'')';
    END IF;

    -- بناء شروط التاريخ
    IF from_date_param IS NOT NULL AND from_date_param != '' THEN
        where_conditions := where_conditions || ' AND e.date >= ''' || from_date_param || '''';
    END IF;

    IF to_date_param IS NOT NULL AND to_date_param != '' THEN
        where_conditions := where_conditions || ' AND e.date <= ''' || to_date_param || '''';
    END IF;

    -- إزالة AND الأولى إذا كانت موجودة
    IF where_conditions != '' THEN
        where_conditions := ' WHERE ' || SUBSTRING(where_conditions FROM 5);
    END IF;

    -- إضافة شروط البحث إلى شروط WHERE
    IF query_conditions != '' THEN
        IF where_conditions = '' THEN
            where_conditions := ' WHERE ' || SUBSTRING(query_conditions FROM 5);
        ELSE
            where_conditions := where_conditions || query_conditions;
        END IF;
    END IF;

    EXECUTE '
        SELECT json_agg(row_to_json(t))
        FROM (
            SELECT 
                e.*,
                u.name AS username,
                ec.name AS ecname
            FROM expansive e
            LEFT JOIN users u ON e.userid = u.id
            LEFT JOIN expansive_category ec ON e.category_id = ec.id
            ' || where_conditions || '
            ORDER BY e.date DESC, e.id DESC
        ) t'
    INTO result_json;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 10. وظيفة الحصول على مصروف محدد
CREATE OR REPLACE FUNCTION get_all_expansivez(query_param TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            e.*,
            u.name AS username,
            ec.name AS ecname
        FROM expansive e
        LEFT JOIN users u ON e.userid = u.id
        LEFT JOIN expansive_category ec ON e.category_id = ec.id
        WHERE e.id::text = query_param
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 1. وظيفة الحصول على جميع الحسابات المحاسبية


-- 2. وظيفة الحصول على جميع الإيداعات
CREATE OR REPLACE FUNCTION get_all_account_debit(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_conditions TEXT := '';
    query_args TEXT[] := '{}';
    result_json JSON;
BEGIN
    -- بناء شروط البحث
    IF query_text != '' THEN
        where_conditions := where_conditions || 
            ' (c.code LIKE $1 OR ac.name LIKE $2 OR acd.name LIKE $3)';
        query_args := query_args || 
            ARRAY['%' || query_text || '%', '%' || query_text || '%', '%' || query_text || '%'];
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date >= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[from_date];
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date <= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[to_date];
    END IF;

    IF where_conditions != '' THEN
        where_conditions := 'WHERE ' || where_conditions;
    END IF;

    -- بناء الاستعلام الديناميكي
    EXECUTE format('
        SELECT json_agg(row_to_json(debit_data))
        FROM (
            SELECT 
                c.*,
                ac.name AS accountTransfname,
                acd.name AS accountDebitname,
                u.name AS username,
                COALESCE(CAST(c.balance AS REAL), 0.0) AS balance,
                (acd.name || '' → '' || ac.name) AS deposit_desc,
                ''deposit'' AS transaction_type
            FROM accountdebitcode c
            LEFT JOIN account ac ON c.accounttransf_id = ac.id
            LEFT JOIN account acd ON c.accountdebit_id = acd.id
            LEFT JOIN users u ON c.userid = u.id
            %s
            ORDER BY c.date DESC, c.id DESC
        ) AS debit_data
    ', where_conditions)
    INTO result_json
    USING query_args[1], query_args[2], query_args[3], query_args[4], query_args[5];

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 3. وظيفة الحصول على جميع التحويلات
CREATE OR REPLACE FUNCTION get_all_account_trans(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_conditions TEXT := '';
    query_args TEXT[] := '{}';
    result_json JSON;
BEGIN
    -- بناء شروط البحث
    IF query_text != '' THEN
        where_conditions := where_conditions || 
            ' (c.code LIKE $1 OR ac.name LIKE $2 OR acd.name LIKE $3)';
        query_args := query_args || 
            ARRAY['%' || query_text || '%', '%' || query_text || '%', '%' || query_text || '%'];
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date >= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[from_date];
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date <= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[to_date];
    END IF;

    IF where_conditions != '' THEN
        where_conditions := 'WHERE ' || where_conditions;
    END IF;

    -- بناء الاستعلام الديناميكي
    EXECUTE format('
        SELECT json_agg(row_to_json(trans_data))
        FROM (
            SELECT 
                c.*,
                ac.name AS accountTransfname,
                acd.name AS accountDebitname,
                u.name AS username,
                COALESCE(CAST(c.balance AS REAL), 0.0) AS balance,
                (acd.name || '' → '' || ac.name) AS transfer_desc
            FROM accounttrans c
            LEFT JOIN account ac ON c.accounttransf_id = ac.id
            LEFT JOIN account acd ON c.accountdebit_id = acd.id
            LEFT JOIN users u ON c.userid = u.id
            %s
            ORDER BY c.date DESC, c.id DESC
        ) AS trans_data
    ', where_conditions)
    INTO result_json
    USING query_args[1], query_args[2], query_args[3], query_args[4], query_args[5];

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 4. وظيفة الحصول على جميع الفواتير
CREATE OR REPLACE FUNCTION get_invoices(search_query TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(invoice_data)) INTO result_json
    FROM (
        SELECT 
            p.invoice_code AS invoice_code,
            SUM(pd.qty * pd.price) AS total_amount,
            a.name AS account_name,
            p.date AS date,
            'Purchase' AS type
        FROM 
            purchases p
        JOIN 
            purchase_details pd ON p.id = pd.id_invoice_code
        JOIN 
            items i ON pd.id_item = i.id
        JOIN 
            account a ON p.account_id = a.id
        WHERE 
            p.invoice_code LIKE '%' || search_query || '%'
        GROUP BY 
            p.invoice_code, a.name, p.date
        
        UNION ALL
        
        SELECT 
            rp.invoice_code AS invoice_code,
            SUM(rpd.qty * rpd.price) AS total_amount,
            a.name AS account_name,
            rp.date AS date,
            'Return' AS type
        FROM 
            return_purchases rp
        JOIN 
            return_purchase_detals rpd ON rp.id = rpd.id_invoice_code
        JOIN 
            items i ON rpd.id_item = i.id
        JOIN 
            account a ON rp.account_id = a.id
        WHERE 
            rp.invoice_code LIKE '%' || search_query || '%'
        GROUP BY 
            rp.invoice_code, a.name, rp.date
        
        ORDER BY date DESC
    ) AS invoice_data;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 5. وظيفة الحصول على جميع تحويلات المخزون
CREATE OR REPLACE FUNCTION get_all_stock_transfer(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_conditions TEXT := '';
    query_args TEXT[] := '{}';
    result_json JSON;
BEGIN
    -- بناء شروط البحث
    IF query_text != '' THEN
        where_conditions := where_conditions || 
            ' (inv.name LIKE $1 OR invv.name LIKE $2 OR u.name LIKE $3 OR c.invoice_code LIKE $4)';
        query_args := query_args || 
            ARRAY['%' || query_text || '%', '%' || query_text || '%', '%' || query_text || '%', '%' || query_text || '%'];
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date >= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[from_date];
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date <= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[to_date];
    END IF;

    IF where_conditions != '' THEN
        where_conditions := 'WHERE ' || where_conditions;
    END IF;

    -- بناء الاستعلام الديناميكي
    EXECUTE format('
        SELECT json_agg(row_to_json(transfer_data))
        FROM (
            SELECT 
                c.*,
                u.name AS username,
                inv.name AS fromstock,
                invv.name AS tostock,
                COUNT(trd.id_item) AS allcount,
                SUM(trd.qty) AS allqty,
                SUM(trd.qty * i.price) AS allprice,
                SUM(trd.qty * trd.sell) AS allsell,
                COALESCE(SUM(
                    trd.qty * trd.sell
                    - CASE 
                        WHEN trd.type_dic = 0 THEN (trd.sell * CAST(trd.value_dic AS REAL) / 100)
                        WHEN trd.type_dic = 1 THEN CAST(trd.value_dic AS REAL)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (trd.sell - 
                                CASE 
                                    WHEN trd.type_dic = 0 THEN (trd.sell * CAST(trd.value_dic AS REAL) / 100)
                                    WHEN trd.type_dic = 1 THEN CAST(trd.value_dic AS REAL)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS REAL) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS REAL)
                        ELSE 0
                    END
                ), 0.0) AS total
            FROM transf_stock c
            LEFT JOIN users u ON c.userid = u.id
            JOIN transf_stock_details trd ON c.id = trd.id_invoice_code
            JOIN items i ON trd.id_item = i.id
            JOIN inventory inv ON c.id_from_stock = inv.id 
            JOIN inventory invv ON c.id_to_stock = invv.id
            LEFT JOIN taxs ti ON trd.taxid = ti.id
            %s
            GROUP BY c.id, u.name, inv.name, invv.name
            ORDER BY c.date DESC, c.id DESC
        ) AS transfer_data
    ', where_conditions)
    INTO result_json
    USING query_args[1], query_args[2], query_args[3], query_args[4], query_args[5], query_args[6];

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

-- 6. وظيفة الحصول على جميع تعديلات المخزون
CREATE OR REPLACE FUNCTION get_all_stock_change(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_conditions TEXT := '';
    query_args TEXT[] := '{}';
    result_json JSON;
BEGIN
    -- بناء شروط البحث
    IF query_text != '' THEN
        where_conditions := where_conditions || 
            ' (u.name LIKE $1 OR inv.name LIKE $2 OR c.change_type LIKE $3)';
        query_args := query_args || 
            ARRAY['%' || query_text || '%', '%' || query_text || '%', '%' || query_text || '%'];
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date >= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[from_date];
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        IF where_conditions != '' THEN
            where_conditions := where_conditions || ' AND ';
        END IF;
        where_conditions := where_conditions || ' c.date <= $' || (array_length(query_args, 1) + 1);
        query_args := query_args || ARRAY[to_date];
    END IF;

    IF where_conditions != '' THEN
        where_conditions := 'WHERE ' || where_conditions;
    END IF;

    -- بناء الاستعلام الديناميكي
    EXECUTE format('
        SELECT json_agg(row_to_json(change_data))
        FROM (
            SELECT 
                c.*,
                u.name AS username,
                inv.name AS stockname,
                COUNT(trd.id_item) AS allcount,
                SUM(trd.qty) AS allqty,
                SUM(trd.qty * i.price) AS allprice,
                SUM(trd.qty * trd.sell) AS allsell,
                COALESCE(SUM(
                    trd.qty * trd.sell
                    - CASE 
                        WHEN trd.type_dic = 0 THEN (trd.sell * CAST(trd.value_dic AS REAL) / 100)
                        WHEN trd.type_dic = 1 THEN CAST(trd.value_dic AS REAL)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (trd.sell - 
                                CASE 
                                    WHEN trd.type_dic = 0 THEN (trd.sell * CAST(trd.value_dic AS REAL) / 100)
                                    WHEN trd.type_dic = 1 THEN CAST(trd.value_dic AS REAL)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS REAL) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS REAL)
                        ELSE 0
                    END
                ), 0.0) AS total
            FROM change_stock c
            JOIN change_stock_details trd ON c.id = trd.id_invoice_code
            JOIN items i ON trd.id_item = i.id
            LEFT JOIN users u ON c.userid = u.id
            LEFT JOIN inventory inv ON c.id_stock = inv.id
            LEFT JOIN taxs ti ON trd.taxid = ti.id
            %s
            GROUP BY c.id, u.name, inv.name
            ORDER BY c.date DESC, c.id DESC
        ) AS change_data
    ', where_conditions)
    INTO result_json
    USING query_args[1], query_args[2], query_args[3], query_args[4], query_args[5];

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;


-- وظيفة الحصول على جميع تحويلات المخزون (المبسطة)
CREATE OR REPLACE FUNCTION get_all_stock_transfer_simple(query_text TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(transfer_data)) INTO result_json
    FROM (
        SELECT  
            c.*,
            u.name AS username,
            inv.name AS fromstock,
            invv.name AS tostock,
            SUM(trd.qty) AS allqty,
            SUM(trd.qty * i.price) AS allprice,
            SUM(trd.qty * trd.sell) AS allsell,
            COUNT(trd.id_item) AS allcount
        FROM transf_stock c
        LEFT JOIN users u ON c.userid = u.id
        JOIN transf_stock_details trd ON c.id = trd.id_invoice_code
        JOIN inventory inv ON c.id_from_stock = inv.id 
        JOIN inventory invv ON c.id_to_stock = invv.id
        JOIN items i ON trd.id_item = i.id
        WHERE inv.name LIKE '%' || query_text || '%' OR invv.name LIKE '%' || query_text || '%'
        GROUP BY c.id, u.name, inv.name, invv.name
    ) AS transfer_data;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_all_purchases(
    query TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
BEGIN
    -- بناء شروط البحث
    IF query IS NOT NULL AND query != '' THEN
        conditions := conditions || ' AND p.invoice_code LIKE $' || array_length(args, 1) + 1;
        args := array_append(args, '%' || query || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                sup.name AS suppliername,
                s.name AS stockname,
                
                COALESCE(SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) + p.charge_price AS "total",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                  END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                        ELSE 0
                                                    END
                                                ) * CAST(ti.value AS REAL) / 100
                                            )
                                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                            ELSE 0
                                          END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            FROM purchases p
            JOIN purchase_details pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN suppliers sup ON p.id_supplier = sup.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            %s
            GROUP BY p.id, sup.name, s.name, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t
    ', conditions)
    INTO result_records
    USING args[1], args[2], args[3];

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_all_purchases1(
    query TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
BEGIN
    -- بناء شروط البحث
    IF query IS NOT NULL AND query != '' THEN
        conditions := conditions || ' AND p.invoice_code LIKE $' || array_length(args, 1) + 1;
        args := array_append(args, '%' || query || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                sup.name AS suppliername,
                s.name AS stockname,
                
                COALESCE(SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) + p.charge_price AS "total",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                  END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                        ELSE 0
                                                    END
                                                ) * CAST(ti.value AS REAL) / 100
                                            )
                                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                            ELSE 0
                                          END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            FROM purchases p
            LEFT JOIN purchase_details pd ON p.id = pd.id_invoice_code
            LEFT JOIN items i ON pd.id_item = i.id
            LEFT JOIN suppliers sup ON p.id_supplier = sup.id
            LEFT JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            %s
            GROUP BY p.id, sup.name, s.name, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t
    ', conditions)
    INTO result_records
    USING args[1], args[2], args[3];

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_all_supplier_purchases(
    query TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
    result1_records JSON;
    combined_results JSON;
BEGIN
    -- بناء شروط البحث
    IF query IS NOT NULL AND query != '' THEN
        conditions := conditions || ' AND sup.name LIKE $' || array_length(args, 1) + 1;
        args := array_append(args, '%' || query || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- جلب المشتريات العادية
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                sup.name AS suppliername,
                s.name AS stockname,
                
                COALESCE(SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) + p.charge_price AS "total",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                  END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                        ELSE 0
                                                    END
                                                ) * CAST(ti.value AS REAL) / 100
                                            )
                                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                            ELSE 0
                                          END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice",
                ''s'' as state
            FROM purchases p
            JOIN purchase_details pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN suppliers sup ON p.id_supplier = sup.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            %s
            GROUP BY p.id, sup.name, s.name, t.type, t.value
        ) t
    ', conditions)
    INTO result_records
    USING args[1], args[2], args[3];

    -- جلب مرتجعات المشتريات
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
                COALESCE(SUM(p.charge_price), 0.0) AS totalCharge,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                sup.name AS suppliername,
                s.name AS stockname,
                pur.invoice_code AS invcode,
                
                COALESCE(SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) AS "total",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                  END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                        ELSE 0
                                                    END
                                                ) * CAST(ti.value AS REAL) / 100
                                            )
                                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                            ELSE 0
                                          END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice",
                ''r'' as state
            FROM return_purchases p
            JOIN return_purchase_detals pd ON p.id = pd.id_invoice_code
            LEFT JOIN purchases pur ON p.purchase_id = pur.id
            JOIN items i ON pd.id_item = i.id
            JOIN suppliers sup ON p.id_supplier = sup.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            LEFT JOIN taxs t ON p.taxid = t.id
            %s
            GROUP BY p.id, sup.name, s.name, t.type, t.value, pur.invoice_code
        ) t
    ', conditions)
    INTO result1_records
    USING args[1], args[2], args[3];

    -- دمج النتائج
    combined_results := COALESCE(result_records, '[]'::json) || COALESCE(result1_records, '[]'::json);

    RETURN combined_results;
END;
$$;





CREATE OR REPLACE FUNCTION get_all_orders_with_status(
    id_param TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL,
    status_filter TEXT DEFAULT 'all'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
BEGIN
    -- بناء شروط البحث
    IF id_param IS NOT NULL AND id_param != '' THEN
        conditions := conditions || ' AND (p.invoice_code LIKE $' || array_length(args, 1) + 1;
        conditions := conditions || ' OR dy.name LIKE $' || array_length(args, 1) + 1;
        conditions := conditions || ' OR cus.name LIKE $' || array_length(args, 1) + 1;
        conditions := conditions || ' OR tab.name LIKE $' || array_length(args, 1) + 1 || ')';
        args := array_append(args, '%' || id_param || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- فلترة الحالة
    IF status_filter IS NOT NULL AND status_filter != 'all' THEN
        IF status_filter = 'delivered' THEN
            conditions := conditions || ' AND (p.status = ''delivered'' OR p.status IS NULL)';
        ELSE
            conditions := conditions || ' AND p.status = $' || array_length(args, 1) + 1;
            args := array_append(args, status_filter);
        END IF;
    END IF;

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.*,
                COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                cus.name AS customername,
                cus.id AS customerid,
                s.name AS stockname,
                dy.name AS deliveryname,
                u.name AS username,
                tab.name AS tablename,

                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) AS "total",

                COALESCE(SUM(
                    pd.qty * (
                        (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )
                        - pd.price
                    )
                ), 0.0) AS "profit",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                  END
                            )
                        ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                    ELSE 0
                                                END
                                            ) * CAST(ti.value AS REAL) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                        ELSE 0
                                      END
                                )
                            ) - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.sell 
                                            - CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                              END
                                            + CASE 
                                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (pd.sell - 
                                                        CASE 
                                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(ti.value AS REAL) / 100
                                                )
                                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                                ELSE 0
                                              END
                                        )
                                    ) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            FROM sales p
            JOIN sales_detals pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN users u ON p.userid = u.id
            JOIN customers cus ON p.id_customer = cus.id
            LEFT JOIN my_table tab ON p.id_table = tab.id
            LEFT JOIN delivery dy ON p.id_delivery = dy.id
            LEFT JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            %s
            GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, tab.name, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t
    ', conditions)
    INTO result_records
    USING args[1], args[2], args[3], args[4];

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_all_profits_by_item(
    item_name TEXT DEFAULT NULL,
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
BEGIN
    -- بناء شروط البحث
    IF item_name IS NOT NULL AND item_name != '' THEN
        conditions := conditions || ' AND i.name LIKE $' || array_length(args, 1) + 1;
        args := array_append(args, '%' || item_name || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    EXECUTE format('
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                i.id AS item_id,
                i.name AS item_name,
                i.code AS item_code,
                i.price AS cost_price,
                SUM(pd.qty) AS total_qty,
                
                SUM(pd.qty * pd.sell) AS total_revenue_before,

                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                          END
                    )
                ), 0.0) AS total_revenue,

                COALESCE(SUM(
                    pd.qty * (
                        (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                              END
                        )
                        - pd.price
                    )
                ), 0.0) AS total_profit
            FROM sales p
            JOIN sales_detals pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            %s
            GROUP BY i.id, i.name, i.code, i.price
            ORDER BY total_profit DESC, total_qty DESC
        ) t
    ', conditions)
    INTO result_records
    USING args[1], args[2], args[3];

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;



-- 1. وظيفة جلب جميع مبيعات العملاء مع إمكانية البحث والتصفية
CREATE OR REPLACE FUNCTION get_all_customer_sales(
    query_text TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    sales_result JSON;
    return_sales_result JSON;
    customer_payments_result JSON;
    combined_results JSON;
BEGIN
    -- بناء شروط البحث
    IF query_text IS NOT NULL AND query_text != '' THEN
        conditions := conditions || ' AND (cus.name LIKE $' || array_length(args, 1) + 1 || ' OR cus.number_phone LIKE $' || array_length(args, 1) + 2 || ' OR $' || array_length(args, 1) + 3 || ' = ''walk_in'')';
        args := array_append(args, '%' || query_text || '%');
        args := array_append(args, '%' || query_text || '%');
        args := array_append(args, query_text);
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        conditions := conditions || ' AND p.date >= $' || array_length(args, 1) + 1;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        conditions := conditions || ' AND p.date <= $' || array_length(args, 1) + 1;
        args := array_append(args, to_date);
    END IF;

    -- إزالة AND الأولى إذا كانت conditions تبدأ بها
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 5);
    END IF;

    -- استعلام المبيعات
    EXECUTE '
    SELECT json_agg(results) FROM (
        SELECT 
            p.*,
            COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            cus.name AS customername,
            cus.id AS customerid,
            cus.number_phone AS customernumberphone,
            s.name AS stockname,
            dy.name AS deliveryname,
            u.name AS username,
            COALESCE(SUM(
                pd.qty * (
                    pd.sell 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                            ) * CAST(ti.value AS REAL) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                        ELSE 0
                    END
                )
            ), 0.0) AS "total",
            CASE 
                WHEN p.type_dic = 0 THEN (SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                        END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                        END
                    )
                ) * p.value_dic / 100)
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS "discountPrice",
            CASE 
                WHEN t.type = 0 THEN (
                    (SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                            END
                        )
                    ) - CASE 
                        WHEN p.type_dic = 0 THEN (SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100)
                        WHEN p.type_dic = 1 THEN p.value_dic
                        ELSE 0
                    END) * t.value / 100
                )
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS "TaxPrice",
            ''s'' AS state
        FROM sales p
        JOIN sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN users u ON p.userid = u.id
        JOIN customers cus ON p.id_customer = cus.id
        LEFT JOIN delivery dy ON p.id_delivery = dy.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        ' || conditions || '
        GROUP BY p.id, cus.name, cus.id, cus.number_phone, s.name, dy.name, u.name, t.type, t.value
        ORDER BY p.date DESC, p.id DESC
    ) results'
    INTO sales_result
    USING args;

    -- استعلام مرتجعات المبيعات
    EXECUTE '
    SELECT json_agg(results) FROM (
        SELECT 
            p.*, 
            COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            cus.name AS customername,
            cus.id AS customerid,
            s.name AS stockname,
            cus.number_phone AS customernumberphone,
            dy.name AS deliveryname,
            u.name AS username,
            sal.invoice_code AS invcode,
            COALESCE(SUM(
                pd.qty * (
                    pd.sell 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                        ELSE 0
                    END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                            ) * CAST(ti.value AS REAL) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                        ELSE 0
                    END
                )
            ), 0.0) AS "total",
            CASE 
                WHEN p.type_dic = 0 THEN (SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                        END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                        END
                    )
                ) * p.value_dic / 100)
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS "discountPrice",
            CASE 
                WHEN t.type = 0 THEN (
                    (SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                            END
                        )
                    ) - CASE 
                        WHEN p.type_dic = 0 THEN (SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100)
                        WHEN p.type_dic = 1 THEN p.value_dic
                        ELSE 0
                    END) * t.value / 100
                )
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS "TaxPrice",
            ''r'' AS state
        FROM return_sales p
        JOIN return_sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN users u ON p.userid = u.id
        LEFT JOIN sales sal ON p.sales_id = sal.id
        JOIN customers cus ON p.id_customer = cus.id
        LEFT JOIN delivery dy ON p.id_delivery = dy.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        ' || conditions || '
        GROUP BY p.id, cus.name, cus.id, s.name, cus.number_phone, dy.name, u.name, sal.invoice_code, t.type, t.value
        ORDER BY p.date DESC, p.id DESC
    ) results'
    INTO return_sales_result
    USING args;

    -- دمج النتائج
    combined_results := COALESCE(sales_result, '[]'::JSON) || COALESCE(return_sales_result, '[]'::JSON);

    RETURN combined_results;
END;
$$;

CREATE OR REPLACE FUNCTION get_all_sales_view(
  p_id TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      cus.name AS customername,
      cus.id AS customerid,
      s.name AS stockname,
      dy.name AS deliveryname,
      u.name AS username,

      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS "total",

      -- إجمالي الربح
      COALESCE(SUM(
        pd.qty * (
          (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
          - pd.price
        )
      ), 0.0) AS "profit",

      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",

      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"

    FROM sales_view p
    JOIN sales_view_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    
    -- بناء شروط WHERE ديناميكياً
    WHERE (
      (p_id = '' OR p.invoice_code ILIKE '%' || p_id || '%'))
    
    GROUP BY p.id, cus.id, s.id, dy.id, u.id, t.id
    ORDER BY p.date DESC, p.id DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

-- 3. وظيفة جلب المبيعات مع الضرائب والخصومات
CREATE OR REPLACE FUNCTION get_sales_with_tax_discount()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(results) INTO result
    FROM (
        SELECT 
            p.id AS invoice_id,
            p.invoice_code,
            cus.name AS customername,
            s.name AS stockname,
            dy.name AS deliveryname,
            u.name AS username,
            COALESCE(SUM(
                sd.qty * (
                    sd.sell
                    + (CASE 
                        WHEN t.type = 0 THEN (sd.sell * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END)
                    - (CASE 
                        WHEN i.discount_type = 0 THEN (sd.sell * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END)
                )
            ), 0.0) AS "invoice_subtotal",
            CASE 
                WHEN p.type_dic = 0 THEN (COALESCE(SUM(
                    (sd.qty * sd.sell)
                    + CASE 
                        WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END
                    - CASE 
                        WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END
                ), 0.0) * COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0) / 100)
                WHEN p.type_dic = 1 THEN COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0)
                ELSE 0.0
            END AS "discountPrice",
            CASE 
                WHEN tax_invoice.type = 0 THEN (COALESCE(SUM(
                    (sd.qty * sd.sell)
                    + CASE 
                        WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END
                    - CASE 
                        WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                        WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                        ELSE 0.0
                    END
                ), 0.0) * COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0) / 100)
                WHEN tax_invoice.type = 1 THEN COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0)
                ELSE 0.0
            END AS "TaxPrice",
            (COALESCE(SUM(
                (sd.qty * sd.sell)
                + CASE 
                    WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END
                - CASE 
                    WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END
            ), 0.0)
            - COALESCE(
                CASE 
                    WHEN p.type_dic = 0 THEN (COALESCE(SUM(
                        (sd.qty * sd.sell)
                        + CASE 
                            WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                        - CASE 
                            WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                    ), 0.0) * COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN p.type_dic = 1 THEN COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END, 0.0)
            + COALESCE(
                CASE 
                    WHEN tax_invoice.type = 0 THEN (COALESCE(SUM(
                        (sd.qty * sd.sell)
                        + CASE 
                            WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                        - CASE 
                            WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                    ), 0.0) * COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN tax_invoice.type = 1 THEN COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END, 0.0)
            ) AS final_total,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            (COALESCE(SUM(
                (sd.qty * sd.sell)
                + CASE 
                    WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END
                - CASE 
                    WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END
            ), 0.0)
            - COALESCE(
                CASE 
                    WHEN p.type_dic = 0 THEN (COALESCE(SUM(
                        (sd.qty * sd.sell)
                        + CASE 
                            WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                        - CASE 
                            WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                    ), 0.0) * COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN p.type_dic = 1 THEN COALESCE(CAST(p.value_dic AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END, 0.0)
            + COALESCE(
                CASE 
                    WHEN tax_invoice.type = 0 THEN (COALESCE(SUM(
                        (sd.qty * sd.sell)
                        + CASE 
                            WHEN t.type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN t.type = 1 THEN COALESCE(CAST(t.value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                        - CASE 
                            WHEN i.discount_type = 0 THEN ((sd.qty * sd.sell) * COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0) / 100)
                            WHEN i.discount_type = 1 THEN COALESCE(CAST(i.discount_value AS DOUBLE PRECISION), 0.0)
                            ELSE 0.0
                        END
                    ), 0.0) * COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0) / 100)
                    WHEN tax_invoice.type = 1 THEN COALESCE(CAST(tax_invoice.value AS DOUBLE PRECISION), 0.0)
                    ELSE 0.0
                END, 0.0)
            ) - COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS remaining
        FROM sales p
        JOIN sales_detals sd ON p.id = sd.id_invoice_code
        JOIN items i ON sd.id_item = i.id
        JOIN customers cus ON p.id_customer = cus.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN delivery dy ON p.id_delivery = dy.id
        JOIN users u ON p.userid = u.id
        LEFT JOIN taxs t ON i.id_taxs = t.id
        LEFT JOIN taxs tax_invoice ON p.taxid = tax_invoice.id
        GROUP BY p.id, p.invoice_code, cus.name, s.name, dy.name, u.name, p.type_dic, p.value_dic, tax_invoice.type, tax_invoice.value
        ORDER BY p.id
    ) results;

    RETURN COALESCE(result, '[]'::JSON);
END;
$$;






-- وظيفة الحصول على جميع الطلبات مع الحالة
CREATE OR REPLACE FUNCTION get_all_orders_with_statusp(
    id_param TEXT DEFAULT '',
    from_date_param TEXT DEFAULT NULL,
    to_date_param TEXT DEFAULT NULL,
    status_filter_param TEXT DEFAULT 'all'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT[] := '{}';
    query_text TEXT;
    result_records JSON;
BEGIN
    -- بناء شروط WHERE
    IF id_param IS NOT NULL AND id_param != '' THEN
        conditions := array_append(conditions, 
            '(p.invoice_code::TEXT LIKE ''%' || id_param || '%'' OR 
              dy.name LIKE ''%' || id_param || '%'' OR 
              cus.name LIKE ''%' || id_param || '%'' OR 
              tab.name LIKE ''%' || id_param || '%'')'
        );
    END IF;

    -- فلترة التاريخ
    IF from_date_param IS NOT NULL AND from_date_param != '' THEN
        conditions := array_append(conditions, 'p.date >= ''' || from_date_param || '''');
    END IF;
    
    IF to_date_param IS NOT NULL AND to_date_param != '' THEN
        conditions := array_append(conditions, 'p.date <= ''' || to_date_param || '''');
    END IF;

    -- فلترة الحالة
    IF status_filter_param IS NOT NULL AND status_filter_param != 'all' THEN
        IF status_filter_param = 'delivered' THEN
            conditions := array_append(conditions, '(p.status = ''delivered'' OR p.status IS NULL)');
        ELSE
            conditions := array_append(conditions, 'p.status = ''' || status_filter_param || '''');
        END IF;
    END IF;

    -- بناء WHERE clause
    IF array_length(conditions, 1) = 0 THEN
        conditions := array_append(conditions, '1=1');
    END IF;

    -- بناء الاستعلام الرئيسي
    query_text := '
    SELECT 
        p.*,
        COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
        COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code::TEXT), 0.0) AS paid,
        cus.name AS customername,
        cus.id AS customerid,
        s.name AS stockname,
        dy.name AS deliveryname,
        u.name AS username,
        tab.name AS tablename,

        COALESCE(SUM(
            pd.qty * (
                pd.sell 
                - CASE 
                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                    ELSE 0
                  END
                + CASE 
                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                        (pd.sell - 
                            CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                            END
                        ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                    )
                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                    ELSE 0
                  END
            )
        ), 0.0) AS "total",

        COALESCE(SUM(
            pd.qty * (
                (
                    pd.sell 
                    - CASE 
                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                      END
                    + CASE 
                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                    ELSE 0
                                END
                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                        )
                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                        ELSE 0
                      END
                )
                - pd.price
            )
        ), 0.0) AS "profit",

        CASE 
            WHEN p.type_dic = 0 THEN (
                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                            ELSE 0
                          END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                    END
                                ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                            ELSE 0
                          END
                    )
                ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
            )
            WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
            ELSE 0
        END AS "discountPrice",

        CASE 
            WHEN t.type = 0 THEN (
                (
                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                ELSE 0
                              END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                            ELSE 0
                                        END
                                    ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                ELSE 0
                              END
                        )
                    ), 0.0)
                    - 
                    CASE 
                        WHEN p.type_dic = 0 THEN (
                            COALESCE(SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * CAST(pd.value_dic AS DOUBLE PRECISION) / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS DOUBLE PRECISION)
                                                    ELSE 0
                                                END
                                            ) * CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(CAST(ti.value AS REAL) AS DOUBLE PRECISION)
                                        ELSE 0
                                      END
                                )
                            ), 0.0) * CAST(p.value_dic AS DOUBLE PRECISION) / 100
                        )
                        WHEN p.type_dic = 1 THEN CAST(p.value_dic AS DOUBLE PRECISION)
                        ELSE 0
                    END
                ) * CAST(t.value AS DOUBLE PRECISION) / 100
            )
            WHEN t.type = 1 THEN CAST(t.value AS DOUBLE PRECISION)
            ELSE 0
        END AS "TaxPrice",

        -- التحقق من وجود مرتجع للفاتورة
        EXISTS (
            SELECT 1 FROM return_sales rs 
            WHERE rs.sales_id = p.id
        ) AS r_state

    FROM sales p
    JOIN sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN my_table tab ON p.id_table = tab.id::TEXT
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    LEFT JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE ' || array_to_string(conditions, ' AND ') || '
    GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, tab.name, t.type, t.value
    ORDER BY p.date DESC, p.id DESC';

    -- تنفيذ الاستعلام وإرجاع النتائج كـ JSON
    EXECUTE 'SELECT json_agg(t) FROM (' || query_text || ') t' INTO result_records;
    
    RETURN COALESCE(result_records, '[]'::json);
END;
$$;

-- 1. الحصول على جميع الأصناف في المبيعات
CREATE OR REPLACE FUNCTION get_all_items_sales(
    stock_param TEXT,
    search_items_param TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    query_text TEXT;
    where_clause TEXT;
    where_args TEXT[];
    result_data JSON;
BEGIN
    -- إذا كان stock فارغاً، نرجع مصفوفة فارغة
    IF stock_param IS NULL OR stock_param = '' THEN
        RETURN '[]'::JSON;
    END IF;

    where_clause := 'p.id_stock = $1';
    where_args := ARRAY[stock_param];

    IF search_items_param IS NOT NULL AND search_items_param != '' THEN
        where_clause := where_clause || ' AND i.name LIKE $2';
        where_args := array_append(where_args, '%' || search_items_param || '%');
    END IF;

    query_text := '
        SELECT DISTINCT i.*
        FROM items i
        JOIN purchase_details pd ON i.id = pd.id_item
        JOIN purchases p ON pd.id_invoice_code = p.id
        LEFT JOIN users u ON i.userid = u.id
        WHERE ' || where_clause;

    EXECUTE 'SELECT json_agg(t) FROM (' || query_text || ') t'
    INTO result_data
    USING where_args[1], CASE WHEN array_length(where_args, 1) > 1 THEN where_args[2] ELSE NULL END;

    RETURN COALESCE(result_data, '[]'::JSON);
END;
$$;

-- 2. الحصول على جميع مرتجعات المشتريات
CREATE OR REPLACE FUNCTION get_all_return_purchases(
    query_param TEXT DEFAULT '',
    from_date_param TEXT DEFAULT NULL,
    to_date_param TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT[];
    args TEXT[];
    where_clause TEXT;
    result_data JSON;
BEGIN
    -- شرط البحث بالرقم
    IF query_param IS NOT NULL AND query_param != '' THEN
        conditions := array_append(conditions, '(p.invoice_code LIKE $1 OR pur.invoice_code LIKE $2)');
        args := array_append(args, '%' || query_param || '%');
        args := array_append(args, '%' || query_param || '%');
    END IF;

    -- شرط التاريخ
    IF from_date_param IS NOT NULL AND from_date_param != '' THEN
        conditions := array_append(conditions, 'p.date >= $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, from_date_param);
    END IF;

    IF to_date_param IS NOT NULL AND to_date_param != '' THEN
        conditions := array_append(conditions, 'p.date <= $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, to_date_param);
    END IF;

    where_clause := '';
    IF array_length(conditions, 1) > 0 THEN
        where_clause := 'WHERE ' || array_to_string(conditions, ' AND ');
    END IF;

    EXECUTE '
        SELECT json_agg(t) FROM (
            SELECT 
                p.*, 
                COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
                COALESCE(SUM(p.charge_price), 0.0) AS totalCharge,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                sup.name AS suppliername,
                s.name AS stockname,
                pur.invoice_code AS invcode,
                
                COALESCE(SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                        END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                        END
                    )
                ), 0.0) + p.charge_price AS "total",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                            END
                        )) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                END
                            ))
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                        + CASE 
                                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                        ELSE 0
                                                    END
                                                ) * CAST(ti.value AS REAL) / 100
                                            )
                                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                            ELSE 0
                                        END
                                    )) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            
            FROM return_purchases p
            JOIN return_purchase_detals pd ON p.id = pd.id_invoice_code
            LEFT JOIN purchases pur ON p.purchase_id = pur.id
            JOIN items i ON pd.id_item = i.id
            JOIN suppliers sup ON p.id_supplier = sup.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            LEFT JOIN taxs t ON p.taxid = t.id
            ' || where_clause || '
            GROUP BY p.id,p.date, sup.name, s.name, pur.invoice_code, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t'
    INTO result_data
    USING args[1], 
          CASE WHEN array_length(args, 1) > 1 THEN args[2] ELSE NULL END,
          CASE WHEN array_length(args, 1) > 2 THEN args[3] ELSE NULL END;

    RETURN COALESCE(result_data, '[]'::JSON);
END;
$$;

-- 3. الحصول على جميع الطلبات مع حالة المطعم
--CREATE OR REPLACE FUNCTION get_all_orders_with_status_ketchin(
    id_param TEXT DEFAULT '',
    from_date_param TEXT DEFAULT NULL,
    to_date_param TEXT DEFAULT NULL,
    status_filter_param TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT[];
    args TEXT[];
    where_clause TEXT;
    result_data JSON;
BEGIN
    -- فلترة الكود
    IF id_param IS NOT NULL AND id_param != '' THEN
        conditions := array_append(conditions, 
            '(p.invoice_code LIKE $1 OR dy.name LIKE $2 OR cus.name LIKE $3 OR tab.name LIKE $4)');
        args := array_append(args, '%' || id_param || '%');
        args := array_append(args, '%' || id_param || '%');
        args := array_append(args, '%' || id_param || '%');
        args := array_append(args, '%' || id_param || '%');
    END IF;

    -- فلترة التاريخ
    IF from_date_param IS NOT NULL AND from_date_param != '' THEN
        conditions := array_append(conditions, 'p.date >= $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, from_date_param);
    END IF;

    IF to_date_param IS NOT NULL AND to_date_param != '' THEN
        conditions := array_append(conditions, 'p.date <= $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, to_date_param);
    END IF;

    -- فلترة الحالة
    IF status_filter_param IS NOT NULL AND status_filter_param != 'waiting' THEN
        conditions := array_append(conditions, 'p.status = $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, status_filter_param);
    END IF;

    IF status_filter_param = 'waiting' THEN
        conditions := array_append(conditions, 
            'p.status = $' || (array_length(args, 1) + 1)::TEXT || 
            ' OR p.status = $' || (array_length(args, 1) + 2)::TEXT);
        args := array_append(args, 'completing');
        args := array_append(args, 'whating');
    END IF;

    where_clause := '';
    IF array_length(conditions, 1) > 0 THEN
        where_clause := 'WHERE ' || array_to_string(conditions, ' AND ');
    END IF;

    EXECUTE '
        SELECT json_agg(t) FROM (
            SELECT 
                p.*,
                COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                cus.name AS customername,
                cus.id AS customerid,
                s.name AS stockname,
                dy.name AS deliveryname,
                u.name AS username,
                tab.name AS tablename,

                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                            ELSE 0
                        END
                        + CASE 
                            WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                ) * CAST(ti.value AS REAL) / 100
                            )
                            WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                            ELSE 0
                        END
                    )
                ), 0.0) AS "total",

                COALESCE(SUM(
                    pd.qty * (
                        (
                            pd.sell 
                            - CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                            END
                            + CASE 
                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                            ELSE 0
                                        END
                                    ) * CAST(ti.value AS REAL) / 100
                                )
                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                ELSE 0
                            END
                        )
                        - pd.price
                    )
                ), 0.0) AS "profit",

                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                        ) * CAST(ti.value AS REAL) / 100
                                    )
                                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice",

                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                    ELSE 0
                                                END
                                            ) * CAST(ti.value AS REAL) / 100
                                        )
                                        WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                        ELSE 0
                                    END
                                )
                            )
                            - 
                            CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.sell 
                                            - CASE 
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                                                    (pd.sell - 
                                                        CASE 
                                                            WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                            WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                                            ELSE 0
                                                        END
                                                    ) * CAST(ti.value AS REAL) / 100
                                                )
                                                WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                                                ELSE 0
                                            END
                                        )
                                    ) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice"
            FROM ketchine p
            JOIN ketchine_detals pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN users u ON p.userid = u.id
            JOIN customers cus ON p.id_customer = cus.id
            LEFT JOIN my_table tab ON p.id_table = tab.id
            LEFT JOIN delivery dy ON p.id_delivery = dy.id
            LEFT JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            ' || where_clause || '
            GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, tab.name, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t'
    INTO result_data
    USING 
        CASE WHEN array_length(args, 1) > 0 THEN args[1] ELSE NULL END,
        CASE WHEN array_length(args, 1) > 1 THEN args[2] ELSE NULL END,
        CASE WHEN array_length(args, 1) > 2 THEN args[3] ELSE NULL END,
        CASE WHEN array_length(args, 1) > 3 THEN args[4] ELSE NULL END,
        CASE WHEN array_length(args, 1) > 4 THEN args[5] ELSE NULL END,
        CASE WHEN array_length(args, 1) > 5 THEN args[6] ELSE NULL END;

    RETURN COALESCE(result_data, '[]'::JSON);
END;
$$;

-- 4. الحصول على جميع الطلبات مع حالة POS للمطعم













-- 1. وظيفة البحث عن الأصناف للبيع (مع أو بدون خدمات)

DROP FUNCTION get_item_sales(TEXT, INTEGER, BOOLEAN);
CREATE OR REPLACE FUNCTION get_item_sales(
    query TEXT,
    p_stock_id INTEGER,  -- غيرنا اسم المعلمة لتجنب التباس الأسماء
    noservices BOOLEAN
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_data JSON;
BEGIN
    query := TRIM(query);
    
    IF noservices THEN
        SELECT json_agg(row_to_json(t)) INTO result_data
        FROM (
            SELECT 
                i.*,
                ty.name AS tyname,
                COALESCE(SUM(b.quantity), 0) AS final_quantity,
                i.price * COALESCE(SUM(b.quantity), 0) AS final_price
            FROM batches b
            JOIN items i ON b.item_id = i.id
            LEFT JOIN type_items ty ON i.id_itemtype = ty.id
            WHERE 
                b.stock_id = p_stock_id  -- استخدام المعلمة الجديدة
                AND (
                    i.name LIKE '%' || query || '%'
                    OR (i.barcode IS NOT NULL AND i.barcode != '' AND i.barcode LIKE '%' || query || '%')
                    OR (i.barcode1 IS NOT NULL AND i.barcode1 != '' AND i.barcode1 LIKE '%' || query || '%')
                    OR (i.barcode2 IS NOT NULL AND i.barcode2 != '' AND i.barcode2 LIKE '%' || query || '%')
                    OR (i.barcode3 IS NOT NULL AND i.barcode3 != '' AND i.barcode3 LIKE '%' || query || '%')
                    OR (i.barcode4 IS NOT NULL AND i.barcode4 != '' AND i.barcode4 LIKE '%' || query || '%')
                    OR (i.barcode5 IS NOT NULL AND i.barcode5 != '' AND i.barcode5 LIKE '%' || query || '%')
                    OR (i.barcode6 IS NOT NULL AND i.barcode6 != '' AND i.barcode6 LIKE '%' || query || '%')
                )
            GROUP BY i.id, ty.name
            ORDER BY i.name ASC
        ) t;
    ELSE
        SELECT json_agg(row_to_json(t)) INTO result_data
        FROM (
            -- الجزء 1: الأصناف (التي لها دفعات في المخزن)
            SELECT 
                i.*,
                ty.name AS tyname,
                COALESCE(SUM(b.quantity), 0) AS final_quantity,
                'item' AS source_type,
                i.price * COALESCE(SUM(b.quantity), 0) AS final_price
            FROM batches b
            JOIN items i ON b.item_id = i.id
            LEFT JOIN type_items ty ON i.id_itemtype = ty.id
            WHERE 
                b.stock_id = p_stock_id  -- استخدام المعلمة الجديدة
                AND (
                    i.name LIKE '%' || query || '%'
                    OR (i.barcode IS NOT NULL AND i.barcode != '' AND i.barcode LIKE '%' || query || '%')
                    OR (i.barcode1 IS NOT NULL AND i.barcode1 != '' AND i.barcode1 LIKE '%' || query || '%')
                    OR (i.barcode2 IS NOT NULL AND i.barcode2 != '' AND i.barcode2 LIKE '%' || query || '%')
                    OR (i.barcode3 IS NOT NULL AND i.barcode3 != '' AND i.barcode3 LIKE '%' || query || '%')
                    OR (i.barcode4 IS NOT NULL AND i.barcode4 != '' AND i.barcode4 LIKE '%' || query || '%')
                    OR (i.barcode5 IS NOT NULL AND i.barcode5 != '' AND i.barcode5 LIKE '%' || query || '%')
                    OR (i.barcode6 IS NOT NULL AND i.barcode6 != '' AND i.barcode6 LIKE '%' || query || '%')
                )
            GROUP BY i.id, ty.name

            UNION ALL

            -- الجزء 2: الخدمات (لا تحتاج دُفعات)
            SELECT 
                i.*,
                ty.name AS tyname,
                1.0 AS final_quantity,
                'service' AS source_type,
                i.sell AS final_price
            FROM items i
            LEFT JOIN type_items ty ON i.id_itemtype = ty.id
            WHERE 
                i.is_item = 0
                AND i.is_active = 1
                AND (
                    i.name LIKE '%' || query || '%'
                    OR (i.barcode IS NOT NULL AND i.barcode != '' AND i.barcode LIKE '%' || query || '%')
                    OR (i.barcode1 IS NOT NULL AND i.barcode1 != '' AND i.barcode1 LIKE '%' || query || '%')
                    OR (i.barcode2 IS NOT NULL AND i.barcode2 != '' AND i.barcode2 LIKE '%' || query || '%')
                    OR (i.barcode3 IS NOT NULL AND i.barcode3 != '' AND i.barcode3 LIKE '%' || query || '%')
                    OR (i.barcode4 IS NOT NULL AND i.barcode4 != '' AND i.barcode4 LIKE '%' || query || '%')
                    OR (i.barcode5 IS NOT NULL AND i.barcode5 != '' AND i.barcode5 LIKE '%' || query || '%')
                    OR (i.barcode6 IS NOT NULL AND i.barcode6 != '' AND i.barcode6 LIKE '%' || query || '%')
                )
            ORDER BY name ASC
        ) t;
    END IF;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;
-- 2. وظيفة البحث عن الأصناف للبيع بدون خدمات
CREATE OR REPLACE FUNCTION get_item_sales_no_ser(
    query TEXT,
    stock_id INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_data JSON;
BEGIN
    query := TRIM(query);
    
    SELECT json_agg(row_to_json(t)) INTO result_data
    FROM (
        SELECT 
            i.*,
            ty.name AS tyname,
            COALESCE(SUM(b.quantity), 0) AS final_quantity,
            i.price * COALESCE(SUM(b.quantity), 0) AS final_price
        FROM batches b
        JOIN items i ON b.item_id = i.id
        LEFT JOIN type_items ty ON i.id_itemtype = ty.id
        WHERE 
            b.stock_id = stock_id
            AND (
                i.name LIKE '%' || query || '%'
                OR (i.barcode IS NOT NULL AND i.barcode != '' AND i.barcode LIKE '%' || query || '%')
                OR (i.barcode1 IS NOT NULL AND i.barcode1 != '' AND i.barcode1 LIKE '%' || query || '%')
                OR (i.barcode2 IS NOT NULL AND i.barcode2 != '' AND i.barcode2 LIKE '%' || query || '%')
                OR (i.barcode3 IS NOT NULL AND i.barcode3 != '' AND i.barcode3 LIKE '%' || query || '%')
                OR (i.barcode4 IS NOT NULL AND i.barcode4 != '' AND i.barcode4 LIKE '%' || query || '%')
                OR (i.barcode5 IS NOT NULL AND i.barcode5 != '' AND i.barcode5 LIKE '%' || query || '%')
                OR (i.barcode6 IS NOT NULL AND i.barcode6 != '' AND i.barcode6 LIKE '%' || query || '%')
            )
        GROUP BY i.id, ty.name
        ORDER BY i.name ASC
    ) t;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;

-- 3. وظيفة الحصول على كميات الأصناف حسب المخزن
DROP FUNCTION get_item_quantities_by_stock1(TEXT);


CREATE OR REPLACE FUNCTION get_item_quantities_by_stock(
    query TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_data JSON;
BEGIN
    query := TRIM(COALESCE(query, ''));
    
    WITH 
    -- جمع الكميات من عمليات الشراء
    purchases_qty AS (
        SELECT pd.id_item, p.id_stock, SUM(pd.qty) AS total_qty
        FROM purchase_details pd
        JOIN purchases p ON pd.id_invoice_code = p.id
        GROUP BY pd.id_item, p.id_stock
    ),
    -- جمع الكميات من عمليات مرتجع الشراء
    return_purchases_qty AS (
        SELECT rpd.id_item, rp.id_stock, -SUM(rpd.qty) AS total_qty
        FROM return_purchase_detals rpd
        JOIN return_purchases rp ON rpd.id_invoice_code = rp.id
        GROUP BY rpd.id_item, rp.id_stock
    ),
    -- جمع الكميات من عمليات البيع
    sales_qty AS (
        SELECT sd.id_item, s.id_stock, -SUM(sd.qty) AS total_qty
        FROM sales_detals sd
        JOIN sales s ON sd.id_invoice_code = s.id
        GROUP BY sd.id_item, s.id_stock
    ),
    -- جمع الكميات من عمليات مرتجع البيع
    return_sales_qty AS (
        SELECT rsd.id_item, rs.id_stock, SUM(rsd.qty) AS total_qty
        FROM return_sales_detals rsd
        JOIN return_sales rs ON rsd.id_invoice_code = rs.id
        GROUP BY rsd.id_item, rs.id_stock
    ),
    -- جمع الكميات من عمليات التحويل بين المخازن
    transf_stock_qty AS (
        SELECT tsd.id_item, ts.id_from_stock AS id_stock, -SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_from_stock
        UNION ALL
        SELECT tsd.id_item, ts.id_to_stock AS id_stock, SUM(tsd.qty) AS total_qty
        FROM transf_stock_details tsd
        JOIN transf_stock ts ON tsd.id_invoice_code = ts.id
        GROUP BY tsd.id_item, ts.id_to_stock
    ),
    -- جمع الكميات من عمليات تسوية الأصناف
    change_stock_qty AS (
        SELECT csd.id_item, cs.id_stock, SUM(csd.qty) AS total_qty
        FROM change_stock_details csd
        JOIN change_stock cs ON csd.id_invoice_code = cs.id
        GROUP BY csd.id_item, cs.id_stock
    )
    SELECT json_agg(row_to_json(t)) INTO result_data
    FROM (
        SELECT 
            i.id AS item_id,
            i.name AS item_name,
            inv.*,
            COALESCE(SUM(p.total_qty * i.price), 0) + 
            COALESCE(SUM(rp.total_qty * i.price), 0) + 
            COALESCE(SUM(s.total_qty * i.price), 0) +
            COALESCE(SUM(rs.total_qty * i.price), 0) + 
            COALESCE(SUM(ts.total_qty * i.price), 0) + 
            COALESCE(SUM(cs.total_qty * i.price), 0.0) AS final_price,
            COUNT(p.id_item) AS final_count,
            COALESCE(SUM(p.total_qty), 0) + 
            COALESCE(SUM(rp.total_qty), 0) + 
            COALESCE(SUM(s.total_qty), 0) +
            COALESCE(SUM(rs.total_qty), 0) + 
            COALESCE(SUM(ts.total_qty), 0) + 
            COALESCE(SUM(cs.total_qty), 0.0) AS final_quantity
        FROM 
            items i
        CROSS JOIN 
            inventory inv
        LEFT JOIN 
            purchases_qty p ON i.id = p.id_item AND inv.id = p.id_stock
        LEFT JOIN 
            return_purchases_qty rp ON i.id = rp.id_item AND inv.id = rp.id_stock
        LEFT JOIN 
            sales_qty s ON i.id = s.id_item AND inv.id = s.id_stock
        LEFT JOIN 
            return_sales_qty rs ON i.id = rs.id_item AND inv.id = rs.id_stock
        LEFT JOIN 
            transf_stock_qty ts ON i.id = ts.id_item AND inv.id = ts.id_stock
        LEFT JOIN 
            change_stock_qty cs ON i.id = cs.id_item AND inv.id = cs.id_stock
        WHERE 
            inv.name LIKE '%' || query || '%'
        GROUP BY 
            i.id, i.name, inv.id, inv.name, inv.userid, inv.countryid, 
            inv.cityid, inv.date, inv.phoneNumber, inv.adress, 
            inv.email, inv.note, inv.created_at
        ORDER BY 
            inv.id
    ) t;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;

-- 4. وظيفة الحصول على جميع الباركود في المخزن
CREATE OR REPLACE FUNCTION get_all_stock_barcode(
    item_param TEXT DEFAULT NULL,
    stock_param TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_clauses TEXT[] := ARRAY[]::TEXT[];
    where_args TEXT[] := ARRAY[]::TEXT[];
    query_text TEXT;
    result_data JSON;
BEGIN
    IF item_param IS NOT NULL AND item_param != '' THEN
        where_clauses := array_append(where_clauses, 'i.name LIKE $1');
        where_args := array_append(where_args, '%' || item_param || '%');
    END IF;

    IF stock_param IS NOT NULL AND stock_param != '' THEN
        where_clauses := array_append(where_clauses, 'inv.id::TEXT LIKE $' || (array_length(where_args, 1) + 1)::TEXT);
        where_args := array_append(where_args, '%' || stock_param || '%');
    END IF;

    query_text := '
        SELECT i.*, SUM(s.qty) AS qty 
        FROM items i
        JOIN purchase_details s ON i.id = s.id_item
        LEFT JOIN inventory inv ON s.id_invoice_code = inv.id
    ';

    IF array_length(where_clauses, 1) > 0 THEN
        query_text := query_text || ' WHERE ' || array_to_string(where_clauses, ' AND ');
    END IF;

    EXECUTE query_text || ' GROUP BY i.id' INTO result_data USING where_args;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;

-- 5. وظيفة البحث عن الأصناف مع الفلاتر (للمطاعم)
CREATE OR REPLACE FUNCTION get_filtered_item_sales_rest(
    search_items TEXT,
    selected_main_category TEXT,
    selected_sub_category TEXT,
    selected_brand TEXT,
    selected_country TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT[] := ARRAY[]::TEXT[];
    args TEXT[] := ARRAY[]::TEXT[];
    where_clause TEXT;
    result_data JSON;
BEGIN
    -- شرط البحث
    IF search_items IS NOT NULL AND search_items != '' THEN
        conditions := array_append(conditions, 
            '(i.name LIKE $1 OR 
             (i.barcode IS NOT NULL AND i.barcode != '''' AND i.barcode LIKE $1) OR
             (i.barcode1 IS NOT NULL AND i.barcode1 != '''' AND i.barcode1 LIKE $1) OR
             (i.barcode2 IS NOT NULL AND i.barcode2 != '''' AND i.barcode2 LIKE $1) OR
             (i.barcode3 IS NOT NULL AND i.barcode3 != '''' AND i.barcode3 LIKE $1) OR
             (i.barcode4 IS NOT NULL AND i.barcode4 != '''' AND i.barcode4 LIKE $1) OR
             (i.barcode5 IS NOT NULL AND i.barcode5 != '''' AND i.barcode5 LIKE $1) OR
             (i.barcode6 IS NOT NULL AND i.barcode6 != '''' AND i.barcode6 LIKE $1))'
        );
        args := array_append(args, '%' || search_items || '%');
    END IF;

    -- الفلاتر
    IF selected_main_category IS NOT NULL AND selected_main_category != '' THEN
        conditions := array_append(conditions, 'm.id = $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, selected_main_category);
    END IF;

    IF selected_sub_category IS NOT NULL AND selected_sub_category != '' THEN
        conditions := array_append(conditions, 's.id = $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, selected_sub_category);
    END IF;

    IF selected_brand IS NOT NULL AND selected_brand != '' THEN
        conditions := array_append(conditions, 'bnd.id = $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, selected_brand);
    END IF;

    IF selected_country IS NOT NULL AND selected_country != '' THEN
        conditions := array_append(conditions, 'c.id = $' || (array_length(args, 1) + 1)::TEXT);
        args := array_append(args, selected_country);
    END IF;

    -- بناء WHERE
    IF array_length(conditions, 1) > 0 THEN
        where_clause := array_to_string(conditions, ' AND ');
    ELSE
        where_clause := '1=1';
    END IF;

    -- الاستعلام النهائي
    EXECUTE '
        SELECT json_agg(row_to_json(t))
        FROM (
            SELECT 
                i.*,
                ty.name AS tyname,
                1.0 AS final_quantity,
                ''meal'' AS source_type,
                i.price AS final_price
            FROM items i
            LEFT JOIN items_maincategory m ON i.id_maincategory = m.id
            LEFT JOIN subcategory s ON i.id_subcategory = s.id
            LEFT JOIN brand bnd ON i.id_brand = bnd.id
            LEFT JOIN country c ON i.id_country = c.id
            LEFT JOIN type_items ty ON i.id_itemtype = ty.id
            WHERE 
                ' || where_clause || '
                AND i.is_item = 2
                AND (i.is_active = 1 OR i.is_active IS NULL)
            ORDER BY i.name ASC
        ) t'
    INTO result_data
    USING args;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;











DROP FUNCTION get_all_items(TEXT,TEXT,TEXT,TEXT,TEXT,TEXT);
CREATE OR REPLACE FUNCTION get_all_items(
    item TEXT DEFAULT NULL,
    brand TEXT DEFAULT NULL,
    sub TEXT DEFAULT NULL,
    main TEXT DEFAULT NULL,
    type TEXT DEFAULT NULL,
    country TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_clauses TEXT[] := '{}';
    query_text TEXT;
    result_records JSON;
BEGIN
    -- بناء شروط WHERE
    IF item IS NOT NULL AND item != '' THEN
        where_clauses := array_append(where_clauses, 'i.name LIKE ''%' || item || '%''');
    END IF;
    
    -- إصلاح مشكلة النوع: استخدام النص للمقارنة مع الحقول النصية
    IF type IS NOT NULL AND type != '' THEN
        IF type = '0' THEN
            where_clauses := array_append(where_clauses, 'i.is_item = 0');
        ELSIF type = '2' THEN
            where_clauses := array_append(where_clauses, 'i.is_item = 2');
        ELSE
            where_clauses := array_append(where_clauses, 'i.is_item != 0 AND i.is_item != 2');
        END IF;
    ELSE
        where_clauses := array_append(where_clauses, 'i.is_item != 0 AND i.is_item != 2');
    END IF;
    
    IF main IS NOT NULL AND main != '' THEN
        where_clauses := array_append(where_clauses, 'm.id::TEXT LIKE ''%' || main || '%''');
    END IF;
    
    IF sub IS NOT NULL AND sub != '' THEN
        where_clauses := array_append(where_clauses, 's.id::TEXT LIKE ''%' || sub || '%''');
    END IF;
    
    IF brand IS NOT NULL AND brand != '' THEN
        where_clauses := array_append(where_clauses, 'b.id::TEXT LIKE ''%' || brand || '%''');
    END IF;
    
    IF country IS NOT NULL AND country != '' THEN
        where_clauses := array_append(where_clauses, 'c.id::TEXT LIKE ''%' || country || '%''');
    END IF;
    
    -- بناء الاستعلام
    query_text := '
    SELECT 
        i.*,
        CAST(i.alert_qty AS REAL) AS alert_qty,
        CAST(i.discount_value AS REAL) AS discount_value, 
        m.name AS mainname,
        m.id AS id_maincategory, 
        u.username AS username, 
        s.name AS sub,
        s.id AS id_subcategory, 
        b.name AS brand,
        b.id AS id_brand, 
        c.name AS country, 
        c.id AS id_country,
        t.name AS taxname, 
        t.id AS id_taxs,
        ty.name AS typename,
        ty.id as id_itemtype,
        ty.name AS tyname
    FROM items i
    LEFT JOIN items_maincategory m ON i.id_maincategory = m.id
    LEFT JOIN subcategory s ON i.id_subcategory = s.id
    LEFT JOIN brand b ON i.id_brand = b.id
    LEFT JOIN country c ON i.id_country = c.id
    LEFT JOIN users u ON i.userid = u.id
    LEFT JOIN taxs t ON i.id_taxs = t.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id';
    
    -- إضافة WHERE إذا كانت هناك شروط
    IF array_length(where_clauses, 1) > 0 THEN
        query_text := query_text || ' WHERE ' || array_to_string(where_clauses, ' AND ');
    END IF;
    
    -- تنفيذ الاستعلام وإرجاع النتائج كـ JSON
    EXECUTE 'SELECT json_agg(t) FROM (' || query_text || ') t' INTO result_records;
    
    RETURN COALESCE(result_records, '[]'::json);
END;
$$;




-- 2. التحقق من وجود الصنف بالباركود
CREATE OR REPLACE FUNCTION item_exists(barcode_param TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO result_count
    FROM items 
    WHERE barcode = barcode_param OR name = barcode_param;
    
    RETURN json_build_object('exists', result_count > 0);
END;
$$;

-- 3. استيراد بيانات الصنف إذا وجد
CREATE OR REPLACE FUNCTION item_exists_import(barcode_param TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_record JSON;
BEGIN
    SELECT json_agg(t) INTO result_record
    FROM (
        SELECT * FROM items 
        WHERE barcode = barcode_param OR name = barcode_param
        LIMIT 1
    ) t;
    
    RETURN COALESCE(result_record, '{}'::json);
END;
$$;

-- 6. الحصول على جميع الأصناف لنقطة البيع
CREATE OR REPLACE FUNCTION get_all_items_pos(
    stock TEXT DEFAULT '',
    search_items TEXT DEFAULT '',
    selected_main_category TEXT DEFAULT '',
    selected_sub_category TEXT DEFAULT '',
    selected_brand TEXT DEFAULT '',
    selected_country TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    where_clauses TEXT[] := '{}';
    query_text TEXT;
    result_records JSON;
BEGIN
    -- بناء شروط WHERE
    IF search_items IS NOT NULL AND search_items != '' THEN
        where_clauses := array_append(where_clauses, 'i.name LIKE ''%' || search_items || '%''');
    END IF;
    
    IF selected_main_category IS NOT NULL AND selected_main_category != '' THEN
        where_clauses := array_append(where_clauses, 'm.id::TEXT LIKE ''%' || selected_main_category || '%''');
    END IF;
    
    IF selected_sub_category IS NOT NULL AND selected_sub_category != '' THEN
        where_clauses := array_append(where_clauses, 's.id::TEXT LIKE ''%' || selected_sub_category || '%''');
    END IF;
    
    IF selected_brand IS NOT NULL AND selected_brand != '' THEN
        where_clauses := array_append(where_clauses, 'b.id::TEXT LIKE ''%' || selected_brand || '%''');
    END IF;
    
    IF selected_country IS NOT NULL AND selected_country != '' THEN
        where_clauses := array_append(where_clauses, 'c.id::TEXT LIKE ''%' || selected_country || '%''');
    END IF;
    
    IF stock IS NOT NULL AND stock != '' THEN
        where_clauses := array_append(where_clauses, 'st.id::TEXT LIKE ''%' || stock || '%''');
    END IF;
    
    -- بناء الاستعلام
    query_text := '
    SELECT 
        i.*,
        st.qty AS qty,
        ty.name AS tyname
    FROM items i
    LEFT JOIN items_maincategory m ON i.id_maincategory = m.id
    LEFT JOIN subcategory s ON i.id_subcategory = s.id
    JOIN purchase_details st ON i.id = st.id_item
    JOIN inventory inv ON st.id_invoice_code = inv.id
    LEFT JOIN brand b ON i.id_brand = b.id
    LEFT JOIN country c ON i.id_country = c.id
    LEFT JOIN users u ON i.userid = u.id
    LEFT JOIN taxs t ON i.id_taxs = t.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id';
    
    -- إضافة WHERE إذا كانت هناك شروط
    IF array_length(where_clauses, 1) > 0 THEN
        query_text := query_text || ' WHERE ' || array_to_string(where_clauses, ' AND ');
    END IF;
    
    -- تنفيذ الاستعلام وإرجاع النتائج كـ JSON
    EXECUTE 'SELECT json_agg(t) FROM (' || query_text || ') t' INTO result_records;
    
    RETURN COALESCE(result_records, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_all_sales(
    id_param TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
    arg_counter INTEGER := 0;
BEGIN
    -- بناء شروط البحث
    IF id_param IS NOT NULL AND id_param != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.invoice_code LIKE $' || arg_counter;
        args := array_append(args, '%' || id_param || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.date >= $' || arg_counter;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.date <= $' || arg_counter;
        args := array_append(args, to_date);
    END IF;

    -- إضافة شرط الحالة
    conditions := conditions || ' AND (p.status = ''delivered'' OR p.status IS NULL)';

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    IF array_length(args, 1) IS NULL THEN
        EXECUTE format('
            SELECT json_agg(row_to_json(t)) 
            FROM (
                SELECT 
                    p.*,
                    COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                    COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                    cus.name AS customername,
                    cus.id AS customerid,
                    s.name AS stockname,
                    dy.name AS deliveryname,
                    u.name AS username,

                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                ELSE 0
                              END
                        )
                    ), 0.0) AS "total",

                    COALESCE(SUM(
                        pd.qty * (
                            (
                                pd.sell 
                                - CASE 
                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                    ELSE 0
                                  END
                            )
                            - pd.price
                        )
                    ), 0.0) AS "profit",

                    CASE 
                        WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                        ELSE 0
                                      END
                                )
                            ) * p.value_dic / 100
                        )
                        WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                        ELSE 0
                    END AS "discountPrice",

                    CASE 
                        WHEN CAST(t.type AS INTEGER) = 0 THEN (
                            (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                            ELSE 0
                                          END
                                    )
                                ) - 
                                CASE 
                                    WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                                        SUM(
                                            pd.qty * (
                                                pd.sell 
                                                - CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                  END
                                                + CASE 
                                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                        (pd.sell - 
                                                            CASE 
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                                ELSE 0
                                                            END
                                                        ) * ti.value / 100
                                                    )
                                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                                    ELSE 0
                                                  END
                                            )
                                        ) * p.value_dic / 100
                                    )
                                    WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                                    ELSE 0
                                END
                            ) * t.value / 100
                        )
                        WHEN CAST(t.type AS INTEGER) = 1 THEN t.value
                        ELSE 0
                    END AS "TaxPrice"
                FROM sales p
                JOIN sales_detals pd ON p.id = pd.id_invoice_code
                JOIN items i ON pd.id_item = i.id
                JOIN users u ON p.userid = u.id
                JOIN customers cus ON p.id_customer = cus.id
                LEFT JOIN delivery dy ON p.id_delivery = dy.id
                JOIN inventory s ON p.id_stock = s.id
                LEFT JOIN taxs t ON p.taxid = t.id
                LEFT JOIN taxs ti ON pd.taxid = ti.id
                %s
                GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
                ORDER BY p.date DESC, p.id DESC
            ) t
        ', conditions)
        INTO result_records;
    ELSE
        EXECUTE format('
            SELECT json_agg(row_to_json(t)) 
            FROM (
                SELECT 
                    p.*,
                    COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                    COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                    cus.name AS customername,
                    cus.id AS customerid,
                    s.name AS stockname,
                    dy.name AS deliveryname,
                    u.name AS username,

                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                ELSE 0
                              END
                        )
                    ), 0.0) AS total,

                    COALESCE(SUM(
                        pd.qty * (
                            (
                                pd.sell 
                                - CASE 
                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                    ELSE 0
                                  END
                            )
                            - pd.price
                        )
                    ), 0.0) AS profit,

                    CASE 
                        WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                        ELSE 0
                                      END
                                )
                            ) * p.value_dic / 100
                        )
                        WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                        ELSE 0
                    END AS "discountPrice",

                    CASE 
                        WHEN CAST(t.type AS INTEGER) = 0 THEN (
                            (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                            ELSE 0
                                          END
                                    )
                                ) - 
                                CASE 
                                    WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                                        SUM(
                                            pd.qty * (
                                                pd.sell 
                                                - CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                  END
                                                + CASE 
                                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                        (pd.sell - 
                                                            CASE 
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                                ELSE 0
                                                            END
                                                        ) * ti.value / 100
                                                    )
                                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                                    ELSE 0
                                                  END
                                            )
                                        ) * p.value_dic / 100
                                    )
                                    WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                                    ELSE 0
                                END
                            ) * t.value / 100
                        )
                        WHEN CAST(t.type AS INTEGER) = 1 THEN t.value
                        ELSE 0
                    END AS "TaxPrice"
                FROM sales p
                JOIN sales_detals pd ON p.id = pd.id_invoice_code
                JOIN items i ON pd.id_item = i.id
                JOIN users u ON p.userid = u.id
                JOIN customers cus ON p.id_customer = cus.id
                LEFT JOIN delivery dy ON p.id_delivery = dy.id
                JOIN inventory s ON p.id_stock = s.id
                LEFT JOIN taxs t ON p.taxid = t.id
                LEFT JOIN taxs ti ON pd.taxid = ti.id
                %s
                GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
                ORDER BY p.date DESC, p.id DESC
            ) t
        ', conditions)
        INTO result_records
        USING args[1], args[2], args[3];
    END IF;

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;






CREATE OR REPLACE FUNCTION add_batch_for_purchase_edit_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_purchase_detail_id INTEGER,
  p_quantity DOUBLE PRECISION,  -- نقلت قبل المعاملات الاختيارية
  p_expiry_date TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_batch_exists BOOLEAN;
  v_result JSONB;
BEGIN
  BEGIN
    -- التحقق من وجود الدفعة
    SELECT EXISTS(
      SELECT 1 FROM batches 
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id
    ) INTO v_batch_exists;
    
    IF v_batch_exists THEN
      -- تحديث الدفعة الموجودة
      UPDATE batches 
      SET quantity = quantity + p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id;
    ELSE
      -- إنشاء دفعة جديدة
      INSERT INTO batches (
        item_id, stock_id, purchase_detail_id, 
        expiry_date, quantity, created_at
      ) VALUES (
        p_item_id, p_stock_id, p_purchase_detail_id,
        p_expiry_date::DATE, p_quantity, NOW()
      );
    END IF;

    v_result := jsonb_build_object('success', true);

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION add_batch_for_purchase_edit_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_purchase_detail_id INTEGER DEFAULT NULL,
  p_expiry_date TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_batch_exists BOOLEAN;
  v_result JSONB;
BEGIN
  BEGIN
    -- التحقق من وجود الدفعة
    SELECT EXISTS(
      SELECT 1 FROM batches 
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id
    ) INTO v_batch_exists;
    
    IF v_batch_exists THEN
      -- تحديث الدفعة الموجودة
      UPDATE batches 
      SET quantity = quantity + p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id;
    ELSE
      -- إنشاء دفعة جديدة
      INSERT INTO batches (
        item_id, stock_id, purchase_detail_id, 
        expiry_date, quantity, created_at
      ) VALUES (
        p_item_id, p_stock_id, p_purchase_detail_id,
        p_expiry_date::DATE, p_quantity, NOW()
      );
    END IF;

    v_result := jsonb_build_object('success', true);

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;
DROP FUNCTION IF EXISTS add_batch_rpc(
  INTEGER, INTEGER, DOUBLE PRECISION 
  , INTEGER, TEXT
);
CREATE OR REPLACE FUNCTION add_batch_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_purchase_detail_id INTEGER DEFAULT NULL,
  p_expiry_date TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_batch_exists BOOLEAN;
  v_result JSONB;
  v_actual_purchase_detail_id INTEGER;
BEGIN
  BEGIN
    -- تحديد purchase_detail_id الفعلي
    IF p_purchase_detail_id IS NOT NULL AND p_purchase_detail_id > 0 THEN
      v_actual_purchase_detail_id := p_purchase_detail_id;
    ELSE
      v_actual_purchase_detail_id := EXTRACT(EPOCH FROM NOW())::INTEGER;
    END IF;

    -- التحقق من وجود الدفعة
    SELECT EXISTS(
      SELECT 1 FROM batches 
      WHERE purchase_detail_id = v_actual_purchase_detail_id 
      AND stock_id = p_stock_id
    ) INTO v_batch_exists;
    
    IF v_batch_exists THEN
      -- تحديث الدفعة الموجودة
      UPDATE batches 
      SET quantity = quantity + p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = v_actual_purchase_detail_id 
      AND stock_id = p_stock_id;
    ELSE
      -- إنشاء دفعة جديدة
      INSERT INTO batches (
        item_id, stock_id, purchase_detail_id, 
        expiry_date, quantity, created_at
      ) VALUES (
        p_item_id, p_stock_id, v_actual_purchase_detail_id,
        p_expiry_date::DATE, p_quantity, NOW()
      );
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم إضافة/تحديث الدفعة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;



















CREATE OR REPLACE FUNCTION process_transaction_rpc(
  p_transaction_type TEXT,
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_expiry_date TEXT DEFAULT NULL,
  p_check_qty BOOLEAN DEFAULT TRUE,
  p_purchase_detail_id INTEGER DEFAULT NULL,
  p_from_stock_id INTEGER DEFAULT NULL,
  p_to_stock_id INTEGER DEFAULT NULL,
  p_invoice_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
  v_batch_exists BOOLEAN;
  v_available_qty DOUBLE PRECISION;
  v_remaining DOUBLE PRECISION;
  v_batch_record RECORD;
  v_take DOUBLE PRECISION;
  v_default_expiry DATE;
BEGIN
  BEGIN
    CASE p_transaction_type
      WHEN 'purchase' THEN
        -- إضافة دفعة جديدة من شراء
        PERFORM add_batch_rpc(
          p_item_id,
          p_stock_id,
          p_purchase_detail_id,
          p_expiry_date,
          p_quantity
        );

      WHEN 'return_purchase' THEN
        -- إرجاع مشتريات
        PERFORM decrease_batch_rpc(
          p_item_id,
          p_stock_id,
          p_quantity,
          p_check_qty,
          p_purchase_detail_id
        );

      WHEN 'sale' THEN
        IF p_purchase_detail_id IS NOT NULL THEN
          -- بيع من دفعة محددة
          PERFORM sell_from_specific_batch_rpc(
            p_purchase_detail_id,
            p_stock_id,
            p_quantity,
            p_check_qty
          );
        ELSE
          -- بيع تلقائي (FEFO)
          PERFORM sell_from_batches_rpc(
            p_item_id,
            p_stock_id,
            p_quantity,
            p_check_qty
          );
        END IF;

      WHEN 'return_sale' THEN
        -- مرتجع مبيعات
        v_default_expiry := COALESCE(p_expiry_date::DATE, NOW() + INTERVAL '365 days');
        PERFORM add_batch_rpc(
          p_item_id,
          p_stock_id,
          p_purchase_detail_id,
          v_default_expiry::TEXT,
          p_quantity
        );

      WHEN 'transfer_out' THEN
        -- تحويل من مخزن
        PERFORM decrease_batch_rpc(
          p_item_id,
          p_stock_id,
          p_quantity,
          p_check_qty,
          p_purchase_detail_id
        );

      WHEN 'transfer_in' THEN
        -- تحويل إلى مخزن
        PERFORM add_batch_rpc(
          p_item_id,
          p_stock_id,
          p_purchase_detail_id,
          p_expiry_date,
          p_quantity
        );

      WHEN 'adjustment_increase' THEN
        -- تسوية زيادة
        PERFORM add_batch_rpc(
          p_item_id,
          p_stock_id,
          p_purchase_detail_id,
          p_expiry_date,
          ABS(p_quantity)
        );

      WHEN 'adjustment_decrease' THEN
        -- تسوية نقص
        PERFORM decrease_batch_rpc(
          p_item_id,
          p_stock_id,
          p_quantity,
          p_check_qty,
          p_purchase_detail_id
        );

      ELSE
        RAISE EXCEPTION 'نوع العملية غير معروف: %', p_transaction_type;
    END CASE;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تمت العملية بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;





CREATE OR REPLACE FUNCTION decrease_batch_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_check_qty BOOLEAN DEFAULT TRUE,
  p_purchase_detail_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
  v_available_qty DOUBLE PRECISION;
BEGIN
  BEGIN
    IF p_purchase_detail_id IS NOT NULL THEN
      -- تقليل من دفعة معينة
      UPDATE batches 
      SET quantity = quantity - p_quantity,
          updated_at = NOW()
      WHERE item_id = p_item_id 
        AND stock_id = p_stock_id 
        AND purchase_detail_id = p_purchase_detail_id;
      
      -- التحقق من الكمية إذا كان مطلوباً
      IF p_check_qty THEN
        SELECT quantity INTO v_available_qty
        FROM batches 
        WHERE purchase_detail_id = p_purchase_detail_id 
        AND stock_id = p_stock_id;
        
        IF v_available_qty < 0 THEN
          RAISE EXCEPTION 'الكمية لا يمكن أن تكون سالبة للدفعة: %', p_purchase_detail_id;
        END IF;
      END IF;
    ELSE
      -- استخدام FEFO إذا لم تُحدد الدفعة
      PERFORM sell_from_batches_rpc(
        p_item_id,
        p_stock_id,
        p_quantity,
        p_check_qty
      );
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تقليل الكمية بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION sell_from_batches_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_check_qty BOOLEAN DEFAULT TRUE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_remaining DOUBLE PRECISION := p_quantity;
  v_batch_record RECORD;
  v_take DOUBLE PRECISION;
  v_result JSONB;
BEGIN
  BEGIN
    -- البيع من الدفعات حسب FEFO
    FOR v_batch_record IN 
      SELECT id, quantity
      FROM batches
      WHERE item_id = p_item_id 
        AND stock_id = p_stock_id 
        AND quantity > 0
      ORDER BY expiry_date ASC NULLS LAST
    LOOP
      EXIT WHEN v_remaining <= 0;
      
      v_take := LEAST(v_remaining, v_batch_record.quantity);
      
      UPDATE batches 
      SET quantity = quantity - v_take,
          updated_at = NOW()
      WHERE id = v_batch_record.id;

      v_remaining := v_remaining - v_take;
    END LOOP;

    -- التحقق من الكمية المتبقية
    IF p_check_qty AND v_remaining > 0 THEN
      RAISE EXCEPTION 'الكمية غير كافية للبيع: الصنف % (ناقص: %)', p_item_id, v_remaining;
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم البيع من الدفعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION sell_from_specific_batch_rpc(
  p_purchase_detail_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_check_qty BOOLEAN DEFAULT TRUE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_available_qty DOUBLE PRECISION;
  v_result JSONB;
BEGIN
  BEGIN
    -- التحقق من وجود الدفعة وكميتها
    SELECT quantity INTO v_available_qty
    FROM batches 
    WHERE purchase_detail_id = p_purchase_detail_id 
    AND stock_id = p_stock_id;
    
    IF NOT FOUND THEN
      RAISE EXCEPTION 'الدفعة غير موجودة: %', p_purchase_detail_id;
    END IF;
    
    IF p_check_qty AND v_available_qty < p_quantity THEN
      RAISE EXCEPTION 'الكمية غير كافية في الدفعة: المتوفر %, المطلوب %', v_available_qty, p_quantity;
    END IF;
    
    -- تقليل الكمية
    UPDATE batches 
    SET quantity = quantity - p_quantity,
        updated_at = NOW()
    WHERE purchase_detail_id = p_purchase_detail_id 
    AND stock_id = p_stock_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم البيع من الدفعة المحددة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION return_qty_to_specific_batch_rpc(
  p_purchase_detail_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_stock_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_batch_exists BOOLEAN;
  v_item_id INTEGER;
  v_purchase_stock_id INTEGER;
  v_result JSONB;
BEGIN
  BEGIN
    -- التحقق من وجود الدفعة
    SELECT EXISTS(
      SELECT 1 FROM batches 
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id
    ) INTO v_batch_exists;
    
    IF v_batch_exists THEN
      -- تحديث الدفعة الموجودة
      UPDATE batches 
      SET quantity = quantity + p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = p_purchase_detail_id 
      AND stock_id = p_stock_id;
    ELSE
      -- إنشاء دفعة جديدة
      -- الحصول على item_id من purchase_details
      SELECT pd.id_item, p.id_stock 
      INTO v_item_id, v_purchase_stock_id
      FROM purchase_details pd
      JOIN purchases p ON p.id = pd.id_invoice_code
      WHERE pd.id = p_purchase_detail_id;
      
      IF FOUND THEN
        INSERT INTO batches (
          item_id, stock_id, purchase_detail_id, 
          quantity, created_at
        ) VALUES (
          v_item_id, v_purchase_stock_id, p_purchase_detail_id,
          p_quantity, NOW()
        );
      ELSE
        RAISE EXCEPTION 'لا يمكن إنشاء الدفعة: تفاصيل الشراء غير موجودة';
      END IF;
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم إعادة الكمية إلى الدفعة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION delete_sales_rpc(p_sale_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_sale_record RECORD;
  v_detail_record RECORD;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب بيانات الفاتورة
    SELECT id, id_stock, invoice_code, status
    INTO v_sale_record
    FROM sales 
    WHERE id = p_sale_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'الفاتورة غير موجودة'
      );
    END IF;

    -- إعادة الكمية إذا كانت الفاتورة مكتملة
    IF COALESCE(v_sale_record.status, 'delivered') = 'delivered' THEN
      FOR v_detail_record IN 
        SELECT 
          sd.id_item,
          sd.qty,
          sd.purchase_detail_id,
          COALESCE(i.is_item, 1) as is_item
        FROM sales_detals sd
        LEFT JOIN items i ON sd.id_item = i.id
        WHERE sd.id_invoice_code = p_sale_id
        AND sd.qty > 0
      LOOP
        IF v_detail_record.is_item = 1 THEN
          IF v_detail_record.purchase_detail_id IS NOT NULL THEN
            PERFORM return_qty_to_specific_batch_rpc(
              v_detail_record.purchase_detail_id,
              v_detail_record.qty,
              v_sale_record.id_stock
            );
          ELSE
            PERFORM process_transaction_rpc(
              'return_sale',
              v_detail_record.id_item,
              v_sale_record.id_stock,
              v_detail_record.qty,
              (NOW() + INTERVAL '365 days')::TEXT,
              FALSE,
              NULL
            );
          END IF;
        END IF;
      END LOOP;
    END IF;

    -- حذف البيانات
    DELETE FROM payments WHERE code = v_sale_record.invoice_code;
    DELETE FROM sales_detals WHERE id_invoice_code = p_sale_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف فاتورة المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION delete_inv_sales_rpc(p_sale_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_sale_record RECORD;
  v_result JSONB;
BEGIN
  BEGIN
    -- حذف الفاتورة مع إعادة الكميات
    PERFORM delete_sales_rpc(p_sale_id);
    
    -- حذف رأس الفاتورة
    DELETE FROM sales WHERE id = p_sale_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف الفاتورة كاملة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION delete_return_sales_rpc(p_return_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_record RECORD;
  v_detail_record RECORD;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب بيانات المرتجع
    SELECT id, id_stock, invoice_code
    INTO v_return_record
    FROM return_sales 
    WHERE id = p_return_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'المرتجع غير موجود'
      );
    END IF;

    -- إزالة الكمية التي تم إرجاعها
    FOR v_detail_record IN 
      SELECT 
        rsd.id_item,
        rsd.qty,
        rsd.purchase_detail_id,
        COALESCE(i.is_item, 1) as is_item
      FROM return_sales_detals rsd
      LEFT JOIN items i ON rsd.id_item = i.id
      WHERE rsd.id_invoice_code = p_return_id
      AND rsd.qty > 0
    LOOP
      IF v_detail_record.is_item = 1 THEN
        PERFORM process_transaction_rpc(
          'sale',
          v_detail_record.id_item,
          v_return_record.id_stock,
          v_detail_record.qty,
          NULL,
          FALSE,
          v_detail_record.purchase_detail_id
        );
      END IF;
    END LOOP;

    -- حذف البيانات
    DELETE FROM payments WHERE code = v_return_record.invoice_code;
    DELETE FROM return_sales_detals WHERE id_invoice_code = p_return_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف مرتجع المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;





CREATE OR REPLACE FUNCTION delete_inv_return_sales_rpc(p_return_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
BEGIN
  BEGIN
    -- حذف المرتجع مع إزالة الكميات
    PERFORM delete_return_sales_rpc(p_return_id);
    
    -- حذف رأس المرتجع
    DELETE FROM return_sales WHERE id = p_return_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف مرتجع المبيعات كامل بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION edit_sales_rpc(
  p_new_status TEXT,
  p_sale_id INTEGER,
  p_id_customer INTEGER,
  p_id_delivery INTEGER,
  p_id_stock INTEGER,
  p_dis TEXT,
  p_disv DOUBLE PRECISION,
  p_tax INTEGER,
  p_items JSONB,
  p_payments JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_current_status TEXT;
  v_invoice_code TEXT;
  v_date TEXT;
  v_item JSONB;
  v_payment JSONB;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب الحالة الحالية
    SELECT status, invoice_code, date
    INTO v_current_status, v_invoice_code, v_date
    FROM sales WHERE id = p_sale_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'الفاتورة غير موجودة');
    END IF;

    v_current_status := COALESCE(v_current_status, 'delivered');

    -- حذف التفاصيل القديمة
    PERFORM delete_sales_rpc(p_sale_id);

    -- تحديث رأس الفاتورة
    UPDATE sales SET
      id_customer = p_id_customer,
      id_delivery = p_id_delivery,
      id_stock = p_id_stock,
      type_dic = p_dis,
      value_dic = p_disv,
      status = p_new_status,
      taxid = p_tax,
      updated_at = NOW()
    WHERE id = p_sale_id;

    -- إعادة إدخال الدفعات
    DELETE FROM payments WHERE code = v_invoice_code;
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (code, date, type, price, paytype_id)
      VALUES (
        v_invoice_code,
        v_date::DATE,
        'sales',
        (v_payment->>'price')::DOUBLE PRECISION,
        (v_payment->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل الجديدة
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      INSERT INTO sales_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
        price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, p_sale_id,
        (v_item->>'qty')::DOUBLE PRECISION,
        (v_item->>'dis_value')::DOUBLE PRECISION,
        v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER,
        (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION,
        v_item->>'expirydate',
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- خصم الكمية إذا كانت الحالة مكتملة
      IF p_new_status = 'delivered' AND (v_item->>'is_item')::BOOLEAN = true THEN
        PERFORM process_transaction_rpc(
          'sale',
          (v_item->>'id')::INTEGER,
          p_id_stock,
          (v_item->>'qty')::DOUBLE PRECISION,
          NULL,
          TRUE,
          (v_item->>'purchase_detail_id')::INTEGER
        );
      END IF;
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تعديل فاتورة المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION edit_sales_return_rpc(
  p_return_id INTEGER,
  p_id_customer INTEGER,
  p_id_delivery INTEGER,
  p_date DATE,
  p_time TEXT,
  p_note TEXT,
  p_dis TEXT,
  p_disv DOUBLE PRECISION,
  p_tax INTEGER,
  p_stock_id INTEGER,
  p_items JSONB,
  p_payments JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_invoice_code TEXT;
  v_result JSONB;
  v_item JSONB;
  v_payment JSONB;
BEGIN
  BEGIN
    -- حذف التفاصيل القديمة
    PERFORM delete_return_sales_rpc(p_return_id);

    -- تحديث رأس المرتجع
    UPDATE return_sales SET
      id_customer = p_id_customer,
      id_delivery = p_id_delivery,
      date = p_date,
      time = p_time,
      note = p_note,
      type_dic = p_dis,
      value_dic = p_disv,
      taxid = p_tax,
      id_stock = p_stock_id,
      updated_at = NOW()
    WHERE id = p_return_id
    RETURNING invoice_code INTO v_invoice_code;

    -- إعادة الدفعات
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (code, date, type, price, paytype_id)
      VALUES (
        v_invoice_code,
        p_date,
        'rsales',
        (v_payment->>'price')::DOUBLE PRECISION,
        (v_payment->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل الجديدة
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      INSERT INTO return_sales_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
        price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, p_return_id,
        (v_item->>'qty')::DOUBLE PRECISION,
        (v_item->>'dis_value')::DOUBLE PRECISION,
        v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER,
        (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION,
        v_item->>'expirydate',
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- إضافة الكمية كدفعة جديدة
      IF (v_item->>'is_item')::BOOLEAN = true THEN
        PERFORM process_transaction_rpc(
          'return_sale',
          (v_item->>'id')::INTEGER,
          p_stock_id,
          (v_item->>'qty')::DOUBLE PRECISION,
          v_item->>'expirydate',
          FALSE,
          NULL
        );
      END IF;
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تعديل مرتجع المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;



CREATE OR REPLACE FUNCTION change_invoice_status_rpc(
  p_invoice_code TEXT,
  p_new_status TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_sale_record RECORD;
  v_detail_record RECORD;
  v_old_status TEXT;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب بيانات الفاتورة
    SELECT id, id_stock, status
    INTO v_sale_record
    FROM sales 
    WHERE invoice_code = p_invoice_code;

    IF NOT FOUND THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'الفاتورة غير موجودة'
      );
    END IF;

    v_old_status := COALESCE(v_sale_record.status, 'delivered');

    -- إذا لم يتغير وضع التسليم، تحديث الحالة فقط
    IF (v_old_status = 'delivered') = (p_new_status = 'delivered') THEN
      UPDATE sales 
      SET status = p_new_status,
          updated_at = NOW()
      WHERE invoice_code = p_invoice_code;
      
      RETURN jsonb_build_object(
        'success', true,
        'message', 'تم تحديث الحالة بنجاح'
      );
    END IF;

    -- معالجة تغيير حالة التسليم
    FOR v_detail_record IN 
      SELECT 
        sd.id_item,
        sd.qty,
        sd.purchase_detail_id,
        COALESCE(i.is_item, 1) as is_item
      FROM sales_detals sd
      LEFT JOIN items i ON sd.id_item = i.id
      WHERE sd.id_invoice_code = v_sale_record.id
      AND sd.qty > 0
    LOOP
      IF v_detail_record.is_item = 1 THEN
        IF p_new_status = 'delivered' THEN
          -- أصبحت مكتملة → خصم من المخزن
          PERFORM process_transaction_rpc(
            'sale',
            v_detail_record.id_item,
            v_sale_record.id_stock,
            v_detail_record.qty,
            NULL,
            TRUE,
            v_detail_record.purchase_detail_id
          );
        ELSE
          -- كانت مكتملة وأصبحت غير ذلك → إعادة الكمية
          PERFORM process_transaction_rpc(
            'return_sale',
            v_detail_record.id_item,
            v_sale_record.id_stock,
            v_detail_record.qty,
            NULL,
            FALSE,
            v_detail_record.purchase_detail_id
          );
        END IF;
      END IF;
    END LOOP;

    -- تحديث الحالة النهائية
    UPDATE sales 
    SET status = p_new_status,
        updated_at = NOW()
    WHERE invoice_code = p_invoice_code;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تغيير حالة الفاتورة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;



CREATE OR REPLACE FUNCTION add_sales_rpc(
  p_invoice_status TEXT,
  p_id INTEGER,
  p_userid INTEGER,
  p_inv_code TEXT,
  p_id_customer INTEGER,
  p_date DATE,
  p_dis TEXT,
  p_disv DOUBLE PRECISION,
  p_tax INTEGER,
  p_id_delivery INTEGER,
  p_stock_id INTEGER,
  p_items JSONB,
  p_payments JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_sale_id INTEGER;
  v_item JSONB;
  v_payment JSONB;
  v_result JSONB;
BEGIN
  BEGIN
    -- إدخال فاتورة المبيعات
    INSERT INTO sales (
      id, invoice_code, userid, id_customer, type_dic, 
      value_dic, taxid, id_delivery, date, id_stock, status
    ) VALUES (
      p_id, p_inv_code, p_userid, p_id_customer, p_dis,
      p_disv, p_tax, p_id_delivery, p_date, p_stock_id, p_invoice_status
    ) RETURNING id INTO v_sale_id;

    -- إدخال الدفعات المالية
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        p_inv_code, p_date, 'sales',
        (v_payment->>'price')::DOUBLE PRECISION,
        (v_payment->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      INSERT INTO sales_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, 
        taxid, price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, v_sale_id,
        (v_item->>'qty')::DOUBLE PRECISION,
        (v_item->>'dis_value')::DOUBLE PRECISION, v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER, (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION, v_item->>'expirydate',
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- خصم الكمية إذا كانت الفاتورة مكتملة
      IF p_invoice_status = 'delivered' AND 
         (v_item->>'is_item')::BOOLEAN = true THEN
        PERFORM process_transaction_rpc(
          'sale',
          (v_item->>'id')::INTEGER,
          p_stock_id,
          (v_item->>'qty')::DOUBLE PRECISION,
          NULL,
          TRUE,
          (v_item->>'purchase_detail_id')::INTEGER
        );
      END IF;
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'sale_id', v_sale_id,
      'message', 'تم إضافة فاتورة المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;





CREATE OR REPLACE FUNCTION add_return_sales_rpc(
  p_id INTEGER,
  p_userid INTEGER,
  p_id_customer INTEGER,
  p_sales_id INTEGER,
  p_id_delivery INTEGER,
  p_date DATE,
  p_time TEXT,
  p_inv_code TEXT,
  p_note TEXT,
  p_dis TEXT,
  p_disv DOUBLE PRECISION,
  p_tax INTEGER,
  p_stock_id INTEGER,
  p_items JSONB,
  p_payments JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_id INTEGER;
  v_item JSONB;
  v_payment JSONB;
  v_result JSONB;
BEGIN
  BEGIN
    -- إدخال فاتورة المرتجع
    INSERT INTO return_sales (
      id, invoice_code, sales_id, userid, id_customer, id_delivery,
      date, time, note, type_dic, value_dic, taxid, id_stock
    ) VALUES (
      p_id, p_inv_code, p_sales_id, p_userid, p_id_customer, p_id_delivery,
      p_date, p_time, p_note, p_dis, p_disv, p_tax, p_stock_id
    ) RETURNING id INTO v_return_id;

    -- إدخال الدفعات المالية
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        p_inv_code, p_date, 'rsales',
        (v_payment->>'price')::DOUBLE PRECISION,
        (v_payment->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل وإعادة الكمية
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      INSERT INTO return_sales_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
        price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, v_return_id,
        (v_item->>'qty')::DOUBLE PRECISION,
        (v_item->>'dis_value')::DOUBLE PRECISION, v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER, (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION, v_item->>'expirydate',
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- إعادة الكمية إلى الدفعة الأصلية
      IF (v_item->>'is_item')::BOOLEAN = true THEN
        IF (v_item->>'purchase_detail_id')::INTEGER IS NOT NULL THEN
          PERFORM return_qty_to_specific_batch_rpc(
            (v_item->>'purchase_detail_id')::INTEGER,
            (v_item->>'qty')::DOUBLE PRECISION,
            p_stock_id
          );
        ELSE
          PERFORM process_transaction_rpc(
            'return_sale',
            (v_item->>'id')::INTEGER,
            p_stock_id,
            (v_item->>'qty')::DOUBLE PRECISION,
            v_item->>'expirydate',
            FALSE,
            NULL
          );
        END IF;
      END IF;
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'return_id', v_return_id,
      'message', 'تم إضافة مرتجع المبيعات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;




DROP FUNCTION IF EXISTS add_batch_rpc(
  INTEGER, INTEGER,INTEGER 
  , TEXT, DOUBLE PRECISION 
);

DROP FUNCTION IF EXISTS add_batch_rpc(
  INTEGER, INTEGER,INTEGER 
  , TEXT, DOUBLE PRECISION 
);

DROP FUNCTION IF EXISTS add_return_purchase_rpc(
  INTEGER,
  INTEGER,
  INTEGER,
  INTEGER ,
  DATE,
  TEXT,
  TEXT,
  INTEGER,
  DOUBLE PRECISION,
  TEXT,
  DOUBLE PRECISION,
  INTEGER ,
  JSONB,
  JSONB,
  TEXT
);

DROP FUNCTION IF EXISTS decrease_batch_rpc(
  INTEGER, INTEGER, DOUBLE PRECISION,BOOLEAN,INTEGER 
);


CREATE OR REPLACE FUNCTION decrease_batch_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_quantity DOUBLE PRECISION,
  p_check_qty BOOLEAN DEFAULT TRUE,
  p_purchase_detail_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
  v_available_qty DOUBLE PRECISION;
  v_affected_rows INTEGER;
BEGIN
  BEGIN
    RAISE NOTICE 'بدء تقليل الدفعة - عنصر: %, مخزن: %, كمية: %, تفصيل: %', 
      p_item_id, p_stock_id, p_quantity, p_purchase_detail_id;

    IF p_purchase_detail_id IS NOT NULL AND p_purchase_detail_id > 0 THEN
      -- تقليل من دفعة معينة
      UPDATE batches 
      SET quantity = quantity - p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = p_purchase_detail_id 
        AND stock_id = p_stock_id
        AND item_id = p_item_id;
      
      GET DIAGNOSTICS v_affected_rows = ROW_COUNT;
      RAISE NOTICE 'عدد الصفوف المتأثرة: %', v_affected_rows;
      
      -- التحقق من الكمية إذا كان مطلوباً
      IF p_check_qty THEN
        SELECT quantity INTO v_available_qty
        FROM batches 
        WHERE purchase_detail_id = p_purchase_detail_id 
          AND stock_id = p_stock_id
          AND item_id = p_item_id;
        
        RAISE NOTICE 'الكمية المتاحة بعد التقليل: %', v_available_qty;
        
        IF v_available_qty < 0 THEN
          RAISE EXCEPTION 'الكمية لا يمكن أن تكون سالبة للدفعة: %', p_purchase_detail_id;
        END IF;
      END IF;
      
      IF v_affected_rows = 0 THEN
        RAISE NOTICE '⚠️ لم يتم العثور على الدفعة المحددة للتقليل';
        RAISE EXCEPTION 'لم يتم العثور على الدفعة المحددة للتقليل';
      END IF;
      
    ELSE
      RAISE NOTICE '⚠️ لم يتم تحديد purchase_detail_id، جاري استخدام FEFO';
      -- استخدام FEFO إذا لم تُحدد الدفعة
      PERFORM sell_from_batches_rpc(
        p_item_id,
        p_stock_id,
        p_quantity,
        p_check_qty
      );
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تقليل الكمية بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '❌ خطأ في decrease_batch_rpc: %', SQLERRM;
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;
CREATE OR REPLACE FUNCTION add_return_purchase_rpc(
  p_id INTEGER DEFAULT 0,
  p_userid INTEGER DEFAULT 0,
  p_supplierid INTEGER DEFAULT NULL,
  p_purchase_id INTEGER DEFAULT NULL,
  p_date TEXT DEFAULT NULL,
  p_time TEXT DEFAULT '00:00:00',
  p_inv_code TEXT DEFAULT 'TEMP-RETURN-INV',
  p_tax INTEGER DEFAULT NULL,
  p_charge DOUBLE PRECISION DEFAULT 0.0,
  p_dis INTEGER DEFAULT 0,
  p_disvalue DOUBLE PRECISION DEFAULT 0.0,
  p_stock_id INTEGER DEFAULT 0,
  p_items JSONB DEFAULT '[]'::JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_account_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_id INTEGER;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty DOUBLE PRECISION;
  v_current_date TEXT := to_char(CURRENT_DATE, 'YYYY-MM-DD');
  v_items_count INTEGER;
  v_payments_count INTEGER;
  v_next_id INTEGER;
  v_process_rpc_exists BOOLEAN;
BEGIN
  -- التحقق من وجود دالة process_transaction_rpc مرة واحدة
  SELECT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'process_transaction_rpc'
  ) INTO v_process_rpc_exists;
  
  RAISE NOTICE 'دالة process_transaction_rpc موجودة: %', v_process_rpc_exists;

  BEGIN
    -- التحقق من البيانات الواردة
    RAISE NOTICE 'بيانات الواردة - items: %, payments: %', p_items, p_payments;
    
    -- حساب عدد العناصر والدفعات
    v_items_count := jsonb_array_length(p_items);
    v_payments_count := jsonb_array_length(p_payments);
    
    RAISE NOTICE 'عدد العناصر: %, عدد الدفعات: %', v_items_count, v_payments_count;

    -- 1. إدخال فاتورة المرتجع الرئيسية
    IF p_id = 0 THEN
      SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_id FROM return_purchases;
      RAISE NOTICE 'الرقم التالي لمرتجع الشراء: %', v_next_id;

      INSERT INTO return_purchases (
        id, invoice_code, purchase_id, userid, account_id, id_supplier, 
        date, taxid, charge_price, type_dic, value_dic, id_stock, time
      ) VALUES (
        v_next_id,
        p_inv_code, 
        p_purchase_id, 
        p_userid, 
        p_account_id, 
        p_supplierid,
        COALESCE(p_date, v_current_date), 
        p_tax, 
        p_charge, 
        p_dis, 
        p_disvalue, 
        p_stock_id, 
        p_time
      ) RETURNING id INTO v_return_id;
    ELSE
      -- التحقق من عدم تكرار ID
      IF EXISTS (SELECT 1 FROM return_purchases WHERE id = p_id) THEN
        RAISE EXCEPTION 'رقم مرتجع الشراء % موجود مسبقاً', p_id;
      END IF;
      
      INSERT INTO return_purchases (
        id, invoice_code, purchase_id, userid, account_id, id_supplier, 
        date, taxid, charge_price, type_dic, value_dic, id_stock, time
      ) VALUES (
        p_id, 
        p_inv_code, 
        p_purchase_id, 
        p_userid, 
        p_account_id, 
        p_supplierid,
        COALESCE(p_date, v_current_date), 
        p_tax, 
        p_charge, 
        p_dis, 
        p_disvalue, 
        p_stock_id, 
        p_time
      ) RETURNING id INTO v_return_id;
    END IF;

    RAISE NOTICE '✅ تم إنشاء مرتجع شراء برقم: %', v_return_id;

    -- 2. إدخال الدفعات المالية
    IF v_payments_count > 0 THEN
      RAISE NOTICE 'بدء إضافة الدفعات...';
      
      FOR i IN 0..(v_payments_count - 1)
      LOOP
        v_pay := p_payments -> i;
        RAISE NOTICE 'معالجة الدفعة: %', v_pay;
        
        INSERT INTO payments (
          code, date, type, price, paytype_id
        ) VALUES (
          p_inv_code, 
          COALESCE(p_date, v_current_date), 
          'rpur',
          COALESCE((v_pay->>'price')::DOUBLE PRECISION, 0),
          COALESCE((v_pay->>'pay_type')::INTEGER, 1)
        );
        
        RAISE NOTICE '✅ تم إضافة دفعة مرتجع بقيمة: %', (v_pay->>'price')::DOUBLE PRECISION;
      END LOOP;
    ELSE
      RAISE NOTICE '⚠️ لا توجد دفعات لإضافتها';
    END IF;

    -- 3. إدخال تفاصيل مرتجع المشتريات
    IF v_items_count > 0 THEN
      RAISE NOTICE 'بدء إضافة عناصر المرتجع...';
      
      FOR i IN 0..(v_items_count - 1)
      LOOP
        v_item := p_items -> i;
        RAISE NOTICE 'معالجة عنصر المرتجع: %', v_item;
        
        -- حساب الكمية الفعلية
        v_actual_qty := COALESCE((v_item->>'qty')::DOUBLE PRECISION, 0);
        RAISE NOTICE 'الكمية الفعلية للمرتجع: %', v_actual_qty;

        -- إدخال التفاصيل
        INSERT INTO return_purchase_detals (
          id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
          price, sell, expirydate, purchase_detail_id,
          barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
          unit_name, unit_base_qty
        ) VALUES (
          COALESCE((v_item->>'id')::INTEGER, 0), 
          v_return_id, 
          v_actual_qty,
          COALESCE((v_item->>'dis_value')::DOUBLE PRECISION, 0), 
          COALESCE((v_item->>'dis_type')::INTEGER, 0),
          NULLIF((v_item->>'taxid')::INTEGER, 0), 
          COALESCE((v_item->>'price')::DOUBLE PRECISION, 0),
          COALESCE((v_item->>'sell')::DOUBLE PRECISION, 0), 
          NULLIF(v_item->>'expirydate', ''),
          COALESCE(NULLIF((v_item->>'purchase_detail_id')::INTEGER, 0), 0),
          COALESCE(NULLIF(v_item->>'barcode1', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode2', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode3', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode4', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode5', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode6', ''), ''),
          COALESCE(v_item->>'unit_name', 'piece'),
          COALESCE((v_item->>'unit_base_qty')::DOUBLE PRECISION, 1.0)
        );

        RAISE NOTICE '✅ تم إضافة عنصر مرتجع برقم: %, كمية: %', 
          (v_item->>'id')::INTEGER, v_actual_qty;

        -- تقليل الكمية من الدفعات الأصلية
        IF v_process_rpc_exists THEN
          BEGIN
            PERFORM process_transaction_rpc(
              'return_purchase',
              COALESCE((v_item->>'id')::INTEGER, 0),
              p_stock_id,
              v_actual_qty,
              NULL,
              FALSE,
              COALESCE(NULLIF((v_item->>'purchase_detail_id')::INTEGER, 0), 0)
            );
            RAISE NOTICE '✅ تم استدعاء process_transaction_rpc للمرتجع';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE NOTICE '❌ خطأ في process_transaction_rpc للمرتجع: %', SQLERRM;
          END;
        ELSE
          RAISE NOTICE '⚠️ دالة process_transaction_rpc غير موجودة';
        END IF;
      END LOOP;
    ELSE
      RAISE NOTICE '⚠️ لا توجد عناصر مرتجع لإضافتها';
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'return_id', v_return_id,
      'message', 'تم إضافة مرتجع المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '❌ حدث خطأ في مرتجع الشراء: %', SQLERRM;
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'return_id', COALESCE(v_return_id, 0)
      );
  END;

  RETURN v_result;
END;
$$;



CREATE OR REPLACE FUNCTION add_batch_rpc(
  p_item_id INTEGER,
  p_stock_id INTEGER,
  p_purchase_detail_id INTEGER DEFAULT NULL,  -- جعلها المعامل الثالث
  p_expiry_date TEXT DEFAULT NULL,            -- جعلها المعامل الرابع  
  p_quantity DOUBLE PRECISION DEFAULT 0.0                -- جعلها المعامل الخامس
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_batch_exists BOOLEAN;
  v_result JSONB;
  v_actual_purchase_detail_id INTEGER;
BEGIN
  BEGIN
    -- تحديد purchase_detail_id الفعلي
    IF p_purchase_detail_id IS NOT NULL AND p_purchase_detail_id > 0 THEN
      v_actual_purchase_detail_id := p_purchase_detail_id;
    ELSE
      v_actual_purchase_detail_id := EXTRACT(EPOCH FROM NOW())::INTEGER;
    END IF;

    -- التحقق من وجود الدفعة
    SELECT EXISTS(
      SELECT 1 FROM batches 
      WHERE purchase_detail_id = v_actual_purchase_detail_id 
      AND stock_id = p_stock_id
    ) INTO v_batch_exists;
    
    IF v_batch_exists THEN
      -- تحديث الدفعة الموجودة
      UPDATE batches 
      SET quantity = quantity + p_quantity,
          updated_at = NOW()
      WHERE purchase_detail_id = v_actual_purchase_detail_id 
      AND stock_id = p_stock_id;
    ELSE
      -- إنشاء دفعة جديدة
      INSERT INTO batches (
        item_id, stock_id, purchase_detail_id, 
        expiry_date, quantity, created_at
      ) VALUES (
        p_item_id, p_stock_id, v_actual_purchase_detail_id,
        CASE 
          WHEN p_expiry_date IS NOT NULL AND p_expiry_date != '' 
          THEN p_expiry_date::DATE 
          ELSE NULL 
        END, 
        p_quantity, 
        NOW()
      );
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم إضافة/تحديث الدفعة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;



CREATE OR REPLACE FUNCTION get_all_supplier_purchases1(
  search_query TEXT DEFAULT '',
  from_date TEXT DEFAULT NULL,
  to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    -- المشتريات العادية
    SELECT 
      -- تحديد الأعمدة بشكل صريح من جدول purchases
      p.id,
      p.invoice_code,
      p.userid,
      p.id_supplier,
      p.charge_price,
      p.value_dic,
      p.type_dic,
      p.date,
      p.id_stock,
      p.time,
      p.account_id,
      p.taxid,
      p.created_at,
      -- أعمدة إضافية
      's' AS state,
      COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
      0.0::NUMERIC AS totalcharge,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      sup.name AS suppliername,
      s.name AS stockname,
      NULL::TEXT AS invcode,
      
      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.price 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.price - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) + p.charge_price AS total,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.price 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.price - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.price - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.price 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.price - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"
    FROM purchases p
    JOIN purchase_details pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN suppliers sup ON p.id_supplier = sup.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE (
      (search_query = '' OR sup.name ILIKE '%' || search_query || '%')
      AND (from_date IS NULL OR p.date::DATE >= from_date::DATE)
      AND (to_date IS NULL OR p.date::DATE <= to_date::DATE)
    )
    GROUP BY p.id, p.invoice_code, p.userid, p.id_supplier, p.charge_price, 
             p.value_dic, p.type_dic, p.date, p.id_stock, p.time, 
             p.account_id, p.taxid, p.created_at, sup.name, s.name, t.id
    
    UNION ALL
    
    -- المشتريات المرتجعة
    SELECT 
      -- تحديد الأعمدة بشكل صريح من جدول return_purchases
      p.id,
      p.invoice_code,
      p.userid,
      p.id_supplier,
      p.charge_price,
      p.value_dic,
      p.type_dic,
      p.date,
      p.id_stock,
      p.time,
      p.account_id,
      p.taxid,
      p.created_at,
      -- أعمدة إضافية
      'r' AS state,
      COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total1,
      COALESCE(SUM(p.charge_price), 0.0) AS totalcharge,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      sup.name AS suppliername,
      s.name AS stockname,
      pur.invoice_code AS invcode,
      
      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.price 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.price - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.price 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.price - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.price - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.price 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.price - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"
    FROM return_purchases p
    JOIN return_purchase_detals pd ON p.id = pd.id_invoice_code
    LEFT JOIN purchases pur ON p.purchase_id = pur.id
    JOIN items i ON pd.id_item = i.id
    JOIN suppliers sup ON p.id_supplier = sup.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    LEFT JOIN taxs t ON p.taxid = t.id
    WHERE (
      (search_query = '' OR sup.name ILIKE '%' || search_query || '%')
      AND (from_date IS NULL OR p.date::DATE >= from_date::DATE)
      AND (to_date IS NULL OR p.date::DATE <= to_date::DATE)
    )
    GROUP BY p.id, p.invoice_code, p.userid, p.id_supplier, p.charge_price, 
             p.value_dic, p.type_dic, p.date, p.id_stock, p.time, 
             p.account_id, p.taxid, p.created_at, sup.name, s.name, 
             t.id, pur.invoice_code
  ) t
  -- لا تستخدم ORDER BY هنا، بل قم بالترتيب داخل json_agg
  ;
  
  -- بدلاً من ذلك، يمكنك إرجاع النتيجة مرتبة
  IF result IS NULL THEN
    RETURN '[]'::json;
  ELSE
    -- ترتيب النتائج بعد تجميعها
    SELECT json_agg(items ORDER BY (items->>'date') DESC, (items->>'id')::INTEGER DESC)
    INTO result
    FROM json_array_elements(result) items;
    
    RETURN COALESCE(result, '[]'::json);
  END IF;
END;
$$;


CREATE OR REPLACE FUNCTION get_all_sales2(
  p_id TEXT DEFAULT '',
   p_from_date TEXT DEFAULT NULL,
  p_to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      cus.name AS customername,
      cus.id AS customerid,
      s.name AS stockname,
      dy.name AS deliveryname,
      u.name AS username,

      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total,

      -- إجمالي الربح
      COALESCE(SUM(
        pd.qty * (
          (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
          - pd.price
        )
      ), 0.0) AS profit,

      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",

      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"

    FROM sales p
    JOIN sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    
    -- بناء شروط WHERE ديناميكياً
    WHERE (
      (p.status = 'delivered' OR p.status IS NULL)
      AND (p_id = '' OR p.invoice_code ILIKE '%' || p_id || '%')
      AND (p_from_date IS NULL OR p.date::DATE >= p_from_date::DATE)
      AND (p_to_date IS NULL OR p.date::DATE <= p_to_date::DATE)
    )
    
    GROUP BY p.id, cus.id, s.id, dy.id, u.id, t.id
    ORDER BY p.date DESC, p.id DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_batches_for_item(
  p_item_id INTEGER,
  p_stock_id INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      b.id,
      b.purchase_detail_id,
      b.quantity,
      b.expiry_date,
      i.name
    FROM batches b
    JOIN items i ON b.item_id = i.id
    WHERE b.item_id = p_item_id 
      AND b.stock_id = p_stock_id 
      AND b.quantity > 0
    ORDER BY b.expiry_date ASC NULLS LAST
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_stock_batches(
  p_stock_id INTEGER,
  p_search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      b.id,
      b.quantity AS batch_quantity,
      b.expiry_date,
      b.purchase_detail_id,
      i.id AS item_id,
      i.name AS item_name,
      i.price AS purchase_price,
      i.sell AS sell_price,
      inv.name AS stock_name,
      ty.name AS tyname
    FROM batches b
    JOIN items i ON b.item_id = i.id
    JOIN inventory inv ON b.stock_id = inv.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE inv.id = p_stock_id 
      AND i.name ILIKE '%' || p_search_query || '%'
      AND b.quantity > 0
    ORDER BY i.name, b.expiry_date ASC NULLS LAST
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_aggregated_stock(
  p_stock_id INTEGER,
  p_search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      i.id,
      i.name,
      i.price,
      i.sell,
      COALESCE(SUM(b.quantity), 0) AS final_quantity,
      inv.name AS stock_name,
      ty.name AS tyname
    FROM items i
    JOIN batches b ON i.id = b.item_id
    JOIN inventory inv ON b.stock_id = inv.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE inv.id = p_stock_id 
      AND i.name ILIKE '%' || p_search_query || '%'
      AND b.quantity > 0
    GROUP BY i.id, i.name, i.price, i.sell, inv.name, ty.name
    HAVING COALESCE(SUM(b.quantity), 0) > 0
    ORDER BY i.name
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;









CREATE OR REPLACE FUNCTION get_all_customer_sales1(
  search_query TEXT DEFAULT '',
  from_date DATE DEFAULT NULL,
  to_date DATE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    -- المبيعات العادية
    SELECT 
      -- تحديد الأعمدة بشكل صريح من جدول sales
      p.id,
      p.invoice_code,
      p.userid,
      p.id_customer,
      p.id_delivery,
      p.note,
      p.value_dic,
      p.type_dic,
      p.taxid,
      p.id_stock,
      p.account_id,
      p.date,
      p.time,
      p.status,
      p.id_table,
      p.created_at,
      -- أعمدة إضافية
      's' AS state,
      COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      cus.name AS customername,
      cus.id AS customerid,
      cus.number_phone AS customernumberphone,
      s.name AS stockname,
      dy.name AS deliveryname,
      u.name AS username,
      NULL::TEXT AS invcode,
      
      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"
    FROM sales p
    JOIN sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE (
      (search_query = '' OR search_query = 'walk_in' OR 
       cus.name ILIKE '%' || search_query || '%' OR 
       cus.number_phone ILIKE '%' || search_query || '%')
      AND (from_date IS NULL OR p.date::DATE >= from_date::DATE)
      AND (to_date IS NULL OR p.date::DATE <= to_date::DATE)
    )
    GROUP BY p.id, p.invoice_code, p.userid, p.id_customer, p.id_delivery, 
             p.note, p.value_dic, p.type_dic, p.taxid, p.id_stock, 
             p.account_id, p.date, p.time, p.status, p.id_table, p.created_at,
             cus.name, cus.id, cus.number_phone, s.name, dy.name, u.name, t.id
    
    UNION ALL
    
    -- المبيعات المرتجعة
    SELECT 
      -- تحديد الأعمدة بشكل صريح من جدول return_sales
      p.id,
      p.invoice_code,
      p.userid,
      p.id_customer,
      p.id_delivery,
      p.note,
      p.value_dic,
      p.type_dic,
      p.taxid,
      p.id_stock,
      p.account_id,
      p.date,
      p.time,
      NULL::TEXT AS status,
      NULL::TEXT AS id_table,
      p.created_at,
      -- أعمدة إضافية
      'r' AS state,
      COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      cus.name AS customername,
      cus.id AS customerid,
      cus.number_phone AS customernumberphone,
      s.name AS stockname,
      dy.name AS deliveryname,
      u.name AS username,
      sal.invoice_code AS invcode,
      
      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"
    FROM return_sales p
    JOIN return_sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    LEFT JOIN sales sal ON p.sales_id = sal.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE (
      (search_query = '' OR search_query = 'walk_in' OR 
       cus.name ILIKE '%' || search_query || '%' OR 
       cus.number_phone ILIKE '%' || search_query || '%')
      AND (from_date IS NULL OR p.date::DATE >= from_date::DATE)
      AND (to_date IS NULL OR p.date::DATE <= to_date::DATE)
    )
    GROUP BY p.id, p.invoice_code, p.userid, p.id_customer, p.id_delivery, 
             p.note, p.value_dic, p.type_dic, p.taxid, p.id_stock, 
             p.account_id, p.date, p.time, p.created_at,
             cus.name, cus.id, cus.number_phone, s.name, dy.name, 
             u.name, t.id, sal.invoice_code
  ) t
  -- لا تستخدم ORDER BY هنا
  ;
  
  -- ترتيب النتائج بعد تجميعها
  IF result IS NULL THEN
    RETURN '[]'::json;
  ELSE
    SELECT json_agg(items ORDER BY 
      (items->>'date') DESC NULLS LAST,
      (items->>'id')::INTEGER DESC NULLS LAST)
    INTO result
    FROM json_array_elements(result) items;
    
    RETURN COALESCE(result, '[]'::json);
  END IF;
END;
$$;




CREATE OR REPLACE FUNCTION calculate_bettwen_expenses(
  start_date DATE,
  end_date DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'invoice_count', COALESCE(COUNT(*), 0),
    'total_value', COALESCE(SUM(price), 0),
    'average_expense', COALESCE(AVG(price), 0),
    'max_expense', COALESCE(MAX(price), 0),
    'min_expense', COALESCE(MIN(price), 0)
  ) INTO result
  FROM expansive
  WHERE DATE(date) BETWEEN start_date AND end_date;
  
  RETURN COALESCE(result, '{"invoice_count": 0, "total_value": 0}'::json);
END;
$$;


CREATE OR REPLACE FUNCTION calculate_between_sales(
  date_from DATE,
  date_to DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_value', COALESCE(SUM(total_value), 0),
    'paid', COALESCE(SUM(paid), 0),
    'total_discount', COALESCE(SUM(total_discount), 0),
    'itemdis', COALESCE(SUM(itemdis), 0),
    'total_tax', COALESCE(SUM(total_tax), 0),
    'itemtax', COALESCE(SUM(itemtax), 0),
    'total_profit', COALESCE(SUM(total_profit), 0),
    'sales_count', COUNT(*),
    'average_sale', COALESCE(AVG(total_value), 0),
    'max_sale', COALESCE(MAX(total_value), 0),
    'min_sale', COALESCE(MIN(total_value), 0),
    'details', (
      SELECT json_agg(row_to_json(t))
      FROM (
        SELECT 
          p.id,
          p.invoice_code,
          p.date,
          s.name AS stockname,
          -- الإجمالي مع الضريبة والخصم
          COALESCE(SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ), 0.0) AS total_value,
          -- الربح
          COALESCE(SUM(
            pd.qty * (
              (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.sell - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
              - pd.price
            )
          ), 0.0) AS profit
        FROM sales p
        JOIN sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        WHERE DATE(p.date) BETWEEN date_from AND date_to
          AND (p.status = 'delivered' OR p.status IS NULL)
        GROUP BY p.id, s.id
      ) t
    )
  ) INTO result
  FROM (
    SELECT 
      -- إجمالي المبيعات
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total_value,
      
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      
      -- خصم الأصناف
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
          WHEN pd.type_dic = 1 THEN pd.value_dic
          ELSE 0.0
        END
      ), 0.0) AS itemdis,
      
      -- ضريبة الأصناف
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN ti.type = 0 THEN (
            (pd.sell - 
              CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0.0
              END
            ) * ti.value / 100
          )
          WHEN ti.type = 1 THEN ti.value
          ELSE 0.0
        END
      ), 0.0) AS itemtax,
      
      -- الربح الإجمالي
      COALESCE(SUM(
        pd.qty * (
          (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
          - pd.price
        )
      ), 0.0) AS total_profit,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (
          SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) * p.value_dic / 100
        )
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS total_discount,
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (
            SUM(
              pd.qty * (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.sell - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) 
            - CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.sell 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.sell - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
          ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS total_tax
    FROM sales p
    JOIN sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE DATE(p.date) BETWEEN date_from AND date_to
      AND (p.status = 'delivered' OR p.status IS NULL)
    GROUP BY p.id, t.id
  ) subquery;

  RETURN COALESCE(result, '{}'::json);
END;
$$;



CREATE OR REPLACE FUNCTION get_inv_ketchine_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      pt.id AS paytype,
      pt.name AS payment_type_name,
      k.invoice_code AS ketchine_code,
      k.status AS ketchine_status
    FROM payments p
    JOIN pay_types pt ON p.paytype_id = pt.id
    JOIN ketchine k ON p.code = k.invoice_code
    WHERE p.code ILIKE '%' || search_query || '%'
    ORDER BY p.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;









CREATE OR REPLACE FUNCTION add_purchase_rpc19(
  p_id INTEGER DEFAULT 0,
  p_userid INTEGER DEFAULT 0,
  p_supplierid INTEGER DEFAULT NULL,
  p_date TEXT DEFAULT NULL,
  p_charge REAL DEFAULT 0.0,
  p_time TEXT DEFAULT '00:00:00',
  p_inv_code TEXT DEFAULT 'TEMP-INV',
  p_type_dic INTEGER DEFAULT 0,
  p_value_dic REAL DEFAULT 0.0,
  p_taxid INTEGER DEFAULT NULL,
  p_stockid INTEGER DEFAULT 0,
  p_items JSONB DEFAULT '[]'::JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_account_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_purchase_id INTEGER;
  v_detail_id INTEGER;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty REAL;
  v_current_date TEXT := to_char(CURRENT_DATE, 'YYYY-MM-DD');
  v_items_count INTEGER;
  v_payments_count INTEGER;
  v_next_id INTEGER;
  v_process_rpc_exists BOOLEAN;
BEGIN
  -- التحقق من وجود دالة process_transaction_rpc مرة واحدة
  SELECT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'process_transaction_rpc'
  ) INTO v_process_rpc_exists;
  
  RAISE NOTICE 'دالة process_transaction_rpc موجودة: %', v_process_rpc_exists;

  BEGIN
    -- التحقق من البيانات الواردة
    RAISE NOTICE 'بيانات الواردة - items: %, payments: %', p_items, p_payments;
    
    -- حساب عدد العناصر والدفعات
    v_items_count := jsonb_array_length(p_items);
    v_payments_count := jsonb_array_length(p_payments);
    
    RAISE NOTICE 'عدد العناصر: %, عدد الدفعات: %', v_items_count, v_payments_count;

    -- 1. إدخال الفاتورة الرئيسية
    IF p_id = 0 THEN
      SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_id FROM purchases;
      RAISE NOTICE 'الرقم التالي للفاتورة: %', v_next_id;

      INSERT INTO purchases (
        id, invoice_code, userid, id_supplier, account_id, taxid, 
        charge_price, type_dic, value_dic, id_stock, date, time
      ) VALUES (
        v_next_id,
        p_inv_code, 
        p_userid, 
        p_supplierid, 
        p_account_id, 
        p_taxid,
        p_charge, 
        p_type_dic, 
        p_value_dic, 
        p_stockid, 
        COALESCE(p_date, v_current_date),
        p_time
      ) RETURNING id INTO v_purchase_id;
    ELSE
      -- التحقق من عدم تكرار ID
      IF EXISTS (SELECT 1 FROM purchases WHERE id = p_id) THEN
        RAISE EXCEPTION 'رقم الفاتورة % موجود مسبقاً', p_id;
      END IF;
      
      INSERT INTO purchases (
        id, invoice_code, userid, id_supplier, account_id, taxid, 
        charge_price, type_dic, value_dic, id_stock, date, time
      ) VALUES (
        p_id, 
        p_inv_code, 
        p_userid, 
        p_supplierid, 
        p_account_id, 
        p_taxid,
        p_charge, 
        p_type_dic, 
        p_value_dic, 
        p_stockid, 
        COALESCE(p_date, v_current_date),
        p_time
      ) RETURNING id INTO v_purchase_id;
    END IF;

    RAISE NOTICE '✅ تم إنشاء فاتورة برقم: %', v_purchase_id;

    -- 2. إدخال الدفعات المالية
    IF v_payments_count > 0 THEN
      RAISE NOTICE 'بدء إضافة الدفعات...';
      
      FOR i IN 0..(v_payments_count - 1)
      LOOP
        v_pay := p_payments -> i;
        RAISE NOTICE 'معالجة الدفعة: %', v_pay;
        
        INSERT INTO payments (
          code, date, type, price, paytype_id
        ) VALUES (
          p_inv_code, 
          COALESCE(p_date, v_current_date), 
          'pur',
          COALESCE((v_pay->>'price')::REAL, 0),
          COALESCE((v_pay->>'pay_type')::INTEGER, 1)
        );
        
        RAISE NOTICE '✅ تم إضافة دفعة بقيمة: %', (v_pay->>'price')::REAL;
      END LOOP;
    ELSE
      RAISE NOTICE '⚠️ لا توجد دفعات لإضافتها';
    END IF;

    -- 3. إدخال تفاصيل المشتريات
    IF v_items_count > 0 THEN
      RAISE NOTICE 'بدء إضافة العناصر...';
      
      FOR i IN 0..(v_items_count - 1)
      LOOP
        v_item := p_items -> i;
        RAISE NOTICE 'معالجة العنصر: %', v_item;
        
        -- حساب الكمية الفعلية
        v_actual_qty := COALESCE((v_item->>'qty')::REAL, 0);
        RAISE NOTICE 'الكمية الفعلية: %', v_actual_qty;

        -- إدخال التفاصيل
        INSERT INTO purchase_details (
          id_item, id_invoice_code, qty, value_dic, type_dic, taxid, 
          price, sell, purchase_detail_id, expirydate,
          barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
          unit_name, unit_base_qty
        ) VALUES (
          COALESCE((v_item->>'id')::INTEGER, 0), 
          v_purchase_id, 
          v_actual_qty,
          COALESCE((v_item->>'dis_value')::REAL, 0), 
          COALESCE((v_item->>'dis_type')::INTEGER, 0),
          NULLIF((v_item->>'taxid')::INTEGER, 0), 
          COALESCE((v_item->>'price')::REAL, 0),
          COALESCE((v_item->>'sell')::REAL, 0), 
          COALESCE(NULLIF((v_item->>'purchase_detail_id')::INTEGER, 0), 0),
          NULLIF(v_item->>'expirydate', ''),
          COALESCE(NULLIF(v_item->>'barcode1', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode2', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode3', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode4', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode5', ''), ''),
          COALESCE(NULLIF(v_item->>'barcode6', ''), ''),
          COALESCE(v_item->>'unit_name', 'piece'),
          COALESCE((v_item->>'unit_base_qty')::REAL, 1.0)
        ) RETURNING id INTO v_detail_id;

        RAISE NOTICE '✅ تم إضافة عنصر برقم: %, كمية: %, تفصيل: %', 
          (v_item->>'id')::INTEGER, v_actual_qty, v_detail_id;

        -- إنشاء دفعة جديدة إذا كانت الدالة موجودة
        IF v_process_rpc_exists THEN
          BEGIN
            PERFORM process_transaction_rpc(
              'purchase',
              COALESCE((v_item->>'id')::INTEGER, 0),  -- تصحيح هنا
              p_stockid,
              v_actual_qty,
              NULLIF(v_item->>'expirydate', ''),
              TRUE,
              v_detail_id
            );
            RAISE NOTICE '✅ تم استدعاء process_transaction_rpc بنجاح';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE NOTICE '❌ خطأ في process_transaction_rpc: %', SQLERRM;
          END;
        ELSE
          RAISE NOTICE '⚠️ دالة process_transaction_rpc غير موجودة';
        END IF;
      END LOOP;
    ELSE
      RAISE NOTICE '⚠️ لا توجد عناصر لإضافتها';
    END IF;

    v_result := jsonb_build_object(
      'success', true,
      'purchase_id', v_purchase_id,
      'message', 'تم إضافة فاتورة المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '❌ حدث خطأ: %', SQLERRM;
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'purchase_id', COALESCE(v_purchase_id, 0)
      );
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION get_total_available(
  p_item_id INTEGER,
  p_stock_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_total_available REAL;
BEGIN
  SELECT COALESCE(SUM(quantity), 0) 
  INTO v_total_available
  FROM batches
  WHERE item_id = p_item_id AND stock_id = p_stock_id;
  
  RETURN jsonb_build_object('total_available', v_total_available);
END;
$$;

CREATE OR REPLACE FUNCTION edit_purchase_rpc(
  p_id INTEGER,
  p_items JSONB DEFAULT NULL,
  p_payments JSONB DEFAULT NULL,
  p_id_supplier INTEGER DEFAULT NULL,
  p_id_stock INTEGER DEFAULT NULL,
  p_type_dic TEXT DEFAULT NULL,
  p_charge DOUBLE PRECISION DEFAULT NULL,
  p_taxid INTEGER DEFAULT NULL,
  p_value_dic DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_purchase_record RECORD;
  v_inv_code TEXT;
  v_date DATE;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty DOUBLE PRECISION;
  v_detail_id INTEGER;
BEGIN
  BEGIN
    -- جلب بيانات الفاتورة الحالية
    SELECT invoice_code, date INTO v_inv_code, v_date
    FROM purchases WHERE id = p_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'فاتورة المشتريات غير موجودة');
    END IF;

    -- حذف التفاصيل القديمة (مع إزالة الكمية من الدفعات)
    PERFORM delete_purchase_rpc(p_id, false);

    -- تحديث رأس الفاتورة
    UPDATE purchases SET
      type_dic = p_type_dic,
      value_dic = p_value_dic,
      charge_price = p_charge,
      taxid = p_taxid,
      id_supplier = p_id_supplier,
      id_stock = p_id_stock,
      updated_at = NOW()
    WHERE id = p_id;

    -- إعادة إدخال الدفعات المالية
    DELETE FROM payments WHERE code = v_inv_code;
    FOR v_pay IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        v_inv_code, v_date, 'pur',
        (v_pay->>'price')::DOUBLE PRECISION,
        (v_pay->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل الجديدة وإنشاء الدفعات
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      v_actual_qty := (v_item->>'qty')::DOUBLE PRECISION;
      IF (v_item->'unit_base_qty') IS NOT NULL AND (v_item->>'unit_base_qty') != '' THEN
        v_actual_qty := v_actual_qty * (v_item->>'unit_base_qty')::DOUBLE PRECISION;
      END IF;

      -- استخدام purchase_detail_id الموجود أو إنشاء جديد
      v_detail_id := COALESCE((v_item->>'purchase_detail_id')::INTEGER, 
        EXTRACT(EPOCH FROM NOW())::INTEGER + (random() * 1000000)::INTEGER);

      -- إدخال التفاصيل
      INSERT INTO purchase_details (
        id, id_item, id_invoice_code, qty, value_dic, type_dic,
        taxid, price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        v_detail_id,
        (v_item->>'id')::INTEGER, p_id, v_actual_qty,
        (v_item->>'dis_value')::DOUBLE PRECISION, v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER, (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION, (v_item->>'expirydate')::DATE,
        v_detail_id,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- إنشاء/تحديث الدفعة
      PERFORM add_batch_for_purchase_edit_rpc(
        (v_item->>'id')::INTEGER,
        p_id_stock,
        v_detail_id,
        v_item->>'expirydate',
        v_actual_qty
      );
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تعديل فاتورة المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;





CREATE OR REPLACE FUNCTION add_return_purchase_rpc(
  p_id INTEGER DEFAULT 0,
  p_userid INTEGER DEFAULT 0,
  p_supplierid INTEGER DEFAULT 1,
  p_purchase_id INTEGER DEFAULT NULL,
  p_date DATE DEFAULT NULL,
  p_time TEXT DEFAULT NULL,
  p_inv_code TEXT DEFAULT NULL,
  p_tax INTEGER DEFAULT NULL,
  p_charge DOUBLE PRECISION DEFAULT NULL,
  p_dis TEXT DEFAULT NULL,
  p_disvalue DOUBLE PRECISION DEFAULT NULL,
  p_stock_id INTEGER DEFAULT NULL,
  p_items JSONB DEFAULT '[]'::JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_account_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_id INTEGER;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty DOUBLE PRECISION;
BEGIN
  BEGIN
    -- إدخال فاتورة المرتجع
    INSERT INTO return_purchases (
      id, invoice_code, purchase_id, userid, account_id, id_supplier, 
      date, taxid, charge_price, type_dic, value_dic, id_stock, time
    ) VALUES (
      p_id, p_inv_code, p_purchase_id, p_userid, p_account_id, p_supplierid,
      p_date, p_tax, p_charge, p_dis, p_disvalue, p_stock_id, p_time
    ) RETURNING id INTO v_return_id;

    -- إدخال الدفعات المالية
    FOR v_pay IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        p_inv_code, p_date, 'rpur',
        (v_pay->>'price')::DOUBLE PRECISION,
        (v_pay->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل وتقليل الكمية من الدفعات
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      v_actual_qty := (v_item->>'qty')::DOUBLE PRECISION;
     
   
      -- إدخال التفاصيل
      INSERT INTO return_purchase_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
        price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, v_return_id, v_actual_qty,
        (v_item->>'dis_value')::DOUBLE PRECISION, v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER, (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION, (v_item->>'expirydate')::DATE,
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- تقليل الكمية من الدفعات الأصلية
      PERFORM process_transaction_rpc(
        'return_purchase',
        (v_item->>'id')::INTEGER,
        p_stock_id,
        v_actual_qty,
        NULL,
        FALSE,
        (v_item->>'purchase_detail_id')::INTEGER
      );
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'return_id', v_return_id,
      'message', 'تم إضافة مرتجع المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION edit_return_purchase_rpc(
  p_id INTEGER,
  p_items JSONB,
  p_payments JSONB,
  p_id_supplier INTEGER,
  p_type_dic TEXT,
  p_value_dic DOUBLE PRECISION,
  p_taxid INTEGER,
  p_charge DOUBLE PRECISION,
  p_id_stock INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_record RECORD;
  v_inv_code TEXT;
  v_date DATE;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty DOUBLE PRECISION;
BEGIN
  BEGIN
    -- جلب بيانات المرتجع الحالي
    SELECT invoice_code, date, purchase_id 
    INTO v_return_record
    FROM return_purchases WHERE id = p_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'مرتجع المشتريات غير موجود');
    END IF;

    -- حذف التفاصيل القديمة (مع إرجاع الكمية إلى الدفعات)
    PERFORM delete_return_purchase_rpc(p_id);

    -- تحديث رأس المرتجع
    UPDATE return_purchases SET
      id_supplier = p_id_supplier,
      charge_price = p_charge,
      id_stock = p_id_stock,
      type_dic = p_type_dic,
      value_dic = p_value_dic,
      taxid = p_taxid,
      updated_at = NOW()
    WHERE id = p_id
    RETURNING invoice_code, date INTO v_inv_code, v_date;

    -- إعادة إدخال الدفعات المالية
    FOR v_pay IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        v_inv_code, v_date, 'rpur',
        (v_pay->>'price')::DOUBLE PRECISION,
        (v_pay->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل الجديدة وتقليل الكمية من الدفعات
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      v_actual_qty := (v_item->>'qty')::DOUBLE PRECISION;
      IF (v_item->'unit_base_qty') IS NOT NULL AND (v_item->>'unit_base_qty') != '' THEN
        v_actual_qty := v_actual_qty * (v_item->>'unit_base_qty')::DOUBLE PRECISION;
      END IF;

      IF v_actual_qty <= 0 THEN
        CONTINUE;
      END IF;

      -- إدخال التفاصيل
      INSERT INTO return_purchase_detals (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid,
        price, sell, expirydate, purchase_detail_id,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, p_id, v_actual_qty,
        (v_item->>'dis_value')::DOUBLE PRECISION, v_item->>'dis_type',
        (v_item->>'taxid')::INTEGER, (v_item->>'price')::DOUBLE PRECISION,
        (v_item->>'sell')::DOUBLE PRECISION, (v_item->>'expirydate')::DATE,
        (v_item->>'purchase_detail_id')::INTEGER,
        COALESCE(v_item->>'barcode1', 'TEXT'),
        COALESCE(v_item->>'barcode2', 'TEXT'),
        COALESCE(v_item->>'barcode3', 'TEXT'),
        COALESCE(v_item->>'barcode4', 'TEXT'),
        COALESCE(v_item->>'barcode5', 'TEXT'),
        COALESCE(v_item->>'barcode6', 'TEXT'),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::DOUBLE PRECISION
      );

      -- تقليل الكمية من الدفعات
      PERFORM process_transaction_rpc(
        'return_purchase',
        (v_item->>'id')::INTEGER,
        p_id_stock,
        v_actual_qty,
        NULL,
        FALSE,
        (v_item->>'purchase_detail_id')::INTEGER
      );
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم تعديل مرتجع المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;
CREATE OR REPLACE FUNCTION add_chang_stock_rpc(
    p_userid INTEGER,
    p_date DATE,
    p_note TEXT,
    p_id_stock INTEGER,
    p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_id INTEGER;
    v_inv_code TEXT;
    v_adjustment_id INTEGER;
    v_item JSONB;
    v_result JSONB;
BEGIN
    -- إنشاء الفاتورة
    INSERT INTO change_stock (invoice_code, userid, date)
    VALUES ('invCode', p_userid, p_date)
    RETURNING id INTO v_last_id;

    -- تحديث رقم الفاتورة
    v_inv_code := 'InvCH-' || v_last_id;
    UPDATE change_stock
    SET invoice_code = v_inv_code
    WHERE id = v_last_id;

    -- إدخال البيانات الكاملة
    INSERT INTO change_stock (id, note, invoice_code, userid, date, id_stock)
    VALUES (v_last_id, p_note, v_inv_code, p_userid, p_date, p_id_stock)
    ON CONFLICT (id) DO UPDATE SET
        note = EXCLUDED.note,
        invoice_code = EXCLUDED.invoice_code,
        userid = EXCLUDED.userid,
        date = EXCLUDED.date,
        id_stock = EXCLUDED.id_stock;

    -- الحصول على معرف الفاتورة
    SELECT id INTO v_adjustment_id
    FROM change_stock
    WHERE invoice_code = v_inv_code AND userid = p_userid AND date = p_date;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'فشل إنشاء فاتورة التسوية';
    END IF;

    -- إدخال التفاصيل وتنفيذ التسوية
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO change_stock_details (
            id_item,
            id_invoice_code,
            qty,
            purchase_detail_id,
            expirydate,
            unit_name,
            unit_base_qty
        ) VALUES (
            (v_item->>'id')::INTEGER,
            v_adjustment_id,
            (v_item->>'qty')::DOUBLE PRECISION,
            (v_item->>'purchase_detail_id')::INTEGER,
            v_item->>'expirydate',
            v_item->>'unit_name',
            (v_item->>'unit_base_qty')::DOUBLE PRECISION
        );

        -- تطبيق التسوية
        IF (v_item->>'qty')::DOUBLE PRECISION > 0 THEN
            PERFORM process_transaction_rpc(
                'adjustment_increase',
                (v_item->>'id')::INTEGER,
                p_id_stock,
                (v_item->>'qty')::DOUBLE PRECISION,
                v_item->>'expirydate',
                TRUE,
                (v_item->>'purchase_detail_id')::INTEGER
            );
        ELSIF (v_item->>'qty')::DOUBLE PRECISION < 0 THEN
            PERFORM process_transaction_rpc(
                'adjustment_decrease',
                (v_item->>'id')::INTEGER,
                p_id_stock,
                ABS((v_item->>'qty')::DOUBLE PRECISION),
                NULL,
                TRUE,
                (v_item->>'purchase_detail_id')::INTEGER
            );
        END IF;
    END LOOP;

    v_result := jsonb_build_object(
        'success', true,
        'adjustment_id', v_adjustment_id,
        'message', 'تم إضافة فاتورة التسوية بنجاح'
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;



CREATE OR REPLACE FUNCTION edit_chang_stock_rpc(
    p_id INTEGER,
    p_note TEXT,
    p_id_stock INTEGER,
    p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_adjustment_id INTEGER;
    v_item JSONB;
    v_result JSONB;
BEGIN
    -- التحقق من وجود الفاتورة
    SELECT id INTO v_adjustment_id
    FROM change_stock
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'فاتورة التسوية غير موجودة');
    END IF;

    -- عكس التسوية القديمة
    PERFORM delete_inv_chang_stock_rpc(p_id);

    -- تحديث رأس الفاتورة
    UPDATE change_stock
    SET note = p_note,
        id_stock = p_id_stock,
        updated_at = NOW()
    WHERE id = p_id;

    -- إدخال التفاصيل الجديدة
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO change_stock_details (
            id_item,
            id_invoice_code,
            qty,
            purchase_detail_id,
            expirydate,
            unit_name,
            unit_base_qty
        ) VALUES (
            (v_item->>'id')::INTEGER,
            p_id,
            (v_item->>'qty')::DOUBLE PRECISION,
            (v_item->>'purchase_detail_id')::INTEGER,
            v_item->>'expirydate',
            v_item->>'unit_name',
            (v_item->>'unit_base_qty')::DOUBLE PRECISION
        );

        -- تطبيق التسوية الجديدة
        IF (v_item->>'qty')::DOUBLE PRECISION > 0 THEN
            PERFORM process_transaction_rpc(
                'adjustment_increase',
                (v_item->>'id')::INTEGER,
                p_id_stock,
                (v_item->>'qty')::DOUBLE PRECISION,
                v_item->>'expirydate',
                TRUE,
                (v_item->>'purchase_detail_id')::INTEGER
            );
        ELSIF (v_item->>'qty')::DOUBLE PRECISION < 0 THEN
            PERFORM process_transaction_rpc(
                'adjustment_decrease',
                (v_item->>'id')::INTEGER,
                p_id_stock,
                ABS((v_item->>'qty')::DOUBLE PRECISION),
                NULL,
                TRUE,
                (v_item->>'purchase_detail_id')::INTEGER
            );
        END IF;
    END LOOP;

    v_result := jsonb_build_object('success', true, 'message', 'تم تعديل فاتورة التسوية بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;





CREATE OR REPLACE FUNCTION delete_chang_stock_rpc(p_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- حذف الفاتورة (سيؤدي إلى حذف التفاصيل تلقائيًا إذا كان هناك CASCADE)
    PERFORM delete_inv_chang_stock_rpc(p_id);

    -- حذف رأس الفاتورة
    DELETE FROM change_stock WHERE id = p_id;

    v_result := jsonb_build_object('success', true, 'message', 'تم حذف فاتورة التسوية كاملة بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;





CREATE OR REPLACE FUNCTION delete_inv_chang_stock_rpc(p_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_adjustment_id INTEGER;
    v_id_stock INTEGER;
    v_detail_record RECORD;
    v_result JSONB;
BEGIN
    -- جلب بيانات الفاتورة
    SELECT id, id_stock INTO v_adjustment_id, v_id_stock
    FROM change_stock
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'فاتورة التسوية غير موجودة');
    END IF;

    -- معالجة التفاصيل وعكس التسوية
    FOR v_detail_record IN
        SELECT 
            id_item,
            qty,
            expirydate,
            purchase_detail_id
        FROM change_stock_details
        WHERE id_invoice_code = v_adjustment_id
    LOOP
        IF v_detail_record.qty = 0 THEN
            CONTINUE;
        END IF;

        IF v_detail_record.qty > 0 THEN
            -- عكس التسوية: نقصان
            PERFORM process_transaction_rpc(
                'adjustment_decrease',
                v_detail_record.id_item,
                v_id_stock,
                v_detail_record.qty,
                NULL, -- expiry_date
                TRUE, -- check_qty
                v_detail_record.purchase_detail_id
            );
        ELSIF v_detail_record.qty < 0 THEN
            -- عكس التسوية: زيادة
            PERFORM process_transaction_rpc(
                'adjustment_increase',
                v_detail_record.id_item,
                v_id_stock,
                ABS(v_detail_record.qty),
                v_detail_record.expirydate,
                TRUE, -- check_qty
                v_detail_record.purchase_detail_id
            );
        END IF;
    END LOOP;

    -- حذف التفاصيل
    DELETE FROM change_stock_details
    WHERE id_invoice_code = v_adjustment_id;

    v_result := jsonb_build_object('success', true, 'message', 'تم حذف فاتورة التسوية بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;



CREATE OR REPLACE FUNCTION add_trans_between_stock_rpc(
    p_userid INTEGER,
    p_date DATE,
    p_note TEXT,
    p_to_stock INTEGER,
    p_from_stock INTEGER,
    p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_id INTEGER;
    v_inv_code TEXT;
    v_transfer_id INTEGER;
    v_item JSONB;
    v_result JSONB;
BEGIN
    -- إنشاء الفاتورة
    INSERT INTO transf_stock (invoice_code, userid, date)
    VALUES ('invCode', p_userid, p_date)
    RETURNING id INTO v_last_id;

    -- تحديث رقم الفاتورة
    v_inv_code := 'InvTR-' || v_last_id;
    UPDATE transf_stock
    SET invoice_code = v_inv_code
    WHERE id = v_last_id;

    -- إدخال البيانات الكاملة
    INSERT INTO transf_stock (id, note, invoice_code, userid, date, id_to_stock, id_from_stock)
    VALUES (v_last_id, p_note, v_inv_code, p_userid, p_date, p_to_stock, p_from_stock)
    ON CONFLICT (id) DO UPDATE SET
        note = EXCLUDED.note,
        invoice_code = EXCLUDED.invoice_code,
        userid = EXCLUDED.userid,
        date = EXCLUDED.date,
        id_to_stock = EXCLUDED.id_to_stock,
        id_from_stock = EXCLUDED.id_from_stock;

    -- الحصول على معرف الفاتورة
    SELECT id INTO v_transfer_id
    FROM transf_stock
    WHERE invoice_code = v_inv_code AND userid = p_userid AND date = p_date;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'فشل إنشاء فاتورة التحويل';
    END IF;

    -- إدخال التفاصيل وتنفيذ التحويل
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO transf_stock_details (
            id_item,
            id_invoice_code,
            qty,
            purchase_detail_id,
            unit_name,
            unit_base_qty
        ) VALUES (
            (v_item->>'id')::INTEGER,
            v_transfer_id,
            (v_item->>'qty')::DOUBLE PRECISION,
            (v_item->>'purchase_detail_id')::INTEGER,
            v_item->>'unit_name',
            (v_item->>'unit_base_qty')::DOUBLE PRECISION
        );

        -- تطبيق التحويل
        PERFORM process_transaction_rpc(
            'transfer_out',
            (v_item->>'id')::INTEGER,
            p_from_stock,
            (v_item->>'qty')::DOUBLE PRECISION,
            NULL,
            TRUE,
            (v_item->>'purchase_detail_id')::INTEGER
        );

        PERFORM process_transaction_rpc(
            'transfer_in',
            (v_item->>'id')::INTEGER,
            p_to_stock,
            (v_item->>'qty')::DOUBLE PRECISION,
            v_item->>'expirydate',
            TRUE,
            (v_item->>'purchase_detail_id')::INTEGER
        );
    END LOOP;

    v_result := jsonb_build_object(
        'success', true,
        'transfer_id', v_transfer_id,
        'message', 'تم إضافة فاتورة التحويل بنجاح'
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;




CREATE OR REPLACE FUNCTION delete_trans_between_stock_rpc(p_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- حذف الفاتورة (سيؤدي إلى حذف التفاصيل تلقائيًا إذا كان هناك CASCADE)
    PERFORM delete_inv_trans_between_stock_rpc(p_id);

    -- حذف رأس الفاتورة
    DELETE FROM transf_stock WHERE id = p_id;

    v_result := jsonb_build_object('success', true, 'message', 'تم حذف فاتورة التحويل كاملة بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;





CREATE OR REPLACE FUNCTION delete_inv_trans_between_stock_rpc(p_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_transfer_id INTEGER;
    v_from_stock INTEGER;
    v_to_stock INTEGER;
    v_detail_record RECORD;
    v_result JSONB;
BEGIN
    -- جلب بيانات الفاتورة
    SELECT id, id_from_stock, id_to_stock
    INTO v_transfer_id, v_from_stock, v_to_stock
    FROM transf_stock
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'فاتورة التحويل غير موجودة');
    END IF;

    -- معالجة التفاصيل وعكس التحويل
    FOR v_detail_record IN
        SELECT 
            id_item,
            qty,
            purchase_detail_id,
            expirydate
        FROM transf_stock_details
        WHERE id_invoice_code = v_transfer_id
    LOOP
        IF v_detail_record.qty <= 0 THEN
            CONTINUE;
        END IF;

        -- عكس التحويل: من الوجهة إلى المصدر
        PERFORM process_transaction_rpc(
            'transfer_out',
            v_detail_record.id_item,
            v_to_stock, -- نخرج من الوجهة
            v_detail_record.qty,
            NULL,
            TRUE,
            v_detail_record.purchase_detail_id
        );

        PERFORM process_transaction_rpc(
            'transfer_in',
            v_detail_record.id_item,
            v_from_stock, -- ندخل إلى المصدر
            v_detail_record.qty,
            v_detail_record.expirydate,
            TRUE,
            v_detail_record.purchase_detail_id
        );
    END LOOP;

    -- حذف التفاصيل
    DELETE FROM transf_stock_details
    WHERE id_invoice_code = v_transfer_id;

    v_result := jsonb_build_object('success', true, 'message', 'تم حذف فاتورة التحويل بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;







CREATE OR REPLACE FUNCTION edit_trans_between_stock_rpc(
    p_id INTEGER,
    p_note TEXT,
    p_to_stock INTEGER,
    p_from_stock INTEGER,
    p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_transfer_id INTEGER;
    v_old_from_stock INTEGER;
    v_old_to_stock INTEGER;
    v_item JSONB;
    v_result JSONB;
BEGIN
    -- التحقق من وجود الفاتورة
    SELECT id, id_from_stock, id_to_stock
    INTO v_transfer_id, v_old_from_stock, v_old_to_stock
    FROM transf_stock
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'فاتورة التحويل غير موجودة');
    END IF;

    -- عكس التحويل القديم
    PERFORM delete_inv_trans_between_stock_rpc(p_id);

    -- تحديث رأس الفاتورة
    UPDATE transf_stock
    SET note = p_note,
        id_to_stock = p_to_stock,
        id_from_stock = p_from_stock,
        updated_at = NOW()
    WHERE id = p_id;

    -- إدخال التفاصيل الجديدة
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO transf_stock_details (
            id_item,
            id_invoice_code,
            qty,
            purchase_detail_id,
            unit_name,
            unit_base_qty
        ) VALUES (
            (v_item->>'id')::INTEGER,
            p_id,
            (v_item->>'qty')::DOUBLE PRECISION,
            (v_item->>'purchase_detail_id')::INTEGER,
            v_item->>'unit_name',
            (v_item->>'unit_base_qty')::DOUBLE PRECISION
        );

        -- تطبيق التحويل الجديد
        PERFORM process_transaction_rpc(
            'transfer_out',
            (v_item->>'id')::INTEGER,
            p_from_stock,
            (v_item->>'qty')::DOUBLE PRECISION,
            NULL,
            TRUE,
            (v_item->>'purchase_detail_id')::INTEGER
        );

        PERFORM process_transaction_rpc(
            'transfer_in',
            (v_item->>'id')::INTEGER,
            p_to_stock,
            (v_item->>'qty')::DOUBLE PRECISION,
            v_item->>'expirydate',
            TRUE,
            (v_item->>'purchase_detail_id')::INTEGER
        );
    END LOOP;

    v_result := jsonb_build_object('success', true, 'message', 'تم تعديل فاتورة التحويل بنجاح');

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;





























CREATE OR REPLACE FUNCTION delete_inv_return_purchase_rpc(p_return_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
BEGIN
  BEGIN
    -- حذف المرتجع مع إعادة الكميات
    PERFORM delete_return_purchase_rpc(p_return_id);
    
    -- حذف رأس المرتجع
    DELETE FROM return_purchases WHERE id = p_return_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف مرتجع المشتريات كامل بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION delete_return_purchase_rpc(p_return_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_return_record RECORD;
  v_detail_record RECORD;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب بيانات المرتجع
    SELECT id, id_stock, invoice_code
    INTO v_return_record
    FROM return_purchases 
    WHERE id = p_return_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'المرتجع غير موجود');
    END IF;

    -- إعادة الكمية التي تم إرجاعها
    FOR v_detail_record IN 
      SELECT 
        rpd.id_item,
        rpd.qty,
        rpd.purchase_detail_id
      FROM return_purchase_detals rpd
      WHERE rpd.id_invoice_code = p_return_id
      AND rpd.qty > 0
    LOOP
      PERFORM process_transaction_rpc(
        'purchase',
        v_detail_record.id_item,
        v_return_record.id_stock,
        v_detail_record.qty,
        NULL,
        FALSE,
        v_detail_record.purchase_detail_id
      );
    END LOOP;

    -- حذف البيانات
    DELETE FROM payments WHERE code = v_return_record.invoice_code;
    DELETE FROM return_purchase_detals WHERE id_invoice_code = p_return_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف مرتجع المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION delete_purchase_rpc(p_purchase_id INTEGER, p_check_qty BOOLEAN DEFAULT TRUE)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_purchase_record RECORD;
  v_detail_record RECORD;
  v_result JSONB;
BEGIN
  BEGIN
    -- جلب بيانات الفاتورة
    SELECT id, id_stock, invoice_code
    INTO v_purchase_record
    FROM purchases 
    WHERE id = p_purchase_id;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'الفاتورة غير موجودة');
    END IF;

    -- إزالة الكمية من الدفعات
    FOR v_detail_record IN 
      SELECT 
        pd.id_item,
        pd.qty,
        pd.id as purchase_detail_id
      FROM purchase_details pd
      WHERE pd.id_invoice_code = p_purchase_id
      AND pd.qty > 0
    LOOP
      PERFORM process_transaction_rpc(
        'return_purchase',
        v_detail_record.id_item,
        v_purchase_record.id_stock,
        v_detail_record.qty,
        NULL,
        p_check_qty,
        v_detail_record.purchase_detail_id
      );
    END LOOP;

    -- حذف البيانات
    DELETE FROM payments WHERE code = v_purchase_record.invoice_code;
    DELETE FROM purchase_details WHERE id_invoice_code = p_purchase_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف فاتورة المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION delete_inv_purchase_rpc(p_purchase_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
BEGIN
  BEGIN
    -- حذف الفاتورة مع إزالة الكميات
    PERFORM delete_purchase_rpc(p_purchase_id, false);
    
    -- حذف رأس الفاتورة
    DELETE FROM purchases WHERE id = p_purchase_id;

    v_result := jsonb_build_object(
      'success', true,
      'message', 'تم حذف فاتورة المشتريات كاملة بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;



DROP FUNCTION IF EXISTS add_purchase_rpc(
  INTEGER, INTEGER, INTEGER, DATE, DOUBLE PRECISION, TEXT, 
  TEXT, TEXT, DOUBLE PRECISION, INTEGER, INTEGER, 
  JSONB, JSONB, INTEGER
);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, integer, date, double precision, text, text, text, double precision, integer, integer, jsonb, jsonb, text);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, integer, date, double precision, text, text, integer, double precision, integer, integer, jsonb, jsonb, integer);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, text, integer, date, double precision, text, integer, double precision, integer, integer, jsonb, jsonb, integer);
-- حذف جميع الدوال القديمة بنفس الاسم
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, integer, date, double precision, text, text, text, double precision, integer, integer, jsonb, jsonb, text);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, integer, date, double precision, text, text, integer, double precision, integer, integer, jsonb, jsonb, integer);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, text, integer, date, double precision, text, integer, double precision, integer, integer, jsonb, jsonb, integer);
DROP FUNCTION IF EXISTS add_purchase_rpc(integer, integer, text, integer, date, real, text, integer, real, integer, integer, jsonb, jsonb, integer);



CREATE OR REPLACE FUNCTION add_purchase_rpc(
  p_id INTEGER DEFAULT 0,
  p_userid INTEGER DEFAULT 0,
  p_supplierid INTEGER DEFAULT NULL,
  p_date TEXT DEFAULT NULL,
  p_charge REAL DEFAULT 0,
  p_time TEXT DEFAULT '00:00:00',
  p_inv_code TEXT DEFAULT 'TEMP-INV',
  p_type_dic INTEGER DEFAULT 0,
  p_value_dic REAL DEFAULT 0,
  p_taxid INTEGER DEFAULT NULL,
  p_stockid INTEGER DEFAULT 0,
  p_items JSONB DEFAULT '[]'::JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_account_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_purchase_id INTEGER;
  v_detail_id INTEGER;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty REAL;
  v_current_date TEXT := to_char(CURRENT_DATE, 'YYYY-MM-DD');
BEGIN
  BEGIN
    -- إدخال الفاتورة
    INSERT INTO purchases (
      id, invoice_code, userid, id_supplier, account_id, taxid, 
      charge_price, type_dic, value_dic, id_stock, date, time
    ) VALUES (
      p_id, 
      p_inv_code, 
      p_userid, 
      p_supplierid, 
      p_account_id, 
      p_taxid,
      p_charge, 
      p_type_dic, 
      p_value_dic, 
      p_stockid, 
      COALESCE(p_date, v_current_date),
      p_time
    ) RETURNING id INTO v_purchase_id;

    -- إدخال الدفعات المالية
    FOR v_pay IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        p_inv_code, 
        COALESCE(p_date, v_current_date), 
        'pur',
        (v_pay->>'price')::REAL,
        (v_pay->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل وإنشاء الدفعات
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
      -- حساب الكمية الفعلية
      v_actual_qty := (v_item->>'qty')::REAL;
      IF (v_item->'unit_base_qty') IS NOT NULL AND (v_item->>'unit_base_qty') != '' THEN
        v_actual_qty := v_actual_qty * (v_item->>'unit_base_qty')::REAL;
      END IF;

      -- إدخال التفاصيل (بدون تحويل - استخدام القيم مباشرة)
      INSERT INTO purchase_details (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid, 
        price, sell, purchase_detail_id, expirydate,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, 
        v_purchase_id, 
        v_actual_qty,
        (v_item->>'dis_value')::REAL, 
        (v_item->>'dis_type')::INTEGER,  -- استخدام مباشر بدون تحويل
        (v_item->>'taxid')::INTEGER, 
        (v_item->>'price')::REAL,
        (v_item->>'sell')::REAL, 
        (v_item->>'purchase_detail_id')::INTEGER,
        (v_item->>'expirydate'),
        COALESCE(v_item->>'barcode1', ''),
        COALESCE(v_item->>'barcode2', ''),
        COALESCE(v_item->>'barcode3', ''),
        COALESCE(v_item->>'barcode4', ''),
        COALESCE(v_item->>'barcode5', ''),
        COALESCE(v_item->>'barcode6', ''),
        v_item->>'unit_name',
        (v_item->>'unit_base_qty')::REAL
      ) RETURNING id INTO v_detail_id;

      -- إنشاء دفعة جديدة
      PERFORM process_transaction_rpc(
        'purchase',
        (v_item->>'id')::INTEGER,
        p_stockid,
        v_actual_qty,
        v_item->>'expirydate',
        TRUE,
        v_detail_id
      );
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'purchase_id', v_purchase_id,
      'message', 'تم إضافة فاتورة المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION get_inv_ketchine(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      k.*,
      t.id AS table_id,
      t.name AS tablename,
      c.id AS id_customer,
      c.name AS customer_name,
      inv.id AS invname,
      inv.name AS inventory_name,
      d.id AS id_delivery,
      d.name AS delivery_name,
      u.username AS username
    FROM ketchine k
    LEFT JOIN my_table t ON k.id_table = t.id
    LEFT JOIN customers c ON k.id_customer = c.id
    LEFT JOIN inventory inv ON k.id_stock = inv.id
    LEFT JOIN delivery d ON k.id_delivery = d.id
    LEFT JOIN users u ON k.userid = u.id
    WHERE k.invoice_code ILIKE '%' || search_query || '%'
    ORDER BY k.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;



CREATE OR REPLACE FUNCTION get_inv_ketchine_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      pt.id AS paytype,
      pt.name AS payment_type_name,
      k.invoice_code AS ketchine_code,
      k.status AS ketchine_status
    FROM payments p
    JOIN pay_types pt ON p.paytype_id = pt.id
    JOIN ketchine k ON p.code = k.invoice_code
    WHERE p.code ILIKE '%' || search_query || '%'
    ORDER BY p.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_ketchine_details(
  invoice_code_param TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      kd.*,
      i.name AS name,
      i.id AS id,
      i.is_item AS is_item,
      ty.name AS tyname,
      -- معلومات إضافية
      COALESCE(kd.qty, 0) AS itemqty,
      COALESCE(kd.price, 0) AS original_price,
      COALESCE(kd.sell, 0) AS selling_price,
      COALESCE(kd.value_dic, 0) AS discount_value,
      COALESCE(kd.type_dic, 0) AS discount_type,
      -- حساب السعر بعد الخصم
      CASE 
        WHEN kd.type_dic = 0 THEN kd.sell - (kd.sell * kd.value_dic / 100)
        WHEN kd.type_dic = 1 THEN kd.sell - kd.value_dic
        ELSE kd.sell
      END AS price_after_discount,
      -- حساب الإجمالي للصنف
      kd.qty * 
      CASE 
        WHEN kd.type_dic = 0 THEN kd.sell - (kd.sell * kd.value_dic / 100)
        WHEN kd.type_dic = 1 THEN kd.sell - kd.value_dic
        ELSE kd.sell
      END AS item_total
    FROM ketchine_detals kd
    JOIN items i ON kd.id_item = i.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE kd.id_invoice_code = invoice_code_param::INTEGER
    ORDER BY kd.id ASC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION calculate_between_rpurchases(
  date_from DATE,
  date_to DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  summary JSON;
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_value_charge', COALESCE(SUM(total_value_charge), 0),
    'paid', COALESCE(SUM(paid), 0),
    'total_discount', COALESCE(SUM(total_discount), 0),
    'itemdis', COALESCE(SUM(itemdis), 0),
    'total_tax', COALESCE(SUM(total_tax), 0),
    'itemtax', COALESCE(SUM(itemtax), 0),
    'purchase_count', COUNT(*),
    'details', (
      SELECT json_agg(row_to_json(t))
      FROM (
        SELECT 
          p.id,
          p.invoice_code,
          p.date,
          p.charge_price,
          s.name AS stockname,
          -- الحسابات الأساسية
          COALESCE(SUM(pd.qty * pd.price), 0.0) + p.charge_price AS total_value_charge1,
          COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
          
          -- خصم الأصناف
          COALESCE(SUM(
            pd.qty * 
            CASE 
              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0.0
            END
          ), 0.0) AS itemdis1,
          
          COALESCE(SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
            )
          ), 0.0) AS itemdis,

          -- ضريبة الأصناف
          COALESCE(SUM(
            pd.qty * 
            CASE 
              WHEN ti.type = 0 THEN (
                (pd.price - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0.0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0.0
            END
          ), 0.0) AS itemtax,

          -- إجمالي مع الضريبة
          COALESCE(SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.price - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ), 0.0) AS total_value_charge,

          -- خصم الفاتورة
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.price 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.price - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END AS total_discount,

          -- ضريبة الفاتورة
          CASE 
            WHEN t.type = 0 THEN (
              (
                SUM(
                  pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                          (pd.price - 
                            CASE 
                              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                              WHEN pd.type_dic = 1 THEN pd.value_dic
                              ELSE 0
                            END
                          ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                      END
                  )
                ) 
                - CASE 
                    WHEN p.type_dic = 0 THEN (
                      SUM(
                        pd.qty * (
                          pd.price 
                          - CASE 
                              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                              WHEN pd.type_dic = 1 THEN pd.value_dic
                              ELSE 0
                            END
                          + CASE 
                              WHEN ti.type = 0 THEN (
                                (pd.price - 
                                  CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                  END
                                ) * ti.value / 100
                              )
                              WHEN ti.type = 1 THEN ti.value
                              ELSE 0
                            END
                        )
                      ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                  END
              ) * t.value / 100
            )
            WHEN t.type = 1 THEN t.value
            ELSE 0
          END AS total_tax
        FROM return_purchases p
        JOIN return_purchase_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        WHERE DATE(p.date) BETWEEN date_from AND date_to
        GROUP BY p.id, s.id, t.id
      ) t
    )
  ) INTO summary
  FROM (
    SELECT 
      SUM(
        pd.qty * (
          pd.price 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.price - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ) AS total_value_charge,
      
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      
      CASE 
        WHEN p.type_dic = 0 THEN (
          SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.price - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) * p.value_dic / 100
        )
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS total_discount,
      
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
          WHEN pd.type_dic = 1 THEN pd.value_dic
          ELSE 0.0
        END
      ), 0.0) AS itemdis,
      
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN ti.type = 0 THEN (
            (pd.price - 
              CASE 
                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0.0
              END
            ) * ti.value / 100
          )
          WHEN ti.type = 1 THEN ti.value
          ELSE 0.0
        END
      ), 0.0) AS itemtax,
      
      CASE 
        WHEN t.type = 0 THEN (
          (
            SUM(
              pd.qty * (
                pd.price 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.price - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) 
            - CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.price 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.price - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
          ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS total_tax
    FROM return_purchases p
    JOIN return_purchase_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE DATE(p.date) BETWEEN date_from AND date_to
    GROUP BY p.id, t.id
  ) subquery;

  RETURN summary;
END;
$$;
CREATE OR REPLACE FUNCTION calculate_between_purchases(
  date_from DATE,
  date_to DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_value_charge', COALESCE(SUM(total_value_charge), 0),
    'paid', COALESCE(SUM(paid), 0),
    'total_discount', COALESCE(SUM(total_discount), 0),
    'itemdis', COALESCE(SUM(itemdis), 0),
    'total_tax', COALESCE(SUM(total_tax), 0),
    'itemtax', COALESCE(SUM(itemtax), 0),
    'purchase_count', COUNT(*),
    'average_purchase', COALESCE(AVG(total_value_charge), 0),
    'max_purchase', COALESCE(MAX(total_value_charge), 0),
    'min_purchase', COALESCE(MIN(total_value_charge), 0)
  ) INTO result
  FROM (
    SELECT 
      -- إجمالي مع الضريبة
      COALESCE(SUM(
        pd.qty * (
          pd.price 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.price - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) + p.charge_price AS total_value_charge,
      
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      
      -- خصم الأصناف
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
          WHEN pd.type_dic = 1 THEN pd.value_dic
          ELSE 0.0
        END
      ), 0.0) AS itemdis,
      
      -- ضريبة الأصناف
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN ti.type = 0 THEN (
            (pd.price - 
              CASE 
                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0.0
              END
            ) * ti.value / 100
          )
          WHEN ti.type = 1 THEN ti.value
          ELSE 0.0
        END
      ), 0.0) AS itemtax,
      
      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (
          SUM(
            pd.qty * (
              pd.price 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.price - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) * p.value_dic / 100
        )
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS total_discount,
      
      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (
            SUM(
              pd.qty * (
                pd.price 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.price - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) 
            - CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.price 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.price - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
          ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS total_tax
    FROM purchases p
    JOIN purchase_details pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE DATE(p.date) BETWEEN date_from AND date_to
    GROUP BY p.id, t.id
  ) subquery;

  RETURN COALESCE(result, '{}'::json);
END;
$$;

--CREATE OR REPLACE FUNCTION get_yearly_sales(start_year TEXT, end_year TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    WITH yearly_data AS (
        SELECT 
            SUBSTRING(p.date FROM 1 FOR 4)::INTEGER AS year,
            SUM(pd.qty * pd.sell) AS total_sales,
            SUM(
                CASE 
                    WHEN pd.type_dic = 0 THEN (pd.qty * pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN (pd.qty * pd.value_dic)
                    ELSE 0
                END
            ) AS total_discount,
            SUM(
                CASE 
                    WHEN t.type = 0 THEN (pd.qty * pd.sell * t.value / 100)
                    WHEN t.type = 1 THEN (pd.qty * t.value)
                    ELSE 0
                END
            ) AS total_tax
        FROM sales p
        JOIN sales_detals pd ON p.id = pd.id_invoice_code
        LEFT JOIN taxs t ON pd.taxid = t.id
        WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER BETWEEN start_year::INTEGER AND end_year::INTEGER
        AND (p.status = 'delivered' OR p.status IS NULL)
        GROUP BY SUBSTRING(p.date FROM 1 FOR 4)
    )
    SELECT json_agg(
        json_build_object(
            'year', yd.year,
            'total_sales', yd.total_sales,
            'total_discount', yd.total_discount,
            'total_tax', yd.total_tax,
            'net_sales', yd.total_sales - yd.total_discount + yd.total_tax
        )
    ) INTO result
    FROM yearly_data yd
GROUP BY yd.year
    ORDER BY yd.year
;

    RETURN COALESCE(result, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION calculate_between_rsales(
  date_from DATE,
  date_to DATE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_value', COALESCE(SUM(total_value), 0),
    'paid', COALESCE(SUM(paid), 0),
    'total_discount', COALESCE(SUM(total_discount), 0),
    'itemdis', COALESCE(SUM(itemdis), 0),
    'total_tax', COALESCE(SUM(total_tax), 0),
    'itemtax', COALESCE(SUM(itemtax), 0),
    'return_count', COUNT(*),
    'average_return', COALESCE(AVG(total_value), 0),
    'details', (
      SELECT json_agg(row_to_json(t))
      FROM (
        SELECT 
          p.id,
          p.invoice_code,
          p.date,
          s.name AS stockname,
          COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total_value1,
          COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
          -- إجمالي مع الخصم والضريبة
          COALESCE(SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ), 0.0) AS total_value
        FROM return_sales p
        JOIN return_sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN inventory s ON p.id_stock = s.id
        LEFT JOIN taxs t ON p.taxid = t.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        WHERE DATE(p.date) BETWEEN date_from AND date_to
        GROUP BY p.id, s.id
      ) t
    )
  ) INTO result
  FROM (
    SELECT 
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total_value,
      
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
          WHEN pd.type_dic = 1 THEN pd.value_dic
          ELSE 0.0
        END
      ), 0.0) AS itemdis,
      
      COALESCE(SUM(
        pd.qty * 
        CASE 
          WHEN ti.type = 0 THEN (
            (pd.sell - 
              CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0.0
              END
            ) * ti.value / 100
          )
          WHEN ti.type = 1 THEN ti.value
          ELSE 0.0
        END
      ), 0.0) AS itemtax,
      
      CASE 
        WHEN p.type_dic = 0 THEN (
          SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) * p.value_dic / 100
        )
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS total_discount,
      
      CASE 
        WHEN t.type = 0 THEN (
          (
            SUM(
              pd.qty * (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.sell - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) 
            - CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.sell 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.sell - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
          ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS total_tax
    FROM return_sales p
    JOIN return_sales_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    WHERE DATE(p.date) BETWEEN date_from AND date_to
    GROUP BY p.id, t.id
  ) subquery;

  RETURN COALESCE(result, '{}'::json);
END;
$$;
 
DROP FUNCTION get_monthly_sales(INTEGER);
DROP FUNCTION get_monthly_purchases(INTEGER);
CREATE OR REPLACE FUNCTION get_monthly_purchases(year_param INTEGER)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH PurchaseCalculations AS (
        SELECT 
            p.id,
            p.date,
            p.charge_price,
            p.type_dic,
            p.value_dic,
            -- حساب الإجمالي الفرعي لكل صنف
            SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS invoice_subtotal,
            -- حساب الخصم
            CASE 
                WHEN p.type_dic = 0 THEN (
                    SUM(
                        pd.qty * (
                            pd.price 
                            - CASE 
                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (pd.price - 
                                        CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )
                    ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS invoice_discount,
            -- حساب الضريبة
            CASE 
                WHEN t.type = 0 THEN (
                    (
                        SUM(
                            pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) 
                        - CASE 
                            WHEN p.type_dic = 0 THEN (
                                SUM(
                                    pd.qty * (
                                        pd.price 
                                        - CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                        + CASE 
                                            WHEN ti.type = 0 THEN (
                                                (pd.price - 
                                                    CASE 
                                                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN ti.type = 1 THEN ti.value
                                            ELSE 0
                                        END
                                    )
                                ) * p.value_dic / 100
                            )
                            WHEN p.type_dic = 1 THEN p.value_dic
                            ELSE 0
                        END
                    ) * t.value / 100
                )
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS invoice_tax
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER = year_param
        GROUP BY p.id, p.date, p.charge_price, p.type_dic, p.value_dic, t.type, t.value
    )
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            SUBSTRING(date FROM 6 FOR 2)::INTEGER AS month,
            COALESCE(SUM(invoice_subtotal + charge_price), 0.0) AS total_purchases,
            COALESCE(SUM(invoice_discount), 0.0) AS total_discount,
            COALESCE(SUM(invoice_tax), 0.0) AS total_tax
        FROM PurchaseCalculations
        WHERE LENGTH(date) >= 10 -- للتأكد من أن التاريخ له طول كافي
        GROUP BY SUBSTRING(date FROM 6 FOR 2)::INTEGER
        ORDER BY month
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_monthly_sales(year_param INTEGER)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH SaleCalculations AS (
        SELECT 
            p.id,
            p.date,
            p.status,
            -- حساب الإجمالي الفرعي لكل صنف
            SUM(
                pd.qty * (
                    pd.sell 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS invoice_subtotal,
            -- حساب الخصم
            CASE 
                WHEN p.type_dic = 0 THEN (
                    SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )
                    ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS invoice_discount,
            -- حساب الضريبة
            CASE 
                WHEN t.type = 0 THEN (
                    (
                        SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) 
                        - CASE 
                            WHEN p.type_dic = 0 THEN (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                        + CASE 
                                            WHEN ti.type = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN ti.type = 1 THEN ti.value
                                            ELSE 0
                                        END
                                    )
                                ) * p.value_dic / 100
                            )
                            WHEN p.type_dic = 1 THEN p.value_dic
                            ELSE 0
                        END
                    ) * t.value / 100
                )
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS invoice_tax
        FROM sales p
        JOIN sales_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER = year_param
        AND (p.status = 'delivered' OR p.status IS NULL)
        GROUP BY p.id, p.date, p.status, p.type_dic, p.value_dic, t.type, t.value
    )
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            SUBSTRING(date FROM 6 FOR 2)::INTEGER AS month,
            COALESCE(SUM(invoice_subtotal), 0.0) AS total_sales,
            COALESCE(SUM(invoice_discount), 0.0) AS total_discount,
            COALESCE(SUM(invoice_tax), 0.0) AS total_tax
        FROM SaleCalculations
        WHERE LENGTH(date) >= 10 -- للتأكد من أن التاريخ له طول كافي
        GROUP BY SUBSTRING(date FROM 6 FOR 2)::INTEGER
        ORDER BY month
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_inv_change_stock(
  change_id TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      cs.*,
      inv.id AS stock_id,
      inv.name AS stock_name,
      u.username AS user_name
    FROM change_stock cs
    LEFT JOIN inventory inv ON cs.id_stock = inv.id
    LEFT JOIN users u ON cs.userid = u.id
    WHERE cs.invoice_code ILIKE '%' || change_id || '%'
    ORDER BY cs.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_change_stock_details(
  invoice_code_param TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      csd.*,
      i.id AS item_id,
      i.name AS item_name,
      i.price AS item_price,
      i.sell AS item_sell,
      ty.name AS type_name
    FROM change_stock_details csd
    JOIN items i ON csd.id_item = i.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE csd.id_invoice_code = invoice_code_param::INTEGER
    ORDER BY csd.id ASC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_sales(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      s.*,
      c.id AS id_customer,
      c.name AS customer_name,
      inv.id AS invname,
      inv.name AS inventory_name,
      d.id AS id_delivery,
      d.name AS delivery_name
    FROM sales s
    LEFT JOIN customers c ON s.id_customer = c.id
    LEFT JOIN inventory inv ON s.id_stock = inv.id
    LEFT JOIN delivery d ON s.id_delivery = d.id
    WHERE s.invoice_code ILIKE '%' || search_query || '%'
    ORDER BY s.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_all_orders_with_status_ketchin(
  search_id TEXT DEFAULT '',
  status_filter TEXT DEFAULT 'all'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
  where_conditions TEXT := '';
  conditions TEXT[] := '{}';
BEGIN
  -- بناء شروط WHERE
  IF search_id != '' THEN
    conditions := conditions || ARRAY[
      'p.invoice_code ILIKE ''%' || search_id || '%''',
      'dy.name ILIKE ''%' || search_id || '%''', 
      'cus.name ILIKE ''%' || search_id || '%''',
      'tab.name ILIKE ''%' || search_id || '%'''
    ];
  END IF;


  IF status_filter != 'all' THEN
    IF status_filter = 'waiting' THEN
      conditions := conditions || ARRAY['(p.status = ''completing'' OR p.status = ''whating'')'];
    ELSE
      conditions := conditions || ARRAY['p.status = ''' || status_filter || ''''];
    END IF;
  END IF;

  -- بناء شرط WHERE النهائي
  IF array_length(conditions, 1) > 0 THEN
    where_conditions := 'WHERE ' || array_to_string(conditions, ' AND ');
  END IF;

  EXECUTE '
    SELECT json_agg(row_to_json(t))
    FROM (
      SELECT 
        p.*,
        COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
        COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
        cus.name AS customername,
        cus.id AS customerid,
        s.name AS stockname,
        dy.name AS deliveryname,
        u.name AS username,
        tab.name AS tablename,

        COALESCE(SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ), 0.0) AS total,

        COALESCE(SUM(
          pd.qty * (
            (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
            - pd.price
          )
        ), 0.0) AS profit,

        CASE 
          WHEN p.type_dic = 0 THEN (
            SUM(
              pd.qty * (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.sell - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) * p.value_dic / 100
          )
          WHEN p.type_dic = 1 THEN p.value_dic
          ELSE 0
        END AS "discountPrice",

        CASE 
          WHEN t.type = 0 THEN (
            (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              )
              - 
              CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.sell 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.sell - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
            ) * t.value / 100
          )
          WHEN t.type = 1 THEN t.value
          ELSE 0
        END AS "TaxPrice"
      FROM ketchine p
      JOIN ketchine_detals pd ON p.id = pd.id_invoice_code
      JOIN items i ON pd.id_item = i.id
      JOIN users u ON p.userid = u.id
      JOIN customers cus ON p.id_customer = cus.id
      LEFT JOIN my_table tab ON p.id_table::INTEGER = tab.id::INTEGER
      LEFT JOIN delivery dy ON p.id_delivery = dy.id
      LEFT JOIN inventory s ON p.id_stock = s.id
      LEFT JOIN taxs t ON p.taxid = t.id
      LEFT JOIN taxs ti ON pd.taxid = ti.id
      ' || where_conditions || '
      GROUP BY p.id, cus.id, s.id, dy.id, u.id, tab.id, t.id
      ORDER BY p.date DESC, p.id DESC
    ) t
  ' INTO result;

  RETURN COALESCE(result, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_inv_sales_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      pay.*,
      pt.id AS paytype,
      pt.name AS payment_type_name
    FROM payments pay
    JOIN pay_types pt ON pay.paytype_id = pt.id
    JOIN sales s ON pay.code = s.invoice_code
    WHERE pay.code ILIKE '%' || search_query || '%'
    ORDER BY pay.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
DROP FUNCTION get_inv_details_sales(TEXT);
CREATE OR REPLACE FUNCTION get_inv_details_sales(
  invoice_code_param TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      i.name AS name,
      i.id AS id,
      sd.qty AS qty,
      sd.qty AS itemqty,
      sd.price AS price,
      sd.sell AS sell,
      sd.value_dic AS dis_value,
      sd.type_dic AS dis_type,
      sd.unit_base_qty AS unit_base_qty,
      sd.unit_name AS unit_name,
      sd.taxid AS taxid,
      sd.note AS note,
      i.is_item AS is_item,
      ty.name AS tyname,
      sd.purchase_detail_id,
      sd.expirydate
    FROM sales_detals sd
    JOIN items i ON sd.id_item = i.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE sd.id_invoice_code = invoice_code_param::INTEGER
    ORDER BY sd.id ASC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_inv_return_purchases_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      pay.*,
      pt.id AS paytype,
      pt.name AS payment_type_name
    FROM payments pay
    JOIN pay_types pt ON pay.paytype_id = pt.id
    JOIN return_purchases rp ON pay.code = rp.invoice_code
    WHERE pay.code ILIKE '%' || search_query || '%'
    ORDER BY pay.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
DROP FUNCTION get_inv_details_return_purchases(TEXT);
CREATE OR REPLACE FUNCTION get_inv_details_return_purchases(
  invoice_code_param TEXT,
  original_purchase_id TEXT DEFAULT NULL,
  use_original_quantity BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  IF use_original_quantity AND original_purchase_id IS NOT NULL THEN
    -- الحالة 1: جلب itemqty من فاتورة المشتريات الأصلية
    SELECT json_agg(row_to_json(t))
    INTO result
    FROM (
      SELECT 
        i.name AS name,
        i.id AS id,
        pd.qty AS itemqty,
        rpd.qty AS qty,
        rpd.qty AS qtyback,
        rpd.price AS price,
        rpd.sell AS sell,
        rpd.value_dic AS dis_value,
        rpd.type_dic AS dis_type,
        rpd.taxid AS taxid,
        ty.name AS tyname,
        rpd.unit_base_qty AS unit_base_qty,
        rpd.unit_name AS unit_name,
        rpd.expirydate,
        rpd.purchase_detail_id,
        rpd.barcode1,
        rpd.barcode2,
        rpd.barcode3,
        rpd.barcode4,
        rpd.barcode5,
        rpd.barcode6
      FROM return_purchase_detals rpd
      JOIN items i ON rpd.id_item = i.id
      JOIN purchase_details pd ON rpd.id_item = pd.id_item 
        AND pd.id_invoice_code = original_purchase_id
        AND rpd.purchase_detail_id = pd.id
      LEFT JOIN type_items ty ON i.id_itemtype = ty.id
      WHERE rpd.id_invoice_code = invoice_code_param::INTEGER
    ) t;
  ELSE
    -- الحالة 2: استخدام الكمية من العائد فقط
    SELECT json_agg(row_to_json(t))
    INTO result
    FROM (
      SELECT 
        i.name AS name,
        i.id AS id,
        rpd.qty AS itemqty,
        rpd.qty AS qty,
        rpd.price AS price,
        rpd.sell AS sell,
        rpd.value_dic AS dis_value,
        rpd.type_dic AS dis_type,
        rpd.taxid AS taxid,
        ty.name AS tyname,
        rpd.expirydate,
        rpd.purchase_detail_id,
        rpd.barcode1,
        rpd.barcode2,
        rpd.barcode3,
        rpd.barcode4,
        rpd.barcode5,
        rpd.barcode6
      FROM return_purchase_detals rpd
      JOIN items i ON rpd.id_item = i.id
      LEFT JOIN type_items ty ON i.id_itemtype = ty.id
      WHERE rpd.id_invoice_code = invoice_code_param::INTEGER
    ) t;
  END IF;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

DROP FUNCTION get_yearly_purchases1(TEXT,TEXT);
DROP FUNCTION get_yearly_purchases(TEXT,TEXT);
DROP FUNCTION get_yearly_purchases( INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION get_yearly_purchases(start_year TEXT, end_year TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    WITH InvoiceItems AS (
        SELECT 
            pd.id_invoice_code,
            pd.qty * (
                pd.price 
                - CASE 
                    WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                    WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                    ELSE 0
                END
                + CASE 
                    WHEN  CAST(ti.type AS INTEGER) = 0 THEN (
                        (pd.price - 
                            CASE 
                                WHEN  CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.price * pd.value_dic / 100)
                                WHEN  CAST(pd.type_dic AS INTEGER) = 1 THEN CAST(pd.value_dic AS REAL)
                                ELSE 0
                            END
                        ) * CAST(ti.value AS REAL) / 100
                    )
                    WHEN  CAST(ti.type AS INTEGER) = 1 THEN CAST(ti.value AS REAL)
                    ELSE 0
                END
            ) AS item_total
        FROM purchase_details pd
        LEFT JOIN taxs ti ON pd.taxid = ti.id
    ),
    InvoiceTotals AS (
        SELECT 
            id_invoice_code,
            SUM(item_total) AS gross_total
        FROM InvoiceItems
        GROUP BY id_invoice_code
    ),
    InvoiceDiscounts AS (
        SELECT 
            p.id AS invoice_id,
            CASE 
                WHEN p.type_dic = 0 THEN (it.gross_total * p.value_dic / 100)
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS total_discount
        FROM purchases p
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
    ),
    InvoiceTaxes AS (
        SELECT 
            p.id AS invoice_id,
            CASE 
                WHEN t.type = 0 THEN ((it.gross_total - id.total_discount) * t.value / 100)
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS total_tax
        FROM purchases p
        LEFT JOIN taxs t ON p.taxid = t.id
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
        JOIN InvoiceDiscounts id ON p.id = id.invoice_id
    )
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            SUBSTRING(p.date FROM 1 FOR 4)::INTEGER AS year,
            SUM(it.gross_total) + COALESCE(SUM(p.charge_price), 0) AS total_purchases,
            SUM(id.total_discount) AS total_discount,
            SUM(itx.total_tax) AS total_tax
        FROM purchases p
        JOIN InvoiceTotals it ON p.id = it.id_invoice_code
        JOIN InvoiceDiscounts id ON p.id = id.invoice_id
        JOIN InvoiceTaxes itx ON p.id = itx.invoice_id
        WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER BETWEEN start_year::INTEGER AND end_year::INTEGER
        GROUP BY SUBSTRING(p.date FROM 1 FOR 4)::INTEGER
        ORDER BY year
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_return_purchases(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      rp.*,
      s.id AS supplierid,
      s.name AS supplier_name,
      inv.id AS invname,
      inv.name AS inventory_name
    FROM return_purchases rp
    LEFT JOIN suppliers s ON rp.id_supplier = s.id
    LEFT JOIN inventory inv ON rp.id_stock = inv.id
    WHERE rp.invoice_code ILIKE '%' || search_query || '%'
    ORDER BY rp.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

DROP FUNCTION get_inv_details_purchases(TEXT);
CREATE OR REPLACE FUNCTION get_inv_details_purchases(
  invoice_code_param TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      i.name AS name,
      i.id AS id,
      pd.qty AS itemqty,
      pd.qty AS qty,
      pd.price AS price,
      pd.sell AS sell,
      pd.value_dic AS dis_value,
      pd.type_dic AS dis_type,
      pd.taxid AS taxid,
      ty.name AS tyname,
      pd.expirydate,
      pd.unit_base_qty AS unit_base_qty,
      pd.unit_name AS unit_name,
      pd.purchase_detail_id,
      pd.barcode1,
      pd.barcode2,
      pd.barcode3,
      pd.barcode4,
      pd.barcode5,
      pd.barcode6
    FROM purchase_details pd
    JOIN items i ON pd.id_item = i.id
    LEFT JOIN type_items ty ON i.id_itemtype = ty.id
    WHERE pd.id_invoice_code = invoice_code_param::INTEGER
    ORDER BY pd.id ASC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_purchases(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      s.id AS supplierid,
      s.name AS supplier_name,
      inv.id AS invname,
      inv.name AS inventory_name
    FROM purchases p
    LEFT JOIN suppliers s ON p.id_supplier = s.id
    LEFT JOIN inventory inv ON p.id_stock = inv.id
    WHERE p.invoice_code ILIKE '%' || search_query || '%'
    ORDER BY p.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_purchases_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      pay.*,
      pt.id AS paytype,
      pt.name AS payment_type_name
    FROM payments pay
    LEFT JOIN pay_types pt ON pay.paytype_id = pt.id
    JOIN purchases p ON pay.code = p.invoice_code
    WHERE pay.code ILIKE '%' || search_query || '%'
    ORDER BY pay.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;


CREATE OR REPLACE FUNCTION get_inv_return_sales(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      rs.*,
      c.id AS id_customer,
      c.name AS customer_name,
      inv.id AS invname,
      inv.name AS inventory_name,
      d.id AS id_delivery,
      d.name AS delivery_name
    FROM return_sales rs
    LEFT JOIN customers c ON rs.id_customer = c.id
    LEFT JOIN delivery d ON rs.id_delivery = d.id
    LEFT JOIN inventory inv ON rs.id_stock = inv.id
    WHERE rs.invoice_code ILIKE '%' || search_query || '%'
    ORDER BY rs.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;
CREATE OR REPLACE FUNCTION get_inv_return_sales_payments(
  search_query TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      pt.id AS paytype,
      pt.name AS payment_type_name
    FROM payments p
    JOIN pay_types pt ON p.paytype_id = pt.id
    JOIN return_sales rs ON p.code = rs.invoice_code
    WHERE p.code ILIKE '%' || search_query || '%'
    ORDER BY p.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_all_accounttrans(
  search_query TEXT DEFAULT NULL,
  from_date TEXT DEFAULT NULL,
  to_date TEXT DEFAULT NULL
)
RETURNS TABLE (
  id INTEGER,
  code TEXT,
  balance NUMERIC,
  note TEXT,
  userid INTEGER,
  accountdebit_id INTEGER,
  accounttransf_id INTEGER,
  date TEXT,
  accounttransfname TEXT,
  accountdebitname TEXT,
  username TEXT,
  transfer_desc TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.code,
    COALESCE(CAST(c.balance AS NUMERIC), 0.0) AS balance,  -- استخدام CAST
    c.note,
    c.userid,
    c.accountdebit_id,
    c.accounttransf_id,
    c.date,
    ac.name AS accounttransfname,
    acd.name AS accountdebitname,
    u.name AS username,
    (acd.name || ' → ' || ac.name) AS transfer_desc
  FROM accounttrans c
  LEFT JOIN account ac ON c.accounttransf_id = ac.id
  LEFT JOIN account acd ON c.accountdebit_id = acd.id
  LEFT JOIN users u ON c.userid = u.id
  WHERE 
    (search_query IS NULL OR 
     c.code ILIKE '%' || search_query || '%' OR 
     ac.name ILIKE '%' || search_query || '%' OR 
     acd.name ILIKE '%' || search_query || '%')
    AND (from_date IS NULL OR c.date >= from_date)
    AND (to_date IS NULL OR c.date <= to_date)
  ORDER BY c.date DESC, c.id DESC;
END;
$$;


DROP FUNCTION get_all_sales_view(TEXT);

CREATE OR REPLACE FUNCTION get_all_sales_view(
  p_id TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      p.*,
      COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
      COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
      cus.name AS customername,
      cus.id AS customerid,
      s.name AS stockname,
      dy.name AS deliveryname,
      u.name AS username,

      -- إجمالي الأصناف بعد تطبيق الخصم والضريبة لكل صنف
      COALESCE(SUM(
        pd.qty * (
          pd.sell 
          - CASE 
              WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
              WHEN pd.type_dic = 1 THEN pd.value_dic
              ELSE 0
            END
          + CASE 
              WHEN ti.type = 0 THEN (
                (pd.sell - 
                  CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                ) * ti.value / 100
              )
              WHEN ti.type = 1 THEN ti.value
              ELSE 0
            END
        )
      ), 0.0) AS total,

      -- إجمالي الربح
      COALESCE(SUM(
        pd.qty * (
          (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
          - pd.price
        )
      ), 0.0) AS profit,

      -- خصم الفاتورة
      CASE 
        WHEN p.type_dic = 0 THEN (SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ) * p.value_dic / 100)
        WHEN p.type_dic = 1 THEN p.value_dic
        ELSE 0
      END AS "discountPrice",

      -- ضريبة الفاتورة
      CASE 
        WHEN t.type = 0 THEN (
          (SUM(
            pd.qty * (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
          ) - 
          CASE 
            WHEN p.type_dic = 0 THEN (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              ) * p.value_dic / 100
            )
            WHEN p.type_dic = 1 THEN p.value_dic
            ELSE 0
          END
        ) * t.value / 100
        )
        WHEN t.type = 1 THEN t.value
        ELSE 0
      END AS "TaxPrice"

    FROM sales_view p
    JOIN sales_view_detals pd ON p.id = pd.id_invoice_code
    JOIN items i ON pd.id_item = i.id
    JOIN users u ON p.userid = u.id
    JOIN customers cus ON p.id_customer = cus.id
    LEFT JOIN delivery dy ON p.id_delivery = dy.id
    JOIN inventory s ON p.id_stock = s.id
    LEFT JOIN taxs t ON p.taxid = t.id
    LEFT JOIN taxs ti ON pd.taxid = ti.id
    
    -- بناء شروط WHERE ديناميكياً
    WHERE (
      (p_id = '' OR p.invoice_code ILIKE '%' || p_id || '%'))
    
    GROUP BY p.id, cus.id, s.id, dy.id, u.id, t.id
    ORDER BY p.date DESC, p.id DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_item_quantities_by_stock1(search_query TEXT)
RETURNS TABLE (
  username TEXT,
  contry_name TEXT,
  city_name TEXT,
  inventory_data JSON,  -- جميع بيانات inventory ككائن JSON
  item_count BIGINT,
  final_quantity REAL,
  final_price REAL
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.name AS username,
    cont.name AS contry_name,
    ci.name AS city_name,
    row_to_json(inv.*) AS inventory_data,  -- تحويل جميع أعمدة inventory إلى JSON
    COUNT(DISTINCT b.item_id) AS item_count,
    COALESCE(SUM(b.quantity), 0) AS final_quantity,
    COALESCE(SUM(b.quantity * i.price), 0.0) AS final_price
  FROM inventory inv
  LEFT JOIN batches b ON b.stock_id = inv.id AND b.quantity > 0
  LEFT JOIN items i ON b.item_id = i.id
  LEFT JOIN users u ON inv.userid = u.id
  LEFT JOIN country cont ON inv.countryid = cont.id
  LEFT JOIN city ci ON inv.cityid = ci.id
  WHERE inv.name LIKE '%' || search_query || '%'
  GROUP BY inv.id , u.name , cont.name , ci.name
  ORDER BY inv.name;
END;
$$;


ALTER TABLE batches DROP CONSTRAINT batches_purchase_detail_id_fkey;
CREATE OR REPLACE FUNCTION get_customer_with_details(p_customer_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'number_phone', c.number_phone,
        'cityid', c.cityid,
        'countryid', c.countryid,
        'address', c.address,
        'country_name', co.name,
        'city_name', ci.name,
        'delivery_price', cp.price
    ) INTO result
    FROM customers c
    LEFT JOIN country co ON c.countryid = co.id
    LEFT JOIN city ci ON c.cityid = ci.id
    LEFT JOIN citypay cp ON cp.city_id = ci.id AND cp.country_id = co.id
    WHERE c.id = p_customer_id;
    
    RETURN result;
END;
$$;
DROP FUNCTION IF EXISTS get_filtered_item_sales(
    TEXT, 
    TEXT, 
    TEXT, 
    TEXT, 
    TEXT, 
    TEXT
);

CREATE OR REPLACE FUNCTION get_filtered_item_sales(
    stock TEXT,
    search_items TEXT DEFAULT NULL,
    selected_main_category TEXT DEFAULT NULL,
    selected_sub_category TEXT DEFAULT NULL,
    selected_brand TEXT DEFAULT NULL,
    selected_country TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_data JSON;
BEGIN
    -- التحقق من وجود المخزن
    IF stock IS NULL OR stock = '' THEN
        RETURN json_build_object('error', 'معرف المخزن مطلوب');
    END IF;

    SELECT json_agg(row_to_json(t)) INTO result_data
    FROM (
        -- الجزء 1: الأصناف (is_item = 1)
        SELECT 
            i.*,
            ty.name AS tyname,
            COALESCE(SUM(b.quantity), 0) AS final_quantity,
            'item' AS source_type,
            COALESCE(SUM(b.quantity * i.price), 0) AS final_price
        FROM items i
        JOIN batches b ON i.id = b.item_id AND b.stock_id = stock::INTEGER
        LEFT JOIN items_maincategory m ON i.id_maincategory = m.id
        LEFT JOIN subcategory s ON i.id_subcategory = s.id
        LEFT JOIN brand bnd ON i.id_brand = bnd.id
        LEFT JOIN country c ON i.id_country = c.id
        LEFT JOIN type_items ty ON i.id_itemtype = ty.id
        WHERE 
            i.is_item = 1
            AND b.quantity > 0
            AND (search_items IS NULL OR search_items = '' OR 
                 i.name ILIKE '%' || search_items || '%' OR
                 i.barcode ILIKE '%' || search_items || '%' OR
                 i.barcode1 ILIKE '%' || search_items || '%' OR
                 i.barcode2 ILIKE '%' || search_items || '%' OR
                 i.barcode3 ILIKE '%' || search_items || '%' OR
                 i.barcode4 ILIKE '%' || search_items || '%' OR
                 i.barcode5 ILIKE '%' || search_items || '%' OR
                 i.barcode6 ILIKE '%' || search_items || '%')
            AND (selected_main_category IS NULL OR selected_main_category = '' OR m.id = selected_main_category::INTEGER)
            AND (selected_sub_category IS NULL OR selected_sub_category = '' OR s.id = selected_sub_category::INTEGER)
            AND (selected_brand IS NULL OR selected_brand = '' OR bnd.id = selected_brand::INTEGER)
            AND (selected_country IS NULL OR selected_country = '' OR c.id = selected_country::INTEGER)
        GROUP BY i.id, ty.name

        UNION ALL

        -- الجزء 2: الخدمات (is_item = 0)
        SELECT 
            i.*,
            ty.name AS tyname,
            1.0 AS final_quantity,
            'service' AS source_type,
            i.sell AS final_price
        FROM items i
        LEFT JOIN items_maincategory m ON i.id_maincategory = m.id
        LEFT JOIN subcategory s ON i.id_subcategory = s.id
        LEFT JOIN brand bnd ON i.id_brand = bnd.id
        LEFT JOIN country c ON i.id_country = c.id
        LEFT JOIN type_items ty ON i.id_itemtype = ty.id
        WHERE 
            i.is_item = 0
            AND i.is_active = 1
            AND (search_items IS NULL OR search_items = '' OR 
                 i.name ILIKE '%' || search_items || '%' OR
                 i.barcode ILIKE '%' || search_items || '%' OR
                 i.barcode1 ILIKE '%' || search_items || '%' OR
                 i.barcode2 ILIKE '%' || search_items || '%' OR
                 i.barcode3 ILIKE '%' || search_items || '%' OR
                 i.barcode4 ILIKE '%' || search_items || '%' OR
                 i.barcode5 ILIKE '%' || search_items || '%' OR
                 i.barcode6 ILIKE '%' || search_items || '%')
            AND (selected_main_category IS NULL OR selected_main_category = '' OR m.id = selected_main_category::INTEGER)
            AND (selected_sub_category IS NULL OR selected_sub_category = '' OR s.id = selected_sub_category::INTEGER)
            AND (selected_brand IS NULL OR selected_brand = '' OR bnd.id = selected_brand::INTEGER)
            AND (selected_country IS NULL OR selected_country = '' OR c.id = selected_country::INTEGER)
        ORDER BY name ASC
    ) t;

    RETURN COALESCE(result_data, '[]'::json);
END;
$$;



CREATE OR REPLACE FUNCTION get_all_sales0(
    id_param TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
    arg_counter INTEGER := 0;
BEGIN
    -- بناء شروط البحث
    IF id_param IS NOT NULL AND id_param != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.invoice_code LIKE $' || arg_counter;
        args := array_append(args, '%' || id_param || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.date >= $' || arg_counter;
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        arg_counter := arg_counter + 1;
        conditions := conditions || ' AND p.date <= $' || arg_counter;
        args := array_append(args, to_date);
    END IF;

    -- إضافة شرط الحالة
    conditions := conditions || ' AND (p.status = ''delivered'' OR p.status IS NULL)';

    -- إزالة AND الأولى إذا كانت conditions ليست فارغة
    IF conditions != '' THEN
        conditions := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- تنفيذ الاستعلام
    IF array_length(args, 1) IS NULL THEN
        EXECUTE format('
            SELECT json_agg(row_to_json(t)) 
            FROM (
                SELECT 
                    p.*,
                    COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                    COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                    cus.name AS customername,
                    cus.id AS customerid,
                    s.name AS stockname,
                    dy.name AS deliveryname,
                    u.name AS username,

                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                ELSE 0
                              END
                        )
                    ), 0.0) AS total,

                    COALESCE(SUM(
                        pd.qty * (
                            (
                                pd.sell 
                                - CASE 
                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                    ELSE 0
                                  END
                            )
                            - pd.price
                        )
                    ), 0.0) AS profit,

                    CASE 
                        WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                        ELSE 0
                                      END
                                )
                            ) * p.value_dic / 100
                        )
                        WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                        ELSE 0
                    END AS "discountPrice",

                    CASE 
                        WHEN CAST(t.type AS INTEGER) = 0 THEN (
                            (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                            ELSE 0
                                          END
                                    )
                                ) - 
                                CASE 
                                    WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                                        SUM(
                                            pd.qty * (
                                                pd.sell 
                                                - CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                  END
                                                + CASE 
                                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                        (pd.sell - 
                                                            CASE 
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                                ELSE 0
                                                            END
                                                        ) * ti.value / 100
                                                    )
                                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                                    ELSE 0
                                                  END
                                            )
                                        ) * p.value_dic / 100
                                    )
                                    WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                                    ELSE 0
                                END
                            ) * t.value / 100
                        )
                        WHEN CAST(t.type AS INTEGER) = 1 THEN t.value
                        ELSE 0
                    END AS "TaxPrice"
                FROM sales p
                JOIN sales_detals pd ON p.id = pd.id_invoice_code
                JOIN items i ON pd.id_item = i.id
                JOIN users u ON p.userid = u.id
                JOIN customers cus ON p.id_customer = cus.id
                LEFT JOIN delivery dy ON p.id_delivery = dy.id
                JOIN inventory s ON p.id_stock = s.id
                LEFT JOIN taxs t ON p.taxid = t.id
                LEFT JOIN taxs ti ON pd.taxid = ti.id
                %s
                GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
                ORDER BY p.date DESC, p.id DESC
            ) t
        ', conditions)
        INTO result_records;
    ELSE
        EXECUTE format('
            SELECT json_agg(row_to_json(t)) 
            FROM (
                SELECT 
                    p.*,
                    COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
                    COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
                    cus.name AS customername,
                    cus.id AS customerid,
                    s.name AS stockname,
                    dy.name AS deliveryname,
                    u.name AS username,

                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            + CASE 
                                WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                ELSE 0
                              END
                        )
                    ), 0.0) AS total,

                    COALESCE(SUM(
                        pd.qty * (
                            (
                                pd.sell 
                                - CASE 
                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                    ELSE 0
                                  END
                                + CASE 
                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                    ELSE 0
                                  END
                            )
                            - pd.price
                        )
                    ), 0.0) AS profit,

                    CASE 
                        WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                        ELSE 0
                                      END
                                    + CASE 
                                        WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                        ELSE 0
                                      END
                                )
                            ) * p.value_dic / 100
                        )
                        WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                        ELSE 0
                    END AS "discountPrice",

                    CASE 
                        WHEN CAST(t.type AS INTEGER) = 0 THEN (
                            (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                            ELSE 0
                                          END
                                        + CASE 
                                            WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                            ELSE 0
                                          END
                                    )
                                ) - 
                                CASE 
                                    WHEN CAST(p.type_dic AS INTEGER) = 0 THEN (
                                        SUM(
                                            pd.qty * (
                                                pd.sell 
                                                - CASE 
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                    ELSE 0
                                                  END
                                                + CASE 
                                                    WHEN CAST(ti.type AS INTEGER) = 0 THEN (
                                                        (pd.sell - 
                                                            CASE 
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 0 THEN (pd.sell * pd.value_dic / 100)
                                                                WHEN CAST(pd.type_dic AS INTEGER) = 1 THEN pd.value_dic
                                                                ELSE 0
                                                            END
                                                        ) * ti.value / 100
                                                    )
                                                    WHEN CAST(ti.type AS INTEGER) = 1 THEN ti.value
                                                    ELSE 0
                                                  END
                                            )
                                        ) * p.value_dic / 100
                                    )
                                    WHEN CAST(p.type_dic AS INTEGER) = 1 THEN p.value_dic
                                    ELSE 0
                                END
                            ) * t.value / 100
                        )
                        WHEN CAST(t.type AS INTEGER) = 1 THEN t.value
                        ELSE 0
                    END AS "TaxPrice"
                FROM sales p
                JOIN sales_detals pd ON p.id = pd.id_invoice_code
                JOIN items i ON pd.id_item = i.id
                JOIN users u ON p.userid = u.id
                JOIN customers cus ON p.id_customer = cus.id
                LEFT JOIN delivery dy ON p.id_delivery = dy.id
                JOIN inventory s ON p.id_stock = s.id
                LEFT JOIN taxs t ON p.taxid = t.id
                LEFT JOIN taxs ti ON pd.taxid = ti.id
                %s
                GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
                ORDER BY p.date DESC, p.id DESC
            ) t
        ', conditions)
        INTO result_records
        USING args[1], args[2], args[3];
    END IF;

    RETURN COALESCE(result_records, '[]'::json);
END;
$$;



CREATE OR REPLACE FUNCTION get_all_sales_view0(id_param TEXT DEFAULT NULL)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(results) INTO result
    FROM (
        SELECT 
            p.*,
            COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
            COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
            cus.name AS customername,
            cus.id AS customerid,
            s.name AS stockname,
            dy.name AS deliveryname,
            u.name AS username,
            COALESCE(SUM(
                pd.qty * (
                    pd.sell 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.sell - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ), 0.0) AS total,
            CASE 
                WHEN p.type_dic = 0 THEN (SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ) * p.value_dic / 100)
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
            END AS "discountPrice",
            CASE 
                WHEN t.type = 0 THEN (
                    (SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )
                    ) - CASE 
                        WHEN p.type_dic = 0 THEN (SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100)
                        WHEN p.type_dic = 1 THEN p.value_dic
                        ELSE 0
                    END) * t.value / 100
                )
                WHEN t.type = 1 THEN t.value
                ELSE 0
            END AS "TaxPrice"
        FROM sales_view p
        JOIN sales_view_detals pd ON p.id = pd.id_invoice_code
        JOIN items i ON pd.id_item = i.id
        JOIN users u ON p.userid = u.id
        JOIN customers cus ON p.id_customer = cus.id
        LEFT JOIN delivery dy ON p.id_delivery::integer = dy.id::integer
        JOIN inventory s ON p.id_stock::integer = s.id::integer
        LEFT JOIN taxs t ON p.taxid::integer = t.id::integer
        LEFT JOIN taxs ti ON pd.taxid::integer = ti.id::integer
        WHERE (id_param IS NULL OR id_param = '' OR p.invoice_code LIKE '%' || id_param || '%')
        GROUP BY p.id, cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
    ) results;

    RETURN COALESCE(result, '[]'::JSON);
END;
$$;

CREATE OR REPLACE FUNCTION add_purchase_rpc19(
  p_id INTEGER DEFAULT 0,
  p_userid INTEGER DEFAULT 0,
  p_supplierid INTEGER DEFAULT NULL,
  p_date TEXT DEFAULT NULL,
  p_charge REAL DEFAULT 0,
  p_time TEXT DEFAULT '00:00:00',
  p_inv_code TEXT DEFAULT 'TEMP-INV',
  p_type_dic INTEGER DEFAULT 0,
  p_value_dic REAL DEFAULT 0,
  p_taxid INTEGER DEFAULT NULL,
  p_stockid INTEGER DEFAULT 0,
  p_items JSONB DEFAULT '[]'::JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_account_id INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_purchase_id INTEGER;
  v_detail_id INTEGER;
  v_item JSONB;
  v_pay JSONB;
  v_result JSONB;
  v_actual_qty REAL;
  v_current_date TEXT := to_char(CURRENT_DATE, 'YYYY-MM-DD');
  v_items_array JSONB[];
  v_payments_array JSONB[];
BEGIN
  BEGIN
    -- تحويل JSONB إلى array أولاً
    v_items_array := ARRAY(SELECT jsonb_array_elements(p_items));
    v_payments_array := ARRAY(SELECT jsonb_array_elements(p_payments));

    -- إدخال الفاتورة
    INSERT INTO purchases (
      id, invoice_code, userid, id_supplier, account_id, taxid, 
      charge_price, type_dic, value_dic, id_stock, date, time
    ) VALUES (
      p_id, 
      p_inv_code, 
      p_userid, 
      p_supplierid, 
      p_account_id, 
      p_taxid,
      p_charge, 
      p_type_dic, 
      p_value_dic, 
      p_stockid, 
      COALESCE(p_date, v_current_date),
      p_time
    ) RETURNING id INTO v_purchase_id;

    -- إدخال الدفعات المالية (الطريقة المصححة)
    FOR i IN 1..array_length(v_payments_array, 1)
    LOOP
      v_pay := v_payments_array[i];
      
      INSERT INTO payments (
        code, date, type, price, paytype_id
      ) VALUES (
        p_inv_code, 
        COALESCE(p_date, v_current_date), 
        'pur',
        (v_pay->>'price')::REAL,
        (v_pay->>'pay_type')::INTEGER
      );
    END LOOP;

    -- إدخال التفاصيل (الطريقة المصححة)
    FOR i IN 1..array_length(v_items_array, 1)
    LOOP
      v_item := v_items_array[i];
      
      -- حساب الكمية الفعلية
      v_actual_qty := (v_item->>'qty')::REAL;
      IF (v_item->>'unit_base_qty') IS NOT NULL AND (v_item->>'unit_base_qty') != '' THEN
        v_actual_qty := v_actual_qty * (v_item->>'unit_base_qty')::REAL;
      END IF;

      -- إدخال التفاصيل
      INSERT INTO purchase_details (
        id_item, id_invoice_code, qty, value_dic, type_dic, taxid, 
        price, sell, purchase_detail_id, expirydate,
        barcode1, barcode2, barcode3, barcode4, barcode5, barcode6,
        unit_name, unit_base_qty
      ) VALUES (
        (v_item->>'id')::INTEGER, 
        v_purchase_id, 
        v_actual_qty,
        (v_item->>'dis_value')::REAL, 
        (v_item->>'dis_type')::INTEGER,
        (v_item->>'taxid')::INTEGER, 
        (v_item->>'price')::REAL,
        (v_item->>'sell')::REAL, 
        (v_item->>'purchase_detail_id')::INTEGER,
        NULLIF(v_item->>'expirydate', ''),
        COALESCE(NULLIF(v_item->>'barcode1', ''), ''),
        COALESCE(NULLIF(v_item->>'barcode2', ''), ''),
        COALESCE(NULLIF(v_item->>'barcode3', ''), ''),
        COALESCE(NULLIF(v_item->>'barcode4', ''), ''),
        COALESCE(NULLIF(v_item->>'barcode5', ''), ''),
        COALESCE(NULLIF(v_item->>'barcode6', ''), ''),
        COALESCE(v_item->>'unit_name', 'piece'),
        (v_item->>'unit_base_qty')::REAL
      ) RETURNING id INTO v_detail_id;

      -- إنشاء دفعة جديدة
      PERFORM process_transaction_rpc(
        'purchase',
        (v_item->>'id')::INTEGER,
        p_stockid,
        v_actual_qty,
        NULLIF(v_item->>'expirydate', ''),
        TRUE,
        v_detail_id
      );
    END LOOP;

    v_result := jsonb_build_object(
      'success', true,
      'purchase_id', v_purchase_id,
      'message', 'تم إضافة فاتورة المشتريات بنجاح'
    );

  EXCEPTION
    WHEN OTHERS THEN
      v_result := jsonb_build_object(
        'success', false,
        'error', SQLERRM
      );
  END;

  RETURN v_result;
END;
$$;



DROP FUNCTION calculate_daily_sales();

DROP FUNCTION calculate_total_sales();

DROP FUNCTION calculate_annual_sales();

DROP FUNCTION calculate_monthly_sales();

DROP FUNCTION calculate_monthly_expenses();

DROP FUNCTION calculate_annual_expenses();

DROP FUNCTION calculate_total_expenses();

DROP FUNCTION calculate_daily_expenses();

DROP FUNCTION calculate_yearly_purchases();

DROP FUNCTION calculate_monthly_purchases();

DROP FUNCTION calculate_total_purchases();

DROP FUNCTION calculate_daily_purchases();



CREATE OR REPLACE FUNCTION calculate_daily_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    today_date DATE;
    total_value DOUBLE PRECISION := 0;
    total_tax DOUBLE PRECISION := 0;
    total_discount DOUBLE PRECISION := 0;
    total_profit DOUBLE PRECISION := 0;
    paid_total DOUBLE PRECISION := 0;
    invoice_count INTEGER := 0;
    response JSON;
BEGIN
    today_date := CURRENT_DATE;    
    WITH SalesInvoiceCalculations AS (
        SELECT 
            s.id AS invoice_id,
            s.invoice_code,
            s.type_dic,
            s.value_dic,
            t.type AS tax_type,
            t.value AS tax_value,
            -- إجمالي المبيعات قبل أي خصومات
            SUM(sd.qty * sd.sell) AS gross_total,
            -- تكلفة الأصناف
            SUM(sd.qty * sd.price) AS cost_total,
            -- خصومات الأصناف
            SUM(
                sd.qty * (
                    CASE 
                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                        WHEN sd.type_dic = 1 THEN sd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount_total,
            -- ضرائب الأصناف
            SUM(
                sd.qty * (
                    CASE 
                        WHEN ti.type = 0 THEN (
                            (sd.sell - 
                                CASE 
                                    WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                    WHEN sd.type_dic = 1 THEN sd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS item_tax_total
        FROM sales s
        JOIN sales_detals sd ON s.id = sd.id_invoice_code
        LEFT JOIN taxs ti ON sd.taxid = ti.id
        LEFT JOIN taxs t ON s.taxid = t.id
        WHERE s.date::DATE = today_date 
          AND (s.status = 'delivered' OR s.status IS NULL)
        GROUP BY s.id, s.invoice_code, s.type_dic, s.value_dic, t.type, t.value
    ),
    InvoiceTotals AS (
        SELECT 
            invoice_id,
            invoice_code,
            -- الإجمالي بعد خصومات وضرائب الأصناف
            gross_total - item_discount_total + item_tax_total AS net_after_items,
            -- التكلفة الإجمالية
            cost_total,
            -- خصم الفاتورة على الإجمالي
            CASE 
                WHEN type_dic = 0 THEN (
                    (gross_total - item_discount_total + item_tax_total) * value_dic / 100
                )
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS invoice_discount,
            -- ضريبة الفاتورة على الإجمالي بعد خصم الفاتورة
            CASE 
                WHEN tax_type = 0 THEN (
                    (
                        (gross_total - item_discount_total + item_tax_total)
                        - CASE 
                            WHEN type_dic = 0 THEN (
                                (gross_total - item_discount_total + item_tax_total) * value_dic / 100
                            )
                            WHEN type_dic = 1 THEN value_dic
                            ELSE 0
                        END
                    ) * tax_value / 100
                )
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS invoice_tax,
            -- إجمالي خصومات الأصناف
            item_discount_total,
            -- ربح الأصناف (بعد خصومات وضرائب الأصناف فقط)
            (gross_total - item_discount_total + item_tax_total) - cost_total AS item_profit
        FROM SalesInvoiceCalculations
),
    PaymentsSummary AS (
        SELECT 
            code,
            SUM(price) AS paid_amount
        FROM payments
        WHERE date::DATE = today_date
        GROUP BY code
    )
    SELECT 
        COUNT(it.invoice_id) AS invoice_count,
        COALESCE(SUM(
            it.net_after_items 
            - it.invoice_discount 
            + it.invoice_tax
        ), 0.0) AS total_value,
        COALESCE(SUM(it.invoice_discount + it.item_discount_total), 0.0) AS total_discount,
        COALESCE(SUM(it.invoice_tax), 0.0) AS total_tax,
        COALESCE(SUM(
            it.item_profit 
            - it.invoice_discount 
            + it.invoice_tax
        ), 0.0) AS total_profit,
        COALESCE(SUM(ps.paid_amount), 0.0) AS total_paid
    INTO invoice_count, total_value, total_discount, total_tax, total_profit, paid_total
    FROM InvoiceTotals it
    LEFT JOIN PaymentsSummary ps ON it.invoice_code = ps.code;

    response := json_build_object(
        'paid', COALESCE(paid_total, 0.0),
        'total_tax', COALESCE(total_tax, 0.0),
        'invoice_count', COALESCE(invoice_count, 0),
        'total_discount', COALESCE(total_discount, 0.0),
        'total_value', COALESCE(total_value, 0.0),
        'total_profit', COALESCE(total_profit, 0.0)
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_daily_purchases()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    today_date TEXT;
    charge_price_total DOUBLE PRECISION := 0;
    invoice_count_total INTEGER := 0;
    total_discount_total DOUBLE PRECISION := 0;
    total_tax_total DOUBLE PRECISION := 0;
    total_value_total DOUBLE PRECISION := 0;
    response JSON;
BEGIN
    today_date := TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD');
    
    WITH InvoiceLevelCalculations AS (
        SELECT 
            p.id AS invoice_id,
            p.type_dic,
            p.value_dic,
            COALESCE(p.charge_price, 0) AS charge_price,
            t.type AS tax_type,
            t.value AS tax_value,
            -- إجمالي الأصناف قبل أي خصومات
            SUM(pd.qty * pd.price) AS gross_total,
            -- خصومات الأصناف
            SUM(
                pd.qty * (
                    CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount_total,
            -- ضرائب الأصناف
            SUM(
                pd.qty * (
                    CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS item_tax_total
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        WHERE p.date = today_date
        GROUP BY p.id, p.type_dic, p.value_dic, p.charge_price, t.type, t.value
    ),
    InvoiceTotals AS (
        SELECT 
            invoice_id,
            charge_price,
            -- الإجمالي بعد خصومات وضرائب الأصناف
            gross_total - item_discount_total + item_tax_total AS net_after_items,
            -- خصم الفاتورة على الإجمالي
            CASE 
                WHEN type_dic = 0 THEN (
                    (gross_total - item_discount_total + item_tax_total) * value_dic / 100
                )
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS invoice_discount,
            -- ضريبة الفاتورة على الإجمالي بعد خصم الفاتورة
            CASE 
                WHEN tax_type = 0 THEN (
                    (
                        (gross_total - item_discount_total + item_tax_total)
                        - CASE 
                            WHEN type_dic = 0 THEN (
                                (gross_total - item_discount_total + item_tax_total) * value_dic / 100
                            )
                            WHEN type_dic = 1 THEN value_dic
                            ELSE 0
                        END
                    ) * tax_value / 100
                )
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS invoice_tax,
            -- إجمالي خصومات الأصناف
            item_discount_total
        FROM InvoiceLevelCalculations
    )
    SELECT 
        COUNT(invoice_id) AS invoice_count,
        COALESCE(SUM(
            net_after_items 
            - invoice_discount 
            + invoice_tax 
            + charge_price
        ), 0.0) AS total_value,
        COALESCE(SUM(invoice_discount + item_discount_total), 0.0) AS total_discount,
        COALESCE(SUM(invoice_tax), 0.0) AS total_tax,
        COALESCE(SUM(charge_price), 0.0) AS charge_total
    INTO invoice_count_total, total_value_total, total_discount_total, total_tax_total, charge_price_total
    FROM InvoiceTotals;

    response := json_build_object(
        'charge_price1', COALESCE(charge_price_total, 0.0),
        'total_tax', COALESCE(total_tax_total, 0.0),
        'invoice_count', COALESCE(invoice_count_total, 0),
        'total_discount', COALESCE(total_discount_total, 0.0),
        'total_value', COALESCE(total_value_total, 0.0)
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_daily_expenses()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    today_date DATE;
    invoice_count INTEGER;
    total_value DOUBLE PRECISION;
    response JSON;
BEGIN
    today_date := CURRENT_DATE;
    
    -- حساب مباشر
    SELECT 
        COUNT(*) AS invoice_count, 
        SUM(price) AS total_value
    INTO invoice_count, total_value
    FROM expansive
    WHERE date::DATE = today_date;

    -- معالجة القيم NULL
    invoice_count := COALESCE(invoice_count, 0);
    total_value := COALESCE(total_value, 0.0);

    response := json_build_object(
        'invoice_count', invoice_count,
        'total_value', total_value
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_total_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    tax DOUBLE PRECISION := 0.0;
    dic DOUBLE PRECISION := 0.0;
    total DOUBLE PRECISION := 0.0;
    count INTEGER := 0;
    profit DOUBLE PRECISION := 0.0;
    paidTotal DOUBLE PRECISION := 0.0;
    response JSON;
BEGIN
    -- استخدام CTE لتجنب تجميع الدوال
    WITH InvoiceCalculations AS (
        SELECT 
            s.id AS invoice_id,
            s.invoice_code,
            s.type_dic,
            s.value_dic,
            t.type AS tax_type,
            t.value AS tax_value,
            SUM(sd.qty * sd.sell) AS gross_total,
            SUM(
                sd.qty * (
                    sd.sell 
                    - CASE 
                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                        WHEN sd.type_dic = 1 THEN sd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (sd.sell - 
                                CASE 
                                    WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                    WHEN sd.type_dic = 1 THEN sd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS net_total,
            SUM(
                sd.qty * (
                    CASE 
                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                        WHEN sd.type_dic = 1 THEN sd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount,
            SUM(
                sd.qty * (
                    (
                        sd.sell 
                        - CASE 
                            WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                            WHEN sd.type_dic = 1 THEN sd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (sd.sell - 
                                    CASE 
                                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                        WHEN sd.type_dic = 1 THEN sd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                    - sd.price
                )
            ) AS item_profit
        FROM sales s
        JOIN sales_detals sd ON s.id = sd.id_invoice_code
        LEFT JOIN taxs ti ON sd.taxid = ti.id
        LEFT JOIN taxs t ON s.taxid = t.id
        WHERE (s.status = 'delivered' OR s.status IS NULL)
        GROUP BY s.id, s.invoice_code, s.type_dic, s.value_dic, t.type, t.value
    ),
    Payments AS (
        SELECT 
            code,
            SUM(price) AS paid_amount
        FROM payments
        GROUP BY code
    ),
    InvoiceSummary AS (
        SELECT 
            invoice_id,
            invoice_code,
            net_total,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            item_profit AS total_profit
        FROM InvoiceCalculations
    )
    SELECT 
        COUNT(isum.invoice_id) AS invoice_count,
        COALESCE(SUM(isum.net_total), 0.0) AS total_net,
        COALESCE(SUM(isum.total_discount), 0.0) AS total_discount,
        COALESCE(SUM(isum.total_tax), 0.0) AS total_tax,
        COALESCE(SUM(isum.total_profit), 0.0) AS total_profit,
        COALESCE(SUM(p.paid_amount), 0.0) AS total_paid
    INTO count, total, dic, tax, profit, paidTotal
    FROM InvoiceSummary isum
    LEFT JOIN Payments p ON isum.invoice_code = p.code;

    response := json_build_object(
        'paid', paidTotal,
        'total_tax', tax,
        'invoice_count', count,
        'total_discount', dic,
        'total_value', total,
        'total_profit', profit
    );

    RETURN response;
END;
$$;


CREATE OR REPLACE FUNCTION calculate_total_expenses()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    invoice_count INTEGER;
    total_value DOUBLE PRECISION;
    response JSON;
BEGIN
    -- حساب مباشر بدون تجميع داخلي
    SELECT 
        COUNT(*) AS invoice_count, 
        SUM(price) AS total_value
    INTO invoice_count, total_value
    FROM expansive;

    -- معالجة القيم NULL
    invoice_count := COALESCE(invoice_count, 0);
    total_value := COALESCE(total_value, 0.0);

    response := json_build_object(
        'invoice_count', invoice_count,
        'total_value', total_value
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_total_purchases()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    charge_price_total DOUBLE PRECISION := 0;
    invoice_count_total INTEGER := 0;
    total_discount_total DOUBLE PRECISION := 0;
    total_tax_total DOUBLE PRECISION := 0;
    total_value_total DOUBLE PRECISION := 0;
    response JSON;
BEGIN
    -- استخدام CTE لتجنب تجميع الدوال
    WITH PurchaseCalculations AS (
        SELECT 
            p.id AS invoice_id,
            p.type_dic,
            p.value_dic,
            p.charge_price,
            t.type AS tax_type,
            t.value AS tax_value,
            SUM(pd.qty * pd.price) AS gross_total,
            SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS net_total,
            SUM(
                pd.qty * (
                    CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        GROUP BY p.id, p.type_dic, p.value_dic, p.charge_price, t.type, t.value
    ),
    InvoiceSummary AS (
        SELECT 
            invoice_id,
            net_total + COALESCE(charge_price, 0) AS total_net_with_charge,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            charge_price
        FROM PurchaseCalculations
    )
    SELECT 
        COUNT(invoice_id) AS invoice_count,
        COALESCE(SUM(total_net_with_charge), 0.0) AS total_value,
        COALESCE(SUM(total_discount), 0.0) AS total_discount,
        COALESCE(SUM(total_tax), 0.0) AS total_tax,
        COALESCE(SUM(charge_price), 0.0) AS charge_total
    INTO invoice_count_total, total_value_total, total_discount_total, total_tax_total, charge_price_total
    FROM InvoiceSummary;

    response := json_build_object(
        'charge_price1', COALESCE(charge_price_total, 0.0),
        'total_tax', COALESCE(total_tax_total, 0.0),
        'invoice_count', COALESCE(invoice_count_total, 0),
        'total_discount', COALESCE(total_discount_total, 0.0),
        'total_value', COALESCE(total_value_total, 0.0)
    );

    RETURN response;
END;
$$;


CREATE OR REPLACE FUNCTION calculate_yearly_purchases()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_year DATE;
    end_of_year DATE;
    charge_price_total DOUBLE PRECISION := 0;
    invoice_count_total INTEGER := 0;
    total_discount_total DOUBLE PRECISION := 0;
    total_tax_total DOUBLE PRECISION := 0;
    total_value_total DOUBLE PRECISION := 0;
    response JSON;
BEGIN
    start_of_year := DATE_TRUNC('year', CURRENT_DATE)::DATE;
    end_of_year := (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::DATE;
    
    -- استخدام CTE لتجنب تجميع الدوال
    WITH PurchaseCalculations AS (
        SELECT 
            p.id AS invoice_id,
            p.type_dic,
            p.value_dic,
            p.charge_price,
            t.type AS tax_type,
            t.value AS tax_value,
            SUM(pd.qty * pd.price) AS gross_total,
            SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS net_total,
            SUM(
                pd.qty * (
                    CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        WHERE p.date::DATE BETWEEN start_of_year AND end_of_year
        GROUP BY p.id, p.type_dic, p.value_dic, p.charge_price, t.type, t.value
    ),
    InvoiceSummary AS (
        SELECT 
            invoice_id,
            net_total + COALESCE(charge_price, 0) AS total_net_with_charge,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            charge_price
        FROM PurchaseCalculations
    )
    SELECT 
        COUNT(invoice_id) AS invoice_count,
        COALESCE(SUM(total_net_with_charge), 0.0) AS total_value,
        COALESCE(SUM(total_discount), 0.0) AS total_discount,
        COALESCE(SUM(total_tax), 0.0) AS total_tax,
        COALESCE(SUM(charge_price), 0.0) AS charge_total
    INTO invoice_count_total, total_value_total, total_discount_total, total_tax_total, charge_price_total
    FROM InvoiceSummary;

    response := json_build_object(
        'charge_price1', COALESCE(charge_price_total, 0.0),
        'total_tax', COALESCE(total_tax_total, 0.0),
        'invoice_count', COALESCE(invoice_count_total, 0),
        'total_discount', COALESCE(total_discount_total, 0.0),
        'total_value', COALESCE(total_value_total, 0.0)
    );

    RETURN response;
END;
$$;



CREATE OR REPLACE FUNCTION calculate_annual_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_year DATE;
    end_of_year DATE;
    tax DOUBLE PRECISION := 0.0;
    dic DOUBLE PRECISION := 0.0;
    total DOUBLE PRECISION := 0.0;
    count INTEGER := 0;
    profit DOUBLE PRECISION := 0.0;
    paidTotal DOUBLE PRECISION := 0.0;
    response JSON;
BEGIN
    start_of_year := DATE_TRUNC('year', CURRENT_DATE)::DATE;
    end_of_year := (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::DATE;
    
    -- استخدام CTE لتجنب تجميع الدوال
    WITH InvoiceCalculations AS (
        SELECT 
            s.id AS invoice_id,
            s.invoice_code,
            s.type_dic,
            s.value_dic,
            t.type AS tax_type,
            t.value AS tax_value,
            SUM(sd.qty * sd.sell) AS gross_total,
            SUM(
                sd.qty * (
                    sd.sell 
                    - CASE 
                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                        WHEN sd.type_dic = 1 THEN sd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (sd.sell - 
                                CASE 
                                    WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                    WHEN sd.type_dic = 1 THEN sd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ) AS net_total,
            SUM(
                sd.qty * (
                    CASE 
                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                        WHEN sd.type_dic = 1 THEN sd.value_dic
                        ELSE 0
                    END
                )
            ) AS item_discount,
            SUM(
                sd.qty * (
                    (
                        sd.sell 
                        - CASE 
                            WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                            WHEN sd.type_dic = 1 THEN sd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (sd.sell - 
                                    CASE 
                                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                        WHEN sd.type_dic = 1 THEN sd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                    - sd.price
                )
            ) AS item_profit
        FROM sales s
        JOIN sales_detals sd ON s.id = sd.id_invoice_code
        LEFT JOIN taxs ti ON sd.taxid = ti.id
        LEFT JOIN taxs t ON s.taxid = t.id
        WHERE s.date::DATE BETWEEN start_of_year AND end_of_year
          AND (s.status = 'delivered' OR s.status IS NULL)
        GROUP BY s.id, s.invoice_code, s.type_dic, s.value_dic, t.type, t.value
    ),
    InvoiceSummary AS (
        SELECT 
            invoice_id,
            invoice_code,
            net_total,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            item_profit AS total_profit
        FROM InvoiceCalculations
    ),
    Payments AS (
        SELECT 
            code,
            SUM(price) AS paid_amount
        FROM payments
        GROUP BY code
    )
    SELECT 
        COUNT(invoice_id) AS invoice_count,
        COALESCE(SUM(net_total), 0.0) AS total_net,
        COALESCE(SUM(total_discount), 0.0) AS total_discount,
        COALESCE(SUM(total_tax), 0.0) AS total_tax,
        COALESCE(SUM(total_profit), 0.0) AS total_profit,
        COALESCE(SUM(p.paid_amount), 0.0) AS total_paid
    INTO count, total, dic, tax, profit, paidTotal
    FROM InvoiceSummary isum
    LEFT JOIN Payments p ON isum.invoice_code = p.code;

    response := json_build_object(
        'paid', paidTotal,
        'total_tax', tax,
        'invoice_count', count,
        'total_discount', dic,
        'total_value', total,
        'total_profit', profit
    );

    RETURN response;
END;
$$;





DROP FUNCTION get_all_account_pro(TEXT);
CREATE OR REPLACE FUNCTION get_all_account_pro(query_text TEXT)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    -- استخدام CTE مع تسمية صحيحة
    WITH AccountBase AS (
        SELECT 
            c.id,
            c.name,
            c.date AS datee,
            CAST(c.balance AS REAL) AS initial_balance,
            ac.name AS nameac,
            u.name AS username
        FROM account c
        LEFT JOIN account_type ac ON c.account_id = ac.id
        LEFT JOIN users u ON c.userid = u.id
        WHERE query_text = '' OR c.name ILIKE '%' || query_text || '%'
    ),
    DebitTotals AS (
        SELECT 
            c.id AS account_id,
            COALESCE(SUM(
                CASE 
                    WHEN ad.accountdebit_id = c.id THEN 
                        CAST(REPLACE(ad.balance::TEXT, ',', '') AS REAL)
                    ELSE 0.0 
                END
            ), 0.0) AS total_debit,
            COALESCE(SUM(
                CASE 
                    WHEN ad.accounttransf_id = c.id THEN 
                        CAST(REPLACE(ad.balance::TEXT, ',', '') AS REAL)
                    ELSE 0.0 
                END
            ), 0.0) AS total_transfer_debit
        FROM account c
        LEFT JOIN accountdebitcode ad ON c.id IN (ad.accountdebit_id, ad.accounttransf_id)
        WHERE query_text = '' OR c.name ILIKE '%' || query_text || '%'
        GROUP BY c.id
    ),
    TransferTotals AS (
        SELECT 
            c.id AS account_id,
            COALESCE(SUM(
                CASE 
                    WHEN at.accountdebit_id = c.id THEN 
                        CAST(REPLACE(at.balance::TEXT, ',', '') AS REAL)
                    ELSE 0.0 
                END
            ), 0.0) AS total_debit_transfer,
            COALESCE(SUM(
                CASE 
                    WHEN at.accounttransf_id = c.id THEN 
                        CAST(REPLACE(at.balance::TEXT, ',', '') AS REAL)
                    ELSE 0.0 
                END
            ), 0.0) AS total_transfer_transfer
        FROM account c
        LEFT JOIN accounttrans at ON c.id IN (at.accountdebit_id, at.accounttransf_id)
        WHERE query_text = '' OR c.name ILIKE '%' || query_text || '%'
        GROUP BY c.id
    ),
    PurchaseTotals AS (
        SELECT 
            p.account_id,
            COALESCE(SUM(
                pd.qty * (
                    pd.price 
                    - CASE 
                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN ti.type = 0 THEN (
                            (pd.price - 
                                CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                            ) * ti.value / 100
                        )
                        WHEN ti.type = 1 THEN ti.value
                        ELSE 0
                    END
                )
            ), 0.0) AS gross_purchases,
            COALESCE(SUM(p.charge_price), 0.0) AS total_charge_price,
            COALESCE(SUM(
                CASE 
                    WHEN p.type_dic = 0 THEN 
                        pd.qty * pd.price * p.value_dic / 100
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END
            ), 0.0) AS purchase_discount,
            COALESCE(SUM(
                CASE 
                    WHEN t.type = 0 THEN 
                        (pd.qty * pd.price - 
                            CASE 
                                WHEN p.type_dic = 0 THEN 
                                    pd.qty * pd.price * p.value_dic / 100
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END
            ), 0.0) AS purchase_tax
        FROM purchases p
        JOIN purchase_details pd ON p.id = pd.id_invoice_code
        LEFT JOIN taxs ti ON pd.taxid = ti.id
        LEFT JOIN taxs t ON p.taxid = t.id
        WHERE p.account_id IS NOT NULL
        GROUP BY p.account_id
    ),
    ReturnPurchaseTotals AS (
        SELECT 
            rp.account_id,
            COALESCE(SUM(rpd.qty * rpd.price), 0.0) AS gross_return_purchases,
            COALESCE(SUM(rp.charge_price), 0.0) AS return_total_charge_price,
            COALESCE(SUM(
                CASE 
                    WHEN rp.type_dic = 0 THEN 
                        rpd.qty * rpd.price * rp.value_dic / 100
                    WHEN rp.type_dic = 1 THEN rp.value_dic
                    ELSE 0
                END
            ), 0.0) AS return_purchase_discount,
            COALESCE(SUM(
                CASE 
                    WHEN t.type = 0 THEN 
                        (rpd.qty * rpd.price - 
                            CASE 
                                WHEN rp.type_dic = 0 THEN 
                                    rpd.qty * rpd.price * rp.value_dic / 100
                                WHEN rp.type_dic = 1 THEN rp.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END
            ), 0.0) AS return_purchase_tax
        FROM return_purchases rp
        JOIN return_purchase_detals rpd ON rp.id = rpd.id_invoice_code
        LEFT JOIN taxs t ON rp.taxid = t.id
        WHERE rp.account_id IS NOT NULL
        GROUP BY rp.account_id
    ),
    SalesTotals AS (
        SELECT 
            s.account_id,
            COALESCE(SUM(sd.qty * sd.sell), 0.0) AS gross_sales,
            COALESCE(SUM(
                CASE 
                    WHEN s.type_dic = 0 THEN 
                        sd.qty * sd.sell * s.value_dic / 100
                    WHEN s.type_dic = 1 THEN s.value_dic
                    ELSE 0
                END
            ), 0.0) AS sales_discount,
            COALESCE(SUM(
                CASE 
                    WHEN t.type = 0 THEN 
                        (sd.qty * sd.sell - 
                            CASE 
                                WHEN s.type_dic = 0 THEN 
                                    sd.qty * sd.sell * s.value_dic / 100
                                WHEN s.type_dic = 1 THEN s.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END
            ), 0.0) AS sales_tax
        FROM sales s
        JOIN sales_detals sd ON s.id = sd.id_invoice_code
        LEFT JOIN taxs t ON s.taxid = t.id
        WHERE s.account_id IS NOT NULL
        GROUP BY s.account_id
    ),
    ReturnSalesTotals AS (
        SELECT 
            rs.account_id,
            COALESCE(SUM(rsd.qty * rsd.sell), 0.0) AS gross_return_sales,
            COALESCE(SUM(
                CASE 
                    WHEN rs.type_dic = 0 THEN 
                        rsd.qty * rsd.sell * rs.value_dic / 100
                    WHEN rs.type_dic = 1 THEN rs.value_dic
                    ELSE 0
                END
            ), 0.0) AS return_sales_discount,
            COALESCE(SUM(
                CASE 
                    WHEN t.type = 0 THEN 
                        (rsd.qty * rsd.sell - 
                            CASE 
                                WHEN rs.type_dic = 0 THEN 
                                    rsd.qty * rsd.sell * rs.value_dic / 100
                                WHEN rs.type_dic = 1 THEN rs.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END
            ), 0.0) AS return_sales_tax
        FROM return_sales rs
        JOIN return_sales_detals rsd ON rs.id = rsd.id_invoice_code
        LEFT JOIN taxs t ON rs.taxid = t.id
        WHERE rs.account_id IS NOT NULL
        GROUP BY rs.account_id
    ),
    ExpenseTotals AS (
        SELECT 
            e.account_id,
            COALESCE(SUM(e.price), 0.0) AS total_expenses
        FROM expansive e
        WHERE e.account_id IS NOT NULL
        GROUP BY e.account_id
    ),
    -- CTE النهائي مع جميع الحسابات
    FinalAccountData AS (
        SELECT 
            ab.id,
            ab.name,
            ab.datee,
            ab.initial_balance,
            ab.nameac,
            ab.username,
            COALESCE(dt.total_debit, 0.0) AS total_debit,
            COALESCE(dt.total_transfer_debit, 0.0) AS total_transfer_debit,
            COALESCE(tt.total_debit_transfer, 0.0) AS total_debit_transfer,
            COALESCE(tt.total_transfer_transfer, 0.0) AS total_transfer_transfer,
            COALESCE(pt.gross_purchases + pt.total_charge_price - pt.purchase_discount + pt.purchase_tax, 0.0) AS total_purchases,
            COALESCE(rpt.gross_return_purchases + rpt.return_total_charge_price - rpt.return_purchase_discount + rpt.return_purchase_tax, 0.0) AS total_return_purchases,
            COALESCE(st.gross_sales - st.sales_discount + st.sales_tax, 0.0) AS total_sales,
            COALESCE(rst.gross_return_sales - rst.return_sales_discount + rst.return_sales_tax, 0.0) AS total_return_sales,
            COALESCE(et.total_expenses, 0.0) AS total_expenses,
            -- حساب الرصيد النهائي
            ab.initial_balance +
            COALESCE(dt.total_debit, 0.0) - COALESCE(dt.total_transfer_debit, 0.0) +
            COALESCE(tt.total_debit_transfer, 0.0) - COALESCE(tt.total_transfer_transfer, 0.0) -
            COALESCE(pt.gross_purchases + pt.total_charge_price - pt.purchase_discount + pt.purchase_tax, 0.0) +
            COALESCE(rpt.gross_return_purchases + rpt.return_total_charge_price - rpt.return_purchase_discount + rpt.return_purchase_tax, 0.0) +
            COALESCE(st.gross_sales - st.sales_discount + st.sales_tax, 0.0) -
            COALESCE(rst.gross_return_sales - rst.return_sales_discount + rst.return_sales_tax, 0.0) -
            COALESCE(et.total_expenses, 0.0) AS final_balance
        FROM AccountBase ab
        LEFT JOIN DebitTotals dt ON ab.id = dt.account_id
        LEFT JOIN TransferTotals tt ON ab.id = tt.account_id
        LEFT JOIN PurchaseTotals pt ON ab.id = pt.account_id
        LEFT JOIN ReturnPurchaseTotals rpt ON ab.id = rpt.account_id
        LEFT JOIN SalesTotals st ON ab.id = st.account_id
        LEFT JOIN ReturnSalesTotals rst ON ab.id = rst.account_id
        LEFT JOIN ExpenseTotals et ON ab.id = et.account_id
    )
    SELECT json_agg(row_to_json(t)) INTO result_json
    FROM FinalAccountData t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;






CREATE OR REPLACE FUNCTION calculate_annual_expenses()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_year DATE;
    end_of_year DATE;
    invoice_count INTEGER;
    total_value DOUBLE PRECISION;
    response JSON;
BEGIN
    start_of_year := DATE_TRUNC('year', CURRENT_DATE)::DATE;
    end_of_year := (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::DATE;
    
    -- حساب مباشر
    SELECT 
        COUNT(*) AS invoice_count, 
        SUM(price) AS total_value
    INTO invoice_count, total_value
    FROM expansive
    WHERE date::DATE BETWEEN start_of_year AND end_of_year;

    -- معالجة القيم NULL
    invoice_count := COALESCE(invoice_count, 0);
    total_value := COALESCE(total_value, 0.0);

    response := json_build_object(
        'invoice_count', invoice_count,
        'total_value', total_value
    );

    RETURN response;
END;
$$;
CREATE OR REPLACE FUNCTION calculate_monthly_expenses()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_month DATE;
    end_of_month DATE;
    invoice_count INTEGER;
    total_value DOUBLE PRECISION;
    response JSON;
BEGIN
    start_of_month := DATE_TRUNC('month', CURRENT_DATE)::DATE;
    end_of_month := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE;
    
    -- حساب مباشر بدون تجميع داخلي
    SELECT 
        COUNT(*) AS invoice_count, 
        SUM(price) AS total_value
    INTO invoice_count, total_value
    FROM expansive
    WHERE date::DATE BETWEEN start_of_month AND end_of_month;

    -- إذا كانت النتائج NULL، اجعلها 0
    invoice_count := COALESCE(invoice_count, 0);
    total_value := COALESCE(total_value, 0.0);

    response := json_build_object(
        'invoice_count', invoice_count,
        'total_value', total_value
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_monthly_sales()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_month DATE;
    end_of_month DATE;
    tax DOUBLE PRECISION := 0.0;
    dic DOUBLE PRECISION := 0.0;
    total DOUBLE PRECISION := 0.0;
    count INTEGER := 0;
    paidTotal DOUBLE PRECISION := 0.0;
    profit DOUBLE PRECISION := 0.0;
    result_record RECORD;
    response JSON;
BEGIN
    start_of_month := DATE_TRUNC('month', CURRENT_DATE)::DATE;
    end_of_month := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE;
    
    FOR result_record IN (
        WITH InvoiceCalculations AS (
            SELECT 
                s.id AS invoice_id,
                s.invoice_code,
                s.type_dic,
                s.value_dic,
                t.type AS tax_type,
                t.value AS tax_value,
                SUM(sd.qty * sd.sell) AS gross_total,
                SUM(
                    sd.qty * (
                        sd.sell 
                        - CASE 
                            WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                            WHEN sd.type_dic = 1 THEN sd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (sd.sell - 
                                    CASE 
                                        WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                        WHEN sd.type_dic = 1 THEN sd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ) AS net_total,
                SUM(
                    sd.qty * (
                        CASE 
                            WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                            WHEN sd.type_dic = 1 THEN sd.value_dic
                            ELSE 0
                        END
                    )
                ) AS item_discount,
                SUM(
                    sd.qty * (
                        (
                            sd.sell 
                            - CASE 
                                WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                WHEN sd.type_dic = 1 THEN sd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (sd.sell - 
                                        CASE 
                                            WHEN sd.type_dic = 0 THEN (sd.sell * sd.value_dic / 100)
                                            WHEN sd.type_dic = 1 THEN sd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )
                        - sd.price
                    )
                ) AS item_profit
            FROM sales s
            JOIN sales_detals sd ON s.id = sd.id_invoice_code
            LEFT JOIN taxs ti ON sd.taxid = ti.id
            LEFT JOIN taxs t ON s.taxid = t.id
            WHERE s.date::DATE BETWEEN start_of_month AND end_of_month
              AND (s.status = 'delivered' OR s.status IS NULL)
            GROUP BY s.id, s.invoice_code, s.type_dic, s.value_dic, t.type, t.value
        )
        SELECT 
            invoice_id,
            invoice_code,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            net_total AS total_value,
            item_profit AS total_profit
        FROM InvoiceCalculations
    ) LOOP
        -- حساب المبالغ المدفوعة لكل فاتورة
        SELECT COALESCE(SUM(price), 0.0)
        INTO paidTotal
        FROM payments 
        WHERE code = result_record.invoice_code;
        
        tax := tax + COALESCE(result_record.total_tax, 0.0);
        dic := dic + COALESCE(result_record.total_discount, 0.0);
        total := total + COALESCE(result_record.total_value, 0.0);
        profit := profit + COALESCE(result_record.total_profit, 0.0);
        count := count + 1;
    END LOOP;

    response := json_build_object(
        'total_tax', tax,
        'invoice_count', count,
        'total_discount', dic,
        'total_value', total,
        'total_profit', profit,
        'paid', paidTotal
    );

    RETURN response;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_monthly_purchases()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    start_of_month DATE;
    end_of_month DATE;
    charge_price_total DOUBLE PRECISION := 0;
    invoice_count_total INTEGER := 0;
    total_discount_total DOUBLE PRECISION := 0;
    total_tax_total DOUBLE PRECISION := 0;
    total_value_total DOUBLE PRECISION := 0;
    result_record RECORD;
    response JSON;
BEGIN
    -- حساب بداية ونهاية الشهر
    start_of_month := DATE_TRUNC('month', CURRENT_DATE)::DATE;
    end_of_month := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE;
    
    -- حساب المشتريات الرئيسية
    FOR result_record IN (
        WITH InvoiceItems AS (
            SELECT 
                p.id AS invoice_id,
                p.type_dic,
                p.value_dic,
                t.type AS tax_type,
                t.value AS tax_value,
                SUM(pd.qty * pd.price) AS gross_total,
                SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ) AS net_total,
                SUM(
                    pd.qty * (
                        CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                    )
                ) AS item_discount
            FROM purchases p
            JOIN purchase_details pd ON p.id = pd.id_invoice_code
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            LEFT JOIN taxs t ON p.taxid = t.id
            WHERE p.date::DATE BETWEEN start_of_month AND end_of_month
            GROUP BY p.id, p.type_dic, p.value_dic, t.type, t.value
        )
        SELECT 
            invoice_id,
            CASE 
                WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                WHEN type_dic = 1 THEN value_dic
                ELSE 0
            END AS total_discount,
            CASE 
                WHEN tax_type = 0 THEN ((net_total - 
                    CASE 
                        WHEN type_dic = 0 THEN (net_total * value_dic / 100)
                        WHEN type_dic = 1 THEN value_dic
                        ELSE 0
                    END) * tax_value / 100)
                WHEN tax_type = 1 THEN tax_value
                ELSE 0
            END AS total_tax,
            net_total AS total_value
        FROM InvoiceItems
    ) LOOP
        invoice_count_total := invoice_count_total + 1;
        total_discount_total := total_discount_total + COALESCE(result_record.total_discount, 0.0);
        total_tax_total := total_tax_total + COALESCE(result_record.total_tax, 0.0);
        total_value_total := total_value_total + COALESCE(result_record.total_value, 0.0);
    END LOOP;

    -- حساب الشحن
    SELECT COALESCE(SUM(charge_price), 0.0)
    INTO charge_price_total
    FROM purchases 
    WHERE date::DATE BETWEEN start_of_month AND end_of_month;

    -- بناء الاستجابة
    response := json_build_object(
        'charge_price1', COALESCE(charge_price_total, 0.0),
        'total_tax', COALESCE(total_tax_total, 0.0),
        'invoice_count', COALESCE(invoice_count_total, 0),
        'total_discount', COALESCE(total_discount_total, 0.0),
        'total_value', COALESCE(total_value_total + charge_price_total, 0.0)
    );

    RETURN response;
END;
$$;
CREATE OR REPLACE FUNCTION get_popular_items_by_invoices()
RETURNS TABLE(category TEXT, value BIGINT) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.name AS category, 
    COUNT(DISTINCT s.id) AS value
  FROM sales s
  INNER JOIN sales_detals sd ON s.id = sd.id_invoice_code
  INNER JOIN items i ON sd.id_item = i.id
  GROUP BY i.name
  ORDER BY COUNT(DISTINCT s.id) DESC
  LIMIT 10;
END;
$$;



DROP FUNCTION get_all_orders_with_status_pos_ketchin_search(text,text);
DROP FUNCTION get_all_orders_with_status_pos_ketchin_search(text,text);
CREATE OR REPLACE FUNCTION get_all_orders_with_status_pos_ketchin_search(
  search_id TEXT DEFAULT '',
  status_filter TEXT DEFAULT 'all'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
  where_conditions TEXT := '';
  conditions TEXT[] := '{}';
BEGIN
  -- بناء شروط WHERE للحالة (تأكد من التعامل مع النصوص)
  IF status_filter = 'wa' THEN
    conditions := conditions || ARRAY['p.status IN (''completing'', ''whating'')'];
  ELSIF status_filter = 'com' THEN
    conditions := conditions || ARRAY['p.status = ''complete'''];
  END IF;
  -- ملاحظة: حالتي 'all' و NULL لا تحتاجان شرطًا

  -- بناء شروط WHERE للبحث
  IF search_id != '' THEN
    conditions := conditions || ARRAY[
      'p.invoice_code ILIKE ''%' || search_id || '%''',
      'dy.name ILIKE ''%' || search_id || '%''', 
      'cus.name ILIKE ''%' || search_id || '%''',
      'tab.name ILIKE ''%' || search_id || '%'''
    ];
  END IF;

  -- بناء شرط WHERE النهائي
  IF array_length(conditions, 1) > 0 THEN
    where_conditions := 'WHERE ' || array_to_string(conditions, ' AND ');
  END IF;

  EXECUTE '
    SELECT json_agg(row_to_json(t))
    FROM (
      SELECT 
        p.*,
        COALESCE(SUM(pd.qty * pd.sell), 0.0) AS total1,
        COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS paid,
        cus.name AS customername,
        cus.id::TEXT AS customerid,
        s.name AS stockname,
        dy.name AS deliveryname,
        u.name AS username,
        tab.name AS tablename,

        COALESCE(SUM(
          pd.qty * (
            pd.sell 
            - CASE 
                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                WHEN pd.type_dic = 1 THEN pd.value_dic
                ELSE 0
              END
            + CASE 
                WHEN ti.type = 0 THEN (
                  (pd.sell - 
                    CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  ) * ti.value / 100
                )
                WHEN ti.type = 1 THEN ti.value
                ELSE 0
              END
          )
        ), 0.0) AS total,

        COALESCE(SUM(
          pd.qty * (
            (
              pd.sell 
              - CASE 
                  WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                  WHEN pd.type_dic = 1 THEN pd.value_dic
                  ELSE 0
                END
              + CASE 
                  WHEN ti.type = 0 THEN (
                    (pd.sell - 
                      CASE 
                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                        WHEN pd.type_dic = 1 THEN pd.value_dic
                        ELSE 0
                      END
                    ) * ti.value / 100
                  )
                  WHEN ti.type = 1 THEN ti.value
                  ELSE 0
                END
            )
            - pd.price
          )
        ), 0.0) AS profit,

        CASE 
          WHEN p.type_dic = 0 THEN (
            SUM(
              pd.qty * (
                pd.sell 
                - CASE 
                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                    WHEN pd.type_dic = 1 THEN pd.value_dic
                    ELSE 0
                  END
                + CASE 
                    WHEN ti.type = 0 THEN (
                      (pd.sell - 
                        CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      ) * ti.value / 100
                    )
                    WHEN ti.type = 1 THEN ti.value
                    ELSE 0
                  END
              )
            ) * p.value_dic / 100
          )
          WHEN p.type_dic = 1 THEN p.value_dic
          ELSE 0
        END::TEXT AS "discountPrice",

        CASE 
          WHEN t.type = 0 THEN (
            (
              SUM(
                pd.qty * (
                  pd.sell 
                  - CASE 
                      WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                      WHEN pd.type_dic = 1 THEN pd.value_dic
                      ELSE 0
                    END
                  + CASE 
                      WHEN ti.type = 0 THEN (
                        (pd.sell - 
                          CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                          END
                        ) * ti.value / 100
                      )
                      WHEN ti.type = 1 THEN ti.value
                      ELSE 0
                    END
                )
              )
              - 
              CASE 
                WHEN p.type_dic = 0 THEN (
                  SUM(
                    pd.qty * (
                      pd.sell 
                      - CASE 
                          WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                          WHEN pd.type_dic = 1 THEN pd.value_dic
                          ELSE 0
                        END
                      + CASE 
                          WHEN ti.type = 0 THEN (
                            (pd.sell - 
                              CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                              END
                            ) * ti.value / 100
                          )
                          WHEN ti.type = 1 THEN ti.value
                          ELSE 0
                        END
                    )
                  ) * p.value_dic / 100
                )
                WHEN p.type_dic = 1 THEN p.value_dic
                ELSE 0
              END
            ) * t.value / 100
          )
          WHEN t.type = 1 THEN t.value
          ELSE 0
        END::TEXT AS "TaxPrice"
      FROM ketchine p
      JOIN ketchine_detals pd ON p.id = pd.id_invoice_code
      JOIN items i ON pd.id_item = i.id
      JOIN users u ON p.userid = u.id
      JOIN customers cus ON p.id_customer = cus.id
      LEFT JOIN my_table tab ON p.id_table::INTEGER = tab.id::INTEGER
      LEFT JOIN delivery dy ON p.id_delivery = dy.id
      LEFT JOIN inventory s ON p.id_stock = s.id
      LEFT JOIN taxs t ON p.taxid = t.id
      LEFT JOIN taxs ti ON pd.taxid = ti.id
      ' || where_conditions || '
     GROUP BY p.id, cus.id, s.id, dy.id, u.id, tab.id, t.id
      ORDER BY p.date DESC, p.id DESC
    ) t
  ' INTO result;

  RETURN COALESCE(result, '[]'::json);
END;
$$;

CREATE OR REPLACE FUNCTION get_popular_items_by_qty()
RETURNS TABLE(category TEXT, value NUMERIC) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.name AS category, 
    SUM(sd.qty)::NUMERIC AS value
  FROM sales_detals sd
  INNER JOIN items i ON sd.id_item = i.id
  GROUP BY i.name
  ORDER BY SUM(sd.qty) DESC
  LIMIT 10;
END;
$$;








DROP FUNCTION get_daily_sales(INTEGER,INTEGER);

CREATE OR REPLACE FUNCTION get_daily_sales(year_param INTEGER, month_param INTEGER)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            SUBSTRING(date FROM 9 FOR 2) AS day,
            LPAD(SUBSTRING(date FROM 9 FOR 2), 2, '0') AS formatted_day,
            COALESCE(SUM(total_sales), 0.0) AS total_sales,
            COALESCE(SUM(invoice_discount), 0.0) AS total_discount,
            COALESCE(SUM(invoice_tax), 0.0) AS total_tax,
            COALESCE(SUM(total_sales - invoice_discount + invoice_tax), 0.0) AS net_total
        FROM (
            SELECT 
                p.date,
                -- إجمالي الفاتورة (بعد خصومات وضرائب الأصناف)
                SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ) AS total_sales,
                
                -- خصم الفاتورة على الإجمالي
                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS invoice_discount,

                -- ضريبة الفاتورة على الإجمالي بعد الخصم
                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN ti.type = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN ti.type = 1 THEN ti.value
                                        ELSE 0
                                    END
                                )
                            ) 
                            - CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.sell 
                                            - CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN ti.type = 0 THEN (
                                                    (pd.sell - 
                                                        CASE 
                                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                                            ELSE 0
                                                        END
                                                    ) * ti.value / 100
                                                )
                                                WHEN ti.type = 1 THEN ti.value
                                                ELSE 0
                                            END
                                        )
                                    ) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS invoice_tax

            FROM sales p
            JOIN sales_detals pd ON p.id = pd.id_invoice_code
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER = year_param 
                AND SUBSTRING(p.date FROM 6 FOR 2)::INTEGER = month_param 
                AND (p.status = 'delivered' OR p.status IS NULL)
                AND LENGTH(p.date) >= 10
            GROUP BY p.id, p.date, p.type_dic, p.value_dic, t.type, t.value
        ) AS invoice_totals
        WHERE SUBSTRING(date FROM 9 FOR 2)::INTEGER BETWEEN 1 AND 31
        GROUP BY SUBSTRING(date FROM 9 FOR 2)
        ORDER BY SUBSTRING(date FROM 9 FOR 2)::INTEGER
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;


DROP FUNCTION get_daily_purchases(INTEGER,INTEGER);
CREATE OR REPLACE FUNCTION get_daily_purchases(year_param INTEGER, month_param INTEGER)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result_json
    FROM (
        SELECT 
            SUBSTRING(date FROM 9 FOR 2) AS day,
            LPAD(SUBSTRING(date FROM 9 FOR 2), 2, '0') AS formatted_day,
            COUNT(DISTINCT invoice_id) AS invoice_count,
            COALESCE(SUM(total_purchases), 0.0) AS total_purchases,
            COALESCE(SUM(invoice_discount), 0.0) AS total_discount,
            COALESCE(SUM(invoice_tax), 0.0) AS total_tax,
            COALESCE(SUM(charge_price), 0.0) AS total_charge,
            COALESCE(SUM(total_purchases - invoice_discount + invoice_tax + charge_price), 0.0) AS net_total
        FROM (
            SELECT 
                p.id AS invoice_id,
                p.date,
                COALESCE(p.charge_price, 0) AS charge_price,
                -- إجمالي المشتريات لكل فاتورة (بعد خصومات وضرائب الأصناف)
                SUM(
                    pd.qty * (
                        pd.price 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.price - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ) AS total_purchases,
                
                -- خصم الفاتورة على الإجمالي
                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(
                            pd.qty * (
                                pd.price 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.price - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS invoice_discount,

                -- ضريبة الفاتورة على الإجمالي بعد الخصم
                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(
                                pd.qty * (
                                    pd.price 
                                    - CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN ti.type = 0 THEN (
                                            (pd.price - 
                                                CASE 
                                                    WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN ti.type = 1 THEN ti.value
                                        ELSE 0
                                    END
                                )
                            ) 
                            - CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.price 
                                            - CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN ti.type = 0 THEN (
                                                    (pd.price - 
                                                        CASE 
                                                            WHEN pd.type_dic = 0 THEN (pd.price * pd.value_dic / 100)
                                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                                            ELSE 0
                                                        END
                                                    ) * ti.value / 100
                                                )
                                                WHEN ti.type = 1 THEN ti.value
                                                ELSE 0
                                            END
                                        )
                                    ) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS invoice_tax

            FROM purchases p
            JOIN purchase_details pd ON p.id = pd.id_invoice_code
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            WHERE SUBSTRING(p.date FROM 1 FOR 4)::INTEGER = year_param 
                AND SUBSTRING(p.date FROM 6 FOR 2)::INTEGER = month_param 
                AND LENGTH(p.date) >= 10
            GROUP BY p.id, p.date, p.type_dic, p.value_dic, t.type, t.value, p.charge_price
        ) AS invoice_totals
        WHERE SUBSTRING(date FROM 9 FOR 2)::INTEGER BETWEEN 1 AND 31
        GROUP BY SUBSTRING(date FROM 9 FOR 2)
        ORDER BY SUBSTRING(date FROM 9 FOR 2)::INTEGER
    ) t;

    RETURN COALESCE(result_json, '[]'::json);
END;
$$;


DROP FUNCTION get_inv_transfer(text);
CREATE OR REPLACE FUNCTION get_inv_transfer(
  transfer_id TEXT DEFAULT ''
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT 
      ts.*,
      inv_to.id AS to_stock_id,
      inv_to.name AS to_stock_name,
      inv_from.id AS from_stock_id,
      inv_from.name AS from_stock_name,
      u_from.username AS from_user_name
    FROM transf_stock ts
    LEFT JOIN inventory inv_to ON ts.id_to_stock = inv_to.id
    LEFT JOIN inventory inv_from ON ts.id_from_stock = inv_from.id
    LEFT JOIN users u_from ON ts.user_id = u_from.id
    WHERE ts.invoice_code ILIKE '%' || transfer_id || '%'
    ORDER BY ts.date DESC
  ) t;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;


DROP FUNCTION get_all_sales_with_status(TEXT,TEXT,TEXT,TEXT);
CREATE OR REPLACE FUNCTION get_all_sales_with_status(
    id_param TEXT DEFAULT '',
    from_date TEXT DEFAULT NULL,
    to_date TEXT DEFAULT NULL,
    status_filter TEXT DEFAULT 'all'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    conditions TEXT := '';
    args TEXT[] := '{}';
    result_records JSON;
    sql_query TEXT;
    where_clause TEXT := '';
    arg_count INTEGER := 0;
BEGIN
    -- بناء شروط البحث
    IF id_param IS NOT NULL AND id_param != '' THEN
        arg_count := arg_count + 1;
        conditions := conditions || ' AND (p.invoice_code ILIKE $' || arg_count;
        conditions := conditions || ' OR dy.name ILIKE $' || arg_count;
        conditions := conditions || ' OR cus.name ILIKE $' || arg_count || ')';
        args := array_append(args, '%' || id_param || '%');
    END IF;

    IF from_date IS NOT NULL AND from_date != '' THEN
        arg_count := arg_count + 1;
        conditions := conditions || ' AND p.date::DATE >= $' || arg_count || '::DATE';
        args := array_append(args, from_date);
    END IF;

    IF to_date IS NOT NULL AND to_date != '' THEN
        arg_count := arg_count + 1;
        conditions := conditions || ' AND p.date::DATE <= $' || arg_count || '::DATE';
        args := array_append(args, to_date);
    END IF;

    -- فلترة الحالة
    IF status_filter IS NOT NULL AND status_filter != '' AND status_filter != 'all' THEN
        IF status_filter = 'delivered' THEN
            conditions := conditions || ' AND (p.status = ''delivered'' OR p.status IS NULL)';
        ELSE
            arg_count := arg_count + 1;
            conditions := conditions || ' AND p.status = $' || arg_count;
            args := array_append(args, status_filter);
        END IF;
    END IF;

    IF conditions != '' THEN
        where_clause := 'WHERE ' || substr(conditions, 6);
    END IF;

    -- بناء الاستعلام مع أسماء الأعمدة الصحيحة لحالة الأحرف
    sql_query := '
        SELECT json_agg(row_to_json(t)) 
        FROM (
            SELECT 
                p.id,
                p.invoice_code,
                p.date,
                p.status,
                p.type_dic AS invoice_discount_type,
                p.value_dic AS invoice_discount_value,
                p.taxid,
                p.userid,
                p.id_customer,
                p.id_delivery,
                p.id_stock,
                
                
                -- الإجمالي قبل أي خصومات أو ضرائب
                COALESCE(SUM(pd.qty * pd.sell), 0.0) AS "grossTotal",
                
                -- المبلغ المدفوع
                COALESCE((SELECT SUM(price) FROM payments WHERE code = p.invoice_code), 0.0) AS "paid",
                
                cus.name AS "customername",
                cus.id AS "customerid",
                s.name AS "stockname",
                dy.name AS "deliveryname",
                u.name AS "username",
                --total
                -- الإجمالي بعد خصومات وضرائب الأصناف
                COALESCE(SUM(
                    pd.qty * (
                        pd.sell 
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ), 0.0) AS "total",
                
                -- الربح
                COALESCE(SUM(
                    pd.qty * (
                        pd.sell - pd.price
                        - CASE 
                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                            WHEN pd.type_dic = 1 THEN pd.value_dic
                            ELSE 0
                        END
                        + CASE 
                            WHEN ti.type = 0 THEN (
                                (pd.sell - 
                                    CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                ) * ti.value / 100
                            )
                            WHEN ti.type = 1 THEN ti.value
                            ELSE 0
                        END
                    )
                ), 0.0) AS "profit",
                --discountprice
                -- خصم الفاتورة - استخدام الاسم الذي يتوقعه Dart
                CASE 
                    WHEN p.type_dic = 0 THEN (
                        SUM(
                            pd.qty * (
                                pd.sell 
                                - CASE 
                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                    ELSE 0
                                END
                                + CASE 
                                    WHEN ti.type = 0 THEN (
                                        (pd.sell - 
                                            CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                        ) * ti.value / 100
                                    )
                                    WHEN ti.type = 1 THEN ti.value
                                    ELSE 0
                                END
                            )
                        ) * p.value_dic / 100
                    )
                    WHEN p.type_dic = 1 THEN p.value_dic
                    ELSE 0
                END AS "discountPrice", -- ← تغيير هنا
                
                --taxprice ضريبة الفاتورة - استخدام الاسم الذي يتوقعه Dart
                CASE 
                    WHEN t.type = 0 THEN (
                        (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN ti.type = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN ti.type = 1 THEN ti.value
                                        ELSE 0
                                    END
                                )
                            ) 
                            - CASE 
                                WHEN p.type_dic = 0 THEN (
                                    SUM(
                                        pd.qty * (
                                            pd.sell 
                                            - CASE 
                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                ELSE 0
                                            END
                                            + CASE 
                                                WHEN ti.type = 0 THEN (
                                                    (pd.sell - 
                                                        CASE 
                                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                                            ELSE 0
                                                        END
                                                    ) * ti.value / 100
                                                )
                                                WHEN ti.type = 1 THEN ti.value
                                                ELSE 0
                                            END
                                        )
                                    ) * p.value_dic / 100
                                )
                                WHEN p.type_dic = 1 THEN p.value_dic
                                ELSE 0
                            END
                        ) * t.value / 100
                    )
                    WHEN t.type = 1 THEN t.value
                    ELSE 0
                END AS "TaxPrice", -- ← تغيير هنا
                
                -- الإجمالي النهائي
                (
                    COALESCE(SUM(
                        pd.qty * (
                            pd.sell 
                            - CASE 
                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                ELSE 0
                            END
                            + CASE 
                                WHEN ti.type = 0 THEN (
                                    (pd.sell - 
                                        CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                    ) * ti.value / 100
                                )
                                WHEN ti.type = 1 THEN ti.value
                                ELSE 0
                            END
                        )
                    ), 0.0)
                    - CASE 
                        WHEN p.type_dic = 0 THEN (
                            SUM(
                                pd.qty * (
                                    pd.sell 
                                    - CASE 
                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                        ELSE 0
                                    END
                                    + CASE 
                                        WHEN ti.type = 0 THEN (
                                            (pd.sell - 
                                                CASE 
                                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                            ) * ti.value / 100
                                        )
                                        WHEN ti.type = 1 THEN ti.value
                                        ELSE 0
                                    END
                                )
                            ) * p.value_dic / 100
                        )
                        WHEN p.type_dic = 1 THEN p.value_dic
                        ELSE 0
                    END
                    + CASE 
                        WHEN t.type = 0 THEN (
                            (
                                SUM(
                                    pd.qty * (
                                        pd.sell 
                                        - CASE 
                                            WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                            WHEN pd.type_dic = 1 THEN pd.value_dic
                                            ELSE 0
                                        END
                                        + CASE 
                                            WHEN ti.type = 0 THEN (
                                                (pd.sell - 
                                                    CASE 
                                                        WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                        WHEN pd.type_dic = 1 THEN pd.value_dic
                                                        ELSE 0
                                                    END
                                                ) * ti.value / 100
                                            )
                                            WHEN ti.type = 1 THEN ti.value
                                            ELSE 0
                                        END
                                    )
                                ) 
                                - CASE 
                                    WHEN p.type_dic = 0 THEN (
                                        SUM(
                                            pd.qty * (
                                                pd.sell 
                                                - CASE 
                                                    WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                    WHEN pd.type_dic = 1 THEN pd.value_dic
                                                    ELSE 0
                                                END
                                                + CASE 
                                                    WHEN ti.type = 0 THEN (
                                                        (pd.sell - 
                                                            CASE 
                                                                WHEN pd.type_dic = 0 THEN (pd.sell * pd.value_dic / 100)
                                                                WHEN pd.type_dic = 1 THEN pd.value_dic
                                                                ELSE 0
                                                            END
                                                        ) * ti.value / 100
                                                    )
                                                    WHEN ti.type = 1 THEN ti.value
                                                    ELSE 0
                                                END
                                            )
                                        ) * p.value_dic / 100
                                    )
                                    WHEN p.type_dic = 1 THEN p.value_dic
                                    ELSE 0
                                END
                            ) * t.value / 100
                        )
                        WHEN t.type = 1 THEN t.value
                        ELSE 0
                    END
                ) AS "netTotal"
                
            FROM sales p
            JOIN sales_detals pd ON p.id = pd.id_invoice_code
            JOIN items i ON pd.id_item = i.id
            JOIN users u ON p.userid = u.id
            JOIN customers cus ON p.id_customer = cus.id
            LEFT JOIN delivery dy ON p.id_delivery = dy.id
            JOIN inventory s ON p.id_stock = s.id
            LEFT JOIN taxs t ON p.taxid = t.id
            LEFT JOIN taxs ti ON pd.taxid = ti.id
            ' || where_clause || '
            GROUP BY 
                p.id, p.invoice_code, p.date, p.status, p.type_dic, p.value_dic, 
                p.taxid, p.userid, p.id_customer, p.id_delivery, p.id_stock, 
                cus.name, cus.id, s.name, dy.name, u.name, t.type, t.value
            ORDER BY p.date DESC, p.id DESC
        ) t';

    -- تنفيذ الاستعلام
    IF array_length(args, 1) > 0 THEN
        CASE array_length(args, 1)
            WHEN 1 THEN EXECUTE sql_query INTO result_records USING args[1];
            WHEN 2 THEN EXECUTE sql_query INTO result_records USING args[1], args[2];
            WHEN 3 THEN EXECUTE sql_query INTO result_records USING args[1], args[2], args[3];
            WHEN 4 THEN EXECUTE sql_query INTO result_records USING args[1], args[2], args[3], args[4];
            ELSE EXECUTE sql_query INTO result_records;
        END CASE;
    ELSE
        EXECUTE sql_query INTO result_records;
    END IF;

    RETURN COALESCE(result_records, '[]'::json);
    
EXCEPTION
    WHEN others THEN
        RETURN json_build_object('error', SQLERRM, 'detail', SQLSTATE);
END;
$$;

DROP FUNCTION get_inv_details_return_sales(TEXT,TEXT,BOOLEAN);
CREATE OR REPLACE FUNCTION get_inv_details_return_sales(
  invoice_code TEXT,
  original_sales_id TEXT DEFAULT NULL,
  use_original_quantity BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  IF use_original_quantity AND original_sales_id IS NOT NULL THEN
    SELECT json_agg(row_to_json(t))
    INTO result
    FROM (
      SELECT 
        i.name AS name,
        i.id AS id,
        sd.qty AS itemqty,
        rsd.qty AS qtyback,
        rsd.qty AS qty,
        rsd.price AS price,
        rsd.sell AS sell,
        rsd.value_dic AS dis_value,
        rsd.type_dic AS dis_type,
        rsd.taxid AS taxid,
        rsd.unit_base_qty AS unit_base_qty,
        rsd.unit_name AS unit_name,
        ty.name AS tyname,
        rsd.expirydate,
        rsd.purchase_detail_id,
        rsd.barcode1,
        rsd.barcode2,
        rsd.barcode3,
        rsd.barcode4,
        rsd.barcode5,
        rsd.barcode6
      FROM return_sales_detals rsd
      JOIN items i ON rsd.id_item = i.id
      JOIN sales_detals sd ON rsd.id_item = sd.id_item 
        AND sd.id_invoice_code = original_sales_id
        AND (
          rsd.purchase_detail_id = sd.purchase_detail_id 
          OR rsd.purchase_detail_id IS NULL
        )
      LEFT JOIN type_items ty ON i.id_itemtype = ty.id
      WHERE rsd.id_invoice_code = invoice_code::INTEGER
    ) t;
  ELSE
    SELECT json_agg(row_to_json(t))
    INTO result
    FROM (
      SELECT 
        i.name AS name,
        i.id AS id,
        rsd.qty AS itemqty,
        rsd.qty AS qty,
        rsd.price AS price,
        rsd.sell AS sell,
        rsd.value_dic AS dis_value,
        rsd.type_dic AS dis_type,
        rsd.taxid AS taxid,
        ty.name AS tyname,
        rsd.expirydate,
        rsd.purchase_detail_id,
        rsd.barcode1,
        rsd.barcode2,
        rsd.barcode3,
        rsd.barcode4,
        rsd.barcode5,
        rsd.barcode6
      FROM return_sales_detals rsd
      JOIN items i ON rsd.id_item = i.id
      LEFT JOIN type_items ty ON i.id_itemtype = ty.id
      WHERE rsd.id_invoice_code = invoice_code::INTEGER
    ) t;
  END IF;
  
  RETURN COALESCE(result, '[]'::json);
END;
$$;

--55555555555555555555555555

ALTER TABLE sales_view_detals DROP CONSTRAINT sales_view_detals_id_invoice_code_fkey ;

ALTER TABLE batches DROP CONSTRAINT batches_purchase_detail_id_fkey;


ALTER TABLE ketchine_detals
ALTER COLUMN purchase_detail_id TYPE BIGINT;

ALTER TABLE return_purchase_detals
ALTER COLUMN purchase_detail_id TYPE BIGINT;

ALTER TABLE return_sales_detals
ALTER COLUMN purchase_detail_id TYPE BIGINT;

ALTER TABLE sales_detals
ALTER COLUMN purchase_detail_id TYPE BIGINT;

ALTER TABLE batches 
ALTER COLUMN purchase_detail_id TYPE BIGINT;

ALTER TABLE purchase_details
ALTER COLUMN id TYPE BIGINT;

ALTER TABLE purchase_details
ALTER COLUMN purchase_detail_id TYPE BIGINT;


ALTER TABLE sales_view ALTER COLUMN invoice_code TYPE TEXT;

ALTER TABLE sales_view_detals DROP CONSTRAINT sales_view_detals_id_invoice_code_fkey ;

INSERT INTO "pay_types" ("id","name","date","note","is_active") VALUES (1,'كاش',NULL,NULL,1);
INSERT INTO "pay_types" ("id","name","date","note","is_active") VALUES (2,'تحويل',NULL,NULL,1);
INSERT INTO "pay_types" ("id","name","date","note","is_active") VALUES (3,'بطاقة مصرفية',NULL,NULL,1);
INSERT INTO "country" ("id","name","is_active","date","userid","time") VALUES (0,'ليبيا',1,NULL,0,'');
INSERT INTO "customers" ("id","name","number_phone","cityid","countryid","address","is_active","date","userid","time") VALUES (0,'العميل العشوائي',NULL,NULL,NULL,NULL,1,NULL,0,NULL);
INSERT INTO "delivery" ("id","name","number_phone","address","userid","is_active","date","time") VALUES (1,'ihuijkhkj','0916545668',NULL,0,1,'2025-10-14_10:29:49 AM','١٠:٢٩:٤٩ ص');
INSERT INTO "inventory" ("id","name","userid","countryid","cityid","date","phoneNumber","adress","email","note") VALUES (0,'المخزن الرئيسي',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO "papers" ("id","name","width") VALUES (1,'A4',595.0);
INSERT INTO "papers" ("id","name","width") VALUES (2,'A5',420.0);
INSERT INTO "papers" ("id","name","width") VALUES (3,'Letter',612.0);
INSERT INTO "papers" ("id","name","width") VALUES (4,'POS (57mm)',162.0);
INSERT INTO "papers" ("id","name","width") VALUES (5,'POS (80mm)',210.0);
INSERT INTO "papers" ("id","name","width") VALUES (6,'POS (100mm)',283.0);
INSERT INTO "papers" ("id","name","width") VALUES (7,'POS (127mm)',356.0);
INSERT INTO "papers" ("id","name","width") VALUES (8,'POS (152mm)',426.0);

INSERT INTO symbols (
        id,
        currency_symbol,
cny,
country,
userid,
created_at

    ) VALUES (
        0,
        'د.ل',
'LYD',
'ليبيا',
        0,
            NOW()
    );


INSERT INTO "country" ("id","name","is_active","date","userid","time") VALUES (0,'ليبيا',1,NULL,0,'');
INSERT INTO "customers" ("id","name","number_phone","cityid","countryid","address","is_active","date","userid","time") VALUES (0,'العميل العشوائي',NULL,NULL,NULL,NULL,1,NULL,0,NULL);
INSERT INTO "delivery" ("id","name","number_phone","address","userid","is_active","date","time") VALUES (1,'ihuijkhkj','0916545668',NULL,0,1,'2025-10-14_10:29:49 AM','١٠:٢٩:٤٩ ص');
INSERT INTO "inventory" ("id","name","userid","countryid","cityid","date","phoneNumber","adress","email","note") VALUES (0,'المخزن الرئيسي',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (1,'طرابلس',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (2,'بنغازي',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (3,'مصراتة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (4,'سرت',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (5,'سبها',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (6,'طبرق',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (7,'أجدابيا',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (8,'البيضاء',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (9,'الخمس',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (10,'الزاوية',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (11,'المرج',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (12,'زليتن',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (13,'القطرون',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (14,'الكفرة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (15,'الأبرق',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (16,'الأصابعة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (17,'الساحل',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (18,'السدرة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (19,'الشويرف',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (20,'العجيلات',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (21,'القرة بوللي',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (22,'الماية',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (23,'المرادة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (24,'النوفلية',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (25,'الواحة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (26,'الجفارة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (27,'الجميل',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (28,'الرجبان',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (29,'الرقيبة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (30,'الزويتينة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (31,'الزنتان',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (32,'الزوية',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (33,'الشط',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (34,'الضبعة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (35,'القيقب',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (36,'المحجوب',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (37,'الرجبان',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (38,'الرقدال',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (39,'الرقيبة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (40,'السائح',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (41,'السبيعة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (42,'الضبعة',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (43,'القطرون',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (44,'القره بوللي',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (45,'القيقب',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (46,'الماية',1,NULL,'',0,0);
INSERT INTO "city" ("id","name","is_active","date","time","country_id","user_id") VALUES (47,'المرج',1,NULL,'',0,0);
INSERT INTO "citypay" ("id","name","is_active","date","price","country_id","city_id") VALUES (1,NULL,1,'2025-10-12_07:38:15 AM',20.0,0,1);
INSERT INTO "items_maincategory" ("id","name","is_active","userid","date","time") VALUES (1,'tsdfaddfg',1,0,'2025-11-17_03:24:49 AM','٠٣:٢٤:٤٩ ص');
INSERT INTO "items_maincategory" ("id","name","is_active","userid","date","time") VALUES (2,'uydgsfh',1,0,'2025-11-17_03:24:53 AM','٠٣:٢٤:٥٣ ص');






    INSERT INTO inventory (
        id,
        name,
userid,
created_at

    ) VALUES (
        0,
        'المخزن الرئيسي',
        0,
            NOW()
    );
 INSERT INTO customers (
        id,
        name,
        number_phone,
        cityid,
        countryid,
        address,
is_active,
userid,
date,
time,
created_at

    ) VALUES (
        0,
        'العميل الإفتراضي',
        000,
        null,
       null,
       'null',
1,
0,
'null',
'null',
        NOW()
    );

INSERT INTO "subcategory" ("id","name","maincategory_id","is_active","userid","date","time") VALUES (1,'fdgf',1,1,0,'2025-11-17_03:25:00 AM','٠٣:٢٥:٠٠ ص');
INSERT INTO "subcategory" ("id","name","maincategory_id","is_active","userid","date","time") VALUES (2,'outrsdf',1,1,0,'2025-11-17_03:25:06 AM','٠٣:٢٥:٠٦ ص');
INSERT INTO "subcategory" ("id","name","maincategory_id","is_active","userid","date","time") VALUES (3,'wredfghgjh',2,1,0,'2025-11-17_03:25:12 AM','٠٣:٢٥:١٢ ص');
INSERT INTO "subcategory" ("id","name","maincategory_id","is_active","userid","date","time") VALUES (4,'wrdtfghk',2,1,0,'2025-11-17_03:25:18 AM','٠٣:٢٥:١٨ ص');
INSERT INTO "subcategory" ("id","name","maincategory_id","is_active","userid","date","time") VALUES (5,'fsdfdgf',1,1,0,'2025-11-17_03:25:24 AM','٠٣:٢٥:٢٤ ص');
INSERT INTO "suppliers" ("id","name","number_phone","address","cityid","countryid","userid","is_active","date","time") VALUES (1,'يس',NULL,NULL,NULL,NULL,0,1,'2025-10-05_11:04:06 AM','AM');
INSERT INTO "symbols" ("id","currency_symbol","cny","country","date","time","userid","is_active") VALUES (1,'د.ل','LYD','ليبيا',NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (1,'عنصر',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (2,'صندوق',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (3,'كيلو',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (4,'لتر',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (5,'وحدة',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (6,'علبة',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (7,'قطعة',NULL,NULL,NULL,NULL,1);
INSERT INTO "type_items" ("id","name","note","date","time","userid","is_active") VALUES (8,'شاريط',NULL,NULL,NULL,NULL,1);
