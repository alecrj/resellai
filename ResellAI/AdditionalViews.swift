import SwiftUI
import Vision
import AVFoundation
import MessageUI

// MARK: - 🚀 Ultimate Dashboard View with Business Intelligence
struct DashboardView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var showingPortfolioTracking = false
    @State private var showingBusinessIntelligence = false
    @State private var showingProfitOptimizer = false
    @State private var selectedTimeframe = "This Month"
    
    let timeframes = ["This Week", "This Month", "Last 3 Months", "This Year", "All Time"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Ultimate Header
                    VStack(spacing: 8) {
                        Text("🚀 BUSINESS COMMAND CENTER")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Transform from $300 → eBay Empire")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    // Empire Metrics Row
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        EmpireStatCard(
                            title: "Empire Value",
                            value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                            color: .blue,
                            icon: "crown.fill"
                        )
                        
                        EmpireStatCard(
                            title: "Profit Power",
                            value: "$\(String(format: "%.0f", inventoryManager.totalProfit))",
                            color: .green,
                            icon: "bolt.fill"
                        )
                        
                        EmpireStatCard(
                            title: "ROI Mastery",
                            value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                            color: .purple,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        EmpireStatCard(
                            title: "Items Sold",
                            value: "\(inventoryManager.soldItems)",
                            color: .orange,
                            icon: "star.fill"
                        )
                    }
                    
                    // Revolutionary Action Center
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⚡ EMPIRE ACCELERATORS")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            
                            ActionButton(
                                title: "🧠 Business Intelligence",
                                description: "AI insights for growth",
                                color: .purple
                            ) {
                                empireHaptic(.medium)
                                showingBusinessIntelligence = true
                            }
                            
                            ActionButton(
                                title: "💰 Profit Optimizer",
                                description: "Maximize every sale",
                                color: .green
                            ) {
                                empireHaptic(.medium)
                                showingProfitOptimizer = true
                            }
                            
                            ActionButton(
                                title: "📈 Portfolio Tracking",
                                description: "Monitor your empire",
                                color: .blue
                            ) {
                                empireHaptic(.medium)
                                showingPortfolioTracking = true
                            }
                            
                            ActionButton(
                                title: "🎯 Market Opportunities",
                                description: "Hot profit opportunities",
                                color: .red
                            ) {
                                empireHaptic(.medium)
                                // TODO: Show market opportunities
                            }
                        }
                    }
                    
                    // Quick Insights Panel
                    QuickInsightsPanel(inventoryManager: inventoryManager)
                    
                    // Performance Trends
                    PerformanceTrendsView(inventoryManager: inventoryManager)
                    
                    // Recent Activity with Intelligence
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔥 RECENT EMPIRE ACTIVITY")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(inventoryManager.recentItems.prefix(5)) { item in
                            EnhancedRecentItemCard(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPortfolioTracking) {
            UltimatePortfolioTrackingView()
                .environmentObject(inventoryManager)
        }
        .sheet(isPresented: $showingBusinessIntelligence) {
            BusinessIntelligenceView()
                .environmentObject(inventoryManager)
        }
        .sheet(isPresented: $showingProfitOptimizer) {
            ProfitOptimizerView()
                .environmentObject(inventoryManager)
        }
    }
}

// MARK: - 🔍 PROSPECTING MODE - THE ULTIMATE BUYING TOOL
struct ProspectingModeView: View {
    @StateObject private var prospectingService = ProspectingIntelligenceService()
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    @State private var askingPrice = ""
    @State private var selectedCategory = "All Categories"
    
