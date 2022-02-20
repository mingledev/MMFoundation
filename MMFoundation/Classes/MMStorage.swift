//
//  MMStorage.swift
//  MMFoundation
//
//  Created by Mingle on 2022/2/19.
//

import UIKit
import FMDB

/// 存储方式
public enum MMStorageType {
    case userDefault
    case fmdb
    case memory
}

public protocol MMStorageProtocol: NSObjectProtocol {
    
    var storageType: MMStorageType { get set }
    
    /// 保存
    /// - Returns: 返回保存结果
    func save<T: MMStorageDataProtocol>(_ value: T, for key: String, replaceIfExists: Bool) -> Bool
    
    /// 查询
    /// - Returns: 查询结果
    func get<T: MMStorageDataProtocol>(for key: String) -> T?
    
    /// 删除
    /// - Returns: 删除结果
    func remove(for key: String) -> Bool
}

/// 支持存储类型的协议，可以实现协议来扩展支持的类型
public protocol MMStorageDataProtocol {
    func toString() -> String?
    static func from(_ string: String) -> Self?
}

public class MMStorage: NSObject, MMStorageProtocol {
    
    /// 内存空间，用于存储数据
    private static var memorySpace = Dictionary<String, String>()
    
    /// 设置数据保存的表名
    public let tableName = "TableKeyValue"
    private let keyOfTableColumn = "key"
    private let valueOfTableColumn = "value"
    
    private let userDefaultKey = "MMStorageKey"
    
    /// 数据库路径
    public var dbPath: String = FileManager.directory(.documentDirectory).last! + "/MMStorage/MMStorage.db"
    
    /// 存储类型
    public var storageType: MMStorageType = .userDefault
    
    /// 创建实例
    /// - Parameter storageType: 存储方式，默认userDefault
    /// - Returns: 实例
    public class func storage(_ storageType: MMStorageType = .userDefault) -> MMStorage {
        let obj = MMStorage()
        obj.storageType = storageType
        return obj
    }
    
    public class var db: MMStorage {
        return storage(.fmdb)
    }
    
    public class var userDefaults: MMStorage {
        return storage(.userDefault)
    }
    
    public class var memory: MMStorage {
        return storage(.memory)
    }
    
    /// 保存到数据库
    /// - Returns: 保存结果
    private func saveToFMDB<T: MMStorageDataProtocol>(_ value: T, for key: String, replaceIfExists: Bool) -> Bool {
        let fileURL = URL(fileURLWithPath: dbPath)
        let pathDir = fileURL.deletingLastPathComponent().path
        FileManager.default.createDir(pathDir)
        let dbMgr = FMDatabase(path: dbPath)
        dbMgr.open()
        
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) ('rowid' INTEGER PRIMARY KEY AUTOINCREMENT, '\(keyOfTableColumn)' TEXT NOT NULL, '\(valueOfTableColumn)' TEXT NOT NULL)"
        do {
            try dbMgr.executeUpdate(sql, values: nil)
        } catch let error {
            debugPrint("MMStorage Create Table Fail: \(error.localizedDescription)")
            dbMgr.close()
            return false
        }
        
        if let _: T = get(for: key) {
            if replaceIfExists == false {
                dbMgr.close()
                return false
            }
            dbMgr.open()
            do {
                let sql = "UPDATE \(tableName) SET \(valueOfTableColumn) = '\(value.toString() ?? "")' WHERE \(keyOfTableColumn) = '\(key)'"
                try dbMgr.executeUpdate(sql, values: nil)
            } catch {
                dbMgr.close()
            }
        } else {
            dbMgr.open()
            do {
                let sql = "INSERT INTO \(tableName)(\(keyOfTableColumn),\(valueOfTableColumn)) VALUES('\(key)','\(value.toString() ?? "")')"
                try dbMgr.executeUpdate(sql, values: nil)
            } catch {
                dbMgr.close()
                return false
            }
        }
        
