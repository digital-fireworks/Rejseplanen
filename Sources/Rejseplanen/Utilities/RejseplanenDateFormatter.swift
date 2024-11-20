//
//  RejseplanenDateFormatter.swift
//  
//
//  Created by Fredrik Nannestad on 10/11/2022.
//

import Foundation

internal enum RejseplanenDateFormatterError: Error {
    case timeAndDateFormateError
}

internal class RejseplanenDateFormatter: DateFormatter, @unchecked Sendable {
    
    static let shared = RejseplanenDateFormatter()

    private let rejseplanenDateFormat = "dd.MM.yy"
    private let rejseplanenTimeFormat = "HH:mm"

    func dateFromRejseplanenTime(_ time: String, andDate date: String) throws -> Date {
        self.dateFormat = self.rejseplanenTimeFormat + " " + self.rejseplanenDateFormat
        let string = time + " " + date
        if let date = self.date(from: string) {
            return date
        } else {
            throw RejseplanenDateFormatterError.timeAndDateFormateError
        }
    }

    func dateStringForDate(_ date: Date) -> String {
        self.dateFormat = self.rejseplanenDateFormat
        return self.string(from: date)
    }

    func timeStringForDate(_ date: Date) -> String {
        self.dateFormat = self.rejseplanenTimeFormat
        return self.string(from: date)
    }

}
