import SwiftUI
import Observation

@Observable
class ModelData {
    var privacyMode: Bool = false
    var showAddTransaction: Bool = false
    
    // 示例数据
    var transactions: [Transaction] = []
    
    init() {
        // 初始化一些模拟数据
        self.transactions = [
            Transaction(id: UUID(), amount: 10000, type: .income, category: "工资", date: Date()),
            Transaction(id: UUID(), amount: 25, type: .expense, category: "午餐", date: Date()),
            Transaction(id: UUID(), amount: 11, type: .expense, category: "交通", date: Date())
        ]
    }
}

struct Transaction: Identifiable {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var category: String
    var date: Date
    var note: String = ""
}

enum TransactionType {
    case income
    case expense
}
