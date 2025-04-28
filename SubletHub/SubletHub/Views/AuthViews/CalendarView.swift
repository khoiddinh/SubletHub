//
//  CalendarView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/26/25.
//
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
        }
    }
}

