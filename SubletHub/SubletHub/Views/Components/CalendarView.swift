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

    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Availability Calendar")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            DatePicker(
                "",
                selection: .constant(startDate),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .disabled(true) // make it readonly
            .frame(maxHeight: 400)

            DatePicker(
                "",
                selection: .constant(endDate),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .disabled(true)
            .frame(maxHeight: 400)
        }
    }
}
