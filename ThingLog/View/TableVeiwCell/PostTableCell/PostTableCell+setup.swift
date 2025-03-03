//
//  PostTableCell+setup.swift
//  ThingLog
//
//  Created by 이지원 on 2021/11/02.
//

//
//  PostTableCell+setup.swift
//  ThingLog
//
//  Created by 이지원 on 2021/10/31.
//

import UIKit

// MARK: - PostTableCell Setup
extension PostTableCell {
    func setupHeaderView() {
        let headerViewHeight: CGFloat = 30.0
        let moreMenuButtonTrailingConstant: CGFloat = 18.0

        headerContainerView.addSubview(dateLabel)
        headerContainerView.addSubview(moreMenuButton)

        NSLayoutConstraint.activate([
            headerContainerView.heightAnchor.constraint(equalToConstant: headerViewHeight),
            dateLabel.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            moreMenuButton.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            moreMenuButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -moreMenuButtonTrailingConstant),
            moreMenuButton.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
    }

    func setupSlideImageCollectionView() {
        slideImageCollectionView.delegate = self
        slideImageCollectionView.dataSource = slideImageViewDataSource
        slideImageCollectionView.register(ContentsCollectionViewCell.self, forCellWithReuseIdentifier: ContentsCollectionViewCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            slideImageCollectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            slideImageCollectionView.heightAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }

    func setupInteractionView() {
        let interactionViewHeight: CGFloat = 44.0
        let leadingTrailingSpacing: CGFloat = 18.0
        let topBottomSpacing: CGFloat = 10.0
        let betweenSpacing: CGFloat = 12.0

        NSLayoutConstraint.activate([
            interactionContainerView.heightAnchor.constraint(equalToConstant: interactionViewHeight),
            likeButton.leadingAnchor.constraint(equalTo: interactionContainerView.leadingAnchor, constant: leadingTrailingSpacing),
            likeButton.topAnchor.constraint(equalTo: interactionContainerView.topAnchor, constant: topBottomSpacing),
            likeButton.bottomAnchor.constraint(equalTo: interactionContainerView.bottomAnchor, constant: -topBottomSpacing),
            commentButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: betweenSpacing),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            imageCountLabel.centerXAnchor.constraint(equalTo: interactionContainerView.centerXAnchor),
            imageCountLabel.centerYAnchor.constraint(equalTo: interactionContainerView.centerYAnchor),
            photocardButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            photocardButton.trailingAnchor.constraint(equalTo: interactionContainerView.trailingAnchor, constant: -leadingTrailingSpacing)
        ])
    }

    func setupCategoryCollectionView() {
        categoryCollectionView.collectionViewLayout = createCategoryCollectionViewLayout()
        categoryCollectionView.dataSource = categoryViewDataSource
        categoryCollectionView.register(LabelWithButtonRoundCollectionCell.self, forCellWithReuseIdentifier: LabelWithButtonRoundCollectionCell.reuseIdentifier)

        categoryCollectionView.heightAnchor.constraint(equalToConstant: 38.0).isActive = true
    }

    func setupFirstInfoView() {
        let firstInfoViewHeight: CGFloat = 38.0
        let leadingTrailingSpacing: CGFloat = 18.0

        NSLayoutConstraint.activate([
            firstInfoContainerView.heightAnchor.constraint(equalToConstant: firstInfoViewHeight),
            nameLabel.leadingAnchor.constraint(equalTo: firstInfoContainerView.leadingAnchor, constant: leadingTrailingSpacing),
            nameLabel.topAnchor.constraint(equalTo: firstInfoContainerView.topAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingView.leadingAnchor, constant: -leadingTrailingSpacing),
            nameLabel.bottomAnchor.constraint(equalTo: firstInfoContainerView.bottomAnchor),
            ratingView.centerYAnchor.constraint(equalTo: firstInfoContainerView.centerYAnchor),
            ratingView.trailingAnchor.constraint(equalTo: firstInfoContainerView.trailingAnchor, constant: -leadingTrailingSpacing)
        ])
    }

    func setupSecondInfoView() {
        let secondInfoViewHeight: CGFloat = 38.0
        let leadingTrailingSpacing: CGFloat = 18.0

        NSLayoutConstraint.activate([
            secondInfoContainerView.heightAnchor.constraint(equalToConstant: secondInfoViewHeight),
            placeLabel.leadingAnchor.constraint(equalTo: secondInfoContainerView.leadingAnchor, constant: leadingTrailingSpacing),
            placeLabel.topAnchor.constraint(equalTo: secondInfoContainerView.topAnchor),
            placeLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -leadingTrailingSpacing),
            placeLabel.bottomAnchor.constraint(equalTo: lineView.topAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: placeLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: secondInfoContainerView.trailingAnchor, constant: -leadingTrailingSpacing),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            lineView.leadingAnchor.constraint(equalTo: secondInfoContainerView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: secondInfoContainerView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: secondInfoContainerView.bottomAnchor)
        ])
    }

    func setupSpecificActionContainerView() {
        let buttonHeight: CGFloat = 52.0
        let boughtButtonLeadingTrailingSpacing: CGFloat = 20.0

        let heightConstraint: NSLayoutConstraint = specificActionContainerView.heightAnchor.constraint(equalToConstant: buttonHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        NSLayoutConstraint.activate([
            boughtButton.leadingAnchor.constraint(equalTo: specificActionContainerView.leadingAnchor, constant: boughtButtonLeadingTrailingSpacing),
            boughtButton.topAnchor.constraint(equalTo: specificActionContainerView.topAnchor),
            boughtButton.trailingAnchor.constraint(equalTo: specificActionContainerView.trailingAnchor, constant: -boughtButtonLeadingTrailingSpacing),
            boughtButton.bottomAnchor.constraint(equalTo: specificActionContainerView.bottomAnchor),

            trashActionButton.leadingAnchor.constraint(equalTo: specificActionContainerView.leadingAnchor),
            trashActionButton.topAnchor.constraint(equalTo: specificActionContainerView.topAnchor),
            trashActionButton.trailingAnchor.constraint(equalTo: specificActionContainerView.trailingAnchor),
            trashActionButton.bottomAnchor.constraint(equalTo: specificActionContainerView.bottomAnchor)
        ])
        boughtButton.layer.cornerRadius = buttonHeight / 2
    }

    func setupOtherView() {
        let emptySpacing: CGFloat = 40.0

        NSLayoutConstraint.activate([
            emptyView.heightAnchor.constraint(equalToConstant: emptySpacing)
        ])
    }

    func setupStackView() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func createCategoryCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .estimated(16),
                                                     heightDimension: .fractionalHeight(1))
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .estimated(1),
                                                      heightDimension: .fractionalHeight(1))
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])

        let section: NSCollectionLayoutSection = .init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)

        let layout: UICollectionViewCompositionalLayout = .init(section: section)

        return layout
    }
}

extension PostTableCell: UICollectionViewDelegate, UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = scrollView.frame.size.width
        currentImagePage = Int(slideImageCollectionView.contentOffset.x / pageWidth) + 1
    }
}
