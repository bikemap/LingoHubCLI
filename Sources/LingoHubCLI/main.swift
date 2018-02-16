//
//  main.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  blackmirror media
//

import Foundation
import Dispatch

/// The TASKs that can be performed using LungoHub. This can be specified as
/// the first command line option. If missing or cannot be found, it defaults
/// to `help` which displays the usage of the tool.
///
/// - upload: Upload translation files.
/// - download: Download translation file.
/// - help: Display usage of the CLI.
public enum Task {
  case upload
  case download
  case help
  case version

  init(value: String?) {
    guard value != nil else {
      self = .help
      return
    }
    switch value! {
    case "upload": self = .upload
    case "download": self = .download
    case "-v": self = .version
    default: self = .help
    }
  }
}

// Start
let cli = LingoHubCLI()
cli.engage()

// The application will run until exit() is called.
dispatchMain()
