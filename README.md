# Pro-Apps-App-External-IDs
Collection of various App External IDs for Apple Pro apps and Apple productivity apps.

These are useful for downloading older verisons of an app from the Mac App Store.

Anywhere an application version is listed where the App External ID is missing means it's still needed -- please help contribute!

So far, I've been compiling lists for: Final Cut Pro, Motion, Compressor, Logic Pro, and MainStage

As well as some non-Pro Apps: GarageBand, iMovie, Keynote, Pages, Numbers, and Pixelmator Pro

In this repo are csv files for each of the referenced apps. I've provided sources (when available) for where the App External ID was found.

# Installing a specific version
I've created a fork of the MAS cli and patched version 1.9.0's code (as it has good OS support) to accept a version argument at runtime. 

Once you've identified the app version's App External ID you're looking for, you can run this patched version of MAS to install the specific app version from Terminal.


MAS 1.9.0 Patched: https://github.com/handyandy87/mas-cli-appExtVrsId-patcher/releases/tag/MAS190-patched

