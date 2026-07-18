import SwiftUI

struct HomeView: View {
    let store: SyncTableStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("zomato")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(Brand.red)
                        Text("Good evening, Aniket")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    AvatarView(participant: store.table.host)
                }

                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Eat together,\nwherever you are")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Link two local orders into one shared dinner.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.82))
                        }
                        Spacer()
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Brand.peach)
                    }
                    Button {
                        store.go(.invite)
                    } label: {
                        Label("Create Sync Table", systemImage: "person.2.badge.plus")
                            .font(.headline)
                            .foregroundStyle(Brand.redDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white, in: RoundedRectangle(cornerRadius: 15))
                    }
                    .accessibilityHint("Starts a new shared meal")
                }
                .padding(22)
                .background(Brand.red, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Brand.red.opacity(0.25), radius: 20, y: 10)

                Text("Made for tonight")
                    .font(.title2.bold())
                HStack(spacing: 14) {
                    discoveryCard(symbol: "takeoutbag.and.cup.and.straw.fill", title: "North Indian", subtitle: "Warm, smoky, shared")
                    discoveryCard(symbol: "birthday.cake.fill", title: "Dessert run", subtitle: "A sweet little plan")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Your last table", systemImage: "clock.arrow.circlepath")
                        .font(.headline)
                    Text("Mumbai ↔ Bengaluru")
                        .font(.title3.bold())
                    Text("Paneer night • 2 weeks ago")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .softCard()

                Text("Two locations. Two carts. One shared meal.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .navigationBarHidden(true)
    }

    private func discoveryCard(symbol: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol).font(.title).foregroundStyle(Brand.red)
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }
}

struct InviteView: View {
    let store: SyncTableStore
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SectionHeader(eyebrow: "Sync Table • \(store.table.id)", title: store.partnerJoined ? "Aisha is at the table" : "Bring someone to the table", subtitle: store.partnerJoined ? "Connected across Mumbai and Bengaluru." : "Send this private invite. Their order and payment stay separate.")

                VStack(spacing: 18) {
                    HStack {
                        participantColumn(store.table.host, connected: true)
                        ZStack {
                            Capsule().fill(Brand.red.opacity(0.15)).frame(height: 3)
                            Image(systemName: "link")
                                .foregroundStyle(Brand.red)
                                .padding(8)
                                .background(.thinMaterial, in: Circle())
                                .scaleEffect(pulse ? 1.08 : 0.95)
                        }
                        participantColumn(store.table.partner, connected: store.partnerJoined)
                            .opacity(store.partnerJoined ? 1 : 0.35)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                    VStack(spacing: 7) {
                        Text("ST  •  7N4K")
                            .font(.system(.title2, design: .monospaced, weight: .bold))
                        Text("Invite code expires in 14:32")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ShareLink(item: "Join my Zomato Sync Table: zomato.example/sync/7N4K") {
                        Label("Share Invite", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .softCard()

                if !store.partnerJoined {
                    Button("Demo: Join as Partner") {
                        store.joinPartner()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Label("Securely connected", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Brand.green)
                    Button {
                        store.go(.matching)
                    } label: {
                        Label("Find our restaurants", systemImage: "fork.knife")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(20)
        }
        .task {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private func participantColumn(_ participant: Participant, connected: Bool) -> some View {
        VStack(spacing: 8) {
            AvatarView(participant: participant, size: 58)
            Text(participant.name).font(.headline)
            Text(participant.city).font(.caption).foregroundStyle(.secondary)
            if connected {
                Text("Connected").font(.caption2.weight(.bold)).foregroundStyle(Brand.green)
            }
        }
        .frame(width: 94)
    }
}

struct MatchingView: View {
    let store: SyncTableStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SectionHeader(eyebrow: "Menu Twin", title: store.isMatching ? "Finding your shared flavour" : "Great matches for both of you", subtitle: "We compare only restaurants available near each address.")

                if store.isMatching || store.matches.isEmpty {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle().stroke(Brand.red.opacity(0.12), lineWidth: 18).frame(width: 150, height: 150)
                            ProgressView().controlSize(.large).tint(Brand.red)
                            Image(systemName: "fork.knife").font(.title).offset(y: 40)
                        }
                        Text("Checking availability • menus • timing")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 60)
                } else {
                    ForEach(store.matches) { pair in
                        MatchCard(pair: pair, selected: store.table.selectedPair?.id == pair.id) {
                            store.select(pair)
                        }
                    }
                    Button {
                        store.go(.menu)
                    } label: {
                        Text("Browse shared menu")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(20)
        }
        .task {
            if store.matches.isEmpty { await store.findMatches() }
        }
    }
}

struct MatchCard: View {
    let pair: RestaurantPair
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(pair.isSameRestaurant ? "Same restaurant" : "Similar menus", systemImage: pair.isSameRestaurant ? "equal.circle.fill" : "arrow.left.arrow.right.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(pair.isSameRestaurant ? Brand.green : Brand.red)
                    Spacer()
                    Text("\(pair.score.total)")
                        .font(.title.bold())
                    Text("Sync\nScore")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    restaurantName(pair.hostRestaurant, person: "You")
                    Image(systemName: "heart.fill").foregroundStyle(Brand.red)
                    restaurantName(pair.partnerRestaurant, person: "Aisha")
                }
                Text(pair.theme)
                    .font(.headline)
                HStack {
                    Label("\(pair.score.menuSimilarity)% menu match", systemImage: "checkmark.circle")
                    Spacer()
                    Text("Δ \(pair.score.predictedDifference) min")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .softCard()
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(selected ? Brand.red : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(pair.theme), Sync Score \(pair.score.total)")
    }

    private func restaurantName(_ restaurant: Restaurant, person: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(person).font(.caption2).foregroundStyle(.secondary)
            Text(restaurant.name).font(.subheadline.bold()).lineLimit(1)
            Text(restaurant.city).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
