/*
  # Create vendor_services table

  1. New Tables
    - `vendor_services`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `service_name` (text)
      - `price` (numeric)
      - `category` (text)
      - `description` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `vendor_services` table
    - Add policy for vendors to read their own services
    - Add policy for vendors to create services
    - Add policy for vendors to update their own services
    - Add policy for vendors to delete their own services
*/

CREATE TABLE IF NOT EXISTS vendor_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name text NOT NULL,
  price numeric(10, 2) NOT NULL,
  category text NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE vendor_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Vendors can view their own services"
  ON vendor_services FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Vendors can create services"
  ON vendor_services FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Vendors can update their own services"
  ON vendor_services FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Vendors can delete their own services"
  ON vendor_services FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_vendor_services_user_id ON vendor_services(user_id);
