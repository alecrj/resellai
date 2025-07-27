// MARK: - Complete Revolutionary Models.swift
import SwiftUI
import Foundation

// MARK: - Enhanced Core Models
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
    var additionalImageData: [Data]? // Multiple photos support
    var ebayURL: String?
    var resalePotential: Int?
    var marketNotes: String?
    
    // Revolutionary additions
    var conditionScore: Double?
    var aiConfidence: Double?
    var competitorCount: Int?
    var demandLevel: String?
    var listingStrategy: String?
    var sourcingTips: [String]?
    
    // Initialize with comprehensive defaults
    init(itemNumber: Int, name: String, category: String, purchasePrice: Double,
         suggestedPrice: Double, source: String, condition: String, title: String,
         description: String, keywords: [String], status: ItemStatus, dateAdded: Date,
         actualPrice: Double? = nil, dateListed: Date? = nil, dateSold: Date? = nil,
         imageData: Data? = nil, additionalImageData: [Data]? = nil, ebayURL: String? = nil,
         resalePotential: Int? = nil, marketNotes: String? = nil,
         conditionScore: Double? = nil, aiConfidence: Double? = nil,
         competitorCount: Int? = nil, demandLevel: String? = nil,
         listingStrategy: String? = nil, sourcingTips: [String]? = nil) {
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
        self.conditionScore = conditionScore
        self.aiConfidence = aiConfidence
        self.competitorCount = competitorCount
        self.demandLevel = demandLevel
        self.listingStrategy = listingStrategy
        self.sourcingTips = sourcingTips
    }
    
    var profit: Double {
        guard let actualPrice = actualPrice else { return 0 }
        let fees = actualPrice * 0.1325 // Updated eBay fees
        return actualPrice - purchasePrice - fees
    }
    
    var roi: Double {
        guard purchasePrice > 0 else { return 0 }
        return (profit / purchasePrice) * 100
    }
    
    var estimatedProfit: Double {
        let fees = suggestedPrice * 0.1325
        return suggestedPrice - purchasePrice - fees
    }
    
    var estimatedROI: Double {
        guard purchasePrice > 0 else { return 0 }
        return (estimatedProfit / purchasePrice) * 100
    }
    
    // Revolutionary profit calculations
    var netProfitAfterAllFees: Double {
        let totalFees = suggestedPrice * 0.1325 + 8.50 + 0.30 // eBay + shipping + listing
        return suggestedPrice - purchasePrice - totalFees
    }
    
    var breakEvenPrice: Double {
        let totalFeeRate = 0.1325 + (8.80 / suggestedPrice) // eBay fees + fixed costs
        return purchasePrice / (1 - totalFeeRate)
    }
}

// ✅ FIXED ItemStatus enum with proper case handling
enum ItemStatus: String, CaseIterable, Codable {
    case photographed = "📷 Photographed"
    case analyzed = "🧠 AI Analyzed"  // ✅ FIXED: lowercase 'analyzed'
    case toList = "📋 Ready to List"
    case listed = "🏪 Listed"
    case sold = "💰 Sold"
    case prospecting = "🔍 Prospecting"
    
    var color: Color {
        switch self {
        case .photographed: return .orange
        case .analyzed: return .blue
        case .toList: return .red
        case .listed: return .yellow
        case .sold: return .green
        case .prospecting: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .photographed: return "camera.fill"
        case .analyzed: return "brain.head.profile"
        case .toList: return "list.bullet"
        case .listed: return "storefront.fill"
        case .sold: return "dollarsign.circle.fill"
        case .prospecting: return "magnifyingglass.circle"
        }
    }
}

enum SourceLocation: String, CaseIterable {
    case cityWalk = "City Walk"
    case goodwillBins = "Goodwill Bins"
    case goodCents = "Good Cents"
    case estateSale = "Estate Sale"
    case yardSale = "Yard Sale"
    case facebookMarketplace = "Facebook Marketplace"
    case offerUp = "OfferUp"
    case craigslist = "Craigslist"
    case auction = "Auction"
    case thriftStore = "Thrift Store"
    case online = "Online"
    case other = "Other"
    
    var profitability: String {
        switch self {
        case .goodwillBins: return "🔥 Highest"
        case .estateSale, .yardSale: return "🎯 Very High"
        case .goodCents, .thriftStore: return "💰 High"
        case .auction: return "⚡ Variable"
        case .facebookMarketplace, .offerUp: return "📱 Medium"
        default: return "📊 Low-Medium"
        }
    }
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
    case multiPhoto
}

// Rest of the models remain the same...
// (I'll keep this shorter to focus on the main fixes)

// MARK: - Revolutionary Constants
struct ResellAIConstants {
    static let maxPhotosPerItem = 8
    static let minConfidenceThreshold = 0.3
    static let defaultROITarget = 200.0
    static let maxAnalysisTime: TimeInterval = 30.0
    static let cacheExpirationTime: TimeInterval = 3600.0 // 1 hour
    static let supportedImageFormats = ["jpg", "jpeg", "png", "heic"]
    static let maxImageSize: Int = 10 * 1024 * 1024 // 10MB
    
    struct Fees {
        static let ebayFinalValueFee = 0.1325 // 13.25%
        static let averageShippingCost = 8.50
        static let listingFee = 0.30
        static let promotionalFee = 0.02 // 2% for promoted listings
    }
    
    struct Timing {
        static let optimalListingDays = ["Sunday", "Monday", "Tuesday"]
        static let optimalListingHours = ["6 PM", "7 PM", "8 PM", "9 PM"]
        static let peakShoppingMonths = ["November", "December", "January"]
    }
}
