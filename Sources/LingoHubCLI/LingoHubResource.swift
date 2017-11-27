//
//  LingoHubResource.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 27.11.17.
//  blackmirror media
//

import Foundation
import Marshal

/// LingoHubResource is the struct representation of the resource links
/// returned from LingoHub.
/// It uses Marshal to map the JSON to the struct.
///
/// Example JSON:
/// {
///   "rel": "self",
///   "href": "https://api.lingohub.com/v1/bikemap-gmbh/projects/ios-test/resources/Ride.de.strings",
///   "type": "text/plain"
/// }
public struct LingoHubResourceLink: Unmarshaling {
  public var rel: String
  public var href: String
  public var type: String

  public init(object: MarshaledObject) throws {
    self.rel = try object.value(for: "rel")
    self.href = try object.value(for: "href")
    self.type = try object.value(for: "type")
  }
}

/// LingoHubResource is the struct representation of the resources
/// returned from LingoHub.
/// It uses Marshal to map the JSON to the struct.
///
/// Example JSON:
/// {
///   "name": "Ride.de.strings",
///   "links": [LingoHubResourceLink],
///   "project_locale": "de"
/// }
public struct LingoHubResource: Unmarshaling {
  public var name: String
  public var locale: String
  public var links: [LingoHubResourceLink]

  public init(object: MarshaledObject) throws {
    self.name = try object.value(for: "name")
    self.locale = try object.value(for: "locale")
    self.links = try object.value(for: "links")
  }
}



