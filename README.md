# Task Manager App

A Flutter task management app that connects to a REST API, displays tasks in different views, and works offline with local caching.

## What It Does

The app lets you view tasks from an online API, add new tasks, and switch between list and grid layouts. It saves your preferences and keeps working even without internet by storing data locally.

## Main Features

- View tasks in list or grid format
- Filter tasks by status (all, completed, pending)
- Add new tasks with a simple form
- See detailed information for each task
- Dark mode support
- Works offline with cached data
- Pull down to refresh the task list
- Save your preferences

## API Used

I'm using JSONPlaceholder (https://jsonplaceholder.typicode.com) for the backend:
- `/todos` - Gets all tasks
- `/todos/{id}` - Gets one task
- `/todos` (POST) - Creates a task

## What I Built With

- Flutter 3.0+
- http package for API calls
- shared_preferences for saving data locally

## How the App is Organized
```
lib/
├── main.dart - Starts the app
├── models/
│   └── task.dart - Task data structure
├── services/
│   ├── api_service.dart - Handles API requests
│   └── cache_service.dart - Manages local storage
├── screens/
│   ├── home_screen.dart - Main screen
│   ├── task_detail_screen.dart - Shows task details
│   ├── task_form_screen.dart - Form to add tasks
│   └── settings_screen.dart - App settings
└── widgets/
    └── task_card.dart - Task display component
```

## Running the Project

1. Make sure Flutter is installed
2. Clone the project
3. Run `flutter pub get`
4. Run `flutter run`

## What Works

**API Connection**
- Fetching tasks from API
- Creating new tasks
- Handling errors and timeouts
- Converting JSON to app data

**User Interface**
- Scrollable task lists
- Grid view option
- Loading animations
- Error messages with retry button
- Filtering options
- Pull-to-refresh

**Offline Support**
- Saves tasks locally
- Remembers your settings
- Shows cached tasks when offline
- Indicates offline status

**Code Organization**
- Clean file structure
- Separate logic from display
- Easy to understand code

**Everything Else**
- Form validation
- Settings that actually work
- No crashes

## Things I Figured Out

Getting the offline mode to work smoothly was tricky. I had to make sure the app could tell when it was offline and switch to cached data without confusing the user.

Form validation took some time to get right - making sure users can't submit incomplete or wrong data.

Managing when to refresh data versus when to use cached data required some thinking about user experience.

## What Could Be Better

- Search bar to find specific tasks
- Edit existing tasks
- Delete tasks with swipe gesture
- Sort tasks different ways
- More filter options

---
