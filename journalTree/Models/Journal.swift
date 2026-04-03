import Foundation
import SwiftUI

// MARK: - Mood
enum Mood: String, Codable, CaseIterable {
    case happy        = "happy"
    case sad          = "sad"
    case angry        = "angry"
    case disappointed = "disappointed"
    case fear         = "fear"

    var label: String {
        switch self {
        case .happy:        return "Happy"
        case .sad:          return "Sad"
        case .angry:        return "Angry"
        case .disappointed: return "Disappointed"
        case .fear:         return "Fear"
        }
    }

    var leafColor: NSColor {
        switch self {
        case .happy:        return NSColor(red: 1.00, green: 0.76, blue: 0.12, alpha: 1) // golden
        case .sad:          return NSColor(red: 0.56, green: 0.66, blue: 0.88, alpha: 1) // steel blue
        case .angry:        return NSColor(red: 0.90, green: 0.23, blue: 0.20, alpha: 1) // red
        case .disappointed: return NSColor(red: 0.60, green: 0.45, blue: 0.75, alpha: 1) // purple
        case .fear:         return NSColor(red: 0.35, green: 0.65, blue: 0.45, alpha: 1) // dark green
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .happy:        return Color(red: 1.00, green: 0.76, blue: 0.12)
        case .sad:          return Color(red: 0.56, green: 0.66, blue: 0.88)
        case .angry:        return Color(red: 0.90, green: 0.23, blue: 0.20)
        case .disappointed: return Color(red: 0.60, green: 0.45, blue: 0.75)
        case .fear:         return Color(red: 0.35, green: 0.65, blue: 0.45)
        }
    }

    var badgeBG: Color {
        switch self {
        case .happy:        return Color(red: 1.00, green: 0.97, blue: 0.82)
        case .sad:          return Color(red: 0.88, green: 0.91, blue: 0.98)
        case .angry:        return Color(red: 1.00, green: 0.87, blue: 0.87)
        case .disappointed: return Color(red: 0.93, green: 0.88, blue: 0.98)
        case .fear:         return Color(red: 0.84, green: 0.95, blue: 0.88)
        }
    }

    var badgeFG: Color {
        switch self {
        case .happy:        return Color(red: 0.65, green: 0.44, blue: 0.00)
        case .sad:          return Color(red: 0.25, green: 0.35, blue: 0.72)
        case .angry:        return Color(red: 0.72, green: 0.10, blue: 0.10)
        case .disappointed: return Color(red: 0.40, green: 0.22, blue: 0.62)
        case .fear:         return Color(red: 0.15, green: 0.48, blue: 0.28)
        }
    }
}

// MARK: - Journal
struct Journal: Identifiable, Codable, Equatable {
    let id:      UUID
    var title:   String
    var content: String
    var mood:    Mood
    var date:    Date

    init(id: UUID = UUID(),
         title: String, content: String,
         mood: Mood, date: Date = Date()) {
        self.id      = id
        self.title   = title
        self.content = content
        self.mood    = mood
        self.date    = date
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMMM yyyy HH:mm"
        return f.string(from: date)
    }
}
