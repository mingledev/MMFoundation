//
//  FileManager+MMEasy.swift
//  MMFoundation
//
//  Created by Mingle on 2022/2/16.
//

import Foundation

public extension FileManager {
    
    static func directory(_ dir: SearchPathDirectory, _ domain: SearchPathDomainMask = .userDomainMask, _ expandTidle: Bool = true) -> [String] {
        return NSSearchPathForDirectoriesInDomains(dir, domain, expandTidle)
    }
    
    func isExistsDir(_ dirPath: String) -> Bool {
        var isDir: ObjCBool = false
        let isExists = fileExists(atPath: dirPath, isDirectory: &isDir)
        return isDir.boolValue == true && isExists == true
    }
    
    func createDir(_ dirPath: String, isNotExists: Bool = true) {
        if isNotExists && isExistsDir(dirPath) {
            return
        }
        try? createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func fileSizeAt(path: String) -> UInt64 {
        if isExistsDir(path) {
            return folderSizeAt(path: path)
        } else if fileExists(atPath: path) {
            return (try? attributesOfItem(atPath: path))?[.size] as? UInt64 ?? 0
        }
        return 0
    }
    
    func folderSizeAt(path: String) -> UInt64 {
        var size: UInt64 = 0
        if fileExists(atPath: path) == false { return size }
        guard let subPaths = subpaths(atPath: path) else { return size }
        var count = 0
        for name in subPaths {
            let subpath = "\(path)/\(name)"
            if !isExistsDir(subpath) {
                let att = try? attributesOfItem(atPath: subpath)
                size += (att?[.size] as? UInt64 ?? 0)
                count+=1
            }
        }
        return size
    }
    
}
