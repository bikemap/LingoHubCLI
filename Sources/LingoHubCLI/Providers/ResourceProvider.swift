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

  /// Reads the configuration file from the project folder, and maps the
  /// the contents into a `ProviderConfig` struct.
  /// In case of any problems with reading the config, the appliction will
  /// exit with failure.
  var config: ProviderConfig { get set }

  /// The `save` method receives a `LingoHubResource` mapped from the JSON
  /// response from LingoHub. The workflow of downloading and storing these
  /// files are implemented here.
  ///
  /// - Parameter resource: The mapped LingoHubResource
  /// - Throws: Throws an error if the download or storing of any file fails.
  func save(resources: [LingoHubResource]) throws

  init(configuration: ProviderConfig)
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
  public var token: String
  public var projectFolder: String?
  public var translationFolder: String?
  public var baseLocale: String

  // TODO: lingohub import settings

  public init(object: MarshaledObject) throws {
    let platform: String = try object.value(for: "platform")
    self.platform = Platform(value: platform)
    self.team = try object.value(for: "team")
    self.project = try object.value(for: "project")
    self.token = try object.value(for: "token")
    self.projectFolder = try? object.value(for: "projectFolder")
    self.translationFolder = try? object.value(for: "translationFolder")
    self.baseLocale = try object.value(for: "baseLocale")
  }
}
