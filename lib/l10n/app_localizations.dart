import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @thisApplication.
  ///
  /// In en, this message translates to:
  /// **'This Application help you to find phone by'**
  String get thisApplication;

  /// No description provided for @specificVoice.
  ///
  /// In en, this message translates to:
  /// **'specific voice & save your phone'**
  String get specificVoice;

  /// No description provided for @unknownPerson.
  ///
  /// In en, this message translates to:
  /// **' from unknown person'**
  String get unknownPerson;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello !'**
  String get hello;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login Here'**
  String get loginHere;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back you\'ve'**
  String get welcomeBack;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'been missed !'**
  String get missed;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @noUser.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email'**
  String get noUser;

  /// No description provided for @wrongEmail.
  ///
  /// In en, this message translates to:
  /// **'wrong Password provided by user '**
  String get wrongEmail;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE  ACCOUNT'**
  String get createAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Create an account so you can take the '**
  String get account;

  /// No description provided for @advantage.
  ///
  /// In en, this message translates to:
  /// **'advantage of application'**
  String get advantage;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'Enter First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Enter Last Name'**
  String get lastName;

  /// No description provided for @signupWith.
  ///
  /// In en, this message translates to:
  /// **'sign up with'**
  String get signupWith;

  /// No description provided for @weekPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weekPassword;

  /// No description provided for @accountExit.
  ///
  /// In en, this message translates to:
  /// **'Account already exist'**
  String get accountExit;

  /// No description provided for @registerSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Register Successfully'**
  String get registerSuccessfully;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to'**
  String get pleaseEnter;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'reset your password'**
  String get resetYourPassword;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email '**
  String get sendEmail;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'we have sent you a email , please check your inbox'**
  String get checkInbox;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @speakSeek.
  ///
  /// In en, this message translates to:
  /// **'Speak Seek'**
  String get speakSeek;

  /// No description provided for @securePhone.
  ///
  /// In en, this message translates to:
  /// **'Secure your Phone & Secure your Future'**
  String get securePhone;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @provide.
  ///
  /// In en, this message translates to:
  /// **'This Application Provide you Some '**
  String get provide;

  /// No description provided for @unique.
  ///
  /// In en, this message translates to:
  /// **'unique features for your Phone'**
  String get unique;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get active;

  /// No description provided for @deActive.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deActive;

  /// No description provided for @personalize.
  ///
  /// In en, this message translates to:
  /// **'Personalized Voice'**
  String get personalize;

  /// No description provided for @triggerExecution.
  ///
  /// In en, this message translates to:
  /// **'Trigger Execution'**
  String get triggerExecution;

  /// No description provided for @screenLock.
  ///
  /// In en, this message translates to:
  /// **'Screen Lock'**
  String get screenLock;

  /// No description provided for @screenUnlock.
  ///
  /// In en, this message translates to:
  /// **'Screen Unlock'**
  String get screenUnlock;

  /// No description provided for @alertSystem.
  ///
  /// In en, this message translates to:
  /// **'Alert System'**
  String get alertSystem;

  /// No description provided for @audioRecording.
  ///
  /// In en, this message translates to:
  /// **'Audio Recording'**
  String get audioRecording;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @mobileLocation.
  ///
  /// In en, this message translates to:
  /// **'Mobile Location'**
  String get mobileLocation;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @guideLine.
  ///
  /// In en, this message translates to:
  /// **'Guide Line'**
  String get guideLine;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get security;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'The SpeakSeek – Find My Phone by Voice app is designed to help users locate their phone using a specific voice phrase while ensuring strong privacy and security protections. The app may collect limited data including voice recordings (used solely for recognizing the custom wake phrase), microphone access (only when enabled by the user),device location (to display phone position), and optional login credentials (such as email) for syncing settings. with voice recognition typically processed locally on the device unless cloud-based services like speech brain are explicitly used. Firebase or similar secure platforms may be used for authentication and cloud storage. The app requires user consent for all permissions and allows users to disable voice detection or delete their voice data and account at any time. We do not collect data from children under 13. Third-party services we integrate with follow their own privacy practices. This policy may be updated occasionally,and users will be informed of any major changes.'**
  String get privacy;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'1.Getting Started '**
  String get gettingStarted;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download and install SpeakSeek from the app store.Open the app and allow microphone and location permissions.Sign in  to save your settings securely'**
  String get download;

  /// No description provided for @wakePhrase.
  ///
  /// In en, this message translates to:
  /// **'2.Set Your Wake Phrase'**
  String get wakePhrase;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Record your custom voice phrase like: “Phone, where are you?”Make sure to speak clearly in a quiet place.You can change this phrase anytime in settings.'**
  String get custom;

  /// No description provided for @theApp.
  ///
  /// In en, this message translates to:
  /// **'3.Using the App'**
  String get theApp;

  /// No description provided for @losePhone.
  ///
  /// In en, this message translates to:
  /// **'When you lose your phone nearby, say your wake phrase.The app will detect your voice and ring the phone loudly, even if it\'s on silent.You can also see the phone’s last location on the map if tracking is enabled'**
  String get losePhone;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'4.Voice Training Tips'**
  String get training;

  /// No description provided for @normalVoice.
  ///
  /// In en, this message translates to:
  /// **'Speak the same way every time.Don’t whisper or shout—use your normal voice.Re-record the wake phrase if detection doesn’t work.'**
  String get normalVoice;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'5.Safety & Privacy'**
  String get safety;

  /// No description provided for @stored.
  ///
  /// In en, this message translates to:
  /// **'Your voice data is stored securely.You can turn off voice detection anytime.You can delete your account and data from the settings.'**
  String get stored;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'6.Battery & Performance'**
  String get battery;

  /// No description provided for @smallAmount.
  ///
  /// In en, this message translates to:
  /// **'SpeakSeek uses a small amount of battery to keep listening.To save battery, you can pause the voice detection when not needed.'**
  String get smallAmount;

  /// No description provided for @troubleshooting.
  ///
  /// In en, this message translates to:
  /// **'7.Troubleshooting'**
  String get troubleshooting;

  /// No description provided for @responding.
  ///
  /// In en, this message translates to:
  /// **'Not responding? Make sure microphone permission is on.Location not showing? Enable location access in phone settings.Wake phrase not working? Re-record your phrase more clearly.'**
  String get responding;

  /// No description provided for @voiceEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Personalized Voice Enrollment'**
  String get voiceEnrollment;

  /// No description provided for @reorganization.
  ///
  /// In en, this message translates to:
  /// **' & Reorganization'**
  String get reorganization;

  /// No description provided for @passCode.
  ///
  /// In en, this message translates to:
  /// **'Pass Code'**
  String get passCode;

  /// No description provided for @whistle.
  ///
  /// In en, this message translates to:
  /// **'Whistle'**
  String get whistle;

  /// No description provided for @clapping.
  ///
  /// In en, this message translates to:
  /// **'Clapping'**
  String get clapping;

  /// No description provided for @ring.
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get ring;

  /// No description provided for @vibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get vibrate;

  /// No description provided for @flash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get flash;

  /// No description provided for @selectRingtone.
  ///
  /// In en, this message translates to:
  /// **'Select Ringtone'**
  String get selectRingtone;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record Your Voice'**
  String get recordAudio;

  /// No description provided for @flashTrigger.
  ///
  /// In en, this message translates to:
  /// **'Turn on the flash trigger'**
  String get flashTrigger;

  /// No description provided for @vibrateTrigger.
  ///
  /// In en, this message translates to:
  /// **'Turn on the vibrate trigger'**
  String get vibrateTrigger;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get startTracking;

  /// No description provided for @sendLocation.
  ///
  /// In en, this message translates to:
  /// **'Start Sending My Location '**
  String get sendLocation;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone to Track'**
  String get track;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Your Phone Number (e.g. +923001112223)'**
  String get number;

  /// No description provided for @trackUser.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackUser;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History Maintenance'**
  String get history;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
