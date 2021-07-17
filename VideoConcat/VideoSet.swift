//
//  VideoSet.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import Foundation

struct VideoSet : Hashable, Codable{
    var videos : [VideoFile]
    var path : String
}
