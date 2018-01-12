//
//  GameDetailVC.swift
//  Banjo
//
//  Created by Jarrod Parkes on 12/29/16.
//  Copyright © 2016 ParkesTwins. All rights reserved.
//

import UIKit

// MARK: - GameDetailVC: UIViewController, NibLoadable

class GameDetailVC: UIViewController, NibLoadable {
    
    // MARK: Properties
    
    var game: Game?
    let reuseIdentifier = AppConstants.IDs.genreCell
    var sizingCell: GenreCell?
    
    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var ratingFieldLabel: UILabel!
    @IBOutlet weak var developerFieldLabel: UILabel!
    @IBOutlet weak var debugCoverLabel: UILabel!    
    @IBOutlet weak var coverLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var regionSelectButton: UIBarButtonItem!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playersImage: UIImageView!
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func backToSearch(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: Setup UI
    
    private func setupUI() {
        let genreCellNib = UINib(nibName: AppConstants.Nibs.genreCell, bundle: nil)
        let genreCellLayout = GenreCellLayout()
        genreCellLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        genreCollectionView.collectionViewLayout = genreCellLayout
        genreCollectionView.register(genreCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        sizingCell = (genreCellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! GenreCell?
        detailScrollView.contentInset.bottom = 30
        setupUIForRelease()
    }
    
    private func setupUIForRelease() {
        if let game = game {
            
            // reset image
            coverLoadingIndicator.startAnimating()
            coverLoadingIndicator.isHidden = false
            debugCoverLabel.isHidden = true
            coverImageView.image = nil
            
            developerLabel.text = "\(game.developers)"
            publisherLabel.text = "\(game.publishers)"
            summaryLabel.text = game.summary
            // regionSelectButton.title = game.
            titleLabel.text = game.name
            releaseDateLabel.text = "\(game.firstReleaseDate)"
            
            // number of players
            if let playersLabelTuple = playersLabelText(game: game), playersLabelTuple.0 {
                playersImage.isHidden = false
                playersLabel.isHidden = false
                playersLabel.text = playersLabelTuple.1
            } else {
                playersImage.isHidden = true
                playersLabel.isHidden = true
            }
            
            // game rating
//            if let rating = release.rating, let ratingSystemAbbrevation = rating.system?.abbreviation {
//                ratingLabel.isHidden = false
//                ratingFieldLabel.isHidden = false
//                ratingLabel.text = rating.name
//                ratingFieldLabel.text = "\(ratingSystemAbbrevation) \(AppConstants.Strings.rating)"
//            } else {
//                ratingLabel.isHidden = true
//                ratingFieldLabel.isHidden = true
//            }
            
            // cover image
            // FIXME: check cache for image
            
            let filePath = game.cover.url as NSString
            let fileExtension = filePath.pathExtension
            
            if let url = URL(string: "https://images.igdb.com/igdb/image/upload/\(game.cover.cloudinaryID).\(fileExtension)"), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                coverImageView.image = image
            }
        }
    }
    
    private func playersLabelText(game: Game) -> (Bool, String)? {
//        let players = (game.playersMin.value, game.playersMax.value)
//        switch(players) {
//        case (nil, nil):
//            return (false, "")
//        case (let min, nil):
//            return (true, "\(min!)")
//        case (nil, let max):
//            return (true, "\(max!)")
//        case (let min, let max):
//            return (true, "\(min!) - \(max!)")
//        }
        return (true, "")
    }
}

// MARK: - GameDetailVC: UICollectionViewDelegate, UICollectionViewDataSource

extension GameDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let game = game {
            return game.genres.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GenreCell
        configureCell(genreCell: cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(genreCell: GenreCell, forIndexPath indexPath: IndexPath) {
        if let game = game {
            let genre = game.genres[indexPath.row]
            switch(indexPath.row) {
            case 0:
                genreCell.backgroundColor = .banjoFern
            case 1:
                genreCell.backgroundColor = .banjoCornflowerBlue
            case 2:
                genreCell.backgroundColor = .banjoBlueberry
            case 3:
                genreCell.backgroundColor = .banjoGolden
            default:
                genreCell.backgroundColor = .banjoBrickOrange
            }
            genreCell.nameLabel.text = "\(genre)"
        }
    }
}

// MARK: - GameDetailVC: UICollectionViewDelegateFlowLayout

extension GameDetailVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        configureCell(genreCell: sizingCell!, forIndexPath: indexPath)
        return sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
}
