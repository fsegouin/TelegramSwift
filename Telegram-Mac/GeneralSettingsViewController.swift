//
//  GeneralSettingsViewController.swift
//  TelegramMac
//
//  Created by keepcoder on 15/11/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import SwiftSignalKitMac
import PostboxMac


private enum GeneralSettingsEntry : Comparable, Identifiable {
    case section(sectionId:Int)
    case header(sectionId: Int, uniqueId:Int, text:String)
    case handleInAppKeys(sectionId:Int, enabled:Bool)
    case darkMode(sectionId:Int, enabled: Bool)
    case fontSize(sectionId:Int, enabled: Bool)
    case sidebar(sectionId:Int, enabled: Bool)
    case inAppSounds(sectionId:Int, enabled: Bool)
    case enterBehavior(sectionId:Int, enabled: Bool)
    case cmdEnterBehavior(sectionId:Int, enabled: Bool)
    case emojiReplacements(sectionId:Int, enabled: Bool)
    var stableId: Int {
        switch self {
        case let .header(_, uniqueId, _):
            return uniqueId
        case .darkMode:
            return 0
        case .fontSize:
            return 1
        case .enterBehavior:
            return 2
        case .cmdEnterBehavior:
            return 3
        case .handleInAppKeys:
            return 4
        case .sidebar:
            return 5
        case .inAppSounds:
            return 6
        case .emojiReplacements:
            return 7
        case let .section(id):
            return (id + 1) * 1000 - id
        }
    }
    
    var sortIndex:Int {
        switch self {
        case let .header(sectionId, _, _):
            return (sectionId * 1000) + stableId
        case let .fontSize(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .darkMode(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .sidebar(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .inAppSounds(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .emojiReplacements(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .handleInAppKeys(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .enterBehavior(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .cmdEnterBehavior(sectionId, _):
            return (sectionId * 1000) + stableId
        case let .section(id):
            return (id + 1) * 1000 - id
        }
    }
    
    func item(_ arguments:GeneralSettingsArguments, initialSize:NSSize) -> TableRowItem {
        switch self {
        case .section:
            return GeneralRowItem(initialSize, height: 30, stableId: stableId)
        case let .fontSize(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsLargeFonts), description: tr(.generalSettingsFontDescription), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleFonts(!enabled)
            })
        case let .darkMode(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsDarkMode), description: tr(.generalSettingsDarkModeDescription), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                _ = updateThemeSettings(postbox: arguments.account.postbox, pallete: !enabled ? darkPallete : solarizedLightPalette, dark: !enabled).start()

            })
        case let .handleInAppKeys(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsMediaKeysForInAppPlayer), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleInAppKeys(!enabled)
            })
        case let .sidebar(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsEnableSidebar), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleSidebar(!enabled)
            })
        case let .inAppSounds(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsInAppSounds), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleInAppSounds(!enabled)
            })
        case let .emojiReplacements(sectionId: _, enabled: enabled):
            return  GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.generalSettingsEmojiReplacements), type: .switchable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleEmojiReplacements(!enabled)
            })
        case let .header(sectionId: _, uniqueId: _, text: text):
            return GeneralTextRowItem(initialSize, stableId: stableId, text: text, drawCustomSeparator: true, inset: NSEdgeInsets(left: 30.0, right: 30.0, top:2, bottom:6))
        case let .enterBehavior(sectionId: _, enabled: enabled):
            return GeneralInteractedRowItem(initialSize, name: tr(.generalSettingsSendByEnter), type: .selectable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleInput(.enter)
            })
        case let .cmdEnterBehavior(sectionId: _, enabled: enabled):
            return GeneralInteractedRowItem(initialSize, name: tr(.generalSettingsSendByCmdEnter), type: .selectable(stateback: { () -> Bool in
                return enabled
            }), action: {
                arguments.toggleInput(.cmdEnter)
            })
        }
    }
    
}

