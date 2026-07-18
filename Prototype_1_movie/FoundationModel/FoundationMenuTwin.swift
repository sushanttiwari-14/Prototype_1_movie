#if canImport(FoundationModels)
import FoundationModels
import Foundation

@available(iOS 26.0, *)
@Generable
struct GeneratedMenuTwin {
    @Guide(description: "A short canonical culinary dish type")
    var canonicalDishType: String
    @Guide(description: "Cuisine name")
    var cuisine: String
    @Guide(description: "Flavor words grounded only in the supplied descriptions")
    var flavorProfile: [String]
    @Guide(description: "Cooking style")
    var cookingStyle: String
}

@available(iOS 26.0, *)
@MainActor
final class AppleFoundationMenuTwinService {
    private let fallback = DeterministicMenuTwinService()

    func profile(for item: MenuItem, counterpart: MenuItem) async -> MenuTwinProfile {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            return await fallback.profile(for: item, counterpart: counterpart)
        }
        let session = LanguageModelSession(model: model, instructions: """
        Classify only the two supplied catalogue items. Never infer availability, price, delivery,
        allergens, inventory, or logistics. Return concise culinary attributes.
        """)
        do {
            let response = try await session.respond(
                to: "Item A: \(item.name) — \(item.description). Item B: \(counterpart.name) — \(counterpart.description).",
                generating: GeneratedMenuTwin.self
            )
            let value = response.content
            return .init(
                canonicalDishType: value.canonicalDishType,
                cuisine: value.cuisine,
                mealCategory: item.category,
                isVegetarian: item.isVegetarian && counterpart.isVegetarian,
                flavorProfile: value.flavorProfile,
                spiceCategory: max(item.spice, counterpart.spice) >= 3 ? "Hot" : "Medium",
                cookingStyle: value.cookingStyle,
                suitableCounterpart: counterpart.name
            )
        } catch {
            return await fallback.profile(for: item, counterpart: counterpart)
        }
    }
}
#endif
