//
//  FriendsListVC.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit
import SwiftyJSON
import Firebase
import SDWebImage

class FriendsListVC: BaseViewController {
    // MARK: - Variable
    @IBOutlet var tblList: UITableView!
    var arrData : [UserData] = []
    var listener: ListenerRegistration?
    
    var isForward = false
    var forwardData = [MessageListModel]()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        self.tblList.register(UINib.init(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: "FriendsCell")
        self.tblList.estimatedRowHeight = 70
        self.tblList.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationItem.backButtonTitle = ""
        self.getUserList()
        self.setDbListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listener?.remove()
    }
    
    // MARK: - Get user list
    func getUserList(){
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        self.showSpinner()
        FireStoreChat.shared.getUserListData(docId: currentUID) { data in
            self.arrData = [UserData]()
            self.hideSpinner()
            for doc in data {
                self.arrData.append(UserData.init(dictionary: doc))
            }
            self.arrData = self.arrData.sorted(by: {$0.name ?? "" < $1.name ?? ""})
            self.tblList.reloadData()
            
        }
    }
    
    // MARK: - Set user listner
    func setDbListner(){
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        self.listener = Firestore.firestore().collection(usersCollection).whereField(strname, isNotEqualTo: "").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                if !snapshot.metadata.hasPendingWrites {
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if diff.document[struserId] as? String ?? "" != currentUID {
                                self.arrData.append(UserData.init(dictionary: diff.document.data()))
                                self.arrData = self.arrData.sorted(by: {$0.name ?? "" < $1.name ?? ""})
                                self.tblList.reloadData()
                            }
                        }
                        if (diff.type == .modified) {
                            if let userId = diff.document[struserId] as? String {
                                if let index = self.arrData.firstIndex(where: {$0.userId == userId }){
                                    self.arrData[index] = UserData.init(dictionary: diff.document.data())
                                    self.arrData = self.arrData.sorted(by: {$0.name ?? "" < $1.name ?? ""})
                                    self.tblList.reloadData()
                                }
                            }
                        }
                        if (diff.type == .removed) {
                            if let userId = diff.document[struserId] as? String {
                                if let index = self.arrData.firstIndex(where: {$0.userId == userId }){
                                    self.arrData.remove(at: index)
                                    self.tblList.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                                }
                            }
                        }
                    }
                }
                
            }
    }
    
    func configureNavigationBar() {
        extendedLayoutIncludesOpaqueBars = true
        self.navigationBarWith(.withTitle, title: strFriendsList)
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension FriendsListVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblList.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
        cell.setFriendsCell(data: self.arrData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GlobalFunction.fetchViewControllerWithName("ChatDetailsVC", storyBoardName: AppStoryboard.registration.rawValue) as! ChatDetailsVC
        vc.userData = [self.arrData[indexPath.row]]
        vc.isForward = self.isForward
        vc.forwardData = self.forwardData
       
        self.navigationController?.pushViewController(vc, animated: true)
        
        var arr = self.navigationController?.viewControllers
        for i in 0..<arr!.count {
            if arr![i].isKind(of: FriendsListVC.self){
                arr?.remove(at: i)
                break
            }
        }
        if self.isForward {
            for i in 0..<arr!.count {
                if arr![i].isKind(of: ChatDetailsVC.self){
                    arr?.remove(at: i)
                    break
                }
            }
        }
        
        self.navigationController?.viewControllers = arr!
    }
}
