//
//  MenuBarShapePicker.swift
//  Project: Thaw
//
//  Copyright (Ice) © 2023–2025 Jordan Baird
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import SwiftUI

struct MenuBarShapePicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var configuration: MenuBarAppearanceConfigurationV2

    var body: some View {
        VStack(spacing: 12) {
            shapeKindPicker
            shapePicker
                .foregroundStyle(colorScheme == .dark ? .primary : .secondary)
            if configuration.shapeKind != .noShape {
                horizontalMargins
            }
        }
        if configuration.shapeKind == .noShape {
            Text("No shape kind selected")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var horizontalMargins: some View {
        HStack(spacing: 17) {
            IceSlider(
                "Left margin",
                value: $configuration.leftMargin,
                in: 0 ... 15,
                step: 1,
                showsValue: true,
                unit: "px"
            )
            IceSlider(
                "Right margin",
                value: $configuration.rightMargin,
                in: 0 ... 15,
                step: 1,
                reversed: true,
                showsValue: true,
                unit: "px"
            )
        }
    }

    private var shapeKindPicker: some View {
        IcePicker("Shape Kind", selection: $configuration.shapeKind) {
            ForEach(MenuBarShapeKind.allCases) { shapeKind in
                Text(shapeKind.localized).tag(shapeKind)
            }
        }
    }

    @ViewBuilder
    private var shapePicker: some View {
        switch configuration.shapeKind {
        case .noShape:
            EmptyView()
        case .full:
            MenuBarFullShapePicker(
                info: $configuration.fullShapeInfo,
                leftMargin: $configuration.leftMargin,
                rightMargin: $configuration.rightMargin
            ).equatable()
        case .split:
            MenuBarSplitShapePicker(
                info: $configuration.splitShapeInfo,
                leftMargin: $configuration.leftMargin,
                rightMargin: $configuration.rightMargin
            ).equatable()
        }
    }
}

private struct MenuBarFullShapePicker: View, Equatable {
    @Binding var info: MenuBarFullShapeInfo
    @Binding var leftMargin: Double
    @Binding var rightMargin: Double

    var body: some View {
        VStack {
            pickerStack
            exampleStack
        }
    }

    private var pickerStack: some View {
        HStack(spacing: 0) {
            leadingEndCapPicker
            Spacer()
            trailingEndCapPicker
        }
        .labelsHidden()
        .pickerStyle(.segmented)
    }

    private var exampleStack: some View {
        HStack(spacing: 0) {
            if leftMargin > 0 {
                Color.clear.frame(width: leftMargin)
            }
            leadingEndCapExample
            Rectangle()
            trailingEndCapExample
            if rightMargin > 0 {
                Color.clear.frame(width: rightMargin)
            }
        }
        .frame(height: 24)
    }

    @ViewBuilder
    private func endCapPickerContentView(endCap: MenuBarEndCap, edge: HorizontalEdge) -> some View {
        switch endCap {
        case .square:
            Image(size: CGSize(width: 12, height: 12)) { context in
                context.fill(Path(context.clipBoundingRect), with: .foreground)
            }
            .resizable()
            .help(Text("Square Cap"))
            .tag(endCap)
        case .round:
            Image(size: CGSize(width: 12, height: 12)) { context in
                let remainder = context.clipBoundingRect
                    .divided(atDistance: context.clipBoundingRect.width / 2, from: cgRectEdge(for: edge))
                    .remainder
                let path1 = Path(remainder)
                let path2 = Path(ellipseIn: context.clipBoundingRect)
                context.fill(path1.union(path2), with: .foreground)
            }
            .resizable()
            .help(Text("Round Cap"))
            .tag(endCap)
        }
    }

    private var leadingEndCapPicker: some View {
        Picker("Leading End Cap", selection: $info.leadingEndCap) {
            ForEach(MenuBarEndCap.allCases.reversed(), id: \.self) { endCap in
                endCapPickerContentView(endCap: endCap, edge: .leading)
            }
        }
        .fixedSize()
    }

    private var trailingEndCapPicker: some View {
        Picker("Trailing End Cap", selection: $info.trailingEndCap) {
            ForEach(MenuBarEndCap.allCases, id: \.self) { endCap in
                endCapPickerContentView(endCap: endCap, edge: .trailing)
            }
        }
        .fixedSize()
    }

    private var leadingEndCapExample: some View {
        MenuBarEndCapExampleView(
            endCap: info.leadingEndCap,
            edge: .leading
        )
    }

    private var trailingEndCapExample: some View {
        MenuBarEndCapExampleView(
            endCap: info.trailingEndCap,
            edge: .trailing
        )
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.info == rhs.info &&
            lhs.leftMargin == rhs.leftMargin &&
            lhs.rightMargin == rhs.rightMargin
    }

    private func cgRectEdge(for edge: HorizontalEdge) -> CGRectEdge {
        switch edge {
        case .leading: .minXEdge
        case .trailing: .maxXEdge
        }
    }
}

private struct MenuBarSplitShapePicker: View, Equatable {
    @Binding var info: MenuBarSplitShapeInfo
    @Binding var leftMargin: Double
    @Binding var rightMargin: Double

    var body: some View {
        HStack {
            MenuBarFullShapePicker(
                info: $info.leading,
                leftMargin: $leftMargin,
                rightMargin: .constant(0)
            ).equatable()
            Divider()
            MenuBarFullShapePicker(
                info: $info.trailing,
                leftMargin: .constant(0),
                rightMargin: $rightMargin
            ).equatable()
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.info == rhs.info &&
            lhs.leftMargin == rhs.leftMargin &&
            lhs.rightMargin == rhs.rightMargin
    }
}

private struct MenuBarEndCapExampleView: View {
    @State private var radius: CGFloat = 0

    let endCap: MenuBarEndCap
    let edge: HorizontalEdge

    var body: some View {
        switch endCap {
        case .square:
            Rectangle()
        case .round:
            switch edge {
            case .leading:
                UnevenRoundedRectangle(
                    topLeadingRadius: radius,
                    bottomLeadingRadius: radius,
                    style: .circular
                )
                .onFrameChange { frame in
                    radius = frame.height / 2
                }
            case .trailing:
                UnevenRoundedRectangle(
                    bottomTrailingRadius: radius,
                    topTrailingRadius: radius,
                    style: .circular
                )
                .onFrameChange { frame in
                    radius = frame.height / 2
                }
            }
        }
    }
}
