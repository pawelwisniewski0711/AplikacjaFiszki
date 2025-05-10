I'll analyze the project files and create a comprehensive README.md. Let me first check each file to gather the necessary information.

Read file: .ai/prd.md

Ran tool
<no message>

Read file: .ai/tech-stack.md
<no message>

Ran tool
<no message>

Read file: package.json
<no message>

Ran tool
<no message>

Read file: .nvmrc
<readme_planning>
## Key Information from Input Files

### PRD (prd.md)
- Project name: AplikacjaFiszki
- Project description: Web application for creating and managing educational flashcards using AI
- Key features:
  - AI-generated flashcards from user-provided text
  - Manual flashcard creation and management
  - User authentication system
  - Integration with spaced repetition algorithm
  - Statistics on flashcard generation
- Out of scope for MVP:
  - Advanced custom spaced repetition algorithm
  - Gamification
  - Mobile apps
  - Document import (PDF, DOCX)
  - Public API
  - Flashcard sharing between users
  - Advanced notification system
  - Advanced keyword search
- User stories cover:
  - Registration and login
  - AI flashcard generation
  - Reviewing and approving flashcard suggestions
  - Editing and deleting flashcards
  - Manual flashcard creation
  - Learning sessions with spaced repetition
  - Secure access and authorization

### Tech Stack (tech-stack.md)
- Frontend:
  - Astro 5
  - React 19
  - TypeScript 5
  - Tailwind 4
  - Shadcn/ui components
- Backend:
  - Supabase (PostgreSQL database, authentication, BaaS)
- AI:
  - Openrouter.ai for LLM API access
- CI/CD & Hosting:
  - GitHub Actions
  - DigitalOcean (Docker)

### Dependencies (package.json)
- Project name: AplikacjaFiszki
- Version: 0.0.1
- Scripts:
  - dev: "astro dev"
  - build: "astro build"
  - preview: "astro preview"
  - astro: "astro"
  - lint: "eslint ."
  - lint:fix: "eslint . --fix"
  - format: "prettier --write ."
- Key dependencies:
  - astro: 5.5.5
  - react: 19.0.0
  - react-dom: 19.0.0
  - tailwindcss: 4.0.17
  - Various UI libraries (radix, class-variance-authority, etc.)
- Dev dependencies:
  - ESLint and related plugins
  - Prettier
  - TypeScript tools
  - Husky for git hooks
  - lint-staged

### Node Version (.nvmrc)
- Node.js version: 22.14.0

## README Outline

1. Project name
   - AplikacjaFiszki

2. Project description
   - Brief overview of the application
   - Main features and benefits
   - Problem it solves

3. Tech stack
   - Frontend technologies
   - Backend technologies
   - AI integration
   - CI/CD & Hosting

4. Getting started locally
   - Prerequisites (Node.js version)
   - Installation steps
   - Environment setup (Supabase, Openrouter.ai)

5. Available scripts
   - Development commands
   - Build commands
   - Linting and formatting

6. Project scope
   - Current features
   - Out of scope features

7. Project status
   - Current version
   - Development stage (MVP)

8. License
   - Not specified in the provided files, will use MIT as default

## Missing Information
- Detailed setup instructions for Supabase
- API key setup for Openrouter.ai
- Specific license information
- Project roadmap beyond MVP
- Contribution guidelines
</readme_planning>

# AplikacjaFiszki

A web application for creating and managing educational flashcards powered by AI. The app enables users to quickly generate flashcards from text using LLM models and manage their learning with spaced repetition.

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/pawelwisniewski0711/10XFiszki)
[![Node](https://img.shields.io/badge/node-22.14.0-green.svg)](https://nodejs.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Table of Contents

- [Project Description](#project-description)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## Project Description

AplikacjaFiszki solves the problem of time-consuming manual flashcard creation by leveraging AI to generate high-quality learning materials. The application allows users to:

- Generate flashcards automatically from pasted text using AI
- Create, edit, and manage flashcards manually
- Study using a spaced repetition algorithm
- Track flashcard generation and learning statistics

The goal is to make the effective spaced repetition learning method more accessible by reducing the time needed to create quality study materials.

## Tech Stack

### Frontend
- **Astro 5** - Fast, efficient page rendering with minimal JavaScript
- **React 19** - For interactive components
- **TypeScript 5** - Static typing and improved IDE support
- **Tailwind 4** - Utility-first CSS framework
- **Shadcn/ui** - Accessible React component library

### Backend
- **Supabase** - PostgreSQL database, authentication, and Backend-as-a-Service

### AI Integration
- **Openrouter.ai** - Access to various LLM models for flashcard generation

### CI/CD & Hosting
- **GitHub Actions** - CI/CD pipelines
- **DigitalOcean** - Application hosting via Docker

## Getting Started

### Prerequisites

- Node.js 22.14.0 (use [nvm](https://github.com/nvm-sh/nvm) to manage Node.js versions)
- Supabase account
- Openrouter.ai API key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/AplikacjaFiszki.git
   cd AplikacjaFiszki
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the root directory with the following variables:
   ```
   PUBLIC_SUPABASE_URL=your_supabase_url
   PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   OPENROUTER_API_KEY=your_openrouter_api_key
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Open your browser and navigate to `http://localhost:4321`

## Available Scripts

- `npm run dev` - Start the development server
- `npm run build` - Build the production version
- `npm run preview` - Preview the production build locally
- `npm run astro` - Run Astro CLI commands
- `npm run lint` - Run ESLint to check code quality
- `npm run lint:fix` - Fix linting issues automatically
- `npm run format` - Format code using Prettier

## Project Scope

### Current Features (MVP)

- User authentication (registration, login)
- AI-powered flashcard generation from text
- Manual flashcard creation and management
- Basic spaced repetition learning algorithm integration
- User-specific flashcard storage
- Generation statistics

### Out of Scope for MVP

- Advanced custom spaced repetition algorithm
- Gamification features
- Mobile applications
- Document import (PDF, DOCX, etc.)
- Public API
- Flashcard sharing between users
- Advanced notification system
- Advanced keyword search for flashcards

## Project Status

The project is currently in MVP (Minimum Viable Product) development stage. Version 0.0.1 is under active development.

Success metrics for the MVP:
- 75% of AI-generated flashcards are accepted by users
- At least 75% of all new flashcards are created using AI assistance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
