import os

from PIL import Image


def convert_to_webp(project_asset_path, quality=85, delete_original=False):
    target_extensions = (".png", ".jpg", ".jpeg")

    for root, dirs, files in os.walk(project_asset_path):
        for file in files:
            if file.lower().endswith(target_extensions):
                file_path = os.path.join(root, file)
                file_name_no_ext = os.path.splitext(file)[0]
                webp_path = os.path.join(root, f"{file_name_no_ext}.webp")

                try:
                    with Image.open(file_path) as img:
                        img.save(webp_path, "WEBP", quality=quality)
                        print(f"Converted: {file} -> {file_name_no_ext}.webp")

                    if delete_original:
                        os.remove(file_path)
                        print(f"Deleted original: {file}")
                except Exception as e:
                    print(f"Error converting {file}: {e}")


if __name__ == "__main__":
    # Logic to find the 'assets' folder relative to this script
    # This goes up one level from 'scriptTools' to find 'assets'
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    asset_folder = os.path.join(project_root, "assets")

    if os.path.exists(asset_folder):
        print(f"Starting conversion in: {asset_folder}")
        # Set delete_original=True only if you have a backup!
        convert_to_webp(asset_folder, quality=85, delete_original=False)
        print("Conversion process completed.")
    else:
        print(f"Path not found: {asset_folder}")
