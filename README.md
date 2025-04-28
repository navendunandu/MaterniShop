# Mamasphere

Mamasphere is a comprehensive maternity platform consisting of three interconnected Flutter applications designed to support the maternity journey:

## Applications

### 1. User Application (user_maternityapp)
A feature-rich mobile application for expecting mothers that includes:
- Pregnancy tracking and weekly updates
- Baby development information
- Personalized diet plans and exercise routines
- Weight tracking
- Shopping for maternity products
- Community features
- Payment integration with Razorpay
- Appointment booking system

### 2. Shop Application (shop_maternityapp)
A dedicated platform for maternity shop owners featuring:
- Product management system
- Order tracking
- Sales analytics
- Customer management
- Inventory control
- Sales reporting
- Complaint management

### 3. Admin Application (admin_maternityapp)
An administrative dashboard for platform management with:
- User management
- Shop approval system
- Content moderation
- Analytics and reporting
- System configuration

## Technical Stack

- **Frontend Framework:** Flutter
- **Backend Service:** Supabase
- **Database:** PostgreSQL (via Supabase)
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage
- **Additional Services:**
  - Firebase (User App)
  - Razorpay (Payments)
  - File Management
  - PDF Generation

## Key Features

- **Authentication & Authorization**
- **Real-time Data Sync**
- **File Upload & Management**
- **Responsive Design**
- **Cross-platform Support**
  - Android
  - iOS
  - Web
  - Linux
  - Windows

## Getting Started

1. Clone the respective repositories:
```bash
git clone [user-app-repo-url]
git clone [shop-app-repo-url]
git clone [admin-app-repo-url]
```

2. Install dependencies for each application:
```bash
cd user_maternityapp
flutter pub get

cd ../shop_maternityapp
flutter pub get

cd ../admin_maternityapp
flutter pub get
```

3. Configure environment variables and Supabase credentials

4. Run the applications:
```bash
flutter run
```

## Requirements

- Flutter SDK ^3.6.0
- Dart SDK
- Supabase Account
- Firebase Project (for user app)
- Razorpay Account (for payments)

## Contributing

Please read our contributing guidelines before submitting pull requests.

## License

[Add your license information here]

## Contact

[Add your contact information here]
