import SwiftUI

struct CalendarView: View {
    let startDate: Date
    let endDate: Date

    @State private var selectedDate: Date

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        _selectedDate = State(initialValue: startDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Availability Calendar")
                .font(.headline)
                .foregroundColor(.secondary)

            DatePicker(
                "",
                selection: $selectedDate,
                in: startDate...endDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .disabled(true)
            .frame(maxHeight: 350)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }
}

