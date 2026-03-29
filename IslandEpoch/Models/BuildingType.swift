//
//  BuildingType.swift
//  IslandEpoch
//

import Foundation

/// Building blueprint (static definition)
struct BuildingType: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let workers: Int              // Required workers to operate
    let providesWorkers: Int      // Workers provided (for housing)
    let produces: Inventory       // Output per tick
    let consumes: Inventory       // Input per tick
    let goldCost: Int             // Cost to build
    let availableFromEpoch: Int   // Epoch when this building becomes available
    let requiredFertility: FertilityType? // Required fertility to build (nil = no requirement)
    let goldProduction: Int       // Gold produced per tick
    let constructionTime: TimeInterval // Seconds to construct
    let workerGrowthRate: Int     // Extra workers per level (housing only)

    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case id, name, workers, providesWorkers, produces, consumes, goldCost, availableFromEpoch, requiredFertility, goldProduction, constructionTime, workerGrowthRate
    }

    init(id: String, name: String, workers: Int, providesWorkers: Int, produces: Inventory, consumes: Inventory, goldCost: Int, availableFromEpoch: Int, requiredFertility: FertilityType?, goldProduction: Int = 0, constructionTime: TimeInterval = 60, workerGrowthRate: Int = 0) {
        self.id = id
        self.name = name
        self.workers = workers
        self.providesWorkers = providesWorkers
        self.produces = produces
        self.consumes = consumes
        self.goldCost = goldCost
        self.availableFromEpoch = availableFromEpoch
        self.requiredFertility = requiredFertility
        self.goldProduction = goldProduction
        self.constructionTime = constructionTime
        self.workerGrowthRate = workerGrowthRate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        workers = try container.decode(Int.self, forKey: .workers)
        providesWorkers = try container.decode(Int.self, forKey: .providesWorkers)
        produces = try container.decode(Inventory.self, forKey: .produces)
        consumes = try container.decode(Inventory.self, forKey: .consumes)
        goldCost = try container.decode(Int.self, forKey: .goldCost)
        availableFromEpoch = try container.decode(Int.self, forKey: .availableFromEpoch)
        requiredFertility = try container.decodeIfPresent(FertilityType.self, forKey: .requiredFertility)
        goldProduction = try container.decodeIfPresent(Int.self, forKey: .goldProduction) ?? 0
        constructionTime = (try? container.decodeIfPresent(TimeInterval.self, forKey: .constructionTime)) ?? 60
        workerGrowthRate = try container.decodeIfPresent(Int.self, forKey: .workerGrowthRate) ?? 0
    }

    // MARK: - Static Catalog

    // Housing
    static let tent = BuildingType(
        id: "tent",
        name: "Tent",
        workers: 0,
        providesWorkers: 5,
        produces: [:],
        consumes: [:],
        goldCost: 30,
        availableFromEpoch: 1,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 10,
        workerGrowthRate: 1
    )

    // Production Buildings
    static let farm = BuildingType(
        id: "farm",
        name: "Farm",
        workers: 2,
        providesWorkers: 0,
        produces: [.wheat: 2],
        consumes: [:],
        goldCost: 50,
        availableFromEpoch: 2,
        requiredFertility: .grainland,
        goldProduction: 0,
        constructionTime: 30
    )

    static let forester = BuildingType(
        id: "forester",
        name: "Forester",
        workers: 2,
        providesWorkers: 0,
        produces: [.wood: 2],
        consumes: [:],
        goldCost: 40,
        availableFromEpoch: 1,
        requiredFertility: .forest,
        goldProduction: 0,
        constructionTime: 20
    )

    static let mine = BuildingType(
        id: "mine",
        name: "Mine",
        workers: 3,
        providesWorkers: 0,
        produces: [.ironOre: 1],
        consumes: [:],
        goldCost: 80,
        availableFromEpoch: 4,
        requiredFertility: .ironDeposits,
        goldProduction: 0,
        constructionTime: 120
    )

    static let bakery = BuildingType(
        id: "bakery",
        name: "Bakery",
        workers: 2,
        providesWorkers: 0,
        produces: [.bread: 4],
        consumes: [.wheat: 1],
        goldCost: 100,
        availableFromEpoch: 2,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 45
    )

    static let forager = BuildingType(
        id: "forager",
        name: "Forager",
        workers: 1,
        providesWorkers: 0,
        produces: [.berries: 1],
        consumes: [:],
        goldCost: 20,
        availableFromEpoch: 1,
        requiredFertility: .wildlife,
        goldProduction: 0,
        constructionTime: 15
    )

    static let library = BuildingType(
        id: "library",
        name: "Library",
        workers: 3,
        providesWorkers: 0,
        produces: [.insight: 1],
        consumes: [:],
        goldCost: 150,
        availableFromEpoch: 3,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 60
    )

    static let herbalist = BuildingType(
        id: "herbalist",
        name: "Herbalist",
        workers: 1,
        providesWorkers: 0,
        produces: [.herbs: 1],
        consumes: [:],
        goldCost: 35,
        availableFromEpoch: 2,
        requiredFertility: .wildlife,
        goldProduction: 0,
        constructionTime: 25
    )

    static let sawmill = BuildingType(
        id: "sawmill",
        name: "Sawmill",
        workers: 2,
        providesWorkers: 0,
        produces: [.planks: 2],
        consumes: [.wood: 1],
        goldCost: 100,
        availableFromEpoch: 3,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 60
    )

    static let quarry = BuildingType(
        id: "quarry",
        name: "Quarry",
        workers: 3,
        providesWorkers: 0,
        produces: [.stone: 1],
        consumes: [:],
        goldCost: 120,
        availableFromEpoch: 3,
        requiredFertility: .stoneDeposits,
        goldProduction: 0,
        constructionTime: 90
    )

    static let cottage = BuildingType(
        id: "cottage",
        name: "Cottage",
        workers: 0,
        providesWorkers: 10,
        produces: [:],
        consumes: [:],
        goldCost: 120,
        availableFromEpoch: 4,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 120,
        workerGrowthRate: 2
    )

    static let smelter = BuildingType(
        id: "smelter",
        name: "Smelter",
        workers: 3,
        providesWorkers: 0,
        produces: [.ironBars: 1],
        consumes: [.ironOre: 1],
        goldCost: 200,
        availableFromEpoch: 5,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 180
    )

    static let market = BuildingType(
        id: "market",
        name: "Market",
        workers: 2,
        providesWorkers: 0,
        produces: [:],
        consumes: [.bread: 2],
        goldCost: 250,
        availableFromEpoch: 5,
        requiredFertility: nil,
        goldProduction: 5,
        constructionTime: 180
    )

    static let toolsmith = BuildingType(
        id: "toolsmith",
        name: "Toolsmith",
        workers: 3,
        providesWorkers: 0,
        produces: [.tools: 1],
        consumes: [.ironBars: 1, .planks: 1],
        goldCost: 300,
        availableFromEpoch: 6,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 300
    )

    static let tradingPost = BuildingType(
        id: "tradingPost",
        name: "Trading Post",
        workers: 2,
        providesWorkers: 0,
        produces: [:],
        consumes: [.tools: 1, .herbs: 1],
        goldCost: 350,
        availableFromEpoch: 6,
        requiredFertility: nil,
        goldProduction: 8,
        constructionTime: 300
    )

    static let coalMine = BuildingType(
        id: "coalMine",
        name: "Coal Mine",
        workers: 3,
        providesWorkers: 0,
        produces: [.coal: 1],
        consumes: [:],
        goldCost: 250,
        availableFromEpoch: 7,
        requiredFertility: .coalVeins,
        goldProduction: 0,
        constructionTime: 480
    )

    static let manor = BuildingType(
        id: "manor",
        name: "Manor",
        workers: 0,
        providesWorkers: 20,
        produces: [:],
        consumes: [:],
        goldCost: 400,
        availableFromEpoch: 7,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 480,
        workerGrowthRate: 4
    )

    static let university = BuildingType(
        id: "university",
        name: "University",
        workers: 4,
        providesWorkers: 0,
        produces: [.insight: 3],
        consumes: [.bread: 1],
        goldCost: 500,
        availableFromEpoch: 8,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 720
    )

    static let smokehouse = BuildingType(
        id: "smokehouse",
        name: "Smokehouse",
        workers: 2,
        providesWorkers: 0,
        produces: [.bread: 3],
        consumes: [.berries: 1, .herbs: 1],
        goldCost: 300,
        availableFromEpoch: 8,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 600
    )

    static let forge = BuildingType(
        id: "forge",
        name: "Forge",
        workers: 4,
        providesWorkers: 0,
        produces: [.ironBars: 2],
        consumes: [.ironOre: 1, .coal: 1],
        goldCost: 500,
        availableFromEpoch: 9,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 900
    )

    static let monument = BuildingType(
        id: "monument",
        name: "Monument",
        workers: 0,
        providesWorkers: 0,
        produces: [:],
        consumes: [:],
        goldCost: 1000,
        availableFromEpoch: 10,
        requiredFertility: nil,
        goldProduction: 0,
        constructionTime: 1800
    )

    /// All available building types
    static let all: [BuildingType] = [
        .tent, .farm, .forester, .mine, .bakery, .forager, .library,
        .herbalist, .sawmill, .quarry, .cottage, .smelter, .market,
        .toolsmith, .tradingPost, .coalMine, .manor, .university,
        .smokehouse, .forge, .monument
    ]

    // MARK: - Helpers

    var icon: String {
        switch id {
        case "tent": return "house.fill"
        case "farm": return "leaf.fill"
        case "forester": return "tree.fill"
        case "mine": return "cube.box.fill"
        case "bakery": return "basket.fill"
        case "forager": return "leaf.circle.fill"
        case "library": return "book.fill"
        case "herbalist": return "leaf.arrow.circlepath"
        case "sawmill": return "rectangle.split.3x1"
        case "quarry": return "square.stack.3d.up"
        case "cottage": return "house"
        case "smelter": return "flame"
        case "market": return "cart"
        case "toolsmith": return "wrench"
        case "tradingPost": return "arrow.left.arrow.right"
        case "coalMine": return "flame.fill"
        case "manor": return "building.columns"
        case "university": return "graduationcap"
        case "smokehouse": return "cloud.fill"
        case "forge": return "hammer"
        case "monument": return "star.circle.fill"
        default: return "building.2"
        }
    }

    var productionDescription: String {
        guard let (resource, amount) = produces.first else {
            return "No production"
        }
        return "+\(amount) \(resource.displayNameWithCategory)/tick"
    }
}

