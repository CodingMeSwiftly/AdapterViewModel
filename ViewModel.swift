//
//  ViewModel.swift
//  Apeidos
//
//  Created by Maximilian Kraus on 12/10/2016.
//  Copyright © 2016 Apeidos. All rights reserved.
//

import AsyncDisplayKit

/// Any model that can vend a cell node to be displayed in either ASTableView or ASCollectionView
/// representing the data of said model.
protocol ViewModel {
  func createNode() -> ASCellNode
}
