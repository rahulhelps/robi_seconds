class AuthStrings {
  static Map<String, Map<String, String>> values = {
    'en': {
      'loginTitle': 'QuickCV Pro',
      'loginSubtitle': 'Create a professional CV in minutes.',
      'loginHeroTitle': 'Register',
      'loginHeroSubtitle':
          'Enter your phone number to access your career profile.',
      'phoneHint': '01XXXXXXXXX',
      'sendCode': 'Send Code',
      'enterPhone': 'Please enter your phone number',
      'invalidPhone': 'Enter a valid Bangladeshi number (e.g. 018XXXXXXXX)',
      'robiAirtelBenefit':
          'Only ৳2/day (including VAT, SD & SC). Available for Robi and Airtel users only.',
      'otherNetworkBenefit':
          'You are not using Robi/Airtel number, so you need to purchase premium separately.',
      'otpSentDesc': 'A 6-digit verification code (OTP) will be sent.',
      'verificationTitle': 'Verification Code',
      'verificationDesc': 'Please enter the 4-digit code sent to your phone.',
      'verifyOtp': 'Verify OTP',
      'invalidOtp': 'Please enter a valid 4-digit code',
      'invalidOtp6': 'Please enter a valid 6-digit code',
      'verificationDesc6': 'Please enter the 6-digit code sent to your phone.',
      'otpSentDesc6': 'A 6-digit verification code (OTP) will be sent.',
      'subscriptionExpiredTitle': 'Subscription Expired',
      'subscriptionExpiredDesc':
          'Your Robi/Airtel daily subscription (2 BDT/day) is no longer active. Re-subscribe to continue using QuickCV Pro.',
      'resubscribe': 'Re-subscribe',
      'subscriptionPendingTitle': 'Processing Subscription',
      'subscriptionPendingDesc':
          'Your subscription is being activated. This may take a few seconds…',
      'emailTitle': 'Email Registration',
      'emailDesc': 'Add an email to sync your CVs across devices.',
      'emailHint': 'nittotech@mail.com',
      'addEmail': 'Add Email',
      'skipDashboard': 'Not now, take me to Dashboard',
    },
    'bn': {
      'loginTitle': 'কুইকসিভি প্রো',
      'loginSubtitle': 'কয়েক মিনিটের মধ্যে একটি পেশাদার সিভি তৈরি করুন।',
      'loginHeroTitle': 'রেজিস্ট্রেশন',
      'loginHeroSubtitle':
          'আপনার ক্যারিয়ার প্রোফাইল অ্যাক্সেস করতে আপনার ফোন নম্বর লিখুন।',
      'phoneHint': '০১XXXXXXXXX',
      'sendCode': 'কোড পাঠান',
      'enterPhone': 'আপনার ফোন নম্বর লিখুন',
      'invalidPhone': 'সঠিক বাংলাদেশি নম্বর লিখুন (উদা: ০১৮XXXXXXXX)',
      'robiAirtelBenefit':
          'প্রতিদিন মাত্র ২ টাকা চার্জ (VAT+SD+SC সহ)। শুধুমাত্র রবি ও এয়ারটেল গ্রাহকদের জন্য।',
      'otherNetworkBenefit':
          'আপনি রবি/এয়ারটেল নম্বর ব্যবহার করছেন না, তাই আপনাকে আলাদাভাবে প্রিমিয়াম কিনতে হবে।',
      'otpSentDesc': 'একটি ৬-অঙ্কের ভেরিফিকেশন কোড (OTP) পাঠানো হবে।',
      'verificationTitle': 'ভেরিফিকেশন কোড',
      'verificationDesc': 'আপনার ফোনে পাঠানো ৪-অঙ্কের কোডটি লিখুন।',
      'verifyOtp': 'ওটিপি যাচাই করুন',
      'invalidOtp': 'দয়া করে একটি সঠিক ৪-অঙ্কের কোড লিখুন',
      'invalidOtp6': 'দয়া করে একটি সঠিক ৬-অঙ্কের কোড লিখুন',
      'verificationDesc6': 'আপনার ফোনে পাঠানো ৬-অঙ্কের কোডটি লিখুন।',
      'otpSentDesc6': 'একটি ৬-অঙ্কের ভেরিফিকেশন কোড (OTP) পাঠানো হবে।',
      'subscriptionExpiredTitle': 'সাবস্ক্রিপশন মেয়াদ শেষ',
      'subscriptionExpiredDesc':
          'আপনার রবি/এয়ারটেল দৈনিক সাবস্ক্রিপশন (২ টাকা/দিন) সক্রিয় নেই। QuickCV Pro ব্যবহার চালিয়ে যেতে পুনরায় সাবস্ক্রাইব করুন।',
      'resubscribe': 'পুনরায় সাবস্ক্রাইব করুন',
      'subscriptionPendingTitle': 'সাবস্ক্রিপশন প্রক্রিয়াকরণ',
      'subscriptionPendingDesc':
          'আপনার সাবস্ক্রিপশন সক্রিয় হচ্ছে। কিছুক্ষণ অপেক্ষা করুন…',
      'emailTitle': 'ইমেইল রেজিস্ট্রেশন',
      'emailDesc': 'আপনার সিভি বিভিন্ন ডিভাইসে সিঙ্ক করতে একটি ইমেইল যোগ করুন।',
      'emailHint': 'nittotech@mail.com',
      'addEmail': 'ইমেইল যোগ করুন',
      'skipDashboard': 'এখন নয়, ড্যাশবোর্ডে যান',
    },
  };

  static String get(String key, String lang) {
    return values[lang]?[key] ?? values['en']![key]!;
  }
}
