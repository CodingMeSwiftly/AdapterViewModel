//
//  SectionModel.swift
//  Apeidos
//
//  Created by Maximilian Kraus on 09.02.17.
//  Copyright © 2017 Apeidos. All rights reserved.
//

import Foundation

struct SectionModel {
  var headerModel: ViewModel?
  var itemModels: [ViewModel]
  var footerModel: ViewModel?
}


extension SectionModel {
  init(header: ViewModel? = nil, items: [ViewModel], footer: ViewModel? = nil) {
    itemModels = items
    headerModel = header
    footerModel = footer
  }
}
