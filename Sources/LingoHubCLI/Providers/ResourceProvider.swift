//
//  ResourceProvider.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  blackmirror media
//

import Foundation

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

  /// The `save` method receives a `LingoHubResource` mapped from the JSON
  /// response from LingoHub. The workflow of downloading and storing these
  /// files are implemented here.
  ///
  /// - Parameter resource: The mapped LingoHubResource
  /// - Throws: Throws an error if the download or storing of any file fails.
  func save(resource: LingoHubResource) throws
}
