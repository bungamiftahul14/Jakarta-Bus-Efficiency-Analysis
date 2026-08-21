# 🚌 End-to-End Public Transportation Efficiency Analysis (DKI Jakarta)

## 📌 Executive Summary
Proyek analisis data ini bertujuan untuk mengevaluasi kinerja operasional 17 terminal bus perkotaan di DKI Jakarta berbasis data transaksi riil (14.993 baris data). Menggunakan **20 Production Query SQL**, studi ini mengidentifikasi *supply-demand mismatch* masif (seperti krisis penumpukan di Terminal Manggarai dan Cililitan) serta merumuskan simulasi redistribusi operasional berbasis standar **40 penumpang/trip** tanpa memerlukan penambahan pengadaan operasional baru.

---

## 🎯 Key Findings
* **Macro Volume Traffic:** Total pergerakan mencapai **43,21 Juta Penumpang Berangkat** dan **34,76 Juta Penumpang Datang**, membuktikan Jakarta didominasi oleh pergerakan komuter harian.
* **Supply-Demand Mismatch:** Manggarai mencatatkan volume penumpang terbesar ke-2 (8,91 Juta), tetapi frekuensi operasional busnya berada di peringkat 16 dari 17 terminal (hanya 64,4 ribu pergerakan).
* **Prinsip Pareto 70/30:** **71,30% total beban penumpang** terpusat hanya pada 3 terminal utama (*Cililitan, Manggarai, dan Blok M*).
* **Pemborosan Operasional:** 5 terminal sekunder (seperti *Klender & Pasar Minggu*) mengalami underutilized ekstrem dengan rata-rata keterisian `< 5 penumpang/trip`.

---

## 💡 Strategic Recommendations
1. **Redistribusi Operasional:** Merelokasi surplus **138 trip/hari** dari Blok M serta mengalihkan alokasi perjalanan dari terminal sepi (Klender & Pasar Minggu) ke Manggarai (+216 trip) dan Cililitan (+231 trip).
2. **Surge Buffer Planning:** Menyiapkan protokol perjalanan cadangan pada periode lonjakan ekstrem (April-Mei) saat *load factor* menembus `>130 penumpang/trip`.
3. **Optimasi Feeder:** Penataan ulang rute *feeder* dari Terminal Gateway (Kampung Rambutan) langsung menuju Transit Hub.

---

## 🛠️ Tech Stack & Data Source
* **Database Engine:** MySQL Workbench 8.0 (Data Cleaning, Validation, Multi-table Aggregation, Time-Series & Simulation).
* **Data Visualization:** Microsoft Excel (Chart Formatting & Executive Slide Deck Presentation).
* **Data Source:** Official Open Data Portal — `satudata.jakarta.go.id`

---

**Author:** Bunga Miftahul Barokah  
**Repository:** Jakarta-Bus-Efficiency-Analysis
