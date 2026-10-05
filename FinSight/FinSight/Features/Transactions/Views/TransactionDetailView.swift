import SwiftUI
import MapKit

public struct TransactionDetailView: View {
    let transaction: Transaction
    let viewModel: TransactionListViewModel
    
    @State private var showDeleteConfirmation = false
    
    public init(transaction: Transaction, viewModel: TransactionListViewModel) {
        self.transaction = transaction
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hero Section
                VStack(spacing: 8) {
                    Text(transaction.formattedAmount)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(transaction.isCredit ? Color.App.income : Color.App.expense)
                    
                    Text(transaction.type.displayName)
                        .font(.App.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    
                    Text(transaction.formattedDate)
                        .font(.App.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                .frame(maxWidth: .infinity)
                
                // Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details").sectionHeader()
                    
                    Text(transaction.title)
                        .font(.App.title3)
                    
                    if let desc = transaction.description, !desc.isEmpty {
                        Text(desc)
                            .font(.App.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if !transaction.categories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(transaction.categories, id: \.self) { cat in
                                    Text(cat)
                                        .font(.App.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.App.accentPrimary.opacity(0.1))
                                        .foregroundColor(Color.App.accentPrimary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .cardStyle()
                
                // Note Card
                if let note = transaction.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note").sectionHeader()
                        Text(note)
                            .font(.App.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemYellow).opacity(0.1))
                            .cornerRadius(8)
                    }
                    .cardStyle()
                }
                
                // Location Card
                if let loc = transaction.location {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location").sectionHeader()
                        
                        Map(initialPosition: .region(MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                            Marker(loc.placeName ?? "Location", coordinate: loc.coordinate)
                        }
                        .frame(height: 150)
                        .cornerRadius(8)
                        
                        if let place = loc.placeName {
                            Text(place).font(.App.headline)
                        }
                        if let addr = loc.address {
                            Text(addr).font(.App.subheadline).foregroundColor(.secondary)
                        }
                        
                        Button("Open in Maps") {
                            let url = URL(string: "maps://?q=\(loc.latitude),\(loc.longitude)")!
                            #if canImport(UIKit)
                            UIApplication.shared.open(url)
                            #else
                            NSWorkspace.shared.open(url)
                            #endif
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .cardStyle()
                }
                
                // Items Card
                if !transaction.items.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items").sectionHeader()
                        
                        ForEach(transaction.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.App.body)
                                    Text("\(item.quantity) x \(item.unitPrice?.formattedAsCurrency() ?? "")")
                                        .font(.App.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.displayPrice)
                                    .font(.App.body.weight(.medium))
                            }
                            Divider()
                        }
                        
                        HStack {
                            Text("Subtotal").font(.App.headline)
                            Spacer()
                            Text(transaction.itemsSubtotal.formattedAsCurrency())
                                .font(.App.headline)
                        }
                    }
                    .cardStyle()
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metadata").sectionHeader()
                    HStack { Text("Created:"); Spacer(); Text(transaction.createdAt.formattedDate) }
                    HStack { Text("Source:"); Spacer(); Text(transaction.source.rawValue.capitalized) }
                    HStack { Text("Sync:"); Spacer(); Text(transaction.syncStatus.rawValue.capitalized) }
                }
                .font(.App.caption)
                .foregroundColor(.secondary)
                .cardStyle()
            }
            .padding()
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        // Edit
                    } label: { Label("Edit", systemImage: "pencil") }
                    
                    Button {
                        Task { await viewModel.toggleFlag(transaction) }
                    } label: { Label(transaction.isFlagged ? "Unflag" : "Flag", systemImage: transaction.isFlagged ? "flag.slash" : "flag") }
                    
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: { Label("Delete", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Transaction?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteTransaction(transaction)
                }
            }
        }
    }
}
