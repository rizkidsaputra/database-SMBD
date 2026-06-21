USE db_sipaketnyata;

DROP VIEW IF EXISTS v_status_pengiriman_publik;
DROP VIEW IF EXISTS v_ringkasan_invoice_keuangan;

CREATE VIEW v_status_pengiriman_publik AS
SELECT
  p.no_resi,
  p.nama_penerima,
  p.alamat_penerima_kabupaten,
  p.alamat_penerima_provinsi,
  lp.`timestamp`,
  lp.status_pengiriman
FROM paket p
JOIN log_pelacakan lp ON lp.no_resi = p.no_resi;

CREATE VIEW v_ringkasan_invoice_keuangan AS
SELECT
  i.id_invoice,
  i.no_resi,
  p.no_identitas,
  i.total_biaya_kotor,
  i.nilai_potongan_aktual,
  i.total_bayar_bersih,
  i.status_pembayaran,
  i.tanggal_terbit,
  i.jatuh_tempo
FROM invoice i
JOIN paket p ON p.no_resi = i.no_resi;

DROP USER IF EXISTS
  'rizki_owner'@'localhost',
  'hafiz_koordinator'@'localhost',
  'sheren_keuangan'@'localhost',
  'jonatannael_kurir'@'localhost';

DROP ROLE IF EXISTS
  'role_super_admin',
  'role_operasional',
  'role_keuangan',
  'role_kurir';

CREATE ROLE 'role_super_admin';
CREATE ROLE 'role_operasional';
CREATE ROLE 'role_keuangan';
CREATE ROLE 'role_kurir';

-- Password berikut hanya password demo untuk kebutuhan praktikum.
-- Ganti password sebelum digunakan pada database produksi.
CREATE USER 'rizki_owner'@'localhost' IDENTIFIED BY 'OwnerDemo_2026!';
CREATE USER 'hafiz_koordinator'@'localhost' IDENTIFIED BY 'OpsDemo_2026!';
CREATE USER 'sheren_keuangan'@'localhost' IDENTIFIED BY 'FinanceDemo_2026!';
CREATE USER 'jonatannael_kurir'@'localhost' IDENTIFIED BY 'CourierDemo_2026!';

-- Role super admin: akses penuh ke seluruh database.
GRANT ALL PRIVILEGES ON db_sipaketnyata.* TO 'role_super_admin';

-- Role operasional: mengelola paket dan pelacakan, tetapi tidak mengubah invoice.
GRANT SELECT, INSERT, UPDATE ON db_sipaketnyata.paket TO 'role_operasional';
GRANT SELECT, INSERT, UPDATE ON db_sipaketnyata.log_pelacakan TO 'role_operasional';
GRANT SELECT, INSERT ON db_sipaketnyata.detail_transit TO 'role_operasional';
GRANT SELECT ON db_sipaketnyata.pelanggan TO 'role_operasional';
GRANT SELECT ON db_sipaketnyata.layanan TO 'role_operasional';
GRANT SELECT ON db_sipaketnyata.gudang TO 'role_operasional';

-- Role keuangan: hanya melihat ringkasan invoice dan mencatat pembayaran.
GRANT SELECT ON db_sipaketnyata.v_ringkasan_invoice_keuangan TO 'role_keuangan';
GRANT SELECT, INSERT ON db_sipaketnyata.pembayaran TO 'role_keuangan';

-- Role kurir: hanya melihat status pengiriman publik dan menambah log pelacakan.
GRANT SELECT ON db_sipaketnyata.v_status_pengiriman_publik TO 'role_kurir';
GRANT INSERT ON db_sipaketnyata.log_pelacakan TO 'role_kurir';

-- Pemberian role ke user.
GRANT 'role_super_admin' TO 'rizki_owner'@'localhost';
GRANT 'role_operasional' TO 'hafiz_koordinator'@'localhost';
GRANT 'role_keuangan' TO 'sheren_keuangan'@'localhost';
GRANT 'role_kurir' TO 'jonatannael_kurir'@'localhost';

SET DEFAULT ROLE 'role_super_admin' TO 'rizki_owner'@'localhost';
SET DEFAULT ROLE 'role_operasional' TO 'hafiz_koordinator'@'localhost';
SET DEFAULT ROLE 'role_keuangan' TO 'sheren_keuangan'@'localhost';
SET DEFAULT ROLE 'role_kurir' TO 'jonatannael_kurir'@'localhost';

-- Owner memberi akses tambahan ke koordinator dengan GRANT OPTION.
-- Artinya koordinator boleh meneruskan sebagian akses operasional ke user lain.
GRANT SELECT, INSERT, UPDATE
ON db_sipaketnyata.log_pelacakan
TO 'hafiz_koordinator'@'localhost'
WITH GRANT OPTION;

GRANT SELECT
ON db_sipaketnyata.v_status_pengiriman_publik
TO 'hafiz_koordinator'@'localhost'
WITH GRANT OPTION;

-- Keuangan hanya diberi akses kolom tertentu pada tabel invoice.
-- Ini contoh pengamanan di level kolom.
GRANT SELECT (
  id_invoice,
  no_resi,
  total_biaya_kotor,
  nilai_potongan_aktual,
  total_bayar_bersih,
  status_pembayaran
)
ON db_sipaketnyata.invoice
TO 'sheren_keuangan'@'localhost';

FLUSH PRIVILEGES;