        dbMgr.close()
        return true
    }
    
    private func saveToUserDefault<T: MMStorageDataProtocol>(_ value: T, for key: String, replaceIfExists: Bool) -> Bool {
        var userDefaultSpace = (UserDefaults.standard.value(forKey: key) as? [String: String]) ?? [String:String]()
        if userDefaultSpace[key] != nil && replaceIfExists == false { return false }
        userDefaultSpace[key] = value.toString()
        UserDefaults.standard.set(userDefaultSpace, forKey: userDefaultKey)
        return true
    }
    
    private func saveToMemoryu<T: MMStorageDataProtocol>(_ value: T, for key: String, replaceIfExists: Bool) -> Bool {
        if MMStorage.memorySpace[key] != nil && replaceIfExists == false { return false }
        MMStorage.memorySpace[key] = value.toString()
        return true
    }
    
    public func save<T: MMStorageDataProtocol>(_ value: T, for key: String, replaceIfExists: Bool = true) -> Bool {
        switch storageType {
        case .userDefault:
            if replaceIfExists == false && UserDefaults.standard.object(forKey: key) != nil {
                break
            }
            UserDefaults.standard.set(value.toString, forKey: key)
            break
        case .fmdb:
            return saveToFMDB(value, for: key, replaceIfExists: replaceIfExists)
        case .memory:
            if replaceIfExists == false && MMStorage.memorySpace[key] != nil {
                break
            }
            MMStorage.memorySpace[key] = value.toString()
            break
        }
        return true
    }
    
    public func get<T: MMStorageDataProtocol>(for key: String) -> T? {
        let dbMgr = FMDatabase(path: dbPath)
        dbMgr.open()
        let sql = "SELECT \(valueOfTableColumn) FROM \(tableName) WHERE \(keyOfTableColumn) = '\(key)'"
        do {
            let result = try dbMgr.executeQuery(sql, values: nil)
            while result.next() {
                let value = T.from(result.string(forColumn: valueOfTableColumn) ?? "")
                dbMgr.close()
                return value
            }
        } catch let error {
            debugPrint("SELECT FAIL: \(error.localizedDescription)")
            dbMgr.close()
            return nil
        }
        dbMgr.close()
        return nil
    }
    
    public func remove(for key: String) -> Bool {
        let dbMgr = FMDatabase(path: dbPath)
        dbMgr.open()
        let sql = "DELETE FROM \(tableName) WHERE \(keyOfTableColumn)='\(key)'"
        do {
            try dbMgr.executeUpdate(sql, values: nil)
        } catch let error {
            debugPrint("DELETE FAIL: \(error.localizedDescription)")
            dbMgr.close()
            return false
        }
        dbMgr.close()
        return true
    }
    
    public func dropTable(_ table: String) -> Bool {
        let dbMgr = FMDatabase(path: dbPath)
        dbMgr.open()
        let sql = "DROP TABLE \(tableName)"
        do {
            try dbMgr.executeUpdate(sql, values: nil)
        } catch let error {
            debugPrint("DROP TABLE \(tableName) FAIL: \(error.localizedDescription)")
            dbMgr.close()
            return false
        }
        dbMgr.close()
        return true
    }
    
    public func dropCurrentTable() -> Bool {
        return dropTable(tableName)
    }
    
    /// 清空数据
    public func clear() {
        switch storageType {
        case .userDefault:
            UserDefaults.standard.removeObject(forKey: userDefaultKey)
            break
        case .fmdb:
            try? FileManager.default.removeItem(atPath: dbPath)
            break
        case .memory:
            MMStorage.memorySpace.removeAll()
            break
        }
    }
    
}

extension String: MMStorageDataProtocol {
    
    public func toString() -> String? {
        return self
    }
    
    public static func from(_ string: String) -> String? {
        return string
    }
}

extension Data: MMStorageDataProtocol {
    
    public func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
    public static func from(_ string: String) -> Data? {
        return string.data(using: .utf8)
    }
}

extension UIImage: MMStorageDataProtocol {
    
    public func toString() -> String? {
        guard let data = UIImageJPEGRepresentation(self, 1) else { return nil }
        return data.base64EncodedString()
    }
    
    public static func from(_ string: String) -> Self? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return UIImage(data: data) as? Self
    }
    
}

extension Bool: MMStorageDataProtocol {
    
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Bool? {
        return Bool(string)
    }
}

extension Int: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Int? {
        return Int(string)
    }
}

extension Int32: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Int32? {
        return Int32(string)
    }
}

extension Int64: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Int64? {
        return Int64(string)
    }
}

extension Float: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Float? {
        return Float(string)
    }
}

extension Double: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(self)
    }
    public static func from(_ string: String) -> Double? {
        return Double(string)
    }
}

extension Date: MMStorageDataProtocol {
    public func toString() -> String? {
        return String(timeIntervalSince1970)
    }
    public static func from(_ string: String) -> Date? {
        return Date(timeIntervalSince1970: TimeInterval(string) ?? 0)
    }
}
