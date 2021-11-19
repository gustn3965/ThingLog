//
//  WriteViewModel.swift
//  ThingLog
//
//  Created by 이지원 on 2021/10/03.
//

import Photos
import UIKit

import RxSwift

final class WriteViewModel {
    enum Section: Int, CaseIterable {
        case image
        case category
        /// 물건 이름, 가격 등 WriteTextField를 사용하는 항목을 나타내는 섹션
        case type
        case rating
        case contents
    }

    // MARK: - Properties
    var pageType: PageType
    /// WriteTextFieldCell을 표시할 때 필요한 keyboardType, placeholder 구성. writeType에 따라 개수가 다르다.
    var typeInfo: [(keyboardType: UIKeyboardType, placeholder: String)] {
        switch pageType {
        case .bought:
            return [(.default, "물건 이름"), (.numberPad, "가격"), (.default, "구매처")]
        case .wish:
            return [(.default, "물건 이름"), (.numberPad, "가격"), (.default, "판매처")]
        case .gift:
            return [(.default, "물건 이름"), (.default, "선물 준 사람")]
        }
    }
    /// Section 마다 표시할 항목의 개수
    lazy var itemCount: [Int] = [1, 1, typeInfo.count, 1, 1]
    /// 썸네일 크기
    private let thumbnailSize: CGSize = CGSize(width: 100, height: 100)
    /// 이미지가 저장될 크기
    private let imageSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    private let repository: PostRepository = PostRepository(fetchedResultsControllerDelegate: nil)
    private var isSelectImages: Bool = false

    // MARK: - Properties for save Post
    var price: Int = 0
    var rating: Int = 0
    var contents: String = ""
    lazy var typeValues: [String?] = Array(repeating: "", count: typeInfo.count)
    private(set) var originalImages: [UIImage] = []
    private var categories: [Category] = []

    // MARK: - Rx
    private(set) var thumbnailImagesSubject: BehaviorSubject<[UIImage]> = BehaviorSubject<[UIImage]>(value: [])
    private(set) var categorySubject: BehaviorSubject<[Category]> = BehaviorSubject<[Category]>(value: [])
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Init
    init(pageType: PageType) {
        self.pageType = pageType

        setupBinding()
    }

    // MARK: - setup
    private func setupBinding() {
        bindNotificationPassToSelectedCategories()
        bindNotificationPassSelectPHAssets()
        bindThumbnailImagesSubject()
        bindNotificationRemoveSelectedThumbnail()
        bindCategorySubject()
    }

    /// Core Data에 게시물을 저장한다.
    /// - Parameter completion: 성공 여부를 반환한다.
    func save(completion: @escaping (Bool) -> Void) {
        guard isSelectImages else {
            completion(false)
            return
        }

        let newPost: Post = createNewPost()

        repository.create(newPost) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }

    /// 사용자에게 입력받은 데이터를 토대로 Post 객체를 생성한다.
    private func createNewPost() -> Post {
        let title: String = typeValues[0] ?? ""
        var purchasePlace: String = ""
        var giftGiver: String = ""

        switch pageType {
        case .bought:
            price = Int(typeValues[1]?.filter("0123456789".contains) ?? "") ?? 0
            purchasePlace = typeValues[2] ?? ""
        case .wish:
            price = Int(typeValues[1]?.filter("0123456789".contains) ?? "") ?? 0
            purchasePlace = typeValues[2] ?? ""
        case .gift:
            giftGiver = typeValues[1] ?? ""
        }

        let attachments: [Attachment] = createAttachment()

        return Post(title: title,
                    price: price,
                    purchasePlace: purchasePlace,
                    contents: contents,
                    giftGiver: giftGiver,
                    postType: PostType(isDelete: false, type: pageType),
                    rating: Rating(score: ScoreType(rawValue: Int16(rating)) ?? ScoreType.unrated),
                    categories: categories,
                    attachments: attachments)
    }

