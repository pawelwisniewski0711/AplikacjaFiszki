-- Migration: 20250510185333_create_extension.sql
-- Description: Włączenie niezbędnych rozszerzeń PostgreSQL

-- Enable UUID extension
create extension if not exists "uuid-ossp"; 