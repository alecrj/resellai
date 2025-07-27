//
//  InventoryManager.swift
//  ResellAI
//
//  Created by Alec on 7/26/25.
//

import SwiftUI
import Foundation

// MARK: - Enhanced Inventory Manager with Data Migration
class InventoryManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let itemsKey = "SavedInventoryItems"
    private let migrationKey = "DataMigrationV2_Completed"
    
    init() {
        performDataMigrationIfNeeded()
        loadItems()
    }
    
    // ✅ DATA MIGRATION for fixing old enum values
    private func performDataMigrationIfNeeded() {
        guard !userDefaults.bool(forKey: migrationKey) else {
            print("✅ Data migration already completed")
            return
        }
        
        print("🔄 Performing data migration...")
        
        // Clear old corrupted data
        userDefaults.removeObject(forKey: itemsKey)
        
        // Mark migration as completed
        userDefaults.set(true, forKey: migrationKey)
        
        print("✅ Data migration completed - fresh start!")
    }
    
    // MARK: - Computed Properties
    var nextItemNumber: Int {
        (items.map { $0.itemNumber }.max() ?? 0) + 1
    }
    
    var itemsToList: Int {
        items.filter { $0.status == .toList }.count
    }
    
    var listedItems: Int {
        items.filter { $0.status == .listed }.count
    }
    
    var soldItems: Int {
        items.filter { $0.status == .sold }.count
    }
    
    var totalInvestment: Double {
        items.reduce(0) { $0 + $1.purchasePrice }
    }
    
    var totalProfit: Double {
        items.filter { $0.status == .sold }.reduce(0) { $0 + $1.profit }
    }
    
    var totalEstimatedValue: Double {
        items.reduce(0) { $0 + $1.suggestedPrice }
    }
    
    var averageROI: Double {
        let soldItems = items.filter { $0.status == .sold && $0.roi > 0 }
        guard !soldItems.isEmpty else { return 0 }
        return soldItems.reduce(0) { $0 + $1.roi } / Double(soldItems.count)
    }
    
    var recentItems: [InventoryItem] {
        items.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    // MARK: - CRUD Operations
    func addItem(_ item: InventoryItem) {
        items.append(item)
        saveItems()
        print("✅ Added item: \(item.name)")
    }
    
    func updateItem(_ updatedItem: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveItems()
            print("✅ Updated item: \(updatedItem.name)")
        }
    }
    
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
        print("🗑️ Deleted item: \(item.name)")
    }
    
    func deleteItems(at offsets: IndexSet, from filteredItems: [InventoryItem]) {
        for offset in offsets {
            let itemToDelete = filteredItems[offset]
            deleteItem(itemToDelete)
        }
    }
    
    // MARK: - Data Persistence with Error Handling
    private func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: itemsKey)
            print("💾 Saved \(items.count) items to UserDefaults")
        } catch {
            print("❌ Error saving items: \(error)")
        }
    }
    
    private func loadItems() {
        guard let data = userDefaults.data(forKey: itemsKey) else {
            print("📱 No saved items found - starting fresh")
            return
        }
        
        do {
            items = try JSONDecoder().decode([InventoryItem].self, from: data)
            print("📂 Loaded \(items.count) items from UserDefaults")
        } catch {
            print("❌ Error loading items: \(error)")
            print("🔄 Clearing corrupted data and starting fresh")
            userDefaults.removeObject(forKey: itemsKey)
            items = []
        }
    }
    
    // MARK: - Utility Functions
    func exportCSV() -> String {
        var csv = "Item#,Name,Source,Cost,Suggested$,Status,Profit,ROI%,Date,Title,Description,Keywords,Condition,Category,Barcode\n"
        
        for item in items {
            let row = [
                "\(item.itemNumber)",
                csvEscape(item.name),
                csvEscape(item.source),
                "\(item.purchasePrice)",
                "\(item.suggestedPrice)",
                csvEscape(item.status.rawValue),
                "\(item.estimatedProfit)",
                "\(item.estimatedROI)",
                formatDate(item.dateAdded),
                csvEscape(item.title),
                csvEscape(item.description),
                csvEscape(item.keywords.joined(separator: "; ")),
                csvEscape(item.condition),
                csvEscape(item.category),
                csvEscape(item.barcode ?? "")  // ✅ NEW: Barcode support
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    private func csvEscape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Statistics
    func getStatistics() -> InventoryStatistics {
        let totalItems = items.count
        let listedCount = listedItems
        let soldCount = soldItems
        let investment = totalInvestment
        let profit = totalProfit
        let avgROI = averageROI
        
        return InventoryStatistics(
            totalItems: totalItems,
            listedItems: listedCount,
            soldItems: soldCount,
            totalInvestment: investment,
            totalProfit: profit,
            averageROI: avgROI,
            estimatedValue: totalEstimatedValue
        )
    }
    
    // ✅ NEW: Category Analytics for Clothes/Shoes
    func getCategoryBreakdown() -> [String: Int] {
        let categories = Dictionary(grouping: items, by: { $0.category })
        return categories.mapValues { $0.count }
    }
    
    func getBestPerformingBrands() -> [String: Double] {
        let brands = Dictionary(grouping: items.filter { !$0.brand.isEmpty }, by: { $0.brand })
        return brands.mapValues { items in
            items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
        }
    }
}

// MARK: - Enhanced Statistics Model
struct InventoryStatistics {
    let totalItems: Int
    let listedItems: Int
    let soldItems: Int
    let totalInvestment: Double
    let totalProfit: Double
    let averageROI: Double
    let estimatedValue: Double
    
    var potentialProfit: Double {
        estimatedValue - totalInvestment - (estimatedValue * 0.13) // Minus fees
    }
    
    var successRate: Double {
        guard totalItems > 0 else { return 0 }
        return Double(soldItems) / Double(totalItems) * 100
    }
    
    var profitMargin: Double {
        guard totalInvestment > 0 else { return 0 }
        return (totalProfit / totalInvestment) * 100
    }
}
