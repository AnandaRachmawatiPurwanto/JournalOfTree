import SwiftUI

// MARK: - JournalPopupView
struct JournalPopupView: View {
    let journal: Journal
    @EnvironmentObject var store: JournalStore

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { store.dismissPopup() }

            // Card
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack(alignment: .top, spacing: 10) {
                    Text(journal.mood == .happy ? "🍂" : "🍃")
                        .font(.system(size: 22))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(journal.title)
                            .font(.system(size: 17, weight: .bold))
                        Text(journal.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Badge mood
                    Text(journal.mood.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(journal.mood.badgeFG)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(journal.mood.badgeBG)
                        .cornerRadius(20)

                    // Tombol tutup
                    Button { store.dismissPopup() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 14)

                Divider()

                // Isi jurnal
                ScrollView {
                    Text(journal.content)
                        .font(.system(size: 13))
                        .lineSpacing(5)
                        .foregroundColor(.primary.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 14)
                }
                .frame(maxHeight: 240)
            }
            .padding(22)
            .frame(width: 430)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.20), radius: 24, x: 0, y: 8)
        }
    }
}
