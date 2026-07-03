//
//  ProjectPath.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/10/24.
//

import Foundation

func projectPath() -> String {
    return String(
        URL(fileURLWithPath: #filePath)
            .pathComponents
            .prefix(while: { $0 != "CodeEditUITests" })
            .joined(separator: "/")
            .dropFirst()
    )
}

private var tempProjectPathIds = Set<String>()

private func makeTempID() -> String {
    let id = String((0..<10).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-".randomElement()! })
    if tempProjectPathIds.contains(id) {
        return makeTempID()
    }
    tempProjectPathIds.insert(id)
    return id
}

func tempProjectPath() throws -> String {
    let baseDir = FileManager.default.temporaryDirectory.appending(path: "CodeEditUITests")
    let id = makeTempID()
    let path = baseDir.appending(path: id)
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    return path.path(percentEncoded: false)
}

func appWritableTempProjectID() -> String {
    makeTempID()
}

func cleanUpTempProjectPaths() throws {
    let fileManager = FileManager.default
    let baseDir = FileManager.default.temporaryDirectory.appending(path: "CodeEditUITests")
    var cleanupError: Error?
    var remainingIDs = Set<String>()

    for id in tempProjectPathIds {
        let path = baseDir.appending(path: id)
        guard fileManager.fileExists(atPath: path.path(percentEncoded: false)) else {
            continue
        }

        do {
            try fileManager.removeItem(at: path)
        } catch {
            cleanupError = cleanupError ?? error
            remainingIDs.insert(id)
        }
    }

    tempProjectPathIds = remainingIDs

    if let cleanupError {
        throw cleanupError
    }
}
