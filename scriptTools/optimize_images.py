import os

from PIL import Image

# --- CONFIGURATION (ตั้งค่าที่นี่) ---
# คุณสามารถใส่พาธ เช่น "C:/Users/Game/Project/Assets" หรือ "./assets"
INPUT_FOLDER = "../assets"

TARGET_WIDTH = 1024  # ขนาดความกว้างสูงสุด (px)
QUALITY = 80  # คุณภาพ WebP (0-100)
KEEP_ORIGINAL = True  # ถ้าเป็น False จะลบไฟล์ต้นฉบับ (PNG/JPG) ทันทีหลังแปลงเสร็จ
# ----------------------------------


def optimize_images(root_directory):
    # ตรวจสอบว่าโฟลเดอร์มีอยู่จริงหรือไม่
    if not os.path.exists(root_directory):
        print(f"❌ Error: Folder '{root_directory}' not found!")
        return

    print(f"🚀 Scanning directory: {os.path.abspath(root_directory)}")

    for subdir, dirs, files in os.walk(root_directory):
        for filename in files:
            if filename.lower().endswith((".png", ".jpg", ".jpeg")):
                filepath = os.path.join(subdir, filename)

                try:
                    with Image.open(filepath) as img:
                        # 1. เช็คขนาด
                        if img.width <= TARGET_WIDTH:
                            print(f"Skipping {filename} (Width: {img.width}px)")
                            continue

                        # 2. คำนวณความสูงใหม่
                        aspect_ratio = img.height / img.width
                        new_height = int(TARGET_WIDTH * aspect_ratio)

                        # 3. ย่อรูป
                        img_resized = img.resize(
                            (TARGET_WIDTH, new_height), Image.Resampling.LANCZOS
                        )

                        # 4. บันทึกเป็น WebP
                        new_filename = os.path.splitext(filename)[0] + ".webp"
                        new_filepath = os.path.join(subdir, new_filename)
                        img_resized.save(new_filepath, "WEBP", quality=QUALITY)

                        # แสดงผลลัพธ์
                        old_size = os.path.getsize(filepath) / 1024
                        new_size = os.path.getsize(new_filepath) / 1024
                        reduction = ((old_size - new_size) / old_size) * 100

                        print(
                            f"✅ Optimized: {new_filename} (Reduced {reduction:.1f}%)"
                        )

                        # 5. ลบไฟล์ต้นฉบับ (ถ้าตั้งค่าไว้)
                        if not KEEP_ORIGINAL:
                            os.remove(filepath)
                            print(f"   🗑️ Original file '{filename}' removed.")

                except Exception as e:
                    print(f"❌ Error processing {filename}: {e}")


if __name__ == "__main__":
    optimize_images(INPUT_FOLDER)
