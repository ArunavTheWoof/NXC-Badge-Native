NXC Badge – Smart Attendance & Identity Ecosystem
Revolutionizing institutional identity and attendance management with NFC-powered technology, AI, and real-time analytics.

📌 About the Project
NXC Badge is not just an attendance app — it’s a complete identity ecosystem for institutions.
Our NFC-enabled solution allows students, staff, and event managers to connect, verify, and manage activities seamlessly.

With a single NFC card, users can:

Mark attendance in seconds

Access personalized dashboards

View hall tickets, news, and shared notes

Share profiles instantly via NFC

For administrators, it provides:

Real-time data tracking

Class, subject, and teacher management

Event attendance exports

Detailed analytics

🚀 Core Features
For Admins
Create & manage classes (name, duration, subjects)

Assign teachers to specific subjects

View, update, or remove teachers from subjects

Export attendance reports for classes and events

For Event Managers
Export attendance data for all gatekeepers

Filter exports by event, gatekeeper, or both

Real-time access to attendance logs

For Gatekeepers
Easy event check-in with NFC scanning

Instant verification of attendee credentials

📊 Tech Stack
Component	Technology
Frontend	Flutter
Backend	Firebase (Firestore, Auth, Functions)
NFC Handling	Flutter NFC Plugins
Authentication	Firebase Auth
Hosting	Firebase Hosting
Analytics	Firebase Analytics

🖼 Block Diagram
pgsql
Copy
Edit
+------------------+         +------------------+
|     NFC Card     | ----->  |   NXC Badge App  |
+------------------+         +------------------+
                                   |
                                   v
                          +------------------+
                          |  Firebase Auth   |
                          +------------------+
                                   |
                                   v
                          +------------------+
                          |  Firestore DB    |
                          +------------------+
                                   |
                                   v
                   +-------------------------------+
                   | Admin Dashboard / Event Mgmt  |
                   +-------------------------------+
📥 Installation & Setup
bash
Copy
Edit
# Clone the repository
git clone https://github.com/nikith-bv/NXC-Badge-Native

# Navigate into the project
cd nxc-badge

# Install dependencies
flutter pub get

# Run the app
flutter run
📌 Usage
Admin
Login with admin credentials

Create classes, assign teachers, manage subjects

Export attendance or event reports

Event Manager
Select event and/or gatekeeper

Export attendance data instantly

Student/Teacher
Tap NFC card to mark attendance

View personal data, class schedule, and updates

📈 Business Impact
Institutions save hours daily on attendance & verification

Events run smoother with automated check-ins

Investors gain entry into a high-demand EdTech & ID Management market with a scalable product