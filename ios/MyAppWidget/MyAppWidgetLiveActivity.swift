import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    public struct ContentState: Codable, Hashable {
        var appGroupId: String
    }
    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

let sharedDefault = UserDefaults(suiteName: "group.example.liveActivitiesSample")!

struct MyAppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let name = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Pizza"
            let ingredient = sharedDefault.string(forKey: context.attributes.prefixedKey("ingredient")) ?? ""
            let quantity = sharedDefault.integer(forKey: context.attributes.prefixedKey("quantity"))
            let status = sharedDefault.string(forKey: context.attributes.prefixedKey("status")) ?? "preparing"
            return HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                    if !ingredient.isEmpty {
                        Text(ingredient)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Image(systemName: statusIcon(for: status))
                            .foregroundColor(statusColor(for: status))
                        Text(statusText(for: status))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("x\(quantity)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Image(systemName: "shippingbox.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .activityBackgroundTint(Color.cyan.opacity(0.2))
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            let name = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Pizza"
            let quantity = sharedDefault.integer(forKey: context.attributes.prefixedKey("quantity"))
            let status = sharedDefault.string(forKey: context.attributes.prefixedKey("status")) ?? "preparing"
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                        Text("x\(quantity)")
                            .font(.caption)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: statusIcon(for: status))
                        .font(.title2)
                        .foregroundColor(statusColor(for: status))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: statusIcon(for: status))
                        Text(statusText(for: status))
                            .font(.caption)
                        Spacer()
                        Text("Qty: \(quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "shippingbox.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text("x\(quantity)")
                    .font(.caption2)
                    .fontWeight(.bold)
            } minimal: {
                Image(systemName: statusIcon(for: status))
                    .font(.caption)
                    .foregroundColor(statusColor(for: status))
            }
            .keylineTint(Color.orange)
        }
    }

    private func statusIcon(for status: String) -> String {
        switch status {
        case "preparing": return "flame.fill"
        case "baking": return "flame.fill"
        case "delivering": return "bicycle"
        case "delivered": return "checkmark.circle.fill"
        default: return "flame.fill"
        }
    }

    private func statusText(for status: String) -> String {
        switch status {
        case "preparing": return "Preparing"
        case "baking": return "Baking"
        case "delivering": return "On the way"
        case "delivered": return "Delivered"
        default: return "Preparing"
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "preparing": return .orange
        case "baking": return .red
        case "delivering": return .blue
        case "delivered": return .green
        default: return .orange
        }
    }
}
