//
//  ViewController.swift
//  HiTrending
//
//  Created by tospery on 04/09/2026.
//  Copyright (c) 2026 tospery. All rights reserved.
//

import HiTrending
import UIKit

class ViewController: UIViewController {

    private enum ContentMode {
        case repositories([HiTrendingRepository])
        case developers([HiTrendingDeveloper])
        case empty
    }

    private var contentMode: ContentMode = .empty

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 100
        tv.estimatedRowHeight = 100
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.register(DeveloperTableViewCell.self, forCellReuseIdentifier: DeveloperTableViewCell.reuseIdentifier)
        return tv
    }()

    private let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
    }()

    private lazy var reposBarButton = UIBarButtonItem(
        title: "仓库",
        style: .plain,
        target: self,
        action: #selector(loadRepositories)
    )

    private lazy var developersBarButton = UIBarButtonItem(
        title: "开发者",
        style: .plain,
        target: self,
        action: #selector(loadDevelopers)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "HiTrending"

        navigationItem.rightBarButtonItems = [reposBarButton, developersBarButton]

        view.addSubview(tableView)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    @objc private func loadRepositories() {
        setLoading(true)
        Task {
            let items = await HiTrending.shared.repositories()
            await MainActor.run {
                self.setLoading(false)
                self.contentMode = .repositories(items)
                self.tableView.reloadData()
            }
        }
    }

    @objc private func loadDevelopers() {
        setLoading(true)
        Task {
            let items = await HiTrending.shared.developers()
            await MainActor.run {
                self.setLoading(false)
                self.contentMode = .developers(items)
                self.tableView.reloadData()
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
        reposBarButton.isEnabled = !loading
        developersBarButton.isEnabled = !loading
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch contentMode {
        case .repositories(let items): return items.count
        case .developers(let items): return items.count
        case .empty: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch contentMode {
        case .repositories(let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            let repo = items[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = "\(repo.owner)/\(repo.repoName)"
            let lang = repo.programmingLanguage.isEmpty ? "—" : repo.programmingLanguage
            config.secondaryText =
                "\(lang) · ☆\(repo.totalStars) · \(repo.starsSince)\n\(repo.description)"
            config.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = config
            return cell
        case .developers(let items):
            let devCell =
                tableView.dequeueReusableCell(
                    withIdentifier: DeveloperTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as! DeveloperTableViewCell
            devCell.configure(with: items[indexPath.row])
            return devCell
        case .empty:
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
    }
}
