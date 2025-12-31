import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

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

  /// No description provided for @booknow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get booknow;

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

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @charities.
  ///
  /// In en, this message translates to:
  /// **'Charities'**
  String get charities;

  /// No description provided for @clinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get clinics;

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

  /// No description provided for @commentsopt.
  ///
  /// In en, this message translates to:
  /// **'Comments (Optional)'**
  String get commentsopt;

  /// No description provided for @commentshint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get commentshint;

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

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @errloadingpartners.
  ///
  /// In en, this message translates to:
  /// **'Error loading featured partners'**
  String get errloadingpartners;

  /// No description provided for @featuredpartners.
  ///
  /// In en, this message translates to:
  /// **'Featured Partners'**
  String get featuredpartners;

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

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @homecare.
  ///
  /// In en, this message translates to:
  /// **'Homecare'**
  String get homecare;

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

  /// No description provided for @nofeaturedpartners.
  ///
  /// In en, this message translates to:
  /// **'No featured partners available'**
  String get nofeaturedpartners;

  /// No description provided for @nopartners.
  ///
  /// In en, this message translates to:
  /// **'No Partners Found'**
  String get nopartners;

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

  /// No description provided for @notavail.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notavail;

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

  /// No description provided for @ptrlist.
  ///
  /// In en, this message translates to:
  /// **'Partner List'**
  String get ptrlist;

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

  /// No description provided for @refinesrch.
  ///
  /// In en, this message translates to:
  /// **'Refine your search'**
  String get refinesrch;

  /// No description provided for @reqsent.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully'**
  String get reqsent;

  /// No description provided for @requestvisit.
  ///
  /// In en, this message translates to:
  /// **'Request Home Visit'**
  String get requestvisit;

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

  /// No description provided for @searchhint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, clinics...'**
  String get searchhint;

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

  /// No description provided for @srchptr.
  ///
  /// In en, this message translates to:
  /// **'Search Partners'**
  String get srchptr;

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

  /// No description provided for @status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get status_in_progress;

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

  /// No description provided for @unnamedptr.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Partner'**
  String get unnamedptr;

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

  /// No description provided for @welcomeback.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeback;

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

  /// No description provided for @specialty_anatomy.
  ///
  /// In en, this message translates to:
  /// **'Pathological Anatomy and Cytology'**
  String get specialty_anatomy;

  /// No description provided for @specialty_anesthesiology.
  ///
  /// In en, this message translates to:
  /// **'Anesthesiology'**
  String get specialty_anesthesiology;

  /// No description provided for @specialty_biochemistry.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry'**
  String get specialty_biochemistry;

  /// No description provided for @specialty_biophysics.
  ///
  /// In en, this message translates to:
  /// **'Medical Biophysics'**
  String get specialty_biophysics;

  /// No description provided for @specialty_cardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get specialty_cardiology;

  /// No description provided for @specialty_cardiovascular_surgery.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular Surgery'**
  String get specialty_cardiovascular_surgery;

  /// No description provided for @specialty_child_psychiatry.
  ///
  /// In en, this message translates to:
  /// **'Child Psychiatry'**
  String get specialty_child_psychiatry;

  /// No description provided for @specialty_cobstetrics_gynecology.
  ///
  /// In en, this message translates to:
  /// **'Obstetrics and Gynecology'**
  String get specialty_cobstetrics_gynecology;

  /// No description provided for @specialty_dentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get specialty_dentist;

  /// No description provided for @specialty_dermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get specialty_dermatology;

  /// No description provided for @specialty_emergency_medicine.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get specialty_emergency_medicine;

  /// No description provided for @specialty_endocrinology.
  ///
  /// In en, this message translates to:
  /// **'Endocrinology and Diabetology'**
  String get specialty_endocrinology;

  /// No description provided for @specialty_ent.
  ///
  /// In en, this message translates to:
  /// **'ENT (Otorhinolaryngology)'**
  String get specialty_ent;

  /// No description provided for @specialty_epidemiology.
  ///
  /// In en, this message translates to:
  /// **'Epidemiology and Preventive Medicine'**
  String get specialty_epidemiology;

  /// No description provided for @specialty_forensic_medicine.
  ///
  /// In en, this message translates to:
  /// **'Forensic Medicine'**
  String get specialty_forensic_medicine;

  /// No description provided for @specialty_gastroenterology.
  ///
  /// In en, this message translates to:
  /// **'Gastroenterology and Hepatology'**
  String get specialty_gastroenterology;

  /// No description provided for @specialty_general_practice.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get specialty_general_practice;

  /// No description provided for @specialty_general_surgery.
  ///
  /// In en, this message translates to:
  /// **'General Surgery'**
  String get specialty_general_surgery;

  /// No description provided for @specialty_gynecology.
  ///
  /// In en, this message translates to:
  /// **'Gynecology'**
  String get specialty_gynecology;

  /// No description provided for @specialty_hematology.
  ///
  /// In en, this message translates to:
  /// **'Hematology (Clinical)'**
  String get specialty_hematology;

  /// No description provided for @specialty_hematology_bio.
  ///
  /// In en, this message translates to:
  /// **'Hematology (Biological)'**
  String get specialty_hematology_bio;

  /// No description provided for @specialty_histology.
  ///
  /// In en, this message translates to:
  /// **'Histology, Embryology and Cytogenetics'**
  String get specialty_histology;

  /// No description provided for @specialty_immunology.
  ///
  /// In en, this message translates to:
  /// **'Immunology'**
  String get specialty_immunology;

  /// No description provided for @specialty_infectious_diseases.
  ///
  /// In en, this message translates to:
  /// **'Infectious Diseases'**
  String get specialty_infectious_diseases;

  /// No description provided for @specialty_internal_medicine.
  ///
  /// In en, this message translates to:
  /// **'Internal Medicine'**
  String get specialty_internal_medicine;

  /// No description provided for @specialty_maxillofacial_surgery.
  ///
  /// In en, this message translates to:
  /// **'Maxillofacial Surgery'**
  String get specialty_maxillofacial_surgery;

  /// No description provided for @specialty_microbiology.
  ///
  /// In en, this message translates to:
  /// **'Microbiology'**
  String get specialty_microbiology;

  /// No description provided for @specialty_nephrology.
  ///
  /// In en, this message translates to:
  /// **'Nephrology'**
  String get specialty_nephrology;

  /// No description provided for @specialty_neurology.
  ///
  /// In en, this message translates to:
  /// **'Neurology'**
  String get specialty_neurology;

  /// No description provided for @specialty_neurophysiology.
  ///
  /// In en, this message translates to:
  /// **'Clinical Neurophysiology'**
  String get specialty_neurophysiology;

  /// No description provided for @specialty_neurosurgery.
  ///
  /// In en, this message translates to:
  /// **'Neurosurgery'**
  String get specialty_neurosurgery;

  /// No description provided for @specialty_nuclear_medicine.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Medicine'**
  String get specialty_nuclear_medicine;

  /// No description provided for @specialty_occupational_medicine.
  ///
  /// In en, this message translates to:
  /// **'Occupational Medicine'**
  String get specialty_occupational_medicine;

  /// No description provided for @specialty_oncology.
  ///
  /// In en, this message translates to:
  /// **'Medical Oncology'**
  String get specialty_oncology;

  /// No description provided for @specialty_ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get specialty_ophthalmology;

  /// No description provided for @specialty_orthopedics.
  ///
  /// In en, this message translates to:
  /// **'Orthopedics'**
  String get specialty_orthopedics;

  /// No description provided for @specialty_parasitology.
  ///
  /// In en, this message translates to:
  /// **'Parasitology and Mycology'**
  String get specialty_parasitology;

  /// No description provided for @specialty_pediatric_surgery.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Surgery'**
  String get specialty_pediatric_surgery;

  /// No description provided for @specialty_pediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get specialty_pediatrics;

  /// No description provided for @specialty_pharmacology.
  ///
  /// In en, this message translates to:
  /// **'Pharmacology'**
  String get specialty_pharmacology;

  /// No description provided for @specialty_physical_rehab.
  ///
  /// In en, this message translates to:
  /// **'Physical Medicine and Rehabilitation'**
  String get specialty_physical_rehab;

  /// No description provided for @specialty_physiology.
  ///
  /// In en, this message translates to:
  /// **'Physiology'**
  String get specialty_physiology;

  /// No description provided for @specialty_plastic_surgery.
  ///
  /// In en, this message translates to:
  /// **'Plastic and Reconstructive Surgery'**
  String get specialty_plastic_surgery;

  /// No description provided for @specialty_pneumology.
  ///
  /// In en, this message translates to:
  /// **'Pneumology'**
  String get specialty_pneumology;

  /// No description provided for @specialty_psychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry'**
  String get specialty_psychiatry;

  /// No description provided for @specialty_public_health.
  ///
  /// In en, this message translates to:
  /// **'Public Health'**
  String get specialty_public_health;

  /// No description provided for @specialty_radiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get specialty_radiology;

  /// No description provided for @specialty_radiotherapy.
  ///
  /// In en, this message translates to:
  /// **'Radiotherapy'**
  String get specialty_radiotherapy;

  /// No description provided for @specialty_rheumatology.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology'**
  String get specialty_rheumatology;

  /// No description provided for @specialty_sports_medicine.
  ///
  /// In en, this message translates to:
  /// **'Sports Medicine'**
  String get specialty_sports_medicine;

  /// No description provided for @specialty_stomatology.
  ///
  /// In en, this message translates to:
  /// **'Stomatology'**
  String get specialty_stomatology;

  /// No description provided for @specialty_thoracic_surgery.
  ///
  /// In en, this message translates to:
  /// **'Thoracic Surgery'**
  String get specialty_thoracic_surgery;

  /// No description provided for @specialty_toxicology.
  ///
  /// In en, this message translates to:
  /// **'Toxicology'**
  String get specialty_toxicology;

  /// No description provided for @specialty_transfusion_medicine.
  ///
  /// In en, this message translates to:
  /// **'Transfusion Medicine'**
  String get specialty_transfusion_medicine;

  /// No description provided for @specialty_urology.
  ///
  /// In en, this message translates to:
  /// **'Urology'**
  String get specialty_urology;

  /// No description provided for @specialty_vascular_surgery.
  ///
  /// In en, this message translates to:
  /// **'Vascular Surgery'**
  String get specialty_vascular_surgery;

  /// No description provided for @state_adrar.
  ///
  /// In en, this message translates to:
  /// **'Adrar'**
  String get state_adrar;

  /// No description provided for @state_ain_defla.
  ///
  /// In en, this message translates to:
  /// **'Ain Defla'**
  String get state_ain_defla;

  /// No description provided for @state_ain_temouchent.
  ///
  /// In en, this message translates to:
  /// **'Ain Temouchent'**
  String get state_ain_temouchent;

  /// No description provided for @state_alger.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get state_alger;

  /// No description provided for @state_algiers.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get state_algiers;

  /// No description provided for @state_annaba.
  ///
  /// In en, this message translates to:
  /// **'Annaba'**
  String get state_annaba;

  /// No description provided for @state_batna.
  ///
  /// In en, this message translates to:
  /// **'Batna'**
  String get state_batna;

  /// No description provided for @state_bechar.
  ///
  /// In en, this message translates to:
  /// **'Bechar'**
  String get state_bechar;

  /// No description provided for @state_bejaia.
  ///
  /// In en, this message translates to:
  /// **'Bejaia'**
  String get state_bejaia;

  /// No description provided for @state_biskra.
  ///
  /// In en, this message translates to:
  /// **'Biskra'**
  String get state_biskra;

  /// No description provided for @state_blida.
  ///
  /// In en, this message translates to:
  /// **'Blida'**
  String get state_blida;

  /// No description provided for @state_bordj_bou_arreridj.
  ///
  /// In en, this message translates to:
  /// **'Bordj Bou Arreridj'**
  String get state_bordj_bou_arreridj;

  /// No description provided for @state_bouira.
  ///
  /// In en, this message translates to:
  /// **'Bouira'**
  String get state_bouira;

  /// No description provided for @state_boumerdes.
  ///
  /// In en, this message translates to:
  /// **'Boumerdes'**
  String get state_boumerdes;

  /// No description provided for @state_chlef.
  ///
  /// In en, this message translates to:
  /// **'Chlef'**
  String get state_chlef;

  /// No description provided for @state_constantine.
  ///
  /// In en, this message translates to:
  /// **'Constantine'**
  String get state_constantine;

  /// No description provided for @state_djelfa.
  ///
  /// In en, this message translates to:
  /// **'Djelfa'**
  String get state_djelfa;

  /// No description provided for @state_el_bayadh.
  ///
  /// In en, this message translates to:
  /// **'El Bayadh'**
  String get state_el_bayadh;

  /// No description provided for @state_el_tarf.
  ///
  /// In en, this message translates to:
  /// **'El Tarf'**
  String get state_el_tarf;

  /// No description provided for @state_ghardaia.
  ///
  /// In en, this message translates to:
  /// **'Ghardaia'**
  String get state_ghardaia;

  /// No description provided for @state_guelma.
  ///
  /// In en, this message translates to:
  /// **'Guelma'**
  String get state_guelma;

  /// No description provided for @state_illizi.
  ///
  /// In en, this message translates to:
  /// **'Illizi'**
  String get state_illizi;

  /// No description provided for @state_jijel.
  ///
  /// In en, this message translates to:
  /// **'Jijel'**
  String get state_jijel;

  /// No description provided for @state_khenchela.
  ///
  /// In en, this message translates to:
  /// **'Khenchela'**
  String get state_khenchela;

  /// No description provided for @state_laghouat.
  ///
  /// In en, this message translates to:
  /// **'Laghouat'**
  String get state_laghouat;

  /// No description provided for @state_mascara.
  ///
  /// In en, this message translates to:
  /// **'Mascara'**
  String get state_mascara;

  /// No description provided for @state_medea.
  ///
  /// In en, this message translates to:
  /// **'Medea'**
  String get state_medea;

  /// No description provided for @state_mila.
  ///
  /// In en, this message translates to:
  /// **'Mila'**
  String get state_mila;

  /// No description provided for @state_mostaganem.
  ///
  /// In en, this message translates to:
  /// **'Mostaganem'**
  String get state_mostaganem;

  /// No description provided for @state_msila.
  ///
  /// In en, this message translates to:
  /// **'M\'Sila'**
  String get state_msila;

  /// No description provided for @state_naama.
  ///
  /// In en, this message translates to:
  /// **'Naama'**
  String get state_naama;

  /// No description provided for @state_oran.
  ///
  /// In en, this message translates to:
  /// **'Oran'**
  String get state_oran;

  /// No description provided for @state_ouargla.
  ///
  /// In en, this message translates to:
  /// **'Ouargla'**
  String get state_ouargla;

  /// No description provided for @state_oued_souf.
  ///
  /// In en, this message translates to:
  /// **'El Oued'**
  String get state_oued_souf;

  /// No description provided for @state_oum_el_bouaghi.
  ///
  /// In en, this message translates to:
  /// **'Oum El Bouaghi'**
  String get state_oum_el_bouaghi;

  /// No description provided for @state_relizane.
  ///
  /// In en, this message translates to:
  /// **'Relizane'**
  String get state_relizane;

  /// No description provided for @state_saida.
  ///
  /// In en, this message translates to:
  /// **'Saida'**
  String get state_saida;

  /// No description provided for @state_setif.
  ///
  /// In en, this message translates to:
  /// **'Setif'**
  String get state_setif;

  /// No description provided for @state_sidi_bel_abbes.
  ///
  /// In en, this message translates to:
  /// **'Sidi Bel Abbes'**
  String get state_sidi_bel_abbes;

  /// No description provided for @state_skikda.
  ///
  /// In en, this message translates to:
  /// **'Skikda'**
  String get state_skikda;

  /// No description provided for @state_souk_ahras.
  ///
  /// In en, this message translates to:
  /// **'Souk Ahras'**
  String get state_souk_ahras;

  /// No description provided for @state_tamanrasset.
  ///
  /// In en, this message translates to:
  /// **'Tamanrasset'**
  String get state_tamanrasset;

  /// No description provided for @state_tebessa.
  ///
  /// In en, this message translates to:
  /// **'Tebessa'**
  String get state_tebessa;

  /// No description provided for @state_tiaret.
  ///
  /// In en, this message translates to:
  /// **'Tiaret'**
  String get state_tiaret;

  /// No description provided for @state_tindouf.
  ///
  /// In en, this message translates to:
  /// **'Tindouf'**
  String get state_tindouf;

  /// No description provided for @state_tipaza.
  ///
  /// In en, this message translates to:
  /// **'Tipaza'**
  String get state_tipaza;

  /// No description provided for @state_tissemsilt.
  ///
  /// In en, this message translates to:
  /// **'Tissemsilt'**
  String get state_tissemsilt;

  /// No description provided for @state_tizi_ouzou.
  ///
  /// In en, this message translates to:
  /// **'Tizi Ouzou'**
  String get state_tizi_ouzou;

  /// No description provided for @state_tlemcen.
  ///
  /// In en, this message translates to:
  /// **'Tlemcen'**
  String get state_tlemcen;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
