-- Standard SQL Schema for IMDb Datasets
-- This file contains the complete schema for all IMDb dataset tables
-- Compatible with MySQL, PostgreSQL, SQLite, and other SQL databases

-- Create database (run this separately if needed)
-- CREATE DATABASE imdb_datasets;
-- USE imdb_datasets;

-- =============================================
-- Table: name_basics
-- Description: Basic information about names/persons
-- Source: name.basics.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS name_basics (
    nconst VARCHAR(20) PRIMARY KEY,  -- alphanumeric unique identifier of the name/person
    primary_name VARCHAR(255) NOT NULL,  -- name by which the person is most often credited
    birth_year INT,  -- in YYYY format, NULL if not available
    death_year INT,  -- in YYYY format if applicable, NULL if not applicable
    primary_profession TEXT,  -- comma-separated professions (top-3)
    known_for_titles TEXT  -- comma-separated tconsts, titles the person is known for
);

-- Create index on birth_year for faster queries
CREATE INDEX IF NOT EXISTS idx_name_basics_birth_year ON name_basics(birth_year);

-- Create index on death_year for faster queries
CREATE INDEX IF NOT EXISTS idx_name_basics_death_year ON name_basics(death_year);

-- =============================================
-- Table: title_basics
-- Description: Basic information about titles
-- Source: title.basics.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_basics (
    tconst VARCHAR(20) PRIMARY KEY,  -- alphanumeric unique identifier of the title
    title_type VARCHAR(50) NOT NULL,  -- the type/format of the title (e.g. movie, short, tvseries, tvepisode, video, etc)
    primary_title VARCHAR(500) NOT NULL,  -- the more popular title / the title used by the filmmakers on promotional materials at the point of release
    original_title VARCHAR(500),  -- original title, in the original language
    is_adult BOOLEAN DEFAULT FALSE,  -- 0: non-adult title; 1: adult title
    start_year INT,  -- represents the release year of a title. In the case of TV Series, it is the series start year
    end_year INT,  -- TV Series end year. NULL for all other title types
    runtime_minutes INT,  -- primary runtime of the title, in minutes
    genres TEXT  -- comma-separated genres (up to three genres associated with the title)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_title_basics_title_type ON title_basics(title_type);
CREATE INDEX IF NOT EXISTS idx_title_basics_start_year ON title_basics(start_year);
CREATE INDEX IF NOT EXISTS idx_title_basics_end_year ON title_basics(end_year);
CREATE INDEX IF NOT EXISTS idx_title_basics_runtime_minutes ON title_basics(runtime_minutes);
CREATE INDEX IF NOT EXISTS idx_title_basics_is_adult ON title_basics(is_adult);

-- =============================================
-- Table: title_akas
-- Description: Alternative titles for movies/shows
-- Source: title.akas.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_akas (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- auto-incrementing primary key (MySQL) / SERIAL (PostgreSQL)
    title_id VARCHAR(20) NOT NULL,  -- a tconst, an alphanumeric unique identifier of the title
    ordering INT NOT NULL,  -- a number to uniquely identify rows for a given titleId
    title VARCHAR(500) NOT NULL,  -- the localized title
    region VARCHAR(10),  -- the region for this version of the title
    language VARCHAR(10),  -- the language of the title
    types TEXT,  -- comma-separated enumerated set of attributes for this alternative title
    attributes TEXT,  -- comma-separated additional terms to describe this alternative title
    is_original_title BOOLEAN DEFAULT FALSE  -- 0: not original title; 1: original title
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_title_akas_title_id ON title_akas(title_id);
CREATE INDEX IF NOT EXISTS idx_title_akas_ordering ON title_akas(ordering);
CREATE INDEX IF NOT EXISTS idx_title_akas_region ON title_akas(region);
CREATE INDEX IF NOT EXISTS idx_title_akas_language ON title_akas(language);
CREATE INDEX IF NOT EXISTS idx_title_akas_is_original_title ON title_akas(is_original_title);

-- =============================================
-- Table: title_crew
-- Description: Director and writer information for titles
-- Source: title.crew.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_crew (
    tconst VARCHAR(20) PRIMARY KEY,  -- alphanumeric unique identifier of the title
    directors TEXT,  -- comma-separated nconsts, director(s) of the given title
    writers TEXT  -- comma-separated nconsts, writer(s) of the given title
);

-- =============================================
-- Table: title_episode
-- Description: Episode information for TV series
-- Source: title.episode.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_episode (
    tconst VARCHAR(20) PRIMARY KEY,  -- alphanumeric identifier of episode
    parent_tconst VARCHAR(20) NOT NULL,  -- alphanumeric identifier of the parent TV Series
    season_number INT,  -- season number the episode belongs to
    episode_number INT  -- episode number of the tconst in the TV series
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_title_episode_parent_tconst ON title_episode(parent_tconst);
CREATE INDEX IF NOT EXISTS idx_title_episode_season_number ON title_episode(season_number);
CREATE INDEX IF NOT EXISTS idx_title_episode_episode_number ON title_episode(episode_number);

-- =============================================
-- Table: title_principals
-- Description: Principal cast/crew for titles
-- Source: title.principals.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_principals (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- auto-incrementing primary key (MySQL) / SERIAL (PostgreSQL)
    tconst VARCHAR(20) NOT NULL,  -- alphanumeric unique identifier of the title
    ordering INT NOT NULL,  -- a number to uniquely identify rows for a given titleId
    nconst VARCHAR(20) NOT NULL,  -- alphanumeric unique identifier of the name/person
    category VARCHAR(100) NOT NULL,  -- the category of job that person was in
    job VARCHAR(255),  -- the specific job title if applicable, NULL if not applicable
    characters TEXT  -- the name of the character played if applicable, NULL if not applicable
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_title_principals_tconst ON title_principals(tconst);
CREATE INDEX IF NOT EXISTS idx_title_principals_ordering ON title_principals(ordering);
CREATE INDEX IF NOT EXISTS idx_title_principals_nconst ON title_principals(nconst);
CREATE INDEX IF NOT EXISTS idx_title_principals_category ON title_principals(category);

-- =============================================
-- Table: title_ratings
-- Description: Rating information for titles
-- Source: title.ratings.tsv.gz
-- =============================================
CREATE TABLE IF NOT EXISTS title_ratings (
    tconst VARCHAR(20) PRIMARY KEY,  -- alphanumeric unique identifier of the title
    average_rating DECIMAL(3,1) NOT NULL,  -- weighted average of all the individual user ratings
    num_votes INT NOT NULL  -- number of votes the title has received
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_title_ratings_average_rating ON title_ratings(average_rating);
CREATE INDEX IF NOT EXISTS idx_title_ratings_num_votes ON title_ratings(num_votes);

-- =============================================
-- Foreign Key Constraints (Optional - uncomment if your database supports them)
-- =============================================

-- Add foreign key constraints to maintain referential integrity
-- Note: Some databases may not support all of these constraints

-- ALTER TABLE title_akas 
-- ADD CONSTRAINT fk_title_akas_title_id 
-- FOREIGN KEY (title_id) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- ALTER TABLE title_crew 
-- ADD CONSTRAINT fk_title_crew_tconst 
-- FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- ALTER TABLE title_episode 
-- ADD CONSTRAINT fk_title_episode_tconst 
-- FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- ALTER TABLE title_episode 
-- ADD CONSTRAINT fk_title_episode_parent_tconst 
-- FOREIGN KEY (parent_tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- ALTER TABLE title_principals 
-- ADD CONSTRAINT fk_title_principals_tconst 
-- FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- ALTER TABLE title_principals 
-- ADD CONSTRAINT fk_title_principals_nconst 
-- FOREIGN KEY (nconst) REFERENCES name_basics(nconst) ON DELETE CASCADE;

-- ALTER TABLE title_ratings 
-- ADD CONSTRAINT fk_title_ratings_tconst 
-- FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- =============================================
-- Views for Common Queries (Database-specific)
-- =============================================

-- View for movies with ratings
CREATE OR REPLACE VIEW movies_with_ratings AS
SELECT 
    tb.tconst,
    tb.primary_title,
    tb.original_title,
    tb.start_year,
    tb.runtime_minutes,
    tb.genres,
    tr.average_rating,
    tr.num_votes
FROM title_basics tb
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.title_type = 'movie'
AND tb.is_adult = FALSE;

-- View for TV series with ratings
CREATE OR REPLACE VIEW tv_series_with_ratings AS
SELECT 
    tb.tconst,
    tb.primary_title,
    tb.original_title,
    tb.start_year,
    tb.end_year,
    tb.genres,
    tr.average_rating,
    tr.num_votes
FROM title_basics tb
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.title_type = 'tvSeries'
AND tb.is_adult = FALSE;

-- View for top-rated movies
CREATE OR REPLACE VIEW top_rated_movies AS
SELECT 
    tb.tconst,
    tb.primary_title,
    tb.start_year,
    tb.runtime_minutes,
    tb.genres,
    tr.average_rating,
    tr.num_votes
FROM title_basics tb
JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.title_type = 'movie'
AND tb.is_adult = FALSE
AND tr.num_votes >= 1000  -- Minimum votes threshold
ORDER BY tr.average_rating DESC, tr.num_votes DESC;

-- =============================================
-- Comments on Tables (Database-specific)
-- =============================================

-- Note: Table comments are database-specific
-- For MySQL: ALTER TABLE name_basics COMMENT = 'Basic information about names/persons in IMDb';
-- For PostgreSQL: COMMENT ON TABLE name_basics IS 'Basic information about names/persons in IMDb';

-- =============================================
-- Sample Queries
-- =============================================

/*
-- Sample queries to test the schema:

-- 1. Find all movies from 2020 with ratings
SELECT * FROM movies_with_ratings 
WHERE start_year = 2020 
ORDER BY average_rating DESC;

-- 2. Find top 10 highest rated movies
SELECT * FROM top_rated_movies 
LIMIT 10;

-- 3. Find all episodes of a specific TV series
SELECT te.*, tb.primary_title as episode_title
FROM title_episode te
JOIN title_basics tb ON te.tconst = tb.tconst
WHERE te.parent_tconst = 'tt0903747'  -- Breaking Bad
ORDER BY te.season_number, te.episode_number;

-- 4. Find all actors in a specific movie
SELECT tp.*, nb.primary_name
FROM title_principals tp
JOIN name_basics nb ON tp.nconst = nb.nconst
WHERE tp.tconst = 'tt0111161'  -- The Shawshank Redemption
AND tp.category IN ('actor', 'actress')
ORDER BY tp.ordering;

-- 5. Find all movies directed by a specific director
SELECT tb.*, tr.average_rating
FROM title_basics tb
JOIN title_crew tc ON tb.tconst = tc.tconst
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE FIND_IN_SET('nm0000233', tc.directors) > 0  -- Christopher Nolan (MySQL)
-- WHERE 'nm0000233' = ANY(string_to_array(tc.directors, ','))  -- PostgreSQL
AND tb.title_type = 'movie'
ORDER BY tr.average_rating DESC;

-- 6. Find movies by genre (using comma-separated values)
SELECT * FROM title_basics 
WHERE genres LIKE '%Drama%' 
AND title_type = 'movie'
ORDER BY start_year DESC;

-- 7. Find actors with most movies
SELECT nb.primary_name, COUNT(tp.tconst) as movie_count
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
WHERE tp.category IN ('actor', 'actress')
AND tb.title_type = 'movie'
GROUP BY nb.nconst, nb.primary_name
ORDER BY movie_count DESC
LIMIT 10;
*/
