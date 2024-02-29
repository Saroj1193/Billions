//
//  UIDevice+Extension.swift
//
//
//  Created by  on 11/18/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// <#Description#>
extension UIDevice {
    
    /// <#Description#>
    enum DeviceType {
        case iPhone35
        case iPhone40
        case iPhone47
        case iPhone55
        case iPhoneX
        case iPhoneXR
        case iPad
        case TV
        
        var isPhone: Bool {
            return [ .iPhone35, .iPhone40, .iPhone47, .iPhone55, .iPhoneX ,.iPhoneXR].contains(self)
        }
    }
    
    /// <#Description#>
    var deviceType: DeviceType? {
        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            return .TV
            
        case .pad:
            return .iPad
            
        case .phone:
            let screenSize = UIScreen.main.bounds.size
            let height = max(screenSize.width, screenSize.height)
            
            switch height {
            case 480:
                return .iPhone35 //4
            case 568:
                return .iPhone40 //5
            case 667:
                return .iPhone47 //6 6s
            case 736:
                return .iPhone55 //6+
            case 812:
                return .iPhoneX //X XS
            case 896:
                return .iPhoneXR //XS MAX
            default:
                return nil
            }
            
        case .unspecified:
            return nil
        default:
            return nil
        }
    }
}

import AVFoundation


extension AVAsset {
    // Provide a URL for where you wish to write
    // the audio file if successful
    func writeAudioTrack(to url: URL,success: @escaping () -> (),failure: @escaping (Error) -> ()) {
        do {
            let asset = try audioAsset()
            asset.write(to: url, success: success, failure: failure)
        } catch {
            failure(error)
        }
    }
    
    private func write(to url: URL, success: @escaping () -> (),failure: @escaping (Error) -> ()) {
        // Create an export session that will output an
        // audio track (M4A file)
        guard let exportSession = AVAssetExportSession(asset: self,  presetName: AVAssetExportPresetAppleM4A) else {
            // This is just a generic error
            let error = NSError(domain: "domain", code: 0, userInfo: nil)
            failure(error)
            
            return
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL = url
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                success()
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            }
        }
    }
    
    private func audioAsset() throws -> AVAsset {
        // Create a new container to hold the audio track
        let composition = AVMutableComposition()
        // Create an array of audio tracks in the given asset
        // Typically, there is only one
        let audioTracks = tracks(withMediaType: .audio)
        
        // Iterate through the audio tracks while
        // Adding them to a new AVAsset
        for track in audioTracks {
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                // Add the current audio track at the beginning of
                // the asset for the duration of the source AVAsset
                try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            } catch {
                throw error
            }
        }
        
        return composition
    }
}
