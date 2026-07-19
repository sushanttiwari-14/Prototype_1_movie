import SwiftUI

/// The delivery home keeps familiar browse controls up front, then offers Sync Table
/// at the moment a customer is deciding what to order.
struct SyncTableEntryView: View {
    let store: SyncTableStore

    @State private var query = ""
    @State private var selectedCategory = "All"
    @State private var vegetarianOnly = false
    @State private var showFilters = false

    private let categories = [
        HomeCategory(title: "All", symbol: "fork.knife"),
        HomeCategory(title: "North Indian", symbol: "takeoutbag.and.cup.and.straw"),
        HomeCategory(title: "Snacks", symbol: "birthday.cake"),
        HomeCategory(title: "Desserts", symbol: "cup.and.saucer")
    ]

    private var restaurants: [Restaurant] {
        DemoData.catalogue.filter { restaurant in
            let matchesSearch = query.isEmpty || restaurant.name.localizedCaseInsensitiveContains(query)
                || restaurant.cuisine.localizedCaseInsensitiveContains(query)
            let matchesCategory = selectedCategory == "All" || restaurant.cuisine == selectedCategory
                || (selectedCategory == "Snacks" && restaurant.cuisine == "Asian")
                || (selectedCategory == "Desserts" && restaurant.menu.contains { $0.category == "Desserts" })
            let matchesVeg = !vegetarianOnly || restaurant.menu.allSatisfy(\.isVegetarian)
            return matchesSearch && matchesCategory && matchesVeg
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                locationHeader
                    .padding(.horizontal, HomePalette.pageInset)
                    .padding(.top, 12)

                searchRow
                    .padding(.horizontal, HomePalette.pageInset)
                    .padding(.top, 20)

                categoryStrip
                    .padding(.top, 20)

                filterStrip
                    .padding(.horizontal, HomePalette.pageInset)
                    .padding(.top, 18)

                syncTableCard
                    .padding(.horizontal, HomePalette.pageInset)
                    .padding(.top, 24)

                recommendationSection
                    .padding(.top, 28)
            }
            .padding(.bottom, 98)
        }
        .scrollIndicators(.hidden)
        .background(HomePalette.canvas)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomNavigation }
        .tint(HomePalette.red)
    }

    private var locationHeader: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "location.fill")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(HomePalette.red)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(store.localParticipant.address.label)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                }
                Text(store.localParticipant.address.line)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HomePalette.secondaryText)
            }
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 39))
                .foregroundStyle(HomePalette.red.opacity(0.9))
                .accessibilityLabel("Profile, \(store.localParticipant.name)")
        }
    }

    private var searchRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(HomePalette.secondaryText)
                TextField("Search \"biryani\"", text: $query)
                    .font(.system(size: 17, weight: .medium))
                    .submitLabel(.search)
                Image(systemName: "mic.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(HomePalette.secondaryText)
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(HomePalette.searchFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(spacing: 4) {
                Text("VEG")
                    .font(.system(size: 10, weight: .heavy))
                Toggle("Vegetarian only", isOn: $vegetarianOnly)
                    .labelsHidden()
                    .tint(HomePalette.green)
                    .scaleEffect(0.78)
                    .frame(width: 40)
            }
            .foregroundStyle(HomePalette.ink)
            .accessibilityElement(children: .combine)
        }
    }

    private var categoryStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 18) {
                ForEach(categories) { category in
                    Button {
                        withAnimation(.smooth(duration: 0.2)) { selectedCategory = category.title }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(category.title == selectedCategory ? HomePalette.red.opacity(0.11) : HomePalette.chipFill)
                                    .frame(width: 62, height: 62)
                                Image(systemName: category.symbol)
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(category.title == selectedCategory ? HomePalette.red : HomePalette.ink)
                            }
                            Text(category.title)
                                .font(.system(size: 13, weight: category.title == selectedCategory ? .bold : .medium))
                                .foregroundStyle(category.title == selectedCategory ? HomePalette.ink : HomePalette.secondaryText)
                                .lineLimit(1)
                        }
                        .frame(width: 82)
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(category.title == selectedCategory ? HomePalette.red : .clear)
                                .frame(width: 42, height: 3)
                                .offset(y: 5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HomePalette.pageInset)
            .padding(.bottom, 7)
        }
        .scrollIndicators(.hidden)
    }

    private var filterStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(HomeChipStyle(active: showFilters))

                Text("New to you")
                    .homeChip()
                Text("No packaging charges")
                    .homeChip()
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private var syncTableCard: some View {
        Button {
            Task { await store.createTable() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.24))
                        .frame(width: 54, height: 54)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORDER TOGETHER")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1.1)
                    Text("Start a Sync Table")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    Text("Different places, one shared meal")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                }
                Spacer(minLength: 4)
                Image(systemName: "arrow.right")
                    .font(.headline.bold())
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.2), in: Circle())
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                LinearGradient(colors: [HomePalette.red, HomePalette.redDark], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: HomePalette.red.opacity(0.22), radius: 13, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(store.isSubmitting)
        .accessibilityHint("Create a table and invite someone to join your order")
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("RECOMMENDED FOR YOU")
                    .font(.system(size: 15, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(HomePalette.secondaryText)
                Spacer()
                if showFilters { Text("Filters on").font(.caption.weight(.semibold)).foregroundStyle(HomePalette.red) }
            }
            .padding(.horizontal, HomePalette.pageInset)

            if restaurants.isEmpty {
                ContentUnavailableView("No restaurants found", systemImage: "magnifyingglass", description: Text("Try another dish or remove a filter."))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 34)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 22) {
                    ForEach(restaurants) { restaurant in
                        RestaurantHomeCard(restaurant: restaurant)
                    }
                }
                .padding(.horizontal, HomePalette.pageInset)
            }
        }
    }

    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            HomeTab(title: "Home", icon: "house.fill", active: true)
            HomeTab(title: "Dining", icon: "fork.knife", active: false)
            HomeTab(title: "Sync Table", icon: "person.2.fill", active: false)
            HomeTab(title: "Profile", icon: "person.fill", active: false)
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider().opacity(0.35) }
    }
}

