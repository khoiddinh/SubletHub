import SwiftUI

struct CalendarView: View {
    let startDate: Date
    let endDate:   Date

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Availability Calendar")
                .font(.headline)
                .foregroundColor(.secondary)

            DatePicker(
                "",
                selection: .constant(startDate),      // <- constant binding
                in:        startDate...endDate,
                displayedComponents: .date
            )
            .labelsHidden()
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
