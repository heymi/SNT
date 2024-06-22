import Foundation

func formatDateString(for text: String) -> Date {
    let calendar = Calendar.current
    let today = Date()
    var resultDate: Date?
    
    switch text {
    case "今天":
        resultDate = today
    case "明天":
        resultDate = calendar.date(byAdding: .day, value: 1, to: today)
    case "后天":
        resultDate = calendar.date(byAdding: .day, value: 2, to: today)
    case "大后天":
        resultDate = calendar.date(byAdding: .day, value: 3, to: today)
    case "下周":
        resultDate = calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime)
    case "下个月":
        resultDate = calendar.date(byAdding: .month, value: 1, to: today)
    case "明年":
        resultDate = calendar.date(byAdding: .year, value: 1, to: today)
    default:
        if text.starts(with: "下周") {
            let weekday = weekdayIndex(for: text)
            resultDate = calendar.nextDate(after: today, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTime)
        } else if text.starts(with: "周") {
            let weekday = weekdayIndex(for: text)
            if calendar.component(.weekday, from: today) < weekday {
                resultDate = calendar.nextDate(after: today, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTimePreservingSmallerComponents)
            } else {
                resultDate = calendar.date(byAdding: .weekOfYear, value: 1, to: today)
                resultDate = calendar.nextDate(after: resultDate!, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTimePreservingSmallerComponents)
            }
        } else if text == "下周日" {
            // 解决下周日的特殊处理方法：使用下周六的日期加1天
            if let nextSaturday = calendar.nextDate(after: today, matching: DateComponents(weekday: 7), matchingPolicy: .nextTime) {
                resultDate = calendar.date(byAdding: .day, value: 1, to: nextSaturday)
            }
        } else {
            resultDate = today
        }
    }
    
    if let result = resultDate {
        print("Keyword: \(text), Calculated Date: \(result)")
    } else {
        print("Keyword: \(text), Calculated Date: Calculation failed, defaulting to today")
    }
    
    return resultDate ?? today
}

func weekdayIndex(for text: String) -> Int {
    switch text {
    case "周一", "下周一": return 2
    case "周二", "下周二": return 3
    case "周三", "下周三": return 4
    case "周四", "下周四": return 5
    case "周五", "下周五": return 6
    case "周六", "下周六": return 7
    case "周日", "下周日": return 1
    default: return 2
    }
}

func extractTasks(from text: String) -> [TodoItem] {
    var tasks = [TodoItem]()
    let futureTimeKeywords = ["今天", "明天", "后天", "大后天", "下周", "下个月", "明年",
                              "周一", "周二", "周三", "周四", "周五", "周六", "周日",
                              "下周一", "下周二", "下周三", "下周四", "下周五", "下周六", "下周日",
                              "周末", "下周末"]

    let sentences = text.split { [".", "。", "!", "！"].contains($0) }.map { String($0) }
    
    for sentence in sentences {
        var lastKeywordRange: Range<String.Index>?

        for keyword in futureTimeKeywords {
            if let range = sentence.range(of: keyword, options: .backwards) {
                lastKeywordRange = range
            }
        }

        if let range = lastKeywordRange {
            let keyword = String(sentence[range])
            let extractedSentence = String(sentence[range.lowerBound...])
            let date = formatDateString(for: keyword)
            tasks.append(TodoItem(text: extractedSentence, timestamp: date))
        }
    }

    return tasks
}

// 测试函数
func testDateCalculations() {
    let testKeywords = [
        "今天", "明天", "后天", "大后天", "下周", "下个月", "明年",
        "周一", "周二", "周三", "周四", "周五", "周六", "周日",
        "下周一", "下周二", "下周三", "下周四", "下周五", "下周六", "下周日"
    ]
    
    for keyword in testKeywords {
        let resultDate = formatDateString(for: keyword)
        print("Keyword: \(keyword), Calculated Date: \(resultDate)")
    }
}
