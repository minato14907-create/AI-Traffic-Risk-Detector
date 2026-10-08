# 🚨 AI Traffic Risk Detector

ระบบวิเคราะห์พฤติกรรมเสี่ยงบนท้องถนนแบบ Real-time ด้วย YOLOv8 + Object Tracking

---

## ภาพรวมระบบ

AI Traffic Risk Detector เป็น web application ที่ใช้ deep learning ตรวจจับและวิเคราะห์ยานพาหนะจากวิดีโอกล้องจราจร โดยสามารถระบุพฤติกรรมเสี่ยง เช่น การขับรถกระทันหัน การเบียดเส้น การขับสวนทาง และการเข้าใกล้กันอย่างอันตราย

---

## Features

| Feature | รายละเอียด |
|---|---|
| 🚗 Vehicle Detection | ตรวจจับ 5 ประเภท: รถยนต์, มอเตอร์ไซค์, รถบัส, รถบรรทุก, จักรยาน |
| ⚠️ Risk Scoring | คำนวณคะแนนความเสี่ยง 0–15 จาก movement pattern และ direction change |
| 🔲 ROI Zone | กำหนดพื้นที่วิเคราะห์ด้วย polygon วาดบนวิดีโอ |
| 📏 Line Counter | วางเส้นนับรถที่ผ่าน รองรับหลายเส้นพร้อมกัน |
| 💥 Near-Miss Detection | ตรวจจับยานพาหนะที่เข้าใกล้กันเกินระยะปลอดภัย |
| ↩ Wrong-Way Detection | ตรวจจับรถที่วิ่งสวนทางจากมุมทิศทางที่กำหนด |
| ➡️ Direction Arrow | แสดงลูกศรทิศทางการเคลื่อนที่บนแต่ละยานพาหนะ |
| ⚡ Speed Alert | แจ้งเตือนเมื่อความเร็วเกิน threshold ที่ตั้งไว้ |
| 📐 Speed Calibration | ตั้งค่า pixel-per-meter เพื่อแสดงความเร็วเป็น km/h จริง |
| 🔥 Heatmap | แสดง density map ของตำแหน่งยานพาหนะสะสม |
| 📸 Auto Snapshot | บันทึกภาพอัตโนมัติเมื่อเกิดเหตุการณ์สำคัญ |
| 📊 Progress Bar | แสดงความคืบหน้าการประมวลผลวิดีโอ |
| 📥 Export CSV | export event log ทั้งหมดเป็น CSV |
| 📄 Export PDF | สร้างรายงาน PDF พร้อม chart, ตาราง, และ snapshots |
| 🤖 Model Selector | เลือก YOLOv8 n/s/m/l ตามความต้องการ speed/accuracy |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Browser (UI)                      │
│  Upload → Canvas Editor → Live View → Summary       │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP / JSON
┌──────────────────────▼──────────────────────────────┐
│                  Flask Backend                       │
│                                                      │
│  /upload          → รับวิดีโอ                       │
│  /get_next_frame  → ประมวลผลทีละเฟรม                │
│  /set_roi         → กำหนด ROI polygon               │
│  /set_lines       → กำหนดเส้นนับ                    │
│  /set_wrong_way   → ตั้งค่า wrong-way               │
│  /set_speed_config→ ตั้งค่าความเร็ว                 │
│  /export_csv      → ดาวน์โหลด CSV                   │
│  /export_pdf      → สร้างรายงาน PDF                 │
│  /get_heatmap     → ดึง heatmap                     │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│              YOLOv8 + ByteTrack                      │
│                                                      │
│  Detection → Tracking → Risk Analysis                │
│  Direction → Near-Miss → Wrong-Way                   │
└─────────────────────────────────────────────────────┘
```

---

## Risk Scoring Algorithm

```
score += 2   ถ้า displacement > 20px AND direction_changes >= 1
score += 1.6 ถ้า direction_changes >= 2 (เบียดเส้น)
score -= 0.2 ถ้าไม่มีพฤติกรรมเสี่ยง (decay)

ระดับความเสี่ยง:
  score < 5   → ปลอดภัย  (เขียว)
  score 5–9   → เฝ้าระวัง (ส้ม)
  score ≥ 10  → เสี่ยงสูง (แดง)
```

---

## การติดตั้ง

```bash
# 1. Clone หรือดาวน์โหลดโปรเจกต์
git clone <repo-url>
cd traffic-detector

# 2. สร้าง virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. ติดตั้ง dependencies
pip install -r requirements.txt

# 4. รันระบบ
python app.py
```

เปิดเบราว์เซอร์ที่ `http://localhost:8000`

---

## วิธีใช้งาน

### 1. โหลดวิดีโอ
- ลากวางไฟล์วิดีโอ หรือคลิกเลือก
- ถ้ามีวิดีโอใน `uploads/` อยู่แล้ว ระบบจะ auto-load ใน 3 วินาที

### 2. ตั้งค่า ROI (ไม่บังคับ)
- กด **🔲 ROI** → คลิกวางจุดบนวิดีโอ → ดับเบิลคลิกปิด polygon
- ระบบจะวิเคราะห์เฉพาะในพื้นที่ที่กำหนด

### 3. วางเส้นนับรถ (ไม่บังคับ)
- กด **📏 เส้นนับ** → คลิก 2 จุด → ตั้งชื่อเส้น
- รองรับหลายเส้นพร้อมกัน

### 4. ตั้งค่า Wrong-Way (ไม่บังคับ)
- กด **↩ Wrong-Way** → กำหนดช่วงมุมที่อนุญาต → เปิดใช้งาน
- รถที่วิ่งนอกช่วงมุมจะถูกแจ้งเตือน

### 5. ดูผลลัพธ์
- **Live view**: เห็นผลการวิเคราะห์แบบ real-time
- **Side panel**: สถิติ, รายการพาหนะ, near-miss, snapshots
- **Heatmap**: กด 🔥 เพื่อดู density map
- **Export**: ดาวน์โหลด CSV หรือ PDF report

---

## Environment Variables

| Variable | Default | รายละเอียด |
|---|---|---|
| `MODEL_PATH` | `yolov8s.pt` | path ของ YOLO model |
| `CONF_THRES` | `0.4` | confidence threshold |
| `IOU_THRES` | `0.5` | IoU threshold |
| `IMG_SIZE` | `640` | inference image size |
| `FRAME_STRIDE` | `3` | ประมวลผลทุก N เฟรม |
| `JPEG_QUALITY` | `60` | คุณภาพภาพที่ส่งไป browser |
| `PORT` | `8000` | port ของ server |

---

## Tech Stack

- **Backend**: Python 3, Flask
- **AI/ML**: YOLOv8 (Ultralytics), ByteTrack
- **Computer Vision**: OpenCV
- **PDF Generation**: ReportLab
- **Frontend**: Vanilla JS, Chart.js
- **Deployment**: Railway / Render ready

---

## โครงสร้างโปรเจกต์

```
.
├── app.py              # Flask backend หลัก
├── requirements.txt    # Python dependencies
├── templates/
│   └── main.html       # Frontend UI
├── uploads/            # วิดีโอที่อัปโหลด
├── snapshots/          # ภาพ auto-snapshot
└── yolov8s.pt          # YOLO model weights
```

---

## ผู้พัฒนา

พัฒนาโดย **Thunyathep** สำหรับ Portfolio การสมัครเข้าศึกษาต่อ  
ระบบนี้แสดงให้เห็นการประยุกต์ใช้ Computer Vision และ Deep Learning  
เพื่อแก้ปัญหาจริงด้านความปลอดภัยบนท้องถนน
