# 📓 Capture!

**Capture** is a super-fast, elegant note-taking app inspired by Google Keep. Its core philosophy is simplicity and speed — removing all unnecessary features that slow down the note-taking process. 

Unlike many modern note-taking apps that overwhelm users with excessive functionality, **Capture** is designed to be lightweight, fluid, and frustration-free.

> 🚀 The app is currently at version **v2.0.0** — marking the first public release committed to GitHub.

---

## ✨ Features Overview

### 🏠 Home Screen

- Displays all saved notes.
- App bar includes:
  - Button to **switch between grid and list view**.
  - Button to **navigate to the archive screen**.
  - Button to **open the settings screen**.
- A **search bar** appears just below the app bar:
  - Helps you quickly find notes.
  - Automatically hides the cursor when it loses focus.
  - Includes a **clear (×)** button to reset the input.
- Supports two layout modes:
  - 🟨 **Grid view** for a compact, colorful layout.
  - 📋 **List view** with support for **drag-and-drop reordering** *(currently has minor bugs)*.
- Floating Action Button (‘+’) allows quick note creation.

---

### 📝 Creating & Editing Notes

- Supports notes with:
  - Optional **title** and **content**.
  - **Dynamic sizing**: If no title is provided, space is removed for a cleaner look.
- Notes are **saved automatically** when using back navigation (`Navigator.pop`), but **not saved if the app is force closed**.
- Tapping an existing note opens the **editor screen**:
  - Cursor immediately focuses in the content area for fast typing.
  - Both title and content fields are **scrollable** for long notes.
- The **three-dot menu** in the editor screen contains the **same options** as the note card on the home screen:
  - Change note color.
  - Share note content with other apps.
  - Archive the note.
  - Delete the note.

---

### 🎨 Note Appearance

- Notes have clean **borders for visual distinction** on transparent notes.
  - Colored notes **do not** have borders for a cleaner look.
- Design is consistent across both **light and dark modes**.
  - Transparent notes appear **white in dark mode** for better readability.
- App uses a **yellow seed color** to theme the interface.
- Supports **transparent notes** for enhanced aesthetics.

---

### 📋 Note Options Menu

- Every note card on the home screen includes a **three-dot menu**, offering:
  - Change color.
  - Share with other apps.
  - Archive note.
  - Delete note.
- The **editor screen** includes an identical **options menu** in the top-right corner.

---

### ⚙️ Settings

- **Settings screen** includes:
  - Toggle for **AMOLED dark mode** across the app.
  - **Export notes** feature:
    - Exports **all notes** in simple, readable text format:
      ```
      Title:
      Content:
      ---
      Title:
      Content:
      ```
    - This format allows easy sharing to other apps like email, messaging, or plain text storage.
  - **Import notes** feature:
    - Opens a **text field** where you can paste the exported format above.
    - The app intelligently splits the text into **multiple separate notes**.

---

### 🔍 Smart Features

- **Blank notes are automatically deleted**.
- **Clickable links** work when viewing notes on the home screen.
  - (Note: Links are not clickable in the editing screen.)
- You can **import text and links** shared from other apps into Capture to quickly store information.

---

### 🖼️ Branding

- Comes with a custom-designed **app icon/logo** tailored for Capture’s minimal aesthetic.

---

## 🛠️ Data Storage

- Notes are stored **locally** using **SharedPreferences**.
  - Ensures fast performance and complete offline access.
  - No external cloud syncing — your data stays on your device.

---

**Capture** is built with performance, elegance, and minimalism in mind — giving you a lightning-fast way to **jot down thoughts, collect links, and stay organized**, all without the bloat.

---


