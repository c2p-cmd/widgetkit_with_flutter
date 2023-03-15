//
//  ideaWidget.swift
//  ideaWidget
//
//  Created by Sharan Thakur on 15/03/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: Date(), image: UIImage(named: "Placeholder")!, title: "Placeholder")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MyEntry) -> ()) {
        let entry = MyEntry(date: Date(), image: UIImage(named: "Placeholder")!, title: "Placeholder")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        IdeaProvider.getIdeaOfTheDayImage { response, title in
            var entries: [MyEntry] = []
            let policy: TimelineReloadPolicy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
            var entry: MyEntry
            
            switch response {
            case .Failure:
                entry = MyEntry(date: Date(), image: UIImage(named: "Error")!, title: title)
                break
            case .Success(let image):
                entry = MyEntry(date: Date(), image: image, title: title)
                break
            }
            
            entries.append(entry)
            completion(Timeline(entries: entries, policy: policy))
        }
    }
}

struct ideaWidgetEntryView : View {
    var entry: Provider.Entry
    
    func getFormattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader { geoReader in
            ZStack(alignment: .bottom) {
                Image(uiImage: entry.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geoReader.size.width, height: geoReader.size.height)
                HStack {
                    Text(getFormattedDate(entry.date))
                        .font(.caption)
                        .foregroundColor(Color.yellow)
                        .padding(2)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(5)
                        .padding(.bottom, 3)
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.leading)
                    Text(entry.title)
                        .font(.caption)
                        .foregroundColor(Color.yellow)
                        .padding(2)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(5)
                        .padding(.bottom, 3)
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct ideaWidget: Widget {
    let kind: String = "ideaWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ideaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ideaWidget_Previews: PreviewProvider {
    static var previews: some View {
        ideaWidgetEntryView(entry: MyEntry(date: Date(), image: UIImage(named: "Placeholder")!, title: "Placeholder"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
