//
//  FileView.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import SwiftUI

struct FileView: View {
    var video : VideoFile
    @State var checked : Bool = false
    var body: some View {
        
        HStack {
            Text(video.path)
            Spacer()
            Button(action: {
                    
                checked = !checked

            }) {
                Image(   systemName: checked ? "plus.rectangle.on.rectangle":"plus.rectangle.fill.on.rectangle.fill")
                    .renderingMode(.original)
            }.padding().foregroundColor(.red).listItemTint(.green).controlSize(.large)
        }
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(video:
                    VideoFile(path: "path/file1", addedId:0))
    }
}
