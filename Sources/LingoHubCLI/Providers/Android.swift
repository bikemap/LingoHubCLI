//
//  Android.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//

import Foundation
import Alamofire

open class Android: ResourceProvider {

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
      stringsFolder += config.translationFolder!
    }

    // `baseLocale`
    stringsFolder += "/values/"

    // Reading all string files if folder path is specified
    do {
      let allFilesInFolder = try fileManager
        .contentsOfDirectory(atPath: stringsFolder)

      // Filtering only the strings files
      stringsFiles = allFilesInFolder
        .filter { $0.contains("strings.xml") }
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
      guard let downloadUrl = resource.links.first?.href else {
        print("No download url for resource: \(resource)")
        continue
      }

      let locale = resource.locale
      // We do not download the base locale.
      guard locale != self.config.baseLocale else {
        continue
      }

      // Removing locale from the resource name
      // Localizable.de.strings -> Localizable.strings
      let name = resource
        .name
        .replacingOccurrences(
          of: "\(self.config.separator)\(locale)",
          with: "",
          options: String.CompareOptions.caseInsensitive,
          range: nil)

      // Making the download destination

      // The config can specify:
      // - an optional absolute `projectFolder`, defaults to the current folder.
      // - an optional `translationFolder` within the `projectFolder`
      // - a mandatory `baseLocale`, from which the `lproj` folder can be found
      var destinationFolder = config.projectFolder ??
        FileManager.default.currentDirectoryPath

      // `translationFolder`
      if config.translationFolder != nil {
        destinationFolder += config.translationFolder!
      }

      // `locale` and name
      destinationFolder += "/values-\(locale)/\(name)"

      let destinationUrl = URL(fileURLWithPath: destinationFolder)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        return (destinationUrl, [
          .removePreviousFile,
          .createIntermediateDirectories])
      }

      downloadCount += 1

      Alamofire
        .download(
          downloadUrl + "?auth_token=" + self.config.token,
          to: destination)
        .response { response in

          if response.error == nil,
            let filePath = response.destinationURL?.path {
            print("Downloaded: ", filePath)
          }

          downloadCount -= 1
          if downloadCount == 0 {
            completion()
          }
      }
    }
  }
}
