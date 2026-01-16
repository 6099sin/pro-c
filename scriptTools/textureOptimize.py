import os

from PIL import Image


def run_conversion_pipeline(asset_path, quality=85):
    """
    Converts images to WebP, deletes originals, and cleans up .import files.
    """
    target_exts = (".webp", ".jpg", ".jpeg")
    converted_count = 0
    cleaned_import_count = 0

    print(f"--- Starting Pipeline in: {asset_path} ---")

    for root, dirs, files in os.walk(asset_path):
        for file in files:
            if file.lower().endswith(target_exts):
                # 1. Setup paths
                old_file_path = os.path.join(root, file)
                file_name_no_ext = os.path.splitext(file)[0]
                new_file_path = os.path.join(root, f"{file_name_no_ext}.webp")
                old_import_file = old_file_path + ".import"

                try:
                    # 2. Conversion Logic
                    with Image.open(old_file_path) as img:
                        # Ensure we handle RGBA for PNGs
                        if img.mode in ("RGBA", "P") and file.lower().endswith(".webp"):
                            img.save(
                                new_file_path, "WEBP", quality=quality, lossless=False
                            )
                        else:
                            img.convert("RGB").save(
                                new_file_path, "WEBP", quality=quality
                            )

                    # 3. Replace/Delete Logic
                    os.remove(old_file_path)
                    converted_count += 1
                    print(f"[CONVERTED & REPLACED] {file} -> .webp")

                    # 4. Godot Metadata Cleanup
                    if os.path.exists(old_import_file):
                        os.remove(old_import_file)
                        cleaned_import_count += 1
                        print(
                            f"[CLEANED] Removed orphan import: {os.path.basename(old_import_file)}"
                        )

                except Exception as e:
                    print(f"[ERROR] Could not process {file}: {e}")

    print("--- Pipeline Summary ---")
    print(f"Images Converted/Replaced: {converted_count}")
    print(f"Orphan .import files cleaned: {cleaned_import_count}")
    print("Action Required: Focus your Godot window to trigger a re-import.")


if __name__ == "__main__":
    # Robust pathing relative to your /scriptTools/ folder
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_dir = os.path.join(project_root, "assets")

    if os.path.exists(assets_dir):
        # WARNING: This will delete original PNG/JPG files.
        run_conversion_pipeline(assets_dir, quality=85)
    else:
        print(f"Error: Asset directory not found at {assets_dir}")
