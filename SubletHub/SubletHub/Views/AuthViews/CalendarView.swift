import SwiftUI

struct CalendarView: View {
    var startDate: Date
    var endDate: Date

    @State private var selectedDate: Date

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        _selectedDate = State(initialValue: startDate)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Availability Calendar")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            DatePicker(
                "",
                selection: $selectedDate,
                in: startDate...endDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .disabled(true)
            .frame(maxHeight: 400)
            .environment(\.calendar, Calendar(identifier: .gregorian)) // Force Gregorian Calendar
            .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!) // Force UTC TimeZone
        }
    }
}

