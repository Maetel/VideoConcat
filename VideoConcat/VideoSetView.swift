//
//  VideoSetView.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import SwiftUI

struct VideoSetView: View {
    @State var videos : VideoSet
    @State var id : Int
    var body: some View {
        HStack{
            Text("[" + String(id) + "]")
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)}
            VStack{
                List {
                    ForEach(videos.videos, id: \.self) {videofile in
                        Text(videofile.path)
                   }}
            }
        
    }
}

struct VideoSetView_Previews: PreviewProvider {
    static var previews: some View {
        VideoSetView(videos:VideoSet(videos: [], path:"path"), id:1)
    }
}
