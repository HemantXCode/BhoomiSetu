-- Migration: Migrate parcel identifier to ULPIN
-- Unique Land Parcel Identification Number (ULPIN)

-- Ensure land_parcels table has ulpin column
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'land_parcels' AND column_name = 'parcel_number'
    ) THEN
        ALTER TABLE land_parcels RENAME COLUMN parcel_number TO ulpin;
    ELSE
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'land_parcels' AND column_name = 'ulpin'
        ) THEN
            ALTER TABLE land_parcels ADD COLUMN ulpin VARCHAR(100) UNIQUE;
        END IF;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_land_parcels_ulpin ON land_parcels(ulpin);
