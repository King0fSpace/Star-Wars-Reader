//
//  DateFormatters.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/21/23.
//

import Foundation

class DateFormatterUtils {
    // Singleton instance of DateFormatterUtils
    static let shared = DateFormatterUtils()
    
    // Format a date string to the desired output format
    func formatDate(from date: String?) -> String {
        // Date formatter to convert the input string to a Date object
        let inputFormatter = DateFormatter()
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // Date formatter to format the date to the desired output format
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        guard let date = date, let inputDate = inputFormatter.date(from: date) else {
            // If the input date string is nil or cannot be converted to a Date, return an empty string
            return ""
        }
        
        // Format the date to the desired output format and return as string
        return dateFormatter.string(from: inputDate)
    }
}

