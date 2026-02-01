# Pro-Apps-App-External-IDs
Collection of various App External IDs for Apple Pro apps and Apple productivity apps.

These are useful for downloading older verisons of an app from the Mac App Store.

Anywhere an application version is listed where the App External ID is missing means it's still needed -- please help contribute!

So far, I've been compiling lists for: Final Cut Pro, Motion, Compressor, Logic Pro, and MainStage

As well as some non-Pro Apps: GarageBand, iMovie, Keynote, Pages, Numbers, and Pixelmator Pro

In this repo are csv files for each of the referenced apps. I've provided sources (when available) for where the App External ID was found.

# Installing a specific version
> Note: The method below is currently the only way to obain older versions of Final Cut Pro, Compressor and Motion from the Mac App Store on OS versions older than 15.6.*

**I've created a fork of the MAS-CLI and patched version 1.9.0's code (as it has good OS support) to accept a version argument at runtime.**

Once you've identified the app version's App External ID you're looking for, you can run this patched version of MAS to install the specific app version from Terminal.


**MAS 1.9.0 Patched:** https://github.com/handyandy87/mas-cli-appExtVrsId-patcher/releases/tag/MAS190-patched

# How to contribute your App External ID
This project maps macOS App Store app versions to their corresponding **App External ID**. The easiest way to contribute is to generate a crash report for the running app and copy the values directly from the crash report popup.

When the crash report dialog appears, you’ll see the fields you need in this exact order:

1. **Version**
2. **App Item ID**
3. **App External ID**

Please submit those three values exactly as shown (plus the app name) by creating a new issue.

## How to find your **App External ID** (by forcing a crash report)

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

> Exmaple excerpt from crash report, for Compressor 4.6.5
```code
Process: Compressor [50811]
Path: /Applications/Compressor.app/Contents/MacOS/Compressor
Identifier: com.apple.Compressor
Version: 4.6.5 (408047)
Build Info: Compressor-40800047016000000~4 (20A104)
App Item ID: 424390742
App External ID: 858081833
```


