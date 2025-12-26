import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @acctlegal.
  ///
  /// In en, this message translates to:
  /// **'Account & Legal'**
  String get acctlegal;

  /// No description provided for @allapts.
  ///
  /// In en, this message translates to:
  /// **'All Appointments'**
  String get allapts;

  /// No description provided for @alldocs.
  ///
  /// In en, this message translates to:
  /// **'All Doctors'**
  String get alldocs;

  /// No description provided for @alrdyappt.
  ///
  /// In en, this message translates to:
  /// **'You already have an active appointment with this provider'**
  String get alrdyappt;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @apptcreated.
  ///
  /// In en, this message translates to:
  /// **'Appointment created successfully'**
  String get apptcreated;

  /// No description provided for @aptcnld.
  ///
  /// In en, this message translates to:
  /// **'Appointment Cancelled'**
  String get aptcnld;

  /// No description provided for @atpartner.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atpartner;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @becomeptr.
  ///
  /// In en, this message translates to:
  /// **'Become a Partner'**
  String get becomeptr;

  /// No description provided for @bookapptbar.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookapptbar;

  /// No description provided for @bookforpatient.
  ///
  /// In en, this message translates to:
  /// **'Book for Patient'**
  String get bookforpatient;

  /// No description provided for @callnext.
  ///
  /// In en, this message translates to:
  /// **'Call Next'**
  String get callnext;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @casedesc.
  ///
  /// In en, this message translates to:
  /// **'Case Description'**
  String get casedesc;

  /// No description provided for @casedescex.
  ///
  /// In en, this message translates to:
  /// **'Describe the patient\'s condition'**
  String get casedescex;

  /// No description provided for @clncanalytics.
  ///
  /// In en, this message translates to:
  /// **'Clinic Analytics'**
  String get clncanalytics;

  /// No description provided for @closeddate.
  ///
  /// In en, this message translates to:
  /// **'This provider is closed on the selected date'**
  String get closeddate;

  /// No description provided for @cnclapt.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cnclapt;

  /// No description provided for @cnclaptq.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get cnclaptq;

  /// No description provided for @cnclaptsure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get cnclaptsure;

  /// No description provided for @cnclconfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get cnclconfirm;

  /// No description provided for @cnclfail.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel appointment'**
  String get cnclfail;

  /// No description provided for @commentshint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get commentshint;

  /// No description provided for @commentsopt.
  ///
  /// In en, this message translates to:
  /// **'Comments (Optional)'**
  String get commentsopt;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @contactus.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactus;

  /// No description provided for @darkmode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkmode;

  /// No description provided for @delacct.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delacct;

  /// No description provided for @fieldreq.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldreq;

  /// No description provided for @fltrdoc.
  ///
  /// In en, this message translates to:
  /// **'Filter Doctors'**
  String get fltrdoc;

  /// No description provided for @fulladdr.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fulladdr;

  /// No description provided for @fulladdrex.
  ///
  /// In en, this message translates to:
  /// **'Street, City, Wilaya'**
  String get fulladdrex;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @getmynum.
  ///
  /// In en, this message translates to:
  /// **'Get My Number'**
  String get getmynum;

  /// No description provided for @getnumberfor.
  ///
  /// In en, this message translates to:
  /// **'Get your queue number'**
  String get getnumberfor;

  /// No description provided for @gotnum.
  ///
  /// In en, this message translates to:
  /// **'Queue number assigned successfully'**
  String get gotnum;

  /// No description provided for @hcdetails.
  ///
  /// In en, this message translates to:
  /// **'Homecare Request Details'**
  String get hcdetails;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @listservices.
  ///
  /// In en, this message translates to:
  /// **'List Services'**
  String get listservices;

  /// No description provided for @loadanalyticsfail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics'**
  String get loadanalyticsfail;

  /// No description provided for @loadptrfail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load partner data'**
  String get loadptrfail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @lvrvw.
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get lvrvw;

  /// No description provided for @markcomp.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markcomp;

  /// No description provided for @myapts.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myapts;

  /// No description provided for @noapts.
  ///
  /// In en, this message translates to:
  /// **'No Appointments'**
  String get noapts;

  /// No description provided for @noaptsfltr.
  ///
  /// In en, this message translates to:
  /// **'No appointments match your filter'**
  String get noaptsfltr;

  /// No description provided for @noaptsfound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noaptsfound;

  /// No description provided for @noaptsmsg.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any appointments yet'**
  String get noaptsmsg;

  /// No description provided for @noslots.
  ///
  /// In en, this message translates to:
  /// **'No available time slots for this date'**
  String get noslots;

  /// No description provided for @nospecialty.
  ///
  /// In en, this message translates to:
  /// **'No Specialty'**
  String get nospecialty;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notworkingday.
  ///
  /// In en, this message translates to:
  /// **'This provider doesn\'t work on this day'**
  String get notworkingday;

  /// No description provided for @pastdateerr.
  ///
  /// In en, this message translates to:
  /// **'Cannot book appointments in the past'**
  String get pastdateerr;

  /// No description provided for @privpolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privpolicy;

  /// No description provided for @ptfullname.
  ///
  /// In en, this message translates to:
  /// **'Patient Full Name'**
  String get ptfullname;

  /// No description provided for @ptphone.
  ///
  /// In en, this message translates to:
  /// **'Patient Phone'**
  String get ptphone;

  /// No description provided for @ptrnotconfig.
  ///
  /// In en, this message translates to:
  /// **'Partner booking system not configured'**
  String get ptrnotconfig;

  /// No description provided for @pushnotif.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushnotif;

  /// No description provided for @qready.
  ///
  /// In en, this message translates to:
  /// **'Queue Ready'**
  String get qready;

  /// No description provided for @ratevisit.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Visit'**
  String get ratevisit;

  /// No description provided for @rcvalerts.
  ///
  /// In en, this message translates to:
  /// **'Receive Alerts'**
  String get rcvalerts;

  /// No description provided for @requestvisit.
  ///
  /// In en, this message translates to:
  /// **'Request Home Visit'**
  String get requestvisit;

  /// No description provided for @reqsent.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully'**
  String get reqsent;

  /// No description provided for @revfail.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get revfail;

  /// No description provided for @saveall.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveall;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @slottaken.
  ///
  /// In en, this message translates to:
  /// **'This time slot is no longer available'**
  String get slottaken;

  /// No description provided for @status_cancelled_by_partner.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by Partner'**
  String get status_cancelled_by_partner;

  /// No description provided for @status_cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by User'**
  String get status_cancelled_by_user;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get status_confirmed;

  /// No description provided for @status_no_show.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get status_no_show;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_rescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get status_rescheduled;

  /// No description provided for @submithcreq.
  ///
  /// In en, this message translates to:
  /// **'Submit Homecare Request'**
  String get submithcreq;

  /// No description provided for @submitreq.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitreq;

  /// No description provided for @submitrev.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitrev;

  /// No description provided for @submittingrev.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submittingrev;

  /// No description provided for @termsserv.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsserv;

  /// No description provided for @thankrev.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankrev;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @upnext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upnext;

  /// No description provided for @yourdash.
  ///
  /// In en, this message translates to:
  /// **'Your Dashboard'**
  String get yourdash;

  /// No description provided for @yournum.
  ///
  /// In en, this message translates to:
  /// **'Your Number'**
  String get yournum;

  /// No description provided for @unnamedptr.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Partner'**
  String get unnamedptr;

  /// No description provided for @notavail.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notavail;

  /// No description provided for @booknow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get booknow;

  /// No description provided for @ptrlist.
  ///
  /// In en, this message translates to:
  /// **'Partner List'**
  String get ptrlist;

  /// No description provided for @nopartners.
  ///
  /// In en, this message translates to:
  /// **'No Partners Found'**
  String get nopartners;

  /// No description provided for @ptrerr.
  ///
  /// In en, this message translates to:
  /// **'Error loading partner'**
  String get ptrerr;

  /// No description provided for @ptridmissing.
  ///
  /// In en, this message translates to:
  /// **'Partner ID is missing'**
  String get ptridmissing;

  /// No description provided for @srchptr.
  ///
  /// In en, this message translates to:
  /// **'Search Partners'**
  String get srchptr;

  /// No description provided for @refinesrch.
  ///
  /// In en, this message translates to:
  /// **'Refine your search'**
  String get refinesrch;

  /// No description provided for @noresults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noresults;

  /// No description provided for @noresultsmsg.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria'**
  String get noresultsmsg;

  /// No description provided for @welcomeback.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeback;

  /// No description provided for @searchhint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, clinics...'**
  String get searchhint;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featuredpartners.
  ///
  /// In en, this message translates to:
  /// **'Featured Partners'**
  String get featuredpartners;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @clinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get clinics;

  /// No description provided for @homecare.
  ///
  /// In en, this message translates to:
  /// **'Homecare'**
  String get homecare;

  /// No description provided for @charities.
  ///
  /// In en, this message translates to:
  /// **'Charities'**
  String get charities;

  /// No description provided for @nofeaturedpartners.
  ///
  /// In en, this message translates to:
  /// **'No featured partners available'**
  String get nofeaturedpartners;

  /// No description provided for @errloadingpartners.
  ///
  /// In en, this message translates to:
  /// **'Error loading featured partners'**
  String get errloadingpartners;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
