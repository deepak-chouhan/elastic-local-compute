"""Elastic Local Compute configuration management."""

import platform
from pathlib import Path


class Settings:
    """ELC Settings."""

    APP_NAME: str = "Elastic Local Compute"
    APP_VERSION: str = "0.1.0"

    # SERVER
    HOST: str = "localhost"
    PORT: int = 8000

    # PATHS
    BASE_DIR: Path = Path.home() / ".elastic-local-compute"
    STORAGE_DIR: Path = BASE_DIR / "storage"
    IMAGES_DIR: Path = BASE_DIR / "images"
    INSTACE_DIR: Path = BASE_DIR / "instances"
    DB_PATH: Path = BASE_DIR / "elastic-local-compute.db"

    # HOST PLATFORM
    ARCH: str = "aarch64" if platform.machine() == "arm64" else "x86_64"
