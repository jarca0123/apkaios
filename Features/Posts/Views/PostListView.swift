//
//  PostListView.swift
//  nejskutecnejsiprojekt
//
//  List view for displaying posts with pull-to-refresh and offline support
//

import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel = PostViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.adaptiveBackground(for: colorScheme)
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isOffline {
                        offlineIndicator
                    }
                }
            }
        }
        .task {
            viewModel.loadCachedPostsIfAvailable()
            await viewModel.fetchPosts()
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .loading where viewModel.posts.isEmpty:
            loadingView
            
        case .error(let message) where viewModel.posts.isEmpty:
            errorView(message: message)
            
        case .loaded, .offline, .loading, .error:
            postsList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Načítání...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Nelze načíst příspěvky")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.fetchPosts()
                }
            } label: {
                Label("Zkusit znovu", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .transition(.opacity)
    }
    
    private var postsList: some View {
        List {
            ForEach(viewModel.posts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PostRowView(post: post)
                }
                .listRowBackground(Color.adaptiveCardBackground(for: colorScheme))
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshPosts()
        }
        .animation(.easeInOut, value: viewModel.posts.count)
    }
    
    private var offlineIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("Offline")
                .font(.caption)
        }
        .foregroundColor(.orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Post Row View

struct PostRowView: View {
    let post: Post
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
                .foregroundColor(.blue)
                .lineLimit(2)
            
            Text(post.body)
                .font(.subheadline)
                .foregroundColor(Color.adaptiveSecondaryText(for: colorScheme))
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    PostListView()
}

