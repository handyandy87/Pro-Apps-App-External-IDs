# Pro-Apps-App-External-IDs
A collection of App External IDs for Apple Pro apps and Apple productivity apps.

These are useful for downloading older versions of apps from the Mac App Store.

If an app version is listed without an App External ID, that value is still needed — please help contribute!

This repo includes lists for the following apps:

**Pro Apps:** Final Cut Pro, Motion, Compressor, Logic Pro, and MainStage

**Other Apple Apps:** GarageBand, iMovie, Keynote, Pages, Numbers, and Pixelmator Pro

Each app has a corresponding CSV file. Sources are provided (where available) for where each App External ID was found.

# Installing a Specific Version
> Note: The method below is currently the only way to obtain older versions of Final Cut Pro, Compressor, and Motion from the Mac App Store on macOS versions older than 15.6.

**I've created a fork of the MAS-CLI and patched version 1.9.0's code (which has broad OS support) to accept a version argument at runtime.**

Once you've identified the App External ID for the version you want, you can use this patched version of MAS to install it directly from Terminal.

**MAS 1.9.0 Patched:** https://github.com/handyandy87/mas-cli-appExtVrsId-patcher

# Last Compatible Versions by macOS

If you're on an older version of macOS, use the tables below to find the last version of each Pro App compatible with your OS, along with the App Item ID and App External ID needed to install it.

> Note: Data for Big Sur, Ventura, and Sonoma is not yet included. Contributions welcome!

### High Sierra (10.13)
| App | Version | App Item ID | App External ID |
|-----|---------|:-----------:|:---------------:|
| Final Cut Pro | 10.4.6 | 424389933 | 830604740 |
| Compressor | 4.4.4 | 424390742 | 830431847 |
| Motion | 5.4.3 | 434290957 | 830431815 |
| Logic Pro | 10.4.8 | 634148309 | 833082327 |
| MainStage | 3.4.4 | 634159523 | 832148253 |

### Mojave (10.14)
| App | Version | App Item ID | App External ID |
|-----|---------|:-----------:|:---------------:|
| Final Cut Pro | 10.4.10 | 424389933 | 837625711 |
| Compressor | 4.4.8 | 424390742 | 837625598 |
| Motion | 5.4.7 | 434290957 | 837625726 |
| Logic Pro | 10.5.1 | 634148309 | 835960408 |
| MainStage | 3.4.4 | 634159523 | 832148253 |

### Catalina (10.15)
| App | Version | App Item ID | App External ID |
|-----|---------|:-----------:|:---------------:|
| Final Cut Pro | 10.5.4 | 424389933 | 842932377 |
| Compressor | 4.5.4 | 424390742 | 842932628 |
| Motion | 5.5.3 | 434290957 | 842933665 |
| Logic Pro | 10.6.3 | 634148309 | 841990097 |
| MainStage | 3.5.3 | 634159523 | 841990111 |

### Monterey (12)
| App | Version | App Item ID | App External ID |
|-----|---------|:-----------:|:---------------:|
| Final Cut Pro | 10.6.8 | 424389933 | 858759812 |
| Compressor | 4.6.5 | 424390742 | 858081833 |
| Motion | 5.6.5 | 434290957 | 858081811 |
| Logic Pro | 10.7.9 | 634148309 | 857501258 |
| MainStage | 3.6.4 | 634159523 | 854029745 |
| GarageBand | 10.4.8 | 682658836 | 853773014 |
| iMovie | 10.3.8 | 408981434 | 858759843 |
| Keynote | 13.1 | 409183694 | 857401958 |
| Numbers | 13.1 | 409203825 | 857401959 |
| Pages | 13.1 | 409201541 | 857401961 |
| Xcode | 14.2 | 497799835 | 853602198 |

# How to Contribute an App External ID
This project maps macOS App Store app versions to their corresponding **App External ID**. The easiest way to contribute is to share any App External IDs that are missing from the repo.

