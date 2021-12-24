import Foundation
import AVKit

class VideoModel: ObservableObject {
    @Published var player: AVPlayer?
    func startPlayer(url: URL) {
        self.player = AVPlayer(url: url)
    }
}
