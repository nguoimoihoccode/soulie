#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import WidgetKit

enum SoulieWidgetConstants {
    static let appGroupId = "group.com.soulie.soulie"
    static let widgetKind = "SoulieHomeWidget"
}

struct SoulieWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let highlight: String
    let friends: String
    let notificationCount: Int
    let imagePath: String?
}

struct SoulieWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SoulieWidgetEntry {
        SoulieWidgetEntry(
            date: Date(),
            title: "Soulie",
            subtitle: "Your private photo pulse",
            highlight: "Share a tiny window into your day.",
            friends: "Luna • Nhi • Cam",
            notificationCount: 3,
            imagePath: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SoulieWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SoulieWidgetEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry()], policy: .never))
    }

    private func loadEntry() -> SoulieWidgetEntry {
        let defaults = UserDefaults(suiteName: SoulieWidgetConstants.appGroupId)
        return SoulieWidgetEntry(
            date: Date(),
            title: defaults?.string(forKey: "title") ?? "Soulie",
            subtitle: defaults?.string(forKey: "subtitle") ?? "Your private photo pulse",
            highlight: defaults?.string(forKey: "highlight") ?? "Share a tiny window into your day.",
            friends: defaults?.string(forKey: "friends") ?? "Open Soulie to reconnect.",
            notificationCount: defaults?.integer(forKey: "notificationCount") ?? 0,
            imagePath: defaults?.string(forKey: "soulie_widget_image")
        )
    }
}

struct SoulieWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    var entry: SoulieWidgetProvider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SoulieSmallWidgetView(entry: entry)
            case .systemMedium:
                SoulieMediumWidgetView(entry: entry)
            default:
                SoulieMediumWidgetView(entry: entry)
            }
        }
        .widgetURL(URL(string: "soulie://messages?homeWidget=1"))
    }
}

struct SoulieSmallWidgetView: View {
    let entry: SoulieWidgetEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SouliePhotoBackground(entry: entry)

            LinearGradient(
                colors: [Color.black.opacity(0.06), Color.black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    SoulieCapsuleLabel(text: "SOULIE")
                    Spacer(minLength: 8)
                    if entry.notificationCount > 0 {
                        SoulieUnreadBadge(count: entry.notificationCount)
                    }
                }

                Spacer(minLength: 0)

                Text(smallTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 3)

                Text(smallFooter)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.84))
                    .lineLimit(1)
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var smallTitle: String {
        if !entry.highlight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return entry.highlight
        }
        return entry.subtitle
    }

    private var smallFooter: String {
        if !entry.friends.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return entry.friends
        }
        return "Tap to open messages"
    }
}

struct SoulieMediumWidgetView: View {
    let entry: SoulieWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                SouliePhotoBackground(entry: entry)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.46)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(entry.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    SoulieCapsuleLabel(text: "LOCKET FEEL")
                    Spacer(minLength: 8)
                    if entry.notificationCount > 0 {
                        SoulieUnreadBadge(count: entry.notificationCount)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Live vibe")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.74, blue: 0.82))
                        .tracking(0.8)

                    Text(entry.highlight)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Close friends")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.46))
                        .tracking(0.7)

                    HStack(spacing: 8) {
                        ForEach(friendTokens.indices, id: \.self) { index in
                            SoulieFriendChip(name: friendTokens[index])
                        }
                    }
                }

                Spacer(minLength: 0)

                Text("Tap to jump into messages")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.74))
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.14, green: 0.11, blue: 0.17), Color(red: 0.09, green: 0.07, blue: 0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var friendTokens: [String] {
        let split = entry.friends
            .split(separator: "•")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if split.isEmpty {
            return ["Soulie", "Friends"]
        }

        return Array(split.prefix(3))
    }
}

struct SouliePhotoBackground: View {
    let entry: SoulieWidgetEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.23, green: 0.16, blue: 0.26), Color(red: 0.08, green: 0.06, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 1.0, green: 0.52, blue: 0.64).opacity(0.34))
                .frame(width: 120, height: 120)
                .offset(x: 54, y: -54)

            Circle()
                .fill(Color(red: 1.0, green: 0.75, blue: 0.81).opacity(0.24))
                .frame(width: 140, height: 140)
                .offset(x: -72, y: 78)

            #if canImport(UIKit)
            if let imagePath = entry.imagePath,
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                SoulieFallbackArtwork()
            }
            #else
            SoulieFallbackArtwork()
            #endif
        }
        .clipped()
    }
}

struct SoulieFallbackArtwork: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.24, green: 0.18, blue: 0.30), Color(red: 0.11, green: 0.09, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 74, height: 74)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    )

                Text("Soulie")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))

                Spacer()
            }
            .padding(.bottom, 10)
        }
    }
}

struct SoulieCapsuleLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .tracking(0.9)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.24))
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

struct SoulieUnreadBadge: View {
    let count: Int

    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color(red: 1.0, green: 0.52, blue: 0.64))
            .clipShape(Capsule())
    }
}

struct SoulieFriendChip: View {
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.52, blue: 0.64), Color(red: 1.0, green: 0.68, blue: 0.76)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 18, height: 18)
                .overlay(
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )

            Text(name)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }
}

struct SoulieWidget: Widget {
    let kind: String = SoulieWidgetConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SoulieWidgetProvider()) { entry in
            SoulieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Soulie")
        .description("Quick pulse from your close friends.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
