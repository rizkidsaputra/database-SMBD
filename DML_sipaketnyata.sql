USE db_sipaketnyata;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE detail_transit;
TRUNCATE TABLE ulasan;
TRUNCATE TABLE pakai_promo;
TRUNCATE TABLE pembayaran;
TRUNCATE TABLE invoice;
TRUNCATE TABLE log_pelacakan;
TRUNCATE TABLE gudang;
TRUNCATE TABLE paket;
TRUNCATE TABLE promo;
TRUNCATE TABLE layanan;
TRUNCATE TABLE pelanggan;
SET FOREIGN_KEY_CHECKS = 1;

DELIMITER //

DROP PROCEDURE IF EXISTS seed_sipaketnyata//

CREATE PROCEDURE seed_sipaketnyata()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE v_no_identitas VARCHAR(30);
  DECLARE v_no_resi VARCHAR(30);
  DECLARE v_id_invoice VARCHAR(20);
  DECLARE v_id_log VARCHAR(20);
  DECLARE v_id_pembayaran VARCHAR(20);
  DECLARE v_id_ulasan VARCHAR(20);
  DECLARE v_total_bersih DECIMAL(14,2);
  DECLARE v_status_pembayaran VARCHAR(20);
  DECLARE v_status_akhir VARCHAR(30);
  DECLARE v_tanggal_terbit DATE;
  DECLARE v_waktu_awal DATETIME;
  DECLARE v_kota_asal_idx INT;
  DECLARE v_kota_tujuan_idx INT;
  DECLARE v_layanan_idx INT;
  DECLARE v_pelanggan_idx INT;
  DECLARE v_no_log INT DEFAULT 1;
  DECLARE v_no_bayar INT DEFAULT 1;
  DECLARE v_no_ulasan INT DEFAULT 1;

  INSERT INTO layanan (
    id_layanan, nama_layanan, tarif_dasar_per_kg, tarif_dasar_per_km, estimasi_waktu
  ) VALUES
    ('SERV-001', 'Reguler', 8000.00, 1350.00, '2-4 hari'),
    ('SERV-002', 'Ekspres', 12000.00, 1900.00, '1-2 hari'),
    ('SERV-003', 'Kargo', 5500.00, 900.00, '4-7 hari');

  INSERT INTO promo (
    kode_promo, tipe_promo, nilai_promo, tanggal_mulai, tanggal_berakhir
  ) VALUES
    ('ONGKIRHEMAT', 'persentase', 0.10, '2026-01-01', '2026-12-31'),
    ('RAMADAN10', 'persentase', 0.10, '2026-02-20', '2026-04-20'),
    ('MERDEKA25', 'nominal', 25000.00, '2026-08-01', '2026-08-31'),
    ('GAJIAN15', 'persentase', 0.15, '2026-06-20', '2026-06-30'),
    ('UMKM5000', 'nominal', 5000.00, '2026-01-01', '2026-12-31'),
    ('ANAKKOS12', 'persentase', 0.12, '2026-01-15', '2026-12-31'),
    ('KIRIMBARANG', 'nominal', 15000.00, '2026-03-01', '2026-12-31'),
    ('LEBARAN20', 'persentase', 0.20, '2026-03-15', '2026-04-15'),
    ('TOKOONLINE', 'persentase', 0.08, '2026-01-01', '2026-12-31'),
    ('FREESHIPID', 'nominal', 10000.00, '2026-05-01', '2026-12-31');

  INSERT INTO gudang (
    id_gudang, nama_gudang, alamat_gudang_jalan, alamat_gudang_kecamatan,
    alamat_gudang_kabupaten, alamat_gudang_provinsi, alamat_gudang_kodePos
  ) VALUES
    ('GDG-001', 'Hub Bandung Gedebage', 'Jl. Soekarno Hatta No. 789', 'Gedebage', 'Bandung', 'Jawa Barat', '40295'),
    ('GDG-002', 'Hub Jakarta Cakung', 'Jl. Raya Bekasi Km 22 No. 11', 'Cakung', 'Jakarta Timur', 'DKI Jakarta', '13910'),
    ('GDG-003', 'Hub Surabaya Margomulyo', 'Jl. Margomulyo Indah Blok H-12', 'Tandes', 'Surabaya', 'Jawa Timur', '60184'),
    ('GDG-004', 'Hub Yogyakarta Sleman', 'Jl. Magelang Km 8 No. 18', 'Mlati', 'Sleman', 'DI Yogyakarta', '55284'),
    ('GDG-005', 'Hub Semarang Tembalang', 'Jl. Prof. Soedarto No. 5', 'Tembalang', 'Semarang', 'Jawa Tengah', '50275'),
    ('GDG-006', 'Hub Denpasar Sanur', 'Jl. By Pass Ngurah Rai No. 88', 'Denpasar Selatan', 'Denpasar', 'Bali', '80228'),
    ('GDG-007', 'Hub Medan Tanjung Morawa', 'Jl. Medan Lubuk Pakam Km 18', 'Tanjung Morawa', 'Deli Serdang', 'Sumatera Utara', '20362'),
    ('GDG-008', 'Hub Makassar Daya', 'Jl. Perintis Kemerdekaan Km 15', 'Biringkanaya', 'Makassar', 'Sulawesi Selatan', '90243'),
    ('GDG-009', 'Hub Palembang Alang Alang Lebar', 'Jl. Soekarno Hatta No. 14', 'Alang Alang Lebar', 'Palembang', 'Sumatera Selatan', '30154'),
    ('GDG-010', 'Hub Balikpapan Kariangau', 'Jl. Mulawarman No. 27', 'Balikpapan Barat', 'Balikpapan', 'Kalimantan Timur', '76131');

  WHILE i <= 40 DO
    INSERT INTO pelanggan (
      no_identitas, nama_pelanggan, no_telepon,
      alamat_jalan, alamat_kecamatan, alamat_kabupaten, alamat_provinsi, alamat_kodePos
    ) VALUES (
      CONCAT(
        ELT(((i - 1) MOD 10) + 1, '3173', '3273', '3578', '3374', '3471', '5171', '1271', '7371', '1671', '6471'),
        LPAD(860000000000 + i, 12, '0')
      ),
      ELT(
        ((i - 1) MOD 20) + 1,
        'Muhammad Fajar Pratama',
        'Siti Aisyah Ramadhani',
        'Budi Santoso',
        'Dewi Lestari',
        'Rizky Maulana',
        'Nabila Putri Maharani',
        'Andi Saputra',
        'Putra Mahendra',
        'Ayu Sekar Wangi',
        'Bayu Prakoso',
        'Intan Permatasari',
        'Wahyu Hidayat',
        'Fikri Alamsyah',
        'Rani Puspitasari',
        'Yoga Pranata',
        'Nanda Aprilia',
        'Arif Nugroho',
        'Citra Anjani',
        'Reza Kurniawan',
        'Tasya Khairunnisa'
      ),
      CONCAT(
        ELT(((i - 1) MOD 5) + 1, '0812', '0813', '0821', '0857', '0878'),
        LPAD(1200000 + (i * 731), 7, '0')
      ),
      ELT(
        ((i - 1) MOD 10) + 1,
        CONCAT('Jl. Cikutra Barat No. ', 10 + i),
        CONCAT('Jl. Tebet Timur Dalam No. ', 20 + i),
        CONCAT('Jl. Manyar Kartika No. ', 5 + i),
        CONCAT('Jl. Kaliurang Km 5 No. ', 2 + i),
        CONCAT('Jl. Ngesrep Timur V No. ', 4 + i),
        CONCAT('Jl. Tukad Badung No. ', 3 + i),
        CONCAT('Jl. Setia Budi Pasar II No. ', 7 + i),
        CONCAT('Jl. Aroepala No. ', 9 + i),
        CONCAT('Jl. Demang Lebar Daun No. ', 11 + i),
        CONCAT('Jl. Jenderal Sudirman No. ', 6 + i)
      ),
      ELT(
        ((i - 1) MOD 10) + 1,
        'Cibeunying Kidul',
        'Tebet',
        'Sukolilo',
        'Depok',
        'Tembalang',
        'Denpasar Barat',
        'Medan Selayang',
        'Rappocini',
        'Ilir Barat I',
        'Balikpapan Kota'
      ),
      ELT(
        ((i - 1) MOD 10) + 1,
        'Bandung',
        'Jakarta Selatan',
        'Surabaya',
        'Sleman',
        'Semarang',
        'Denpasar',
        'Medan',
        'Makassar',
        'Palembang',
        'Balikpapan'
      ),
      ELT(
        ((i - 1) MOD 10) + 1,
        'Jawa Barat',
        'DKI Jakarta',
        'Jawa Timur',
        'DI Yogyakarta',
        'Jawa Tengah',
        'Bali',
        'Sumatera Utara',
        'Sulawesi Selatan',
        'Sumatera Selatan',
        'Kalimantan Timur'
      ),
      ELT(
        ((i - 1) MOD 10) + 1,
        '40124',
        '12820',
        '60286',
        '55281',
        '50275',
        '80119',
        '20132',
        '90222',
        '30137',
        '76114'
      )
    );

    SET i = i + 1;
  END WHILE;

  SET i = 1;
  WHILE i <= 120 DO
    SET v_pelanggan_idx = ((i - 1) MOD 40) + 1;
    SET v_no_identitas = CONCAT(
      ELT(((v_pelanggan_idx - 1) MOD 10) + 1, '3173', '3273', '3578', '3374', '3471', '5171', '1271', '7371', '1671', '6471'),
      LPAD(860000000000 + v_pelanggan_idx, 12, '0')
    );

    SET v_no_resi = CONCAT('PKT-2026', LPAD(i, 4, '0'));
    SET v_layanan_idx = ((i - 1) MOD 3) + 1;
    SET v_kota_asal_idx = ((i - 1) MOD 10) + 1;
    SET v_kota_tujuan_idx = ((i + 3) MOD 10) + 1;

    INSERT INTO paket (
      no_resi, no_identitas, id_layanan,
      berat, panjang, lebar, tinggi,
      jenis_barang, nilai_deklarasi,
      nama_penerima, no_telepon_penerima,
      alamat_penerima_jalan, alamat_penerima_kecamatan, alamat_penerima_kabupaten,
      alamat_penerima_provinsi, alamat_penerima_kodePos,
      latitude_asal, longitude_asal,
      latitude_tujuan, longitude_tujuan
    ) VALUES (
      v_no_resi,
      v_no_identitas,
      CONCAT('SERV-', LPAD(v_layanan_idx, 3, '0')),
      ROUND(
        CASE
          WHEN v_layanan_idx = 3 THEN 6.00 + ((i MOD 7) * 1.80)
          WHEN v_layanan_idx = 2 THEN 1.20 + ((i MOD 4) * 0.55)
          ELSE 0.40 + ((i MOD 9) * 0.65)
        END,
        2
      ),
      12 + (i MOD 18) + IF(v_layanan_idx = 3, 25, 0),
      10 + (i MOD 15) + IF(v_layanan_idx = 3, 18, 0),
      6 + (i MOD 12) + IF(v_layanan_idx = 3, 10, 0),
      ELT(
        ((i - 1) MOD 12) + 1,
        'Dokumen tender',
        'Keripik pisang Lampung',
        'Hijab dan busana muslim',
        'Aksesori handphone',
        'Buku pelajaran',
        'Kopi arabika Gayo',
        'Suku cadang motor',
        'Peralatan dapur UMKM',
        'Skincare lokal',
        'Frozen food bakso sapi',
        'Kain batik tulis',
        'Perlengkapan bayi'
      ),
      CASE
        WHEN v_layanan_idx = 3 THEN 750000 + (i * 45000)
        WHEN v_layanan_idx = 2 THEN 180000 + (i * 12000)
        ELSE 95000 + (i * 17500)
      END,
      ELT(
        ((i + 4) MOD 20) + 1,
        'Ahmad Fauzi',
        'Nurul Hidayah',
        'Kevin Wijaya',
        'Meylani Putri',
        'Rudi Hartono',
        'Vina Oktavia',
        'Dimas Saputro',
        'Salma Nabila',
        'Gilang Ramadhan',
        'Tiara Maharani',
        'Doni Kurnia',
        'Lukman Hakim',
        'Sherly Natalia',
        'Putri Amelia',
        'Yusuf Maulana',
        'Ratna Wulandari',
        'Hendra Gunawan',
        'Novi Andriani',
        'Bagas Aditya',
        'Fitri Handayani'
      ),
      CONCAT(
        ELT(((i + 1) MOD 5) + 1, '0811', '0815', '0822', '0856', '0882'),
        LPAD(2100000 + (i * 577), 7, '0')
      ),
      ELT(
        v_kota_tujuan_idx,
        CONCAT('Jl. Buah Batu No. ', 30 + i),
        CONCAT('Jl. Condet Raya No. ', 15 + i),
        CONCAT('Jl. Dharmahusada No. ', 22 + i),
        CONCAT('Jl. Gejayan No. ', 9 + i),
        CONCAT('Jl. Sisingamangaraja No. ', 14 + i),
        CONCAT('Jl. Mahendradatta No. ', 6 + i),
        CONCAT('Jl. Ringroad Setia Budi No. ', 8 + i),
        CONCAT('Jl. Pettarani No. ', 12 + i),
        CONCAT('Jl. Angkatan 45 No. ', 7 + i),
        CONCAT('Jl. MT Haryono No. ', 10 + i)
      ),
      ELT(
        v_kota_tujuan_idx,
        'Lengkong',
        'Kramat Jati',
        'Gubeng',
        'Depok',
        'Candisari',
        'Denpasar Barat',
        'Medan Sunggal',
        'Panakkukang',
        'Ilir Timur I',
        'Balikpapan Selatan'
      ),
      ELT(
        v_kota_tujuan_idx,
        'Bandung',
        'Jakarta Timur',
        'Surabaya',
        'Sleman',
        'Semarang',
        'Denpasar',
        'Medan',
        'Makassar',
        'Palembang',
        'Balikpapan'
      ),
      ELT(
        v_kota_tujuan_idx,
        'Jawa Barat',
        'DKI Jakarta',
        'Jawa Timur',
        'DI Yogyakarta',
        'Jawa Tengah',
        'Bali',
        'Sumatera Utara',
        'Sulawesi Selatan',
        'Sumatera Selatan',
        'Kalimantan Timur'
      ),
      ELT(
        v_kota_tujuan_idx,
        '40266',
        '13530',
        '60284',
        '55281',
        '50249',
        '80119',
        '20122',
        '90231',
        '30126',
        '76115'
      ),
      ELT(v_kota_asal_idx, -6.9175000, -6.2146000, -7.2575000, -7.7956000, -6.9667000, -8.6705000, 3.5952000, -5.1477000, -2.9761000, -1.2379000),
      ELT(v_kota_asal_idx, 107.6191000, 106.8451000, 112.7521000, 110.3695000, 110.4167000, 115.2126000, 98.6722000, 119.4327000, 104.7754000, 116.8529000),
      ELT(v_kota_tujuan_idx, -6.9175000, -6.2146000, -7.2575000, -7.7956000, -6.9667000, -8.6705000, 3.5952000, -5.1477000, -2.9761000, -1.2379000),
      ELT(v_kota_tujuan_idx, 107.6191000, 106.8451000, 112.7521000, 110.3695000, 110.4167000, 115.2126000, 98.6722000, 119.4327000, 104.7754000, 116.8529000)
    );

    SET v_tanggal_terbit = DATE_ADD('2026-06-01', INTERVAL (i MOD 15) DAY);

    SET v_id_invoice = CONCAT('INV-', LPAD(i, 3, '0'));

    INSERT INTO invoice (
      id_invoice, no_resi, status_pembayaran, jatuh_tempo, tanggal_terbit, nilai_potongan_aktual
    ) VALUES (
      v_id_invoice,
      v_no_resi,
      'Belum Lunas',
      DATE_ADD(v_tanggal_terbit, INTERVAL 7 DAY),
      v_tanggal_terbit,
      0.00
    );

    IF i MOD 3 <> 0 THEN
      INSERT INTO pakai_promo (id_invoice, kode_promo)
      VALUES (
        v_id_invoice,
        ELT(((i - 1) MOD 10) + 1, 'ONGKIRHEMAT', 'RAMADAN10', 'MERDEKA25', 'GAJIAN15', 'UMKM5000', 'ANAKKOS12', 'KIRIMBARANG', 'LEBARAN20', 'TOKOONLINE', 'FREESHIPID')
      );
    END IF;

    SELECT total_bayar_bersih
      INTO v_total_bersih
    FROM invoice
    WHERE id_invoice = v_id_invoice;

    IF i MOD 8 IN (0, 3) THEN
      SET v_status_pembayaran = 'Belum Lunas';
    ELSEIF i MOD 8 IN (1, 5) THEN
      SET v_status_pembayaran = 'Sebagian';
    ELSEIF i MOD 8 = 6 THEN
      SET v_status_pembayaran = 'Jatuh Tempo';
    ELSE
      SET v_status_pembayaran = 'Lunas';
    END IF;

    SET v_waktu_awal = DATE_ADD('2026-06-01 08:00:00', INTERVAL ((i - 1) * 3) HOUR);

    IF v_status_pembayaran = 'Sebagian' THEN
      SET v_id_pembayaran = CONCAT('PAY-', LPAD(v_no_bayar, 3, '0'));
      INSERT INTO pembayaran (
        id_pembayaran, id_invoice, tanggal_pembayaran, metode_pembayaran, jumlah_pembayaran
      ) VALUES (
        v_id_pembayaran,
        v_id_invoice,
        DATE_ADD(v_waktu_awal, INTERVAL 2 HOUR),
        ELT(((i - 1) MOD 3) + 1, 'Transfer', 'Tunai', 'Kartu Kredit'),
        ROUND(v_total_bersih * 0.45, 2)
      );
      SET v_no_bayar = v_no_bayar + 1;
    ELSEIF v_status_pembayaran = 'Lunas' THEN
      SET v_id_pembayaran = CONCAT('PAY-', LPAD(v_no_bayar, 3, '0'));
      INSERT INTO pembayaran (
        id_pembayaran, id_invoice, tanggal_pembayaran, metode_pembayaran, jumlah_pembayaran
      ) VALUES (
        v_id_pembayaran,
        v_id_invoice,
        DATE_ADD(v_waktu_awal, INTERVAL 2 HOUR),
        ELT(((i - 1) MOD 3) + 1, 'Transfer', 'Tunai', 'Kartu Kredit'),
        v_total_bersih
      );
      SET v_no_bayar = v_no_bayar + 1;
    ELSEIF v_status_pembayaran = 'Jatuh Tempo' THEN
      SET v_id_pembayaran = CONCAT('PAY-', LPAD(v_no_bayar, 3, '0'));
      INSERT INTO pembayaran (
        id_pembayaran, id_invoice, tanggal_pembayaran, metode_pembayaran, jumlah_pembayaran
      ) VALUES (
        v_id_pembayaran,
        v_id_invoice,
        DATE_ADD(v_waktu_awal, INTERVAL 1 HOUR),
        'Transfer',
        ROUND(v_total_bersih * 0.25, 2)
      );
      SET v_no_bayar = v_no_bayar + 1;
    END IF;

    UPDATE invoice
    SET status_pembayaran = v_status_pembayaran
    WHERE id_invoice = v_id_invoice;

    SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
    INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
    VALUES (v_id_log, v_no_resi, v_waktu_awal, 'Menunggu Pickup');
    SET v_no_log = v_no_log + 1;

    SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
    INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
    VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 4 HOUR), 'Dalam Pengiriman');
    SET v_no_log = v_no_log + 1;

    SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
    INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
    VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 10 HOUR), 'Tiba di Gudang');
    SET v_no_log = v_no_log + 1;

    INSERT INTO detail_transit (id_log, id_gudang)
    VALUES (v_id_log, CONCAT('GDG-', LPAD(((v_kota_asal_idx - 1) MOD 10) + 1, 3, '0')));

    SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
    INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
    VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 18 HOUR), 'Dikirim ke Tujuan');
    SET v_no_log = v_no_log + 1;

    IF i MOD 15 = 0 THEN
      SET v_status_akhir = 'Dibatalkan';
      SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
      INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
      VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 22 HOUR), 'Dibatalkan');
      SET v_no_log = v_no_log + 1;
    ELSEIF i MOD 4 = 0 THEN
      SET v_status_akhir = 'Dalam Pengiriman';
      SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
      INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
      VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 30 HOUR), 'Dalam Pengiriman');
      SET v_no_log = v_no_log + 1;
    ELSE
      SET v_status_akhir = 'Selesai';

      SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
      INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
      VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 30 HOUR), 'Tiba di Gudang');
      SET v_no_log = v_no_log + 1;

      INSERT INTO detail_transit (id_log, id_gudang)
      VALUES (v_id_log, CONCAT('GDG-', LPAD(((v_kota_tujuan_idx - 1) MOD 10) + 1, 3, '0')));

      SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
      INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
      VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 38 HOUR), 'Dikirim ke Tujuan');
      SET v_no_log = v_no_log + 1;

      SET v_id_log = CONCAT('LOG-', LPAD(v_no_log, 4, '0'));
      INSERT INTO log_pelacakan (id_log, no_resi, `timestamp`, status_pengiriman)
      VALUES (v_id_log, v_no_resi, DATE_ADD(v_waktu_awal, INTERVAL 52 HOUR), 'Selesai');
      SET v_no_log = v_no_log + 1;
    END IF;

    IF v_status_akhir = 'Selesai' AND i MOD 2 = 0 THEN
      SET v_id_ulasan = CONCAT('ULS-', LPAD(v_no_ulasan, 3, '0'));
      INSERT INTO ulasan (
        id_ulasan, no_resi, rating, komentar, tanggal_ulasan
      ) VALUES (
        v_id_ulasan,
        v_no_resi,
        ELT(((i - 1) MOD 5) + 1, 5, 4, 5, 4, 3),
        ELT(
          ((i - 1) MOD 8) + 1,
          'Kurir ramah, paket sampai cepat dan rapi.',
          'Packing aman, cocok untuk kiriman toko online.',
          'Pengiriman antarkota sesuai estimasi, update resi jelas.',
          'Barang diterima utuh, hanya sempat transit satu kali.',
          'Frozen food masih dingin saat diterima, puas.',
          'Respon admin cepat, promo ongkir cukup membantu.',
          'Paket tiba malam hari tapi penerima tetap dikabari dulu.',
          'Secara umum memuaskan, semoga layanan konsisten.'
        ),
        DATE_ADD(v_waktu_awal, INTERVAL 56 HOUR)
      );
      SET v_no_ulasan = v_no_ulasan + 1;
    END IF;

    SET i = i + 1;
  END WHILE;
END//

CALL seed_sipaketnyata()//

DROP PROCEDURE IF EXISTS seed_sipaketnyata//

DELIMITER ;
