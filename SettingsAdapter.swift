//
//  SettingsAdapter.swift
//  Apeidos
//
//  Created by Maximilian Kraus on 09.02.17.
//  Copyright © 2017 Apeidos. All rights reserved.
//

import AsyncDisplayKit


//  SectionHeader, TableRow, etc. are classes conforming to `ViewModel`.


class SettingsAdapter: Adapter {
  enum Row {
    case about, reportProblem, shareApp, themeSetting, pushNotifications, newFollower, termsOfUse, privacyPolicy, copyright, clearCache, deleteProfile, signOut
    
    fileprivate static func with(indexPath: IndexPath) -> Row? {
      switch (indexPath.section, indexPath.item) {
      case (0, 0): return .about
      case (0, 1): return .reportProblem
      case (0, 2): return .shareApp
      case (0, 3): return .themeSetting
      case (1, 0): return .pushNotifications
      case (1, 1): return .newFollower
      case (2, 0): return .termsOfUse
      case (2, 1): return .privacyPolicy
      case (2, 2): return .copyright
      case (3, 0): return .clearCache
      case (3, 1): return .deleteProfile
      case (4, 0): return .signOut
      default: return nil
      }
    }
    
    var indexPath: IndexPath {
      switch self {
      case .about:          return IndexPath(item: 0, section: 0)
      case .reportProblem:  return IndexPath(item: 1, section: 0)
      case .shareApp:       return IndexPath(item: 2, section: 0)
      case .themeSetting:   return IndexPath(item: 3, section: 0)
      case .pushNotifications: return IndexPath(item: 0, section: 1)
      case .newFollower:    return IndexPath(item: 1, section: 1)
      case .termsOfUse:     return IndexPath(item: 0, section: 2)
      case .privacyPolicy:  return IndexPath(item: 1, section: 2)
      case .copyright:      return IndexPath(item: 2, section: 2)
      case .clearCache:     return IndexPath(item: 0, section: 3)
      case .deleteProfile:  return IndexPath(item: 1, section: 3)
      case .signOut:        return IndexPath(item: 0, section: 4)
      }
    }
  }
  
  
  init(collectionNode: ASCollectionNode) {
    
    let generalSection = SectionModel(
      header: SectionHeader(title: "settings.general".localized.uppercased()),
      items: [
        TableRow(title: "settings.about".localized, accessoryType: .detailIndicator),
        TableRow(title: "settings.reportProblem".localized),
        TableRow(title: "settings.tellYourFriends".localized),
        ThemeSettingRowModel()
      ]
    )
    
    let notificationsSection = SectionModel(
      header: SectionHeader(title: "Notifications".uppercased()),
      items: [
        SwitchRow(title: "Push notifications", initiallyOn: Defaults.pushNotificationsEnabled.get() ?? false),
        SwitchRow(title: "New follower", initiallyOn: Defaults.newFollowerNotificationsEnabled.get() ?? false)
      ]
    )
    
    let legalSection = SectionModel(
      header: SectionHeader(title: "settings.legal".localized.uppercased()),
      items: [
        TableRow(title: "settings.legal.terms".localized, accessoryType: .detailIndicator),
        TableRow(title: "settings.legal.privacy".localized, accessoryType: .detailIndicator),
        TableRow(title: "settings.legal.copyright".localized, accessoryType: .detailIndicator)
      ]
    )
    
    let advancedSection = SectionModel(
      header: SectionHeader(title: "settings.advanced".localized.uppercased()),
      items: [
        TableRow(title: "settings.advanced.clearCache".localized, subtitle: "settings.advanced.clearCache.footer".localized),
        TableRow(title: "settings.advanced.deleteProfile".localized, accessoryType: .detailIndicator)
      ]
    )
    
    let signOutSection = SectionModel(items: [SignOutModel()])
    
    
    super.init(collectionNode: collectionNode, sections: [
      generalSection,
      notificationsSection,
      legalSection,
      advancedSection,
      signOutSection
      ]
    )
  }
  
  
  func rowForIndexPath(_ indexPath: IndexPath) -> Row? {
    return Row.with(indexPath: indexPath)
  }
  
  
  fileprivate class SignOutModel: ViewModel {
    func createNode() -> ASCellNode {
      let node = TableCellNode()
      
      node.textAttributesProvider = { TextAttributes.signOutCellTitle }
      node.backgroundColorProvider = {
        switch Theme.style {
        case .light: return $0 ? .black : .tintForSystemUI
        case .dark: return $0 ? UIColor(white: 0.05, alpha: 1) : .black
        }
      }
      node.textNode.attributedText = NSAttributedString(
        string: "settings.signOut".localized,
        attributes: TextAttributes.signOutCellTitle
      )
      
      return node
    }
  }
}
