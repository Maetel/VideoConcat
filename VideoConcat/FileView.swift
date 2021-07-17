//
//  FileView.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import SwiftUI

struct VideoFileView: View {
    @State var video : VideoFile
    @State var checked : Bool = false
    var body: some View {
        
        HStack {
            //Text(URL(fileURLWithPath: video.path).lastPathComponent)
            Text(getFileName(of: video))
            Spacer()
            
        }
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        VideoFileView(video:
                    VideoFile(path: "path/file1", checked:false))
    }
}
