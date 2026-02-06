# BidFix - Service Marketplace

BidFix is a service marketplace platform where customers post jobs and service providers bid to complete them. The platform features a unique coin-based bidding system and subscription model.

## Features

### For Customers (Consignees)
- Post service requirements with detailed descriptions
- Receive competitive bids from multiple service providers
- Review proposals and choose the best provider
- Pay 10% advance to the platform, 90% directly to the service provider
- Cancel jobs with automatic refund of advance payment

### For Service Providers (Sellers)
- Receive 4 free coins upon signup (worth ₹20)
- Browse available jobs by location, category, and budget
- Place bids using 5-20 coins per bid
- Coins are only deducted when you win the bid
- Subscribe to Unlimited Plan (₹499/month) for unlimited bids without coin deductions
- Track all your bids and their statuses

## Business Rules

1. **Coin System**
   - 1 coin = ₹5
   - New sellers get 4 free coins on signup
   - Bids cost 5-20 coins
   - Coins are only deducted when the seller wins the bid

2. **Subscription**
   - Unlimited Plan: ₹499/month
   - Unlimited bids without coin deductions
   - Valid for 30 days from subscription

3. **Payment Flow**
   - Consignee pays 10% advance to platform when accepting a bid
   - Remaining 90% paid directly to seller after job completion
   - 10% is refunded if job is cancelled

4. **Location System**
   - Dependent dropdowns for Indian States and Cities
   - All states and major cities pre-populated

5. **Categories**
   - All categories include an 'Other' option
   - If 'Other' is selected, user must specify the service type

## Database Setup

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `database-setup.sql` and run it
4. This will create all tables, policies, and seed data

## Environment Variables

The `.env` file is already configured with Supabase credentials:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

## Tech Stack

- **Frontend**: React 18 with TypeScript
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Build Tool**: Vite

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up the database using the SQL script in Supabase

3. The app uses the Supabase project that's already configured

4. Build the project:
   ```bash
   npm run build
   ```

## Project Structure

```
src/
├── components/          # React components
│   ├── AuthModal.tsx   # Authentication (signin/signup)
│   ├── Navbar.tsx      # Navigation bar
│   ├── PostJobModal.tsx # Job posting form
│   ├── JobCard.tsx     # Job display card
│   ├── PlaceBidModal.tsx # Bid placement form
│   ├── JobDetailsModal.tsx # Job details with bids
│   ├── WalletModal.tsx # Wallet and transactions
│   └── MyBidsView.tsx  # Seller's bid history
├── contexts/
│   └── AuthContext.tsx # Authentication state management
├── lib/
│   ├── supabase.ts     # Supabase client
│   └── database.types.ts # TypeScript database types
└── App.tsx             # Main application component

database-setup.sql       # Database schema and seed data
```

## Key Features Implementation

### Authentication
- Email/password authentication via Supabase Auth
- User roles: seller or consignee
- Profile creation with location selection

### Wallet Management
- Coin balance tracking
- Transaction history
- Subscription management
- Auto-credit of 4 coins on seller signup

### Bidding System
- Range-based coin selection (5-20 coins)
- Proposal submission with quoted price
- Coins deducted only on winning bid
- Subscription bypass for unlimited bidding

### Job Management
- Create, view, and cancel jobs
- Filter by category, location, and status
- View all bids on a job
- Accept bids with payment flow

### Payment Flow
- 10% advance payment tracking
- Refund on cancellation
- Transaction history for all payments

## Security

- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- Authentication required for all operations
- Secure payment tracking

## Notes

- The platform uses a reverse bidding model where service providers bid for jobs
- Higher coin bids increase visibility to job posters
- All monetary amounts are in Indian Rupees (INR)
