# GRC Running Club Frontend

A modern React TypeScript frontend for the GRC Running Club management system.

## Features

- **Dashboard**: Overview of club statistics and quick actions
- **Athletes Management**: View and manage club athletes
- **Races**: Browse race information and results
- **Workouts**: Training session management
- **Admin Panel**: Administrative functions (coming soon)

## Tech Stack

- **React 18** with TypeScript
- **Vite** for fast development and building
- **React Router** for client-side routing
- **Axios** for API communication
- **Tailwind CSS** for styling

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Running GRC API backend (see `../grc-api/`)

### Installation

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

3. Update `.env` with your API configuration:
   ```env
   VITE_API_URL=http://localhost:8080/api/v1
   ```

### Development

Start the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Building for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
src/
├── components/     # Reusable UI components
├── pages/         # Page components
├── services/      # API services
├── types/         # TypeScript type definitions
├── utils/         # Utility functions
├── hooks/         # Custom React hooks
├── App.tsx        # Main app component with routing
└── main.tsx       # App entry point
```

## API Integration

The frontend communicates with the Go backend API. Make sure the backend is running on the configured URL.

## Contributing

1. Follow the existing code style
2. Use TypeScript for type safety
3. Test your changes with the development server
4. Ensure API calls handle errors appropriately
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
