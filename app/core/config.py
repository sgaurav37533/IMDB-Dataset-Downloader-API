from pydantic_settings import BaseSettings
from typing import Dict
import os

class Settings(BaseSettings):
    """Application settings and configuration"""
    

    app_name: str = "IMDb Dataset Downloader"
    app_version: str = "1.0.0"
    debug: bool = False
    
    host: str = "0.0.0.0"
    port: int = 8000
    
    download_dir: str = "imdb_datasets"
    
    imdb_datasets: Dict[str, str] = {
        "name.basics.tsv.gz": "https://datasets.imdbws.com/name.basics.tsv.gz",
        "title.akas.tsv.gz": "https://datasets.imdbws.com/title.akas.tsv.gz",
        "title.basics.tsv.gz": "https://datasets.imdbws.com/title.basics.tsv.gz",
        "title.crew.tsv.gz": "https://datasets.imdbws.com/title.crew.tsv.gz",
        "title.episode.tsv.gz": "https://datasets.imdbws.com/title.episode.tsv.gz",
        "title.principals.tsv.gz": "https://datasets.imdbws.com/title.principals.tsv.gz",
        "title.ratings.tsv.gz": "https://datasets.imdbws.com/title.ratings.tsv.gz"
    }
    
    log_level: str = "INFO"
    
    azure_storage_account_name: str = ""
    azure_storage_account_key: str = ""
    azure_storage_connection_string: str = ""
    azure_container_name: str = "imdb-datasets"
    use_azure_blob: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
