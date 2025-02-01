# Kimia Farma Big Data Analytics Project Based Internship Program Final Task: Performance Analytics Kimia Farma Business Year 2020-2023

## Overview
Project ini merupakan bagian dari tugas Big Data Analytics Intern di Kimia Farma untuk mengevaluasi kinerja bisnis perusahaan periode 2020-2023.

## Dataset
### kf_final_transaction.csv (https://drive.google.com/file/d/1iDOBdKZ4-kkLhpklQWWrsFvACtI7MCz3/view?usp=sharing)
* transaction_id: kode id transaksi, 
* product_id : kode produk obat, 
* branch_id: kode id cabang Kimia Farma, 
* customer_name: nama customer yang melakukan transaksi, 
* date: tanggal transaksi dilakukan, 
* price: harga obat, 
* discount_percentage: Persentase diskon yang diberikan pada obat, 
* rating: penilaian konsumen terhadap transaksi yang dilakukan.
### kf_product.csv (https://drive.google.com/file/d/1739wO7BwtVStHCA4Dcj9xGhlc_blBNbT/view?usp=sharing)
* product_id: kode produk obat, 
* product_name: nama produk obat, 
* product_category: kategori produk obat, 
* price: harga obat
### kf_inventory.csv (https://drive.google.com/file/d/1ihtG2t0V1AO0IAGkGwQaqtba6AxDEKDI/view?usp=sharing)
* inventory_ID: kode inventory produk obat,
* branch_id: kode id cabang Kimia Farma,
* product_id: kode id produk obat,
* product_name: nama produk obat,
* opname_stock: jumlah stok produk obat.
### kf_kantor_cabang.csv (https://drive.google.com/file/d/1vzaasqIeXqqe_jI99dNLaa8nxnoe9OWW/view?usp=sharing)
* branch_id: kode id cabang Kimia Farma,
* branch_category: kategori cabang Kimia Farma,
* branch_name: nama kantor cabang Kimia Farma,
* kota: kota cabang Kimia Farma,
* provinsi: provinsi cabang Kimia Farma,
* rating: penilaian konsumen terhadap cabang Kimia Farma

## Project Challenges
### 1. Data Import
Challenge pertama dalam proyek ini adalah mengimpor empat dataset yang telah disediakan. Berikut adalah tahap-tahap yang dilakukan untuk challenge ini:
1. Download dataset dari link yang telah disediakan,
2. Klik “Create dataset” pada proyek di BigQuery, lalu masukan Daset ID sebelum menekan tombol “Create Dataset”.,
3. Klik “Create table” pada dataset, lalu klik “Create table from” dan pilih “Upload” pada dropdown “Create table from”,
4. Pilih data yang ingin di-upload (File Format akan berubah secara otomatis) dan beri nama pada tabel, lalu tekan “Create Table”.

### 2. Tabel Analisa
Untuk memudahkan analisa, tabel-tabel yang telah diimpor digabungkan menjadi satu tabel yang tidak hanya berisi kolom-kolom tabel yang digabungkan, tetapi juga kolom yang berisi hasil dari kalkulasi kolom-kolom tersebut. Hal ini dicapai dengan melakukan JOIN terhadap tabel-tabel.
Berikut adalah kolom-kolom pada tabel analisa yang dibutuhkan untuk memenuhi challenge:
* transaction_id : kode id transaksi, 
* date : tanggal transaksi dilakukan, 
* branch_id : kode id cabang Kimia Farma, 
* branch_name : nama cabang Kimia Farma, 
* kota : kota cabang Kimia Farma, 
* provinsi : provinsi cabang Kimia Farma,
* rating_cabang : penilaian konsumen terhadap cabang Kimia Farma
* customer_name : Nama customer yang melakukan transaksi,
* product_id : kode product obat,
* product_name : nama obat, 
* actual_price : harga obat, 
* discount_percentage : Persentase diskon yang diberikan pada obat, 
* persentase_gross_laba : Persentase laba yang seharusnya diterima dari obat dengan ketentuan berikut:
    - Harga <= Rp 50.000 -> laba 10%
    - Harga > Rp 50.000 - 100.000 -> laba 15%
    - Harga > Rp 100.000 - 300.000 -> laba 20%
    - Harga > Rp 300.000 - 500.000 -> laba 25%
    - Harga > Rp 500.000 -> laba 30%,
* nett_sales : harga setelah diskon, didapatkan dengan dengan ketentuan berikut: actual_price * (100% - discount_percentage)
* nett_profit : keuntungan yang diperoleh Kimia Farma, didapatkan dengan ketentuan berikut: nett_sales * persentase_gross_laba
* rating_transaksi : penilaian konsumen terhadap transaksi yang dilakukan.

Terdapat juga dua kolom yang tidak termasuk kolom-kolom mandatory, yaitu:
* province_average_transaction_rank: ranking provinsi berdasarkan rata-rata rating_transaksi pada provinsi tersebut. (untuk memenuhi salah satu challenge ke-3. "Top 5 Cabang Dengan Rating Tertinggi, namun Rating Transaksi Terendah")

#### SQL Query
```
-- Query 1: Create analysis_table
-- Query pertama menggabungkan tabel-tabel dari dataset yang disediakan sesuai ketentuan dan keperluan challenge.
CREATE OR REPLACE TABLE rakamin-kf-analytics-448909.kimia_farma.analysis_table AS
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
    t1.product_id = t3.product_id;

-- Query 2: Menambahkan ranking provinsi ke tabel analysis_table
-- Query menambahkan kolom province_average_ratings_rank ke tabel analysis_table berdasarkan rata-rata rating_transaksi provinsi
CREATE OR REPLACE TABLE rakamin-kf-analytics-448909.kimia_farma.analysis_table AS
WITH ranked_provinces AS (
  SELECT
    provinsi,
    -- Memberi Rank pada provinsi berdasarkan rata-rata rating provinsi
    RANK() OVER (ORDER BY AVG(rating_transaksi) DESC) AS province_average_ratings_rank
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
  ranked_provinces t2
ON 
  t1.provinsi = t2.provinsi;

### 3. Dashboard
