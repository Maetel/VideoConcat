//
//  ContentView.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import SwiftUI
import AVFoundation

//func merge(arrayVideos:[AVAsset], completion:@escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {

let ignoreLastCharacter = {(str:String)->String in
    return String(str[str.startIndex..<str.index(before:str.endIndex)])}
let cutter = {(str:String, parseBy:Character)->String in return ignoreLastCharacter(String(str[...str.lastIndex(of:parseBy)!]))}

struct ExportVideoSet : Hashable, Codable {
    var videos : [VideoFile]
    var filename : String
    var doExport : Bool = true
}

struct ContentView: View {
  @State var filename = "파일 :"
  @State var showFileChooser = false
    @State var filenames: [VideoFile] = []
    @State var checked : [Bool] = []
    @State var areAdded : [Bool] = []
    @State var tempFileNames : [VideoFile] = []
    @State var isMerging = "대기"
    @State var currentSelectedVideos :[VideoFile] = []
    @State var toBeExportedVideos : [ExportVideoSet] = []
    @State var destDir : URL = URL(fileURLWithPath: FileManager().homeDirectoryForCurrentUser.path, isDirectory: true)
    @State private var showingAbout = false
    @State var droppedFiles : [URL] = []
    @State private var dragOver = false
    
    func initialDestDir()->URL {
        return FileManager().homeDirectoryForCurrentUser
    }
    
    func handleCompletion(at url:URL){
        isMerging = "완료 : " + url.path
    }
    func reset(){
             filename = "파일 :"
             showFileChooser = false
             filenames = []
             isMerging = "대기"
             currentSelectedVideos = []
             checked = []
             areAdded = []
             toBeExportedVideos = []
            destDir = initialDestDir()
    }
    
