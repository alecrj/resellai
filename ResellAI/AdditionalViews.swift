import SwiftUI

// MARK: - Item Form View
struct ItemFormView: View {
    let analysis: ItemAnalysis
    let image: UIImage
    let onSave: (InventoryItem) -> Void
    
    @State private var purchasePrice = ""
    @State private var selectedSource = SourceLocation.cityWalk
    @State private var condition = "Good"
    @State private var customTitle = ""
    @State private var customDescription = ""
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Photo") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                }
                
                Section("AI Analysis") {
                    HStack {
                        Text("Item Name:")
                        Spacer()
                        Text(analysis.itemName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Suggested Price:")
                        Spacer()
                        Text("$\(analysis.suggestedPrice, specifier: "%.2f")")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("Category:")
                        Spacer()
                        Text(analysis.category)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Section("Purchase Details") {
                    HStack {
                        Text("Purchase Price ($)")
                        TextField("0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Source", selection: $selectedSource) {
                        ForEach(SourceLocation.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    
                    Picker("Condition", selection: $condition) {
                        Text("New").tag("New")
                        Text("Like New").tag("Like New")
                        Text("Good").tag("Good")
                        Text("Fair").tag("Fair")
                        Text("For Parts").tag("For Parts")
                    }
                }
                
                Section("eBay Listing") {
                    VStack(alignment: .leading) {
                        Text("Title (80 characters)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("eBay Title", text: $customTitle)
                            .onAppear {
                                customTitle = analysis.ebayTitle
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $customDescription)
                            .frame(minHeight: 100)
                            .onAppear {
                                customDescription = analysis.description
                            }
                    }
                }
                
                Section("Profit Calculation") {
                    if let price = Double(purchasePrice) {
                        let suggestedProfit = analysis.suggestedPrice - price - (analysis.suggestedPrice * 0.13)
                        let roi = price > 0 ? (suggestedProfit / price) * 100 : 0
                        
                        HStack {
                            Text("Estimated Profit:")
                            Spacer()
                            Text("$\(suggestedProfit, specifier: "%.2f")")
                                .foregroundColor(suggestedProfit > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("ROI:")
                            Spacer()
                            Text("\(roi, specifier: "%.1f")%")
                                .foregroundColor(roi > 200 ? .green : roi > 100 ? .orange : .red)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(purchasePrice.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        guard let price = Double(purchasePrice) else { return }
        
        let item = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: price,
            suggestedPrice: analysis.suggestedPrice,
            source: selectedSource.rawValue,
            condition: condition,
            title: customTitle,
            description: customDescription,
            keywords: analysis.keywords,
            status: .analyzed,
            dateAdded: Date(),
            imageData: image.jpegData(compressionQuality: 0.8)
        )
        
        onSave(item)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📊 Business Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    // Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StatCard(title: "Total Items", value: "\(inventoryManager.items.count)", color: .blue)
                        StatCard(title: "To List", value: "\(inventoryManager.itemsToList)", color: .red)
                        StatCard(title: "Listed", value: "\(inventoryManager.listedItems)", color: .orange)
                        StatCard(title: "Sold", value: "\(inventoryManager.soldItems)", color: .green)
                    }
                    
                    // Financial Overview
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💰 Financial Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        FinancialCard(
                            title: "Total Investment",
                            amount: inventoryManager.totalInvestment,
                            color: .blue
                        )
                        
                        FinancialCard(
                            title: "Total Profit",
                            amount: inventoryManager.totalProfit,
                            color: .green
                        )
                        
                        FinancialCard(
                            title: "Average ROI",
                            amount: inventoryManager.averageROI,
                            color: .purple,
                            isPercentage: true
                        )
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🕒 Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(inventoryManager.recentItems.prefix(5)) { item in
                            RecentItemCard(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct RecentItemCard: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.source)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                Text("$\(item.purchasePrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Inventory View
struct InventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @State private var searchText = ""
    @State private var filterStatus: ItemStatus?
    @State private var showingFilters = false
    
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
                SearchBar(text: $searchText)
                
                List {
                    ForEach(filteredItems) { item in
                        InventoryItemRow(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                            googleSheetsService.updateItem(updatedItem)
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
                            filterStatus = nil
                        }
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Button(status.rawValue) {
                                filterStatus = status
                            }
                        }
                        Divider()
                        Button("Export to CSV") {
                            exportToCSV()
                        }
                        Button("Sync to Google Sheets") {
                            googleSheetsService.syncAllItems(inventoryManager.items)
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        inventoryManager.deleteItems(at: offsets, from: filteredItems)
    }
    
    private func exportToCSV() {
        // Implementation for CSV export
        print("Exporting to CSV...")
    }
}

struct InventoryItemRow: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
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
                
                Text("\(item.source) • $\(item.purchasePrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if item.profit > 0 {
                    Text("Profit: $\(item.profit, specifier: "%.2f") (\(item.roi, specifier: "%.1f")%)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                Text("#\(item.itemNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            ItemDetailView(item: item, onUpdate: onUpdate)
        }
    }
}

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
                        Text("$\(item.purchasePrice, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text("$\(item.suggestedPrice, specifier: "%.2f")")
                    }
                    
                    if item.profit > 0 {
                        HStack {
                            Text("Profit")
                            Spacer()
                            Text("$\(item.profit, specifier: "%.2f")")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("ROI")
                            Spacer()
                            Text("\(item.roi, specifier: "%.1f")%")
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
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

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    
    var body: some View {
        NavigationView {
            Form {
                Section("AI Configuration") {
                    HStack {
                        Text("OpenAI API Key")
                        Spacer()
                        SecureField("sk-...", text: $aiService.apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Enhanced Analysis", isOn: $aiService.enhancedMode)
                }
                
                Section("Google Sheets Integration") {
                    HStack {
                        Text("Spreadsheet ID")
                        Spacer()
                        TextField("Spreadsheet ID", text: $googleSheetsService.spreadsheetId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Connect Google Account") {
                        googleSheetsService.authenticate()
                    }
                    
                    Button("Test Connection") {
                        googleSheetsService.testConnection()
                    }
                }
                
                Section("Business Settings") {
                    HStack {
                        Text("Default Markup")
                        Spacer()
                        TextField("300%", text: .constant("300%"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Auto-sync to Sheets", isOn: .constant(true))
                    Toggle("Price Alerts", isOn: .constant(true))
                }
                
                Section("Export & Backup") {
                    Button("Export All Data") {
                        // Implementation
                        print("Exporting data...")
                    }
                    
                    Button("Backup to iCloud") {
                        // Implementation
                        print("Backing up to iCloud...")
                    }
                    
                    Button("Reset All Data") {
                        // Implementation
                        print("Resetting data...")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
