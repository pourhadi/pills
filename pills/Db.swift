//
//  Db.swift
//  pills
//
//  Created by dan on 10/8/19.
//  Copyright © 2019 dan. All rights reserved.
//

import Foundation
import GRDB
import UIKit
import SwiftDate
import CloudKit
import Combine

class DB: ObservableObject {
    @Published var all: [Pill]
    
    init(all: [Pill]) {
        self.all = all
        
    }
    
    func refresh() {}
    
    func delete(indexes: IndexSet) {
        
    }
    
    func delete(pill: Pill) {}
    
    func add(date: Date) {}
}

class DummyDb: DB {
    
    convenience init() {
        self.init(all: [Pill(), Pill()])
    }
}

class CloudDb: DB {
    
    static let instance = CloudDb(all: [])
    
    let db = CKContainer(identifier: "iCloud.com.pourhadi.pills").privateCloudDatabase
    
    func getAll() -> Future<[Pill], Error> {
        return Future<[Pill], Error> { (block) in
            let q = CKQuery(recordType: "Pill", predicate: NSPredicate(format: "takenAt >= %@", argumentArray: [Date().addingTimeInterval(-(60 * 60 * 24 * 5))]))
            self.db.perform(q, inZoneWith: nil) { (records, error) in
                if let records = records {
                    let mapped = records.map({ Pill(takenAt: $0["takenAt"] as! Date, recordName: $0.recordID.recordName) }).sorted { (lhs, rhs) -> Bool in
                        return lhs.takenAt > rhs.takenAt
                    }
                    block(Result.success(mapped))
                } else if let error = error {
                    block(Result.failure(error))
                }
            }
        }
    }
    
    private var getAllCancellable: AnyCancellable?
    override func refresh() {
        print("refresh")
        getAllCancellable?.cancel()
        getAllCancellable = getAll().receive(on: DispatchQueue.main).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print(error)
            default: break
            }
        }) { (value) in
            self.all = value
        }
    }
    
    override func add(date: Date) {
        let newId = CKRecord.ID(recordName: "\(date.timeIntervalSince1970)")
        let record = CKRecord(recordType: "Pill", recordID: newId)
        record["takenAt"] = date
        
        let pill = Pill(takenAt: date, recordName: newId.recordName)
        var all = self.all
        all.insert(pill, at: 0)
        self.all = all.sorted { (lhs, rhs) -> Bool in
            return lhs.takenAt > rhs.takenAt
        }
        
        db.save(record) { (_, error) in
            if let error = error {
                print(error)
            }
        }
        
        Notifications.reschedule()
    }
    
    func pillTaken() {
        let date = Date()
        add(date: date)
    }
    
    override func delete(indexes: IndexSet) {
        indexes.forEach { index in
            let pill = self.all[index]
            self.all.remove(at: index)
            self.db.delete(withRecordID: CKRecord.ID(recordName: pill.recordName), completionHandler: { (id, error) in
            })
        }
    }
    
    override func delete(pill: Pill) {
        self.all.removeAll { $0.recordName == pill.recordName }
        
        self.db.delete(withRecordID: CKRecord.ID(recordName: pill.recordName), completionHandler: { (id, error) in

        })
    }
}

//class Db {
//    static var customDatabaseURL: URL? = nil
//
//    static var dbUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pourhadi.pillstaken")!
//        .appendingPathComponent("db.sqlite")
//    static var dbPool: DatabasePool = createDbPool()
//
//    public static func createDbPool() -> DatabasePool {
//        let databaseURL = customDatabaseURL ?? (dbUrl)
//
//        var config = Configuration()
//        if customDatabaseURL != nil {
//            config.readonly = true
//        }
//        let pool = try! DatabasePool(path: databaseURL.path, configuration: config)
////        #if os(iOS)
////        pool.setupMemoryManagement(in: UIApplication.shared)
////        #endif
//        try! migrator.migrate(pool)
//
//        return pool
//    }
//
//    static var migrator: DatabaseMigrator {
//        var migrator = DatabaseMigrator()
//
//        migrator.registerMigration("schema") { db in
//            // Create a table
//            // See https://github.com/groue/GRDB.swift#create-tables
//            try db.create(table: "pill") { t in
//                // An integer primary key auto-generates unique IDs
//                t.column("takenAt", .datetime).primaryKey()
//
//            }
//
//            try Pill(takenAt: Date()).insert(db)
//        }
//
//        return migrator
//    }
//
//    static func getAll() -> [Pill] {
//        return (try? dbPool.read { (db) -> [Pill] in
//            try! Pill.limit(100).fetchAll(db).sorted(by: { (lhs, rhs) -> Bool in
//                return lhs.takenAt > rhs.takenAt
//            })
//        }) ?? []
//    }
//
//    static func getToday() -> [Date] {
//        return (try? dbPool.read { (db) -> [Pill] in
//            try! Pill.fetchAll(db).filter { $0.takenAt.in(region: Region.local).isToday }.sorted(by: { (lhs, rhs) -> Bool in
//                return lhs.takenAt < rhs.takenAt
//            })
//        }.map { $0.takenAt }) ?? [Date()]
//    }
//
//    static func pillTaken() {
//        try? dbPool.write { db in
//            try Pill(takenAt: Date()).insert(db)
//        }
//    }
//
//
//}


struct Pill: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Double {
        return self.takenAt.timeIntervalSince1970
    }
    
    
    let takenAt: Date
    
    let recordName: String
    
    init(takenAt: Date, recordName: String) {
        self.takenAt = takenAt
        self.recordName = recordName
    }
    
    init() {
        self.takenAt = Date()
        self.recordName = ""
    }
    
}

