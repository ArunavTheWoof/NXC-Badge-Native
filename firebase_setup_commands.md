# Firebase SHA Certificate Setup Commands

## 📋 **Commands to Generate SHA Certificates**

### **For Debug (Development) Build:**
```powershell
# Navigate to your project directory
cd "D:\Projects\NXC\NXC-Badge-Native"

# Generate SHA-1 and SHA-256 for Debug keystore
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### **Alternative Method using Gradle:**
```powershell
# Run this from your project root
./gradlew signingReport
```

### **For Release Build (Future):**
```powershell
# When you create a release keystore, use:
keytool -list -v -keystore "path\to\your\release.keystore" -alias your_alias_name
```

## 🔧 **Firebase Configuration Steps:**

1. **Generate SHA certificates** using the commands above
2. **Copy the SHA-1 and SHA-256 values** from the output
3. **Go to your Firebase Console** (https://console.firebase.google.com)
4. **Select your project** → **Project Settings** (gear icon)
5. **Go to "Your apps"** section
6. **Click on your Android app** (com.example.test_app1)
7. **Add the SHA certificates** in the "SHA certificate fingerprints" section
8. **Download the updated google-services.json** file
9. **Replace** the existing file in `android/app/google-services.json`

## 📱 **Expected Output Format:**
```
Certificate fingerprints:
     MD5:  XX:XX:XX:...
     SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
     SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

## ⚡ **Quick Test Command:**
After updating Firebase configuration:
```powershell
flutter clean
flutter pub get
flutter run
```

---
**Note:** The debug keystore password is always `android` and the alias is `androiddebugkey`.
