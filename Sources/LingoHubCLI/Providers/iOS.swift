//
//  iOS.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  Copyright © 2017 Bikemap GmbH. All rights reserved.
//

import Foundation

open class iOS: ResourceProvider {

  public var _config: ProviderConfig?

  public var config: ProviderConfig {

    if self._config != nil {
      return self._config!
    }

    let currentDirectory = FileManager
      .default
      .currentDirectoryPath
    let file = URL(fileURLWithPath: "\(currentDirectory)/.lingorc")

    do {
      let data = try Data(contentsOf: file)
      let json = try JSONSerialization.jsonObject(with: data, options: [])

      guard let object = json as? [AnyHashable: Any] else {
        print("Cannot read config .lingorc file.")
        exit(EXIT_FAILURE)
      }

      self._config = try ProviderConfig(object: object)
      return self._config!
    } catch {
      print(error)
      exit(EXIT_FAILURE)
    }
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

    // Strings files from the English base translation.
    // If `projectPath` is specified from there, if not, then the
    // current directory
    let projectPath = self.config.projectPath ??
      FileManager.default.currentDirectoryPath

    // Reading all string files if folder path is specified
    if let stringsFolder = self.config.stringsFolder {
      let stringsFolderPath = projectPath + stringsFolder
      do {
        let allFilesInFolder = try fileManager
          .contentsOfDirectory(atPath: stringsFolderPath)

        // Filtering only the strings files
        stringsFiles = allFilesInFolder
          .filter { $0.contains(".strings") }
          .map { stringsFolderPath + $0 }
      } catch {
        print(error)
      }
    }

    for stringFile in self.config.stringsFiles {
      stringsFiles.append(projectPath + stringFile)
    }

    return stringsFiles
  }

  public func save(resource: LingoHubResource) throws {


  }
}
