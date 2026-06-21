CREATE DATABASE IF NOT EXISTS db_sipaketnyata
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE db_sipaketnyata;

SET NAMES utf8mb4;

DROP TRIGGER IF EXISTS trg_paket_bi;
DROP TRIGGER IF EXISTS trg_paket_bu;
DROP TRIGGER IF EXISTS trg_invoice_bi;
DROP TRIGGER IF EXISTS trg_invoice_bu;
DROP TRIGGER IF EXISTS trg_pakai_promo_ai;
DROP TRIGGER IF EXISTS trg_pakai_promo_au;
DROP TRIGGER IF EXISTS trg_pakai_promo_ad;
DROP TRIGGER IF EXISTS trg_ulasan_bi;
DROP TRIGGER IF EXISTS trg_ulasan_bu;
DROP FUNCTION IF EXISTS hitung_jarak_km;

DROP TABLE IF EXISTS detail_transit;
DROP TABLE IF EXISTS ulasan;
DROP TABLE IF EXISTS pakai_promo;
DROP TABLE IF EXISTS pembayaran;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS log_pelacakan;
DROP TABLE IF EXISTS gudang;
DROP TABLE IF EXISTS paket;
DROP TABLE IF EXISTS promo;
DROP TABLE IF EXISTS layanan;
DROP TABLE IF EXISTS pelanggan;

