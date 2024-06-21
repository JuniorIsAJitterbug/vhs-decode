import PyInstaller.__main__
from pyinstaller_versionfile import create_versionfile

try:
    from _version import version_tuple
    version = f"{version_tuple[0]}.{version_tuple[1]}.{version_tuple[2]}.0"
except ImportError:
    version = "0.0.0.0"

print("Building Windows binary")

create_versionfile(
    output_file="build\\versionfile.txt",
    product_name="vhs-decode",
    original_filename="decode.exe",
    file_description="Software defined VHS decoder",
    version=version,
)

PyInstaller.__main__.run(
    [
        "decode.py",
        "--collect-submodules",
        "application",
        "--add-data",
        "vhsdecode/format_defs:vhsdecode/format_defs",
        "--icon",
        "assets\\icons\\vhs-decode.ico",
        "--version-file",
        "build\\versionfile.txt",
        "--onefile",
        "--name",
        "decode",
    ]
)