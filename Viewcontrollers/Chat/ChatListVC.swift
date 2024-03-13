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
    var viewmodel: ChatListFireStoreViewModel = ChatListFireStoreViewModel()
    @IBOutlet var tblChat: UITableView!
    var msgData : [MessageData] = []
    var profileImg: ProfileImageView = ProfileImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblChat.register(UINib.init(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        self.viewmodel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
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
        let viewmodel = ChatDetailsFireStoreViewModel(userData: userData)
        vc.viewModel = viewmodel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatListVC: ChatListFireStoreDelegate {
    func userDataListner(_ data: [MessageData], _ index: IndexPath, _ isScroll: Bool) {
        self.msgData = data
        if isScroll {
            self.tblChat.reloadData()
            self.tblChat.scrollToRow(at: index, at: .top, animated: true)
        } else {
            self.tblChat.reloadRows(at: [index], with: .none)
        }
    }
    
    func getChatListData(_ data: [MessageData]) {
        self.msgData = data
        self.tblChat.reloadData()
    }
}
