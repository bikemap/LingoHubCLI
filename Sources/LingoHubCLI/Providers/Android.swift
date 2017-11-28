//
//  Android.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//

import Foundation


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

//    // Strings files from the English base translation.
//    // If `projectPath` is specified from there, if not, then the
//    // current directory
//    let projectPath = self.config.projectPath ??
//      FileManager.default.currentDirectoryPath
//
//    // Reading all string files if folder path is specified
//    if let stringsFolder = self.config.stringsFolder {
//      let stringsFolderPath = projectPath + stringsFolder
//      do {
//        let allFilesInFolder = try fileManager
//          .contentsOfDirectory(atPath: stringsFolderPath)
//
//        // Filtering only the strings files
//        stringsFiles = allFilesInFolder
//          .filter { $0.contains(".xml") }
//          .map { stringsFolderPath + $0 }
//      } catch {
//        print(error)
//      }
//    }
//
//    for stringFile in self.config.stringsFiles {
//      stringsFiles.append(projectPath + stringFile)
//    }

    return stringsFiles
  }

  public func save(
    resources: [LingoHubResource],
    completion: @escaping (() -> Void)) {

  }
}
