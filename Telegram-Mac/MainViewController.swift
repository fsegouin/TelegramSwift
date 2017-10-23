//
//  MainViewController.swift
//  Telegram-Mac
//
//  Created by keepcoder on 27/09/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import PostboxMac
import SwiftSignalKitMac


class MainViewController: TelegramViewController {

    private var tabController:TabBarController = TabBarController()
    private let accountManager:AccountManager
    private var contacts:ContactsController
    private var chatList:ChatListController
    private var settings:AccountViewController
    private let phoneCalls:RecentCallsViewController
    private let layoutDisposable:MetaDisposable = MetaDisposable()
    
    override var navigationController: NavigationViewController? {
        didSet {
            tabController.navigationController = navigationController
        }
    }
    
    override func viewDidResized(_ size: NSSize) {
        super.viewDidResized(size)
        tabController.view.frame = bounds
    }
    
    override func loadView() {
        super.loadView()
        tabController._frameRect = self._frameRect
        self.bar = NavigationBarStyle(height: 0)
        backgroundColor = theme.colors.background
        addSubview(tabController.view)
        
        tabController.add(tab: TabItem(image: theme.tabBar.icon(key: 0, image: #imageLiteral(resourceName: "Icon_TabContacts"), selected: false), selectedImage: theme.tabBar.icon(key: 0, image: #imageLiteral(resourceName: "Icon_TabContacts_Highlighted"), selected: true), controller: contacts))
        
        tabController.add(tab: TabItem(image: theme.tabBar.icon(key: 1, image: #imageLiteral(resourceName: "Icon_TabRecentCalls"), selected: false), selectedImage: theme.tabBar.icon(key: 1, image: #imageLiteral(resourceName: "Icon_TabRecentCallsHighlighted"), selected: true), controller: phoneCalls))
        
        tabController.add(tab: TabBadgeItem(account, controller: chatList, image: theme.tabBar.icon(key: 2, image: #imageLiteral(resourceName: "Icon_TabChatList"), selected: false), selectedImage: theme.tabBar.icon(key: 2, image: #imageLiteral(resourceName: "Icon_TabChatList_Highlighted"), selected: true)))
        
        tabController.add(tab: TabItem(image: theme.tabBar.icon(key: 3, image: #imageLiteral(resourceName: "Icon_TabSettings"), selected: false), selectedImage: theme.tabBar.icon(key: 3, image: #imageLiteral(resourceName: "Icon_TabSettings_Highlighted"), selected: true), controller: settings, longHoverHandler: { [weak self] control in
            self?.showFastSettings(control)
            
        }))
        
        tabController.updateLocalizationAndTheme()

        
        self.ready.set(.single(true))
        
        layoutDisposable.set(account.context.layoutHandler.get().start(next: { [weak self] state in
            self?.tabController.hideTabView(state == .minimisize)
        }))
        
        tabController.didChangedIndex = { [weak self] index in
            self?.checkSettings(index)
        }
    }
    
    private let settingsDisposable = MetaDisposable()
    
    private func showFastSettings(_ control:Control) {
        
        let passcodeData = account.postbox.modify { modifier -> PostboxAccessChallengeData in
            return modifier.getAccessChallengeData()
        } |> deliverOnMainQueue
        
        let applicationSettings = appNotificationSettings(postbox: account.postbox) |> take(1)  |> deliverOnMainQueue
        
       
        settingsDisposable.set(combineLatest(passcodeData, applicationSettings).start(next: { [weak self] passcode, notifications in
            self?._showFast(control: control, passcodeData: passcode, notifications: notifications)
        }))
        
       
    }
    
    private func _showFast( control: Control, passcodeData: PostboxAccessChallengeData, notifications: InAppNotificationSettings) {
        var items:[SPopoverItem] = []
       
        switch passcodeData {
        case .none:
            items.append(SPopoverItem(tr(.fastSettingsSetPasscode), { [weak self] in
                if let account = self?.account {
                    self?.tabController.select(index: 3)
                    account.context.mainNavigation?.push(PasscodeSettingsViewController(account))
                }
            }, theme.icons.fastSettingsLock))
        default:
            items.append(SPopoverItem(tr(.fastSettingsLockTelegram), {
                if let event = NSEvent.keyEvent(with: .keyDown, location: NSZeroPoint, modifierFlags: [.command], timestamp: Date().timeIntervalSince1970, windowNumber: mainWindow.windowNumber, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: KeyboardKey.L.rawValue) {
                    mainWindow.sendEvent(event)
                }
            }, theme.icons.fastSettingsLock))
        }
        
        items.append(SPopoverItem(theme.dark ? tr(.fastSettingsDisableDarkMode) : tr(.fastSettingsEnableDarkMode), { [weak self] in
            if let strongSelf = self {
                _ = updateThemeSettings(postbox: strongSelf.account.postbox, pallete: !theme.dark ? darkPallete : solarizedLightPalette, dark: !theme.dark).start()
            }
        }, theme.dark ? theme.icons.fastSettingsSunny : theme.icons.fastSettingsDark))
        
        let time = Int32(Date().timeIntervalSince1970)
        let unmuted = notifications.muteUntil < time
        items.append(SPopoverItem(unmuted ? tr(.fastSettingsMute2Hours) : tr(.fastSettingsUnmute), { [weak self] in
            if let account = self?.account {
                let time = Int32(Date().timeIntervalSince1970 + 2 * 60 * 60)
                _ = updateInAppNotificationSettingsInteractively(postbox: account.postbox, {$0.withUpdatedMuteUntil(unmuted ? time : 0)}).start()
            }
            
        }, notifications.muteUntil < time ? theme.icons.fastSettingsMute : theme.icons.fastSettingsUnmute))
        let controller = SPopoverViewController(items: items)
        if self.tabController.current != settings {
            showPopover(for: control, with: controller, edge: .maxX, inset: NSMakePoint(control.frame.width - 12, 0))
        }
    }
    
    override func updateLocalizationAndTheme() {
        super.updateLocalizationAndTheme()
        tabController.updateLocalizationAndTheme()
        
        
        if !tabController.isEmpty {
            tabController.replace(tab: tabController.tab(at: 0).withUpdatedImages(theme.tabBar.icon(key: 0, image: #imageLiteral(resourceName: "Icon_TabContacts"), selected: false), theme.tabBar.icon(key: 0, image: #imageLiteral(resourceName: "Icon_TabContacts_Highlighted"), selected: true)), at: 0)
            
            tabController.replace(tab: tabController.tab(at: 1).withUpdatedImages(theme.tabBar.icon(key: 1, image: #imageLiteral(resourceName: "Icon_TabRecentCalls"), selected: false), theme.tabBar.icon(key: 1, image: #imageLiteral(resourceName: "Icon_TabRecentCallsHighlighted"), selected: true)), at: 1)
            
            tabController.replace(tab: tabController.tab(at: 2).withUpdatedImages(theme.tabBar.icon(key: 2, image: #imageLiteral(resourceName: "Icon_TabChatList"), selected: false), theme.tabBar.icon(key: 2, image: #imageLiteral(resourceName: "Icon_TabChatList_Highlighted"), selected: true)), at: 2)
            
            tabController.replace(tab: tabController.tab(at: 3).withUpdatedImages(theme.tabBar.icon(key: 3, image: #imageLiteral(resourceName: "Icon_TabSettings"), selected: false), theme.tabBar.icon(key: 3, image: #imageLiteral(resourceName: "Icon_TabSettings_Highlighted"), selected: true)), at: 3)
        }
    }
    
    func checkSettings(_ index:Int) {
        
        if index == 3 && account.context.layout != .single {
            account.context.mainNavigation?.push(GeneralSettingsViewController(account), false)
        } else {
            
            account.context.mainNavigation?.enumerateControllers( { controller, index in
                if (controller is ChatController) || (controller is PeerInfoController) || (controller is GroupAdminsController) || (controller is GroupAdminsController)  || (controller is ChannelAdminsViewController) || (controller is ChannelAdminsViewController) || (controller is EmptyChatViewController) {
                    self.backFromSettings(index)
                    return true
                }
                return false
            })
        }
    }
    
    private func backFromSettings(_ index:Int) {
        account.context.mainNavigation?.to(index: index)
    }
    
    override func getCenterBarViewOnce() -> TitledBarView {
        return TitledBarView(controller: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animated {
            self.tabController.select(index:2)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabController.current?.viewWillAppear(animated)
       // loadViewIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabController.current?.viewWillDisappear(animated)
    }
    
    func showPreferences() {
        if self.account.context.layout != .minimisize {
            self.tabController.select(index:3)
        }
    }
    
    func isCanMinimisize() -> Bool{
        return self.tabController.current == chatList
    }
    
    init(_ account:Account, accountManager:AccountManager) {
        
        self.accountManager = accountManager
        chatList = ChatListController(account)
        contacts = ContactsController(account)
        settings = AccountViewController(account, accountManager: accountManager)
        phoneCalls = RecentCallsViewController(account)
        super.init(account)
        bar = NavigationBarStyle(height: 0)
    }

    deinit {
        layoutDisposable.dispose()
    }
}
