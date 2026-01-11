# Add User Authentication

## Goal

Implement JWT-based user authentication system for the application.

## What I Want

- Users can log in with username and password
- Protected routes require valid authentication
- Users can logout
- Tokens can be refreshed without re-authentication

## Context

- Currently there's no authentication - all routes are public
- User model already exists with username and hashed password
- Using Express.js for the backend

## Preferences

- Use JWT (JSON Web Tokens) for stateless auth
- Access tokens should be short-lived (15 minutes)
- Refresh tokens should be longer (7 days)
- Tokens should be invalidated on logout

## Out of Scope

- User registration (that's a separate task)
- Password reset
- OAuth/social login
- Multi-factor authentication

## Success Criteria

- User can log in and receive tokens
- Protected routes reject requests without valid tokens
- User can refresh tokens before they expire
- User can logout and tokens become invalid
- All authentication flows are tested
