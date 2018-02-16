//
//  URLSession+Extension.swift
//  LingoHubCLI
//
//  Created by Adam Eri on 16.02.18.
//

import Foundation

extension NSMutableData {
  func appendString(_ string: String) {
    let data = string.data(
      using: String.Encoding.utf8,
      allowLossyConversion: false)
    append(data!)
  }
}

extension URLRequest {

  public static func multipartFromDataFileUploadRequest(
    url: URL,
    file: URL,
    parameters: [String: String]? = nil) -> URLRequest {

    let boundary = "Boundary-\(UUID().uuidString)"
    var urlRequest: URLRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type")

    urlRequest.httpBody = URLRequest.createBody(
      parameters: [:],
      boundary: boundary,
      data: try! Data.init(contentsOf: file),
      mimeType: "text/plain",
      filename: file.lastPathComponent)

    return urlRequest
  }

  public static func createBody(
    parameters: [String: String],
    boundary: String,
    data: Data,
    mimeType: String,
    filename: String) -> Data {
    let body = NSMutableData()

    let boundaryPrefix = "--\(boundary)\r\n"

    for (key, value) in parameters {
      body.appendString(boundaryPrefix)
      body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      body.appendString("\(value)\r\n")
    }

    body.appendString(boundaryPrefix)
    body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
    body.append(data)
    body.appendString("\r\n")
    body.appendString("--".appending(boundary.appending("--")))

    return body as Data
  }
}
