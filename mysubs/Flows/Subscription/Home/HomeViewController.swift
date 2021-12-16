//
//  CollectionViewController.swift
//  mysubs
//
//  Created by Manon Russo on 30/11/2021.
//

import UIKit

// MARK: Enums
enum State<Data> {
    case loading
    case empty
    case error
    case showData(Data)
}

class HomeViewController: UIViewController, UINavigationBarDelegate {
    var category = CategoryInfo(name: " Ajouter une catégorie ")
    
    var viewModel : HomeViewModel?
    weak var coordinator: AppCoordinator?
    
    
    // MARK: UI Properties
    var subsView = UIView()
    var totalAmountView = UIView()
    var totalAmountLabel = UILabel()
    var amountLabel = UILabel()
    var myCollectionView: UICollectionView!
    var stackView = UIStackView()
    var categoryButton = UIButton()//AdaptableSizeButton()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    // MARK: Properties
    var storageService = StorageService()
//    var newSubVC = NewSubController()
    var subscriptions: [Subscription] = []
    var viewState: State<[Subscription]> = .empty {
        didSet {
//            resetState()
            switch viewState {
            case .loading:
                activityIndicator.startAnimating()
                print("loading...")
            case .empty:
                myCollectionView.isHidden = true

                displayEmptyView()
                print("empty!")
            case .error:
                showAlert("Erreur", "Il semble y avoir un problème, merci de réessayer")
                print("error")
            case .showData(let subscriptions):
                print("thats datas")
                activityIndicator.stopAnimating()
//                self.subscriptions = subscriptions
                self.viewModel?.subscriptions = subscriptions
                myCollectionView.reloadData()
                myCollectionView.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        viewModel?.fetchSubs()
        do {
            // Allowed to reload those subs when re-launching app since they're now saved
            for subs in subscriptions {
            try storageService.saveSubs(subs)
            }
        }
        catch { print("error") }
//        fetchSubFromDataBase()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("Category : \(category)")
        fetchSubFromDataBase()
        setUpTotalAmountView()
    }
    
    
    func displayEmptyView() {
        let emptyView = UITextView.init(frame: myCollectionView.frame)
        emptyView.text = "\n\n\n\n\nAppuyez sur le + en haut pour commencer !"
        emptyView.isEditable = false
        emptyView.textAlignment = .center
        emptyView.font = MSFonts.title1
        emptyView.translatesAutoresizingMaskIntoConstraints = true
        myCollectionView.insertSubview(emptyView, at: 0)
    }
    
    func fetchSubFromDataBase() {
        do { subscriptions = try storageService.loadSubs()
            if subscriptions.isEmpty {
                viewState = .empty
            } else {
                viewState = .showData(subscriptions)
                print("abonnement print dans le fetchsub : \(subscriptions)")
            }
        } catch { print("error: \(error) can't load data") }

    }
    private func fetchLogo() {
//        guard isAllLoaded == false else { return }
//        viewState = .loading
//        recipeService.fetchRecipes(for: ingredients) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let recipesInfo) where recipesInfo.recipes.isEmpty :
//                    /// If the request works but does not find any recipes.
//                    self.viewState = .empty
//                case .success(let recipesInfo):
//                    self.viewState = .showData(recipesInfo.recipes)
//                case .failure(let error):
//                    print("Erreur : \(error.localizedDescription)")
//                    self.showAlert("Error", "Can't load recipes. Please try again.")
//                }
//            }
//        }
    }
    func refreshWith(subscriptions: [Subscription]) {
        myCollectionView.reloadData()
    }
    
    
    @objc func plusButtonAction() {
        viewModel?.showNewSub()
        print("passage dans methode obj c")
    }
    
    func cellTapped(sub: Subscription) {
        viewModel?.showDetail(sub: sub)
        print("passage dans methode show details")
    }
    
//    MARK: Private methods
    private func resetState() {
        activityIndicator.stopAnimating()
        viewState = .loading
        myCollectionView.isHidden = true
    }
    
    private func deleteSub(sub: Subscription) {
        do {
            try storageService.deleteSubs(sub)
            //fetchSubs()
        }
        catch { print (error); self.showAlert("Erreur", "Suppression impossible. Merci de réessayer plus tard") }
    }
    
    func setUpUI() {
        setUpNavBar()
        setUpView()
        setUpStackView()
        activateConstraints()
    }
    
    func setUpNavBar() {
        // DISPLAYING LOGO
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "subs_dark")
        imageView.image = image
        navigationItem.titleView = imageView
        
        //DISPLAYING PLUS BUTTON
        let plusButton: UIButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plus_button"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: plusButton)
        let plusWidth = rightBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        plusWidth?.isActive = true
        let plusHeight = rightBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        plusHeight?.isActive = true
        rightBarButtonItem.customView = plusButton
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        //DISPLAYING MENU BUTTON
        let menuButton: UIButton = UIButton(type: .custom)
        menuButton.setImage(UIImage(named: "menu_button"), for: .normal)
        menuButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: menuButton)
        let menuWidth = leftBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        menuWidth?.isActive = true
        let menuHeight = leftBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        menuHeight?.isActive = true
        leftBarButtonItem.customView = menuButton
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    
    func setUpView() {
        view.backgroundColor = MSColors.background

//        view.isUserInteractionEnabled = true
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.setTitle(category.name, for: UIControl.State.normal)
        categoryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        categoryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        categoryButton.backgroundColor = UIColor(named: "reverse_bg")
        categoryButton.setTitleColor(MSColors.background, for: UIControl.State.normal)
        categoryButton.addCornerRadius()
        categoryButton.isUserInteractionEnabled = true
//        categoryButton.
        view.addSubview(categoryButton)
        categoryButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)

    }
    
