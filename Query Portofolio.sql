-- 1. Buat Database
CREATE DATABASE db_transportasi_dki;
SELECT * FROM db_transportasi_dki;

-- 2. Berapa total baris data yang tersedia dalam database?
SELECT COUNT(*) AS total_baris_data
FROM db_transportasi_dki;

-- 3. Apakah terdapat data yang kosong (NULL) pada database?
SELECT 
    COUNT(*) AS total_baris,
    SUM(CASE WHEN periode_data IS NULL THEN 1 ELSE 0 END) AS null_periode,
    SUM(CASE WHEN tanggal IS NULL THEN 1 ELSE 0 END) AS null_tanggal,
    SUM(CASE WHEN terminal IS NULL THEN 1 ELSE 0 END) AS null_terminal,
    SUM(CASE WHEN jumlah_bus_datang IS NULL THEN 1 ELSE 0 END) AS null_bus_datang,
    SUM(CASE WHEN jumlah_penumpang_datang IS NULL THEN 1 ELSE 0 END) AS null_penumpang_datang,
    SUM(CASE WHEN jumlah_bus_berangkat IS NULL THEN 1 ELSE 0 END) AS null_bus_berangkat,
    SUM(CASE WHEN jumlah_penumpang_berangkat IS NULL THEN 1 ELSE 0 END) AS null_penumpang_berangkat
FROM db_transportasi_dki;

-- 4. Berapa banyak data yang bernilai 0 pada pencatatan bus dan penumpang?
SELECT 
    SUM(CASE WHEN jumlah_penumpang_datang = 0 THEN 1 ELSE 0 END) AS zero_penumpang_datang,
    SUM(CASE WHEN jumlah_penumpang_berangkat = 0 THEN 1 ELSE 0 END) AS zero_penumpang_berangkat,
    SUM(CASE WHEN jumlah_bus_datang = 0 THEN 1 ELSE 0 END) AS zero_bus_datang,
    SUM(CASE WHEN jumlah_bus_berangkat = 0 THEN 1 ELSE 0 END) AS zero_bus_berangkat
FROM db_transportasi_dki;

-- 5. Membuat tabel data bersih terstandarisasi
DROP TABLE IF EXISTS arus_terminal_clean;
CREATE TABLE arus_terminal_clean AS
SELECT 
    periode_data,
    -- Membentuk format tanggal standar (YYYY-MM-DD)
    STR_TO_DATE(CONCAT(LEFT(periode_data, 4), '-', RIGHT(periode_data, 2), '-', LPAD(tanggal, 2, '0')), '%Y-%m-%d') AS tanggal_lengkap,
    -- Standarisasi nama terminal menjadi huruf kecil dan rapi
    LOWER(TRIM(terminal)) AS nama_terminal,
    jumlah_bus_datang,
    COALESCE(jumlah_penumpang_datang, 0) AS jumlah_penumpang_datang,
    jumlah_bus_berangkat,
    jumlah_penumpang_berangkat,
    -- Total penumpang harian
    (COALESCE(jumlah_penumpang_datang, 0) + jumlah_penumpang_berangkat) AS total_penumpang_harian
FROM db_transportasi_dki;
-- Cek hasil tabel bersih
SELECT * FROM arus_terminal_clean LIMIT 10;

-- 6. Berapa total keseluruhan akumulasi bus dan penumpang di seluruh wilayah DKI Jakarta?
SELECT 
    SUM(jumlah_bus_datang) AS total_bus_datang,
    SUM(jumlah_bus_berangkat) AS total_bus_berangkat,
    SUM(jumlah_penumpang_datang) AS total_penumpang_datang,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang_berangkat
FROM arus_terminal_clean;

-- 7. Terminal mana yang melayani jumlah keberangkatan penumpang terbanyak?
SELECT 
    nama_terminal,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang_berangkat
FROM arus_terminal_clean
GROUP BY nama_terminal
ORDER BY total_penumpang_berangkat DESC;

-- 8. Terminal mana yang menerima kedatangan penumpang terbanyak?
SELECT 
    nama_terminal,
    SUM(jumlah_penumpang_datang) AS total_penumpang_datang
FROM arus_terminal_clean
GROUP BY nama_terminal
ORDER BY total_penumpang_datang DESC;

-- 9. Terminal mana yang memiliki lalu lintas bus paling sibuk?
SELECT 
    nama_terminal,
    SUM(jumlah_bus_datang) AS total_bus_datang,
    SUM(jumlah_bus_berangkat) AS total_bus_berangkat,
    (SUM(jumlah_bus_datang) + SUM(jumlah_bus_berangkat)) AS total_lalu_lintas_bus
FROM arus_terminal_clean
GROUP BY nama_terminal
ORDER BY total_lalu_lintas_bus DESC;

-- 10. Bagaimana perbandingan antara arus penumpang datang dan berangkat di setiap terminal (Analisis Neto Arus)?
SELECT 
    nama_terminal,
    SUM(jumlah_penumpang_datang) AS total_datang,
    SUM(jumlah_penumpang_berangkat) AS total_berangkat,
    (SUM(jumlah_penumpang_berangkat) - SUM(jumlah_penumpang_datang)) AS selisih_neto
FROM arus_terminal_clean
GROUP BY nama_terminal
ORDER BY selisih_neto DESC;

-- 11.  Bagaimana tren perkembangan volume penumpang dan armada bus bulanan di Seluruh DKI Jakarta?
SELECT 
    LEFT(periode_data, 4) AS tahun,
    RIGHT(periode_data, 2) AS bulan,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang_berangkat,
    SUM(jumlah_bus_berangkat) AS total_bus_berangkat
FROM arus_terminal_clean
GROUP BY tahun, bulan
ORDER BY tahun ASC, bulan ASC;

