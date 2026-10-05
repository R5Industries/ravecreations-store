-- RAVE Creations sample catalog (dev/demo data, not run by migrations).
-- Re-runnable: every insert is a no-op if the slug already exists.
--   local:   npx wrangler d1 execute DB --local --file=./rave/seed.sql
--   images:  bash rave/seed-images.sh   (uploads rave/seed/images/* to local R2)
-- Product photos are neon placeholders — replace them in Admin → Media / Products.

-- ── Categories (slugs match the marketing site's /shop collection links) ──────
INSERT INTO categories (name, slug)
SELECT 'Romantic Florals', 'romantic-florals' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'romantic-florals');
INSERT INTO categories (name, slug)
SELECT 'Midnight & Jewel', 'midnight-and-jewel' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'midnight-and-jewel');
INSERT INTO categories (name, slug)
SELECT 'Color Pop Favorites', 'color-pop-favorites' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'color-pop-favorites');

-- ── Products (price_cents $38–$48; weight_grams ≈ packed bracelet) ───────────
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Blush Peony Silk Cuff', 'blush-peony-silk-cuff',
  'A soft, romantic cuff of upcycled blush silk with hand-stitched ribbon peonies. Featherlight, adjustable, and made one at a time in Phoenix.',
  4400, 12, 'products/seed-blush-peony-silk-cuff.webp', 40
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'blush-peony-silk-cuff');
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Wild Rose Ribbon Bracelet', 'wild-rose-ribbon-bracelet',
  'Deep rose ribbon florals layered over vintage silk. A little romantic, a little rebellious.',
  3800, 15, 'products/seed-wild-rose-ribbon-bracelet.webp', 35
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'wild-rose-ribbon-bracelet');
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Midnight Orchid Wrap Bracelet', 'midnight-orchid-wrap-bracelet',
  'Inky violet silk wrapped twice around the wrist and finished with a glowing orchid bead cluster.',
  4600, 10, 'products/seed-midnight-orchid-wrap-bracelet.webp', 45
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'midnight-orchid-wrap-bracelet');
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Sapphire Jewel Silk Cuff', 'sapphire-jewel-silk-cuff',
  'Sapphire-blue upcycled silk with faceted jewel accents. Made to catch the lights after dark.',
  4800, 8, 'products/seed-sapphire-jewel-silk-cuff.webp', 42
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'sapphire-jewel-silk-cuff');
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Neon Sunset Stack Set', 'neon-sunset-stack-set',
  'Three stackable silk bracelets in magenta, cyan and sunshine yellow. Wear them together or mix them in.',
  4200, 20, 'products/seed-neon-sunset-stack-set.webp', 60
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'neon-sunset-stack-set');
INSERT INTO products (name, slug, description, price_cents, stock, image_key, weight_grams)
SELECT 'Electric Citrus Silk Bracelet', 'electric-citrus-silk-bracelet',
  'Bright citrus and aqua silk, braided for all-day comfort. Pure festival energy.',
  4000, 18, 'products/seed-electric-citrus-silk-bracelet.webp', 32
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'electric-citrus-silk-bracelet');

-- ── Category membership ──────────────────────────────────────────────────────
INSERT OR IGNORE INTO product_categories (product_id, category_id)
SELECT p.id, c.id FROM products p JOIN categories c
  ON (c.slug = 'romantic-florals'    AND p.slug IN ('blush-peony-silk-cuff', 'wild-rose-ribbon-bracelet'))
  OR (c.slug = 'midnight-and-jewel'  AND p.slug IN ('midnight-orchid-wrap-bracelet', 'sapphire-jewel-silk-cuff'))
  OR (c.slug = 'color-pop-favorites' AND p.slug IN ('neon-sunset-stack-set', 'electric-citrus-silk-bracelet'));

-- ── Gallery images + media library rows (objects are uploaded by seed:images) ─
INSERT INTO product_images (product_id, image_key, position, alt)
SELECT p.id, p.image_key, 0, p.name || ' — placeholder photo' FROM products p
WHERE p.image_key LIKE 'products/seed-%'
  AND NOT EXISTS (SELECT 1 FROM product_images i WHERE i.product_id = p.id AND i.image_key = p.image_key);

INSERT INTO media (image_key, original_name, mime_type, size_bytes, width, height)
SELECT p.image_key, replace(p.image_key, 'products/', ''), 'image/webp', NULL, 800, 800 FROM products p
WHERE p.image_key LIKE 'products/seed-%'
  AND NOT EXISTS (SELECT 1 FROM media m WHERE m.image_key = p.image_key);

-- Fixture normalization: give every seeded row a valid public_id so the
-- public serializers (which refuse to emit rows without one) work out of the
-- box. Hex chars are a subset of the Crockford base32 alphabet, so
-- 10 hex chars is a valid token. Real production data is backfilled by
-- scripts/backfill-public-ids.mjs with the Web Crypto generator instead.
UPDATE products         SET public_id = 'prod_' || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE product_variants SET public_id = 'var_'  || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE product_extras   SET public_id = 'xtra_' || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE categories       SET public_id = 'cat_'  || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE pages            SET public_id = 'page_' || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE media            SET public_id = 'med_'  || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE product_images   SET public_id = 'pimg_' || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
UPDATE menu_items       SET public_id = 'nav_'  || lower(substr(hex(randomblob(10)),1,10)) WHERE public_id IS NULL;
