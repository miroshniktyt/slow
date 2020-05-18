//
//  MCManager.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/12/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import MultipeerConnectivity
import Foundation

protocol MCManagerDiscoveryDelegate: class {
    func foundPeersChanged()
    func didReceiveInvitationFromPeer(peerName: String)
    func connectedWithPeer(isHost: Bool)
}

protocol MCManagerGameDelegate: class {
    func hostDidReplaceAim(toLocation location: Location)
    func otherPlayerDidTapAim()
    func finishGame(isWinner: Bool)
}

class MCManager: NSObject {
    
    var isHost: Bool = false
    
    var isSearchOn: Bool = false {
        didSet {
            guard oldValue != isSearchOn else { return }
            
            if isSearchOn {
                browser.startBrowsingForPeers()
                advertiser.startAdvertisingPeer()
            } else {
                foundPeers = []
                browser.stopBrowsingForPeers()
                advertiser.stopAdvertisingPeer()
            }
        }
    }
    
    var session: MCSession!
     
    private var peer: MCPeerID!
     
    private var browser: MCNearbyServiceBrowser!
     
    private var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers: [MCPeerID] = [] {
        didSet {
            discoveryDelegate?.foundPeersChanged()
        }
    }
     
    var invitationHandler: ((Bool, MCSession?) -> ())?
    
    weak var discoveryDelegate: MCManagerDiscoveryDelegate?
    weak var gameDelegate: MCManagerGameDelegate?
    
    override init() {
        super.init()
     
        peer = MCPeerID(displayName: UIDevice.current.name)
     
        session = MCSession(peer: peer)
        session.delegate = self
     
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "WhoIsSlow")
        browser.delegate = self
     
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "WhoIsSlow")
        advertiser.delegate = self
    }
    
    func sendInvitation(toPeer index: Int) {
        let peer = foundPeers[index]
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }
    
    func sendDidTapData() {
        let gameData = GameData(dataType: .didTap, location: nil)
        do {
            let data = try JSONEncoder().encode(gameData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendNewLocation(location: Location) {
        let gameData = GameData(dataType: .newLocation, location: location)
        do {
            let data = try JSONEncoder().encode(gameData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendFinishData() {
        let gameData = GameData(dataType: .finish, location: nil)
        do {
            let data = try JSONEncoder().encode(gameData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func didReceive(data: Data) {
        let decoder = JSONDecoder()
        guard let data = try? decoder.decode(GameData.self, from: data) else {
            print("got error while decoding GameData")
            return
        }
        
        switch data.dataType {
        case .didTap:
            DispatchQueue.main.async { self.gameDelegate?.otherPlayerDidTapAim() }
        case .newLocation:
            if let location = data.location {
                DispatchQueue.main.async { self.gameDelegate?.hostDidReplaceAim(toLocation: location) }
            }
        case .finish:
            DispatchQueue.main.async { self.gameDelegate?.finishGame(isWinner: false) }
        }
    }
}

extension MCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = foundPeers.firstIndex(of: peerID) else {
            print("can't find lostPeerID inside foundPeers array")
            return
        }
        foundPeers.remove(at: index)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(Thread.isMainThread)
        print(error.localizedDescription)
    }
}


extension MCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(Thread.isMainThread)
        switch state {
        case .connected:
            print("Connected to session: \(session)")
            DispatchQueue.main.async {
                self.discoveryDelegate?.connectedWithPeer(isHost: self.isHost)
            }
        case .connecting:
            print("Connecting to session: \(session)")
        case .notConnected:
            print("Did not connect to session: \(session)")
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(Thread.isMainThread)
        didReceive(data: data)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}

extension MCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(Thread.isMainThread)
        discoveryDelegate?.didReceiveInvitationFromPeer(peerName: peerID.displayName)
        self.invitationHandler = invitationHandler
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}
