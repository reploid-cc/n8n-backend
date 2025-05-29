-- RFC-002: PostgreSQL Local Database - Schema Initialization
-- Initialize schemas for local development environment
-- n8n core tables → public schema (default)
-- Extended tables → n8n schema (custom, avoid conflicts)

-- Create n8n schema for extended tables only
CREATE SCHEMA IF NOT EXISTS n8n;

-- Create extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create migration tracking table in public schema
CREATE TABLE IF NOT EXISTS public.migration_log (
    id SERIAL PRIMARY KEY,
    script_name VARCHAR(255) UNIQUE NOT NULL,
    executed_at TIMESTAMP DEFAULT NOW(),
    checksum VARCHAR(64)
);

-- Set search path: public first (n8n core), then n8n (extended)
-- This ensures n8n core uses public schema by default
ALTER DATABASE n8ndb SET search_path TO public, n8n;

-- Log initialization
INSERT INTO public.migration_log (script_name, executed_at) 
VALUES ('001-init-schema.sql', NOW())
ON CONFLICT (script_name) DO NOTHING;

-- Create a function to update updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Log completion
INSERT INTO public.migration_log (script_name, executed_at) 
VALUES ('001-init-schema-complete', NOW())
ON CONFLICT (script_name) DO NOTHING; 