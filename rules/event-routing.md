---
description: "Guidelines for event routing and handling between Phoenix and React. Ensure consistent naming, error handling, and bidirectional event communication."
globs:
  - "**/*.{ex,tsx}"
alwaysApply: false
---
# Event Routing Guidelines

- **Naming Conventions:**  
  - Prefix Phoenix events with `phx:` and use clear, descriptive names.
  
- **Consistency & Cleanup:**  
  - Define event handler functions clearly on both backend and frontend.  
  - Ensure proper registration and cleanup (using try/catch and cleanup functions).

- **Bidirectional Communication:**  
  - Use `push_event` from Phoenix to send updates; React should listen via hooks.
  
- **Error Handling:**  
  - Implement error logging and fallback logic to track any issues in event propagation.
  
- **Reference:**  
  - See @notes/architecture.md for an overview of your project’s event handling system.

