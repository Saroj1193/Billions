//
//  ChatListVC.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit
import Firebase
import SDWebImage

class ChatListVC: BaseViewController {
    // MARK: - Variable
    @IBOutlet var tblChat: UITableView!
    var listener: ListenerRegistration?
    var listenerUser: ListenerRegistration?
    var msgData : [MessageData] = []
    var lastChatId : Timestamp!
    var profileImg: ProfileImageView = ProfileImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblChat.register(UINib.init(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
        self.listener?.remove()
        self.listenerUser?.remove()
    }
    
    func configureNavigationBar() {
        self.navigationBarWith(.withTitle, title: strChat)
        self.navigationItem.hidesBackButton = true
        extendedLayoutIncludesOpaqueBars = true
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(rightBarButtonDidTap) )
        navigationItem.rightBarButtonItem = rightBarButton
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(leftBarButtonDidTap))
        tap.numberOfTapsRequired = 1
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tap)
        profileImg.clipsToBounds = true
        DispatchQueue.main.async {
            self.profileImg.isRoundRect = true
        }
        
        guard let urlString = APPData.appDelegate.loginUserData[0].thumbnailPhotoURL else { return }
        let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
        let placeholder = UIImage(named: "UserpicIcon")?.resizeImage(targetSize: CGSize(width: 30, height: 30))
        self.profileImg.sd_setImage(with: URL(string: urlString), placeholderImage: placeholder, options: options) { (image, _, cacheType, _) in
          guard image != nil else { return }
          guard cacheType != .memory, cacheType != .disk else {
              self.profileImg.image = image?.resizeImage(targetSize: CGSize(width: 30, height: 30))
            return
          }
          UIView.transition(with: self.profileImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
              self.profileImg.image = image?.resizeImage(targetSize: CGSize(width: 30, height: 30))
          }, completion: nil)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImg)
    }
    
    @objc func rightBarButtonDidTap () {
        let vc = GlobalFunction.fetchViewControllerWithName("FriendsListVC", storyBoardName: AppStoryboard.registration.rawValue) as! FriendsListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func leftBarButtonDidTap () {
        let vc = GlobalFunction.fetchViewControllerWithName("UserProfileVC", storyBoardName: AppStoryboard.registration.rawValue) as! UserProfileVC
        vc.type = .edit
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getData(){
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
        
        FireStoreChat.shared.getChatListData(docId: currentUID) { (data) in
            self.msgData  = []
            var arr = [MessageData]()

            for dataObj in data{
                if self.msgData.count == 0 {
                    self.lastChatId =  (data[0][strtimeStamp] as! Timestamp)
                }
                arr.append(MessageData(dictionary: dataObj))
            }
            self.msgData = arr
            self.tblChat.reloadData()
            self.setDbListner()
            self.setUserListner()
        }
    }
    
    // MARK: - Set user listner
    func setUserListner(){
        self.listenerUser = Firestore.firestore().collection(usersCollection).whereField(strname, isNotEqualTo: "").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                if !snapshot.metadata.hasPendingWrites {
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .modified) {
                            if let userId = diff.document[struserId] as? String {
                                print(diff.document.data())
                                if let index = self.msgData.firstIndex(where: {$0.RID == userId }){
                                    let user = UserData.init(dictionary: diff.document.data())
                                    self.msgData[index].onlineStatusR = user.onlineStatus
                                    self.msgData[index].RName = user.name
                                    self.msgData[index].RTImage = user.thumbnailPhotoURL
                                    self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                                    Firestore.firestore().collection(dataCollection).document(self.msgData[index].chatID  ?? "").updateData(([strOnlineStatusR: user.onlineStatus!, strRName : user.name ?? "", strRTImage : user.thumbnailPhotoURL ?? ""])) { error in
                                        print("Errooooo111:--", error)
                                    }
                                } else if let index = self.msgData.firstIndex(where: {$0.SID == userId }){
                                    let user = UserData.init(dictionary: diff.document.data())
                                    self.msgData[index].onlineStatusS = user.onlineStatus
                                    self.msgData[index].SName = user.name
                                    self.msgData[index].STImage = user.thumbnailPhotoURL
                                    self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                                    Firestore.firestore().collection(dataCollection).document(self.msgData[index].chatID  ?? "").updateData(([strOnlineStatusS: user.onlineStatus!, strSName : user.name ?? "", strSTImage : user.thumbnailPhotoURL ?? ""])) { error in
                                        print("Errooooo111:--", error)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
    }
    
    func setDbListner(){
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
               
        let ref = Firestore.firestore().collection(dataCollection).whereField(strusersIDs, arrayContainsAny: [currentUID]).order(by: strtimeStamp, descending: true)
        
       listener = ref.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
        
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .added) {
                        if let id = (diff.document[strtimeStamp] as? Timestamp) {
                            self.lastChatId = id
                            if self.msgData.count > 0 {
                                let isAdd = self.msgData.filter({$0.timeStamp as? Timestamp == self.lastChatId })
                                if isAdd.count == 0 {
                                    self.msgData.insert(MessageData(dictionary: diff.document.data()), at: 0)
                                    self.tblChat.reloadData()
                                    self.tblChat.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: .top, animated: true)
                                }
                            } else {
                                self.msgData.insert(MessageData(dictionary: diff.document.data()), at: 0)
                                self.tblChat.reloadData()
                                self.tblChat.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: .top, animated: true)
                            }
                            
                        }
                    }
                    if (diff.type == .modified) {
                        if let time = diff.document[strchatID] as? String {
                            if let index = self.msgData.firstIndex(where: {$0.chatID == time }){
                                self.msgData[index] = MessageData(dictionary: diff.document.data())
                                self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                            }
                        }
                    }
//                    if (diff.type == .removed) {
//                        if let time = diff.document["timeStamp"] as? NSNumber {
//                            if let index = self.arrData.firstIndex(where: {$0["timeStamp"] as? NSNumber == time }){
//                                self.arrData.remove(at: index)
//                                self.tblChat.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
//                            }
//                        }
//                    }
                }
            }
    }
}

