# **edugitual**

**edugitual** is an open-source classroom platform designed as an alternative to **GitHub Classroom**, allowing teachers and students to collaborate on coding assignments using self-hosted Git services such as **Forgejo**.

## Project Overview

**edugitual** connects classrooms with Git-based workflows — assignments, automated grading, and collaborative group work — in a single integrated environment.

### Key Features

-   Manage **subjects**, **classes**, and **assignments**
-   Clear **roles**: teacher vs. student
-   Built-in **commenting and review** system
-   View **class-wide progress** or **individual student performance**
-   Simple **group assignment setup**
-   Integration with **self-hosted Git services** (Forgejo, Gitea, GitLab)

## Technology Stack

**edugitual** is a full-stack TypeScript project:

-   **Backend:** [NestJS](https://nestjs.com/) + [Prisma ORM](https://www.prisma.io/) + [SQLite](https://sqlite.org)
-   **Frontend:** [Vue 3](https://vuejs.org/) + [Vite](https://vitejs.dev/) + [Capacitor](https://capacitorjs.com/)
-   **Git Hosting:** Forgejo (via Docker)
-   **Mobile builds:** Android APK via Docker container and local emulator

## Project Structure

```bash
.
├── backend/            # NestJS API
│   ├── src/            # Controllers, services, modules
│   ├── prisma/         # Prisma schema and SQLite DB
│   ├── test/           # Unit & e2e tests
│   └── package.json
│
├── frontend/           # Vue 3 + Vite + Capacitor app
│   ├── src/            # Components, router, stores
│   ├── public/         # Static assets
│   └── package.json
│
├── forgejo/            # Forgejo container and setup scripts
│   ├── app.ini         # Default configuration
│   ├── Dockerfile
│   ├── entrypoint.sh   # Startup & initialization logic
│   ├── create-users.sh # Default users (admin, teacher, students)
│   ├── create-token.sh # Admin API token
│   └── data/           # Mounted volume for repositories, DB, etc.
│
├── android/            # Android build container
│   ├── Dockerfile
│   ├── build-apk.sh    # Builds debug or release APK
│   └── start-emulator.sh # Script to start local emulator
│
├── docker-compose.yml
└── README.md
```

---

## Prerequisites

- [**Docker** and **Docker Compose**](https://docs.docker.com/get-docker/) for running Forgejo and building Android APKs
- [**Node.js 20+**](https://nodejs.org/) for local frontend/backend development
- [**Android SDK & Emulator**](https://developer.android.com/studio?hl=de) for building and testing APKs

## Development Setup

### 1\. Clone the repository

### 2\. Start Forgejo

If you haven't used docker before, add your user to the `docker` group

```shell
sudo groupmod --append --users $USER docker
```

To avoid having to log in again before the change becomes active, run

```shell
newgrp docker
```

Now you can start the forgejo container

```bash
docker compose up --build forgejo
```

This will start **Forgejo** (http://localhost:3001) and set up default users:

-   `root` / `root123` (admin)
-   `teacher` / `teacher123`
-   `student1` ... `student10` with password `studentX123`

An API token is stored in `/data/token.env`.

## Backend (NestJS + Prisma)

Run locally:

```bash
cd backend
npm install
npm run start:dev
```

-   API: [http://localhost:3000](http://localhost:3000)
-   SQLite database: `backend/prisma/dev.db`

## Frontend (Vue + Vite + Capacitor)

Run locally:

```bash
cd frontend
npm install
npx ionic serve
```

-   App: [http://localhost:5173](http://localhost:5173)
-   Automatically connects to backend API

## Android Build

Before building the APK in Docker, prepare the frontend locally. Run
the following commands from the `frontend/` directory.

```bash
# Build frontend for production
npm run build

# Add Android platform (only once)
npx ionic capacitor add android

# Copy web assets to the Android project
npx ionic cap copy

# Sync Capacitor plugins (run whenever new plugins are added)
npx ionic cap sync
```

This ensures that the latest frontend build is included in the Android APK.

### Build APKs

The Android build runs inside a Docker container. To build the container once,
run in this project's root directory:

```bash
docker compose build android
```

Then start it with:

```bash
docker compose run android bash
```

Inside the container, you can now build APKs. Note, that the first build will
take a while, but dependencies are mounted on your host system to speed up
future builds:

```bash
# Build debug APK
/app/build-apk.sh

# Build release APK
/app/build-apk.sh release
```

- Output APKs are placed in `/android/output/` (mounted volume)
    
### Start Emulator

Install Android SDK (you don’t need the full Android Studio — unless you really
want to sacrifice disk space 😄).

Use the included `start-emulator.sh` script to launch a local Android emulator:

```bash
./android/start-emulator.sh
```

- The script will automatically:
  - Check if an emulator AVD exists, create it if necessary
  - Start the emulator
  - Wait until the device is fully booted
        
Note: The script is tailored to my local setup and may require minor adjustments for your environment.

If you already have a working Android development setup, you may use an
emulator and android virtual device (AVD) of that setup. Assuming that the
emulator binary is in your path, you could start the emulator via

```shell
emulator -avd $YOUR_AVD
```


### Install APK

While the emulator is running, the apk can be (re-)installed using

```bash
adb install -r android/output/debug/app-debug.apk
```

## Testing

### Backend (Jest)

```bash
cd backend
npm test
```

### Frontend (Vitest & Cypress)

```bash
cd frontend
npm run test:unit    # Unit tests
npm run test:e2e     # End-to-end tests
```

## Production Builds

### Backend

```bash
cd backend
npm run build
```

Output: `backend/dist/`

### Frontend

```bash
cd frontend
npm run build
```

Output: `frontend/dist/` (serve via Nginx or similar)

### Forgejo

Forgejo runs inside Docker. Persistent data is stored in `forgejo/data/`.

## Debugging

- Backend: attach VS Code debugger (`npm run start:debug`)
- Frontend: browser DevTools with Vite source maps
- Forgejo: `docker logs forgejo`
- Android: check `/android/output` and use `adb logcat`

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPLv3).

You are free to use, modify, and distribute this software under the terms of the AGPLv3. If you make modifications and deploy this software on a server, you must make the complete corresponding source code available to users interacting with it over the network.

See the [LICENSE](./LICENSE) file for the full text.

© 2025 Simon Gunacker and contributors
# edugitual
