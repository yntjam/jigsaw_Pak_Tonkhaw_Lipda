-- =========================================================
-- ฐานข้อมูลเกมต่อจิ๊กซอว์ (Turso / SQLite)
-- โปรแกรมจะสร้างตารางเหล่านี้ให้อัตโนมัติเมื่อเชื่อมต่อครั้งแรก
-- ไฟล์นี้มีไว้ให้นักเรียนศึกษาโครงสร้าง หรือรันเองใน Turso Shell
-- =========================================================

-- ตารางที่ 1 : บันทึกผลการเล่นทุกครั้ง
CREATE TABLE IF NOT EXISTS results (
  id          INTEGER PRIMARY KEY AUTOINCREMENT, -- รหัสอัตโนมัติ
  player_name TEXT    NOT NULL,                  -- ชื่อผู้เล่น
  pieces      INTEGER NOT NULL,                  -- จำนวนชิ้น (9, 16, 25, ...)
  time_ms     INTEGER NOT NULL,                  -- เวลาที่ใช้ (มิลลิวินาที)
  moves       INTEGER NOT NULL,                  -- จำนวนครั้งที่สลับชิ้น
  mode        TEXT    NOT NULL,                  -- solo / turn / online
  room_code   TEXT,                              -- รหัสห้อง (เฉพาะโหมด online)
  created_at  TEXT    NOT NULL                   -- วันเวลาที่เล่น (ISO 8601)
);

-- ตารางที่ 2 : ห้องแข่งแบบ 2 เครื่อง
CREATE TABLE IF NOT EXISTS rooms (
  code           TEXT PRIMARY KEY,               -- รหัสห้อง 4 หลัก
  pieces         INTEGER NOT NULL,
  image          TEXT    NOT NULL,               -- รูปภาพแบบ base64 (data URL)
  order_json     TEXT    NOT NULL,               -- ลำดับชิ้นที่สลับแล้ว เช่น [3,0,2,1]
  host_name      TEXT    NOT NULL,               -- ผู้สร้างห้อง
  guest_name     TEXT,                           -- ผู้เข้าร่วม
  status         TEXT    NOT NULL DEFAULT 'waiting', -- waiting / playing
  started_at     INTEGER,                        -- เวลาเริ่ม (epoch ms)
  host_progress  INTEGER DEFAULT 0,              -- % ชิ้นที่ถูกที่ของ host
  guest_progress INTEGER DEFAULT 0,
  host_time      INTEGER,                        -- เวลาที่ host ใช้ (-1 = ยอมแพ้)
  guest_time     INTEGER,
  created_at     INTEGER NOT NULL
);

-- ---------- ตัวอย่างคำสั่ง SQL ให้นักเรียนฝึก ----------

-- 10 อันดับเร็วที่สุดของ 16 ชิ้น
SELECT player_name, time_ms / 1000.0 AS seconds, moves
FROM results WHERE pieces = 16
ORDER BY time_ms LIMIT 10;

-- เวลาเฉลี่ยและสถิติของแต่ละคน
SELECT player_name, COUNT(*) AS games,
       ROUND(AVG(time_ms) / 1000.0, 1) AS avg_sec,
       MIN(time_ms) / 1000.0 AS best_sec
FROM results GROUP BY player_name ORDER BY best_sec;

-- ล้างห้องแข่งที่เก่ากว่า 1 วัน (ห้องเก็บรูปไว้ จึงควรล้างเป็นระยะ)
DELETE FROM rooms WHERE created_at < (strftime('%s','now') - 86400) * 1000;
