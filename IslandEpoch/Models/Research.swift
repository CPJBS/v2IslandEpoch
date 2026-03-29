//
//  Research.swift
//  IslandEpoch
//

import Foundation

// MARK: - Research Effects

enum ResearchEffect: Codable, Equatable {
    case advanceEpoch
    case unlockBuildingTier(epoch: Int)
    case productionBonus(buildingId: String, multiplier: Double)
    case allProductionBonus(multiplier: Double)
    case unlockIsland(islandName: String)
    case workerCapacityBonus(perHousing: Int)
    case storageBonusPercent(percent: Int)
    case goldIncomeBonus(perTick: Int)
    case goldIncomeMultiplier(multiplier: Double)
    case constructionSpeedBonus(percent: Int)
    case researchSpeedBonus(percent: Int)
    case insightProductionBonus(multiplier: Double)
    case foodProductionBonus(multiplier: Double)
    case buildingSlotsBonus(perIsland: Int)
    case housingCapacityBonus(percent: Int)
}

/// Research blueprint (static definition)
struct ResearchType: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let cost: Inventory
    let requiredEpoch: Int
    let prerequisiteIds: [String]
    let researchTime: TimeInterval // Seconds to research
    let effects: [ResearchEffect]

    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case id, name, description, cost, requiredEpoch, prerequisiteIds, prerequisiteId, researchTime, effects
    }

    init(id: String, name: String, description: String, cost: Inventory, requiredEpoch: Int = 1, prerequisiteIds: [String] = [], researchTime: TimeInterval = 60, effects: [ResearchEffect] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.cost = cost
        self.requiredEpoch = requiredEpoch
        self.prerequisiteIds = prerequisiteIds
        self.researchTime = researchTime
        self.effects = effects
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        cost = try container.decode(Inventory.self, forKey: .cost)
        requiredEpoch = try container.decodeIfPresent(Int.self, forKey: .requiredEpoch) ?? 1
        researchTime = (try? container.decodeIfPresent(TimeInterval.self, forKey: .researchTime)) ?? 60
        effects = (try? container.decodeIfPresent([ResearchEffect].self, forKey: .effects)) ?? []

        // Backward compatibility: try new prerequisiteIds first, fall back to old prerequisiteId
        if let ids = try? container.decodeIfPresent([String].self, forKey: .prerequisiteIds) {
            prerequisiteIds = ids
        } else if let singleId = try? container.decodeIfPresent(String.self, forKey: .prerequisiteId) {
            prerequisiteIds = [singleId]
        } else {
            prerequisiteIds = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(cost, forKey: .cost)
        try container.encode(requiredEpoch, forKey: .requiredEpoch)
        try container.encode(prerequisiteIds, forKey: .prerequisiteIds)
        try container.encode(researchTime, forKey: .researchTime)
        try container.encode(effects, forKey: .effects)
    }

    // MARK: - Static Catalog

    // ── EPOCH 1 — Dawn (6) ──

    static let e1_gathering = ResearchType(
        id: "e1_gathering",
        name: "Systematic Gathering",
        description: "Observe where the fattest berries grow. Return to those spots.",
        cost: [.berries: 20],
        requiredEpoch: 1,
        prerequisiteIds: [],
        researchTime: 15,
        effects: [.productionBonus(buildingId: "forager", multiplier: 1.25)]
    )

    static let e1_shelter = ResearchType(
        id: "e1_shelter",
        name: "Sturdy Shelters",
        description: "Lash the poles tighter. Pack the gaps with mud.",
        cost: [.wood: 25],
        requiredEpoch: 1,
        prerequisiteIds: [],
        researchTime: 20,
        effects: [.unlockBuildingTier(epoch: 1)]
    )

    static let e1_firemaking = ResearchType(
        id: "e1_firemaking",
        name: "Firemaking",
        description: "Sparks caught in dry moss. The dark no longer owns the night.",
        cost: [.berries: 15, .wood: 20],
        requiredEpoch: 1,
        prerequisiteIds: [],
        researchTime: 30,
        effects: [.goldIncomeBonus(perTick: 1)]
    )

    static let e1_toolcraft = ResearchType(
        id: "e1_toolcraft",
        name: "Basic Toolcraft",
        description: "Flint edges lashed to sticks. Hands alone are no longer enough.",
        cost: [.wood: 30, .berries: 20],
        requiredEpoch: 1,
        prerequisiteIds: ["e1_gathering"],
        researchTime: 45,
        effects: [.productionBonus(buildingId: "forester", multiplier: 1.25)]
    )

    static let e1_herblore = ResearchType(
        id: "e1_herblore",
        name: "Herblore",
        description: "The healer knows which leaf soothes and which leaf kills.",
        cost: [.berries: 30],
        requiredEpoch: 1,
        prerequisiteIds: ["e1_gathering"],
        researchTime: 60,
        effects: [.productionBonus(buildingId: "herbalist", multiplier: 1.25)]
    )

    static let e1_agriculture = ResearchType(
        id: "e1_agriculture",
        name: "Agriculture",
        description: "Seeds pressed into turned earth. Patience rewarded with grain.",
        cost: [.berries: 50, .wood: 30],
        requiredEpoch: 1,
        prerequisiteIds: ["e1_toolcraft", "e1_firemaking"],
        researchTime: 90,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 2 — Settlement (7) ──

    static let e2_crop_rotation = ResearchType(
        id: "e2_crop_rotation",
        name: "Crop Rotation",
        description: "Plant beans after wheat. The soil remembers and gives more.",
        cost: [.wheat: 40, .berries: 30],
        requiredEpoch: 2,
        prerequisiteIds: [],
        researchTime: 120,
        effects: [.productionBonus(buildingId: "farm", multiplier: 1.25)]
    )

    static let e2_settlement_walls = ResearchType(
        id: "e2_settlement_walls",
        name: "Settlement Walls",
        description: "A ring of sharpened logs. The wild things stay outside now.",
        cost: [.wood: 60],
        requiredEpoch: 2,
        prerequisiteIds: [],
        researchTime: 90,
        effects: [.unlockBuildingTier(epoch: 2)]
    )

    static let e2_bread_baking = ResearchType(
        id: "e2_bread_baking",
        name: "Bread Baking",
        description: "Dough on hot stone. One loaf feeds more than a bushel of grain.",
        cost: [.wheat: 50, .wood: 20],
        requiredEpoch: 2,
        prerequisiteIds: ["e2_crop_rotation"],
        researchTime: 150,
        effects: [.productionBonus(buildingId: "bakery", multiplier: 1.25)]
    )

    static let e2_metal_hatchets = ResearchType(
        id: "e2_metal_hatchets",
        name: "Metal Hatchets",
        description: "Copper edge bites deeper than stone. The forest falls faster.",
        cost: [.bread: 50, .wood: 45, .insight: 10],
        requiredEpoch: 2,
        prerequisiteIds: [],
        researchTime: 180,
        effects: [.productionBonus(buildingId: "forester", multiplier: 1.25)]
    )

    static let e2_animal_husbandry = ResearchType(
        id: "e2_animal_husbandry",
        name: "Animal Husbandry",
        description: "Tame what you once hunted. A herd is a living storehouse.",
        cost: [.wheat: 60, .herbs: 20],
        requiredEpoch: 2,
        prerequisiteIds: ["e2_crop_rotation"],
        researchTime: 200,
        effects: [.workerCapacityBonus(perHousing: 2)]
    )

    static let e2_pottery = ResearchType(
        id: "e2_pottery",
        name: "Pottery",
        description: "Fired clay holds water, grain, and oil. Storage becomes reliable.",
        cost: [.wood: 40, .berries: 30],
        requiredEpoch: 2,
        prerequisiteIds: [],
        researchTime: 120,
        effects: [.storageBonusPercent(percent: 25)]
    )

    static let e2_construction = ResearchType(
        id: "e2_construction",
        name: "Construction",
        description: "Mortise and tenon joints. The frame holds without lashing.",
        cost: [.wheat: 100, .wood: 80, .insight: 15],
        requiredEpoch: 2,
        prerequisiteIds: ["e2_settlement_walls", "e2_bread_baking"],
        researchTime: 300,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 3 — Crafting (7) ──

    static let e3_masonry = ResearchType(
        id: "e3_masonry",
        name: "Masonry",
        description: "Cut stone stacks true. Walls that will outlast the builders.",
        cost: [.stone: 30, .wood: 40],
        requiredEpoch: 3,
        prerequisiteIds: [],
        researchTime: 300,
        effects: [.constructionSpeedBonus(percent: 20)]
    )

    static let e3_carpentry = ResearchType(
        id: "e3_carpentry",
        name: "Carpentry",
        description: "Planks sawn to measure. No more wasting half the log.",
        cost: [.planks: 20, .wood: 50],
        requiredEpoch: 3,
        prerequisiteIds: [],
        researchTime: 360,
        effects: [.productionBonus(buildingId: "sawmill", multiplier: 1.25)]
    )

    static let e3_fortification = ResearchType(
        id: "e3_fortification",
        name: "Fortification",
        description: "Stone foundations replace wooden palisades. Permanence.",
        cost: [.stone: 50, .planks: 30],
        requiredEpoch: 3,
        prerequisiteIds: ["e3_masonry"],
        researchTime: 420,
        effects: [.unlockBuildingTier(epoch: 3)]
    )

    static let e3_exploration = ResearchType(
        id: "e3_exploration",
        name: "Exploration",
        description: "Charts scratched on hide. The waters beyond hold other lands.",
        cost: [.insight: 50, .planks: 40],
        requiredEpoch: 3,
        prerequisiteIds: [],
        researchTime: 480,
        effects: [.unlockIsland(islandName: "Ironcliff")]
    )

    static let e3_written_records = ResearchType(
        id: "e3_written_records",
        name: "Written Records",
        description: "Marks on clay tablets. Memory no longer dies with the elder.",
        cost: [.insight: 40, .bread: 30],
        requiredEpoch: 3,
        prerequisiteIds: [],
        researchTime: 360,
        effects: [.insightProductionBonus(multiplier: 1.50)]
    )

    static let e3_kiln_craft = ResearchType(
        id: "e3_kiln_craft",
        name: "Kiln Mastery",
        description: "Higher temperatures, stronger materials. The kiln reshapes everything.",
        cost: [.stone: 40, .wood: 60, .insight: 20],
        requiredEpoch: 3,
        prerequisiteIds: ["e3_masonry", "e3_carpentry"],
        researchTime: 540,
        effects: [.productionBonus(buildingId: "quarry", multiplier: 1.25)]
    )

    static let e3_prospecting = ResearchType(
        id: "e3_prospecting",
        name: "Prospecting",
        description: "Streak the stone. Taste the dust. The earth signals where metal hides.",
        cost: [.insight: 80, .stone: 50, .planks: 30],
        requiredEpoch: 3,
        prerequisiteIds: ["e3_fortification", "e3_written_records"],
        researchTime: 720,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 4 — Mining (6) ──

    static let e4_deep_mining = ResearchType(
        id: "e4_deep_mining",
        name: "Deep Mining",
        description: "Timber shores hold the ceiling while picks ring in the dark below.",
        cost: [.wood: 100, .stone: 60, .insight: 30],
        requiredEpoch: 4,
        prerequisiteIds: [],
        researchTime: 900,
        effects: [.productionBonus(buildingId: "mine", multiplier: 1.25)]
    )

    static let e4_irrigation = ResearchType(
        id: "e4_irrigation",
        name: "Irrigation",
        description: "Channels cut into the hillside carry water where rain forgot.",
        cost: [.insight: 30, .stone: 40, .planks: 30],
        requiredEpoch: 4,
        prerequisiteIds: [],
        researchTime: 720,
        effects: [.productionBonus(buildingId: "farm", multiplier: 1.25)]
    )

    static let e4_ore_refinement = ResearchType(
        id: "e4_ore_refinement",
        name: "Ore Refinement",
        description: "Crush, wash, sort. More metal from less stone.",
        cost: [.ironOre: 40, .stone: 30, .insight: 40],
        requiredEpoch: 4,
        prerequisiteIds: ["e4_deep_mining"],
        researchTime: 1080,
        effects: [.unlockBuildingTier(epoch: 4)]
    )

    static let e4_advanced_tools = ResearchType(
        id: "e4_advanced_tools",
        name: "Advanced Tools",
        description: "Iron edges hold sharper, longer. Everything works better now.",
        cost: [.ironOre: 30, .planks: 40, .insight: 50],
        requiredEpoch: 4,
        prerequisiteIds: ["e4_deep_mining"],
        researchTime: 1200,
        effects: [.allProductionBonus(multiplier: 1.10)]
    )

    static let e4_navigation = ResearchType(
        id: "e4_navigation",
        name: "Navigation",
        description: "Stars as guideposts. The open water becomes a road.",
        cost: [.insight: 80, .planks: 60],
        requiredEpoch: 4,
        prerequisiteIds: [],
        researchTime: 1500,
        effects: [.unlockIsland(islandName: "Coral Atoll")]
    )

    static let e4_smelting = ResearchType(
        id: "e4_smelting",
        name: "Smelting",
        description: "Bellows roar. Ore runs liquid. The age of raw stone is over.",
        cost: [.insight: 100, .ironOre: 50, .stone: 40],
        requiredEpoch: 4,
        prerequisiteIds: ["e4_ore_refinement", "e4_advanced_tools"],
        researchTime: 1800,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 5 — Metalworking (7) ──

    static let e5_alloys = ResearchType(
        id: "e5_alloys",
        name: "Alloy Forging",
        description: "Mix metals for strength. Bronze was only the beginning.",
        cost: [.ironBars: 30, .insight: 60],
        requiredEpoch: 5,
        prerequisiteIds: [],
        researchTime: 2400,
        effects: [.productionBonus(buildingId: "smelter", multiplier: 1.25)]
    )

    static let e5_advanced_masonry = ResearchType(
        id: "e5_advanced_masonry",
        name: "Advanced Masonry",
        description: "Arched doorways and load-bearing walls. Architecture begins.",
        cost: [.stone: 80, .ironBars: 20, .insight: 40],
        requiredEpoch: 5,
        prerequisiteIds: [],
        researchTime: 2700,
        effects: [.buildingSlotsBonus(perIsland: 2)]
    )

    static let e5_metalworking_tiers = ResearchType(
        id: "e5_metalworking_tiers",
        name: "Standardized Metalwork",
        description: "Molds and templates. Every blade, every nail, the same quality.",
        cost: [.ironBars: 40, .tools: 20, .insight: 50],
        requiredEpoch: 5,
        prerequisiteIds: ["e5_alloys"],
        researchTime: 3000,
        effects: [.unlockBuildingTier(epoch: 5)]
    )

    static let e5_trade_routes = ResearchType(
        id: "e5_trade_routes",
        name: "Trade Routes",
        description: "Agreed paths, agreed prices. Commerce replaces barter.",
        cost: [.bread: 60, .tools: 15, .insight: 40],
        requiredEpoch: 5,
        prerequisiteIds: [],
        researchTime: 2100,
        effects: [.goldIncomeMultiplier(multiplier: 1.25)]
    )

    static let e5_apothecary = ResearchType(
        id: "e5_apothecary",
        name: "Apothecary Science",
        description: "Distilled tinctures and measured doses. Healing becomes reliable.",
        cost: [.herbs: 50, .insight: 30, .bread: 40],
        requiredEpoch: 5,
        prerequisiteIds: [],
        researchTime: 1800,
        effects: [.productionBonus(buildingId: "herbalist", multiplier: 1.50)]
    )

    static let e5_siege_eng = ResearchType(
        id: "e5_siege_eng",
        name: "Siege Engineering",
        description: "Counterweights and levers. What stone raises, iron can tear down.",
        cost: [.ironBars: 50, .planks: 60, .insight: 60],
        requiredEpoch: 5,
        prerequisiteIds: ["e5_alloys", "e5_advanced_masonry"],
        researchTime: 3600,
        effects: [.constructionSpeedBonus(percent: 25)]
    )

    static let e5_engineering = ResearchType(
        id: "e5_engineering",
        name: "Engineering",
        description: "Gears mesh. Pulleys multiply force. The machine age stirs.",
        cost: [.insight: 120, .ironBars: 50, .tools: 30],
        requiredEpoch: 5,
        prerequisiteIds: ["e5_metalworking_tiers", "e5_trade_routes"],
        researchTime: 4200,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 6 — Trade (6) ──

    static let e6_cartography = ResearchType(
        id: "e6_cartography",
        name: "Cartography",
        description: "Ink lines on vellum. Every reef, every current, now charted.",
        cost: [.insight: 100, .tools: 40, .planks: 50],
        requiredEpoch: 6,
        prerequisiteIds: [],
        researchTime: 5400,
        effects: [.unlockIsland(islandName: "Stormwatch")]
    )

    static let e6_guilds = ResearchType(
        id: "e6_guilds",
        name: "Guild Charters",
        description: "Master craftsmen teach apprentices. Knowledge compounds.",
        cost: [.bread: 80, .tools: 30, .insight: 80],
        requiredEpoch: 6,
        prerequisiteIds: [],
        researchTime: 4800,
        effects: [.allProductionBonus(multiplier: 1.15)]
    )

    static let e6_colonial_mastery = ResearchType(
        id: "e6_colonial_mastery",
        name: "Colonial Mastery",
        description: "Distant islands governed as extensions of the homeland.",
        cost: [.tools: 50, .planks: 60, .insight: 60],
        requiredEpoch: 6,
        prerequisiteIds: ["e6_cartography"],
        researchTime: 6000,
        effects: [.unlockBuildingTier(epoch: 6)]
    )

    static let e6_currency = ResearchType(
        id: "e6_currency",
        name: "Minted Currency",
        description: "Stamped coins replace IOUs. Trade accelerates everywhere.",
        cost: [.ironBars: 40, .tools: 20, .insight: 50],
        requiredEpoch: 6,
        prerequisiteIds: [],
        researchTime: 4200,
        effects: [.goldIncomeMultiplier(multiplier: 1.50)]
    )

    static let e6_supply_lines = ResearchType(
        id: "e6_supply_lines",
        name: "Supply Lines",
        description: "Scheduled shipments, not hopeful launches. Predictable logistics.",
        cost: [.tools: 40, .bread: 60, .insight: 70],
        requiredEpoch: 6,
        prerequisiteIds: ["e6_guilds", "e6_currency"],
        researchTime: 7200,
        effects: [.housingCapacityBonus(percent: 25)]
    )

    static let e6_architecture = ResearchType(
        id: "e6_architecture",
        name: "Architecture",
        description: "Grand designs on parchment become grand structures in stone.",
        cost: [.insight: 150, .stone: 100, .tools: 50, .ironBars: 30],
        requiredEpoch: 6,
        prerequisiteIds: ["e6_colonial_mastery", "e6_supply_lines"],
        researchTime: 9000,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 7 — Fortification (6) ──

    static let e7_coal_extraction = ResearchType(
        id: "e7_coal_extraction",
        name: "Coal Extraction",
        description: "Black seams in the cliff face. This fuel burns hotter than any wood.",
        cost: [.tools: 60, .stone: 80, .insight: 80],
        requiredEpoch: 7,
        prerequisiteIds: [],
        researchTime: 10800,
        effects: [.productionBonus(buildingId: "coalMine", multiplier: 1.25)]
    )

    static let e7_formal_scholarship = ResearchType(
        id: "e7_formal_scholarship",
        name: "Formal Scholarship",
        description: "Lecture halls and disputations. Knowledge becomes a profession.",
        cost: [.insight: 200, .bread: 100, .tools: 40],
        requiredEpoch: 7,
        prerequisiteIds: [],
        researchTime: 12600,
        effects: [.insightProductionBonus(multiplier: 2.0)]
    )

    static let e7_blast_furnace = ResearchType(
        id: "e7_blast_furnace",
        name: "Blast Furnace",
        description: "Forced air and coke fuel. Iron flows like water.",
        cost: [.coal: 40, .ironBars: 50, .stone: 60, .insight: 100],
        requiredEpoch: 7,
        prerequisiteIds: ["e7_coal_extraction"],
        researchTime: 14400,
        effects: [.unlockBuildingTier(epoch: 7)]
    )

    static let e7_expedition = ResearchType(
        id: "e7_expedition",
        name: "Expedition",
        description: "A fleet bearing surveyors sails beyond the known charts.",
        cost: [.insight: 200, .tools: 80, .bread: 60],
        requiredEpoch: 7,
        prerequisiteIds: [],
        researchTime: 16200,
        effects: [.unlockIsland(islandName: "Frostveil")]
    )

    static let e7_civic_works = ResearchType(
        id: "e7_civic_works",
        name: "Civic Works",
        description: "Roads paved, wells dug, waste channeled. A city, not a camp.",
        cost: [.stone: 100, .planks: 80, .tools: 50, .insight: 60],
        requiredEpoch: 7,
        prerequisiteIds: ["e7_formal_scholarship"],
        researchTime: 14400,
        effects: [.buildingSlotsBonus(perIsland: 3)]
    )

    static let e7_industrialization = ResearchType(
        id: "e7_industrialization",
        name: "Industrialization",
        description: "Steam hisses. Wheels turn. One machine replaces twenty hands.",
        cost: [.insight: 250, .tools: 100, .coal: 60, .ironBars: 60],
        requiredEpoch: 7,
        prerequisiteIds: ["e7_blast_furnace", "e7_civic_works"],
        researchTime: 21600,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 8 — Scholarship (7) ──

    static let e8_steam_power = ResearchType(
        id: "e8_steam_power",
        name: "Steam Power",
        description: "Pistons drive shafts. The factory floor trembles with potential.",
        cost: [.coal: 80, .ironBars: 60, .tools: 50, .insight: 120],
        requiredEpoch: 8,
        prerequisiteIds: [],
        researchTime: 25200,
        effects: [.allProductionBonus(multiplier: 1.20)]
    )

    static let e8_precision_tools = ResearchType(
        id: "e8_precision_tools",
        name: "Precision Tooling",
        description: "Micrometers and lathes. Tolerance measured in thousandths.",
        cost: [.tools: 80, .ironBars: 40, .insight: 100],
        requiredEpoch: 8,
        prerequisiteIds: [],
        researchTime: 21600,
        effects: [.productionBonus(buildingId: "toolsmith", multiplier: 1.50)]
    )

    static let e8_mass_production = ResearchType(
        id: "e8_mass_production",
        name: "Mass Production",
        description: "Interchangeable parts on an assembly line. Scale without skill.",
        cost: [.tools: 100, .ironBars: 80, .coal: 40, .insight: 150],
        requiredEpoch: 8,
        prerequisiteIds: ["e8_steam_power", "e8_precision_tools"],
        researchTime: 28800,
        effects: [.unlockBuildingTier(epoch: 8)]
    )

    static let e8_printing_press = ResearchType(
        id: "e8_printing_press",
        name: "Printing Press",
        description: "A thousand copies where once there was one. Ideas spread like wildfire.",
        cost: [.planks: 60, .ironBars: 30, .insight: 200],
        requiredEpoch: 8,
        prerequisiteIds: [],
        researchTime: 18000,
        effects: [.insightProductionBonus(multiplier: 2.0)]
    )

    static let e8_adv_logistics = ResearchType(
        id: "e8_adv_logistics",
        name: "Advanced Logistics",
        description: "Manifests, schedules, and routing tables. Nothing lost in transit.",
        cost: [.tools: 60, .bread: 80, .insight: 100],
        requiredEpoch: 8,
        prerequisiteIds: ["e8_mass_production"],
        researchTime: 25200,
        effects: [.constructionSpeedBonus(percent: 30)]
    )

    static let e8_preservation = ResearchType(
        id: "e8_preservation",
        name: "Preservation Science",
        description: "Salt, smoke, and sealed vessels. Food lasts months, not days.",
        cost: [.herbs: 60, .bread: 50, .coal: 30, .insight: 80],
        requiredEpoch: 8,
        prerequisiteIds: [],
        researchTime: 18000,
        effects: [.foodProductionBonus(multiplier: 1.50)]
    )

    static let e8_enlightenment_dawn = ResearchType(
        id: "e8_enlightenment_dawn",
        name: "Dawn of Enlightenment",
        description: "Reason over tradition. Experiment over belief. A new age begins.",
        cost: [.insight: 350, .tools: 150, .coal: 80, .ironBars: 50],
        requiredEpoch: 8,
        prerequisiteIds: ["e8_mass_production", "e8_printing_press"],
        researchTime: 36000,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 9 — Industry (5) ──

    static let e9_mechanization = ResearchType(
        id: "e9_mechanization",
        name: "Full Mechanization",
        description: "Human hands guide; machines execute. Production reaches new heights.",
        cost: [.tools: 200, .ironBars: 100, .coal: 100, .insight: 200],
        requiredEpoch: 9,
        prerequisiteIds: [],
        researchTime: 43200,
        effects: [.allProductionBonus(multiplier: 1.25)]
    )

    static let e9_logistics_mastery = ResearchType(
        id: "e9_logistics_mastery",
        name: "Logistics Mastery",
        description: "The entire archipelago breathes as one economy.",
        cost: [.tools: 150, .bread: 100, .insight: 250],
        requiredEpoch: 9,
        prerequisiteIds: [],
        researchTime: 50400,
        effects: [.unlockBuildingTier(epoch: 9)]
    )

    static let e9_adv_metallurgy = ResearchType(
        id: "e9_adv_metallurgy",
        name: "Advanced Metallurgy",
        description: "Alloy compositions engineered for specific purposes.",
        cost: [.ironBars: 150, .coal: 120, .tools: 80, .insight: 200],
        requiredEpoch: 9,
        prerequisiteIds: ["e9_mechanization"],
        researchTime: 57600,
        effects: [.productionBonus(buildingId: "forge", multiplier: 1.50), .productionBonus(buildingId: "mine", multiplier: 1.25)]
    )

    static let e9_scientific_method = ResearchType(
        id: "e9_scientific_method",
        name: "Scientific Method",
        description: "Hypothesis, experiment, conclusion. Knowledge accelerates itself.",
        cost: [.insight: 400, .tools: 100, .bread: 80],
        requiredEpoch: 9,
        prerequisiteIds: ["e9_logistics_mastery"],
        researchTime: 64800,
        effects: [.researchSpeedBonus(percent: 40)]
    )

    static let e9_enlightenment = ResearchType(
        id: "e9_enlightenment",
        name: "Enlightenment",
        description: "The sum of all knowledge converges. Civilization reaches its zenith.",
        cost: [.insight: 500, .tools: 250, .coal: 150, .ironBars: 100],
        requiredEpoch: 9,
        prerequisiteIds: ["e9_adv_metallurgy", "e9_scientific_method"],
        researchTime: 86400,
        effects: [.advanceEpoch]
    )

    // ── EPOCH 10 — Enlightenment (3) ──

    static let e10_grand_archives = ResearchType(
        id: "e10_grand_archives",
        name: "Grand Archives",
        description: "Every scroll, every theorem in one place. The library of civilization.",
        cost: [.insight: 600, .tools: 200, .bread: 150],
        requiredEpoch: 10,
        prerequisiteIds: [],
        researchTime: 108000,
        effects: [.insightProductionBonus(multiplier: 2.0), .allProductionBonus(multiplier: 1.25)]
    )

    static let e10_master_builders = ResearchType(
        id: "e10_master_builders",
        name: "Master Builders",
        description: "The final refinements. Structures to endure a thousand years.",
        cost: [.insight: 400, .ironBars: 200, .coal: 150, .stone: 200, .tools: 150],
        requiredEpoch: 10,
        prerequisiteIds: [],
        researchTime: 129600,
        effects: [.unlockBuildingTier(epoch: 10)]
    )

    static let e10_monument_planning = ResearchType(
        id: "e10_monument_planning",
        name: "Monument Planning",
        description: "Plans for a structure visible from the heavens. The culmination of everything.",
        cost: [.insight: 800, .tools: 300, .ironBars: 200, .coal: 200, .stone: 200],
        requiredEpoch: 10,
        prerequisiteIds: ["e10_grand_archives", "e10_master_builders"],
        researchTime: 172800,
        effects: []
    )

    /// All available researches
    static let all: [ResearchType] = [
        // Epoch 1 — Dawn
        .e1_gathering, .e1_shelter, .e1_firemaking, .e1_toolcraft, .e1_herblore, .e1_agriculture,
        // Epoch 2 — Settlement
        .e2_crop_rotation, .e2_settlement_walls, .e2_bread_baking, .e2_metal_hatchets,
        .e2_animal_husbandry, .e2_pottery, .e2_construction,
        // Epoch 3 — Crafting
        .e3_masonry, .e3_carpentry, .e3_fortification, .e3_exploration, .e3_written_records,
        .e3_kiln_craft, .e3_prospecting,
        // Epoch 4 — Mining
        .e4_deep_mining, .e4_irrigation, .e4_ore_refinement, .e4_advanced_tools,
        .e4_navigation, .e4_smelting,
        // Epoch 5 — Metalworking
        .e5_alloys, .e5_advanced_masonry, .e5_metalworking_tiers, .e5_trade_routes,
        .e5_apothecary, .e5_siege_eng, .e5_engineering,
        // Epoch 6 — Trade
        .e6_cartography, .e6_guilds, .e6_colonial_mastery, .e6_currency,
        .e6_supply_lines, .e6_architecture,
        // Epoch 7 — Fortification
        .e7_coal_extraction, .e7_formal_scholarship, .e7_blast_furnace, .e7_expedition,
        .e7_civic_works, .e7_industrialization,
        // Epoch 8 — Scholarship
        .e8_steam_power, .e8_precision_tools, .e8_mass_production, .e8_printing_press,
        .e8_adv_logistics, .e8_preservation, .e8_enlightenment_dawn,
        // Epoch 9 — Industry
        .e9_mechanization, .e9_logistics_mastery, .e9_adv_metallurgy, .e9_scientific_method,
        .e9_enlightenment,
        // Epoch 10 — Enlightenment
        .e10_grand_archives, .e10_master_builders, .e10_monument_planning
    ]
}

/// Instance of a completed research
struct CompletedResearch: Codable, Identifiable {
    let id: String
    let researchId: String
    let completedAt: Date

    init(researchId: String) {
        self.id = UUID().uuidString
        self.researchId = researchId
        self.completedAt = Date()
    }
}