private func ==(lhs: GeneralSettingsEntry, rhs: GeneralSettingsEntry) -> Bool {
    switch lhs {
    case let .header(sectionId, uniqueId, text):
        if case .header(sectionId, uniqueId, text) = rhs {
            return true
        } else {
            return false
        }
    case let .fontSize(sectionId, enabled):
        if case .fontSize(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .darkMode(sectionId, enabled):
        if case .darkMode(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .handleInAppKeys(sectionId, enabled):
        if case .handleInAppKeys(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .sidebar(sectionId, enabled):
        if case .sidebar(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .inAppSounds(sectionId, enabled):
        if case .inAppSounds(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .emojiReplacements(sectionId, enabled):
        if case .emojiReplacements(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .enterBehavior(sectionId, enabled):
        if case .enterBehavior(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .cmdEnterBehavior(sectionId, enabled):
        if case .cmdEnterBehavior(sectionId, enabled) = rhs {
            return true
        } else {
            return false
        }
    case let .section(sectionId):
        if case .section(sectionId) = rhs {
            return true
        } else {
            return false
        }
    }
}

private func <(lhs: GeneralSettingsEntry, rhs: GeneralSettingsEntry) -> Bool {
    return lhs.sortIndex < rhs.sortIndex
}

private final class GeneralSettingsArguments {
    let account:Account
    let toggleFonts:(Bool) -> Void
    let toggleInAppKeys:(Bool) -> Void
    let toggleInput:(SendingType)-> Void
    let toggleSidebar:(Bool) -> Void
    let toggleInAppSounds:(Bool) -> Void
    let toggleEmojiReplacements:(Bool) -> Void
    init(account:Account, toggleFonts:@escaping(Bool)-> Void, toggleInAppKeys: @escaping(Bool) -> Void, toggleInput: @escaping(SendingType)-> Void, toggleSidebar: @escaping (Bool) -> Void, toggleInAppSounds: @escaping (Bool) -> Void, toggleEmojiReplacements:@escaping(Bool) -> Void) {
        self.account = account
        self.toggleFonts = toggleFonts
        self.toggleInAppKeys = toggleInAppKeys
        self.toggleInput = toggleInput
        self.toggleSidebar = toggleSidebar
        self.toggleInAppSounds = toggleInAppSounds
        self.toggleEmojiReplacements = toggleEmojiReplacements
    }
   
}

private func generalSettingsEntries(arguments:GeneralSettingsArguments, baseSettings: BaseApplicationSettings, appearance: Appearance) -> [GeneralSettingsEntry] {
    var sectionId:Int = 1
    var entries:[GeneralSettingsEntry] = []
    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    var headerUnique:Int = -1
    
    entries.append(.header(sectionId: sectionId, uniqueId: headerUnique, text: tr(.generalSettingsAppearanceSettings)))
    headerUnique -= 1
    
    entries.append(.darkMode(sectionId: sectionId, enabled: appearance.presentation.dark))
    entries.append(.fontSize(sectionId: sectionId, enabled: appearance.presentation.fontSize > 13.0))

    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    entries.append(.header(sectionId: sectionId, uniqueId: headerUnique, text: tr(.generalSettingsInputSettings)))
    headerUnique -= 1
    
    entries.append(.enterBehavior(sectionId: sectionId, enabled: FastSettings.sendingType == .enter))
    entries.append(.cmdEnterBehavior(sectionId: sectionId, enabled: FastSettings.sendingType == .cmdEnter))
    
    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    

    entries.append(.header(sectionId: sectionId, uniqueId: headerUnique, text: tr(.generalSettingsGeneralSettings)))
    headerUnique -= 1
    
    
    //entries.append(.largeFonts(sectionId: sectionId, enabled: baseSettings.fontSize > 13))
    #if !APP_STORE
        entries.append(.handleInAppKeys(sectionId: sectionId, enabled: baseSettings.handleInAppKeys))
    #endif
    entries.append(.sidebar(sectionId: sectionId, enabled: FastSettings.sidebarEnabled))
    entries.append(.inAppSounds(sectionId: sectionId, enabled: FastSettings.inAppSounds))
    entries.append(.emojiReplacements(sectionId: sectionId, enabled: FastSettings.isPossibleReplaceEmojies))
    


    
    return entries
}

private func prepareEntries(left: [AppearanceWrapperEntry<GeneralSettingsEntry>], right: [AppearanceWrapperEntry<GeneralSettingsEntry>], arguments: GeneralSettingsArguments, initialSize: NSSize) -> TableUpdateTransition {
    let (removed, inserted, updated)  = proccessEntriesWithoutReverse(left, right: right) { entry -> TableRowItem in
        return entry.entry.item(arguments, initialSize: initialSize)
    }
    
    return TableUpdateTransition(deleted: removed, inserted: inserted, updated: updated, animated: true)
}

class GeneralSettingsViewController: TableViewController {
    
    
    override var removeAfterDisapper:Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readyOnce()
        
        let postbox = account.postbox
        let inputPromise:ValuePromise<SendingType> = ValuePromise(FastSettings.sendingType, ignoreRepeated: true)
        let arguments = GeneralSettingsArguments(account: account, toggleFonts: { enable in
            _ = updateApplicationFontSize(postbox: postbox, fontSize: enable ? 15.0 : 13.0).start()
        }, toggleInAppKeys: { enable in
            _ = updateBaseAppSettingsInteractively(postbox: postbox, { settings -> BaseApplicationSettings in
                return settings.withUpdatedInAppKeyHandle(enable)
            }).start()
        }, toggleInput: { input in
            FastSettings.changeSendingType(input)
            inputPromise.set(input)
        }, toggleSidebar: { enable in
            FastSettings.toggleSidebar(enable)
        }, toggleInAppSounds: { enable in
            FastSettings.toggleInAppSouds(enable)
        }, toggleEmojiReplacements: { enable in
            FastSettings.toggleAutomaticReplaceEmojies(enable)
        })
        
        let initialSize = atomicSize
        
        let previos:Atomic<[AppearanceWrapperEntry<GeneralSettingsEntry>]> = Atomic(value: [])
        
        genericView.merge(with: combineLatest(account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.baseAppSettings]) |> deliverOnMainQueue, inputPromise.get() |> deliverOnMainQueue, appearanceSignal) |> map { settings, _, appearance -> TableUpdateTransition in
            
            let baseSettings: BaseApplicationSettings
            if let settings = settings.values[ApplicationSpecificPreferencesKeys.baseAppSettings] as? BaseApplicationSettings {
                baseSettings = settings
            } else {
                baseSettings = BaseApplicationSettings.defaultSettings
            }
            
            let entries = generalSettingsEntries(arguments: arguments, baseSettings: baseSettings, appearance: appearance).map({AppearanceWrapperEntry(entry: $0, appearance: appearance)})
            let previous = previos.swap(entries)
            return prepareEntries(left: previous, right: entries, arguments: arguments, initialSize: initialSize.modify({$0}))

        } |> deliverOnMainQueue )
        
    }
    
    private var loggerClickCount = 0

    private func incrementLogClick() {
        loggerClickCount += 1
        let account = self.account
        if loggerClickCount == 5 {
            UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "enablelogs"), forKey: "enablelogs")
            let logs = Logger.shared.collectLogs() |> deliverOnMainQueue |> mapToSignal { logs -> Signal<Void, Void> in
                return selectModalPeers(account: account, title: "Send Logs", limit: 1, confirmation: {_ in return confirmSignal(for: mainWindow, header: appName, information: "Are you sure you want send logs?")}) |> filter {!$0.isEmpty} |> map {$0.first!} |> mapToSignal { peerId -> Signal<Void, Void> in
                    let messages = logs.map { (name, path) -> EnqueueMessage in
                        let id = arc4random64()
                        let file = TelegramMediaFile(fileId: MediaId(namespace: Namespaces.Media.LocalFile, id: id), resource: LocalFileReferenceMediaResource(localFilePath: path, randomId: id), previewRepresentations: [], mimeType: "application/text", size: nil, attributes: [.FileName(fileName: name)])
                        return .message(text: "", attributes: [], media: file, replyToMessageId: nil)
                    }
                    return enqueueMessages(account: account, peerId: peerId, messages: messages) |> map {_ in}
                }
            }
            _ = logs.start()
        }
    }
    
    func sendLogs() {
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.window?.set(handler: { [weak self] () -> KeyHandlerResult in
            self?.incrementLogClick()
            return .invoked
        }, with: self, for: .L, modifierFlags: [.control])
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        window?.removeAllHandlers(for: self)
    }
   
}


