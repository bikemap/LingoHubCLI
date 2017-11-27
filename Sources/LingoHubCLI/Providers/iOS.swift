//
//  iOS.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  Copyright © 2017 Bikemap GmbH. All rights reserved.
//

import Foundation

open class iOS: ResourceProvider {

  public var projectUrl: String {
    return "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test"
    return "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios"
  }

  public var files: [String] {

    let fileManager = FileManager()
    var stringsFiles: [String] = []

    // TODO: Read these paths from the config file

    // Strings files from the English base translation.
    // TODO: remove

    let projectPath = "/Users/adameri/Developer/bikemap-x-ios"

//    let projectPath = FileManager
//      .default
//      .currentDirectoryPath

    let stringsPath = projectPath + "/Bikemap/en.lproj/"

    do {
      let allFilesInFolder = try fileManager
        .contentsOfDirectory(atPath: stringsPath)

      // Filtering only the strings files
      stringsFiles = allFilesInFolder
        .filter { $0.contains(".strings") }
        .map { stringsPath + $0 }
    } catch {
      print(error)
    }

    // Localizable.strings file from the Base translation
    let localizableStringsPath = projectPath +
      "/Bikemap/Base.lproj/Localizable.strings"
    stringsFiles.append(localizableStringsPath)

    return stringsFiles
  }

  public func save(resource: LingoHubResource) throws {


  }
}
