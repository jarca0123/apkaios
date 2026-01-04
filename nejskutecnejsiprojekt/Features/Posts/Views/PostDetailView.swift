//
//  PostDetailView.swift
//  nejskutecnejsiprojekt
//
//  Detail view for a single post
//

import SwiftUI
import Combine

struct PostDetailView: View {
    let post: Post
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                Divider()
                
                // Body
                bodySection
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color.adaptiveBackground(for: colorScheme))
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Post ID badge
            HStack {
                Text("Post #\(post.id)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
                
                Spacer()
            }
            
            // Title
            Text(post.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.adaptiveText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Obsah")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(post.body)
                .font(.body)
                .foregroundColor(Color.adaptiveText(for: colorScheme))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.adaptiveCardBackground(for: colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PostDetailView(post: Post(
            id: 1,
            userId: 1,
            title: "Sample Post Title That Might Be Quite Long",
            body: "This is the body of the post. It contains more detailed information about the topic. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        ))
    }
}

