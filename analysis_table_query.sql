-- Query 1: Create analysis_table
-- Query pertama menggabungkan tabel-tabel dari dataset yang disediakan sesuai ketentuan dan keperluan challenge.
CREATE TABLE rakamin-kf-analytics-448909.kimia_farma.analysis_table AS
SELECT
    t1.transaction_id,                   -- Kode id transaksi
    t1.date,                             -- Tanggal transaksi dilakukan
    t1.branch_id,                        -- Kode id cabang Kimia Farma
    t1.customer_name,                    -- Nama customer yang melakukan transaksi
    t2.branch_name,                      -- Nama kantor cabang Kimia Farma
    t2.kota,                             -- Kota cabang Kimia Farma
    t2.provinsi  ,                       -- Provinsi cabang Kimia Farma
    t2.rating AS rating_cabang,          -- Penilaian konsumen terhadap cabang Kimia Farma
    t1.product_id,                       -- Kode product obat
    t3.product_name,                     -- Nama obat
    t1.price AS actual_price,            -- Harga obat,
    t1.discount_percentage,              -- Persentase diskon yang diberikan pada obat
    t4.opname_stock,                     -- Jumlah stok produk obat
    
    -- Perhitungan persentase_gross_laba
    CASE
      WHEN t1.price <= 50000 THEN 0.10                        -- laba 10%
      WHEN t1.price > 50000 AND t1.price <= 100000 THEN 0.15  -- laba 15%
      WHEN t1.price > 100000 AND t1.price <= 300000 THEN 0.20 -- laba 20%
      WHEN t1.price > 300000 AND t1.price <= 500000 THEN 0.25 -- laba 25%
      WHEN t1.price > 500000 THEN 0.30                        -- laba 30%
      ELSE NULL
    END AS persentase_gross_laba,        -- Persentase laba yang seharusnya diterima dari obat
    
    -- Perhitungan nett_sales
    t1.price * (1 - t1.discount_percentage) AS nett_sales, -- Harga setelah diskon
    
    -- Perhitungan nett_profit
    CASE
      WHEN t1.price IS NOT NULL THEN t1.price * (1 - t1.discount_percentage) *
        CASE
          WHEN t1.price <= 50000 THEN 0.10                        -- laba 10%
          WHEN t1.price > 50000 AND t1.price <= 100000 THEN 0.15  -- laba 15%
          WHEN t1.price > 100000 AND t1.price <= 300000 THEN 0.20 -- laba 20%
          WHEN t1.price > 300000 AND t1.price <= 500000 THEN 0.25 -- laba 25%
          WHEN t1.price > 500000 THEN 0.30                        -- laba 30%
          ELSE NULL
        END
      ELSE NULL
    END AS nett_profit,                -- Keuntungan yang diperoleh Kimia Farma
    
    t1.rating AS rating_transaksi      -- Penilaian konsumen terhadap transaksi yang dilakukan.

FROM
    rakamin-kf-analytics-448909.kimia_farma.kf_final_transaction t1
JOIN
    rakamin-kf-analytics-448909.kimia_farma.kf_kantor_cabang t2 -- Join tabel kf_final_transaction dengan kf_kantor_cabang
ON
    t1.branch_id = t2.branch_id
JOIN
    rakamin-kf-analytics-448909.kimia_farma.kf_product t3       -- Join tabel kf_final_transaction dengan kf_product
ON
    t1.product_id = t3.product_id
JOIN
    rakamin-kf-analytics-448909.kimia_farma.kf_inventory t4     -- Join tabel kf_final_transaction dengan kf_inventory
ON 
    t1.branch_id = t4.branch_id AND t1.product_id = t4.product_id;

-- Query 2: Menambahkan ranking provinsi ke tabel analysis_table
-- Query menambahkan kolom province_average_ratings_rank ke tabel analysis_table berdasarkan rata-rata rating_transaksi provinsi
CREATE OR REPLACE TABLE rakamin-kf-analytics-448909.kimia_farma.analysis_table AS
WITH ranked_provinces AS (
  SELECT
    provinsi,
    -- Memberi Rank pada provinsi berdasarkan rata-rata rating provinsi
    RANK() OVER (ORDER BY AVG(transaction_ratings) DESC) AS province_average_ratings_rank
  FROM 
    rakamin-kf-analytics-448909.kimia_farma.analysis_table
  GROUP BY 
    provinsi
)
SELECT 
  t1.*,                                  -- Pilih semua kolom dari tabel analysis_table
  t2.province_average_ratings_rank       -- Menambahkan kolom province_average_ratings_rank
FROM 
  rakamin-kf-analytics-448909.kimia_farma.analysis_table t1
JOIN 
  ranked_provinces t2 ON t1.provinsi = t2.provinsi;    -- Join analysis_table dengan ranked_provinces
