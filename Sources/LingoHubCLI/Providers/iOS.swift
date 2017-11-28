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
      stringsFolder += config.translationFolder!
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

  public func save(resources: [LingoHubResource]) throws {
//    self.config.projectPath + self.config.stringsFolder
  }
}
