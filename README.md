# IMDb Dataset Downloader API

A FastAPI application that downloads and extracts IMDb datasets from [datasets.imdbws.com](https://datasets.imdbws.com/). The API provides endpoints to download all IMDb datasets in TSV.GZ format and extract them to TSV files.

## Features

- **🚀 Download All Datasets**: Single API call to download all 7 IMDb datasets concurrently
- **📦 Extract Files**: Decompress TSV.GZ files to TSV format automatically
- **📁 File Management**: List, delete, and manage downloaded files with detailed metadata
- **☁️ Azure Blob Storage Support**: Store datasets in Azure Blob Storage or locally
- **🔄 Flexible Storage**: Switch between local and cloud storage seamlessly
- **⚡ Async Operations**: Fast, concurrent downloads using aiohttp
- **🛡️ Error Handling**: Comprehensive error handling and logging
- **🏗️ Modular Architecture**: Clean separation of concerns with proper folder structure
- **⚙️ Configuration Management**: Environment-based configuration with Pydantic settings
- **🔒 Type Safety**: Full type hints and Pydantic models for data validation
- **🐳 Docker Support**: Complete containerization with multi-stage builds
- **🔧 uv Integration**: Fast Python package management with uv
- **📊 Health Monitoring**: Built-in health checks and monitoring
- **🌐 RESTful API**: Clean, well-documented REST API endpoints
- **📝 Comprehensive Logging**: Detailed logging for debugging and monitoring

## Available Datasets

The API downloads the following IMDb datasets:

1. **name.basics.tsv.gz** - Basic information about names/persons
2. **title.akas.tsv.gz** - Alternative titles for movies/shows
3. **title.basics.tsv.gz** - Basic information about titles
4. **title.crew.tsv.gz** - Director and writer information
5. **title.episode.tsv.gz** - Episode information for TV series
6. **title.principals.tsv.gz** - Principal cast/crew for titles
7. **title.ratings.tsv.gz** - Rating information for titles

## Installation

### Option 1: Local Installation

1. **Clone or download the project files**

2. **Install Python dependencies:**
   ```bash
   # Using pip
   pip install -r requirements.txt
   
   # Or using uv (faster)
   pip install uv
   uv pip install -r requirements.txt
   ```

3. **Run the application:**
   ```bash
   # Using main.py
   python main.py
   
   # Or using uvicorn directly
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   
   # Or using uv
   uv run python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

### Option 2: Docker Installation

1. **Build and run with Docker Compose (Local Storage):**
   ```bash
   # Build and start the application
   docker-compose up --build
   
   # Run in background
   docker-compose up -d --build
   
   # View logs
   docker-compose logs -f
   ```

2. **Build and run with Docker Compose (Azure Blob Storage):**
   ```bash
   # Set Azure environment variables
   export AZURE_STORAGE_CONNECTION_STRING="your_connection_string"
   export AZURE_STORAGE_ACCOUNT_NAME="your_account_name"
   export AZURE_STORAGE_ACCOUNT_KEY="your_account_key"
   
   # Build and start with Azure Blob Storage
   docker-compose -f docker-compose.azure.yml up --build
   ```

3. **Build and run with Docker commands:**
   ```bash
   # Build the image
   docker build -t imdb-downloader .
   
   # Run the container
   docker run -d \
     --name imdb-downloader \
     -p 8000:8000 \
     -v imdb_data:/app/data \
     imdb-downloader
   ```

### Option 3: Development Setup with uv

1. **Install uv:**
   ```bash
   pip install uv
   ```

2. **Install dependencies:**
   ```bash
   # Install from requirements.txt
   uv pip install -r requirements.txt
   
   # Or install from pyproject.toml
   uv sync
   ```

3. **Run in development mode:**
   ```bash
   # Using uv
   uv run python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   
   # Or using uv with pyproject.toml
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

## Azure Blob Storage Configuration

The application supports both local file storage and Azure Blob Storage. You can switch between them using configuration settings.

### Setting up Azure Blob Storage

1. **Create an Azure Storage Account:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Create a new Storage Account
   - Note down the account name and access key

2. **Create a Container:**
   - In your Storage Account, create a new container
   - Set the container name (default: `imdb-datasets`)
   - Set access level to "Private" for security

3. **Configure the Application:**
   - Copy `.env.azure.example` to `.env`
   - Update the Azure Storage credentials:
     ```bash
     # Option 1: Use connection string (recommended)
     AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;AccountName=your_account_name;AccountKey=your_account_key;EndpointSuffix=core.windows.net
     
     # Option 2: Use account name and key separately
     AZURE_STORAGE_ACCOUNT_NAME=your_storage_account_name
     AZURE_STORAGE_ACCOUNT_KEY=your_storage_account_key
     
     # Container name for storing datasets
     AZURE_CONTAINER_NAME=imdb-datasets
     
     # Set to true to use Azure Blob Storage, false for local storage
     USE_AZURE_BLOB=true
     ```

4. **Test the Configuration:**
   - Start the application
   - Check logs for "Using Azure Blob Storage for dataset operations"
   - Test API endpoints

### Storage Modes

- **Local Storage** (`USE_AZURE_BLOB=false`): Files are stored in the local `imdb_datasets` directory
- **Azure Blob Storage** (`USE_AZURE_BLOB=true`): Files are stored in the specified Azure container

The application automatically detects the storage mode and uses the appropriate service.

## Docker Deployment

The application includes comprehensive Docker support with multiple deployment options.

### Docker Files Included

- **`Dockerfile`** - Multi-stage Dockerfile using uv for fast builds
- **`docker-compose.yml`** - Local storage deployment configuration
- **`docker-compose.azure.yml`** - Azure Blob Storage deployment configuration
- **`.dockerignore`** - Optimized build context
- **`pyproject.toml`** - Python project configuration for uv

### Quick Docker Commands

#### Local Storage Deployment
```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in background
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

#### Azure Blob Storage Deployment
```bash
# Set Azure environment variables
export AZURE_STORAGE_CONNECTION_STRING="your_connection_string"
export AZURE_STORAGE_ACCOUNT_NAME="your_account_name"
export AZURE_STORAGE_ACCOUNT_KEY="your_account_key"

# Build and run with Azure Blob Storage
docker-compose -f docker-compose.azure.yml up --build

# Run in background
docker-compose -f docker-compose.azure.yml up -d --build
```

#### Direct Docker Commands
```bash
# Build the image
docker build -t imdb-downloader .

# Run with local storage
docker run -d \
  --name imdb-downloader \
  -p 8000:8000 \
  -v imdb_data:/app/data \
  imdb-downloader

# Run with Azure Blob Storage
docker run -d \
  --name imdb-downloader \
  -p 8000:8000 \
  -e USE_AZURE_BLOB=true \
  -e AZURE_STORAGE_CONNECTION_STRING="your_connection_string" \
  imdb-downloader
```

### Docker Features

- **Multi-stage builds** for optimized image size
- **Non-root user** for security
- **Health checks** for reliability
- **Volume persistence** for data
- **Environment variable** support
- **uv optimization** for faster builds
- **Comprehensive logging** and monitoring

### Production Deployment

#### Docker Hub Deployment
```bash
# Build and tag for Docker Hub
docker build -t your-username/imdb-downloader:latest .

# Push to Docker Hub
docker push your-username/imdb-downloader:latest

# Pull and run on production server
docker pull your-username/imdb-downloader:latest
docker run -d --name imdb-downloader -p 8000:8000 your-username/imdb-downloader:latest
```

#### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: imdb-downloader
spec:
  replicas: 3
  selector:
    matchLabels:
      app: imdb-downloader
  template:
    metadata:
      labels:
        app: imdb-downloader
    spec:
      containers:
      - name: imdb-downloader
        image: your-username/imdb-downloader:latest
        ports:
        - containerPort: 8000
        env:
        - name: USE_AZURE_BLOB
          value: "true"
        - name: AZURE_STORAGE_CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: azure-secrets
              key: connection-string
---
apiVersion: v1
kind: Service
metadata:
  name: imdb-downloader-service
spec:
  selector:
    app: imdb-downloader
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

### Docker Monitoring

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' imdb-downloader

# View container stats
docker stats imdb-downloader

# View container logs
docker logs -f imdb-downloader

# Execute commands in running container
docker exec -it imdb-downloader /bin/bash
```

## API Endpoints

### Base URL
```
http://localhost:8000
```

### Available Endpoints

#### 1. **GET /** - Health Check
Returns basic API information and health status.

**Method:** `GET`  
**Path:** `/`  
**Headers:** `Accept: application/json`

**Response:**
```json
{
  "status": "healthy",
  "message": "IMDb Dataset Downloader API",
  "version": "1.0.0",
  "timestamp": "2025-10-26T02:00:00.000Z"
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8000/" \
  -H "Accept: application/json"
```

---

#### 2. **GET /datasets** - List Available Datasets
Returns a list of all available IMDb datasets that can be downloaded.

**Method:** `GET`  
**Path:** `/datasets`  
**Headers:** `Accept: application/json`

**Response:**
```json
{
  "datasets": [
    "name.basics.tsv.gz",
    "title.akas.tsv.gz",
    "title.basics.tsv.gz",
    "title.crew.tsv.gz",
    "title.episode.tsv.gz",
    "title.principals.tsv.gz",
    "title.ratings.tsv.gz"
  ],
  "total_count": 7
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8000/datasets" \
  -H "Accept: application/json"
```

---

#### 3. **POST /download** - Download All Datasets
Downloads all IMDb datasets concurrently from IMDb's official servers. If files already exist, they will be deleted first.

**Method:** `POST`  
**Path:** `/download`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`  
**Body:** None required

**Response:**
```json
{
  "message": "Download completed",
  "downloaded_files": [
    "name.basics.tsv.gz",
    "title.akas.tsv.gz",
    "title.basics.tsv.gz",
    "title.crew.tsv.gz",
    "title.episode.tsv.gz",
    "title.principals.tsv.gz",
    "title.ratings.tsv.gz"
  ],
  "failed_downloads": [],
  "total_files": 7,
  "successful_downloads": 7
}
```

**Error Response:**
```json
{
  "detail": "Download failed: Connection timeout"
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:8000/download" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Expected Duration:** ~2-5 minutes (depends on internet speed)

---

#### 4. **POST /extract** - Extract Downloaded Files
Extracts all downloaded TSV.GZ files to TSV format. Requires files to be downloaded first.

**Method:** `POST`  
**Path:** `/extract`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`  
**Body:** None required

**Response:**
```json
{
  "message": "Extraction completed",
  "extracted_files": [
    "name.basics.tsv",
    "title.akas.tsv",
    "title.basics.tsv",
    "title.crew.tsv",
    "title.episode.tsv",
    "title.principals.tsv",
    "title.ratings.tsv"
  ],
  "failed_extractions": [],
  "total_files": 7,
  "successful_extractions": 7
}
```

**Error Response:**
```json
{
  "detail": "Extraction failed: No compressed files found"
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:8000/extract" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

---

#### 5. **GET /files** - List All Files
Lists all files in the download directory (local or Azure Blob Storage) with their sizes and metadata.

**Method:** `GET`  
**Path:** `/files`  
**Headers:** `Accept: application/json`

**Response (Local Storage):**
```json
{
  "files": [
    {
      "name": "name.basics.tsv.gz",
      "size_bytes": 292318780,
      "size_mb": 278.78
    },
    {
      "name": "name.basics.tsv",
      "size_bytes": 1234567890,
      "size_mb": 1177.34
    }
  ],
  "total_files": 14,
  "directory": "imdb_datasets"
}
```

**Response (Azure Blob Storage):**
```json
{
  "files": [
    {
      "name": "name.basics.tsv.gz",
      "size_bytes": 292318780,
      "size_mb": 278.78,
      "last_modified": "2025-10-26T02:00:00.000Z",
      "content_type": "application/gzip"
    }
  ],
  "total_files": 7,
  "directory": "Azure Blob Container: imdb-datasets"
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8000/files" \
  -H "Accept: application/json"
```

---

#### 6. **DELETE /files** - Delete All Files
Deletes all files in the download directory (local or Azure Blob Storage).

**Method:** `DELETE`  
**Path:** `/files`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`  
**Body:** None required

**Response:**
```json
{
  "message": "All files deleted successfully",
  "deleted_files": [
    "name.basics.tsv.gz",
    "name.basics.tsv",
    "title.akas.tsv.gz",
    "title.akas.tsv"
  ],
  "total_deleted": 14
}
```

**Error Response:**
```json
{
  "detail": "Failed to delete files: Permission denied"
}
```

**cURL Example:**
```bash
curl -X DELETE "http://localhost:8000/files" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

---

#### 7. **POST /full-process** - Complete Data Processing
Downloads and extracts all datasets in one operation. This is the recommended endpoint for getting started.

**Method:** `POST`  
**Path:** `/full-process`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`  
**Body:** None required

**Response:**
```json
{
  "message": "Full data processing completed",
  "download": {
    "downloaded_files": [
      "name.basics.tsv.gz",
      "title.akas.tsv.gz",
      "title.basics.tsv.gz",
      "title.crew.tsv.gz",
      "title.episode.tsv.gz",
      "title.principals.tsv.gz",
      "title.ratings.tsv.gz"
    ],
    "successful_downloads": 7
  },
  "extract": {
    "extracted_files": [
      "name.basics.tsv",
      "title.akas.tsv",
      "title.basics.tsv",
      "title.crew.tsv",
      "title.episode.tsv",
      "title.principals.tsv",
      "title.ratings.tsv"
    ],
    "successful_extractions": 7
  }
}
```

**Error Response:**
```json
{
  "detail": "Full process endpoint error: No files were downloaded successfully"
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:8000/full-process" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Expected Duration:** ~3-7 minutes (depends on internet speed)

---

### Error Responses

All endpoints may return the following error responses:

**400 Bad Request:**
```json
{
  "detail": "Invalid request format"
}
```

**500 Internal Server Error:**
```json
{
  "detail": "Internal server error: [specific error message]"
}
```

**405 Method Not Allowed:**
```json
{
  "detail": "Method Not Allowed"
}
```

---

### Complete Workflow Examples

#### Basic Workflow (Download → Extract → List)
```bash
# 1. Check API health
curl -X GET "http://localhost:8000/"

# 2. Download all datasets
curl -X POST "http://localhost:8000/download"

# 3. Extract downloaded files
curl -X POST "http://localhost:8000/extract"

# 4. List all files
curl -X GET "http://localhost:8000/files"
```

#### Quick Start (All-in-One)
```bash
# Download and extract in one command
curl -X POST "http://localhost:8000/full-process"

# List files to verify
curl -X GET "http://localhost:8000/files"
```

#### Cleanup Workflow
```bash
# List current files
curl -X GET "http://localhost:8000/files"

# Delete all files
curl -X DELETE "http://localhost:8000/files"

# Verify deletion
curl -X GET "http://localhost:8000/files"
```

---

### Response Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | Health status ("healthy" or "error") |
| `message` | string | Human-readable message describing the operation result |
| `version` | string | API version number |
| `timestamp` | string | ISO 8601 timestamp of the response |
| `datasets` | array | List of available dataset filenames |
| `total_count` | integer | Total number of available datasets |
| `downloaded_files` | array | List of successfully downloaded files |
| `failed_downloads` | array | List of failed downloads with error details |
| `extracted_files` | array | List of successfully extracted files |
| `failed_extractions` | array | List of failed extractions with error details |
| `files` | array | List of files with metadata (name, size, etc.) |
| `total_files` | integer | Total number of files |
| `directory` | string | Storage location description |
| `deleted_files` | array | List of successfully deleted files |
| `total_deleted` | integer | Total number of deleted files |
| `successful_downloads` | integer | Number of successful downloads |
| `successful_extractions` | integer | Number of successful extractions |

## Usage Examples

### Using curl

1. **Download all datasets:**
   ```bash
   curl -X POST "http://localhost:8000/download"
   ```

2. **Extract all datasets:**
   ```bash
   curl -X POST "http://localhost:8000/extract"
   ```

3. **List files:**
   ```bash
   curl -X GET "http://localhost:8000/files"
   ```

4. **Delete all files:**
   ```bash
   curl -X DELETE "http://localhost:8000/files"
   ```

5. **Test database connection:**
   ```bash
   curl -X GET "http://localhost:8000/database/test"
   ```

6. **Load data to database:**
   ```bash
   curl -X POST "http://localhost:8000/database/load"
   ```

7. **Truncate database:**
   ```bash
   curl -X POST "http://localhost:8000/database/truncate"
   ```

8. **Get database counts:**
   ```bash
   curl -X GET "http://localhost:8000/database/counts"
   ```

9. **Full data processing (download, extract, load):**
   ```bash
   curl -X POST "http://localhost:8000/database/full-process"
   ```

### Using Python requests

```python
import requests

# Download all datasets
response = requests.post("http://localhost:8000/download")
print(response.json())

# Extract all datasets
response = requests.post("http://localhost:8000/extract")
print(response.json())

# List files
response = requests.get("http://localhost:8000/files")
print(response.json())
```

## Database Setup

The project includes database schemas for multiple SQL databases:

- **`azure_sql_schema.sql`** - Azure SQL Database (SQL Server) compatible schema
- **`sql_schema.sql`** - Standard SQL compatible with MySQL, PostgreSQL, SQLite, and other databases
- **`postgresql_schema.sql`** - PostgreSQL-specific schema with advanced features

### Database Setup Steps

#### For Azure SQL Database

1. **Create a database in Azure SQL Database**
   - Go to Azure Portal
   - Create a new SQL Database
   - Note down the server name, database name, username, and password

2. **Run the Azure SQL schema:**
   ```bash
   # Using sqlcmd
   sqlcmd -S your-server.database.windows.net -d imdb_datasets -U your-username -P your-password -i azure_sql_schema.sql
   
   # Or copy-paste the schema directly in Azure SQL Studio
   ```

3. **Configure the application:**
   ```bash
   # Copy the example configuration
   cp config.example .env
   
   # Edit .env with your Azure SQL Database details
   DATABASE_SERVER=your-server.database.windows.net
   DATABASE_NAME=imdb_datasets
   DATABASE_USERNAME=your-username
   DATABASE_PASSWORD=your-password
   ```

#### For Standard SQL (MySQL, SQLite, etc.)

1. **Create a database:**
   ```sql
   CREATE DATABASE imdb_datasets;
   USE imdb_datasets;  -- MySQL only
   ```

2. **Run the schema:**
   ```bash
   # MySQL
   mysql -u username -p imdb_datasets < sql_schema.sql
   
   # SQLite
   sqlite3 imdb_datasets.db < sql_schema.sql
   ```

#### For PostgreSQL

1. **Create a database:**
   ```sql
   CREATE DATABASE imdb_datasets;
   ```

2. **Run the PostgreSQL-specific schema:**
   ```bash
   psql -d imdb_datasets -f postgresql_schema.sql
   ```

### Database Schema Overview

All schemas include:

- **7 main tables** corresponding to each IMDb dataset
- **Indexes** for optimal query performance
- **Views** for common queries (movies with ratings, top-rated movies, etc.)
- **Sample queries** for testing

#### Key Differences

- **Azure SQL Database (`azure_sql_schema.sql`)**: 
  - Uses `NVARCHAR` and `NVARCHAR(MAX)` for Unicode support
  - Uses `BIT` for boolean values
  - Uses `IDENTITY(1,1)` for auto-increment
  - Uses `CHARINDEX()` for string searching
  - Full foreign key constraints enabled
  
- **Standard SQL (`sql_schema.sql`)**: 
  - Uses `TEXT` fields for comma-separated arrays
  - Compatible with MySQL, SQLite, SQL Server, etc.
  - Foreign key constraints are commented out (optional)
  
- **PostgreSQL (`postgresql_schema.sql`)**:
  - Uses native `TEXT[]` array types
  - Full foreign key constraints enabled
  - PostgreSQL-specific features and optimizations

### Key Tables

- `name_basics` - Person information
- `title_basics` - Title information (movies, TV shows, etc.)
- `title_akas` - Alternative titles
- `title_crew` - Directors and writers
- `title_episode` - TV episode information
- `title_principals` - Cast and crew
- `title_ratings` - Ratings and votes

## File Structure

```
├── main.py                 # Entry point (imports from app/)
├── requirements.txt        # Python dependencies
├── azure_sql_schema.sql   # Azure SQL Database schema
├── sql_schema.sql         # Standard SQL schema (MySQL, SQLite, etc.)
├── postgresql_schema.sql  # PostgreSQL-specific schema
├── config.example         # Configuration example
├── README.md              # This file
├── app/                   # Main application package
│   ├── __init__.py
│   ├── main.py            # FastAPI application factory
│   ├── api/               # API routes
│   │   ├── __init__.py
│   │   └── v1/            # API version 1
│   │       ├── __init__.py
│   │       └── datasets.py # Dataset endpoints
│   ├── core/              # Core functionality
│   │   ├── __init__.py
│   │   ├── config.py      # Configuration settings
│   │   └── logging.py     # Logging configuration
│   ├── models/            # Data models/schemas
│   │   ├── __init__.py
│   │   └── schemas.py     # Pydantic models
│   ├── services/          # Business logic
│   │   ├── __init__.py
│   │   └── dataset_service.py # Dataset operations
│   └── utils/             # Utility functions
│       ├── __init__.py
│       └── file_utils.py  # File operations
└── imdb_datasets/         # Downloaded files directory (created automatically)
```

## Architecture Overview

The application follows a clean, modular architecture with proper separation of concerns:

### **Core Components**

- **`app/core/`**: Configuration and logging setup
- **`app/models/`**: Pydantic schemas for request/response validation
- **`app/services/`**: Business logic and data operations
- **`app/api/`**: API routes and endpoints
- **`app/utils/`**: Utility functions and helpers

### **Key Benefits**

- **Maintainable**: Clear separation of concerns makes code easy to understand and modify
- **Testable**: Each component can be tested independently
- **Scalable**: Easy to add new features without affecting existing code
- **Type Safe**: Full type hints and Pydantic validation
- **Configurable**: Environment-based configuration management

### **Configuration Management**

The application uses Pydantic Settings for configuration management:
- Environment variables override default settings
- Type validation for all configuration values
- Easy to extend with new settings

## Data Processing Workflow

1. **Download**: Use `/download` endpoint to fetch all TSV.GZ files
2. **Extract**: Use `/extract` endpoint to decompress files to TSV format
3. **Import**: Use the TSV files to populate your database (Azure SQL, MySQL, PostgreSQL, SQLite, etc.)
4. **Query**: Use the provided views and sample queries for analysis

## Error Handling

The API includes comprehensive error handling:

- **Network errors** during download
- **File system errors** during extraction
- **Missing files** or directories
- **Invalid responses** from IMDb servers

All errors are logged and returned in a structured format.

## Performance Notes

- **Concurrent Downloads**: All datasets are downloaded simultaneously for faster processing
- **Memory Efficient**: Files are streamed during download to handle large datasets
- **Automatic Cleanup**: Existing files are automatically deleted before new downloads

## Dataset Information

For detailed information about each dataset's schema and fields, refer to the [IMDb Non-Commercial Datasets documentation](https://datasets.imdbws.com/).

## Troubleshooting

### Common Issues and Solutions

#### 1. **Port Already in Use**
**Error:** `Address already in use` or `Port 8000 is already in use`

**Solutions:**
```bash
# Find and kill process using port 8000
lsof -ti:8000 | xargs kill -9

# Or use a different port
uvicorn app.main:app --host 0.0.0.0 --port 8001

# For Docker, change port mapping
docker run -p 8001:8000 imdb-downloader
```

#### 2. **Permission Denied Errors**
**Error:** `Permission denied` when accessing files

**Solutions:**
```bash
# Fix file permissions
chmod -R 755 imdb_datasets/

# For Docker, check volume permissions
docker run -v $(pwd)/data:/app/data imdb-downloader

# Run with proper user permissions
sudo chown -R $USER:$USER imdb_datasets/
```

#### 3. **Azure Connection Issues**
**Error:** `Incorrect padding` or Azure authentication errors

**Solutions:**
```bash
# Check environment variables
echo $AZURE_STORAGE_CONNECTION_STRING

# Verify Azure credentials format
# Connection string should be: DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...;EndpointSuffix=core.windows.net

# Test Azure connection
python -c "
from azure.storage.blob import BlobServiceClient
client = BlobServiceClient.from_connection_string('your_connection_string')
print('Azure connection successful')
"
```

#### 4. **Download Failures**
**Error:** `Download failed: Connection timeout` or `HTTP 404`

**Solutions:**
```bash
# Check internet connection
curl -I https://datasets.imdbws.com/

# Check IMDb server status
curl -I https://datasets.imdbws.com/name.basics.tsv.gz

# Retry download
curl -X POST "http://localhost:8000/download"

# Check logs for specific errors
docker logs imdb-downloader
```

#### 5. **Memory Issues**
**Error:** `Out of memory` during extraction

**Solutions:**
```bash
# Increase Docker memory limit
docker run --memory=4g imdb-downloader

# Process files individually (modify code)
# Or use Azure Blob Storage to reduce local memory usage
```

#### 6. **Docker Build Failures**
**Error:** `Build failed` or `uv not found`

**Solutions:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t imdb-downloader .

# Check Dockerfile syntax
docker build --progress=plain -t imdb-downloader .
```

#### 7. **Environment Variable Issues**
**Error:** `Configuration error` or `Missing environment variable`

**Solutions:**
```bash
# Check .env file exists and is readable
ls -la .env
cat .env

# Verify environment variables are loaded
python -c "from app.core.config import settings; print(settings.use_azure_blob)"

# For Docker, pass environment variables explicitly
docker run -e USE_AZURE_BLOB=false imdb-downloader
```

### Debug Commands

#### Check Application Status
```bash
# Health check
curl http://localhost:8000/

# Check configuration
python -c "
from app.core.config import settings
print(f'Storage mode: {settings.use_azure_blob}')
print(f'Download dir: {settings.download_dir}')
print(f'Azure container: {settings.azure_container_name}')
"
```

#### Check File System
```bash
# List downloaded files
curl http://localhost:8000/files

# Check local directory
ls -la imdb_datasets/

# Check disk space
df -h
```

#### Check Docker Container
```bash
# Container status
docker ps

# Container logs
docker logs imdb-downloader

# Container stats
docker stats imdb-downloader

# Execute commands in container
docker exec -it imdb-downloader /bin/bash
```

#### Check Network Connectivity
```bash
# Test IMDb servers
curl -I https://datasets.imdbws.com/name.basics.tsv.gz

# Test API endpoints
curl -X GET "http://localhost:8000/datasets"

# Check firewall/port access
netstat -tlnp | grep 8000
```

### Performance Optimization

#### For Large Datasets
```bash
# Use Azure Blob Storage for large datasets
export USE_AZURE_BLOB=true

# Increase Docker memory
docker run --memory=8g imdb-downloader

# Use SSD storage for local files
docker run -v /path/to/ssd:/app/data imdb-downloader
```

#### For Slow Downloads
```bash
# Check network speed
speedtest-cli

# Use concurrent downloads (already enabled)
# Consider using a faster internet connection
# Or download during off-peak hours
```

### Log Analysis

#### Application Logs
```bash
# View real-time logs
docker logs -f imdb-downloader

# Search for errors
docker logs imdb-downloader 2>&1 | grep ERROR

# Search for specific operations
docker logs imdb-downloader 2>&1 | grep "download"
```

#### System Logs
```bash
# Check system resources
htop
df -h
free -h

# Check Docker resource usage
docker system df
docker system events
```

### Getting Help

1. **Check the logs** - Most issues are logged with detailed error messages
2. **Verify configuration** - Ensure all environment variables are set correctly
3. **Test connectivity** - Verify network access to IMDb servers
4. **Check resources** - Ensure sufficient disk space and memory
5. **Review documentation** - Check this README for specific endpoint usage

### Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| 400 | Bad Request | Check request format and headers |
| 404 | Not Found | Verify endpoint URL and server status |
| 405 | Method Not Allowed | Use correct HTTP method (GET, POST, DELETE) |
| 500 | Internal Server Error | Check logs for specific error details |
| 503 | Service Unavailable | Check IMDb server status and retry |

## License

This project is for educational and non-commercial use only, following IMDb's data usage terms.

## Support

For issues with the IMDb datasets themselves, contact: imdb-data-interest@imdb.com

For issues with this API, please check the logs and error messages returned by the endpoints.