CREATE TABLE pelanggan (
  no_identitas            VARCHAR(30)  NOT NULL,
  nama_pelanggan          VARCHAR(100) NOT NULL,
  no_telepon              VARCHAR(20)  NOT NULL,
  alamat_jalan            VARCHAR(255) NOT NULL,
  alamat_kecamatan        VARCHAR(100) NOT NULL,
  alamat_kabupaten        VARCHAR(100) NOT NULL,
  alamat_provinsi         VARCHAR(100) NOT NULL,
  alamat_kodePos          VARCHAR(10)  NOT NULL,
  PRIMARY KEY (no_identitas),
  CONSTRAINT chk_pelanggan_kodepos CHECK (alamat_kodePos REGEXP '^[0-9]{5,10}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE layanan (
  id_layanan              VARCHAR(20) NOT NULL,
  nama_layanan            VARCHAR(100) NOT NULL,
  tarif_dasar_per_kg      DECIMAL(12,2) NOT NULL,
  tarif_dasar_per_km      DECIMAL(12,2) NOT NULL,
  estimasi_waktu          VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_layanan),
  UNIQUE KEY uq_layanan_nama (nama_layanan),
  CONSTRAINT chk_layanan_tarif_kg CHECK (tarif_dasar_per_kg >= 0),
  CONSTRAINT chk_layanan_tarif_km CHECK (tarif_dasar_per_km >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE paket (
  no_resi                     VARCHAR(30)  NOT NULL,
  no_identitas                VARCHAR(30)  NOT NULL,
  id_layanan                  VARCHAR(20) NOT NULL,
  berat                       DECIMAL(10,2) NOT NULL,
  panjang                     DECIMAL(10,2) NOT NULL,
  lebar                       DECIMAL(10,2) NOT NULL,
  tinggi                      DECIMAL(10,2) NOT NULL,
  jenis_barang                VARCHAR(100) NOT NULL,
  nilai_deklarasi             DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  nama_penerima               VARCHAR(100) NOT NULL,
  no_telepon_penerima         VARCHAR(20)  NOT NULL,
  alamat_penerima_jalan       VARCHAR(255) NOT NULL,
  alamat_penerima_kecamatan   VARCHAR(100) NOT NULL,
  alamat_penerima_kabupaten   VARCHAR(100) NOT NULL,
  alamat_penerima_provinsi    VARCHAR(100) NOT NULL,
  alamat_penerima_kodePos     VARCHAR(10)  NOT NULL,
  latitude_asal               DECIMAL(10,7) NOT NULL,
  longitude_asal              DECIMAL(10,7) NOT NULL,
  latitude_tujuan             DECIMAL(10,7) NOT NULL,
  longitude_tujuan            DECIMAL(10,7) NOT NULL,
  jarak_km                    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (no_resi),
  KEY idx_paket_no_identitas (no_identitas),
  KEY idx_paket_id_layanan (id_layanan),
  CONSTRAINT fk_paket_pelanggan
    FOREIGN KEY (no_identitas) REFERENCES pelanggan(no_identitas)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_paket_layanan
    FOREIGN KEY (id_layanan) REFERENCES layanan(id_layanan)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_paket_berat CHECK (berat > 0),
  CONSTRAINT chk_paket_panjang CHECK (panjang > 0),
  CONSTRAINT chk_paket_lebar CHECK (lebar > 0),
  CONSTRAINT chk_paket_tinggi CHECK (tinggi > 0),
  CONSTRAINT chk_paket_nilai_deklarasi CHECK (nilai_deklarasi >= 0),
  CONSTRAINT chk_paket_kodepos_tujuan CHECK (alamat_penerima_kodePos REGEXP '^[0-9]{5,10}$'),
  CONSTRAINT chk_paket_lat_asal CHECK (latitude_asal BETWEEN -90 AND 90),
  CONSTRAINT chk_paket_lon_asal CHECK (longitude_asal BETWEEN -180 AND 180),
  CONSTRAINT chk_paket_lat_tujuan CHECK (latitude_tujuan BETWEEN -90 AND 90),
  CONSTRAINT chk_paket_lon_tujuan CHECK (longitude_tujuan BETWEEN -180 AND 180),
  CONSTRAINT chk_paket_jarak CHECK (jarak_km >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE invoice (
  id_invoice                 VARCHAR(20) NOT NULL,
  no_resi                    VARCHAR(30) NOT NULL,
  total_biaya_kotor          DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  total_bayar_bersih         DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  status_pembayaran          VARCHAR(20) NOT NULL DEFAULT 'Belum Lunas',
  jatuh_tempo                DATE NOT NULL,
  tanggal_terbit             DATE NOT NULL DEFAULT (CURRENT_DATE),
  nilai_potongan_aktual      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_invoice),
  UNIQUE KEY uq_invoice_no_resi (no_resi),
  CONSTRAINT fk_invoice_paket
    FOREIGN KEY (no_resi) REFERENCES paket(no_resi)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_invoice_kotor CHECK (total_biaya_kotor >= 0),
  CONSTRAINT chk_invoice_potongan CHECK (nilai_potongan_aktual >= 0),
  CONSTRAINT chk_invoice_bersih CHECK (total_bayar_bersih >= 0),
  CONSTRAINT chk_invoice_status CHECK (status_pembayaran IN ('Belum Lunas', 'Sebagian', 'Lunas', 'Jatuh Tempo')),
  CONSTRAINT chk_invoice_due CHECK (jatuh_tempo >= tanggal_terbit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pembayaran (
  id_pembayaran              VARCHAR(20) NOT NULL,
  id_invoice                 VARCHAR(20) NOT NULL,
  tanggal_pembayaran         DATETIME NOT NULL,
  metode_pembayaran          VARCHAR(30) NOT NULL,
  jumlah_pembayaran          DECIMAL(14,2) NOT NULL,
  PRIMARY KEY (id_pembayaran),
  KEY idx_pembayaran_invoice (id_invoice),
  CONSTRAINT fk_pembayaran_invoice
    FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_pembayaran_jumlah CHECK (jumlah_pembayaran > 0),
  CONSTRAINT chk_pembayaran_metode CHECK (metode_pembayaran IN ('Tunai', 'Transfer', 'Kartu Kredit'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promo (
  kode_promo                 VARCHAR(30) NOT NULL,
  tipe_promo                 VARCHAR(20) NOT NULL,
  nilai_promo                DECIMAL(12,4) NOT NULL,
  tanggal_mulai              DATE NOT NULL,
  tanggal_berakhir           DATE NOT NULL,
  PRIMARY KEY (kode_promo),
  CONSTRAINT chk_promo_tipe CHECK (tipe_promo IN ('persentase', 'nominal')),
  CONSTRAINT chk_promo_tanggal CHECK (tanggal_berakhir >= tanggal_mulai),
  CONSTRAINT chk_promo_nilai CHECK (
    (tipe_promo = 'persentase' AND nilai_promo >= 0 AND nilai_promo <= 1)
    OR
    (tipe_promo = 'nominal' AND nilai_promo >= 0)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pakai_promo (
  id_invoice                 VARCHAR(20) NOT NULL,
  kode_promo                 VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_invoice),
  KEY idx_pakai_promo_kode (kode_promo),
  CONSTRAINT fk_pakai_promo_invoice
    FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_pakai_promo_promo
    FOREIGN KEY (kode_promo) REFERENCES promo(kode_promo)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ulasan (
  id_ulasan                  VARCHAR(20) NOT NULL,
  no_resi                    VARCHAR(30) NOT NULL,
  rating                     TINYINT UNSIGNED NOT NULL,
  komentar                   TEXT NULL,
  tanggal_ulasan             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_ulasan),
  UNIQUE KEY uq_ulasan_no_resi (no_resi),
  CONSTRAINT fk_ulasan_paket
    FOREIGN KEY (no_resi) REFERENCES paket(no_resi)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_ulasan_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE log_pelacakan (
  id_log                     VARCHAR(20) NOT NULL,
  no_resi                    VARCHAR(30) NOT NULL,
  `timestamp`                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_pengiriman          VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_log),
  KEY idx_log_pelacakan_resi (no_resi),
  KEY idx_log_pelacakan_resi_ts (no_resi, `timestamp`),
  CONSTRAINT fk_log_pelacakan_paket
    FOREIGN KEY (no_resi) REFERENCES paket(no_resi)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_log_status CHECK (
    status_pengiriman IN (
      'Menunggu Pickup',
      'Dalam Pengiriman',
      'Tiba di Gudang',
      'Dikirim ke Tujuan',
      'Selesai',
      'Dibatalkan'
    )
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gudang (
  id_gudang                  VARCHAR(20) NOT NULL,
  nama_gudang                VARCHAR(100) NOT NULL,
  alamat_gudang_jalan        VARCHAR(255) NOT NULL,
  alamat_gudang_kecamatan    VARCHAR(100) NOT NULL,
  alamat_gudang_kabupaten    VARCHAR(100) NOT NULL,
  alamat_gudang_provinsi     VARCHAR(100) NOT NULL,
  alamat_gudang_kodePos      VARCHAR(10) NOT NULL,
  PRIMARY KEY (id_gudang),
  UNIQUE KEY uq_gudang_nama (nama_gudang),
  CONSTRAINT chk_gudang_kodepos CHECK (alamat_gudang_kodePos REGEXP '^[0-9]{5,10}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detail_transit (
  id_log                     VARCHAR(20) NOT NULL,
  id_gudang                  VARCHAR(20) NOT NULL,
  PRIMARY KEY (id_log),
  KEY idx_detail_transit_gudang (id_gudang),
  CONSTRAINT fk_detail_transit_log
    FOREIGN KEY (id_log) REFERENCES log_pelacakan(id_log)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_detail_transit_gudang
    FOREIGN KEY (id_gudang) REFERENCES gudang(id_gudang)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //

CREATE FUNCTION hitung_jarak_km(
  p_lat1 DECIMAL(10,7),
  p_lon1 DECIMAL(10,7),
  p_lat2 DECIMAL(10,7),
  p_lon2 DECIMAL(10,7)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_r DOUBLE DEFAULT 6371.0;
  DECLARE v_dlat DOUBLE;
  DECLARE v_dlon DOUBLE;
  DECLARE v_a DOUBLE;
  DECLARE v_c DOUBLE;

  SET v_dlat = RADIANS(p_lat2 - p_lat1);
  SET v_dlon = RADIANS(p_lon2 - p_lon1);

  SET v_a =
      POW(SIN(v_dlat / 2), 2)
      + COS(RADIANS(p_lat1))
      * COS(RADIANS(p_lat2))
      * POW(SIN(v_dlon / 2), 2);

  SET v_c = 2 * ASIN(SQRT(v_a));

  RETURN ROUND(v_r * v_c, 2);
END//

CREATE TRIGGER trg_paket_bi
BEFORE INSERT ON paket
FOR EACH ROW
BEGIN
  SET NEW.jarak_km = hitung_jarak_km(
    NEW.latitude_asal,
    NEW.longitude_asal,
    NEW.latitude_tujuan,
    NEW.longitude_tujuan
  );
END//

CREATE TRIGGER trg_paket_bu
BEFORE UPDATE ON paket
FOR EACH ROW
BEGIN
  SET NEW.jarak_km = hitung_jarak_km(
    NEW.latitude_asal,
    NEW.longitude_asal,
    NEW.latitude_tujuan,
    NEW.longitude_tujuan
  );
END//

CREATE TRIGGER trg_invoice_bi
BEFORE INSERT ON invoice
FOR EACH ROW
BEGIN
  DECLARE v_berat DECIMAL(10,2);
  DECLARE v_jarak DECIMAL(10,2);
  DECLARE v_tarif_kg DECIMAL(12,2);
  DECLARE v_tarif_km DECIMAL(12,2);

  SELECT p.berat, p.jarak_km, l.tarif_dasar_per_kg, l.tarif_dasar_per_km
    INTO v_berat, v_jarak, v_tarif_kg, v_tarif_km
  FROM paket p
  JOIN layanan l ON l.id_layanan = p.id_layanan
  WHERE p.no_resi = NEW.no_resi;

  SET NEW.total_biaya_kotor = ROUND((v_berat * v_tarif_kg) + (v_jarak * v_tarif_km), 2);
  SET NEW.nilai_potongan_aktual = COALESCE(NEW.nilai_potongan_aktual, 0);
  SET NEW.total_bayar_bersih = GREATEST(ROUND(NEW.total_biaya_kotor - NEW.nilai_potongan_aktual, 2), 0);
END//

CREATE TRIGGER trg_invoice_bu
BEFORE UPDATE ON invoice
FOR EACH ROW
BEGIN
  SET NEW.nilai_potongan_aktual = COALESCE(NEW.nilai_potongan_aktual, 0);
  SET NEW.total_bayar_bersih = GREATEST(ROUND(NEW.total_biaya_kotor - NEW.nilai_potongan_aktual, 2), 0);
END//

CREATE TRIGGER trg_pakai_promo_ai
AFTER INSERT ON pakai_promo
FOR EACH ROW
BEGIN
  UPDATE invoice i
  JOIN promo p ON p.kode_promo = NEW.kode_promo
  SET
    i.nilai_potongan_aktual = CASE
      WHEN p.tipe_promo = 'persentase' THEN ROUND(i.total_biaya_kotor * p.nilai_promo, 2)
      WHEN p.tipe_promo = 'nominal' THEN ROUND(p.nilai_promo, 2)
      ELSE 0
    END,
    i.total_bayar_bersih = GREATEST(
      ROUND(
        i.total_biaya_kotor - CASE
          WHEN p.tipe_promo = 'persentase' THEN (i.total_biaya_kotor * p.nilai_promo)
          WHEN p.tipe_promo = 'nominal' THEN p.nilai_promo
          ELSE 0
        END,
      2),
    0)
  WHERE i.id_invoice = NEW.id_invoice;
END//

CREATE TRIGGER trg_pakai_promo_au
AFTER UPDATE ON pakai_promo
FOR EACH ROW
BEGIN
  UPDATE invoice i
  JOIN promo p ON p.kode_promo = NEW.kode_promo
  SET
    i.nilai_potongan_aktual = CASE
      WHEN p.tipe_promo = 'persentase' THEN ROUND(i.total_biaya_kotor * p.nilai_promo, 2)
      WHEN p.tipe_promo = 'nominal' THEN ROUND(p.nilai_promo, 2)
      ELSE 0
    END,
    i.total_bayar_bersih = GREATEST(
      ROUND(
        i.total_biaya_kotor - CASE
          WHEN p.tipe_promo = 'persentase' THEN (i.total_biaya_kotor * p.nilai_promo)
          WHEN p.tipe_promo = 'nominal' THEN p.nilai_promo
          ELSE 0
        END,
      2),
    0)
  WHERE i.id_invoice = NEW.id_invoice;
END//

CREATE TRIGGER trg_pakai_promo_ad
AFTER DELETE ON pakai_promo
FOR EACH ROW
BEGIN
  UPDATE invoice
  SET
    nilai_potongan_aktual = 0,
    total_bayar_bersih = total_biaya_kotor
  WHERE id_invoice = OLD.id_invoice;
END//

CREATE TRIGGER trg_ulasan_bi
BEFORE INSERT ON ulasan
FOR EACH ROW
BEGIN
  DECLARE v_status_terakhir VARCHAR(30);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_status_terakhir = NULL;

  SELECT lp.status_pengiriman
    INTO v_status_terakhir
  FROM log_pelacakan lp
  WHERE lp.no_resi = NEW.no_resi
  ORDER BY lp.`timestamp` DESC, lp.id_log DESC
  LIMIT 1;

  IF v_status_terakhir IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ulasan tidak dapat dibuat karena paket belum memiliki log pelacakan.';
  END IF;

  IF v_status_terakhir <> 'Selesai' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ulasan hanya boleh dibuat jika status terakhir paket adalah Selesai.';
  END IF;
END//

CREATE TRIGGER trg_ulasan_bu
BEFORE UPDATE ON ulasan
FOR EACH ROW
BEGIN
  DECLARE v_status_terakhir VARCHAR(30);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_status_terakhir = NULL;

  SELECT lp.status_pengiriman
    INTO v_status_terakhir
  FROM log_pelacakan lp
  WHERE lp.no_resi = NEW.no_resi
  ORDER BY lp.`timestamp` DESC, lp.id_log DESC
  LIMIT 1;

  IF v_status_terakhir IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ulasan tidak dapat diubah karena paket belum memiliki log pelacakan.';
  END IF;

  IF v_status_terakhir <> 'Selesai' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ulasan hanya boleh ada untuk paket dengan status terakhir Selesai.';
  END IF;
END//

DELIMITER ;
