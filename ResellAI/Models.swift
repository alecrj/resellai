import SwiftUI
import Foundation

// MARK: - Core Models
struct InventoryItem: Identifiable, Codable {
    let id = UUID()
    var itemNumber: Int
    var name: String
    var category: String
    var purchasePrice: Double
    var suggestedPrice: Double
    var actualPrice: Double?
    var source: String
    var condition: String
    var title: String
    var description: String
    var keywords: [String]
    var status: ItemStatus
    var dateAdded: Date
    var dateListed: Date?
    var dateSold: Date?
    var imageData: Data?
    var additionalImageData: [Data]? // NEW: Multiple photos support
    var ebayURL: String?
    var resalePotential: Int?
    var marketNotes: String?
    
    // Initialize with default values to avoid ambiguous init
    init(itemNumber: Int, name: String, category: String, purchasePrice: Double,
         suggestedPrice: Double, source: String, condition: String, title: String,
         description: String, keywords: [String], status: ItemStatus, dateAdded: Date,
         actualPrice: Double? = nil, dateListed: Date? = nil, dateSold: Date? = nil,
         imageData: Data? = nil, additionalImageData: [Data]? = nil, ebayURL: String? = nil,
         resalePotential: Int? = nil, marketNotes: String? = nil) {
        self.itemNumber = itemNumber
        self.name = name
        self.category = category
        self.purchasePrice = purchasePrice
        self.suggestedPrice = suggestedPrice
        self.actualPrice = actualPrice
        self.source = source
        self.condition = condition
        self.title = title
        self.description = description
        self.keywords = keywords
        self.status = status
        self.dateAdded = dateAdded
        self.dateListed = dateListed
        self.dateSold = dateSold
        self.imageData = imageData
        self.additionalImageData = additionalImageData
        self.ebayURL = ebayURL
        self.resalePotential = resalePotential
        self.marketNotes = marketNotes
    }
    
    var profit: Double {
        guard let actualPrice = actualPrice else { return 0 }
        let fees = actualPrice * 0.13 // eBay + PayPal fees
        return actualPrice - purchasePrice - fees
    }
    
    var roi: Double {
        guard purchasePrice > 0 else { return 0 }
        return (profit / purchasePrice) * 100
    }
    
    var estimatedProfit: Double {
        let fees = suggestedPrice * 0.13
        return suggestedPrice - purchasePrice - fees
    }
    
    var estimatedROI: Double {
        guard purchasePrice > 0 else { return 0 }
        return (estimatedProfit / purchasePrice) * 100
    }
}

enum ItemStatus: String, CaseIterable, Codable {
    case photographed = "Photographed"
    case analyzed = "Analyzed"
    case toList = "To List"
    case listed = "Listed"
    case sold = "Sold"
    
    var color: Color {
        switch self {
        case .photographed: return .orange
        case .analyzed: return .blue
        case .toList: return .red
        case .listed: return .yellow
        case .sold: return .green
        }
    }
}

enum SourceLocation: String, CaseIterable {
    case cityWalk = "City Walk"
    case goodwillBins = "Goodwill Bins"
    case goodCents = "Good Cents"
    case estateSale = "Estate Sale"
    case yardSale = "Yard Sale"
    case online = "Online"
    case other = "Other"
}

// MARK: - Enhanced Analysis Models
protocol ItemAnalysis {
    var itemName: String { get }
    var category: String { get }
    var suggestedPrice: Double { get }
    var confidence: Double { get }
    var ebayTitle: String { get }
    var description: String { get }
    var keywords: [String] { get }
    var condition: String { get }
    var resalePotential: Int { get }
    var marketNotes: String { get }
}

struct EnhancedItemAnalysis: ItemAnalysis {
    let itemName: String
    let category: String
    let modelNumber: String
    let suggestedPrice: Double
    let priceRange: PriceRange
    let confidence: Double
    let ebayTitle: String
    let description: String
    let keywords: [String]
    let condition: String
    let resalePotential: Int
    let marketNotes: String
    let authenticationNotes: String
    let shippingNotes: String
    let competitionLevel: String
    let seasonalDemand: String
    let photosAnalyzed: Int
}

struct BasicItemAnalysis: ItemAnalysis {
    let itemName: String
    let category: String
    let suggestedPrice: Double
    let confidence: Double
    let ebayTitle: String
    let description: String
    let keywords: [String]
    let condition: String
    let resalePotential: Int
    let marketNotes: String
}

struct PriceRange {
    var low: Double
    var high: Double
    var average: Double
    
    init(low: Double = 0, high: Double = 0, average: Double = 0) {
        self.low = low
        self.high = high
        self.average = average
    }
}

// MARK: - Photo Source
enum PhotoSource {
    case camera
    case photoLibrary
}
