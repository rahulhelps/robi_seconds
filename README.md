# QuickCV Pro - BDApps Integration

This document outlines the recently integrated features and architectural changes for the **QuickCV Pro** application (originally developed as `flutterapp` and updated to match the BDApps workflow of `robi_seconds-main`).

---

## 1. Authentication & OTP Flow

The application has fully migrated to a robust phone-number-based OTP flow backed by BDApps.

### Key Workflows:
- **Phone Input (`PhoneInputCard`)**: Users enter their phone number. If they are an active Robi/Airtel user (i.e. already registered in BDApps), the system can detect this state and automatically verify or redirect them appropriately.
- **OTP Delivery**: Handled via `BDAppsService.sendOtp(phone)`. A reference number is obtained upon success.
- **OTP Verification (`VerificationScreen`)**: Users enter the 6-digit OTP code sent to them.
- **JWT Persistence**: Upon successful OTP validation, `BDAppsService.verifyOtp` automatically exchanges the OTP for a long-lived JWT token and user profile data, saving them securely to local storage via `TokenManager` and `UserStorage`.

### Bypass Logic Removed
- **Strict Validation**: All legacy "debug bypass" mechanisms have been strictly removed. There are no longer any `DevConstants` for auto-bypassing OTPs. Users must verify their phone numbers properly to access the dashboard.

---

## 2. Billing & Subscription (Premium Content)

The app now properly integrates the BDApps Carrier Billing architecture, seamlessly gating premium templates.

- **Status Checking**: Upon a successful login or OTP verification, the `AuthBloc` automatically marks the local subscription status as active (`UserStorage.updateSubscriptionStatus(true)`). 
- **Premium Checks (`SecureStorageHelper`)**: Any widget or screen (e.g., `SopTemplateScreen`, `EmailTemplateScreen`, `TemplateGrid`) displaying premium content explicitly checks if the user has an active subscription.
  - If `isSubscriptionActive` is true, the user has full access to download/export premium CV, Email, and SOP templates.
  - If false or unauthenticated, premium templates remain locked, and the user is navigated back to the authentication flow or subscription prompt.

---

## 3. Modular BLoC Architecture

State management is cleanly organized using `flutter_bloc`, mirroring the robust structure previously found in `robi_seconds-main`.

- **AuthBloc**: Central hub for handling OTP dispatch, verification, login success, subscription checks, and user logouts.
- **DashboardBloc**: Controls bottom navigation state and top-level interactions in the Dashboard (Home, Documents, Payments, Profile, Mock Tests).
- **ProfileBloc / PackagesBloc / SopBloc**: Dedicated state managers for their respective feature domains, all automatically re-fetched upon reconnection if the user was temporarily offline (handled by `ConnectivityBloc`).

---

## 4. UI / UX Enhancements

- **Splash Screen**: Now handles the initial gating logic natively. It checks if the user is fully logged in and whether their subscription is active before seamlessly transitioning to the `Dashboard` or the `AuthScreen`.
- **Clean Action Cards**: The dashboard is styled with modern action cards for immediate access to core tools (CV Builder, Cover Letters, Portfolios, etc.).
- **Dynamic Navigation**: A custom-styled `DashboardBottomNavBar` supports deep linking and maintains a sleek profile view.

## 5. Security Details

- Tokens (`accessToken`, `refreshToken`) and sensitive user data (`isSubscriptionActive`) are stored securely using `flutter_secure_storage`.
- Network calls gracefully timeout and fallback to cached states when appropriate to ensure uninterrupted offline experiences where possible.
