//
//  AddressAutocompleteViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import MapKit
import Observation

@Observable
class AddressAutocompleteViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var searchResults: [MKLocalSearchCompletion] = []

    private var completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = [.address]
        completer.delegate = self
    }

    func updateSearch(query: String) {
        completer.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Autocomplete error:", error.localizedDescription)
    }
    
}


extension MKLocalSearchCompletion {
    var uniqueID: String {
        return "\(title)-\(subtitle)"
    }
}