    let categories = ["All Categories", "Electronics", "Gaming", "Clothing", "Collectibles", "Home & Garden", "Sports", "Books", "Toys"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Prospecting Header
                    VStack(spacing: 12) {
                        Text("🔍 PROSPECTING MODE")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Instant Buy/Avoid Analysis • Real Profit Potential • Max Pay Price")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Quick Stats Row
                        HStack(spacing: 15) {
                            ProspectingStatCard(
                                title: "Items Analyzed",
                                value: "\(prospectingService.itemsAnalyzed)",
                                color: .blue
                            )
                            ProspectingStatCard(
                                title: "Profit Opportunities",
                                value: "\(prospectingService.profitableItems)",
                                color: .green
                            )
                            ProspectingStatCard(
                                title: "Avoided Losses",
                                value: "\(prospectingService.avoidedItems)",
                                color: .red
                            )
                        }
                    }
                    
                    // Analysis Progress
                    if prospectingService.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView(value: Double(prospectingService.currentStep), total: Double(prospectingService.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            
                            Text(prospectingService.analysisProgress)
                                .font(.caption)
                                .foregroundColor(.purple)
                            
                            Text("Prospecting Analysis: Step \(prospectingService.currentStep)/\(prospectingService.totalSteps)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Quick Input Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📊 Quick Analysis Setup")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Asking Price: $")
                                .fontWeight(.semibold)
                            TextField("0.00", text: $askingPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Picker("Category Focus", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Analysis Methods
                    VStack(spacing: 15) {
                        // Photo Analysis Button
                        Button(action: {
                            empireHaptic(.medium)
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                VStack(alignment: .leading) {
                                    Text("📸 Photo Analysis")
                                        .fontWeight(.bold)
                                    Text("Snap and get instant buy/avoid decision")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Barcode Lookup Button
                        Button(action: {
                            empireHaptic(.medium)
                            showingBarcodeLookup = true
                        }) {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                VStack(alignment: .leading) {
                                    Text("📱 Barcode Lookup")
                                        .fontWeight(.bold)
                                    Text("Instant UPC/ISBN profit analysis")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Analyze Current Photos Button
                        if !capturedImages.isEmpty {
                            Button(action: {
                                empireHaptic(.heavy)
                                analyzeProspect()
                            }) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("🚀 ANALYZE PROSPECT (\(capturedImages.count) photos)")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .disabled(prospectingService.isAnalyzing)
                        }
                    }
                    
                    // Photo Preview
                    if !capturedImages.isEmpty {
                        ProspectPhotoPreview(images: $capturedImages)
                    }
                    
                    // Analysis Results
                    if let analysis = prospectAnalysis {
                        ProspectAnalysisResultView(analysis: analysis)
                    }
                    
                    // Pro Tips Section
                    ProspectingProTipsView()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImages: $capturedImages, allowsMultipleSelection: true)
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        lookupBarcode(barcode)
                    }
                }
        }
    }
    
    private func analyzeProspect() {
        guard !capturedImages.isEmpty else { return }
        
        let askingPriceValue = Double(askingPrice) ?? 0.0
        
        prospectingService.analyzeProspect(
            images: capturedImages,
            askingPrice: askingPriceValue,
            category: selectedCategory
        ) { analysis in
            prospectAnalysis = analysis
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        empireHaptic(.success)
        prospectingService.lookupBarcode(barcode) { analysis in
            prospectAnalysis = analysis
        }
    }
}

// MARK: - 🔍 Prospecting Intelligence Service
class ProspectingIntelligenceService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 4
    
    // Stats tracking
    @Published var itemsAnalyzed = 0
    @Published var profitableItems = 0
    @Published var avoidedItems = 0
    
    func analyzeProspect(images: [UIImage], askingPrice: Double, category: String, completion: @escaping (ProspectAnalysis) -> Void) {
        isAnalyzing = true
        currentStep = 0
        totalSteps = 4
        
        analysisProgress = "🔍 Step 1/4: Identifying item and condition..."
        currentStep = 1
        
        // Step 1: Quick Identification
        quickIdentification(images) { [weak self] identification in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.analysisProgress = "📊 Step 2/4: Real-time market research..."
                self.currentStep = 2
            }
            
            // Step 2: Market Research
            self.instantMarketLookup(identification.itemName) { marketData in
                DispatchQueue.main.async {
                    self.analysisProgress = "💰 Step 3/4: Profit potential calculation..."
                    self.currentStep = 3
                }
                
                // Step 3: Profit Analysis
                self.calculateProfitPotential(identification, market: marketData, askingPrice: askingPrice) { profitAnalysis in
                    DispatchQueue.main.async {
                        self.analysisProgress = "🎯 Step 4/4: Final recommendation..."
                        self.currentStep = 4
                    }
                    
                    // Step 4: Final Decision
                    let recommendation = self.generateBuyAvoidRecommendation(
                        identification: identification,
                        market: marketData,
                        profit: profitAnalysis,
                        askingPrice: askingPrice
                    )
                    
                    let finalAnalysis = ProspectAnalysis(
                        itemName: identification.itemName,
                        brand: identification.brand,
                        condition: identification.condition,
                        confidence: identification.confidence,
                        askingPrice: askingPrice,
                        estimatedValue: marketData.averagePrice,
                        maxPayPrice: profitAnalysis.maxPayPrice,
                        potentialProfit: profitAnalysis.potentialProfit,
                        expectedROI: profitAnalysis.expectedROI,
                        recommendation: recommendation.decision,
                        reasons: recommendation.reasons,
                        riskLevel: recommendation.riskLevel,
                        demandLevel: marketData.demandLevel,
                        competitorCount: marketData.competitorCount,
                        marketTrend: marketData.trend,
                        sellTimeEstimate: profitAnalysis.sellTimeEstimate,
                        seasonalFactors: marketData.seasonalFactors,
                        sourcingTips: recommendation.sourcingTips,
                        images: images
                    )
                    
                    // Update stats
                    DispatchQueue.main.async {
                        self.itemsAnalyzed += 1
                        if recommendation.decision == .buy {
                            self.profitableItems += 1
                        } else if recommendation.decision == .avoid {
                            self.avoidedItems += 1
                        }
                        
                        self.isAnalyzing = false
                        self.analysisProgress = "Ready"
                        self.currentStep = 0
                        completion(finalAnalysis)
                    }
                }
            }
        }
    }
    
    func lookupBarcode(_ barcode: String, completion: @escaping (ProspectAnalysis) -> Void) {
        isAnalyzing = true
        analysisProgress = "🔍 Looking up barcode..."
        
        // Simulate barcode API lookup
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let mockAnalysis = ProspectAnalysis(
                itemName: "Product from barcode \(barcode)",
                brand: "Unknown Brand",
                condition: "Unknown",
                confidence: 0.8,
                askingPrice: 0,
                estimatedValue: 25.0,
                maxPayPrice: 15.0,
                potentialProfit: 8.50,
                expectedROI: 56.7,
                recommendation: .investigate,
                reasons: ["Barcode lookup successful", "Need visual inspection for condition"],
                riskLevel: "Medium",
                demandLevel: "Medium",
                competitorCount: 150,
                marketTrend: "Stable",
                sellTimeEstimate: "7-14 days",
                seasonalFactors: "Standard demand",
                sourcingTips: ["Check condition carefully", "Look for complete accessories"],
                images: []
            )
            
            self.isAnalyzing = false
            self.analysisProgress = "Ready"
            completion(mockAnalysis)
        }
    }
    
    // MARK: - Private Analysis Methods
    private func quickIdentification(_ images: [UIImage], completion: @escaping (QuickIdentification) -> Void) {
        // Simulated quick AI identification
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            let identification = QuickIdentification(
                itemName: "Gaming Controller",
                brand: "Sony",
                condition: "Good",
                confidence: 0.85
            )
            completion(identification)
        }
    }
    
    private func instantMarketLookup(_ itemName: String, completion: @escaping (InstantMarketData) -> Void) {
        // Simulated rapid market lookup
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let marketData = InstantMarketData(
                averagePrice: 42.50,
                recentSales: [38.99, 45.00, 41.50, 44.99, 39.95],
                competitorCount: 127,
                demandLevel: "High",
                trend: "Increasing 12% this month",
                seasonalFactors: "Peak demand Nov-Jan"
            )
            completion(marketData)
        }
    }
    
    private func calculateProfitPotential(_ identification: QuickIdentification, market: InstantMarketData, askingPrice: Double, completion: @escaping (ProfitPotential) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let fees = market.averagePrice * 0.1325 + 8.50 + 0.30 // eBay fees + shipping + listing
            let netSalePrice = market.averagePrice - fees
            let potentialProfit = netSalePrice - askingPrice
            let roi = askingPrice > 0 ? (potentialProfit / askingPrice) * 100 : 0
            let maxPayPrice = netSalePrice * 0.6 // 40% margin target
            
            let profitPotential = ProfitPotential(
                potentialProfit: potentialProfit,
                expectedROI: roi,
                maxPayPrice: maxPayPrice,
                sellTimeEstimate: market.demandLevel == "High" ? "3-7 days" : "7-14 days"
            )
            completion(profitPotential)
        }
    }
    
