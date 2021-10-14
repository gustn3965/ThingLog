//
//  ContentsCollectionViewCell.swift
//  ThingLog
//
//  Created by hyunsu on 2021/09/22.
//
import CoreData
import UIKit

/// 기본적인 이미지만을 보여주기 위한 cell이다.
///
/// 기본적인 구성으로는 imageView, smallIconView 로 구성된다. smallIconView는 이미지가 여러개인 경우에 표시한다.
///
/// 추가적으로 하단의 그라데이션뷰와, 하단의 label, 우측상단의 체크버튼이 존재한다. ( 이는 휴지통 화면에서 재사용하기 위해 존재한다 )
/// ```swift
/// // 휴지통 화면에서 사용하고자 하는 경우
/// cell.smallIconView.isHidden = true
/// cell.bottomGradientView.isHidden = false
/// cell.bottomLabel.isHidden = false
/// cell.checkButton.isHidden = false
/// ```
class ContentsCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageview: UIImageView = UIImageView()
        imageview.backgroundColor = .clear
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    var testLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = SwiftGenColors.systemBlue.color
        label.font = UIFont.systemFont(ofSize: 9)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // smallIconView는 이미지가 여러개인 경우에 표시한다.
    let smallIconView: UIImageView = {
        let image: UIImage? = UIImage(systemName: "square.on.square.fill")
        let imageView: UIImageView = UIImageView(image: image)
        imageView.transform = CGAffineTransform(rotationAngle: .pi)
        imageView.tintColor = SwiftGenColors.white.color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 하단에 그라데이션을 강조하기 위한 뷰다 ( 주로 휴지통 화면에서 사용된다 )
    private let bottomGradientView: UIView = {
        let view: UIView = UIView()
        view.alpha = 0.6
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 하단에 정보를 표시하기 위한 Label이다 ( 주로 휴지통 화면에서 몇일 남았는지를 알려주기 위해 사용된다 )
    let bottomLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = SwiftGenColors.white.color
        label.font = UIFont.Pretendard.body3
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.text = "20일"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    /// 우측 상단에 체크하기 위한 버튼이다. ( 주로 휴지통 화면에서 삭제 또는 복구하기 위해 사용되는 버튼이다 )
    let checkButton: UIButton = {
        let button: UIButton = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = SwiftGenColors.white.color.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let paddingCheckButton: CGFloat = 8
    private let checkButtonSize: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(smallIconView)
        contentView.addSubview(bottomGradientView)
        contentView.addSubview(bottomLabel)
        contentView.addSubview(checkButton)
        checkButton.layer.cornerRadius = checkButtonSize / 2
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            smallIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            smallIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
            smallIconView.widthAnchor.constraint(equalToConstant: 10),
            smallIconView.heightAnchor.constraint(equalToConstant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 124),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomGradientView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1 / 5),
            
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            
            checkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: paddingCheckButton),
            checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingCheckButton),
            checkButton.widthAnchor.constraint(equalToConstant: checkButtonSize),
            checkButton.heightAnchor.constraint(equalToConstant: checkButtonSize)
        ])
        testSetupLabel()
    }
    
    func testSetupLabel() {
        contentView.addSubview(testLabel)
        NSLayoutConstraint.activate([
            testLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            testLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            testLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// PostEntity를 기반으로 뷰를 업데이트한다.
    /// - Parameter postEntity: 특정 PostEntity를 주입한다.
    func updateView(_ postEntity: PostEntity) {
        var text: String = ""
        text += "제목: " + postEntity.title!
        text += "\n카테고리: " + (postEntity.categories?.allObjects as? [CategoryEntity])!.map { $0.title! }.joined(separator: " - ") + "\(postEntity.categories?.count ?? 0)"
        text += "\n가격: " + String(postEntity.price)
        text += "\n" + (postEntity.isLike ? "좋아요" : "싫어요")
        text += "\n날짜: " + (postEntity.createDate!.toString(.year)) + "." + (postEntity.createDate!.toString(.month)) + "." + (postEntity.createDate!.toString(.day))
        text += "\n만족도: " + String(postEntity.rating!.score)
        imageView.image = UIImage(data: (postEntity.attachments?.allObjects as? [AttachmentEntity])![0].thumbnail!)
        testLabel.text = text
    }
    
    /// 그라데이션 뷰의 크기를 결정하기 위해 구현한다.
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomGradientView.frame = contentView.bounds
        bottomGradientView.frame.size.height = contentView.bounds.height / 4
        bottomGradientView.setGradient(startColor: SwiftGenColors.black.color,
                                       endColor: .clear,
                                       startPoint: CGPoint(x: 0.0, y: 1.0),
                                       endPoint: CGPoint(x: 0.0, y: 0.0))
    }
}
