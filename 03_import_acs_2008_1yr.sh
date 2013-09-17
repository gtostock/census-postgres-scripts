#!/bin/bash

# Clone the import scripts from git
cd /home/ubuntu
sudo apt-get -y install git
git clone git://github.com/censusreporter/census-postgres.git

# Create the schema
cd /home/ubuntu/census-postgres/acs2008_1yr
sudo -u postgres psql -c "DROP SCHEMA IF EXISTS acs2008_1yr CASCADE; CREATE SCHEMA acs2008_1yr;"

# Create import tables
sudo -u postgres psql -q -f create_geoheader.sql
sudo -u postgres psql -q -f geoheader_comments.sql
sudo -u postgres psql -q -f create_tmp_geoheader.sql
sudo -u postgres psql -q -f create_import_tables.sql

# Slurp in the actual data
sudo -u postgres psql -q -f import_geoheader.sql
sudo -u postgres psql -q -f import_sequences.sql # This takes ~5 minutes
sudo -u postgres psql -q -f parse_tmp_geoheader.sql
sudo -u postgres psql -q -f store_by_tables.sql
sudo -u postgres psql -q -f insert_into_tables.sql # This takes ~5 minutes
sudo -u postgres psql -q -f view_stored_by_tables.sql

# Drop temp tables
sudo -u postgres psql -q -f drop_import_tables.sql
