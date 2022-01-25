//
//  AppDelegate.swift
//  NowPlayingRetriever
//
//  Created by Adar Hefer on 24/01/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    
    private var getNowPlaying: MRMediaRemoteGetNowPlayingInfoFunction!
    private var registerForNotifications: MRMediaRemoteRegisterForNowPlayingNotificationsFunction!
    private var getIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Load framework
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        getNowPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        
        guard let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) else { return }
        
        registerForNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)
        
        registerForNotifications(.main)
        
        guard let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) else { return }
        
        getIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
        
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "kMRMediaRemoteNowPlayingApplicationDidChangeNotification"),
                                               object: nil,
                                               queue: .main,
                                               using: { notification in
            self.delayAndUpdateNowPlayingInformation()
        })
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
                                               object: nil,
                                               queue: .main,
                                               using: { notification in
            self.delayAndUpdateNowPlayingInformation()
        })
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"),
                                               object: nil,
                                               queue: .main,
                                               using: { notification in
            self.delayAndUpdateNowPlayingInformation()
        })
        
        updateNowPlayingInformation()
    }
    
    private var currentTrack = ""
    
    private var timer: Timer?
    
    private func delayAndUpdateNowPlayingInformation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.updateNowPlayingInformation()
        }
    }
    
    private func updateNowPlayingInformation() {
        getNowPlaying(.main) { [self] information in
            getIsPlaying(.main) { [self] isPlaying in
                guard isPlaying else {
                    currentTrack = ""
                    delete(fileName: "artist", fileExtension: "txt")
                    delete(fileName: "track", fileExtension: "txt")
                    delete(fileName: "album", fileExtension: "txt")
                    delete(fileName: "artwork", fileExtension: "jpg")
                    return
                }
                if let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                    if currentTrack == title {
                        return
                    }
                    currentTrack = title
                    if let data = title.data(using: .utf8) {
                        write(data: data, fileName: "track", fileExtension: "txt")
                    }
                } else {
                    delete(fileName: "track", fileExtension: "txt")
                }
                if let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String,
                    let data = artist.data(using: .utf8) {
                    write(data: data, fileName: "artist", fileExtension: "txt")
                } else {
                    delete(fileName: "artist", fileExtension: "txt")
                }
                if let album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String,
                   let data = album.data(using: .utf8) {
                    write(data: data, fileName: "album", fileExtension: "txt")
                } else {
                    delete(fileName: "album", fileExtension: "txt")
                }
                if let artwork = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    switch information["kMRMediaRemoteNowPlayingInfoArtworkMIMEType"] as? String {
                    case "image/jpeg":
                        write(data: artwork, fileName: "artwork", fileExtension: "jpg")
                    default:
                        guard let representation = NSImage(data: artwork)?.representations.first as? NSBitmapImageRep,
                              let jpegData = representation.representation(using: .jpeg, properties: [:])
                        else { break }
                        
                        write(data: jpegData, fileName: "artwork", fileExtension: "jpg")
                    }
                } else {
                    delete(fileName: "artwork", fileExtension: "jpg")
                }
            }
        }
    }
    
    private func write(data: Data, fileName: String, fileExtension: String) {
        let fileUrl = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtension)
        
        try? data.write(to: fileUrl)
    }
    
    private func delete(fileName: String, fileExtension: String) {
        write(data: Data(), fileName: fileName, fileExtension: fileExtension)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

