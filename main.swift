//
//  main.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  Copyright © 2017 blackmirror media. All rights reserved.
//

import Foundation

/// The JOBs that can be performed using LungoHub. This can be specified as
/// the first command line option. If missing or cannot be found, it defaults
/// to `help` which displays the usage of the tool.
///
/// - upload: Upload translation files.
/// - download: Download translation file.
/// - help: Display usage of the CLI.
public enum Job {
  case upload
  case download
  case help

  init(value: String?) {
    guard value != nil else {
      self = .help
      return
    }
    switch value! {
      case "upload": self = .upload
      case "download": self = .download
      default: self = .help
    }
  }
}

/// The available TARGETs for the JOBs. This can be specified as
/// the second command line option. If missing or cannot be found, it defaults
/// to `help` which displays the usage of the tool.
///
/// - android: Selects the Android workflow.
/// - ios: Selects the iOS workflow.
/// - iosTest: Selects the iOS test workflow.
/// - help: Display usage of the CLI.
public enum Target {
  case android
  case ios
  case iosTest
  case help

  init(value: String?) {
    guard value != nil else {
      self = .help
      return
    }
    switch value! {
      case "android": self = .android
      case "ios": self = .ios
      case "iosTest": self = .iosTest
      default: self = .help
    }
  }
}

/// Configuration of the LungoHub API
fileprivate struct Config {
  let token = "564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0"
}

/// Projects available on LingoHub
fileprivate struct Projects {
  let iOS = "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios"
  let iOSTest = "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test"
  let android = "https://api.lingohub.com/v1/bikemap-gmbh/projects/android"
}

// MARK: - CLI

/// Parses the command line options and mathces them to the available
/// JOBs and TARGETs. The exectution of the workflow depends on these two
/// parameters.
///
/// - Returns: A tuple with the matched Enums for JOB and TARGET.
func parseOptions() -> (Job, Target) {
  let job = Job(value: CommandLine.arguments[1])
  let target = Target(value: CommandLine.arguments[2])
  return (job, target)
}

if CommandLine.argc < 3 {
  print("TODO: usage")
  exit(EXIT_FAILURE)
} else {
  let (job, target) = parseOptions()

  print(job, target)
}

open class LingoHubCLI {

}

print("Hello, World!")

// GET /v1/projects
// curl -X GET https://api.lingohub.com/v1/projects.json?auth_token=564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0

// GET /v1/:account/projects/:project
// curl -X GET https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test?auth_token=564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0

// ## Resources
// GET /v1/:account/projects/:project/resources
// curl -X GET https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources?auth_token=564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0
//{
//  "members": [
//  {
//  "name": "Ride.de.strings",
//  "links": [
//  {
//  "rel": "self",
//  "href": "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources/Ride.de.strings",
//  "type": "text/plain"
//  }
//  ],
//  "project_locale": "de"
//  },
//  {
//  "name": "Ride.en.strings",
//  "links": [
//  {
//  "rel": "self",
//  "href": "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources/Ride.en.strings",
//  "type": "text/plain"
//  }
//  ],
//  "project_locale": "en"
//  }
//  ],
//  "links": [
//  {
//  "rel": "self",
//  "href": "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources"
//  }
//  ]
//}

// ## Upload
// POST /v1/:account/projects/:project/resources
// curl -X POST https://api.lingohub.com/v1/projects/ios-test/resources?auth_token=564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0  -F "iso2_slug=en" -F "path=en.lproj/" -F "file=@/path/to/file/Localizable.strings"

// ## Download
// GET /v1/:account/projects/:project/resources/:filename
// GET "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources/Ride.en.strings"
