# LingoHubCLI

The `lingohub` command line tool makes it super-easy to upload and download
localisable resources to and from LingoHub. 

It currently supports `iOS` and `Android` projects (with the option to extend
to any platforms).

*Important note:* Only base translations are uploaded to LingoHub and base
translations are never overwritten with data from LingoHub. This means, 
alterations to the base have to be done within the project by a developer.

## Upload

```
$ lingohub upload
```

The tool extracts the base translation of the project and uploads it to 
LingoHub for translation.

## Download

```
$ lingohub download
```

The tool downloads all available translated resources of the project from 
LingoHub and places them in the proper folder.

## Configuration

The configuration is done using the `.lingorc` file in the project root folder.

| Property | Description |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `platform` | `ios`, `android` Specifies the platform of the project. File locations and naming conventions depend on this. |
| `team` | The slug of the team from LingoHub. For instance: `"bikemap-gmbh"` |
| `project` | The slug of the project name from LingoHub. For instance: 'ios-test' |
| `token` | The authorisation token generated by LingoHub. |
| `projectFolder` | `Optional` Defaults to the current directory. |
| `translationFolder` | The folder where the translations are stored. For instance `app/src/main/res` for Android. |
| `baseLocale` | The base translation's locale. Your default language. This local will be the one uploaded to LingoHub, however it is never downloaded. |
| `separator` | The separator you used for your uploaded resources. |

Example `.lingorc`: 

```json
{
  "platform": "android",
  "team": "bikemap-gmbh",
  "project": "android-test",
  "token": "your-token",
  "projectFolder": "/Users/path/to/projet/folder/",
  "translationFolder": "app/src/main/res",
  "baseLocale": "en",
  "separator": "_"
}
```

## Naming Convention

According to LingoHub documentation, we put the locale in the files names, 
for instance: `Localizable_zh-Hans-CN.strings` or
`BMRideStartBottomBarView_it.strings"`. The locale is then recognised by 
LingoHub automatically.

The locale format is depending on the platform (e.g. simplified Chinese
on iOS is `zh-Hans-CN`). Then you define your separator (`_` in the above
example) to work with your local files and folders. The script 


## Build & Distribution

You need swift 4 to be installed.

```
$ swift build -c release -Xswiftc -static-stdlib
Compile Swift Module 'LingoHubCLI' (5 sources)
Linking ./.build/x86_64-apple-macosx10.10/release/LingoHubCLI

$ cp ./.build/x86_64-apple-macosx10.10/release/LingoHubCLI ./lingohub
```

Or to install globally:

```
$ cp -f ./.build/x86_64-apple-macosx10.10/release/LingoHubCLI /usr/local/bin/lingohub
```

## Contribution

To support more platforms:

* add a new class that confirms to the `ResourceProvider` protocol, 
* implement project specific logic,
* extend the `func engage()` in the `main.swift` file.