
import UIKit
import SafariServices

class MainViewController: UIViewController {

    var collectionId: Int? {
        didSet {
            updateCollection(collectionId)
        }
    }

    var episode: Episode? {
        didSet {
            updateEpisode(episode)
        }
    }

    var genreTvId: Int? {
        didSet {
            updateGenreTv(genreTvId)
        }
    }

    var genreMovieId: Int? {
        didSet {
            updateGenreMovie(genreMovieId)
        }
    }

    var items: [Item]? {
        didSet {
            updateItems(items)
        }
    }

    var movieId: Int? {
        didSet {
            updateMovie(movieId)
        }
    }

    var networkId: Int? {
        didSet {
            updateNetwork(networkId)
        }
    }

    var personId: Int? {
        didSet {
            updatePerson(personId)
        }
    }

    var productionId: Int? {
        didSet {
            updateProduction(productionId)
        }
    }

    var seasonItem: Item? {
        didSet {
            updateSeason(seasonItem)
        }
    }

    var sortedBy: String? {
        didSet {
            updateSortedBy(sortedBy)
        }
    }

    var tvId: Int? {
        didSet {
            updateTv(tvId)
        }
    }

    // Data
    var screen: ScreenType = .landing
    var kind: Tmdb.MoviesType = .popular
    var dataSource: [Section] = []
    var search = TableSearch()
    var startSearch = false

    // UI
    var imageButton = ImageButton()
    let spinner = UIActivityIndicatorView(style: .large)
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var searchResultsButtons = StackButtons()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
        config()
        
        if screen == .landing {
            loadContent(kind)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if startSearch {
            navigationItem.searchController?.searchBar.becomeFirstResponder()
        }
    }

    deinit {
        print("deinit")
    }

}

private extension MainViewController {

    func setup() {
        navigationController?.navigationBar.tintColor = .systemTeal

        // table
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.regular.rawValue)
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.color.rawValue)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.separatorInset = .zero

        // search
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.delegate = self
        navigationItem.searchController = search

        // search results button
        searchResultsButtons.isHidden = true
        searchResultsButtons.delegate = self

        // long press on image button
        let interaction = UIContextMenuInteraction(delegate: self)
        imageButton.addInteraction(interaction) 
    }

    func config() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let button = barButtonItem(screen)
        navigationItem.rightBarButtonItem = button

        searchResultsButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultsButtons)
        NSLayoutConstraint.activate([
            searchResultsButtons.heightAnchor.constraint(equalToConstant: StackButtons.height), 
            searchResultsButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchResultsButtons.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }

}

extension MainViewController {

    func loadContent(_ kind: Tmdb.MoviesType?) {
        guard let kind = kind else { return }

        title = kind.title

        spinner.startAnimating()

        screen = .landing

        let updater = Updater(dataSource: [])
        updateScreen(updater)

        let provider = ContentDataProvider()
        provider.get(kind) { (movie, tv, people, articles) in
            let sections = Section.contentSections(kind: kind, movie: movie, tv: tv, people: people, articles: articles)
            let updater = Updater(dataSource: sections)
            self.updateScreen(updater)
        }

        self.kind = kind
    }

    func updateScreen(_ updater: Updater?) {
        updateTableHeaderHeader(image: updater?.image, buttonUrl: updater?.buttonUrl)

        spinner.stopAnimating()

        if let ds = updater?.dataSource {
            dataSource = ds
        }

        tableView.reloadData()
    }

}

private extension MainViewController {

    @objc
    func goHome() {
        navigationController?.popToRootViewController(animated: true)

        // TODO: seeing assert warning

        /**
         steps
         launch app
         tap on movie
         tap on box office
         tap on movie
         tap on box office
         tap on movie
         tap on home

         2020-05-10 21:09:14.775267-0700 FastMDb[78921:13778251] [Assert] Unexpected configuration of navigation stack. viewControllers = (
         "<FastMDb.MainViewController: 0x7f821b81ea00>"
         ), stack.items = (
         "<UINavigationItem: 0x7f821a40d8a0> title='Popular' rightBarButtonItems=0x600003520750 searchController=0x7f821b848e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a62f3e0> title='Ad Astra' rightBarButtonItems=0x600003521260 searchController=0x7f821b02b200 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a5433c0> title='Highest Grossing' rightBarButtonItems=0x60000352d1b0 searchController=0x7f821c016400 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a63f730> title='Titanic' rightBarButtonItems=0x600003527270 searchController=0x7f821b019e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a72a570> title='Highest Grossing' rightBarButtonItems=0x60000352d5c0 searchController=0x7f821c02ca00 hidesSearchBarWhenScrolling"
         )*/
    }

    @objc
    func imageTap(sender: ImageButton) {
        guard let url = sender.url else { return }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet
        present(sfvc, animated: true, completion: nil)
    }

    @objc
    func loadRandom() {
        let list = Tmdb.MoviesType.allCases.filter { $0.rawValue != kind.rawValue }
        let random = list.randomElement()

        loadContent(random)
    }

}

private extension MainViewController {

