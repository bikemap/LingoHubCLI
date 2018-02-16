//
//  iOS.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  Copyright © 2017 Bikemap GmbH. All rights reserved.
//

import Foundation

open class iOS: ResourceProvider {

  public var config: ProviderConfig

  public required init(configuration: ProviderConfig) {
    self.config = configuration
  }

  public var projectUrl: String {
    let url =
      "https://api.lingohub.com/v1/\(self.config.team)/projects/" +
      self.config.project
    return url
  }

  public var files: [String] {

    let fileManager = FileManager()
    var stringsFiles: [String] = []
    let config = self.config

    // The config can specify:
    // - an optional absolute `projectFolder`, defaults to the current folder.
    // - an optional `translationFolder` within the `projectFolder`
    // - a mandatory `baseLocale`, from which the `lproj` folder can be found
    var stringsFolder = config.projectFolder ??
      FileManager.default.currentDirectoryPath

    // `translationFolder`
    if config.translationFolder != nil {
      stringsFolder += "/" + config.translationFolder!
    }

    // `baseLocale`
    stringsFolder += "/\(config.baseLocale).lproj/"

    // Reading all string files if folder path is specified
    do {
      let allFilesInFolder = try fileManager
        .contentsOfDirectory(atPath: stringsFolder)

      // Filtering only the strings files
      stringsFiles = allFilesInFolder
        .filter { $0.contains(".strings") }
        .map { stringsFolder + $0 }
    } catch {
      print(error)
    }
    return stringsFiles
  }


  public func save(
    resources: [LingoHubResource],
    completion: @escaping (() -> Void)) {

    var downloadCount: Int = 0

    for resource in resources {
      guard var downloadUrl: String = resource.links.first?.href else {
        print("No download url for resource: \(resource)")
        continue
      }

      downloadUrl += "?auth_token=" + self.config.token

      let locale: String = resource.locale
      // We do not download the base locale.
      guard locale != self.config.baseLocale else {
        continue
      }

      // Removing locale from the resource name
      // Localizable.de.strings -> Localizable.strings
      let name: String = resource
        .name
        .replacingOccurrences(
          of: "\(self.config.separator)\(locale).strings",
          with: ".strings",
          options: String.CompareOptions.caseInsensitive,
          range: nil)

      // Making the download destination

      // The config can specify:
      // - an optional absolute `projectFolder`, defaults to the current folder.
      // - an optional `translationFolder` within the `projectFolder`
      // - a mandatory `baseLocale`, from which the `lproj` folder can be found
      var destinationFolder: String = config.projectFolder ??
        FileManager.default.currentDirectoryPath
      
      // `translationFolder`
      if config.translationFolder != nil {
        destinationFolder += config.translationFolder!
      }
      
      // `locale` and name
      destinationFolder += "/\(locale).lproj/\(name)"

      let destinationUrl: URL = URL(fileURLWithPath: destinationFolder)

      downloadCount += 1

      guard let resourcesURL: URL = URL.init(string: downloadUrl) else {
        print("Cannot create resourcesEndPoint URL")
        exit(EXIT_FAILURE)
      }

      var urlRequest: URLRequest = URLRequest(url: resourcesURL)
      urlRequest.httpMethod = "GET"

      let session: URLSession = URLSession(configuration: .default)
      session
        .downloadTask(
          with: urlRequest,
          completionHandler: { tmpURL, response, error in

            guard error == nil, tmpURL != nil else {
              print(error!)
              exit(EXIT_FAILURE)
            }

            do {
              if FileManager
                .default
                .fileExists(atPath: destinationUrl.relativePath) {
                  try FileManager.default.removeItem(at: destinationUrl)
              }

              try FileManager.default.moveItem(at: tmpURL!, to: destinationUrl)

              print("Downloaded: ", destinationUrl)
              downloadCount -= 1

              if downloadCount == 0 {
                completion()
              }
            } catch {
              print(error)
              exit(EXIT_FAILURE)
            }
        })
      .resume()
    }
  }
}
