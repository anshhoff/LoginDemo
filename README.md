# Flutter Supabase Phone Authentication

A Flutter application demonstrating phone number authentication using Supabase, featuring OTP verification and a clean, modern UI.

## Features

- 📱 Phone number authentication with OTP
- 🔒 Secure authentication using Supabase
- 🎨 Modern and responsive UI
- 📝 Form validation and error handling
- 🔄 OTP resend functionality
- 📊 Detailed logging for debugging
- 🌐 Support for Indian phone numbers

## Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Supabase account
- Twilio account (for SMS delivery)

## Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd logindemo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new project in [Supabase](https://supabase.com)
   - Enable Phone Auth in Authentication → Providers
   - Configure SMS provider (Twilio) in Authentication → SMS Provider
   - Copy your Supabase URL and anon key

4. **Configure Environment**
   Create a `.env` file in the root directory:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. **Configure Twilio**
   - Sign up for a [Twilio](https://www.twilio.com) account
   - Get a phone number that supports SMS
   - Configure in Supabase:
     - Account SID
     - Auth Token
     - From Number (in E.164 format, e.g., +1234567890)

## Phone Number Format

The app supports the following phone number formats:
- 10-digit numbers starting with 6-9 (e.g., 9179982488)
- Numbers with +91 prefix (e.g., +919179982488)

The app will automatically format numbers to the E.164 format required by Supabase.

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── supabase_login_screen.dart
│   └── home_screen.dart
├── services/
│   └── auth_service.dart
└── widgets/
    └── (custom widgets)
```

## Usage

1. **Phone Number Input**
   - Enter a valid 10-digit Indian phone number
   - The app will automatically format it to include the +91 prefix

2. **OTP Verification**
   - Enter the 6-digit OTP received via SMS
   - Use the resend option if OTP expires

3. **Error Handling**
   - Invalid phone numbers
   - OTP validation
   - Network errors
   - Twilio configuration issues

## Debugging

The app includes detailed logging for debugging:
- Phone number validation
- Formatting process
- OTP sending and verification
- Error details

View logs in:
- Flutter DevTools
- Terminal output
- Debug console

## Common Issues

1. **Invalid Phone Number Format**
   - Ensure the number is 10 digits
   - Must start with 6-9
   - No spaces or special characters

2. **Twilio Configuration**
   - Verify Twilio credentials
   - Check "From" number format
   - Ensure SMS capabilities are enabled

3. **OTP Not Received**
   - Check phone number format
   - Verify Twilio configuration
   - Check Supabase logs

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [Twilio](https://www.twilio.com)

## Support

For support, please:
1. Check the [issues](https://github.com/yourusername/logindemo/issues)
2. Review the [documentation](https://supabase.com/docs)
3. Contact the maintainers

## Roadmap

- [ ] Add biometric authentication
- [ ] Implement rate limiting
- [ ] Add phone number formatting as user types
- [ ] Support for international phone numbers
- [ ] Add unit and widget tests