extension ChatListVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        if self.msgData[indexPath.row].SID ?? "" == APPData.appDelegate.loginUserData[0].userId ?? "" {
            cell.setReceiverCall(self.msgData[indexPath.row])
        } else {
            cell.setSenderCall(self.msgData[indexPath.row])
        }
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic : UserData = UserData()
        
        if self.msgData[indexPath.row].SID ?? "" == APPData.appDelegate.loginUserData[0].userId ?? "" {
            
            dic.id = self.msgData[indexPath.row].timeStamp as? Timestamp ?? Timestamp()
            dic.userId = self.msgData[indexPath.row].RID ?? ""
            dic.name = self.msgData[indexPath.row].RName ?? ""
            dic.photoURL = self.msgData[indexPath.row].RTImage ?? ""
            dic.thumbnailPhotoURL = self.msgData[indexPath.row].RTImage ?? ""
            dic.onlineStatus = self.msgData[indexPath.row].onlineStatusR
        } else {
            dic.id = self.msgData[indexPath.row].timeStamp as? Timestamp ?? Timestamp()
            dic.userId = self.msgData[indexPath.row].SID ?? ""
            dic.name = self.msgData[indexPath.row].SName ?? ""
            dic.photoURL = self.msgData[indexPath.row].STImage ?? ""
            dic.thumbnailPhotoURL = self.msgData[indexPath.row].STImage ?? ""
            dic.onlineStatus = self.msgData[indexPath.row].onlineStatusS
        }
        
        let userData : [UserData] = [dic]
        let vc = GlobalFunction.fetchViewControllerWithName("ChatDetailsVC", storyBoardName: AppStoryboard.registration.rawValue) as! ChatDetailsVC
        vc.userData = userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
