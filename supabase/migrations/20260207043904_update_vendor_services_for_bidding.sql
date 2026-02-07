/*
  # Update vendor_services table for bidding platform

  1. Changes to `vendor_services` table
    - Remove `price` column (pricing will be determined through bidding)
    - Add `availability` column (how soon vendor can start)
    - Add `pending_bids_count` column (to track bids)

  2. Updated columns
    - `availability` (text, e.g., "Next week", "ASAP", "2 weeks")
    - `pending_bids_count` (integer, default 0)
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendor_services' AND column_name = 'price'
  ) THEN
    ALTER TABLE vendor_services DROP COLUMN price;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendor_services' AND column_name = 'availability'
  ) THEN
    ALTER TABLE vendor_services ADD COLUMN availability text DEFAULT 'ASAP';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendor_services' AND column_name = 'pending_bids_count'
  ) THEN
    ALTER TABLE vendor_services ADD COLUMN pending_bids_count integer DEFAULT 0;
  END IF;
END $$;
