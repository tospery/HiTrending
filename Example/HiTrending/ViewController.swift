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
        case repositories([GithubRepoItem])
        case developers([GithubDeveloperItem])
        case empty
    }

    private var contentMode: ContentMode = .empty

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 50
        tv.estimatedRowHeight = 88
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            let items = await ghTrendingRepositories()
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
            let items = await ghTrendingDevelopers()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none

        switch contentMode {
        case .repositories(let items):
            let repo = items[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = "\(repo.owner)/\(repo.repoName)"
            let lang = repo.programmingLanguage.isEmpty ? "—" : repo.programmingLanguage
            config.secondaryText =
                "\(lang) · ☆\(repo.totalStars) · \(repo.starsSince)\n\(repo.description)"
            config.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = config
        case .developers(let items):
            let dev = items[indexPath.row]
            var config = cell.defaultContentConfiguration()
            let title: String
            if dev.name.isEmpty {
                title = dev.username
            } else {
                title = "\(dev.name) (@\(dev.username))"
            }
            config.text = title
            config.secondaryText = "\(dev.popularRepoName)\n\(dev.popularRepoDescription)"
            config.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = config
        case .empty:
            break
        }
        return cell
    }
}
