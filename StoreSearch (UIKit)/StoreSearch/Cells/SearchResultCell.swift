//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Boris Ezhov on 02.03.2021.
//

import UIKit

class SearchResultCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!

  var downloadTask: URLSessionDownloadTask?

  override func awakeFromNib() {
    super.awakeFromNib()

    artworkImageView.layer.cornerRadius = 10
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
    selectedBackgroundView = selectedView
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    downloadTask?.cancel()
    downloadTask = nil
  }

  // MARK: - Helper Methods
  func configure(for result: SearchResult) {
    nameLabel.text = result.name
    artistNameLabel.text = result.artist.isEmpty ? NSLocalizedString("Unknown", comment: "Artist name label: unknown") : String(format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "Format for artist name"), result.artist, result.type)
    artworkImageView.image = UIImage(systemName: "square")
    if let smallUrl = URL(string: result.imageSmall) {
      downloadTask = artworkImageView.loadImage(url: smallUrl)
    }
  }
}