-- 12. Terminal mana saja yang volume penumpangnya berada di atas rata-rata terminal di DKI Jakarta?
WITH total_per_terminal AS (
    SELECT 
        nama_terminal,
        SUM(jumlah_penumpang_berangkat) AS total_penumpang
    FROM arus_terminal_clean
    GROUP BY nama_terminal
)
SELECT 
    nama_terminal,
    total_penumpang
FROM total_per_terminal
WHERE total_penumpang > (SELECT AVG(total_penumpang) FROM total_per_terminal)
ORDER BY total_penumpang DESC;

-- 13. Pada tanggal berapa saja terjadi lonjakan penumpang paling ekstrem yang berpotensi 
-- menyebabkan penumpukan/kematian arus lalu lintas di terminal?
SELECT 
    tanggal_lengkap,
    nama_terminal,
    jumlah_bus_berangkat,
    jumlah_penumpang_berangkat,
    ROUND(jumlah_penumpang_berangkat / NULLIF(jumlah_bus_berangkat, 0), 1) AS kepadatan_harian_per_bus
FROM arus_terminal_clean
ORDER BY jumlah_penumpang_berangkat DESC
LIMIT 5;

-- 14. Bagaimana perbandingan rata-rata harian penumpang & bus antara Hari Kerja (Mon-Fri) dan Akhir Pekan (Sat-Sun)?
SELECT 
    CASE 
        WHEN DAYOFWEEK(tanggal_lengkap) IN (1, 7) THEN 'Weekend (Sabtu-Minggu)'
        ELSE 'Weekday (Senin-Jumat)'
    END AS tipe_hari,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang,
    ROUND(AVG(jumlah_penumpang_berangkat), 0) AS rata_penumpang_harian,
    ROUND(AVG(jumlah_bus_berangkat), 0) AS rata_bus_harian
FROM arus_terminal_clean
GROUP BY tipe_hari;

-- 15. Terminal mana yang mengalami beban muatan berlebih (Overloaded) dan 
-- terminal mana yang sepi/kurang dimanfaatkan (Underutilized)?
SELECT 
    nama_terminal,
    ROUND(SUM(jumlah_penumpang_datang) / NULLIF(SUM(jumlah_bus_datang), 0), 1) AS rasio_penumpang_datang_per_bus,
    ROUND(SUM(jumlah_penumpang_berangkat) / NULLIF(SUM(jumlah_bus_berangkat), 0), 1) AS rasio_penumpang_berangkat_per_bus
FROM arus_terminal_clean
GROUP BY nama_terminal
ORDER BY rasio_penumpang_berangkat_per_bus DESC;

-- 16. Bagaimana pertumbuhan total volume penumpang angkutan umum dari tahun 2024 hingga 2026?
SELECT 
    LEFT(periode_data, 4) AS tahun,
    SUM(jumlah_bus_berangkat) AS total_armada_bus,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang_berangkat
FROM arus_terminal_clean
GROUP BY tahun
ORDER BY tahun ASC;

-- 17. Evaluasi Pemborosan Operasional: Terminal mana saja yang lalu lintas busnya tinggi tetapi sepi penumpang?
SELECT 
    nama_terminal,
    SUM(jumlah_bus_berangkat) AS total_bus_berangkat,
    SUM(jumlah_penumpang_berangkat) AS total_penumpang_berangkat,
    ROUND(SUM(jumlah_penumpang_berangkat) / NULLIF(SUM(jumlah_bus_berangkat), 0), 1) AS rata_penumpang_per_bus
FROM arus_terminal_clean
GROUP BY nama_terminal
HAVING rata_penumpang_per_bus < 5
ORDER BY total_bus_berangkat DESC;

-- 18. Berapa persentase kontribusi penumpang keberangkatan di masing-masing terminal?
WITH total_keseluruhan AS (
    SELECT SUM(jumlah_penumpang_berangkat) AS grand_total FROM arus_terminal_clean
)
SELECT 
    a.nama_terminal,
    SUM(a.jumlah_penumpang_berangkat) AS total_penumpang,
    ROUND((SUM(a.jumlah_penumpang_berangkat) / t.grand_total) * 100, 2) AS persentase_kontribusi
FROM arus_terminal_clean a, total_keseluruhan t
GROUP BY a.nama_terminal, t.grand_total
ORDER BY total_penumpang DESC;

-- 19. Seberapa besar penumpukan penumpang terpusat di terminal utama?
WITH total_keseluruhan AS (
    SELECT SUM(jumlah_penumpang_berangkat) AS grand_total FROM arus_terminal_clean
),
top3_terminal AS (
    SELECT SUM(jumlah_penumpang_berangkat) AS top3_total 
    FROM (
        SELECT SUM(jumlah_penumpang_berangkat) AS jumlah_penumpang_berangkat
        FROM arus_terminal_clean
        GROUP BY nama_terminal
        ORDER BY jumlah_penumpang_berangkat DESC
        LIMIT 3
    ) AS sub
)
SELECT 
    top3_total,
    grand_total,
    ROUND((top3_total / grand_total) * 100, 2) AS persentase_penumpukan
FROM top3_terminal, total_keseluruhan;

-- 20. Evaluasi Peramalan Anggaran & Armada (Resource Allocation for Next Season)
SELECT 
    nama_terminal,
    ROUND(AVG(jumlah_penumpang_berangkat), 0) AS rata_penumpang_harian,
    ROUND(AVG(jumlah_bus_berangkat), 0) AS armada_bus_harian_eksisting,
    ROUND(AVG(jumlah_penumpang_berangkat) / 40, 0) AS estimasi_kebutuhan_bus_ideal
FROM arus_terminal_clean
WHERE nama_terminal IN ('cililitan', 'manggarai', 'blok m')
GROUP BY nama_terminal;