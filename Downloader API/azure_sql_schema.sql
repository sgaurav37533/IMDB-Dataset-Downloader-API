CREATE TABLE name_basics (
    nconst NVARCHAR(20) PRIMARY KEY,
    primary_name NVARCHAR(255) NOT NULL,
    birth_year INT,
    death_year INT,
    primary_profession NVARCHAR(MAX),
    known_for_titles NVARCHAR(MAX)
);

CREATE INDEX idx_name_basics_birth_year ON name_basics(birth_year);
CREATE INDEX idx_name_basics_death_year ON name_basics(death_year);

CREATE TABLE title_basics (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50) NOT NULL,
    primary_title NVARCHAR(500) NOT NULL,
    original_title NVARCHAR(500),
    is_adult BIT DEFAULT 0,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX)
);

CREATE INDEX idx_title_basics_title_type ON title_basics(title_type);
CREATE INDEX idx_title_basics_start_year ON title_basics(start_year);
CREATE INDEX idx_title_basics_end_year ON title_basics(end_year);
CREATE INDEX idx_title_basics_runtime_minutes ON title_basics(runtime_minutes);
CREATE INDEX idx_title_basics_is_adult ON title_basics(is_adult);

CREATE TABLE title_akas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title_id NVARCHAR(20) NOT NULL,
    ordering INT NOT NULL,
    title NVARCHAR(500) NOT NULL,
    region NVARCHAR(10),
    language NVARCHAR(10),
    types NVARCHAR(MAX),
    attributes NVARCHAR(MAX),
    is_original_title BIT DEFAULT 0
);

CREATE INDEX idx_title_akas_title_id ON title_akas(title_id);
CREATE INDEX idx_title_akas_ordering ON title_akas(ordering);
CREATE INDEX idx_title_akas_region ON title_akas(region);
CREATE INDEX idx_title_akas_language ON title_akas(language);
CREATE INDEX idx_title_akas_is_original_title ON title_akas(is_original_title);

CREATE TABLE title_crew (
    tconst NVARCHAR(20) PRIMARY KEY,
    directors NVARCHAR(MAX),
    writers NVARCHAR(MAX)
);

CREATE TABLE title_episode (
    tconst NVARCHAR(20) PRIMARY KEY,
    parent_tconst NVARCHAR(20) NOT NULL,
    season_number INT,
    episode_number INT
);
CREATE INDEX idx_title_episode_parent_tconst ON title_episode(parent_tconst);
CREATE INDEX idx_title_episode_season_number ON title_episode(season_number);
CREATE INDEX idx_title_episode_episode_number ON title_episode(episode_number);

CREATE TABLE title_principals (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tconst NVARCHAR(20) NOT NULL,
    ordering INT NOT NULL,
    nconst NVARCHAR(20) NOT NULL,
    category NVARCHAR(100) NOT NULL,
    job NVARCHAR(255),
    characters NVARCHAR(MAX)
);
CREATE INDEX idx_title_principals_tconst ON title_principals(tconst);
CREATE INDEX idx_title_principals_ordering ON title_principals(ordering);
CREATE INDEX idx_title_principals_nconst ON title_principals(nconst);
CREATE INDEX idx_title_principals_category ON title_principals(category);

CREATE TABLE title_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    average_rating DECIMAL(3,1) NOT NULL,
    num_votes INT NOT NULL
);
CREATE INDEX idx_title_ratings_average_rating ON title_ratings(average_rating);
CREATE INDEX idx_title_ratings_num_votes ON title_ratings(num_votes);

