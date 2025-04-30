import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var path = NavigationPath()
    
    private var displayName: String {
        authViewModel.user?.displayName ?? "Unknown User"
    }
    private var email: String {
        authViewModel.user?.email ?? ""
    }
    
    private var initials: String {
        let parts = displayName.split(separator: " ")
        let letters = parts.compactMap { $0.first }
        return String(letters).uppercased()
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                // MARK: — Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 60, height: 60)
                            Text(initials)
                                .font(.title2).bold()
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
                
                // MARK: — Settings
                Section("Settings") {
                    NavigationLink {
                        EditProfileView()
                            .environmentObject(authViewModel)
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                }
                
                // MARK: — Danger Zone
                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Account")
        }
    }
}
