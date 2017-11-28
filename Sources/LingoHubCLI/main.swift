//
//  main.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  blackmirror media
//

import Foundation
import Alamofire
import Marshal

/// The TASKs that can be performed using LungoHub. This can be specified as
/// the first command line option. If missing or cannot be found, it defaults
/// to `help` which displays the usage of the tool.
///
/// - upload: Upload translation files.
/// - download: Download translation file.
/// - help: Display usage of the CLI.
public enum Task {
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

// MARK: - CLI

/// This is the LingoHubCLI class, wrapping all functions of the tool
open class LingoHubCLI: NSObject, URLSessionDelegate, URLSessionDataDelegate {

  private var task: Task = .help
  private var resourceProvider: ResourceProvider

  override public init() {

    guard CommandLine.argc == 2 else {
      LingoHubCLI.help()
      exit(EXIT_FAILURE)
    }

    // Task
    self.task = Task(value: CommandLine.arguments[1])

    // Reading the provider config
    let currentDirectory = FileManager
      .default
      .currentDirectoryPath
    let file = URL(fileURLWithPath: "\(currentDirectory)/.lingorc")
    var config: ProviderConfig?

    do {
      let data = try Data(contentsOf: file)
      let json = try JSONSerialization.jsonObject(with: data, options: [])

      guard let object = json as? [AnyHashable: Any] else {
        print("Cannot read config .lingorc file.")
        exit(EXIT_FAILURE)
      }

      config = try ProviderConfig(object: object)
    } catch {
      print(error)
      exit(EXIT_FAILURE)
    }

    switch config!.platform {
      case .ios:
        self.resourceProvider = iOS(configuration: config!)
      case .android:
        self.resourceProvider = Android(configuration: config!)
    }

    super.init()
  }

  /// Prints usage information to the console.
  private static func help() {
    print(
      "Possible tasks: [upload|download]",
      "\n\nExample: $ LingoHubCLI upload",
      "\n\n")
  }

  public func engage() {
    switch self.task {
    case .download:
      self.download()
    case .upload:
      self.upload()
    default:
      LingoHubCLI.help()
      exit(EXIT_FAILURE)
    }
  }

  // MARK: - API Implementation

  private func download() {
    let config = self.resourceProvider.config
    let projectUrl = self.resourceProvider.projectUrl
    let resourcesEndPoint = "\(projectUrl)/resources?auth_token=" + config.token

    Alamofire
      .request(resourcesEndPoint)
      .responseJSON { response in
        guard let json = response.result.value as? [AnyHashable: Any] else {
          print("invalid response:", response.result.value as Any)
          exit(EXIT_FAILURE)
        }

        do {
          let resources: [LingoHubResource] = try json.value(for: "members")
          // Saving resources locally
          self
            .resourceProvider
            .save(resources: resources) {
              print("All files are downloaded.")
              exit(EXIT_SUCCESS)
            }
        } catch {
          print(error)
          exit(EXIT_FAILURE)
        }
    }
  }

  /// Uploads the files returned by the provider to LingoHub for translation
  private func upload() {

    var uploadCount: Int = 0
    let files = self.resourceProvider.files

    guard files.count > 0 else {
      print(
        "No translation files found with config: ",
        self.resourceProvider.config)
      exit(EXIT_FAILURE)
    }

    let projectUrl = self.resourceProvider.projectUrl
    let resourcesEndPoint = "\(projectUrl)/resources?auth_token=" +
      self.resourceProvider.config.token

    for file in files {
      let fileUrl = URL(fileURLWithPath: file)
      print("Uploading: \(file)")

      Alamofire.upload(
        multipartFormData: { multipartFormData in
          multipartFormData
            .append(fileUrl, withName: "file")
      },
        to: resourcesEndPoint,
        encodingCompletion: { encodingResult in
          switch encodingResult {
          case .success(let upload, _, _):
            upload.responseJSON { response in

              uploadCount += 1
              if uploadCount >= files.count {
                print("All files uploaded.")
                exit(EXIT_SUCCESS)
              }
            }
          case .failure(let encodingError):
            print(encodingError)
            uploadCount += 1
            if uploadCount >= files.count {
              print("All files uploaded.")
              exit(EXIT_SUCCESS)
            }
          }
      })
    }
  }
}

// Start
let cli = LingoHubCLI()
cli.engage()

// The application will run until exit() is called.
dispatchMain()