  var body: some View {
    VStack {
        
        //Header
        HStack {
          Text(filename)
          Button("선택")
          {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = false
            panel.allowedFileTypes = ["mp4"]
            if panel.runModal() == .OK {
                let filtered = panel.urls.filter{
                    return $0.pathExtension.lowercased() == "mp4"
                }
                for url in filtered {
                    destDir = panel.directoryURL!
                    filenames.append(VideoFile(path: url.path, checked: false))
                    checked.append(false)
                    areAdded.append(false)
                }

                filenames = filenames.sorted{return $0.path < $1.path}
                isMerging = String(filenames.count) + "개 파일 추가됨"
            }
          }
            Button("리셋"){
                reset()
            }
        }.frame(height:50)
        Divider()
        
        //contents
        HStack{
            
        //left
            VStack{
                Text("파일 목록 :")
                Divider()
                List{
                    ForEach(0..<filenames.count, id: \.self) {i in
                    GeometryReader { metrics in HStack {
                        VideoFileView(video: filenames[i]).frame(width:metrics.size.width * 0.8, height:metrics.size.height * 1.0)
                        Button(action: {
                            checked[i].toggle()
                        }) {Image(systemName: (checked[i] ? "circle.fill" : "circle.dashed")).foregroundColor(checked[i] ? .blue : .red)
                        }.disabled(areAdded[i]).frame(width:metrics.size.width * 0.2, height:metrics.size.height * 1.0)
                        }
                    }
                }
            }
            }
            
            Divider()
            
            //middle
            VStack{
                Image(systemName: "arrowshape.zigzag.right").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                Button (action: {
                    //filenames.filter( { (videofile: VideoFile) -> Bool in return videofile.checked })
                    var toAppend : [VideoFile] = []
                
                    var checkedIndices : [Int] = []
                    for (index, check) in checked.enumerated() {
                        if(check){
                            toAppend.append(filenames[index])
                            checkedIndices.append(index)
                        }
                    }
                    if(toAppend.isEmpty || toAppend.count <= 1){
                        isMerging = "2개 이상 선택해주세요"
                        return
                    }
                    var curPath : String = ""
                    
                    
                    toAppend.sort(by: {(lhs, rhs)->Bool in return lhs.path > rhs.path})
                    for file in toAppend {
                        curPath = cutter(getFileName(of:file), ".") + "+" + curPath
                    }
                    let finalPath = cutter(curPath, "+") + ".mp4"
                    
                    toBeExportedVideos.append(ExportVideoSet(videos:toAppend, filename:finalPath))
                    //toBeExportedVideos.append(curSet)
                    
                    //disable if added
                    for index in checkedIndices.reversed() {
                        areAdded[index] = true
                    }
                    
                    
                    //clean up checked
                    checked = Array(repeating: false, count: filenames.count)
                    isMerging = "출력 예정에 " + String(finalPath) + " 추가됨"
                    
                    //updateFilelistView()
                    
//                    print(curSet)
//                    print(toBeExportedVideos)
//                    ForEach(filenames, id: \.self) {videofile in
//                        VideoFileView(video: videofile)}
                        }
                , label: {
                    Text("더하기")
                }).controlSize(.large)
            }
            
            Divider()
            //right
            VStack{
                Text("출력 예정 :")
                Divider()
                List {
                    ForEach(toBeExportedVideos, id: \.self) {video in
                        HStack{
                            Text(video.filename)
                            Spacer()
                            Text(video.doExport ? "대기" : "완료")
                        }.foregroundColor(video.doExport ? .red : .blue)
                    }
            }
            
                
//                ForEach(0..<self.toBeExportedVideos.count, id: \.self) {i in
//                    VideoSetView(videos: VideoSet(videos: toBeExportedVideos[i].videos, path: toBeExportedVideos[i].path), id: i+1)}
            }
        }
        Divider()
        
        //footer
        GeometryReader { metrics in
            HStack {
            HStack {
                Text("출력폴더 : " + destDir.path)
                Spacer()
                Button(action: {
                    let panel = NSOpenPanel()
                    panel.directoryURL = destDir
                    panel.canChooseDirectories = true
                    panel.canCreateDirectories = true
                    if panel.runModal() == .OK {
                        destDir = panel.directoryURL!
                    }
                }, label: {
                    Text("지정하기")
                })
            }.frame(height:metrics.size.height * 0.5)
            Divider()
            HStack {
                Text("현재 상태 : " + isMerging)
                Spacer()
                Button(action: { //Export button
                    //AVAssetExportSession(
                    
                    for (index, set) in toBeExportedVideos.enumerated() {
                        let panel = NSSavePanel()
                        panel.directoryURL = destDir
                        panel.canCreateDirectories = true
                        panel.nameFieldStringValue = set.filename
                        if panel.runModal() == .OK {
                            let totalExportCount = toBeExportedVideos.count
                            var assets : [AVAsset] = [];
            //                for file in filenames{
            //                    assets.append(AVAsset(url:URL(fileURLWithPath:file.path)))
            //                }
                            set.videos.forEach{
                                assets.append(AVAsset(url:URL(fileURLWithPath:$0.path)))
                            }
                            
                            //let outURL = URL(fileURLWithPath: panel.directoryURL!.path + set.filename)
                            isMerging="합치는 중 : " + set.filename + ", " + String(index+1) + "/" + String(totalExportCount) + "..."
                            merge(
                                outPath:panel.url!
                                //outPath:panel.url!
                                ,arrayVideos: assets
                                , completion: {(_,_) in handleCompletion(at:destDir)}
                            )
                            toBeExportedVideos[index].doExport = false
                        }
                    }
                }, label: {
                    Text("출력")
                })
                
            }.frame(height:metrics.size.height * 0.5)
            }
        }.frame(height:50)
        HStack {
            Spacer()
            Button(action: {
                showingAbout = true
            }, label: {
                Text("About")
            }).alert(isPresented: $showingAbout, content: {
                Alert(title: Text("About"), message: Text("""
    Author : Wonjun Hwang
    E-mail : iamjam4944@gmail.com
    Source : https://github.com/Maetel/VideoConcat
    """))
            })
        }
        
    }.onDrop(
        of: ["public.url"],
        delegate: BookmarksDropDelegate(bookmarks: $droppedFiles)
    )
    .frame(width: 1200, height: 600)
  }
    struct BookmarksDropDelegate: DropDelegate {
        @Binding var bookmarks: [URL]

        func performDrop(info: DropInfo) -> Bool {
            print("Drop delegate")
            print(info)
            guard info.hasItemsConforming(to: ["public.url"]) else {
                return false
            }
            print("Dropped urls")
            //print(droppedFiles)
            let items = info.itemProviders(for: ["public.url"])
            for item in items {
//                _ = item.loadObject(ofClass: URL.self) { url, _ in
//                    if let url = url {
//                        DispatchQueue.main.async {
//                            self.bookmarks.insert(url, at: 0)
//                        }
//                    }
//                }
            }

            return true
        }
    }
    
    func merge(outPath : URL, arrayVideos:[AVAsset], completion:@escaping (URL?, Error?) -> ()) {

      let mainComposition = AVMutableComposition()
      let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
      //compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

      let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertTime = CMTime.zero

      for videoAsset in arrayVideos {
        try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
        try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
      }

      //let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "merge.mp4")
        let outputFileURL = (outPath.pathExtension.lowercased() == "mp4") ? outPath : outPath.appendingPathExtension(".mp4")
        
        
      let fileManager = FileManager()
      try? fileManager.removeItem(at: outputFileURL)

      let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

        print("path : " + outputFileURL.path)
        exporter?.outputURL = URL(fileURLWithPath:outputFileURL.path)
        //exporter?.outputURL = outPath
      exporter?.outputFileType = AVFileType.mp4
      exporter?.shouldOptimizeForNetworkUse = true

      exporter?.exportAsynchronously {
        print("Done")
        if let outurl = exporter?.outputURL{
            completion(outurl, nil)
        }
        if let error = exporter?.error {
            print(error.localizedDescription)
            //completion(nil, error)
        }
      }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