You can obtain an App External ID in a few different ways:
1. Generate a crash report for the running app and copy the values from the crash report popup.
2. Use the **masreceipt-extid-finder** script included in this repo to print the information from Terminal. (Note: I haven't tested this extensively beyond my own machine, so results may vary.)
3. There may be other methods — let me know if you find one!

Please submit the following values by creating a new issue:
- **App name**
- **Version** (e.g. `4.6.5`)
- **App Item ID** (e.g. `424390742`)
- **App External ID** (e.g. `858081833`)

> Note: App External IDs are only present in app packages obtained from the Mac App Store. Those packages contain a `_MASReceipt` folder with a `receipt` file that reports the App External ID to the OS. Apps obtained outside the Mac App Store will not have a receipt file and cannot be used to identify App External IDs.


## Option 1: Find Your App External ID (via Crash Report)

These steps intentionally generate a crash report for a running Mac App Store app so you can read its **App External ID** from the report dialog.

> Example app used below: **Compressor** (the same steps work for any other app).

### 1) Launch the app

Open the app normally (via Finder, Spotlight, or the Dock), or from Terminal:

*Replace `Compressor` with your app name*
```bash
open -a "Compressor"
```

### 2) Find the app's PID
*Replace `Compressor` with your app name*
```bash
pgrep -x "Compressor"
```
> Example output showing the app's PID:
```
50811
```

### 3) Force a crash report
*Replace `<PID>` with the number from the previous step*
```bash
sudo kill -3 <PID>
```
> Example if the PID was `50811`:
```bash
sudo kill -3 50811
```

### 4) Copy the values from the crash report popup
After the crash report appears, look for these fields near the top:
1. Version
2. App Item ID
3. App External ID

> Example excerpt from a crash report for Compressor 4.6.5:
```
Process: Compressor [50811]
Path: /Applications/Compressor.app/Contents/MacOS/Compressor
Identifier: com.apple.Compressor
Version: 4.6.5 (408047)
Build Info: Compressor-40800047016000000~4 (20A104)
App Item ID: 424390742
App External ID: 858081833
```

## Option 2: Find Your App External ID (via masreceipt-extid-finder)

This is a quick-and-dirty script that retrieves the App External ID by parsing the values found in the app's `_MASReceipt/receipt` file.

This is useful if you're trying to obtain the App External ID from an app package that wasn't installed on the current system from the Mac App Store (e.g., a backup copy on an external hard drive).

When you run this script, Terminal will print:
```
bundle_id            ## the app's bundle identifier (e.g. com.apple.Compressor)
application_version  ## the app's version number (e.g. 4.6.5)
app_item_id          ## the Mac App Store App Item ID (e.g. 424390742)
app_external_id      ## the Mac App Store External Item ID (e.g. 858081833)
```

### 1) Download the script from the releases section of this repo
https://github.com/handyandy87/Pro-Apps-App-External-IDs/releases


### 2) Open Terminal
Go > Utilities > Terminal
— or —
Spotlight Search for "Terminal"

### 3) Run the script

> Note: The examples below use Compressor.app and assume the app is in your Applications folder. If it's stored elsewhere, update the path accordingly — keep the quotes.

**Method A — Run it against the .app itself:**

If the script is in `~/Downloads`:
```bash
sudo bash ~/Downloads/masreceipt-extid-finder.sh "/Applications/Compressor.app"
```
If the script is saved elsewhere:
```bash
sudo bash /path/to/masreceipt-extid-finder.sh "/Applications/Compressor.app"
```

**Method B — Run it against the receipt file directly:**

If the script is in `~/Downloads`:
```bash
sudo bash ~/Downloads/masreceipt-extid-finder.sh "/Applications/Compressor.app/Contents/_MASReceipt/receipt"
```
If the script is saved elsewhere:
```bash
sudo bash /path/to/masreceipt-extid-finder.sh "/Applications/Compressor.app/Contents/_MASReceipt/receipt"
```

### 4) View the output

Example output:
```
bundle_id: com.apple.Compressor
application_version: 4.6.5
app_item_id: 424390742
app_external_id: 858081833
```
