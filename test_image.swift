import AppKit

let path = NSHomeDirectory() + "/Library/Group Containers/group.com.nanda.journalTree/tree_widget_snapshot.png"
let fileURL = URL(fileURLWithPath: path)
do {
    let data = try Data(contentsOf: fileURL)
    if let nsImg = NSImage(data: data) {
        print("Success. Image size: \(nsImg.size)")
        if let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            print("CGImage created successfully: \(cgImg.width)x\(cgImg.height)")
        } else {
            print("Failed to create CGImage")
        }
    } else {
        print("Failed to init NSImage from Data")
    }
} catch {
    print("Error: \(error)")
}
