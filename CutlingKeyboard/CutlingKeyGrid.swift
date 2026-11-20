//
//  CutlingKeyGrid.swift
//  CutlingKeyboard
//
//  The keyboard's grid of cutling keys as a UICollectionView that reuses its cells,
//  each cell hosting the SwiftUI key through UIHostingConfiguration. A SwiftUI lazy
//  stack keeps every key it has built, so the keyboard's memory grew with each key
//  scrolled past (95 MB through 1,000 snippets and 100 photos, against iOS's 77 MB
//  keyboard limit); reused cells hold about one screen of keys at any count, the way
//  Gladys and the open-source GIF keyboards do (docs/research/keyboard-unbounded-items.md).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

/// One section of keys, with an optional title row and a hairline after it.
struct CutlingKeySection {
    var title: Text?
    var cutlings: [Cutling]
    var dividerAfter = false
}

struct CutlingKeyGrid<Key: View>: UIViewRepresentable {
    var sections: [CutlingKeySection]
    var cardHeight: CGFloat
    var cardMinWidth: CGFloat
    var spacing: CGFloat
    var horizontalPadding: CGFloat
    /// Scrolls to this key when it changes, centred.
    var scrollTarget: UUID?
    @ViewBuilder var key: (Cutling) -> Key

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UICollectionView {
        let coordinator = context.coordinator
        let collection = UICollectionView(frame: .zero, collectionViewLayout: coordinator.layout())
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.alwaysBounceVertical = true
        coordinator.attach(to: collection)
        return collection
    }

    func updateUIView(_ collection: UICollectionView, context: Context) {
        let coordinator = context.coordinator
        coordinator.grid = self
        coordinator.apply(to: collection)
        if let target = scrollTarget, target != coordinator.lastScrollTarget,
           let path = coordinator.dataSource?.indexPath(for: .key(target)) {
            collection.scrollToItem(at: path, at: .centeredVertically, animated: true)
        }
        coordinator.lastScrollTarget = scrollTarget
    }

    enum Item: Hashable {
        case title(Int)
        case divider(Int)
        case key(UUID)
    }

    @MainActor
    final class Coordinator {
        var grid: CutlingKeyGrid?
        var dataSource: UICollectionViewDiffableDataSource<Int, Item>?
        var lastScrollTarget: UUID?
        private var cutlingsByID: [UUID: Cutling] = [:]
        private var appliedOrder: [[Item]] = []

        /// Each section is a title row, a grid of keys, then a hairline, as the SwiftUI grid laid them out.
        func layout() -> UICollectionViewCompositionalLayout {
            UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
                guard let self, let grid = self.grid, sectionIndex < grid.sections.count else { return nil }
                let rows = self.appliedOrder.indices.contains(sectionIndex) ? self.appliedOrder[sectionIndex] : []
                let width = environment.container.effectiveContentSize.width - grid.horizontalPadding * 2
                let columns = max(1, Int((width + grid.spacing) / (grid.cardMinWidth + grid.spacing)))
                let keyWidth = (width - grid.spacing * CGFloat(columns - 1)) / CGFloat(columns)

                var groups: [NSCollectionLayoutItem] = []
                if rows.contains(where: { if case .title = $0 { true } else { false } }) {
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(26))
                    groups.append(NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)]))
                }
                let keyCount = rows.filter { if case .key = $0 { true } else { false } }.count
                if keyCount > 0 {
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(keyWidth), heightDimension: .absolute(grid.cardHeight)))
                    let row = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(grid.cardHeight)),
                        repeatingSubitem: item, count: columns)
                    row.interItemSpacing = .fixed(grid.spacing)
                    let rowCount = (keyCount + columns - 1) / columns
                    let block = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(CGFloat(rowCount) * grid.cardHeight + CGFloat(rowCount - 1) * grid.spacing)),
                        repeatingSubitem: row, count: rowCount)
                    block.interItemSpacing = .fixed(grid.spacing)
                    groups.append(block)
                }
                if rows.contains(where: { if case .divider = $0 { true } else { false } }) {
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(0.5 + grid.spacing * 2))
                    groups.append(NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)]))
                }
                guard !groups.isEmpty else { return nil }
                let height = groups.reduce(CGFloat(0)) { $0 + ($1.layoutSize.heightDimension.dimension) }
                let whole = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)),
                    subitems: groups)
                let section = NSCollectionLayoutSection(group: whole)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: grid.spacing, leading: grid.horizontalPadding, bottom: grid.spacing, trailing: grid.horizontalPadding)
                return section
            }
        }

        func attach(to collection: UICollectionView) {
            let keyCell = UICollectionView.CellRegistration<UICollectionViewCell, UUID> { [weak self] cell, _, id in
                guard let self, let grid = self.grid, let cutling = self.cutlingsByID[id] else { return }
                cell.contentConfiguration = UIHostingConfiguration { grid.key(cutling) }.margins(.all, 0)
            }
            let titleCell = UICollectionView.CellRegistration<UICollectionViewCell, Int> { [weak self] cell, _, section in
                guard let title = self?.grid?.sections[safe: section]?.title else { return }
                cell.contentConfiguration = UIHostingConfiguration {
                    title
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }.margins(.all, 0)
            }
            let dividerCell = UICollectionView.CellRegistration<UICollectionViewCell, Int> { cell, _, _ in
                cell.contentConfiguration = UIHostingConfiguration {
                    Rectangle().fill(.secondary.opacity(0.2)).frame(height: 0.5).padding(.horizontal, 8)
                }.margins(.all, 0)
            }
            dataSource = UICollectionViewDiffableDataSource(collectionView: collection) { collection, path, item in
                switch item {
                case .key(let id): collection.dequeueConfiguredReusableCell(using: keyCell, for: path, item: id)
                case .title(let section): collection.dequeueConfiguredReusableCell(using: titleCell, for: path, item: section)
                case .divider(let section): collection.dequeueConfiguredReusableCell(using: dividerCell, for: path, item: section)
                }
            }
        }

        /// Applies new sections; keys already on screen are reconfigured so a copied or highlighted key redraws.
        func apply(to collection: UICollectionView) {
            guard let grid, let dataSource else { return }
            var byID: [UUID: Cutling] = [:]
            var order: [[Item]] = []
            for (index, section) in grid.sections.enumerated() {
                var rows: [Item] = []
                if section.title != nil, !section.cutlings.isEmpty { rows.append(.title(index)) }
                for cutling in section.cutlings where byID[cutling.id] == nil {
                    byID[cutling.id] = cutling
                    rows.append(.key(cutling.id))
                }
                if section.dividerAfter, !section.cutlings.isEmpty { rows.append(.divider(index)) }
                order.append(rows)
            }
            cutlingsByID = byID
            if order != appliedOrder {
                appliedOrder = order
                var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
                for (index, rows) in order.enumerated() {
                    snapshot.appendSections([index])
                    snapshot.appendItems(rows, toSection: index)
                }
                collection.collectionViewLayout.invalidateLayout()
                dataSource.apply(snapshot, animatingDifferences: false)
            } else {
                var snapshot = dataSource.snapshot()
                let visible = collection.indexPathsForVisibleItems.compactMap { dataSource.itemIdentifier(for: $0) }
                guard !visible.isEmpty else { return }
                snapshot.reconfigureItems(visible)
                dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
