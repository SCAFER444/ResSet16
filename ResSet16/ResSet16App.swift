//
//  ResSet16App.swift
//  ResSet16
//
//  Created by sourcelocation on 28/01/2023.
//

import SwiftUI

@main
struct ResSet16App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkNewVersions()
                    checkAndEscape()
                }
        }
    }
    
    func checkAndEscape() {
#if targetEnvironment(simulator)
#else
        var supported = false
        var needsTrollStore = false
        if #available(iOS 16.6, *) {
            supported = true
        } else if #available(iOS 16.0, *) {
            supported = true
            needsTrollStore = false
        } else if #available(iOS 15.7.2, *) {
            supported = false
        } else if #available(iOS 15.0, *) {
            supported = true
            needsTrollStore = false
        } else if #available(iOS 14.0, *) {
            supported = true
            needsTrollStore = true
        }
        
        if !supported {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.")
            return
        }
        
        do {
            // Check if application is entitled
            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile"), includingPropertiesForKeys: nil)
        } catch {
            if needsTrollStore {
                UIApplication.shared.alert(title: "Use TrollStore", body: "You must install this app with TrollStore for it to work with this version of iOS.")
                return
            }
            // Use MacDirtyCOW to gain r/w
            grant_full_disk_access() { error in
                if (error != nil) {
                    UIApplication.shared.alert(body: "\(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                    return
                }
            }
        }
#endif
    }
    
    func checkNewVersions() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/sourcelocation/ResSet16/releases/latest") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["tag_name"] as? String)?.compare(version, options: .numeric) == .orderedDescending {
                        UIApplication.shared.confirmAlert(title: "Update Available", body: "A new version of ResSet16 is available. It is recommended you update to avoid encountering bugs. Would you like to view the releases page?", onOK: {
                            UIApplication.shared.open(URL(string: "https://github.com/sourcelocation/ResSet16/releases/latest")!)
                        }, noCancel: false)
                    }
                }
            }
            task.resume()
        }
    }
}
