# Haze Clue Production Guide & Architecture Overview

This document outlines the current production-ready state of the Haze Clue Monitoring System. It serves as a technical reference for developers, AI assistants, and hardware integration engineers.

## 1. System Architecture

The system is built on a decoupled architecture ensuring high scalability, real-time data processing, and seamless internationalization.

### Frontend (Haze_clue_website)
- Framework: Nuxt 3 (Vue 3, Composition API)
- Styling: Tailwind CSS & Nuxt UI v4 (Glassmorphism design system)
- State Management: Pinia
- Real-time Communication: Socket.io-client
- Localization: @nuxtjs/i18n (English & Arabic)

### Backend (haze_clue_backend)
- Framework: NestJS
- Database: MongoDB (Mongoose ODM)
- Real-time Communication: Socket.io (NestJS WebSockets Gateway)
- Security: JWT Authentication, Password Hashing

## 2. Completed Features

### Frontend Finished Implementations
- Authentication: Login and Registration flow.
- Dashboard Layout: Responsive sidebar, top navigation, and dark mode toggle.
- Device Management: Adding, viewing, and removing hardware devices with proper validation and UI states.
- Live Session Monitoring: Real-time graphs and metrics updating via WebSocket. Ability to add timeline markers during a session.
- Notifications Engine: Global real-time dropdown alert system with unread counts and read receipts.
- User Settings: Profile updates, password changes, and boolean toggles (2FA, Email Notifications) that successfully persist to the backend.
- Full Localization: All static text across the dashboard, devices, and settings is fully translated between English and Arabic.

### Backend Finished Implementations
- User Module: Complete CRUD, authentication, and profile settings persistence.
- Session Module: Handles the lifecycle of a class session, storing timeline markers, and calculating final averages upon session completion.
- Notification Module: Triggers system alerts (Info, Warning, Critical) based on session events (e.g., specific marker keywords like "Attention Drop").
- Dashboard Aggregation: Performs dynamic MongoDB queries to calculate actual class attention averages and fetch recent session activity.
- WebSocket Gateway: Manages client connections, live session rooms, and broadcasts real-time alerts to specific users.
- Telemetry API: An open REST endpoint for hardware integration.

## 3. Hardware Integration Guide

To connect physical EEG or BCI devices to the Haze Clue system, hardware engineers should utilize the Telemetry API. 

The backend exposes a direct endpoint designed to accept raw hardware metrics and instantly pipe them into the live WebSocket streams.

### Telemetry Endpoint
- URL: POST /api/telemetry
- Content-Type: application/json

### Payload Schema
The endpoint expects a JSON payload containing the following fields:

{
  "deviceId": "string",
  "attention": "number (0-100)",
  "meditation": "number (0-100)",
  "delta": "number (optional)",
  "theta": "number (optional)",
  "alpha": "number (optional)",
  "beta": "number (optional)",
  "gamma": "number (optional)"
}

### Integration Example (Python)

import requests
import time

TELEMETRY_URL = 'http://localhost:3001/api/telemetry'
DEVICE_ID = 'SN-123456789'

def send_eeg_data(attention_score, meditation_score):
    payload = {
        "deviceId": DEVICE_ID,
        "attention": attention_score,
        "meditation": meditation_score
    }
    
    try:
        response = requests.post(TELEMETRY_URL, json=payload)
        if response.status_code == 201:
            print("Data transmitted successfully")
    except Exception as e:
        print("Failed to transmit data:", e)

# Example loop for continuous monitoring
while True:
    # Read values from serial/bluetooth hardware here
    current_attention = 85
    current_meditation = 60
    
    send_eeg_data(current_attention, current_meditation)
    time.sleep(1) # Send data every second

## 4. Production Deployment Notes

- Environment Variables: Ensure all `.env` files are properly configured for production (e.g., removing localhost URIs, setting strong JWT secrets, and updating MongoDB connection strings).
- Static Assets: Run `npm run build` on the Nuxt frontend to generate the optimized `.output` production bundle.
- Process Management: It is recommended to use PM2 or Docker containers to manage both the NestJS server and the Nuxt Node server in a production environment.
- WebSocket Scaling: If scaling horizontally, ensure a Redis adapter is configured for Socket.io to allow cross-container message broadcasting.
