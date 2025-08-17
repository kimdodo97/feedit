-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 뉴스 소스 테이블
CREATE TABLE news_sources (
    news_source_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(20) NOT NULL,
    base_url VARCHAR(500) NOT NULL,
    rss_url VARCHAR(500),
    api_endpoint VARCHAR(500),
    language VARCHAR(10) DEFAULT 'en',
    category VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    collection_interval_minutes INTEGER DEFAULT 60,
    last_collected_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 뉴스 기사 테이블
CREATE TABLE news_articles (
    news_articles_id BIGSERIAL PRIMARY KEY,
    source_id BIGINT NOT NULL REFERENCES news_sources(id),
    original_url VARCHAR(1000) UNIQUE NOT NULL,
    original_title VARCHAR(500) NOT NULL,
    original_content TEXT,
    original_summary VARCHAR(1000),
    translated_title VARCHAR(500),
    translated_content TEXT,
    translated_summary VARCHAR(1000),
    translation_status VARCHAR(20) DEFAULT 'PENDING',
    author VARCHAR(200),
    published_at TIMESTAMP NOT NULL,
    score INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    bookmark_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- 태그 마스터 테이블
CREATE TABLE tags (
    tags_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name_ko VARCHAR(100),
    display_name_en VARCHAR(100),
    category VARCHAR(50) NOT NULL,
    color VARCHAR(7),
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 기사-태그 연결 테이블
CREATE TABLE article_tags (
    article_tags_id BIGSERIAL PRIMARY KEY,
    article_id BIGINT NOT NULL REFERENCES news_articles(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES tags(id),
    confidence DECIMAL(3,2) DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(article_id, tag_id)
);

-- 수집 로그 테이블
CREATE TABLE collection_logs (
    collection_logs_id BIGSERIAL PRIMARY KEY,
    source_id BIGINT NOT NULL REFERENCES news_sources(id),
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    articles_found INTEGER DEFAULT 0,
    articles_saved INTEGER DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_news_articles_published_at ON news_articles(published_at DESC);
CREATE INDEX idx_news_articles_source_published ON news_articles(source_id, published_at DESC);
CREATE INDEX idx_news_articles_score ON news_articles(score DESC);
CREATE INDEX idx_user_article_views_date ON user_article_views(DATE(viewed_at));
