//
//  LingoHubCLI.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 16.02.18.
//

import Foundation

/// This is the LingoHubCLI class, wrapping all functions of the tool
open class LingoHubCLI: NSObject, URLSessionDelegate, URLSessionDataDelegate {

  /// The current version of the tool.
  private static let version: String = "1.1.0"

  /// The tasks to be performed. Default is the .help.
  private var task: Task = .help

  /// The resource provider is defined in the .lingorc file by setting the 
  /// platform.
  private var resourceProvider: ResourceProvider

  /// Initialises the CLI, reads the input parameters and the config file.
  override public init() {

    /// There has to be at least 2 arguments: eg: `swift download`.
    /// Otherwise show help.
    guard CommandLine.argc > 1 else {
      LingoHubCLI.help()
      exit(EXIT_FAILURE)
    }

    /// Determine the task from the arguments.
    self.task = Task(value: CommandLine.arguments[1])

    /// Showing the version
    if self.task == .version {
      LingoHubCLI.printVersion()
      exit(EXIT_SUCCESS)
    }

    /// The default path for the `.lingorc` file is the current folder.
    var lingorcLocation: String = FileManager.default.currentDirectoryPath

    /// But it is possible to overwrite it with a 2nd argument passed to the
    /// command: `swift download /path/to/project`
    if CommandLine.argc > 2 {
      lingorcLocation = CommandLine.arguments[2]
    }

    let file = URL(fileURLWithPath: "\(lingorcLocation)/.lingorc")
    var config: ProviderConfig?

    /// Reading and deserialising the configuration from lingorc.
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

    /// Setting the resource provider based on the platform in the config file.
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
      "Possible tasks are upload and download.",
      "\nExample: $ lingohub upload",
      "\n\n")
  }

  /// Prints the current version to the console.
  private static func printVersion() {
    print(
      "lingohub swift command line tool:\nVersion \(self.version)",
      "\n2018. Bikemap GmbH - https://github.com/bikemap\n")
  }

  /// The main entry point to the CLI. Performs the task based on the input
  /// parameters.
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

  /// Fetches the list of available translated resources from LingoHub
  /// and passes the list to the resource provider, which downloads each files
  /// and saves it on the disk.
  private func download() {
    let config = self.resourceProvider.config
    let projectUrl = self.resourceProvider.projectUrl
    let resourcesEndPoint = "\(projectUrl)/resources?auth_token=" + config.token

    guard let resourcesURL: URL = URL.init(string: resourcesEndPoint) else {
      print("Cannot create resourcesEndPoint URL")
      exit(EXIT_FAILURE)
    }

    var urlRequest = URLRequest(url: resourcesURL)
    urlRequest.httpMethod = "GET"

    let session = URLSession(configuration: .default)
    session
      .dataTask(with: urlRequest) { data, response, error in
        do {

          /// Deserialising the received resource objects.
          guard let rawData = data, let json = try JSONSerialization
            .jsonObject(with: rawData) as? [AnyHashable: Any] else {
              print("Cannot parse response", data ?? "nil", error ?? "nil")
              exit(EXIT_FAILURE)
          }

          guard let res: HTTPURLResponse = response as? HTTPURLResponse,
            200 ... 299 ~= res.statusCode else {
              print(response ?? "No response")
              exit(EXIT_FAILURE)
          }

          let resources: [LingoHubResource] = try json.value(for: "members")

          /// Saving translated resources locally
          self
            .resourceProvider
            .save(resources: resources) {
              print("All files were downloaded.")
              exit(EXIT_SUCCESS)
          }
        } catch {
          print(error)
          exit(EXIT_FAILURE)
        }
      }
      .resume()
  }

  /// Uploads the files returned by the provider to LingoHub for translation
  private func upload() {

    /// Keeping a count to check if all resources has been uploaded
    var uploadCount: Int = 0

    /// The files to be uploaded. Defined by the resource provider.
    let files = self.resourceProvider.files

    guard files.count > 0 else {
      print(
        "No translation files found with config: ",
        self.resourceProvider.config)
      exit(EXIT_FAILURE)
    }

    /// Uploading the files
    let projectUrl = self.resourceProvider.projectUrl
    let resourcesEndPoint = "\(projectUrl)/resources?auth_token=" +
      self.resourceProvider.config.token

    guard let resourcesURL: URL = URL.init(string: resourcesEndPoint) else {
      print("Cannot create resourcesEndPoint URL")
      exit(EXIT_FAILURE)
    }

    /// For every file we create a multipart/form request.
    for file in files {
      let fileUrl = URL(fileURLWithPath: file)
      print("Uploading: \(file)")

      let urlRequest = URLRequest
        .multipartFromDataFileUploadRequest(
          url: resourcesURL,
          file: fileUrl)

      let session = URLSession(configuration: .default)
      session
        .dataTask(with: urlRequest) { (data, response, error) in

          guard error == nil else {
            print(error!)
            uploadCount += 1
            if uploadCount >= files.count {
              print("All files uploaded.")
              exit(EXIT_SUCCESS)
            }
            return
          }

          uploadCount += 1
          if uploadCount >= files.count {
            print("All files uploaded.")
            exit(EXIT_SUCCESS)
          }
        }
        .resume()
    }
  }
}
