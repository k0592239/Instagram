//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 佐藤佳子 on 2023/01/15.
//

import UIKit
import FirebaseStorageUI

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var commentPostButton: UIButton!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // 吹き出しボタンを押したときの処理
    @IBAction func commentButton(_ sender: Any) {
        // コメント入力欄の表示切り替え
        commentText.isHidden.toggle()
        commentPostButton.isHidden.toggle()
        updateCommentPostButton()
    }
    // コメント入力欄が変化したときの処理
    @IBAction func textEditingDidChanged(_ sender: Any) {
        // コメント入力欄の入力
        updateCommentPostButton()
    }
    // コメント入力欄の入力状態に応じて、コメント投稿ボタンの状態を変更する
    private func updateCommentPostButton() {
     if commentText.text == "" {
         commentPostButton.isEnabled = false
         commentPostButton.layer.opacity = 0.4
     } else {
         commentPostButton.isEnabled = true
         commentPostButton.layer.opacity = 1
     }
   }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpeg")
        postImageView.sd_setImage(with: imageRef)
    
        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        // コメント関連
        commentText.text = ""
        commentText.layer.cornerRadius = 30.0
        commentText.isHidden = true
        commentPostButton.isHidden = true
        let commentCout =   postData.comments.count
        commentCountLabel.text = "\(commentCout)"
        
    }
}
