//
//  ContentView.swift
//  VideoConcat
//
//  Created by Wonjun on 2021/07/17.
//

import SwiftUI
import AVFoundation

//func merge(arrayVideos:[AVAsset], completion:@escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {
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
    print(outputFileURL)
    
  let fileManager = FileManager()
  try? fileManager.removeItem(at: outputFileURL)

  let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

  exporter?.outputURL = outputFileURL
  exporter?.outputFileType = AVFileType.mp4
  exporter?.shouldOptimizeForNetworkUse = true

  exporter?.exportAsynchronously {
    if let url = exporter?.outputURL{
        completion(url, nil)
    }
    if let error = exporter?.error {
        completion(nil, error)
    }
  }
}

struct ContentView: View {
  @State var filename = "파일 :"
  @State var showFileChooser = false
    @State var filenames: [VideoFile] = []
    @State var isMerging = ""
    
    func handleCompletion(at url:URL){
        isMerging = "완료 : " + url.path
    }
    
  var body: some View {
    VStack {
        
        HStack {
          Text(filename)
          Button("선택")
          {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = false
            panel.allowedFileTypes = ["mp4"]
            if panel.runModal() == .OK {
                print(panel.urls)
                panel.urls.filter{
                    return $0.pathExtension.lowercased() == "mp4"
                }.forEach{url in filenames.append(VideoFile(path: url.path, addedId: 0))}
                filenames.sort{return $0.path < $1.path}
            }
          }
        }
        Divider()
        HStack {
             List {
                Text("파일 목록 : ")
                ForEach(filenames, id: \.self) {videofile in
                    FileView(video: videofile)
                }}
            VStack{
                Image(systemName: "arrowshape.zigzag.right").listItemTint(.red)
                Button (action: {
                    //filenames.filter( { (videofile: VideoFile) -> Bool in return videofile.checked })
                    ForEach(filenames, id: \.self) {videofile in
                        FileView(video: videofile)}
                        }
                , label: {
                    Text("더하기")
                })
            }
            List {
                
            }
            
        }
        HStack {
            Button(action: {
                //AVAssetExportSession(
                var assets : [AVAsset] = [];
//                for file in filenames{
//                    assets.append(AVAsset(url:URL(fileURLWithPath:file.path)))
//                }
                filenames.forEach{
                    assets.append(AVAsset(url:URL(fileURLWithPath:$0.path)))
                }
                let panel = NSSavePanel()
                panel.allowedFileTypes = ["mp4"]
                if panel.runModal() == .OK {
                    let outURL = panel.url ?? URL(fileURLWithPath: "merge.mp4")
                    isMerging="합치는 중..."
                    merge(outPath:outURL,arrayVideos: assets, completion: {(_,_) in handleCompletion(at:outURL)})
                    
                }
                
                
            }, label: {
                Text("합치기")
            })
            Text(isMerging)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
