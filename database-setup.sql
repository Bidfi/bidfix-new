-- BidFix Database Setup Script
-- Run this script in your Supabase SQL Editor to set up the database

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('seller', 'consignee')),
  phone text,
  state_id uuid,
  city_id uuid,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create wallet table
CREATE TABLE IF NOT EXISTS wallet (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  coins integer DEFAULT 0,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE wallet ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wallet"
  ON wallet FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own wallet"
  ON wallet FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallet"
  ON wallet FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan_type text NOT NULL DEFAULT 'unlimited',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
  amount integer NOT NULL DEFAULT 499,
  start_date timestamptz DEFAULT now(),
  end_date timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscriptions"
  ON subscriptions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions"
  ON subscriptions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create states table
CREATE TABLE IF NOT EXISTS states (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE states ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view states"
  ON states FOR SELECT
  TO authenticated
  USING (true);

-- Create cities table
CREATE TABLE IF NOT EXISTS cities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  state_id uuid NOT NULL REFERENCES states(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(state_id, name)
);

ALTER TABLE cities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view cities"
  ON cities FOR SELECT
  TO authenticated
  USING (true);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  consignee_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL,
  category_id uuid NOT NULL REFERENCES categories(id),
  category_other text,
  state_id uuid NOT NULL REFERENCES states(id),
  city_id uuid NOT NULL REFERENCES cities(id),
  budget integer NOT NULL,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),
  winning_bid_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view jobs"
  ON jobs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Consignees can create jobs"
  ON jobs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = consignee_id);

CREATE POLICY "Consignees can update own jobs"
  ON jobs FOR UPDATE
  TO authenticated
  USING (auth.uid() = consignee_id)
  WITH CHECK (auth.uid() = consignee_id);

-- Create bids table
CREATE TABLE IF NOT EXISTS bids (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  seller_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  coin_amount integer NOT NULL CHECK (coin_amount >= 5 AND coin_amount <= 20),
  proposal text NOT NULL,
  quoted_price integer NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'won', 'lost')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(job_id, seller_id)
);

ALTER TABLE bids ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view bids"
  ON bids FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Sellers can create bids"
  ON bids FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can update own bids"
  ON bids FOR UPDATE
  TO authenticated
  USING (auth.uid() = seller_id)
  WITH CHECK (auth.uid() = seller_id);

-- Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  job_id uuid REFERENCES jobs(id) ON DELETE SET NULL,
  type text NOT NULL CHECK (type IN ('coin_deduction', 'advance_payment', 'refund', 'subscription', 'signup_bonus')),
  amount integer NOT NULL DEFAULT 0,
  coins integer,
  description text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
  ON transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions"
  ON transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Add foreign key for winning_bid_id
ALTER TABLE jobs ADD CONSTRAINT fk_winning_bid FOREIGN KEY (winning_bid_id) REFERENCES bids(id) ON DELETE SET NULL;

-- Insert default categories
INSERT INTO categories (name, description) VALUES
  ('Plumbing', 'Plumbing services and repairs'),
  ('Electrical', 'Electrical work and installations'),
  ('Carpentry', 'Woodwork and furniture'),
  ('Painting', 'Interior and exterior painting'),
  ('Cleaning', 'Home and office cleaning services'),
  ('Appliance Repair', 'Repair of household appliances'),
  ('Moving & Packing', 'Relocation and packing services'),
  ('Pest Control', 'Pest management services'),
  ('Other', 'Other services not listed above')
ON CONFLICT (name) DO NOTHING;

-- Insert Indian States
INSERT INTO states (name) VALUES
  ('Andhra Pradesh'),
  ('Arunachal Pradesh'),
  ('Assam'),
  ('Bihar'),
  ('Chhattisgarh'),
  ('Goa'),
  ('Gujarat'),
  ('Haryana'),
  ('Himachal Pradesh'),
  ('Jharkhand'),
  ('Karnataka'),
  ('Kerala'),
  ('Madhya Pradesh'),
  ('Maharashtra'),
  ('Manipur'),
  ('Meghalaya'),
  ('Mizoram'),
  ('Nagaland'),
  ('Odisha'),
  ('Punjab'),
  ('Rajasthan'),
  ('Sikkim'),
  ('Tamil Nadu'),
  ('Telangana'),
  ('Tripura'),
  ('Uttar Pradesh'),
  ('Uttarakhand'),
  ('West Bengal'),
  ('Delhi'),
  ('Jammu and Kashmir'),
  ('Ladakh'),
  ('Puducherry'),
  ('Chandigarh'),
  ('Dadra and Nagar Haveli and Daman and Diu'),
  ('Lakshadweep'),
  ('Andaman and Nicobar Islands')
ON CONFLICT (name) DO NOTHING;

-- Insert major cities for states
DO $$
DECLARE
  state_record RECORD;
BEGIN
  FOR state_record IN SELECT id, name FROM states LOOP
    CASE state_record.name
      WHEN 'Maharashtra' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Mumbai'),
          (state_record.id, 'Pune'),
          (state_record.id, 'Nagpur'),
          (state_record.id, 'Nashik'),
          (state_record.id, 'Thane')
        ON CONFLICT DO NOTHING;
      WHEN 'Karnataka' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Bangalore'),
          (state_record.id, 'Mysore'),
          (state_record.id, 'Mangalore'),
          (state_record.id, 'Hubli')
        ON CONFLICT DO NOTHING;
      WHEN 'Tamil Nadu' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Chennai'),
          (state_record.id, 'Coimbatore'),
          (state_record.id, 'Madurai'),
          (state_record.id, 'Salem')
        ON CONFLICT DO NOTHING;
      WHEN 'Delhi' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'New Delhi'),
          (state_record.id, 'South Delhi'),
          (state_record.id, 'North Delhi'),
          (state_record.id, 'East Delhi'),
          (state_record.id, 'West Delhi')
        ON CONFLICT DO NOTHING;
      WHEN 'Gujarat' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Ahmedabad'),
          (state_record.id, 'Surat'),
          (state_record.id, 'Vadodara'),
          (state_record.id, 'Rajkot')
        ON CONFLICT DO NOTHING;
      WHEN 'West Bengal' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Kolkata'),
          (state_record.id, 'Howrah'),
          (state_record.id, 'Durgapur'),
          (state_record.id, 'Siliguri')
        ON CONFLICT DO NOTHING;
      WHEN 'Uttar Pradesh' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Lucknow'),
          (state_record.id, 'Kanpur'),
          (state_record.id, 'Ghaziabad'),
          (state_record.id, 'Agra'),
          (state_record.id, 'Varanasi'),
          (state_record.id, 'Noida')
        ON CONFLICT DO NOTHING;
      WHEN 'Telangana' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Hyderabad'),
          (state_record.id, 'Warangal'),
          (state_record.id, 'Nizamabad')
        ON CONFLICT DO NOTHING;
      WHEN 'Rajasthan' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Jaipur'),
          (state_record.id, 'Jodhpur'),
          (state_record.id, 'Udaipur'),
          (state_record.id, 'Kota')
        ON CONFLICT DO NOTHING;
      WHEN 'Kerala' THEN
        INSERT INTO cities (state_id, name) VALUES
          (state_record.id, 'Thiruvananthapuram'),
          (state_record.id, 'Kochi'),
          (state_record.id, 'Kozhikode'),
          (state_record.id, 'Thrissur')
        ON CONFLICT DO NOTHING;
      ELSE
        NULL;
    END CASE;
  END LOOP;
END $$;
