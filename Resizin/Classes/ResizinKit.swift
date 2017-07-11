//
//  ResizinKit.swift
//  ImageSDK
//
//  Created by Jan Mísař on 02.05.16.
//  Copyright © 2016 Ackee. All rights reserved.
//

import Foundation
import UIKit


/// Shared manager
public class ResizinManager: NSObject {

    /// Library server environment
    ///
    /// - production: Preset production environment
    /// - custom: Custom server
    public enum Environment {
        case production
        case custom(String)
        
        var url: String {
            switch self {
            case .production: return "https://api.resizin.com/api/v1/image/upload"
            case .custom(let url): return url
            }
        }
    }
    
    /// Image server URL. Change it only in very specific situations. Standard URLs for development and production is set by default
    public var baseURL: URL
    
    /// URL path component to be appended to base URL
    public var projectName: String

    /// Image uploading service
    private let uploader: Uploader

    /// Returns shared image manager.
    ///
    /// **You must call setupSharedManagerWithProjectName(_) before use!**
    public static var sharedManager: ResizinManager {
        if let manager = _sharedManager {
            return manager
        } else {
            assertionFailure("You must initialize sharedManager with setupSharedManagerWithProjectName(_) first!")
            return ResizinManager(projectName: "", baseURL: Environment.production.url, clientKey: "")
        }
    }

    /// Create and setup singleton instance of image manager
    ///
    /// - Parameters:
    ///   - projectName: URL path component to be appended to base URL
    ///   - environment: Image server environment. Default: `.production`
    ///   - clientKey: API client key
    public static func setupSharedManager(projectName: String, environment: Environment = Environment.production, clientKey: String) {
        _sharedManager = ResizinManager(projectName: projectName, baseURL: environment.url, clientKey: clientKey)
    }
    
    /// Signleton manager instance
    private static var _sharedManager: ResizinManager?

    // MARK: Initializers
    
    public init(projectName: String, baseURL: String, clientKey: String) {
        self.baseURL = baseURL
        self.projectName = projectName
        self.uploader = Uploader(baseURL: URL(string: baseURL)!, clientKey: clientKey)
        
        super.init()
        
        if type(of: self)._sharedManager == nil {
            type(of: self)._sharedManager = self
        }
    }
    
    /// Returns builded url for specific image and options
    ///
    /// - Parameters:
    ///   - key: id of image
    ///   - settings: specific settings for transformations
    /// - Returns: URL for desired image
    public func url(for key: String, settings: ResizinSettings = ResizinSettings()) -> URL {
        
        // "static" part of URL
        var url = URL(string: "\(baseURL)/\(projectName)/image")!
        
        // append all modifier according to given settings
        let modifiers = settings.modifiers
        
        // append modifiers to URL
        if modifiers.count > 0 {
            let modifiersString = modifiers.joined(separator: "-")
            url = url.appendingPathComponent(modifiersString)
        }
        
        return url.appendingPathComponent(key)
    }

    /// Uploads given image to Resizin server
    ///
    /// - Parameters:
    ///   - image: Image which will be uploaded
    ///   - name: Image name
    ///   - completion: Upload callback
    public func upload(image: UIImage, name: String, completion: ((Result<ImageReference, ResizinError>) -> Void)?) {
        let location = "\(projectName)/\(name)"

        uploader.upload(image: image, location: location, completion: completion)
    }
}
