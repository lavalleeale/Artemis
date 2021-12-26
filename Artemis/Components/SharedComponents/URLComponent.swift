import SwiftUI

struct URLComponent: View {
    @Binding var image: UIImage?
    @State var url: String
    var body: some View {
        Button {
            guard let url = URL(string: url),
                  UIApplication.shared.canOpenURL(url) else {
                      return
                  }
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
        } label: {
            HStack {
                if (image != nil) {
                    Image(uiImage: image!)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                }
                Text(url)
                    .foregroundColor(Color.primary)
                    .lineLimit(1)
                Spacer()
            }
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(10)
        }
    }
}