private struct RestaurantHomeCard: View {
    let restaurant: Restaurant

    private var dishName: String { restaurant.menu.first?.name ?? restaurant.cuisine }
    private var offer: String { restaurant.rating >= 4.6 ? "₹140 OFF above ₹199" : "30% OFF up to ₹75" }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(restaurantGradient)
                    .frame(height: 124)
                Image(systemName: restaurant.cuisine == "Asian" ? "takeoutbag.and.cup.and.straw.fill" : "fork.knife.circle.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text(offer)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.68), in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomTrailingRadius: 9))
            }
            Text("★ \(restaurant.rating.formatted(.number.precision(.fractionLength(1))))")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(HomePalette.green, in: Capsule())
                .offset(y: -18)
                .padding(.bottom, -18)
            Text(restaurant.name)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HomePalette.ink)
                .lineLimit(1)
            Text(dishName)
                .font(.system(size: 12))
                .foregroundStyle(HomePalette.secondaryText)
                .lineLimit(1)
            Label("\(restaurant.preparationMinutes + restaurant.deliveryMinutes - 4)–\(restaurant.preparationMinutes + restaurant.deliveryMinutes + 2) mins", systemImage: "stopwatch")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(HomePalette.secondaryText)
        }
    }

    private var restaurantGradient: LinearGradient {
        let colors: [Color] = restaurant.cuisine == "Asian"
            ? [Color(red: 0.26, green: 0.12, blue: 0.09), Color(red: 0.78, green: 0.31, blue: 0.13)]
            : [Color(red: 0.89, green: 0.56, blue: 0.23), Color(red: 0.54, green: 0.20, blue: 0.10)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct HomeCategory: Identifiable {
    let title: String
    let symbol: String
    var id: String { title }
}

private struct HomeTab: View {
    let title: String
    let icon: String
    let active: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 18, weight: .semibold))
            Text(title).font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(active ? HomePalette.red : HomePalette.secondaryText)
        .frame(maxWidth: .infinity)
    }
}

private struct HomeChipStyle: ButtonStyle {
    let active: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(active ? .white : HomePalette.ink)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(active ? HomePalette.red : HomePalette.chipFill, in: RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

private extension View {
    func homeChip() -> some View {
        font(.system(size: 14, weight: .medium))
            .foregroundStyle(HomePalette.ink)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(HomePalette.chipFill, in: RoundedRectangle(cornerRadius: 12))
    }
}

private enum HomePalette {
    static let red = Color(red: 0.91, green: 0.12, blue: 0.20)
    static let redDark = Color(red: 0.64, green: 0.05, blue: 0.13)
    static let canvas = Color(red: 0.99, green: 0.98, blue: 0.97)
    static let searchFill = Color(red: 0.95, green: 0.94, blue: 0.93)
    static let chipFill = Color(red: 0.93, green: 0.92, blue: 0.90)
    static let ink = Color(red: 0.10, green: 0.09, blue: 0.10)
    static let secondaryText = Color(red: 0.39, green: 0.37, blue: 0.39)
    static let green = Color(red: 0.06, green: 0.50, blue: 0.29)
    static let pageInset: CGFloat = 20
}

struct ConnectionStatusView: View {
    let state: BackendConnectionState

    var body: some View {
        Label(state.title, systemImage: symbol)
            .font(.subheadline.bold())
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
    }

    private var symbol: String {
        switch state {
        case .loading: "arrow.trianglehead.2.clockwise"
        case .local: "iphone"
        case .disconnected: "wifi.slash"
        case .error: "exclamationmark.triangle.fill"
        case .synced: "checkmark.icloud.fill"
        }
    }

    private var color: Color {
        switch state {
        case .loading: .orange
        case .local: Brand.green
        case .disconnected, .error: Brand.red
        case .synced: Brand.green
        }
    }
}
