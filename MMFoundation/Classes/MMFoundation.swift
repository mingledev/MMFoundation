//
//  MMFoundation.swift
//  MMFoundation
//
//  Created by Mingle on 2022/2/16.
//

import Foundation
import CommonCrypto

/// 判断对象是否为空或集合类型count是否为0
/// - Parameter obj: 对象
/// - Returns: 是否为空
public func mm_isEmpty(_ obj: AnyObject?) -> Bool {
    guard let value = obj else { return true }
    switch value {
    case is String:
        return (obj as! String).count == 0
    case is Set<AnyHashable>:
        return (obj as! Set<AnyHashable>).count == 0
    case is Array<Any>:
        return (obj as! Array<Any>).count == 0
    case is Dictionary<AnyHashable, Any>:
        return (obj as! Dictionary<AnyHashable, Any>).count == 0
    case is NSNull:
        return true
    default:
        return false
    }
}

/// 转换日期为字符串
/// - Parameters:
///   - date: 日期
///   - dateFormat: 日期格式化
/// - Returns: 日期字符串
public func mm_dateToString(_ date: Date?, dateFormatString: String) -> String? {
    guard let value = date else { return nil }

    return mm_dateToStrirng(value) {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = dateFormatString
        return dateFmt
    }
}

/// 转换日期为字符串
/// - Parameters:
///   - date: 日期
///   - createDateFormat: 创建日期格式化对象
/// - Returns: 日期字符串
public func mm_dateToStrirng(_ date: Date?, createDateFormat: () -> DateFormatter) -> String? {
    guard let value = date else { return nil }
    
    return createDateFormat().string(from: value)
}

/// md5加密
/// - Parameter input: 加密前
/// - Returns: 加密后
public func mm_md5HexDigest(_ input: String) -> String {
    let strLen = CUnsignedInt(input.lengthOfBytes(using: .utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_MD5(input, strLen, result)
    
    var hash = ""
    
    for i in 0..<digestLen {
        hash.append(String(format: "%02x", result[i]))
    }
    
    result.deallocate()
    return hash
}

/// 如果对象是空，则使用指定的对象替换（默认使用空字符串替换）
/// - Parameters:
///   - obj: 对象
///   - use: 替换者
/// - Returns: 结果
public func mm_replaceEmpty<T>(obj: T?, use: T) -> T? {
    return mm_isEmpty(obj as AnyObject?) ? use : obj
}