    /// originalImages로 [Attachment] 를 생성한다.
    private func createAttachment() -> [Attachment] {
        var attachments: [Attachment] = []
        for index in 0..<originalImages.count {
            if let thumbnail: UIImage = try? thumbnailImagesSubject.value()[index] {
                let attachment: Attachment = Attachment(thumbnail: thumbnail,
                                                        imageData: .init(originalImage: originalImages[index]))
                attachments.append(attachment)
            }
        }
        return attachments
    }
}

extension WriteViewModel {
    /// `CategoryViewController`에서 전달받은 데이터를 `selectedCategoryIndexPaths`에 저장한다.
    private func bindNotificationPassToSelectedCategories() {
        NotificationCenter.default.rx.notification(.passToSelectedCategories, object: nil)
            .map { notification -> [Category] in
                notification.userInfo?[Notification.Name.passToSelectedCategories] as? [Category] ?? []
            }
            .bind { [weak self] categories in
                self?.categorySubject.onNext(categories)
            }.disposed(by: disposeBag)
    }

    /// PhotosViewController 에서 전달받은 데이터를 바인딩한다.
    private func bindNotificationPassSelectPHAssets() {
        NotificationCenter.default.rx
            .notification(.passSelectAssets, object: nil)
            .map { notification -> [PHAsset] in
                notification.userInfo?[Notification.Name.passSelectAssets] as? [PHAsset] ?? []
            }
            .bind { [weak self] assets in
                self?.requestThumbnailImages(with: assets)
                self?.requestOriginalImages(with: assets)
            }.disposed(by: disposeBag)
    }

    /// 이미지가 선택되어 있는 지 여부를 `isSelectImages` 에 갱신한다.
    private func bindThumbnailImagesSubject() {
        thumbnailImagesSubject
            .map { $0.isNotEmpty }
            .bind { [weak self] isNotEmpty in
                self?.isSelectImages = isNotEmpty
            }.disposed(by: disposeBag)
    }

    /// WriteImageTableCell 에서 삭제한 썸네일을 originalImages에서도 삭제한다.
    private func bindNotificationRemoveSelectedThumbnail() {
        NotificationCenter.default.rx
            .notification(.removeSelectedThumbnail)
            .map { notification -> IndexPath in
                notification.userInfo?[Notification.Name.removeSelectedThumbnail] as? IndexPath ?? IndexPath()
            }
            .bind { [weak self] indexPath in
                self?.originalImages.remove(at: indexPath.row - 1)
            }.disposed(by: disposeBag)
    }

    /// CategorySubject가 갱신될 때마다 categories에 저장한다.
    private func bindCategorySubject() {
        categorySubject
            .bind { [weak self] categories in
                self?.categories = categories
            }.disposed(by: disposeBag)
    }

    /// 파라미터로 전달받은 `PHAsset`을 `UIImage`로 변환하여 `thumbnailImagesSubject`에 저장한다.
    /// - Parameter assets: 가져올 데이터
    private func requestThumbnailImages(with assets: [PHAsset]) {
        var images: [UIImage] = []
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.isSynchronous = true

        assets.forEach { asset in
            asset.toImage(targetSize: self.thumbnailSize, options: options) { image in
                guard let image = image else { return }
                images.append(image)
                if images.count == assets.count {
                    self.thumbnailImagesSubject.onNext(images)
                }
            }
        }
    }

    /// 파라미터로 받은 `PHAsset`을 `UIImage`로 변환하여 originalImages에 저장한다. 비동기로 동작한다.
    /// - Parameter assets: UIImage로 변환할 [PHAsset]
    private func requestOriginalImages(with assets: [PHAsset]) {
        var images: [UIImage] = []
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.isSynchronous = true

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            assets.forEach { asset in
                asset.toImage(targetSize: self.imageSize, options: options) { image in
                    guard let image = image else { return }
                    images.append(image)
                    if images.count == assets.count {
                        self.originalImages = images
                    }
                }
            }
        }
    }
}
