//
//  MMPermission.swift
//  MMFoundation
//
//  Created by Mingle on 2022/2/19.
//

import UIKit
import Photos

public enum MMPermissionType {
    case camera
    case photo
    case locationInUse
    case locationAlways
    case microphone
}

public enum MMPermissionStatus {
    /// 用户未确定权限
    case notDetermined
    /// 已授权
    case authorized
    /// 有限制的权限
    case limited
    /// 未授权
    case denied
}

public class MMPermission:NSObject, CLLocationManagerDelegate {
    
    /// 用于持有对象，防止被意外释放掉，注意手动释放，防止内存泄露
    private var retainObj: AnyObject?
    
    private lazy var locationMgr: CLLocationManager = {
        let mgr = CLLocationManager()
        mgr.delegate = self
        return mgr
    }()
    
    private var type: MMPermissionType
    
    private var authCallback: ((MMPermissionStatus) -> Void)?
    
    public init(_ type: MMPermissionType) {
        self.type = type
        super.init()
    }
    
    public func request(_ closure:@escaping (MMPermissionStatus) -> Void) {
        authCallback = closure
        switch type {
        case .camera:
            requestCamera()
            break
        case .photo:
            requestPhoto()
            break
        case .locationInUse:
            requestLocation(false)
            break
        case .locationAlways:
            requestLocation(true)
            break
        case .microphone:
            requestMicrophone()
            break
        }
    }
    
    func requestCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            case .authorized:
            authCallback?(.authorized)
            break
        case .notDetermined:
            authCallback?(.notDetermined)
            break
        default:
            authCallback?(.denied)
            break
        }
    }
    
    func requestPhoto() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    self.authCallback?(.authorized)
                    break
                case .limited:
                    self.authCallback?(.limited)
                    break
                case .notDetermined:
                    self.authCallback?(.notDetermined)
                    break
                default:
                    self.authCallback?(.denied)
                    break
                }
            }
        } else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.authCallback?(.authorized)
                    break
                case .limited:
                    self.authCallback?(.limited)
                    break
                case .notDetermined:
                    self.authCallback?(.notDetermined)
                    break
                default:
                    self.authCallback?(.denied)
                    break
                }
            }
        }
    }
    
    func requestLocation(_ always: Bool) {
        retainObj = self
        if always {
            locationMgr.requestAlwaysAuthorization()
        } else {
            locationMgr.requestWhenInUseAuthorization()
        }
    }
    
    func requestMicrophone() {
        AVAudioSession.sharedInstance().requestRecordPermission { (ret) in
            self.authCallback?(ret ? .authorized : .denied)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            authCallback?(.authorized)
            break
        case .notDetermined:
            return
        default:
            authCallback?(.denied)
            break
        }
        retainObj = nil
    }
    
    deinit {
        debugPrint("deinit")
    }
}
