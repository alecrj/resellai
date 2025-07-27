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
                        
                        Text("Path to eBay Empire")
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
                    value: "(mock) days",
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
        return categoryROI.max(by: { $0.value < $1.value })?.key ?? "(mock)"
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
                    trend: "+(mock%)",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Avg. ROI",
                    value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                    trend: "+(mock%)",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Items Listed",
                    value: "\(inventoryManager.listedItems)",
                    trend: "+(mock%)",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Inventory Value",
                    value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                    trend: "+(mock%)",
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

// MARK: - Additional Empire Views (Condensed)
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

// MARK: - Barcode Scanner View (FIXED - No Duplicates)
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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
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
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39]
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
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cancelButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        cancelButton.addTarget(self, action: #selector(cancelScanning), for: .touchUpInside)
        overlayView.addSubview(cancelButton)
        
        view.addSubview(overlayView)
    }
    
    @objc private func cancelScanning() {
        dismiss(animated: true)
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

// MARK: - Prospect Analysis Result View (FIXED - No Duplicates)
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
                
                // Key Metrics Row
                HStack {
                    VStack(alignment: .leading) {
                        Text("MAX PAY PRICE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("$\(String(format: "%.2f", analysis.maxPayPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
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
                        Text("Market Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", analysis.estimatedValue))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(analysis.recommendation.color.opacity(0.1))
                    .stroke(analysis.recommendation.color.opacity(0.3), lineWidth: 2)
            )
            
            // Additional content...
            Text("Analysis complete!")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Revolutionary Settings View
struct RevolutionarySettingsView: View {
    @EnvironmentObject var revolutionaryAI: RevolutionaryAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @EnvironmentObject var ebayListingService: DirectEbayListingService
    
    var body: some View {
        NavigationView {
            Form {
                Section("🚀 Revolutionary AI") {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Revolutionary Analysis Engine")
                                .fontWeight(.semibold)
                            Text("Ultra-accurate • Real market data • Computer vision")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Section("🚀 Direct eBay Listing") {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("One-Tap eBay Listing")
                                .fontWeight(.semibold)
                            Text(ebayListingService.isListing ? "Listing in progress..." : "Ready to list")
                                .font(.caption)
                                .foregroundColor(ebayListingService.isListing ? .orange : .green)
                        }
                        Spacer()
                        if ebayListingService.isListing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("📊 Google Sheets") {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Auto-Sync Inventory")
                                .fontWeight(.semibold)
                            Text(googleSheetsService.syncStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if googleSheetsService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("🔥 Revolutionary Features") {
                    FeatureStatusRow(icon: "camera.fill", title: "Multi-Photo Analysis", enabled: true)
                    FeatureStatusRow(icon: "eye.fill", title: "Computer Vision Condition Detection", enabled: true)
                    FeatureStatusRow(icon: "chart.line.uptrend.xyaxis", title: "Real-Time Market Research", enabled: true)
                    FeatureStatusRow(icon: "brain", title: "Ultra-Realistic AI Pricing", enabled: true)
                    FeatureStatusRow(icon: "bolt.fill", title: "Direct eBay Listing", enabled: true)
                    FeatureStatusRow(icon: "magnifyingglass.circle", title: "Prospecting Mode", enabled: true)
                    FeatureStatusRow(icon: "barcode.viewfinder", title: "Barcode Scanner", enabled: true)
                    FeatureStatusRow(icon: "wand.and.stars", title: "Auto-Listing Generator", enabled: true)
                }
            }
            .navigationTitle("Revolutionary Settings")
        }
    }
}

struct FeatureStatusRow: View {
    let icon: String
    let title: String
    let enabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
            Spacer()
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(enabled ? .green : .red)
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
