import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetLeafInfo: Codable {
    let image: String
    let xOffset: Double
    let yOffset: Double
    let rotation: Double
}

struct TreeWidgetEntryView : View {
    var entry: Provider.Entry

    var leaves: [WidgetLeafInfo] {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.nanda.journalTree"),
           let data = sharedDefaults.data(forKey: "widget_leaves_json"),
           let decoded = try? JSONDecoder().decode([WidgetLeafInfo].self, from: data) {
            return decoded
        }
        return []
    }

    var body: some View {
        GeometryReader { proxy in
            let sceneW = proxy.size.width
            let sceneH = proxy.size.height
            
            ZStack {
                // Ground
                let groundH = sceneH * 0.28
                Image("ground")
                    .resizable()
                    .frame(width: sceneW, height: groundH)
                    .position(x: sceneW / 2, y: sceneH - (groundH / 2))
                
                // Tree
                let treeW = sceneW * 0.92
                let treeH = treeW / (1456.0 / 1150.0)
                let treeY = sceneH * 0.68 // 32% from bottom
                
                Image("pohonTekstur")
                    .resizable()
                    .frame(width: treeW, height: treeH)
                    .position(x: sceneW / 2, y: treeY)
                
                if !leaves.isEmpty {
                    // Leaves
                    let leafW = sceneW * 0.024
                    let leafH = leafW * (28.0 / 24.0)
                    
                    ForEach(0..<leaves.count, id: \.self) { i in
                        let leaf = leaves[i]
                        let lX = (sceneW / 2) + (leaf.xOffset * treeW)
                        let lY = treeY - (leaf.yOffset * treeH)
                        
                        Image(leaf.image)
                            .resizable()
                            .frame(width: leafW, height: leafH)
                            .rotationEffect(.degrees(-leaf.rotation))
                            .position(x: lX, y: lY)
                    }
                }
            }
        }
    }
}

struct TreeWidget: Widget {
    let kind: String = "TreeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TreeWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 1.0, green: 0.99, blue: 0.96), for: .widget)
        }
        .configurationDisplayName("Tree of Memories")
        .description("Lihat pohon kenanganmu yang tumbuh setiap hari.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    TreeWidget()
} timeline: {
    SimpleEntry(date: .now)
}