    private func generateBuyAvoidRecommendation(identification: QuickIdentification, market: InstantMarketData, profit: ProfitPotential, askingPrice: Double) -> ProspectRecommendation {
        
        var reasons: [String] = []
        var decision: ProspectDecision = .investigate
        var riskLevel = "Medium"
        var sourcingTips: [String] = []
        
        // Decision Logic
        if profit.expectedROI >= 100 && profit.potentialProfit >= 15 {
            decision = .buy
            riskLevel = "Low"
            reasons.append("🔥 Excellent ROI: \(String(format: "%.1f", profit.expectedROI))%")
            reasons.append("💰 Strong profit potential: $\(String(format: "%.2f", profit.potentialProfit))")
            sourcingTips.append("✅ BUY NOW - This is a winner!")
            sourcingTips.append("📦 List quickly to capitalize on demand")
        } else if profit.expectedROI >= 50 && profit.potentialProfit >= 8 {
            decision = .buy
            riskLevel = "Low-Medium"
            reasons.append("✅ Good ROI: \(String(format: "%.1f", profit.expectedROI))%")
            reasons.append("💵 Decent profit: $\(String(format: "%.2f", profit.potentialProfit))")
            sourcingTips.append("👍 Solid buy for steady profit")
            sourcingTips.append("⏰ List within 24 hours")
        } else if profit.expectedROI >= 25 && profit.potentialProfit >= 5 {
            decision = .investigate
            riskLevel = "Medium"
            reasons.append("⚠️ Marginal ROI: \(String(format: "%.1f", profit.expectedROI))%")
            reasons.append("💭 Small profit: $\(String(format: "%.2f", profit.potentialProfit))")
            sourcingTips.append("🤔 Consider if you have time for small profits")
            sourcingTips.append("💬 Try negotiating price down")
        } else {
            decision = .avoid
            riskLevel = "High"
            reasons.append("❌ Poor ROI: \(String(format: "%.1f", profit.expectedROI))%")
            reasons.append("💸 Potential loss: $\(String(format: "%.2f", abs(profit.potentialProfit)))")
            sourcingTips.append("🚫 AVOID - Not profitable at this price")
            sourcingTips.append("🔍 Look for similar items at lower prices")
        }
        
        // Market condition factors
        if market.competitorCount > 300 {
            reasons.append("⚠️ High competition: \(market.competitorCount) active listings")
            riskLevel = riskLevel == "Low" ? "Medium" : "High"
        }
        
        if market.demandLevel == "Low" {
            reasons.append("📉 Low demand - slow sales expected")
            riskLevel = riskLevel == "Low" ? "Medium" : "High"
        } else if market.demandLevel == "High" {
            reasons.append("🔥 High demand - fast sales likely")
        }
        
        if market.trend.contains("Decreasing") {
            reasons.append("📉 Declining prices - act fast or avoid")
            if decision == .buy {
                sourcingTips.append("⚡ List immediately due to declining prices")
            }
        }
        
        return ProspectRecommendation(
            decision: decision,
            reasons: reasons,
            riskLevel: riskLevel,
            sourcingTips: sourcingTips
        )
    }
}

