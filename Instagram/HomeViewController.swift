//
//  HomeViewController.swift
//  Instagram
//
//  Created by 佐藤佳子 on 2023/01/13.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var offset: CGPoint?
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // ジェスチャーが認識されたときのタッチがビューに配信するようにする
        self.view.addGestureRecognizer(tapGesture)

        // keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    // ホーム画面が閉じられるときに呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        // コメントを投稿するボタンを押した時のアクションをソースコードで設定する
        cell.commentPostButton.addTarget(self, action:#selector(handleButtonPostComment(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    // コメントを投稿するボタンを押したときの処理
    @objc func handleButtonPostComment(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: comment投稿ボタンがタップされました。")

        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let selectCell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        print("DEBUG_PRINT commentText = \(selectCell.commentText.text!)")
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        // FireStoreに投稿データを保存する
        let name = Auth.auth().currentUser?.displayName
        let commentDic = [
            "name": name!,
            "comment": selectCell.commentText.text!,
        ] as [String : Any]
        // 更新データを作成する
        var updateValue : FieldValue
        updateValue = FieldValue.arrayUnion([commentDic])

        // commentsに更新データを書き込む
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
        postRef.updateData(["comments": updateValue])
        // TableViewの表示を更新する
        self.tableView.reloadData()
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    // キーボードを表示したときの処理
    @objc func keyboardWillShow(_ notification: NSNotification) {
        offset = tableView.contentOffset
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    // キーボードを非表示にしたときの処理
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            if let unwrappedOffset = self.offset {
                self.tableView.contentOffset = unwrappedOffset
            }
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
}
