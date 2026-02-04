# Pro-Apps-App-External-IDs
Collection of various App External IDs for Apple Pro apps and Apple productivity apps.

These are useful for downloading older versions of an app from the Mac App Store.

Anywhere an application version is listed where the App External ID is missing means it's still needed -- please help contribute!

So far, I've been compiling lists for: Final Cut Pro, Motion, Compressor, Logic Pro, and MainStage

As well as some non-Pro Apps: GarageBand, iMovie, Keynote, Pages, Numbers, and Pixelmator Pro

In this repo are csv files for each of the referenced apps. I've provided sources (when available) for where the App External ID was found.

# Installing a specific version
> Note: The method below is currently the only way to obtain older versions of Final Cut Pro, Compressor and Motion from the Mac App Store on OS versions older than 15.6.*

**I've created a fork of the MAS-CLI and patched version 1.9.0's code (as it has good OS support) to accept a version argument at runtime.**

Once you've identified the app version's App External ID you're looking for, you can run this patched version of MAS to install the specific app version from Terminal.


**MAS 1.9.0 Patched:** https://github.com/handyandy87/mas-cli-appExtVrsId-patcher

# How to contribute your App External ID
This project maps macOS App Store app versions to their corresponding **App External ID**. The easiest way to contribute is to share any App External IDs that are missing from the repo.
You can obtain these in a few different ways:
1. Generate a crash report for the running app and copy the values directly from the crash report popup.
2. Alternatively, you can try the **masreceipt-extid-finder** script included in this repo to have terminal print the information for you -- I've not tested much beyond my own machine so success may vary.
3. Possibly other methods that I'm not aware of -- let me know!

Please submit those three values exactly as shown (plus the app name) by creating a new issue.

> Note: App External IDs are only present in application packages obtained from the Mac App Store. Those packages contain a MASReceipt folder with a "receipt" file that report the App External ID information to the OS. Applications obtained outside the Mac App Store will not have a receipt file and cannot be used to help identify App External IDs.


## Option 1: How to find your **App External ID** (by forcing a crash report)


These steps intentionally generate a crash report for a running Mac App Store app so you can read its **App External ID** from the report dialog.

> Example app used below: **Compressor** (the same steps work for any other app).

### 1) Launch the app

Open the app normally (Finder, Spotlight, or Dock), or from Terminal:

*Replace "Compressor" with your app name*
```bash
open -a "Compressor"
```

### 2) Find the app’s PID
*Replace "Compressor" with your app name*
```bash
pgrep -x "Compressor"
```
> Example terminal output showing the app's PID:
```bash
50811
```

### 3) Force a crash report using sudo kill -3 <PID>
*Replace with the number you found above*
```bash
sudo kill -3 <PID>
```
>Example if the PID was 50811:
```bash
sudo kill -3 50811
```

### 4) Copy the values from the crash report popup
After the crash report appears, look for these fields towards the very top:
1. Version
2. App Item ID
3. App External ID

> Example excerpt from crash report, for Compressor 4.6.5
```code
Process: Compressor [50811]
Path: /Applications/Compressor.app/Contents/MacOS/Compressor
Identifier: com.apple.Compressor
Version: 4.6.5 (408047)
Build Info: Compressor-40800047016000000~4 (20A104)
App Item ID: 424390742
App External ID: 858081833
```

## Option 2: How to find your **App External ID** (by using masreceipt-extid-finder)

I've cobbled together a QND script to retrieve the App External ID by parsing the values found in the application's associated MASReceipt.

This is useful if you're trying to obtain the App External ID information on an application package that wasn't installed on the current system from the Mac App Store (e.g., backup copy saved on an external hard drive)

When you run this script, terminal will print:
```bash
bundle_id    ##the app’s bundle identifier (example: `com.apple.Compressor`)
application_version    ##the app’s version number (example: `4.6.5`)
app_item_id    ##the Mac App Store App Item ID (example:  `424390742`
app_external_id    ##the Mac App Store External Item ID (example:  `858081833`)
```

### 1) Download the script from the releases section of this repo
  https://github.com/handyandy87/Pro-Apps-App-External-IDs/releases


### 2) Open Terminal
Go > Utilities > Terminal
-or-
Spotlight Search for Terminal

### 3) Run the script using either of the following methods:

> Note: The examples that follow use Compressor.app and assume the application is found in your Applications folder. If the application is stored in another folder, change the path in the example accordingly and make sure you retain the quotes.

  ### Method 1) Run it against the .app itself (e.g. Compressor.app)
  If the script is in ~/Downloads:
  ```bash
  bash ~/Downloads/masreceipt-extid-finder.sh "/Applications/Compressor.app"
  ```
  If you saved the script somewhere else:
  ```bash
  bash /path/to/masreceipt-extid-finder.sh "/Applications/Compressor.app"
  ```
  ### Method 2) Run it against the receipt file directly
  If the script is in ~/Downloads
  ```bash
  bash ~/Downloads/masreceipt-extid-finder.sh "/Applications/Compressor.app/Contents/_MASReceipt/receipt"
  ```
  If you saved the script somewhere else:
  ```bash
  bash /path/to/masreceipt-extid-finder.sh "/Applications/Compressor.app/Contents/_MASReceipt/receipt"
  ```

### 4) Enter to run

Example output:
```code
bundle_id: com.apple.Compressor
application_version: 4.6.5
app_item_id: 424390742
app_external_id: 858081833
```








