-- 檢查是否已安裝
SELECT * FROM pg_available_extensions WHERE name = 'pgvector';

-- 安裝 pgvector 擴展
CREATE EXTENSION IF NOT EXISTS vector;

-- 驗證安裝
SELECT * FROM pg_extension WHERE extname = 'vector';

-- 測試向量功能
CREATE TABLE items (
  id bigserial PRIMARY KEY,
  embedding vector(3)
);

-- 插入測試資料
INSERT INTO items (embedding) VALUES ('[1,2,3]');

-- 查詢測試資料
SELECT * FROM items;