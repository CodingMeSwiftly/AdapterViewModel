//
//  ViewModelAdapter.swift
//  Apeidos
//
//  Created by Maximilian Kraus on 09.02.17.
//  Copyright © 2017 Apeidos. All rights reserved.
//

import AsyncDisplayKit

/// A class that alters the way `UICollectionView` is used.
/// Instead of providing section and item counts as well as nodes ad-hoc,
/// you model the data upfront. Updates to the underlying `UICollectionView`
/// are abstracted away.
/// This class is used when we want to display a heterogenous list of data and is
/// intented to be used with `UICollectionViewFlowLayout` (by providing sensible defaults
/// for values such as constrained layout sizes, scrolling direction, etc.
/// Other layouts will work just as well. However, you will most likely need to subclass
/// and override the methods in `ASCollectionViewLayoutInspecting` to provide values that
/// suit the custom layout. For an example, see `MatchListAdapter`.
class Adapter: NSObject {
  
  var sections: [SectionModel]
  
  unowned let collectionNode: ASCollectionNode
  
  init(collectionNode: ASCollectionNode, sections: [SectionModel] = []) {
    self.collectionNode = collectionNode
    self.sections = sections
    
    super.init()
    
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionFooter)
    
    collectionNode.view.layoutInspector = self
    collectionNode.dataSource = self
  }
}


//MARK: - ASCollectionDataSource
extension Adapter: ASCollectionDataSource {
  final func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }
  
  final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sections[section].itemModels.count
  }
  
  func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let model = sections[indexPath.section].itemModels[indexPath.item]
    return { model.createNode() }
  }
  
  func collectionView(_ collectionView: ASCollectionView, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    
    let model: ViewModel?
    
    switch kind {
    case UICollectionElementKindSectionHeader:
      model = sections[indexPath.section].headerModel
    case UICollectionElementKindSectionFooter:
      model = sections[indexPath.section].footerModel
    default:
      return ASCellNode()
    }
    
    return model?.createNode() ?? ASCellNode()
  }
}
//  -


//MARK: - ASCollectionViewLayoutInspecting
extension Adapter: ASCollectionViewLayoutInspecting {
  
  func scrollableDirections() -> ASScrollDirection {
    return .down
  }

  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
    return constrainedNodeSize(for: collectionView)
  }
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
    return constrainedNodeSize(for: collectionView)
  }
  
  func collectionView(_ collectionView: ASCollectionView, numberOfSectionsForSupplementaryNodeOfKind kind: String) -> UInt {
    let predicate: (SectionModel) -> Bool
    
    switch kind {
    case UICollectionElementKindSectionHeader:
      predicate = { $0.headerModel != nil }
    case UICollectionElementKindSectionFooter:
      predicate = { $0.footerModel != nil }
    default:
      return 0
    }
    
    return UInt(sections.filter(predicate).count)
  }

  func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
    let sectionModel = sections[Int(section)]
    
    switch kind {
    case UICollectionElementKindSectionHeader:
      return sectionModel.headerModel == nil ? 0 : 1
    case UICollectionElementKindSectionFooter:
      return sectionModel.footerModel == nil ? 0 : 1
    default:
      return 0
    }
  }
  
  private func constrainedNodeSize(for collectionView: ASCollectionView) -> ASSizeRange {
    let constrainedWidth: CGFloat
    
    if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      constrainedWidth = collectionView.frame.width - flowLayout.sectionInset.horizontal
    } else {
      //  Use a sensible default.
      constrainedWidth = collectionView.frame.width - 32
    }
    
    return ASSizeRange(
      min: CGSize(width: constrainedWidth, height: 0),
      max: CGSize(width: constrainedWidth, height: .greatestFiniteMagnitude)
    )
  }
}
//  -


//MARK: - Data access
extension Adapter {
  func model(at indexPath: IndexPath) -> ViewModel? {
    guard indexPath.section < sections.count else { return nil }
    
    let section = sections[indexPath.section]
    
    guard indexPath.item < section.itemModels.count else { return nil }
    
    return section.itemModels[indexPath.item]
  }
}
//  -


//MARK: - Insertions & deletions
extension Adapter {
  func add(sections: [SectionModel]) {
    let oldCount = self.sections.count
    
    self.sections.append(contentsOf: sections)
  
    let indexes = IndexSet(integersIn: oldCount..<oldCount + sections.count)
    collectionNode.insertSections(indexes)
  }
  
  func add(items: [ViewModel], inSection sectionIdx: Int = 0) {
    collectionNode.performBatchUpdates({ 
      if sections.isEmpty && sectionIdx == 0 {
        sections.append(SectionModel(items: []))
        collectionNode.insertSections(IndexSet(integer: 0))
      }
      
      let oldCount = sections[sectionIdx].itemModels.count
      
      sections[sectionIdx].itemModels.append(contentsOf: items)
      
      let addedIndexPaths = (oldCount..<oldCount + items.count).map {
        IndexPath(item: $0, section: sectionIdx)
      }
      
      collectionNode.insertItems(at: addedIndexPaths)
    }, completion: nil)
  }
  
  func remove(at indexPath: IndexPath) {
    sections[indexPath.section].itemModels.remove(at: indexPath.item)
    collectionNode.deleteItems(at: [indexPath])
  }
  
  func clearData() {
    if sections.isEmpty { return }
    
    sections.removeAll()
    collectionNode.reloadData()
    collectionNode.waitUntilAllUpdatesAreCommitted()
  }
}
//  -
