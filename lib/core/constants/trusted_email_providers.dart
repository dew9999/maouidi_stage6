// lib/core/constants/trusted_email_providers.dart

/// List of trusted email providers that are allowed for signup.
/// This prevents temporary/disposable email services while allowing
/// legitimate email providers.
const List<String> trustedEmailProviders = [
  // Google
  'gmail.com',
  'googlemail.com',

  // Microsoft
  'outlook.com',
  'outlook.fr',
  'hotmail.com',
  'hotmail.fr',
  'live.com',
  'live.fr',
  'msn.com',

  // Yahoo
  'yahoo.com',
  'yahoo.fr',
  'ymail.com',

  // Apple
  'icloud.com',
  'me.com',
  'mac.com',

  // ProtonMail (privacy-focused but legitimate)
  'protonmail.com',
  'proton.me',
  'pm.me',

  // Other major providers
  'aol.com',
  'zoho.com',
  'mail.com',
  'gmx.com',
  'gmx.fr',

  // European providers
  'orange.fr',
  'wanadoo.fr',
  'free.fr',
  'laposte.net',
  'sfr.fr',

  // Algerian providers
  'algeriatel.dz',
  'caramail.com',
];

/// Validates if an email domain is from a trusted provider.
bool isEmailFromTrustedProvider(String email) {
  if (email.isEmpty) return false;

  final emailLower = email.toLowerCase().trim();
  final atIndex = emailLower.lastIndexOf('@');

  if (atIndex == -1 || atIndex == emailLower.length - 1) {
    return false; // Invalid email format
  }

  final domain = emailLower.substring(atIndex + 1);

  return trustedEmailProviders.contains(domain);
}

/// Gets a user-friendly error message for untrusted email domains.
String getUntrustedEmailMessage(String email) {
  final atIndex = email.lastIndexOf('@');
  if (atIndex == -1) {
    return 'Please use a valid email from a trusted provider';
  }

  final domain = email.substring(atIndex + 1);
  return 'Email domain "$domain" is not supported. Please use Gmail, Outlook, Yahoo, or another major email provider.';
}
