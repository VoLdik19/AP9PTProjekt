import Foundation
import SwiftData

@Model
final class PrimePart {
    var name: String
    var setName: String
    var category: String
    var quantity: Int
    var needed: Int
    var isOwned: Bool

    init(
        name: String,
        setName: String,
        category: String,
        quantity: Int = 0,
        needed: Int = 1,
        isOwned: Bool = false
    ) {
        self.name = name
        self.setName = setName
        self.category = category
        self.quantity = quantity
        self.needed = needed
        self.isOwned = isOwned
    }
}

@Model
final class MasteredItem {
    var name: String
    var category: String
    var isMastered: Bool
    var rank: Int
    var notes: String

    init(
        name: String,
        category: String,
        isMastered: Bool = false,
        rank: Int = 0,
        notes: String = ""
    ) {
        self.name = name
        self.category = category
        self.isMastered = isMastered
        self.rank = rank
        self.notes = notes
    }

    @Model
    final class HelminthFrame {
        var name: String
        var ability: String
        var isSubsumed: Bool
        var notes: String

        init(name: String, ability: String = "", isSubsumed: Bool = false, notes: String = "") {
            self.name = name
            self.ability = ability
            self.isSubsumed = isSubsumed
            self.notes = notes
        }
    }
}

enum SeedData {
    static func insertIfNeeded(in context: ModelContext) {
        let partDescriptor = FetchDescriptor<PrimePart>()
        let itemDescriptor = FetchDescriptor<MasteredItem>()
        let helminthDescriptor = FetchDescriptor<HelminthFrame>()

        if (try? context.fetchCount(partDescriptor)) == 0 {
            let primeSets = [
                ("Ash", ["Neuroptics", "Chassis", "Systems", "Blueprint"]),
                ("Equinox", ["Neuroptics", "Chassis", "Systems", "Blueprint"]),
                ("Harrow", ["Neuroptics", "Chassis", "Systems", "Blueprint"]),
                ("Nekros", ["Neuroptics", "Chassis", "Systems", "Blueprint"])
            ]

            for (setName, categories) in primeSets {
                for category in categories {
                    context.insert(PrimePart(
                        name: "\(setName) Prime \(category)",
                        setName: "\(setName) Prime",
                        category: category
                    ))
                }
            }
        }

        if (try? context.fetchCount(itemDescriptor)) == 0 {
            let items = [
                ("Excalibur", "Warframes"),
                ("Mag", "Warframes"),
                ("Volt", "Warframes"),
                ("Rhino", "Warframes"),
                ("Braton", "Primary"),
                ("Boltor", "Primary"),
                ("Burston", "Primary"),
                ("Skana", "Melee"),
                ("Bo", "Melee"),
                ("Lato", "Secondary")
            ]

            for (name, category) in items {
                context.insert(MasteredItem(name: name, category: category))
            }
        }

        if (try? context.fetchCount(helminthDescriptor)) == 0 {
            let frames: [(String, String)] = [
                ("Ash", "Fatal Teleport"), ("Atlas", "Landslide"),
                ("Banshee", "Silence"), ("Baruuk", "Elude"),
                ("Caliban", "Sentient Wrath"), ("Chroma", "Spectral Scream"),
                ("Citrine", "Prismatic Gem"), ("Dagath", "Carnage"),
                ("Dante", "Light Verse"), ("Ember", "Fire Blast"),
                ("Equinox", "Pacify and Provoke"), ("Excalibur", "Radial Blind"),
                ("Frost", "Freeze"), ("Gauss", "Thermal Sunder"),
                ("Garuda", "Seeking Talons"), ("Grendel", "Pulsating Lure"),
                ("Gyre", "Arcsphere"),
                ("Harrow", "Condemn"), ("Hildryn", "Aegis Storm"),
                ("Hydroid", "Pilfering Swarm"), ("Inaros", "Elemental Sandstorm"),
                ("Ivara", "Prowl"), ("Jade", "Glory on High"),
                ("Khora", "Ensnare"), ("Koumei", "Kumihimo"),
                ("Kullervo", "Collective Curse"), ("Lavos", "Catalyze"),
                ("Limbo", "Banish"),                 ("Loki", "Invisibility"), ("Mag", "Pull"),
                ("Mesa", "Shatter Shield"), ("Mirage", "Eclipse"),
                ("Nekros", "Terrify"), ("Nidus", "Larva"),
                ("Nova", "Molecular Prime"), ("Nyx", "Mind Control"),
                ("Oberon", "Hallowed Ground"), ("Octavia", "Metronome"),
                ("Protea", "Dispensary"), ("Qorvex", "Contagion Cloud"),
                ("Revenant", "Mesmer Skin"), ("Rhino", "Roar"),
                ("Saryn", "Spores"), ("Sevagoth", "Gloom"),
                ("Styanax", "Pull"), ("Titania", "Spellbind"),
                ("Trinity", "Well of Life"), ("Valkyr", "Warcry"),
                ("Vauban", "Bastille"), ("Volt", "Shock"),
                ("Voruna", "Shroud of Dynar"), ("Wisp", "Reservoirs"),
                ("Wukong", "Defy"), ("Xaku", "Gaze"),
                ("Yareli", "Sea Snares"), ("Zephyr", "Tail Wind")
            ]
            for (name, ability) in frames {
                context.insert(HelminthFrame(name: name, ability: ability))
            }
        }

        try? context.save()
    }
}
