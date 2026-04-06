import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

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
    Locale('ne')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @nepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get nepali;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get viewAll;

  /// No description provided for @todaysHarvest.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Harvest'**
  String get todaysHarvest;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fruits, vegetables...'**
  String get searchHint;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @defaultSort.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSort;

  /// No description provided for @priceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low → High'**
  String get priceLowHigh;

  /// No description provided for @priceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High → Low'**
  String get priceHighLow;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @adjustSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustSearch;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'result'**
  String get result;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @vipMember.
  ///
  /// In en, this message translates to:
  /// **'🌟 VIP Member'**
  String get vipMember;

  /// No description provided for @ordersHistory.
  ///
  /// In en, this message translates to:
  /// **'ORDERS & HISTORY'**
  String get ordersHistory;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @recentOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'4 recent orders'**
  String get recentOrdersSub;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @savedItemsSub.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get savedItemsSub;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @manageLocationsSub.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery locations'**
  String get manageLocationsSub;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @cardsWalletsSub.
  ///
  /// In en, this message translates to:
  /// **'Cards & digital wallets'**
  String get cardsWalletsSub;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushEmailSub.
  ///
  /// In en, this message translates to:
  /// **'Push & email settings'**
  String get pushEmailSub;

  /// No description provided for @settingsSub.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsSub;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// No description provided for @addExtra.
  ///
  /// In en, this message translates to:
  /// **'Add something extra?'**
  String get addExtra;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'DELIVER TO'**
  String get deliverTo;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @pickupDetails.
  ///
  /// In en, this message translates to:
  /// **'Pickup Details'**
  String get pickupDetails;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'PICKUP LOCATION'**
  String get pickupLocation;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY ADDRESS'**
  String get deliveryAddress;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'PICKUP TIME'**
  String get pickupTime;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY TIME'**
  String get deliveryTime;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL INSTRUCTIONS'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. No onions, sauce on the side...'**
  String get specialInstructionsHint;

  /// No description provided for @paymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Payment & Confirm'**
  String get paymentConfirm;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name: Sabji mart'**
  String get businessName;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse: Primary HUB'**
  String get warehouse;

  /// No description provided for @billNo.
  ///
  /// In en, this message translates to:
  /// **'Paid Bill No.:'**
  String get billNo;

  /// No description provided for @itemsOrdered.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered'**
  String get itemsOrdered;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate (Rs)'**
  String get rate;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amt (Rs)'**
  String get amount;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashier;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @buzzPoints.
  ///
  /// In en, this message translates to:
  /// **'Buzz Points'**
  String get buzzPoints;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @changePayment.
  ///
  /// In en, this message translates to:
  /// **'Change Payment Method'**
  String get changePayment;

  /// No description provided for @visaEnding.
  ///
  /// In en, this message translates to:
  /// **'Visa ending in'**
  String get visaEnding;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @expressCheckout.
  ///
  /// In en, this message translates to:
  /// **'Express checkout'**
  String get expressCheckout;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashLabel;

  /// No description provided for @payOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pay on delivery or pickup'**
  String get payOnDelivery;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @leafyGreens.
  ///
  /// In en, this message translates to:
  /// **'Leafy Greens'**
  String get leafyGreens;

  /// No description provided for @herbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get herbs;

  /// No description provided for @exotic.
  ///
  /// In en, this message translates to:
  /// **'Exotic'**
  String get exotic;

  /// No description provided for @bestseller.
  ///
  /// In en, this message translates to:
  /// **'Bestseller'**
  String get bestseller;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @organicOnly.
  ///
  /// In en, this message translates to:
  /// **'Organic Only'**
  String get organicOnly;

  /// No description provided for @seasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get seasonal;

  /// No description provided for @localFarm.
  ///
  /// In en, this message translates to:
  /// **'Local Farm'**
  String get localFarm;

  /// No description provided for @premiumGrade.
  ///
  /// In en, this message translates to:
  /// **'Premium Grade'**
  String get premiumGrade;

  /// No description provided for @exportQuality.
  ///
  /// In en, this message translates to:
  /// **'Export Quality'**
  String get exportQuality;

  /// No description provided for @certified.
  ///
  /// In en, this message translates to:
  /// **'Certified'**
  String get certified;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSub.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added anything yet'**
  String get emptyCartSub;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @paymentModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentModeLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @addOns.
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get addOns;

  /// No description provided for @specialInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructionsLabel;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @selectQuantityError.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 item'**
  String get selectQuantityError;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get orderConfirmed;

  /// No description provided for @orderConfirmedDesc.
  ///
  /// In en, this message translates to:
  /// **'We have received your order'**
  String get orderConfirmedDesc;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @preparingDesc.
  ///
  /// In en, this message translates to:
  /// **'Our team is at work'**
  String get preparingDesc;

  /// No description provided for @readyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// No description provided for @readyForPickupDesc.
  ///
  /// In en, this message translates to:
  /// **'Your order will be ready at'**
  String get readyForPickupDesc;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @estReadyAt.
  ///
  /// In en, this message translates to:
  /// **'Est. ready at'**
  String get estReadyAt;

  /// No description provided for @orderProgress.
  ///
  /// In en, this message translates to:
  /// **'Order Progress'**
  String get orderProgress;

  /// No description provided for @stepXofY.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepXofY(Object step, Object total);

  /// No description provided for @trackMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Track My Order'**
  String get trackMyOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @includesItems.
  ///
  /// In en, this message translates to:
  /// **'Includes'**
  String get includesItems;

  /// No description provided for @noItemsInBundle.
  ///
  /// In en, this message translates to:
  /// **'No items in this bundle'**
  String get noItemsInBundle;

  /// No description provided for @bundleInfo.
  ///
  /// In en, this message translates to:
  /// **'This is a bundled offer. When you add this to your cart, you\'ll receive all the items listed above in the specified quantities.'**
  String get bundleInfo;
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
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
