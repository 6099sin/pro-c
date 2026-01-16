import os

from PIL import Image

# --- CONFIGURATION ---
INPUT_FOLDER = "../assets"  # พาธโฟลเดอร์ที่มีรูปภาพของคุณ
TARGET_WIDTH = 1024  # จำกัดความกว้างสูงสุด (เพื่อประหยัด VRAM)
QUALITY = 85  # คุณภาพของ WebP (85 คือค่าที่คมชัดและไฟล์เล็กมาก)
METHOD = 6  # ระดับความละเอียดการบีบอัด (6 = สูงสุด/ช้าที่สุด)
KEEP_ORIGINAL = True  # ตั้งเป็น False หากต้องการลบไฟล์ .png/.jpg หลังแปลงเสร็จ
# ---------------------


def convert_to_webp(root_directory):
    if not os.path.exists(root_directory):
        print(f"❌ ไม่พบโฟลเดอร์: {root_directory}")
        return

    for subdir, dirs, files in os.walk(root_directory):
        for filename in files:
            # ค้นหาไฟล์ต้นฉบับ
            if filename.lower().endswith((".png", ".jpg", ".jpeg")):
                filepath = os.path.join(subdir, filename)

                # กำหนดชื่อไฟล์ปลายทางให้เป็น .webp
                new_filename = os.path.splitext(filename)[0] + ".webp"
                new_filepath = os.path.join(subdir, new_filename)

                try:
                    with Image.open(filepath) as img:
                        # 1. แปลงเป็น RGBA เพื่อรักษาความแม่นยำของสีและ Alpha Channel
                        if img.mode != "RGBA":
                            img = img.convert("RGBA")

                        # 2. ปรับขนาดถ้าจำเป็น (Resize)
                        if img.width > TARGET_WIDTH:
                            ratio = TARGET_WIDTH / float(img.width)
                            new_height = int(float(img.height) * float(ratio))
                            img = img.resize(
                                (TARGET_WIDTH, new_height), Image.Resampling.LANCZOS
                            )

                        # 3. บันทึกเป็นไฟล์ .webp
                        # exact=True: รักษาข้อมูลสีในพิกเซลที่โปร่งใส (สำคัญสำหรับ Godot Shaders)
                        img.save(
                            new_filepath,
                            "WEBP",
                            quality=QUALITY,
                            method=METHOD,
                            exact=True,
                        )

                        # คำนวณขนาดไฟล์
                        old_size = os.path.getsize(filepath) / 1024
                        new_size = os.path.getsize(new_filepath) / 1024
                        reduction = ((old_size - new_size) / old_size) * 100

                        print(
                            f"✅ Converted: {filename} -> {new_filename} | ลดขนาด {reduction:.1f}%"
                        )

                        # 4. ลบไฟล์เก่า (ถ้าต้องการ)
                        if not KEEP_ORIGINAL:
                            os.remove(filepath)
                            print(f"   🗑️ Removed original: {filename}")

                except Exception as e:
                    print(f"❌ Error processing {filename}: {e}")


if __name__ == "__main__":
    print(f"🚀 เริ่มการแปลงไฟล์ภาพเป็น .webp ใน: {INPUT_FOLDER}")
    convert_to_webp(INPUT_FOLDER)