    func barButtonItem(_ screen: ScreenType) -> UIBarButtonItem {
        if screen == .landing {
            let image = UIImage(systemName: "shuffle")
            return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(loadRandom))
        }
        else {
            let image = UIImage(systemName: "house")
            return  UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goHome))
        }
    }

    var header: UIView {
        let headerView = UIView()

        var frame = view.bounds
        frame.size.height = 300
        headerView.frame = frame

        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(imageTap), for: .touchUpInside)

        headerView.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: inset),
            imageButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: inset),
            imageButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -inset),
            imageButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -inset),
        ])

        return headerView
    }

    func updateTableHeaderHeader(image: UIImage?, buttonUrl: URL?) {
        // TODO: show banner instead? looks better on ipad
        guard let image = image else { return }

        let h = header
        var frame = h.frame

        let ratio: CGFloat = image.size.height / image.size.width

        if ratio > 1 {
            let fixedHeight: CGFloat = h.frame.height
            frame.size.width = fixedHeight / ratio
            frame.size.height = fixedHeight
        } else {
            let fixed: CGFloat = h.frame.width
            frame.size.width = fixed
            frame.size.height = fixed * ratio
        }

        h.frame = frame

        tableView.tableHeaderView = h

        imageButton.setImage(image, for: .normal)

        imageButton.url = buttonUrl
    }

}

private extension MainViewController {

    func updateCollection(_ collectionId: Int?) {
        screen = .list
        spinner.startAnimating()

        let provider = CollectionDataProvider()
        provider.get(collectionId) { (movies, image) in
            guard let movies = movies else { return }

            let items = movies.map { $0.listItemCollection }
            let sections = [ Section(items: items) ]
            let u = Updater(image: image, dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateEpisode(_ episode: Episode?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.stillImageUrl(path: episode?.still_path, size: .original)
        let provider = ImageDataProvider()
        provider.get(url) { (image) in
            guard let episode = episode else { return }

            let sections = episode.episodeSections
            let buttonUrl = Tmdb.stillImageUrl(path: episode.still_path, size: .original)
            let u = Updater(image: image, buttonUrl: buttonUrl, dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateGenreTv(_ genreTvId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.tvURL(genreId: genreTvId)
        url?.apiGet { (result: Result<TvSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            let sections = [ Section(items: items) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateGenreMovie(_ genreMovieId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.moviesURL(genreId: genreMovieId)
        url?.apiGet { (result: Result<MediaSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            let sections = [ Section(items: items) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateItems(_ items: [Item]?) {
        screen = .list

        let section = Section(items: items)
        let sections = [section]
        let u = Updater(dataSource: sections)
        updateScreen(u)
    }

    func updateMovie(_ movieId: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = MovieDataProvider()
        provider.get(movieId) { (movie, articles, image) in
            guard let movie = movie else { return }

            let sections = movie.sections(articles: articles, limit: limit)
            let buttonUrl = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .xxl)
            let u = Updater(image: image, buttonUrl: buttonUrl, dataSource:sections)
            self.updateScreen(u)
        }
    }

    func updateNetwork(_ networkId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.tvURL(networkId: networkId)
        url?.apiGet { (result: Result<TvSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let sections = TV.networkSections(search.results)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updatePerson(_ personId: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = PersonDataProvider()
        provider.get(personId) { (credit, articles, image) in
            guard let credit = credit else { return }

            let sections = Section.personSections(credit: credit, articles: articles, limit: limit)
            let buttonUrl = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            let u = Updater(image: image, buttonUrl: buttonUrl, dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateProduction(_ productionId: Int?) {
        screen = .list
        spinner.startAnimating()

        let provider = ProductionDataProvider()
        provider.get(productionId) { (movie, tv) in
            var sections: [Section] = []

            if let s = movie?.productionSections {
                sections.append(contentsOf: s)
            }

            if let s = tv?.productionSections {
                sections.append(contentsOf: s)
            }

            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSeason(_ seasonItem: Item?) {
        screen = .list
        spinner.startAnimating()

        let provider = SeasonDataProvider()
        provider.get(seasonItem) { (season, image) in
            let sections = Section.seasonSections(season)
            let buttonUrl = Tmdb.mediaPosterUrl(path: season?.poster_path, size: .xxl)
            let u = Updater(image: image, buttonUrl: buttonUrl, dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSortedBy(_ sortedBy: String?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.moviesURL(sortedBy: sortedBy)
        url?.apiGet { (result: Result<MediaSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            let sections = [ Section(items: items) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateTv(_ id: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = TvDataProvider()
        provider.get(id) { (tv, image, articles) in
            guard let tv = tv else { return }

            let sections = tv.tvSections(articles)
            let buttonUrl = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .xxl)
            let u = Updater(image: image, buttonUrl: buttonUrl, dataSource: sections)
            self.updateScreen(u)
        }
    }

}

extension MainViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let _ = imageButton.url else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: sfvc, actionProvider: nil)
    }

    private func sfvc() -> UIViewController? {
        guard let url = imageButton.url else { return nil }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet

        return sfvc
    }

}

private extension Credit {

    static let numberOfEntries = 10

}

class ImageButton: UIButton {

    var url: URL?

}

enum CellType: String {

    case regular, color

}

enum ScreenType {

    case landing, list, search

}

struct Updater {

    var image: UIImage?
    var buttonUrl: URL?
    var dataSource: [Section]?
    
}
