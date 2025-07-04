# دليل بناء تطبيق iOS من Windows

## ❌ القيود:
- **لا يمكن** بناء تطبيقات iOS مباشرة من Windows
- يحتاج **macOS + Xcode** لبناء iOS

## ✅ الحلول البديلة:

### 1. Codemagic (الأسهل) 🚀

#### الخطوات:
1. **إنشاء حساب**: [codemagic.io](https://codemagic.io)
2. **ربط المشروع**: GitHub/GitLab/Bitbucket
3. **إعداد iOS Workflow**
4. **الحصول على Apple Developer Account** ($99/سنة)

#### ملف التكوين `codemagic.yaml`:
```yaml
workflows:
  ios-workflow:
    name: iOS Albrog App
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Set up keychain
        script: keychain initialize
      - name: Set up provisioning profiles
        script: app-store-connect fetch-signing-files com.albrog.app.albrog_mobile_app --type IOS_APP_STORE --create
      - name: Set up signing certificate
        script: keychain add-certificates
      - name: Install dependencies
        script: |
          flutter packages pub get
          find . -name "Podfile" -execdir pod install \;
      - name: Build iOS
        script: |
          flutter build ios --release
          xcode-project use-profiles
          xcode-project build-ipa --workspace ios/Runner.xcworkspace --scheme Runner
    artifacts:
      - build/ios/iphoneos/*.app
      - build/ios/iphoneos/*.ipa
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
```

### 2. GitHub Actions (مجاني جزئياً)

#### `.github/workflows/ios.yml`:
```yaml
name: Build iOS
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.0'
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
```

### 3. Bitrise

#### الخطوات:
1. **إنشاء حساب**: [bitrise.io](https://bitrise.io)
2. **ربط Git Repository**
3. **اختيار Flutter iOS Workflow**
4. **إعداد Code Signing**

## 📋 المتطلبات:

### Apple Developer Account:
- **التكلفة**: $99/سنة
- **المطلوب لـ**:
  - رفع التطبيق على App Store
  - إنشاء Certificates
  - إنشاء Provisioning Profiles

### Bundle Identifier:
```
com.albrog.app.albrog_mobile_app
```

## 🔧 الإعدادات الحالية:

### تم إضافة الصلاحيات لـ iOS:
- ✅ **الموقع**: لإظهار العقارات القريبة
- ✅ **الكاميرا**: لالتقاط صور العقارات
- ✅ **المكتبة**: لاختيار صور العقارات
- ✅ **الإنترنت**: للـ API calls
- ✅ **الهاتف/WhatsApp**: للتواصل

### المكتبات متوافقة مع iOS:
- ✅ جميع المكتبات في `pubspec.yaml` تدعم iOS
- ✅ تم حل مشاكل التوافق

## 🚀 خطة العمل الموصى بها:

### المرحلة 1 (الآن):
1. **إنهاء التطوير** على Android
2. **اختبار جميع الميزات**
3. **تجهيز الكود** للإنتاج

### المرحلة 2 (بناء iOS):
1. **إنشاء Apple Developer Account**
2. **استخدام Codemagic** لبناء iOS
3. **اختبار على iOS devices**
4. **رفع على App Store**

## 💡 نصائح:

### للتطوير:
- استمر بالتطوير على **Windows/Android**
- استخدم **Flutter Web** للعرض التوضيحي
- جهز **Screenshots** و **App Store assets**

### للنشر:
- خطط **Apple Developer Account** مبكراً
- جهز **App Store metadata** (العربية/الإنجليزية)
- اختبر على **أجهزة iOS** حقيقية

## 📞 التواصل:
إذا كنت بحاجة لمساعدة في إعداد Codemagic أو Apple Developer Account، يمكنني مساعدتك خطوة بخطوة. 