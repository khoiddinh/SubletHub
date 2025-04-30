import SwiftUI

struct EditListingView: View {
    @EnvironmentObject private var userListingVM: UserListingViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: – Form State
    @State private var title: String
    @State private var price: Double
    @State private var address: String
    @State private var totalBedrooms: Int
    @State private var totalBathrooms: Int
    @State private var squareFootage: Int
    @State private var availableBedrooms: Int
    @State private var descriptionText: String
    @State private var startDate: Date
    @State private var endDate: Date

    @State private var isSaving = false
    @State private var alertMessage: String?
    @State private var showAlert = false


    private let original: Listing

    init(listing: Listing) {
        self.original = listing

        // initialize form state from the passed-in model
        _title             = State(initialValue: listing.title)
        _price             = State(initialValue: listing.price)
        _address           = State(initialValue: listing.address)
        _totalBedrooms     = State(initialValue: listing.totalNumberOfBedrooms)
        _totalBathrooms    = State(initialValue: listing.totalNumberOfBathrooms)
        _squareFootage     = State(initialValue: listing.totalSquareFootage)
        _availableBedrooms = State(initialValue: listing.numberOfBedroomsAvailable)
        _descriptionText   = State(initialValue: listing.description)
        _startDate         = State(initialValue: listing.startDateAvailible)
        _endDate           = State(initialValue: listing.lastDateAvailible)
    }

    // Simple form‐validity check
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && price > 0
        && totalBedrooms >= 0
        && totalBathrooms >= 0
        && squareFootage >= 0
        && availableBedrooms >= 0
        && !address.trimmingCharacters(in: .whitespaces).isEmpty
        && startDate <= endDate
    }

    var body: some View {
        Form {
            Section("Listing Details") {
                TextField("Title", text: $title)

                // Price as currency with zero decimals
                TextField(
                  "Price",
                  value: $price,
                  format: .currency(code: "USD")
                    .precision(.fractionLength(0))
                )
                .keyboardType(.decimalPad)

                TextField("Address", text: $address)
                TextField(
                  "Total Bedrooms",
                  value: $totalBedrooms,
                  format: .number.precision(.integerLength(1))
                )
                .keyboardType(.numberPad)

                TextField(
                  "Total Bathrooms",
                  value: $totalBathrooms,
                  format: .number.precision(.integerLength(1))
                )
                .keyboardType(.numberPad)

                TextField(
                  "Square Footage",
                  value: $squareFootage,
                  format: .number.precision(.integerLength(1))
                )
                .keyboardType(.numberPad)

                TextField(
                  "Bedrooms Available",
                  value: $availableBedrooms,
                  format: .number.precision(.integerLength(1))
                )
                .keyboardType(.numberPad)
            }

            Section("Availability") {
                DatePicker("Start", selection: $startDate, displayedComponents: .date)
                DatePicker("End",   selection: $endDate,   displayedComponents: .date)
            }

            Section("Description") {
                TextEditor(text: $descriptionText)
                  .frame(minHeight: 100)
            }

            Section {
                Button {
                    Task { await saveChanges() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }
                .disabled(!isFormValid || isSaving)
            }
        }
        .navigationTitle("Edit Listing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: { dismiss() })
            }
        }
        .alert("Error", isPresented: $showAlert) {
          Button("OK", role: .cancel) {
            showAlert = false
          }
        } message: {
          Text(alertMessage ?? "")
        }
    }

    /private func saveChanges() {
        guard let uid = authVM.user?.uid else {
            alertMessage = "You must be logged in to edit."
            showAlert = true
            return
        }
        guard let listingID = original.id else {
            alertMessage = "Invalid listing ID."
            showAlert = true
            return
        }

        // 2) Begin saving
        isSaving = true
        alertMessage = nil

        var updated = original
        updated.title                     = title
        updated.price                     = price
        updated.address                   = address
        updated.totalNumberOfBedrooms     = totalBedrooms
        updated.totalNumberOfBathrooms    = totalBathrooms
        updated.totalSquareFootage        = squareFootage
        updated.numberOfBedroomsAvailable = availableBedrooms
        updated.startDateAvailible        = startDate
        updated.lastDateAvailible         = endDate
        updated.description               = descriptionText
        updated.userID                    = uid

        userListingVM.editListing(for: uid, listing: updated) { result in
            DispatchQueue.main.async {
                // Stop the spinner
                isSaving = false

                switch result {
                case .success:
                    // On success, dismiss
                    dismiss()

                case .failure(let error):
                    // On error, show the alert
                    alertMessage = "Failed to save: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

}