// MARK: - Building Tier Catalog

struct BuildingTier {
    let name: String
    let flavorText: String
}

struct BuildingTierCatalog {
    /// Returns the tier name and flavor text for a building at a given tier number (1-10)
    static func tier(for buildingId: String, tierNumber: Int) -> BuildingTier {
        let key = "\(buildingId)_\(tierNumber)"
        return tiers[key] ?? BuildingTier(name: "Unknown", flavorText: "")
    }

    /// Get tier number from level: tier = (level - 1) / 10 + 1
    static func tierNumber(for level: Int) -> Int {
        (level - 1) / 10 + 1
    }

    /// Get level within tier (1-10): ((level - 1) % 10) + 1
    static func levelWithinTier(for level: Int) -> Int {
        ((level - 1) % 10) + 1
    }

    private static let tiers: [String: BuildingTier] = [
        // TENT (Epoch 1-10, 10 tiers)
        "tent_1": BuildingTier(name: "Tent", flavorText: "Animal hides stretched over sticks. It keeps the rain off, mostly."),
        "tent_2": BuildingTier(name: "Hut", flavorText: "Wattle-and-daub walls bring warmth. A hearth makes it home."),
        "tent_3": BuildingTier(name: "Longhouse", flavorText: "Timber frames shelter an entire clan under one roof."),
        "tent_4": BuildingTier(name: "Stone House", flavorText: "Quarried walls hold fast against the storms."),
        "tent_5": BuildingTier(name: "Cottage", flavorText: "Lime-washed with a proper chimney. Civilized at last."),
        "tent_6": BuildingTier(name: "Townhouse", flavorText: "Two stories of colonial ambition, with a merchant's cellar."),
        "tent_7": BuildingTier(name: "Row House", flavorText: "Standardized housing for the industrial workforce."),
        "tent_8": BuildingTier(name: "Tenement", flavorText: "Steam-heated flats stacked high. The city never sleeps."),
        "tent_9": BuildingTier(name: "Apartment Block", flavorText: "Reinforced concrete and running water. Modern comfort."),
        "tent_10": BuildingTier(name: "Habitation Module", flavorText: "Climate-controlled pods designed for the new frontier."),

        // FORAGER (Epoch 1-10, 10 tiers)
        "forager_1": BuildingTier(name: "Forager", flavorText: "Wandering the brush for anything edible."),
        "forager_2": BuildingTier(name: "Berry Garden", flavorText: "Someone thought to plant the seeds near camp. Genius."),
        "forager_3": BuildingTier(name: "Orchard", flavorText: "Trained trees in neat rows. The first managed harvest."),
        "forager_4": BuildingTier(name: "Walled Garden", flavorText: "Stone walls trap the sun's heat, extending the season."),
        "forager_5": BuildingTier(name: "Botanical Nursery", flavorText: "Catalogued specimens from distant shores thrive under glass."),
        "forager_6": BuildingTier(name: "Plantation", flavorText: "Acres of productive land worked by organized teams."),
        "forager_7": BuildingTier(name: "Industrial Greenhouse", flavorText: "Coal-heated glass houses defy winter itself."),
        "forager_8": BuildingTier(name: "Steam Conservatory", flavorText: "Pressurized growing chambers force year-round blooms."),
        "forager_9": BuildingTier(name: "Hydroponic Array", flavorText: "Soil is optional when you understand the chemistry."),
        "forager_10": BuildingTier(name: "Biome Vault", flavorText: "Sealed ecosystems engineered for maximum yield."),

        // FORESTER (Epoch 1-10, 10 tiers)
        "forester_1": BuildingTier(name: "Forester", flavorText: "An axe and strong arms. The forest yields reluctantly."),
        "forester_2": BuildingTier(name: "Logging Camp", flavorText: "Permanent shelters near the best stands."),
        "forester_3": BuildingTier(name: "Timber Yard", flavorText: "Iron saws and organized felling rotations."),
        "forester_4": BuildingTier(name: "Lumber Mill", flavorText: "Water-powered blades slice through trunks in seconds."),
        "forester_5": BuildingTier(name: "Chartered Woodlands", flavorText: "Mapped groves with planned replanting cycles."),
        "forester_6": BuildingTier(name: "Colonial Sawworks", flavorText: "Imported techniques double throughput."),
        "forester_7": BuildingTier(name: "Steam-Powered Mill", flavorText: "The rhythmic chug of pistons replaces axes."),
        "forester_8": BuildingTier(name: "Industrial Lumberworks", flavorText: "Belt-driven machinery processes entire trunks."),
        "forester_9": BuildingTier(name: "Automated Forestry", flavorText: "Mechanical harvesters manage entire regions."),
        "forester_10": BuildingTier(name: "Dendro-Engineering Lab", flavorText: "Genetically optimized fast-growth timber."),

        // FARM (Epoch 2-10, 9 tiers)
        "farm_1": BuildingTier(name: "Farm", flavorText: "Scratching furrows with wooden plows. It works."),
        "farm_2": BuildingTier(name: "Irrigated Fields", flavorText: "Ditches carry water where rain does not."),
        "farm_3": BuildingTier(name: "Iron-Plow Estate", flavorText: "Metal blades cut deeper into the earth."),
        "farm_4": BuildingTier(name: "Fortified Granary Farm", flavorText: "Stone silos protect from rot and raiders."),
        "farm_5": BuildingTier(name: "Charter Farmstead", flavorText: "Land grants and crop rotation bring order."),
        "farm_6": BuildingTier(name: "Colonial Plantation", flavorText: "Vast acreage under a single steward."),
        "farm_7": BuildingTier(name: "Mechanized Farm", flavorText: "Steam threshers replace human toil."),
        "farm_8": BuildingTier(name: "Electrified Agriplex", flavorText: "Conveyors carry grain from field to silo."),
        "farm_9": BuildingTier(name: "Precision Agriculture", flavorText: "Soil sensors ensure every seed reaches potential."),

        // BAKERY (Epoch 2-10, 9 tiers)
        "bakery_1": BuildingTier(name: "Bakery", flavorText: "Dough on hot stone. Simple but transformative."),
        "bakery_2": BuildingTier(name: "Stone Oven", flavorText: "Retained heat bakes evenly. Better bread."),
        "bakery_3": BuildingTier(name: "Guild Bakehouse", flavorText: "Master bakers train apprentices in the craft."),
        "bakery_4": BuildingTier(name: "Fortified Bakery", flavorText: "Protected flour stores ensure bread in lean times."),
        "bakery_5": BuildingTier(name: "Commercial Bakery", flavorText: "Standardized loaves for the growing market."),
        "bakery_6": BuildingTier(name: "Colonial Breadworks", flavorText: "Feeding distant settlements from central ovens."),
        "bakery_7": BuildingTier(name: "Steam Bakery", flavorText: "Automated kneading and precision temperature."),
        "bakery_8": BuildingTier(name: "Industrial Bakery", flavorText: "Thousands of loaves per hour, untouched by hand."),
        "bakery_9": BuildingTier(name: "Automated Food Lab", flavorText: "Nutritionally optimized outputs at scale."),

        // HERBALIST (Epoch 2-10, 9 tiers)
        "herbalist_1": BuildingTier(name: "Herbalist", flavorText: "Knowing which leaf heals and which kills."),
        "herbalist_2": BuildingTier(name: "Herb Garden", flavorText: "Cultivated medicinal plants near the settlement."),
        "herbalist_3": BuildingTier(name: "Apothecary", flavorText: "Dried herbs and measured tinctures on shelves."),
        "herbalist_4": BuildingTier(name: "Physic Garden", flavorText: "Walled gardens with catalogued specimens."),
        "herbalist_5": BuildingTier(name: "Botanical Institute", flavorText: "Scientific study of plant properties."),
        "herbalist_6": BuildingTier(name: "Colonial Herbarium", flavorText: "Specimens from every island, cross-referenced."),
        "herbalist_7": BuildingTier(name: "Chemical Laboratory", flavorText: "Extraction and synthesis of active compounds."),
        "herbalist_8": BuildingTier(name: "Pharmaceutical Works", flavorText: "Standardized medicines at industrial scale."),
        "herbalist_9": BuildingTier(name: "Biotech Facility", flavorText: "Engineered organisms produce compounds on demand."),

        // SAWMILL (Epoch 3-10, 8 tiers)
        "sawmill_1": BuildingTier(name: "Sawmill", flavorText: "Planks sawn to measure. No more wasting logs."),
        "sawmill_2": BuildingTier(name: "Water Sawmill", flavorText: "River current drives the blade. Tireless."),
        "sawmill_3": BuildingTier(name: "Iron-Blade Mill", flavorText: "Harder blades cut cleaner and last longer."),
        "sawmill_4": BuildingTier(name: "Charter Sawworks", flavorText: "Licensed operations with quality standards."),
        "sawmill_5": BuildingTier(name: "Colonial Timber Works", flavorText: "Processing lumber for an expanding empire."),
        "sawmill_6": BuildingTier(name: "Steam Sawmill", flavorText: "Circular saws spinning at impossible speeds."),
        "sawmill_7": BuildingTier(name: "Band Mill", flavorText: "Continuous blade loops maximize yield from each log."),
        "sawmill_8": BuildingTier(name: "CNC Lumber Plant", flavorText: "Computer-guided cuts waste nothing."),

        // QUARRY (Epoch 3-10, 8 tiers)
        "quarry_1": BuildingTier(name: "Quarry", flavorText: "Picks ring against stone. Every block earned by hand."),
        "quarry_2": BuildingTier(name: "Stone Pit", flavorText: "Deeper cuts reveal better stone below."),
        "quarry_3": BuildingTier(name: "Dressed Stone Works", flavorText: "Blocks shaped for construction, not just broken."),
        "quarry_4": BuildingTier(name: "Industrial Quarry", flavorText: "Blasting powder opens new faces overnight."),
        "quarry_5": BuildingTier(name: "Marble Works", flavorText: "Precision cutting for architectural stone."),
        "quarry_6": BuildingTier(name: "Steam Quarry", flavorText: "Powered hoists lift tonnage from the depths."),
        "quarry_7": BuildingTier(name: "Mechanized Extraction", flavorText: "Continuous mining operations around the clock."),
        "quarry_8": BuildingTier(name: "Geological Survey Site", flavorText: "Every vein mapped, every extraction optimized."),

        // LIBRARY (Epoch 3-10, 8 tiers)
        "library_1": BuildingTier(name: "Library", flavorText: "Clay tablets and scrolls. Knowledge preserved."),
        "library_2": BuildingTier(name: "Scriptorium", flavorText: "Scribes copy texts by lamplight. Knowledge multiplies."),
        "library_3": BuildingTier(name: "Academy", flavorText: "Formal teaching alongside the collection."),
        "library_4": BuildingTier(name: "Great Library", flavorText: "Scholars travel from distant lands to study here."),
        "library_5": BuildingTier(name: "Royal Archives", flavorText: "State-sponsored preservation of all knowledge."),
        "library_6": BuildingTier(name: "Printing House", flavorText: "Movable type democratizes learning."),
        "library_7": BuildingTier(name: "Research Institute", flavorText: "Original research alongside the stacks."),
        "library_8": BuildingTier(name: "Digital Archive", flavorText: "Every page indexed, searchable, immortal."),

        // MINE (Epoch 4-10, 7 tiers)
        "mine_1": BuildingTier(name: "Mine", flavorText: "Picks ring in the dark. Every nugget won by hand."),
        "mine_2": BuildingTier(name: "Timbered Shaft", flavorText: "Reinforced tunnels reach new veins below."),
        "mine_3": BuildingTier(name: "Charter Mine", flavorText: "Professional surveyors map the deposits."),
        "mine_4": BuildingTier(name: "Industrial Pit", flavorText: "Steam-powered hoists from unprecedented depths."),
        "mine_5": BuildingTier(name: "Deep Works", flavorText: "Electric rail carts through miles of tunnel."),
        "mine_6": BuildingTier(name: "Automated Bore", flavorText: "Mechanical drills chew through bedrock."),
        "mine_7": BuildingTier(name: "Subterranean Complex", flavorText: "An underground city dedicated to extraction."),

        // COTTAGE (Epoch 4-10, 7 tiers)
        "cottage_1": BuildingTier(name: "Cottage", flavorText: "A proper dwelling with room to breathe."),
        "cottage_2": BuildingTier(name: "Timber House", flavorText: "Planked floors and glass in the windows."),
        "cottage_3": BuildingTier(name: "Manor House", flavorText: "Space for a family and their servants."),
        "cottage_4": BuildingTier(name: "Guildsman's Home", flavorText: "Built to guild standards. Solid and warm."),
        "cottage_5": BuildingTier(name: "Colonial Villa", flavorText: "Imported comforts in a new world setting."),
        "cottage_6": BuildingTier(name: "Terraced Housing", flavorText: "Efficient use of space for the growing population."),
        "cottage_7": BuildingTier(name: "Modern Dwelling", flavorText: "Running water, electric light, central heating."),

        // SMELTER (Epoch 5-10, 6 tiers)
        "smelter_1": BuildingTier(name: "Smelter", flavorText: "Bellows roar. Ore runs liquid."),
        "smelter_2": BuildingTier(name: "Bloomery", flavorText: "Higher temperatures yield purer metal."),
        "smelter_3": BuildingTier(name: "Foundry", flavorText: "Casting molds shape metal to purpose."),
        "smelter_4": BuildingTier(name: "Blast Smelter", flavorText: "Coke-fired furnaces run day and night."),
        "smelter_5": BuildingTier(name: "Bessemer Works", flavorText: "Steel production at industrial scale."),
        "smelter_6": BuildingTier(name: "Arc Furnace", flavorText: "Electric heat melts the hardest alloys."),

        // MARKET (Epoch 5-10, 6 tiers)
        "market_1": BuildingTier(name: "Market", flavorText: "A clearing where goods change hands."),
        "market_2": BuildingTier(name: "Bazaar", flavorText: "Covered stalls and the hum of commerce."),
        "market_3": BuildingTier(name: "Exchange", flavorText: "Standardized weights and regulated trade."),
        "market_4": BuildingTier(name: "Trade Hall", flavorText: "Merchants from every island negotiate here."),
        "market_5": BuildingTier(name: "Stock Exchange", flavorText: "Futures and commodities traded at speed."),
        "market_6": BuildingTier(name: "Financial Center", flavorText: "Capital flows at the speed of telegraph."),

        // TOOLSMITH (Epoch 6-10, 5 tiers)
        "toolsmith_1": BuildingTier(name: "Toolsmith", flavorText: "Iron shaped for purpose. Every tool unique."),
        "toolsmith_2": BuildingTier(name: "Forge Workshop", flavorText: "Apprentices learn the craft of metalwork."),
        "toolsmith_3": BuildingTier(name: "Arms Manufactory", flavorText: "Standardized tools for army and industry."),
        "toolsmith_4": BuildingTier(name: "Precision Workshop", flavorText: "Lathes and micrometers. Exact tolerances."),
        "toolsmith_5": BuildingTier(name: "Tool Factory", flavorText: "Assembly lines produce tools by the thousand."),

        // TRADING POST (Epoch 6-10, 5 tiers)
        "tradingPost_1": BuildingTier(name: "Trading Post", flavorText: "Where goods from distant lands first arrive."),
        "tradingPost_2": BuildingTier(name: "Merchant House", flavorText: "Established trade relationships and credit lines."),
        "tradingPost_3": BuildingTier(name: "Trading Company", flavorText: "Licensed monopoly over certain trade routes."),
        "tradingPost_4": BuildingTier(name: "Import House", flavorText: "Warehouses full of exotic goods from every shore."),
        "tradingPost_5": BuildingTier(name: "Global Exchange", flavorText: "Trade agreements span the known world."),

        // COAL MINE (Epoch 7-10, 4 tiers)
        "coalMine_1": BuildingTier(name: "Coal Mine", flavorText: "Black seams in the cliff. Fuel for the future."),
        "coalMine_2": BuildingTier(name: "Deep Coal Shaft", flavorText: "Ventilated shafts reach rich deposits below."),
        "coalMine_3": BuildingTier(name: "Mechanized Colliery", flavorText: "Conveyor belts bring coal to the surface."),
        "coalMine_4": BuildingTier(name: "Strip Mine", flavorText: "Surface mining at industrial scale."),

        // MANOR (Epoch 7-10, 4 tiers)
        "manor_1": BuildingTier(name: "Manor", flavorText: "A grand house for many families."),
        "manor_2": BuildingTier(name: "Estate", flavorText: "Grounds and gardens surrounding spacious halls."),
        "manor_3": BuildingTier(name: "City Block", flavorText: "Multi-story living for the urban population."),
        "manor_4": BuildingTier(name: "Residential Tower", flavorText: "Steel and glass reaching toward the sky."),

        // UNIVERSITY (Epoch 8-10, 3 tiers)
        "university_1": BuildingTier(name: "University", flavorText: "Halls of higher learning and research."),
        "university_2": BuildingTier(name: "Research University", flavorText: "Original discovery alongside teaching."),
        "university_3": BuildingTier(name: "Innovation Campus", flavorText: "Where theory becomes application."),

        // SMOKEHOUSE (Epoch 8-10, 3 tiers)
        "smokehouse_1": BuildingTier(name: "Smokehouse", flavorText: "Preserved food for long journeys."),
        "smokehouse_2": BuildingTier(name: "Canning Works", flavorText: "Sealed tins keep food for months."),
        "smokehouse_3": BuildingTier(name: "Food Processing Plant", flavorText: "Industrial preservation at scale."),

        // FORGE (Epoch 9-10, 2 tiers)
        "forge_1": BuildingTier(name: "Forge", flavorText: "White-hot metal shaped by skilled hands."),
        "forge_2": BuildingTier(name: "Steel Mill", flavorText: "Rivers of molten steel for the modern age."),

        // MONUMENT (Epoch 10, 1 tier)
        "monument_1": BuildingTier(name: "Monument", flavorText: "A testament to everything your civilization has achieved."),
    ]
}
