//
//  IconResource.swift
//  Thaw
//

import SwiftUI

/// A type that produces a view representing an icon.
enum IconResource: Hashable {
    /// A resource derived from a system symbol.
    case systemSymbol(_ name: String)

    /// A resource derived from an asset catalog.
    case assetCatalog(_ resource: ImageResource)

    /// The view produced by the resource.
    var view: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    /// The image produced by the resource.
    private var image: Image {
        switch self {
        case let .systemSymbol(name):
            Image(systemName: name)
        case let .assetCatalog(resource):
            Image(resource)
        }
    }
}
