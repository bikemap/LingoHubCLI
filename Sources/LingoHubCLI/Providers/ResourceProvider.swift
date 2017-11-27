//
//  ResourceProvider.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  blackmirror media
//

import Foundation
import Marshal

/// The ResourceProvider protocol should be implemented by classes,
/// which are enabling the automated translation of resources of a certain
/// type of project: iOS, Android, Web, and so forth.
///
/// Providers have to implement the processes of collecting the files for upload
/// and the handling of download files.
public protocol ResourceProvider {

  /// The API URL of the project.
  /// TODO: put this in the config.
  var projectUrl: String { get }

  /// An array of file paths to be upladed and translated at LingoHub.
  var files: [String] { get }

  /// A stuct mapped from the .lingorc.json file in the project folder
  var config: ProviderConfig { get }

  /// The `save` method receives a `LingoHubResource` mapped from the JSON
  /// response from LingoHub. The workflow of downloading and storing these
  /// files are implemented here.
  ///
  /// - Parameter resource: The mapped LingoHubResource
  /// - Throws: Throws an error if the download or storing of any file fails.
  func save(resource: LingoHubResource) throws
}

public enum Platform {
  case ios
  case android

  init(value: String) {
    switch value {
    case "ios": self = .ios
    case "android": self = .android
    default: self = .ios
    }
  }
}

public struct ProviderConfig: Unmarshaling {

  public var platform: Platform
  public var team: String
  public var project: String
  public var projectPath: String?
  public var stringsFolder: String?
  public var stringsFiles: [String]

  public init(object: MarshaledObject) throws {
    let platform: String = try object.value(for: "platform")
    self.platform = Platform(value: platform)
    self.team = try object.value(for: "team")
    self.project = try object.value(for: "project")
    self.projectPath = try? object.value(for: "projectPath")
    self.stringsFolder = try? object.value(for: "stringsFolder")
    self.stringsFiles = try object.value(for: "stringsFiles")
  }
}
