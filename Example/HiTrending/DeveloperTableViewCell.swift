//
//  DeveloperTableViewCell.swift
//  HiTrending_Example
//

import HiTrending
import UIKit

final class DeveloperTableViewCell: UITableViewCell {

    static let reuseIdentifier = "DeveloperTableViewCell"

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 28
        iv.backgroundColor = .tertiarySystemFill
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .headline)
        l.numberOfLines = 1
        return l
    }()

    private let usernameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let singleDetailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let repoNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.numberOfLines = 0
        return l
    }()

    private let repoDescLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .footnote)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private lazy var textStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [
            nameLabel, usernameLabel, singleDetailLabel, repoNameLabel, repoDescLabel,
        ])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 4
        s.alignment = .leading
        return s
    }()

    private var imageLoadTask: Task<Void, Never>?
    private var expectedAvatarURL: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarView)
        contentView.addSubview(textStack)
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            avatarView.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            avatarView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),

            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 4),
            textStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with dev: HiTrendingDeveloper) {
        nameLabel.isHidden = dev.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        nameLabel.text = dev.name

        let userTrimmed = dev.username.trimmingCharacters(in: .whitespacesAndNewlines)
        usernameLabel.isHidden = userTrimmed.isEmpty
        usernameLabel.text = userTrimmed.isEmpty ? nil : "@\(userTrimmed)"

        let joined = dev.joinedDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let org = dev.organizationName.trimmingCharacters(in: .whitespacesAndNewlines)

        if !joined.isEmpty {
            singleDetailLabel.isHidden = false
            singleDetailLabel.text = joined
            repoNameLabel.isHidden = true
            repoDescLabel.isHidden = true
        } else if !org.isEmpty {
            singleDetailLabel.isHidden = false
            singleDetailLabel.text = org
            repoNameLabel.isHidden = true
            repoDescLabel.isHidden = true
        } else {
            singleDetailLabel.isHidden = true
            repoNameLabel.isHidden = false
            repoDescLabel.isHidden = false
            repoNameLabel.text = dev.popularRepoName
            repoDescLabel.text = dev.popularRepoDescription
        }

        let avatarTrimmed = dev.avatar.trimmingCharacters(in: .whitespacesAndNewlines)
        expectedAvatarURL = avatarTrimmed.isEmpty ? nil : avatarTrimmed
        loadAvatar(from: avatarTrimmed)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        expectedAvatarURL = nil
        avatarView.image = nil
        nameLabel.isHidden = false
        usernameLabel.isHidden = false
        singleDetailLabel.isHidden = true
        repoNameLabel.isHidden = true
        repoDescLabel.isHidden = true
    }

    private func loadAvatar(from urlString: String) {
        imageLoadTask?.cancel()
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            avatarView.image = nil
            return
        }
        imageLoadTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                guard let image = UIImage(data: data) else { return }
                await MainActor.run { [weak self] in
                    guard let self, self.expectedAvatarURL == urlString else { return }
                    self.avatarView.image = image
                }
            } catch {}
        }
    }
}
