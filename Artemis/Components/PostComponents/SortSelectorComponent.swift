import SwiftUI

struct SortSelectorComponent: View {
    var function: (_: Sort, _: Time) -> Void
    @Binding var currentSort: Sort
    @Binding var currentTime: Time
    @State var type: ThingType
    
    var body: some View {
        Menu {
            ForEach(Sort.allCases.filter({sortType in (type == .posts) ? sortType.posts : sortType.comments}), id: \.rawValue) {sort in
                Button {
                    function(sort, currentTime)
                } label: {
                    if (sort.hasTime && type == .posts) {
                        Menu {
                            ForEach(Time.allCases, id: \.rawValue) {time in
                                Button {
                                    function(sort, time)
                                } label: {
                                    Text(time.rawValue.capitalized)
                                }
                            }
                        } label: {
                            Image(systemName: sort.image)
                            Text(sort.rawValue.capitalized)
                        }
                    } else {
                        Image(systemName: sort.image)
                        Text(sort.rawValue.capitalized)
                    }
                }
            }
        } label: {
            Image(systemName: currentSort.image)
        }
    }
}

enum ThingType: String {
    case comments, posts, user
}
