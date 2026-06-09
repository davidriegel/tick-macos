//
//  TokenListView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenListView: View {
    @Environment(TokenStore.self) private var tokenStore
    @State private var showingMigrationHelp = false
    @State private var showingAdd = false
    @State private var tokenToDelete: OTPToken?
    @State private var tokenToEdit: OTPToken?
    @State private var migrationResult: MigrationResult?
    
    struct MigrationResult: Identifiable {
        let id = UUID()
        let added: Int
        let skipped: Int
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if tokenStore.tokens.isEmpty {
                    emptyState
                } else {
                    tokenList
                }
            }
            .toolbar {
                Button(.tokenlistviewToolbarAdd, systemImage: "plus") {
                    showingAdd = true
                }
                .keyboardShortcut(KeyboardShortcut(KeyEquivalent("n")))
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddTokenView { token in
                tokenStore.add(token)
                showingAdd = false
            } onBulkInsert: { tokens in
                let added = tokenStore.addBulk(tokens)
                let skipped = tokens.count - added
                showingAdd = false
                migrationResult = MigrationResult(added: added, skipped: skipped)
            } onCancel: {
                showingAdd = false
            }
        }
        .sheet(item: $tokenToEdit) { token in
            EditTokenView(token: token) { updated in
                tokenStore.update(updated)
                tokenToEdit = nil
            } onCancel: {
                tokenToEdit = nil
            }
        }
        .alert(
            String(localized: .tokenlistviewImportTitle),
            isPresented: .init(
                get: { migrationResult != nil },
                set: { if !$0 { migrationResult = nil } }
            ),
            presenting: migrationResult
        ) { _ in
            Button(.tokenlistviewImportOk) {}
        } message: { result in
            if result.skipped == 0 {
                Text(.tokenlistviewImportSuccessOnly(result.added))
            } else {
                Text(.tokenlistviewImportSuccessWithSkipped(result.added, duplicates: result.skipped))
            }
        }
        .confirmationDialog(
            String(localized: .tokenlistviewDeleteTitle),
            isPresented: .init(
                get: { tokenToDelete != nil },
                set: { if !$0 { tokenToDelete = nil } }
            ),
            presenting: tokenToDelete
        ) { token in
            Button(.tokenlistviewDeleteConfirm(token.issuer), role: .destructive) {
                tokenStore.remove(token)
            }
            Button(.tokenlistviewDeleteCancel, role: .cancel) {}
        } message: { token in
            Text(.tokenlistviewDeleteMessage(token.issuer, token.account))
        }
    }
    
    // MARK: - TokenList
    
    var tokenList: some View {
        List() {
            ForEach(tokenStore.tokens) { token in
                TokenRowView(token: token)
                    .contextMenu {
                        Button(.tokenlistviewContextmenuCopyTOTP) {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(TOTPGenerator.generate(for: token), forType: .string)
                        }
                        
                        Button(.tokenlistviewContextmenuCopyAccount) {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(token.account, forType: .string)
                        }
                        
                        Divider()
                        
                        Button(.tokenlistviewContextmenuEdit) {
                            tokenToEdit = token
                        }
                        Divider()
                        
                        Button(.tokenlistviewContextmenuDelete, role: .destructive) {
                            tokenToDelete = token
                        }
                    }
            }
            .onMove(perform: tokenStore.reorder)
        }
    }

    // MARK: - Empty State

    var emptyState: some View {
        VStack(spacing: 32) {
            ContentUnavailableView(
                .tokenlistviewUnavailableTitle,
                systemImage: "lock.shield",
                description: Text(.tokenlistviewUnavailableDescription)
            )
            
            VStack(spacing: 10) {
                Text(.tokenlistviewMigrationTitle)
                    .font(.headline)
                
                Text(.tokenlistviewMigrationDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
                
                Button(.tokenlistviewMigrationCta) {
                    showingMigrationHelp = true
                }
                .buttonStyle(.borderless)
                .font(.subheadline)
                .padding(.top, 4)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 40)
        }
        .popover(isPresented: $showingMigrationHelp, arrowEdge: .top) {
            GoogleMigrationHelpView()
                .frame(width: 360)
                .padding()
        }
    }
}

#Preview() {
    TokenListView()
        .environment(TokenStore())
}