ALTER TABLE title_akas 
ADD CONSTRAINT fk_title_akas_title_id 
FOREIGN KEY (title_id) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_crew 
ADD CONSTRAINT fk_title_crew_tconst 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_episode 
ADD CONSTRAINT fk_title_episode_tconst 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_episode 
ADD CONSTRAINT fk_title_episode_parent_tconst 
FOREIGN KEY (parent_tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_principals 
ADD CONSTRAINT fk_title_principals_tconst 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_principals 
ADD CONSTRAINT fk_title_principals_nconst 
FOREIGN KEY (nconst) REFERENCES name_basics(nconst) ON DELETE CASCADE;

ALTER TABLE title_ratings 
ADD CONSTRAINT fk_title_ratings_tconst 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- Additional rating tables for different title types
CREATE TABLE short_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_episode_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_mini_series_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_movie_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_pilot_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_series_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_short_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE tv_special_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE video_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE TABLE video_game_ratings (
    tconst NVARCHAR(20) PRIMARY KEY,
    title_type NVARCHAR(50),
    primary_title NVARCHAR(500),
    original_title NVARCHAR(500),
    is_adult BIT,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres NVARCHAR(MAX),
    average_rating DECIMAL(3,1),
    num_votes INT
);

CREATE VIEW movies_with_ratings AS
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
AND tb.is_adult = 0;

CREATE VIEW tv_series_with_ratings AS
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
AND tb.is_adult = 0;

CREATE VIEW top_rated_movies AS
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
AND tb.is_adult = 0
AND tr.num_votes >= 1000
ORDER BY tr.average_rating DESC, tr.num_votes DESC;

SELECT * FROM movies_with_ratings 
WHERE start_year = 2020
ORDER BY average_rating DESC;

SELECT TOP 10 * FROM top_rated_movies;

SELECT te.*, tb.primary_title as episode_title
FROM title_episode te
JOIN title_basics tb ON te.tconst = tb.tconst
WHERE te.parent_tconst = 'tt0903747'
ORDER BY te.season_number, te.episode_number;

SELECT tp.*, nb.primary_name
FROM title_principals tp
JOIN name_basics nb ON tp.nconst = nb.nconst
WHERE tp.tconst = 'tt0111161'
AND tp.category IN ('actor', 'actress')
ORDER BY tp.ordering;

SELECT tb.*, tr.average_rating
FROM title_basics tb
JOIN title_crew tc ON tb.tconst = tc.tconst
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE CHARINDEX('nm0000233', tc.directors) > 0
AND tb.title_type = 'movie'
ORDER BY tr.average_rating DESC;

SELECT * FROM title_basics 
WHERE genres LIKE '%Drama%' 
AND title_type = 'movie'
ORDER BY start_year DESC;

SELECT TOP 10 nb.primary_name, COUNT(tp.tconst) as movie_count
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
WHERE tp.category IN ('actor', 'actress')
AND tb.title_type = 'movie'
GROUP BY nb.nconst, nb.primary_name
ORDER BY movie_count DESC;

SELECT TOP 20 
    tb.primary_title,
    tb.start_year,
    tb.genres,
    tr.average_rating,
    tr.num_votes
FROM title_basics tb
JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.title_type = 'movie'
AND tb.is_adult = 0
AND tr.num_votes >= 10000
ORDER BY tr.average_rating DESC, tr.num_votes DESC;

SELECT 
    tb.primary_title,
    tb.start_year,
    COUNT(te.tconst) as episode_count
FROM title_basics tb
JOIN title_episode te ON tb.tconst = te.parent_tconst
WHERE tb.title_type = 'tvSeries'
GROUP BY tb.tconst, tb.primary_title, tb.start_year
ORDER BY episode_count DESC;

SELECT TOP 10
    nb.primary_name,
    COUNT(DISTINCT tc.tconst) as movie_count,
    AVG(tr.average_rating) as avg_rating
FROM name_basics nb
JOIN title_crew tc ON CHARINDEX(nb.nconst, tc.directors) > 0
JOIN title_ratings tr ON tc.tconst = tr.tconst
JOIN title_basics tb ON tc.tconst = tb.tconst
WHERE tb.title_type = 'movie'
AND tb.is_adult = 0
GROUP BY nb.nconst, nb.primary_name
HAVING COUNT(DISTINCT tc.tconst) >= 3
ORDER BY avg_rating DESC, movie_count DESC;