    func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        //MARK: Collection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width - 16, height: 60)
        layout.scrollDirection = .vertical
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView?.register(SubCell.self, forCellWithReuseIdentifier: SubCell.identifier)
        myCollectionView?.backgroundColor = MSColors.background
        myCollectionView?.dataSource = self
        myCollectionView?.delegate = self
        myCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        myCollectionView?.isScrollEnabled = true
        myCollectionView?.isUserInteractionEnabled = true
        stackView.addArrangedSubview(myCollectionView ?? UICollectionView())
        setUpTotalAmountView()
        view.addSubview(stackView)
    }
    
    func setUpTotalAmountView() {
        totalAmountView.translatesAutoresizingMaskIntoConstraints = false
        totalAmountView.backgroundColor = .systemBackground
        stackView.addArrangedSubview(totalAmountView)

        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAmountLabel.adjustsFontForContentSizeCategory = true
        totalAmountLabel.text = "Coût total"
        totalAmountLabel.textColor = UIColor(named: "yellowgrey")
        totalAmountLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        totalAmountView.addSubview(totalAmountLabel)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.adjustsFontForContentSizeCategory = true
        
        var totalPrice: Float = 0
        
        for sub in subscriptions {
            totalPrice += sub.price
            print("voici les prix \(sub.price)")
            amountLabel.text = "\(totalPrice) €"
        }
        
    
//        amountLabel.text = "\(subCell.subscriptions.first.price) €"
        
        amountLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        amountLabel.textColor = UIColor(named: "yellowgrey")
        amountLabel.backgroundColor = MSColors.background
        totalAmountView.addSubview(amountLabel)
        amountLabel.layer.cornerRadius = 5
        amountLabel.textAlignment = .center
        amountLabel.layer.masksToBounds = true
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            categoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 50),
            categoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0),
            stackView.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 0),
            stackView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16),

            totalAmountView.leadingAnchor.constraint(equalToSystemSpacingAfter: stackView.leadingAnchor, multiplier: 0),
            totalAmountView.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 0),
            totalAmountView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),
            totalAmountView.heightAnchor.constraint(equalToConstant: 50),
            totalAmountLabel.leadingAnchor.constraint(equalTo: totalAmountView.leadingAnchor, constant: 32),
            totalAmountLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor, constant: 0),
            
            amountLabel.trailingAnchor.constraint(equalTo: totalAmountView.trailingAnchor, constant: -32),
            amountLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor, constant: 0),
            amountLabel.widthAnchor.constraint(equalToConstant: 90),
            amountLabel.heightAnchor.constraint(equalToConstant: 30),
            ])
    }
}



extension HomeViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.subscriptions.count ?? 0
//        return subscriptions.count

    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = myCollectionView.dequeueReusableCell(withReuseIdentifier: SubCell.identifier, for: indexPath) as! SubCell
//        myCell.backgroundColor = .systemBlue
//        UIColor(named: "background")
//        print(viewModel?.subscriptions[indexPath.row] ?? 1)
//        myCell.subscriptions = subscriptions
        
        collectionViewCell.subscription = subscriptions[indexPath.row]
        return collectionViewCell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSub = viewModel?.subscriptions[indexPath.row] else { return }
        cellTapped(sub: selectedSub)
       print("item \(indexPath.row+1) tapped")
    }
}
