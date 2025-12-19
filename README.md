# News Feed Application

A lightweight full-stack News Feed Application that allows authenticated users to register, sign in, select and persist keywords, and view articles from NewsAPI based on those keywords.

## Tech Stack

- **Backend**: Ruby on Rails 8.1.1 with PostgreSQL
- **Frontend**: React with TypeScript, Vite, Tailwind CSS
- **Authentication**: Devise
- **Authorization**: CanCanCan
- **API Integration**: NewsAPI

## Prerequisites

- Ruby 3.3.6 or higher
- Rails 8.1.1
- PostgreSQL (must be installed and running on your system)
- Node.js 18+ and npm
- A NewsAPI account and API key

## Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd interview_storyful
```

### 2. Backend Setup

#### Install Dependencies

```bash
cd backend
bundle install
```

#### Database Configuration

1. **Ensure PostgreSQL is installed and running on your system**

   - On macOS: `brew install postgresql@14` (or your preferred version)
   - On Linux: `sudo apt-get install postgresql` (Ubuntu/Debian) or use your package manager
   - On Windows: Download from [PostgreSQL official website](https://www.postgresql.org/download/windows/)

2. **Create a PostgreSQL database** (if not already created):
   ```bash
   # Connect to PostgreSQL
   psql postgres
   
   # Create a database (optional, Rails will create it)
   CREATE DATABASE storyful_interview;
   ```

3. **Configure environment variables** in `backend/.env`:
   ```bash
   cd backend
   cp .env.example .env
   ```

   Edit `backend/.env` with your PostgreSQL credentials:
   ```env
   DB_NAME=storyful_interview
   DB_USERNAME=postgres
   DB_PASSWORD=your_postgres_password
   DB_HOST=localhost
   DB_PORT=5432
   TEST_DB_NAME=test_storyful_interviews
   NEWS_API_KEY=your_news_api_key_here
   ```

   **Important**: Replace `your_postgres_password` with your actual PostgreSQL password, and `your_news_api_key_here` with your NewsAPI key (see section below).

   The database configuration in `backend/config/database.yml` will automatically use these environment variables. If the variables are not set, it will fall back to defaults.

#### Set Up Database

```bash
rails db:create
rails db:migrate
```

#### Start the Backend Server

```bash
rails server
```

The backend will run on `http://localhost:3000`

### 3. Frontend Setup

#### Install Dependencies

```bash
cd frontend
npm install
```

#### Start the Frontend Development Server

```bash
npm run dev
```

The frontend will run on `http://localhost:5173`

### 4. Environment Variables

#### Backend Environment Variables

Create a `.env` file in the `backend` directory (see Database Configuration above):

- `DB_NAME`: PostgreSQL database name for development
- `DB_USERNAME`: PostgreSQL username
- `DB_PASSWORD`: PostgreSQL password
- `DB_HOST`: PostgreSQL host (usually `localhost`)
- `DB_PORT`: PostgreSQL port (usually `5432`)
- `TEST_DB_NAME`: PostgreSQL database name for tests
- `NEWS_API_KEY`: Your NewsAPI API key (see below)

**Note**: The `.env` file is git-ignored. Never commit sensitive credentials to version control.

## How to Obtain and Use a News API Key

