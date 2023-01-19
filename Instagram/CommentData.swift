//
//  CommentData.swift
//  Instagram
//
//  Created by 佐藤佳子 on 2023/01/17.
//

import UIKit
import Firebase

class CommentData: NSObject {
    var name: String? // コメントを投稿したユーザー名
    var comment: String? // コメント
    init(document: QueryDocumentSnapshot) {
        let commentDic = document.data()
        self.name = commentDic["name"] as? String
        self.comment = commentDic["comment"] as? String
    }
}
