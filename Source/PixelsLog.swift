//
//  PixelsLog.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension Pixels {
    
    public enum LogLevel: String {
        case none = ""
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
        case debug = "DEBUG"
        var index: Int {
            switch self {
            case .none: return 0
            case .info: return 1
            case .warning: return 2
            case .error: return 3
            case .fatal: return 4
            case .debug: return 5
            }
        }
    }
    
    public enum LogCategory: String {
        case pixels = "Pixels"
        case render = "Render"
        case texture = "Texture"
        case resource = "Resource"
        case generator = "Generator"
        case effect = "Effect"
        case connection = "Connection"
        case view = "View"
        case res = "Res"
        case fileIO = "File IO"
        case metal = "Metal"
    }
    
    public func log(prefix: String = "Pixels", pix: PIX? = nil, _ level: LogLevel, _ category: LogCategory?, _ message: String, loop: Bool = false, clean: Bool = false, e error: Error? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        
        var pixType: String?
        if let p = pix {
            pixType = String(String(describing: p).split(separator: ".").last ?? "")
        }
        
        var cleanLog = "\(prefix) "
        if pixType != nil {
            cleanLog += "\(pixType!) "
        }
        cleanLog += message
        if let e = error {
            cleanLog += " Error: \(e)"
        }
        
        guard level != .fatal else {
            fatalError(cleanLog)
        }
        
        if level.index > logLevel.index {
            return
        }
        
        if loop && logLoopLimitActive && frame > logLoopLimitFrameCount {
            if !logLoopLimitIndicated {
                print("Pixels Running...")
                logLoopLimitIndicated = true
            }
            return
        }
        
        if clean {
            print(cleanLog)
            return
        }
        
        // MARK: Log List
        
        var logList: [String] = []
        
        logList.append(prefix)
        
        #if DEBUG
        logList.append("#\(frame < 10 ? "0" : "")\(frame)")
        #else
        if level == .debug { return }
        #endif
        
        logList.append(level.rawValue)
        
        if pixType != nil {
            logList.append(pixType!)
        }
        
        if let pixName = pix?.name {
            logList.append("\"\(pixName)\"")
        }
        
        if let c = category {
            logList.append(c.rawValue)
        }
        
        if logPadding {
            let firstPadding = spaces(40 - logLength(logList))
            logList.append(firstPadding)
        } else {
            logList.append(">>>")
        }
        
        logList.append(message)
        
        if let e = error {
            logList.append("Error: \"\(e)\"")
        }
        
        if logPadding {
            let secondPadding = spaces(80 - logLength(logList))
            logList.append(secondPadding)
        } else {
            logList.append("<<<")
        }
        
        #if DEBUG
        let fileName = file.split(separator: "/").last!
        logList.append("\(fileName):\(function):\(line)")
        #endif
        
        var log = ""
        for (i, subLog) in logList.enumerated() {
            if i > 0 { log += " " }
            log += subLog
        }
        
        print(log)
        
    }
    
    func logLength(_ logList: [String]) -> Int {
        var length = -1
        for log in logList {
            length += log.count + 1
        }
        return length
    }
    
    func spaces(_ count: Int) -> String {
        guard count > 0 else { return "" }
        var spaces = ""
        for _ in 0..<count {
            spaces += " "
        }
        return spaces
    }
    
}
