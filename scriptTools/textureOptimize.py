import os

from PIL import Image


def run_local_png_optimization(asset_path):
    """
    ลดขนาดไฟล์ PNG โดยใช้ Local Quantization และลบไฟล์เก่าทิ้ง
    """
    # รองรับการนำเข้าจาก WebP, JPG, JPEG เพื่อเปลี่ยนเป็น Optimized PNG
    target_exts = (".webp", ".jpg", ".jpeg", ".png")

    print(f"--- Local PNG Optimization Started: {asset_path} ---")

    for root, dirs, files in os.walk(asset_path):
        for file in files:
            if file.lower().endswith(target_exts):
                old_file_path = os.path.join(root, file)
                file_name_no_ext = os.path.splitext(file)[0]

                # กำหนด output เป็น .png เสมอ
                new_file_path = os.path.join(root, f"{file_name_no_ext}.png")
                old_import_file = old_file_path + ".import"

                try:
                    with Image.open(old_file_path) as img:
                        # ตรวจสอบว่าเป็น Normal Map หรือไม่ (ห้ามลดสีเด็ดขาด)
                        if "_normal" in file.lower():
                            img.save(new_file_path, "PNG", optimize=True)
                            print(f"[PASSTHROUGH] {file} (Normal Map preserved)")
                        else:
                            # ทำ Smart Quantization (ลดเหลือ 256 สีแบบ Adaptive)
                            # ช่วยให้ไฟล์ PNG เล็กกว่าปกติ 60-80%
                            optimized_img = img.convert(
                                "P", palette=Image.ADAPTIVE, colors=256
                            )
                            optimized_img.save(new_file_path, "PNG", optimize=True)
                            print(f"[OPTIMIZED PNG] {file} -> Optimized .png")

                    # ถ้าไฟล์ใหม่ชื่อไม่ซ้ำกับไฟล์เก่า (กรณีแปลงจาก .webp/.jpg) ให้ลบไฟล์เก่า
                    if old_file_path != new_file_path:
                        os.remove(old_file_path)
                        # ลบไฟล์ .import เดิมเพื่อให้ Godot สร้างใหม่สำหรับ PNG
                        if os.path.exists(old_import_file):
                            os.remove(old_import_file)

                except Exception as e:
                    print(f"[ERROR] {file}: {e}")


if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_dir = os.path.join(project_root, "assets")

    if os.path.exists(assets_dir):
        run_local_png_optimization(assets_dir)
    else:
        print(f"Error: Path {assets_dir} not found.")
