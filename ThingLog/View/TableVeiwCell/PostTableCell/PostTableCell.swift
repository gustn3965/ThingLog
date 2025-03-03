//
//  PostTableCell.swift
//  ThingLog
//
//  Created by 이지원 on 2021/11/02.
//

import CoreData
import UIKit

import RxCocoa
import RxSwift

/// 게시물을 표시하는데 사용하는 뷰
/// [이미지](https://www.notion.so/PostTableCell-667e8e6eb38c4dd4b6bdf45ac6b4614d)
final class PostTableCell: UITableViewCell {
    // MARK: - View Properties
    /// 날짜, 기타 메뉴(수정, 삭제)를 포함한 뷰
    let headerContainerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    let dateLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let date: Date = Date()
        label.text = "\(date.toString(.year))년 \(date.toString(.month))월 \(date.toString(.day))일"
        label.font = UIFont.Pretendard.body2
        label.textColor = SwiftGenColors.primaryBlack.color
        return label
    }()

    lazy var moreMenuButton: DropDownView = {
        let button: DropDownView = DropDownView(superView: contentView)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// 게시물의 이미지를 보여주는 컬렉션 뷰
    let slideImageCollectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = .zero
        let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    /// 좋아요, 댓글, 이미지 위치, 포토카드를 포함한 뷰
    lazy var interactionContainerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .clear
        view.addSubviews(likeButton, commentButton, imageCountLabel, photocardButton)
        return view
    }()

    let likeButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SwiftGenIcons.likeStorke.image.withTintColor(SwiftGenColors.primaryBlack.color), for: .normal)
        button.setImage(SwiftGenIcons.likeFill.image.withTintColor(SwiftGenColors.primaryBlack.color), for: .selected)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.sizeToFit()
        return button
    }()

    let commentButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SwiftGenIcons.comments.image.withTintColor(SwiftGenColors.primaryBlack.color), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.sizeToFit()
        return button
    }()

    let imageCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.Pretendard.body2
        label.textColor = SwiftGenColors.primaryBlack.color
        return label
    }()

    let photocardButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SwiftGenIcons.photoCard.image.withTintColor(SwiftGenColors.primaryBlack.color), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.sizeToFit()
        return button
    }()

    /// 게시물의 카테고리를 표시하는 컬렉션 뷰
    let categoryCollectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    /// 물건 이름, 별점을 포함한 뷰
    lazy var firstInfoContainerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .clear
        view.addSubviews(nameLabel, ratingView)
        return view
    }()

    /// 물건 이름, 가로로 스크롤할 수 있다.
    let nameLabel: HorizontalScrollLabel = {
        let label: HorizontalScrollLabel = HorizontalScrollLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let ratingView: RatingView = {
        let ratingView: RatingView = RatingView(buttonSpacing: 4.0)
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.isUserInteractionEnabled = false
        ratingView.currentRating = 3
        return ratingView
    }()

    /// 장소, 가격을 포함한 뷰
    lazy var secondInfoContainerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .clear
        view.addSubviews(placeLabel, priceLabel, lineView)
        return view
    }()

    /// 판매처/구매처, 가로로 스크롤할 수 있다.
    let placeLabel: HorizontalScrollLabel = {
        let label: HorizontalScrollLabel = HorizontalScrollLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let priceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.Pretendard.title1
        label.textColor = SwiftGenColors.primaryBlack.color
        return label
    }()

    let lineView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SwiftGenColors.gray4.color
        return view
    }()

    /// 본문, 댓글 n개 모두 보기를 포함한 뷰
    lazy var contentsContainerView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [contentTextView, commentMoreButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        stackView.spacing = 7.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14.0,
                                                                     leading: 20.0,
                                                                     bottom: 14.0,
                                                                     trailing: 20.0)
        return stackView
    }()

    let contentTextView: UITextView = {
        let textView: UITextView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.Pretendard.body1
        textView.textColor = SwiftGenColors.primaryBlack.color
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.sizeToFit()
        return textView
    }()

    let commentMoreButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("댓글 n개 모두 보기", for: .normal)
        button.setTitleColor(SwiftGenColors.systemGreen.color, for: .normal)
        button.titleLabel?.font = UIFont.Pretendard.title2
        return button
    }()

    /// 특별한 상황(사고싶다, 휴지통)에서 쓰이는 샀어요 버튼, 삭제/복구 버튼을 포함한 뷰
    lazy var specificActionContainerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubviews(boughtButton, trashActionButton)
        view.isHidden = true
        return view
    }()

    let boughtButton: RoundCenterTextButton = {
        let button: RoundCenterTextButton = RoundCenterTextButton(cornerRadius: 0.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("샀어요 !", for: .normal)
        button.isHidden = true
        return button
    }()

    let trashActionButton: LeftRightButtonView = {
        let button: LeftRightButtonView = LeftRightButtonView(bottomLineIsHidden: false)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftButton.setTitle("삭제", for: .normal)
        button.rightButton.setTitle("복구", for: .normal)
        button.isHidden = true
        return button
    }()

    let emptyView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    /// 게시물을 표시하기 위한 모든 뷰를 포함한 스택 뷰
    lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [headerContainerView, slideImageCollectionView, interactionContainerView, categoryCollectionView, firstInfoContainerView, secondInfoContainerView, contentsContainerView, specificActionContainerView, emptyView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()

    // MARK: - Properties
    var identifier: String = ""
    let categoryViewDataSource: PostCategoryViewDataSouce = PostCategoryViewDataSouce()
    let slideImageViewDataSource: PostSlideImageViewDataSource = PostSlideImageViewDataSource()
    /// 현재 보여지고 있는 이미지 위치를 저장한다.
    var currentImagePage: Int = 1 {
        didSet { imageCountLabel.text = "\(currentImagePage)/\(imageCount)" }
    }
    var disposeBag: DisposeBag = DisposeBag()
    private(set) var imageCount: Int = 0 {
        didSet { imageCountLabel.text = "\(currentImagePage)/\(imageCount)" }
    }

    // MARK: - Init
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        identifier = ""
        currentImagePage = 1
        slideImageCollectionView.reloadData()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    func setupView() {
        backgroundColor = .clear
        contentView.addSubview(stackView)
        setupHeaderView()
        setupSlideImageCollectionView()
        setupInteractionView()
        setupCategoryCollectionView()
        setupFirstInfoView()
        setupSecondInfoView()
        setupSpecificActionContainerView()
        setupOtherView()

        setupStackView()
    }

    // MARK: - Public
    func configure(with post: PostEntity) {
        guard let type: PageType = post.postType?.pageType else {
            fatalError("\(#function): Not Found PageType")
        }

        identifier = post.identifier?.uuidString ?? ""

        // 날짜
        if let createDate: Date = post.createDate {
            dateLabel.text = "\(createDate.toString(.year))년 \(createDate.toString(.month))월 \(createDate.toString(.day))일"
        }

        // 이미지
        configureSlideImageView(with: post.attachments)

        // 좋아요 여부
        likeButton.isSelected = post.isLike

        // 카테고리
        configureCategory(with: post.categories)

        // 제목
        nameLabel.text = (post.title ?? "").isEmpty ? "물건 이름" : post.title
        nameLabel.configureLabel(isEmpty: (post.title ?? "").isEmpty)

        // 별점
        ratingView.currentRating = Int(post.rating?.score ?? 0)
        ratingView.isHidden = type == .wish ? true : false

        // 판매처/구매처
        configurePurchasePlaceLabel(type: type, place: post.purchasePlace, giver: post.giftGiver)

        // 가격
        configurePriceLabel(type: type, price: post.price)

        // 본문
        contentTextView.text = post.contents
        contentTextView.isHidden = contentTextView.text.isEmpty

        // 댓글 n개 모두 보기
        configureCommentMoreButton(with: post.comments?.allObjects.count)

        // 본문과 댓글이 없는 경우 뷰를 숨김 처리
        let hasContentAndComment: Bool = contentTextView.text.isEmpty && (post.comments?.allObjects.count ?? 0) == 0
        contentsContainerView.isHidden = hasContentAndComment
        lineView.isHidden = hasContentAndComment

        // SpecificAction (휴지통, 사고싶다)
        configureSpecificAction(type: type, isDelete: post.postType?.isDelete)
    }

    /// 현재 보여지고 있는 SlideImageCollectionView의 페이지 값을 업데이트한다.
    func updateCurrentImagePage() {
        let pageWidth: CGFloat = slideImageCollectionView.frame.size.width
        if pageWidth <= 0.0 {
            return
        }
        currentImagePage = Int(slideImageCollectionView.contentOffset.x / pageWidth) + 1
    }
}

// MARK: Configure Method
extension PostTableCell {
    /// SlideImageView의 데이터를 구성한다.
    private func configureSlideImageView(with attachments: NSSet?) {
        if let attachments: [AttachmentEntity] = attachments?.allObjects as? [AttachmentEntity] {
            let imageDatas: [Data] = attachments.sorted(by: {
                $0.createDate ?? Date() < $1.createDate ?? Date()
            }).compactMap { $0.imageData?.originalImage }
            slideImageViewDataSource.images = imageDatas.compactMap { UIImage(data: $0) }
            imageCount = imageDatas.count
            slideImageCollectionView.reloadData()
            currentImagePage = 1
        }
    }

    /// CategoryViewDataSource의 데이터를 구성한다. 카테고리가 선택되어있지 않는 경우, 기본값을 넣는다.
    private func configureCategory(with categories: NSSet?) {
        if let categories: [CategoryEntity] = categories?.allObjects as? [CategoryEntity] {
            categoryViewDataSource.items = categories.isEmpty ? ["카테고리"] : categories.compactMap { $0.title }
            categoryViewDataSource.isEmpty = categories.isEmpty
            categoryCollectionView.reloadData()
        }
    }

    /// PurchasePlace을 구성한다. `선물받았다` 게시물인 경우에 placeLabel에 선물 준 사람을 넣는다.
    /// - Parameters:
    ///   - type: 데이터가 없는 경우에 기본 값을 표시하기 위해서 필요하다.
    private func configurePurchasePlaceLabel(type: PageType, place: String?, giver: String?) {
        switch type {
        case .bought, .wish:
            if (place ?? "").isEmpty {
                placeLabel.text = type == .bought ? "구매처" : "판매처"
            } else {
                placeLabel.text = place
            }
            placeLabel.configureLabel(isEmpty: (place ?? "").isEmpty)
        case .gift:
            placeLabel.text = (giver ?? "").isEmpty ? "선물 준 사람" : giver
            placeLabel.configureLabel(isEmpty: (giver ?? "").isEmpty)
        }
    }

    /// PriceLabel 을 구성한다. PageType == .gift 인 경우 priceLabel. text = "" 로 설정한다.
    /// price 가 0인 경우 데이터가 없을 때로 가정하여 표시한다.
    private func configurePriceLabel(type: PageType, price: Int64) {
        if type == .gift {
            priceLabel.text = ""
            return
        }

        guard let formattedPrice: String = price.toStringWithComma() else {
            priceLabel.text = ""
            return
        }

        priceLabel.text = price == 0 ? "가격" : "\(formattedPrice) 원"
        priceLabel.font = price == 0 ? UIFont.Pretendard.body1 : UIFont.Pretendard.title1
        priceLabel.textColor = price == 0 ? SwiftGenColors.gray2.color : SwiftGenColors.primaryBlack.color
    }

    /// CommentMoreButton을 구성한다.
    /// count 가 0이거나 nil인 경우 commentMoreButton을 숨김 처리한다. 그렇지 않다면 "댓글 \(number)개 모두 보기"로 타이틀을 구성하고 표시한다.
    private func configureCommentMoreButton(with number: Int?) {
        if let number: Int = number, number != 0 {
            commentMoreButton.isHidden = false
            commentMoreButton.setTitle("댓글 \(number)개 모두 보기", for: .normal)
        } else {
            commentMoreButton.isHidden = true
        }
    }

    /// 휴지통이거나, 사고싶다 인 경우 버튼을 숨김/표시 처리한다.
    private func configureSpecificAction(type: PageType, isDelete: Bool?) {
        // 휴지통이면 삭제/복구 버튼 표시
        if let isDelete: Bool = isDelete, isDelete == true {
            specificActionContainerView.isHidden = false
            trashActionButton.isHidden = false
            boughtButton.isHidden = true
            return
        }

        // 사고싶다면 샀어요 버튼 표시, 아니라면 specificActionContainerView 숨김 처리
        if type == .wish {
            specificActionContainerView.isHidden = false
            trashActionButton.isHidden = true
            boughtButton.isHidden = false
        } else {
            specificActionContainerView.isHidden = true
        }
    }
}
