//
//  PostViewController.swift
//  ThingLog
//
//  Created by 이지원 on 2021/11/09.
//

import CoreData
import UIKit

/// 게시물을 표시하는 뷰 컨트롤러
final class PostViewController: BaseViewController {
    // MARK: - View Properties
    let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    // MARK: - Properties
    var coordinator: PostCoordinatorProtocol?
    var canShowPosts: Bool {
        viewModel.fetchedResultsController.fetchedObjects?.count ?? 0 > 0
    }
    private(set) var viewModel: PostViewModel

    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isMovingToParent {
            let startIndexPath: IndexPath = IndexPath(row: viewModel.startIndexPath.row, section: 0)
            tableView.scrollToRow(at: startIndexPath, at: .top, animated: false)
        } else {
            if canShowPosts {
                UIView.performWithoutAnimation {
                    let contentOffset: CGPoint = tableView.contentOffset
                    tableView.reloadData()
                    tableView.contentOffset = contentOffset
                }
            } else {
                coordinator?.back()
            }
        }
    }

    // MARK: - Setup
    override func setupNavigationBar() {
        setupBaseNavigationBar()

        let logoView: LogoView = LogoView("게시물")
        navigationItem.titleView = logoView

        let backButton: UIButton = UIButton()
        backButton.setImage(SwiftGenIcons.longArrowR.image.withTintColor(SwiftGenColors.primaryBlack.color), for: .normal)
        backButton.rx.tap
            .bind { [weak self] in
                self?.coordinator?.back()
            }
            .disposed(by: disposeBag)
        let backBarButton: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButton
    }

    override func setupView() {
        setupTableView()
    }

    // MARK: - Public
    /// 일반 게시물에서 삭제 버튼을 누른 경우 휴지통으로 이동하기 전 표시하는 알럿
    func showTrashPostAlert(post: PostEntity) {
        let alert: AlertViewController = AlertViewController()
        alert.hideTextField()
        alert.hideTitleLabel()
        alert.contentsLabel.text = "게시물을 정말 삭제하시겠어요?"
        alert.leftButton.setTitle("취소", for: .normal)
        alert.rightButton.setTitle("삭제", for: .normal)
        alert.modalPresentationStyle = .overFullScreen
        alert.leftButton.rx.tap.bind {
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        alert.rightButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            post.postType?.isDelete = true
            post.deleteDate = Date()
            self.viewModel.repository.update(post, completion: { result in
                switch result {
                case .success:
                    self.tableView.reloadData()
                    // 표시할 수 있는 데이터가 없다면 이전 화면으로 이동한다.
                    if !self.canShowPosts {
                        self.coordinator?.back()
                    }
                case .failure(let error):
                    fatalError("\(#function): \(error.localizedDescription)")
                }
            })
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        present(alert, animated: false, completion: nil)
    }

    /// 휴지통>게시물에서 삭제 버튼을 누른 경우 표시하는 알럿
    func showRemoveAlert(with item: PostEntity) {
        let alert: AlertViewController = AlertViewController()
        alert.hideTextField()
        alert.hideTitleLabel()
        alert.contentsLabel.text = "정말 삭제하시겠어요?\n이 동작은 취소할 수 없습니다."
        alert.leftButton.setTitle("취소", for: .normal)
        alert.rightButton.setTitle("삭제", for: .normal)
        alert.modalPresentationStyle = .overFullScreen
        alert.leftButton.rx.tap.bind {
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        alert.rightButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.viewModel.repository.delete([item]) { result in
                switch result {
                case .success:
                    self.tableView.reloadData()
                    // 보여줄 수 있는 게시물이 없다면 이전 화면으로 돌아간다.
                    if !self.canShowPosts {
                        self.coordinator?.back()
                    }
                case .failure(let error):
                    fatalError("\(#function): \(error.localizedDescription)")
                }
            }
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        present(alert, animated: false, completion: nil)
    }

    /// 휴지통>게시물에서 복구 버튼을 누른 경우 표시하는 알럿
    func showRecoverAlert(with item: PostEntity) {
        let alert: AlertViewController = AlertViewController()
        alert.hideTextField()
        alert.hideTitleLabel()
        alert.contentsLabel.text = "해당 게시물을 복구하시겠어요?"
        alert.leftButton.setTitle("취소", for: .normal)
        alert.rightButton.setTitle("복구", for: .normal)
        alert.modalPresentationStyle = .overFullScreen
        alert.leftButton.rx.tap.bind {
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        alert.rightButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.viewModel.repository.recover([item], completion: { result in
                switch result {
                case .success:
                    do {
                        try self.viewModel.fetchedResultsController.performFetch()
                        self.tableView.reloadData()
                        // 보여줄 수 있는 게시물이 없다면 이전 화면으로 돌아간다.
                        if !self.canShowPosts {
                            self.coordinator?.back()
                        }
                    } catch {
                        print("\(#function): \(error.localizedDescription)")
                    }
                case .failure(let error):
                    fatalError("\(#function): \(error.localizedDescription)")
                }
            })
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        present(alert, animated: false, completion: nil)
    }
}
