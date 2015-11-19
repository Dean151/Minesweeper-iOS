# Minimal Minesweeper for iOS
This minesweeper game is designed to be the simplest in look and use.
Test it for free on the App Store (when the app will be approved) : http://apple.co/1W5Xw2K

![Screenshot](./screen.png)

# Licence
This source code is on Github for consultation purposes only.
Please **do not** use or reuse all or fraction of this code in one of your project without receiving an authorization from myself.
Feel free to contact me for it anyway !

Nonetheless, you're free to build this app for YOUR PERSONAL USE ONLY.

# Features
* Allow to play Minesweeper in four levels of difficulty (Easy, Medium, Hard and Insane)
* Game Center integration with leaderboards and achievements
* Flat design using iOS7 color palette.
* Ability to mark mines with long press and/or deep press (Deep Press uses 3DTouch if available, but will work on EVERY devices !)
* Otherwise, mine marking with segmented control
* Statistics consultation
* Fully optimized for iPhone and iPad layouts
* Gameplay optimized for touch environment

# Dependancies with Cocoapods
This project use some open source libraries :
* **ChameleonFramework** : Beautiful iOS7 colors packed in a framework
* **Eureka** : Grouped TableView forms made easy in Swift
* **GCHelper** : To handle easily Game Center features
* **HexColors** : UIColor from hexadecimal codes
* **IAPController** : To handle easily In-App purchases
* **iRate** : When conditions are satisfied, ask a review on the AppStore to the user
* **SecureNSUserDefaults** : Encryption for NSUserDefaults data
* **SnapKit** : Easy code side constraint handling

# Building
In order to build, first you will need to install dependancies with Cocoapods :

```pod install```

For Debug building, a Keys.example.xcconfig will be used.
It will not be possible to make a Release build without a valid Keys.xcconfig

Now, you should be able to build a debug version and enjoy the app !

# Tests
The core of the game is tested with units tests, which mean the game itself should always have a correct behavior.

The UI is not tested automatically, but it have been tested manually with a lot of games.
