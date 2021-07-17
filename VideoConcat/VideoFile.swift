//
//  VideoFile.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import Foundation

func getFileName(of video: VideoFile)->String{
    return URL(fileURLWithPath: video.path).lastPathComponent
}

struct VideoFile : Hashable, Codable {
    var path: String
    var checked : Bool = false
}
