/*=====================================================================================
DATABASE & SCHEMA SETUP
Purpose: 
    Sets up the database and required schemas for the project:
    - 'raw' schema: stores unprocessed source tables.
    - 'clean' schema: stores cleaned and transformed views.
    - 'gold' schema: stores final tables ready for analysis.
Usage:
    - Run this script first to prepare the environment for data ingestion and analysis.
========================================================================================*/

DROP DATABASE IF EXISTS bibitor_llc;
-- Create database
CREATE DATABASE bibitor_llc;

-- Create schemas
-- 1) raw
CREATE SCHEMA IF NOT EXISTS raw;
-- 2) clean
CREATE SCHEMA IF NOT EXISTS clean;
-- 3) gold
CREATE SCHEMA IF NOT EXISTS gold;