// MARK: - Business Intelligence Components
struct EmpireStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ActionButton: View {
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
    }
}

struct QuickInsightsPanel: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("⚡ QUICK INSIGHTS")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                InsightCard(
                    title: "Best Category",
                    value: getBestCategory(),
                    color: .green
                )
                
                InsightCard(
                    title: "Avg. Time to Sell",
                    value: "12 days",
                    color: .blue
                )
                
                InsightCard(
                    title: "Success Rate",
                    value: "\(getSuccessRate())%",
                    color: .purple
                )
                
                InsightCard(
                    title: "Next Goal",
                    value: "$\(getNextGoal())",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func getBestCategory() -> String {
        // Calculate best performing category
        let categories = Dictionary(grouping: inventoryManager.items, by: { $0.category })
        let categoryROI = categories.mapValues { items in
            items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
        }
        return categoryROI.max(by: { $0.value < $1.value })?.key ?? "Electronics"
    }
    
    private func getSuccessRate() -> Int {
        let sold = inventoryManager.soldItems
        let total = inventoryManager.items.count
        return total > 0 ? Int(Double(sold) / Double(total) * 100) : 0
    }
    
    private func getNextGoal() -> String {
        let current = Int(inventoryManager.totalEstimatedValue)
        let nextMilestone = ((current / 1000) + 1) * 1000
        return String(nextMilestone)
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PerformanceTrendsView: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📊 PERFORMANCE TRENDS")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TrendRow(
                    title: "Monthly Revenue",
                    value: "$\(String(format: "%.0f", getMonthlyRevenue()))",
                    trend: "+23%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Avg. ROI",
                    value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                    trend: "+8%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Items Listed",
                    value: "\(inventoryManager.listedItems)",
                    trend: "+15%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Inventory Value",
                    value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                    trend: "+31%",
                    isPositive: true
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func getMonthlyRevenue() -> Double {
        // Calculate estimated monthly revenue
        return inventoryManager.totalProfit * 1.2 // Simulate growth
    }
}

struct TrendRow: View {
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
            
            Text(trend)
                .font(.caption)
                .foregroundColor(isPositive ? .green : .red)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(6)
        }
    }
}