1. **Sign up for NewsAPI**:
   - Visit [https://newsapi.org/register](https://newsapi.org/register)
   - Create a free account (free tier allows 100 requests per day)

2. **Get your API key**:
   - After signing up, navigate to your account dashboard
   - Copy your API key

3. **Add the API key to your environment**:
   - Open `backend/.env`
   - Set `NEWS_API_KEY=your_actual_api_key_here`
   - Restart your Rails server for the changes to take effect

4. **API Usage**:
   - The application uses the NewsAPI "everything" endpoint
   - Free tier: 100 requests per day
   - Paid tiers available for higher limits

## How Keyword Filtering Works

1. **User Keywords**: Authenticated users can add multiple keywords (e.g., "technology", "AI", "Rails")

2. **Query Construction**: 
   - All user keywords are combined using the `AND` operator
   - Example: If a user has keywords "technology" and "AI", the query becomes: `"technology AND AI"`
   - This means articles must contain ALL of the user's keywords

3. **Article Fetching**:
   - The backend service (`NewsApiService`) queries NewsAPI's `/everything` endpoint
   - Articles are sorted by `publishedAt` (most recent first)
   - Limited to 20 articles per request
   - Only English language articles are returned

4. **Real-time Updates**:
   - When a user adds or removes keywords, the article list automatically refreshes
   - Articles are refetched based on the updated keyword list

## How to Run the App

### Development Mode

1. **Start the backend** (from `backend` directory):
   ```bash
   rails server
   ```

2. **Start the frontend** (from `frontend` directory):
   ```bash
   npm run dev
   ```

3. **Access the application**:
   - Open `http://localhost:5173` in your browser
   - Sign up or log in
   - Add keywords to see personalized news articles

### Production Build

1. **Build the frontend**:
   ```bash
   cd frontend
   npm run build
   ```

2. **Serve the frontend** (you can use any static file server):
   ```bash
   npm run preview
   ```

## How to Run Tests

### Backend Tests

From the `backend` directory:

```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/user_test.rb
rails test test/integration/keywords_api_test.rb
rails test test/services/news_api_service_test.rb

# Run tests with verbose output
rails test --verbose
```

**Test Coverage**:
- Model tests (User, Keyword)
- Integration tests (Authentication, Keywords API, Articles API)
- Service tests (NewsApiService with mocked API calls)

### Frontend Tests

Frontend testing is not yet implemented (see Issues section).

## Assumptions and Limitations

### Assumptions

1. **User Authentication**: Users are authenticated via email and password only (no email confirmation required)
2. **Keyword Uniqueness**: Keywords are unique per user (same keyword can exist for different users)
3. **Article Limit**: Currently limited to 20 articles per request (no pagination)
4. **Language**: Only English language articles are fetched
5. **API Rate Limits**: Free NewsAPI tier (100 requests/day) is sufficient for development

### Limitations

1. **Pagination**: Article list is limited to 20 articles with no pagination
2. **Spelling**: NewsAPI does not handle spelling errors in keywords
3. **Synonyms**: No synonym expansion - exact keyword matching only
4. **Article Persistence**: Articles are not stored in the database; they are fetched fresh on each request
5. **Error Handling**: Limited error handling for NewsAPI rate limits or failures
6. **Frontend Testing**: No frontend tests currently implemented

## Issues

### Known Issues

1. **Flaky Tests**: There are some flaky tests around user sign in. They fail sometimes, likely due to session management or timing issues in the test environment.

2. **Double Fetching**: There is a bug in the frontend that fetches keywords and articles routes 2 times in a row after login. This needs to be fixed.

## Future Improvements

### Things I Would Do to Make It Better

1. **OpenAI Embeddings for Synonyms**:
   - Connect backend to OpenAI embeddings API
   - Generate synonyms for user keywords to enhance article fetching
   - This would help find more relevant articles even if exact keywords aren't used

2. **Spell Checking**:
   - Integrate OpenAI or a spell-checking library (e.g., `hunspell`, `typo.js`)
   - NewsAPI does not handle spelling issues, so this would improve user experience
   - Suggest corrections when keywords are misspelled

3. **Pagination**:
   - Article page is currently limited to 20 articles
   - Implement pagination (infinite scroll or page-based)
   - Allow users to load more articles

4. **Frontend Testing**:
   - Add frontend testing framework (Jest + React Testing Library)
   - Test component rendering, user interactions, and API integrations
   - Ensure test coverage for critical user flows

5. **Fix Double Fetching Bug**:
   - Investigate and fix the issue where keywords and articles are fetched twice after login
   - Likely related to React StrictMode or useEffect dependencies

6. **Additional Improvements**:
   - Add article caching to reduce API calls
   - Implement article favorites/bookmarks
   - Add article search functionality
   - Improve error handling and user feedback
   - Add loading states and skeleton screens
   - Implement responsive design improvements
   - Add dark mode support

## Project Structure

```
interview_storyful/
├── backend/                 # Rails API backend
│   ├── app/
│   │   ├── controllers/    # API controllers
│   │   ├── models/         # ActiveRecord models
│   │   ├── services/       # Business logic (NewsApiService)
│   │   └── ...
│   ├── config/
│   │   ├── database.yml    # Database configuration
│   │   └── routes.rb      # API routes
│   ├── test/              # Backend tests
│   └── .env               # Environment variables (git-ignored)
│
└── frontend/              # React frontend
    ├── src/
    │   ├── components/    # React components
    │   ├── contexts/      # React contexts (AuthContext)
    │   └── ...
    └── package.json
```

## API Endpoints

### Authentication
- `POST /users` - Sign up
- `POST /users/sign_in` - Sign in
- `DELETE /users/sign_out` - Sign out

### Keywords
- `GET /keywords` - Get user's keywords
- `POST /keywords` - Create a keyword
- `DELETE /keywords/:id` - Delete a keyword

### Articles
- `GET /articles` - Get articles based on user's keywords

## License

[Add your license here]

## Contributing

[Add contributing guidelines if applicable]

