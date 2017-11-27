//
//  main.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  Copyright © 2017 blackmirror media. All rights reserved.
//

import Foundation
import Alamofire

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
  public static let token =
  "564c23254e56682f0f8ccca2758398d0e1fe812f28657a02e9f5cd1357354bc0"
}

/// Projects available on LingoHub
fileprivate struct Projects {
  public static let android =
  "https://api.lingohub.com/v1/bikemap-gmbh/projects/android"
  public static let iOS =
  "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios"
  public static let iOSTest =
  "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test"
}

// MARK: - CLI

/// This is the LingoHubCLI class, wrapping all functions of the tool
open class LingoHubCLI: NSObject, URLSessionDelegate, URLSessionDataDelegate {

  private var job: Job = .help
  private var target: Target = .help
  private var projectPath: String?
  private var session: URLSession?

  override public init() {
    super.init()
    if CommandLine.argc < 4 {
      self.help()
      exit(EXIT_FAILURE)
    } else {
      self.parseOptions()
    }
  }

  /// Parses the command line options and mathces them to the available
  /// JOBs and TARGETs and the project path. The exectution of the workflow
  /// depends on these two parameters.
  ///
  /// - Returns: A tuple with the matched Enums for JOB and TARGET.
  private func parseOptions() {
    self.job = Job(value: CommandLine.arguments[1])
    self.target = Target(value: CommandLine.arguments[2])

    guard let path = CommandLine
      .arguments[3]
      .components(separatedBy: "=")
      .last else {
        print("Project path not spedicifed.")
        // TODO: Check if folder/file exists
        self.help()
        exit(EXIT_FAILURE)
    }

    self.projectPath = path

    print(self.job, self.target, self.projectPath)
  }

  /// Prints usage information to the console.
  private func help() {
    print(
      "Possible jobs: [upload|download]",
      "\nPossible targets: [ios|android|iosTest]",
      "\n\nExample: $ LingoHubCLI upload ios",
      "\n\n")
  }

  // MARK: Common

  public func engage() {

    self.session = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: self,
      delegateQueue: OperationQueue.main)

    switch self.job {
    case .download:
      self.download()
    case .upload:
      self.upload()
    default:
      self.help()
    }
  }

  private func download() {

  }


  private func upload() {
    var files: [String] = []
    var projectUrlString: String = "?token=" + Config.token

    switch self.target {
    case .ios:
      files = self.iOSFiles()
      projectUrlString = Projects.iOS + projectUrlString

    case .iosTest:
      files = self.iOSTestFiles()
      projectUrlString = Projects.iOSTest + projectUrlString

    case .android:
      files = self.androidFiles()
      projectUrlString = Projects.android + projectUrlString

    case .help:
      self.help()
    }

    guard let projectUrl = URL(string: projectUrlString) else {
      print("projectUrl not specified")
      exit(EXIT_FAILURE)
    }


    for file in files {
      print(file)



      //      var request = URLRequest(url: projectUrl)
      //      request.httpMethod = "POST"
      //      request.addValue(
      //        "multipart/form-data",
      //        forHTTPHeaderField: "Content-Type")
      //
      //      print("Request:", request)
      //
      //      let uploadTask = self
      //        .session?
      //        .uploadTask(
      //          with: request,
      //          fromFile: URL(fileURLWithPath: file),
      //          completionHandler: { (data, response, error) in
      //            print(data)
      //            print(response)
      //            print(error)
      //        })
      //
      //      uploadTask?.resume()
    }

  }

  // MARK: iOS

  private func iOSFiles() -> [String] {
    return []
  }

  private func iOSTestFiles() -> [String] {
    guard let projectPath = self.projectPath else {
      print("ProjectPath not specified")
      return []
    }

    var stringsFiles: [String] = []
    let fileManager: FileManager = FileManager()

    do {
      let files = try fileManager.contentsOfDirectory(atPath: projectPath)
      stringsFiles = files.filter {
        $0.contains(".strings")
      }
    } catch {
      print(error)
      exit(EXIT_FAILURE)
    }

    return stringsFiles
  }

  // MARK: Android
  private func androidFiles() -> [String] {
    return []
  }


  // MARK: URLSessionDelegate

}

// Start
let cli = LingoHubCLI()
cli.engage()
dispatchMain()

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