struct EnhancedRecentItemCard: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(item.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.estimatedROI > 100 {
                        Text("🔥 Hot Deal")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(8)
                
                if item.estimatedProfit > 0 {
                    Text("$\(String(format: "%.0f", item.estimatedProfit))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Prospecting Data Models
struct ProspectAnalysis {
    let itemName: String
    let brand: String
    let condition: String
    let confidence: Double
    let askingPrice: Double
    let estimatedValue: Double
    let maxPayPrice: Double
    let potentialProfit: Double
    let expectedROI: Double
    let recommendation: ProspectDecision
    let reasons: [String]
    let riskLevel: String
    let demandLevel: String
    let competitorCount: Int
    let marketTrend: String
    let sellTimeEstimate: String
    let seasonalFactors: String
    let sourcingTips: [String]
    let images: [UIImage]
}

enum ProspectDecision {
    case buy, investigate, avoid
    
    var emoji: String {
        switch self {
        case .buy: return "✅"
        case .investigate: return "🤔"
        case .avoid: return "❌"
        }
    }
    
    var title: String {
        switch self {
        case .buy: return "BUY NOW"
        case .investigate: return "INVESTIGATE"
        case .avoid: return "AVOID"
        }
    }
    
    var color: Color {
        switch self {
        case .buy: return .green
        case .investigate: return .orange
        case .avoid: return .red
        }
    }
}

struct QuickIdentification {
    let itemName: String
    let brand: String
    let condition: String
    let confidence: Double
}

struct InstantMarketData {
    let averagePrice: Double
    let recentSales: [Double]
    let competitorCount: Int
    let demandLevel: String
    let trend: String
    let seasonalFactors: String
}

struct ProfitPotential {
    let potentialProfit: Double
    let expectedROI: Double
    let maxPayPrice: Double
    let sellTimeEstimate: String
}

struct ProspectRecommendation {
    let decision: ProspectDecision
    let reasons: [String]
    let riskLevel: String
    let sourcingTips: [String]
}

// MARK: - Prospecting UI Components
struct ProspectingStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ProspectPhotoPreview: View {
    @Binding var images: [UIImage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📸 Captured Photos (\(images.count))")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ProspectAnalysisResultView: View {
    let analysis: ProspectAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Decision Header
            VStack(spacing: 12) {
                HStack {
                    Text(analysis.recommendation.emoji)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.recommendation.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.recommendation.color)
                        
                        Text("Risk: \(analysis.riskLevel)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ROI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", analysis.expectedROI))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.expectedROI > 100 ? .green : analysis.expectedROI > 50 ? .orange : .red)
                    }
                }
                
                // Profit Summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Potential Profit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", analysis.potentialProfit))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.potentialProfit > 0 ? .green : .red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Max Pay Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", analysis.maxPayPrice))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(analysis.recommendation.color.opacity(0.1))
                    .stroke(analysis.recommendation.color.opacity(0.3), lineWidth: 2)
            )
            
            // Detailed Analysis Cards
            VStack(spacing: 15) {
                // Market Intelligence Card
                AnalysisCard(
                    title: "📊 Market Intelligence",
                    content: [
                        ("Estimated Value", "$\(String(format: "%.2f", analysis.estimatedValue))"),
                        ("Competition", "\(analysis.competitorCount) active listings"),
                        ("Demand Level", analysis.demandLevel),
                        ("Market Trend", analysis.marketTrend),
                        ("Sell Time", analysis.sellTimeEstimate)
                    ],
                    color: .blue
                )
                
                // Decision Reasons Card
                AnalysisCard(
                    title: "🎯 Analysis Reasons",
                    items: analysis.reasons,
                    color: .purple
                )
                
                // Sourcing Tips Card
                AnalysisCard(
                    title: "💡 Pro Sourcing Tips",
                    items: analysis.sourcingTips,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
    }
}

struct AnalysisCard: View {
    let title: String
    var content: [(String, String)]?
    var items: [String]?
    let color: Color
    
    init(title: String, content: [(String, String)], color: Color) {
        self.title = title
        self.content = content
        self.items = nil
        self.color = color
    }
    
    init(title: String, items: [String], color: Color) {
        self.title = title
        self.content = nil
        self.items = items
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let content = content {
                VStack(spacing: 8) {
                    ForEach(content, id: \.0) { item in
                        HStack {
                            Text(item.0)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(item.1)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            if let items = items {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        Text("• \(item)")
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProspectingProTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🔥 Pro Prospecting Tips")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                ProTipRow(
                    icon: "🎯",
                    title: "Target High ROI",
                    description: "Look for 100%+ ROI opportunities"
                )
                
                ProTipRow(
                    icon: "⚡",
                    title: "Speed Matters",
                    description: "Analyze quickly - good deals don't last"
                )
                
                ProTipRow(
                    icon: "📱",
                    title: "Use Barcode Scanner",
                    description: "Books, media, and retail items have UPCs"
                )
                
                ProTipRow(
                    icon: "🔍",
                    title: "Check Completeness",
                    description: "Missing parts = much lower value"
                )
                
                ProTipRow(
                    icon: "📅",
                    title: "Seasonal Timing",
                    description: "Some items peak at certain times"
                )
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ProTipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Additional Empire Views (Condensed for space)
struct UltimatePortfolioTrackingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📈 EMPIRE PORTFOLIO TRACKING")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    // Add advanced portfolio content here
                    Text("Advanced portfolio tracking coming soon!")
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct BusinessIntelligenceView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🧠 BUSINESS INTELLIGENCE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("AI-powered business insights coming soon!")
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ProfitOptimizerView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("💰 PROFIT OPTIMIZER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Profit optimization engine coming soon!")
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Image Picker for Multiple Photos
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var allowsMultipleSelection: Bool = false
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Barcode Scanner
struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func didScanBarcode(_ code: String) {
            parent.scannedCode = code
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

protocol ScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class ScannerViewController: UIViewController {
    weak var delegate: ScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce]
        } else {
            print("Could not add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addScannerOverlay()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func addScannerOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let scanRect = CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 200)
        let scanRectPath = UIBezierPath(rect: scanRect)
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        overlayPath.append(scanRectPath.reversing())
        
        let overlayLayer = CAShapeLayer()
        overlayLayer.path = overlayPath.cgPath
        overlayLayer.fillRule = .evenOdd
        overlayView.layer.addSublayer(overlayLayer)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "📱 Scan barcode for instant profit analysis"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(x: 20, y: scanRect.maxY + 20, width: view.bounds.width - 40, height: 30)
        overlayView.addSubview(instructionLabel)
        
        view.addSubview(overlayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.didScanBarcode(stringValue)
        }
    }
}

// MARK: - SINGLE UNIFIED HAPTIC FUNCTION (NO DUPLICATES!)
func empireHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impactFeedback = UIImpactFeedbackGenerator(style: style)
    impactFeedback.impactOccurred()
}

extension UIImpactFeedbackGenerator.FeedbackStyle {
    static let success = UIImpactFeedbackGenerator.FeedbackStyle.heavy
}

// MARK: - Enhanced Inventory View with Auto-Listing
struct InventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @State private var searchText = ""
    @State private var filterStatus: ItemStatus?
    @State private var showingFilters = false
    @State private var showingBarcodeScanner = false
    @State private var scannedBarcode: String?
    @State private var selectedItem: InventoryItem?
    @State private var showingAutoListing = false
    
    var filteredItems: [InventoryItem] {
        inventoryManager.items
            .filter { item in
                if let status = filterStatus {
                    return item.status == status
                }
                return true
            }
            .filter { item in
                if searchText.isEmpty {
                    return true
                }
                return item.name.localizedCaseInsensitiveContains(searchText) ||
                       item.source.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Enhanced Search Bar with Barcode Scanner
                HStack {
                    SearchBar(text: $searchText)
                    
                    Button(action: {
                        empireHaptic(.light)
                        showingBarcodeScanner = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                    }
                }
                
                List {
                    ForEach(filteredItems) { item in
                        EnhancedInventoryItemRow(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                            googleSheetsService.updateItem(updatedItem)
                        } onAutoList: { item in
                            selectedItem = item
                            showingAutoListing = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All Items") {
                            empireHaptic(.light)
                            filterStatus = nil
                        }
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Button(status.rawValue) {
                                empireHaptic(.light)
                                filterStatus = status
                            }
                        }
                        Divider()
                        Button("📊 Export to CSV") {
                            empireHaptic(.medium)
                            exportToCSV()
                        }
                        Button("🔄 Sync to Google Sheets") {
                            empireHaptic(.medium)
                            googleSheetsService.syncAllItems(inventoryManager.items)
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        lookupProduct(barcode: barcode)
                    }
                }
        }
        .sheet(isPresented: $showingAutoListing) {
            if let item = selectedItem {
                AutoListingView(item: item)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        empireHaptic(.medium)
        inventoryManager.deleteItems(at: offsets, from: filteredItems)
    }
    
    private func exportToCSV() {
        let csv = inventoryManager.exportCSV()
        print("📄 CSV Export: \(csv.prefix(200))...")
    }
    
    private func lookupProduct(barcode: String) {
        empireHaptic(.success)
        print("🔍 Looking up barcode: \(barcode)")
    }
}

// MARK: - Enhanced Inventory Item Row
struct EnhancedInventoryItemRow: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    let onAutoList: (InventoryItem) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(item.source) • $\(String(format: "%.2f", item.purchasePrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if item.profit > 0 {
                    Text("Profit: $\(String(format: "%.2f", item.profit)) (\(String(format: "%.1f", item.roi))%)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                // Auto-List Button
                Button(action: {
                    empireHaptic(.light)
                    onAutoList(item)
                }) {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("#\(item.itemNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            empireHaptic(.light)
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            ItemDetailView(item: item, onUpdate: onUpdate)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search items...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - Auto-Listing View
struct AutoListingView: View {
    let item: InventoryItem
    @State private var generatedListing = ""
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🚀 Auto-Generated eBay Listing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ItemPreviewCard(item: item)
                    
                    if generatedListing.isEmpty {
                        Button(action: {
                            empireHaptic(.medium)
                            generateListing()
                        }) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("🤖 Generate Complete eBay Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        .disabled(isGenerating)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📝 Generated eBay Listing")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ScrollView {
                                Text(generatedListing)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .frame(maxHeight: 300)
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    empireHaptic(.light)
                                    showingEditSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    empireHaptic(.medium)
                                    showingShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share/Send")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                empireHaptic(.light)
                                copyToClipboard()
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("📋 Copy to Clipboard")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generatedListing])
        }
        .sheet(isPresented: $showingEditSheet) {
            ListingEditView(listing: $generatedListing)
        }
    }
    
    private func generateListing() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            generatedListing = generateEbayListing(for: item)
        }
    }
    
    private func generateEbayListing(for item: InventoryItem) -> String {
        return """
        🔥 \(item.title) 🔥
        
        ⭐ CONDITION: \(item.condition) - \(item.description)
        
        📦 FAST SHIPPING:
        • Same or next business day shipping
        • Carefully packaged with tracking
        • 30-day return policy
        
        💎 ITEM DETAILS:
        • Category: \(item.category)
        • Keywords: \(item.keywords.joined(separator: ", "))
        • Authentic & Verified
        
        🎯 WHY BUY FROM US:
        ✅ Top-rated seller
        ✅ 100% authentic items
        ✅ Fast & secure shipping
        ✅ Excellent customer service
        
        📱 QUESTIONS? Message us anytime!
        
        🔍 Search terms: \(item.keywords.joined(separator: " "))
        
        #\(item.keywords.joined(separator: " #"))
        
        Starting bid: $\(String(format: "%.2f", item.suggestedPrice * 0.7))
        Buy It Now: $\(String(format: "%.2f", item.suggestedPrice))
        
        Thank you for shopping with us! 🙏
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
    }
}

// MARK: - Item Preview Card
struct ItemPreviewCard: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Price:")
                    Spacer()
                    Text(String(format: "$%.2f", item.suggestedPrice))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Condition:")
                    Spacer()
                    Text(item.condition)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Listing Edit View
struct ListingEditView: View {
    @Binding var listing: String
    @Environment(\.presentationMode) var presentationMode
    @State private var editedListing: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("✏️ Edit Your Listing")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                TextEditor(text: $editedListing)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                
                Button(action: {
                    empireHaptic(.medium)
                    listing = editedListing
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("💾 Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            editedListing = listing
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Item Detail View
struct ItemDetailView: View {
    @State var item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCopyAlert = false
    @State private var copiedText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Photo") {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }
                }
                
                Section("eBay Listing") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.title)
                        
                        Button("📋 Copy Title") {
                            empireHaptic(.light)
                            UIPasteboard.general.string = item.title
                            copiedText = "Title copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.description)
                        
                        Button("📋 Copy Description") {
                            empireHaptic(.light)
                            UIPasteboard.general.string = item.description
                            copiedText = "Description copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Keywords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.keywords.joined(separator: ", "))
                        
                        Button("📋 Copy Keywords") {
                            empireHaptic(.light)
                            UIPasteboard.general.string = item.keywords.joined(separator: ", ")
                            copiedText = "Keywords copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section("Status & Pricing") {
                    Picker("Status", selection: $item.status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    if item.status == .sold {
                        HStack {
                            Text("Sale Price")
                            TextField("0.00", value: $item.actualPrice, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                
                Section("Financial Details") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text(String(format: "$%.2f", item.purchasePrice))
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text(String(format: "$%.2f", item.suggestedPrice))
                    }
                    
                    if item.profit > 0 {
                        HStack {
                            Text("Profit")
                            Spacer()
                            Text(String(format: "$%.2f", item.profit))
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("ROI")
                            Spacer()
                            Text(String(format: "%.1f%%", item.roi))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Item #\(item.itemNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        empireHaptic(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        empireHaptic(.medium)
                        onUpdate(item)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Copied!", isPresented: $showingCopyAlert) {
            Button("OK") { }
        } message: {
            Text(copiedText)
        }
    }
}

// MARK: - Supporting View Components
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 80)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct FinancialCard: View {
    let title: String
    let amount: Double
    let color: Color
    let isPercentage: Bool
    
    init(title: String, amount: Double, color: Color, isPercentage: Bool = false) {
        self.title = title
        self.amount = amount
        self.color = color
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if isPercentage {
                    Text("\(amount, specifier: "%.1f")%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                } else {
                    Text("$\(amount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            Spacer()
            
            Image(systemName: getIconName())
                .font(.largeTitle)
                .foregroundColor(color.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    private func getIconName() -> String {
        switch title {
        case "Total Investment":
            return "dollarsign.circle"
        case "Total Profit":
            return "chart.line.uptrend.xyaxis"
        case "Average ROI":
            return "percent"
        default:
            return "chart.bar"
        }
    }
}
