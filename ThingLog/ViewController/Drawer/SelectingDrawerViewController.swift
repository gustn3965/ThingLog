//
//  SelectingDrawerViewController.swift
//  ThingLog
//
//  Created by hyunsu on 2021/10/28.
//
import RxSwift
import UIKit

/// 진열장의 특정 아이템을 대표 아이템으로 설정하거나 아이템의 설명을 보기위한 뷰컨트롤러다.
class SelectingDrawerViewController: UIViewController {
    var coordinator: DrawerCoordinator?
    
    // MARK: - View
    var popupView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let drawerView: ImageWithTwoLabelVerticalCetnerXView = {
        let drawerView: ImageWithTwoLabelVerticalCetnerXView = ImageWithTwoLabelVerticalCetnerXView(imageViewHeight: 100)
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        return drawerView
    }()
    
    let information: UILabel = {
        let label: UILabel = UILabel()
        label.text = "30일간 꾸준히 기록했네요. 앞으로도 열심히 하라고 문구세트를 드립니다"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.Pretendard.body2
        label.textColor = SwiftGenColors.systemGreen.color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.init(rawValue: 50), for: .vertical)
        return label
    }()
    
    let selectButton: UIButton = {
        let button: UIButton = UIButton()
        button.clipsToBounds = true
        button.setTitleColor(SwiftGenColors.white.color, for: .normal)
        button.titleLabel?.font = UIFont.Pretendard.title1
        button.setTitle("대표 물건 지정", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var dimmedView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var popupViewBottomAnchor: NSLayoutConstraint?
    private let popupViewHeight: CGFloat = UIScreen.main.bounds.height / 1.8
    private let buttonHeight: CGFloat = 56
    private let padding: CGFloat = 20
    private let informaitonTopPadding: CGFloat = 10
    private let informaitonBottomPadding: CGFloat = 20
    private let drawerTopPadding: CGFloat = 40
    private var buttonBottomPadding: CGFloat {
        let window: UIWindow? = UIApplication.shared.windows.first
        let bottomPadding: CGFloat = window?.safeAreaInsets.bottom ?? 0.0
        return 20 + bottomPadding
    }
    
    var drawer: Drawerable
    var drawerRepository: DrawerRepositoryable = DrawerCoreDataRepository(coreDataStack: CoreDataStack.shared)
    var disposeBag: DisposeBag = DisposeBag()
    
    init(drawer: Drawerable) {
        self.drawer = drawer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDarkMode()
        addSubView()
        setupDimmedView()
        setupPopupView()
        setupBackgroundColor()
        
        subscribeDimmedView()
        subscribeSelectButton()
        
        setupDrawerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.dimmedView.backgroundColor = SwiftGenColors.dimmedColor.color.withAlphaComponent(0.6)
            self.popupViewBottomAnchor?.constant = 0
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.view.layoutIfNeeded()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.backgroundColor = .clear
            self.popupViewBottomAnchor?.constant = self.popupViewHeight
            self.view.layoutIfNeeded()
        } completion: { _ in
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    // MARK: - Setup
    func addSubView() {
        view.addSubviews(dimmedView, popupView)
        
        popupView.layer.cornerRadius = 17.0
        popupView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        popupView.addSubview(drawerView)
        popupView.addSubview(information)
        popupView.addSubview(selectButton)
    }
    
    private func setupBackgroundColor() {
        popupView.backgroundColor = SwiftGenColors.primaryBackground.color
        selectButton.backgroundColor = SwiftGenColors.primaryBlack.color
        view.backgroundColor = .clear
    }
    
    func setupDimmedView() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setupPopupView() {
        popupViewBottomAnchor = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupViewHeight)
        popupViewBottomAnchor?.isActive = true
        
        selectButton.layer.cornerRadius = buttonHeight / 2
        
        // 화면이 작은 경우에도 보여지기 위해 두 개의 Constraint를 준비
        let drawerTopAnchorMax: NSLayoutConstraint = drawerView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: drawerTopPadding)
        drawerTopAnchorMax.isActive = true
        drawerTopAnchorMax.priority = .init(rawValue: 150)
        
        let imageViewTopAnchorMin: NSLayoutConstraint = drawerView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10)
        imageViewTopAnchorMin.isActive = true
        imageViewTopAnchorMin.priority = .init(rawValue: 100)
        
        let buttonBottomAnchorMax: NSLayoutConstraint = selectButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -buttonBottomPadding)
        buttonBottomAnchorMax.isActive = true
        buttonBottomAnchorMax.priority = .init(rawValue: 150)
        
        let buttonBottomAnchorMin: NSLayoutConstraint = selectButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -5)
        buttonBottomAnchorMin.isActive = true
        buttonBottomAnchorMin.priority = .init(rawValue: 100)
        
        NSLayoutConstraint.activate([
            drawerView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            
            information.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            information.topAnchor.constraint(equalTo: drawerView.bottomAnchor, constant: informaitonTopPadding),
            information.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: padding),
            information.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -padding),
            information.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: -informaitonBottomPadding),
            
            selectButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: padding),
            selectButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -padding),
            selectButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            selectButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            popupView.heightAnchor.constraint(equalToConstant: popupViewHeight),
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupDrawerView() {
        selectButton.isHidden = !drawer.isAcquired
        drawerView.hideQuestionImageView(drawer.isAcquired)
        drawerView.hideTitleLabel(!drawer.isAcquired)
        information.isHidden = !drawer.isAcquired
        
        drawerView.setTitleLabel(fontType: UIFont.Pretendard.title1,
                                 color: SwiftGenColors.primaryBlack.color,
                                 text: drawer.title)
        drawerView.setSubLabel(fontType: UIFont.Pretendard.body1,
                               color: SwiftGenColors.primaryBlack.color,
                               text: drawer.subTitle)
        information.text = drawer.information
        
        guard let imageData: Data = drawer.imageData,
              var drawerImage: UIImage = UIImage(data: imageData) else {
            return
        }
        if drawer.isAcquired == false {
            drawerImage = drawerImage.withRenderingMode(.alwaysTemplate)
        }
        drawerView.setImage(drawerImage)
    }
}

extension SelectingDrawerViewController {
    /// View를 Subscribe하여 터치할 시 사라지도록 한다.
    func subscribeDimmedView() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        dimmedView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind { [weak self] _ in
            self?.coordinator?.detachSelectingDrawerViewController()
        }.disposed(by: disposeBag)
    }
    
    /// 대표물건으로 설정하여 뒤로 돌아간다.
    func subscribeSelectButton() {
        selectButton.rx.tap.bind { [weak self] in
            self?.drawerRepository.updateRepresentative(drawer: self?.drawer)
            self?.coordinator?.detachSelectingDrawerViewController()
        }.disposed(by: disposeBag)
    }
}
