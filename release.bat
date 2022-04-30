set app= motuo.apk
flutter build apk &&^
copy build\app\outputs\apk\release\app-release.apk .\ &&^
del/f/s/q %app%  &&^
rename app-release.apk %app% &&^
echo ==== build successfully %app% =====
