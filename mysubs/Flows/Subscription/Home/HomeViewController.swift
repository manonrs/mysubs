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

//class AdaptableSizeButton: UIButton {
//    override var intrinsicContentSize: CGSize {
//        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
//        let desiredButtonSize = CGSize(width: labelSize.width, height: labelSize.height)
//        return desiredButtonSize
//    }
//}
//créer tabbar, 1 navigationcontroller pour chaque objet 
class HomeViewController: UIViewController, UINavigationBarDelegate {
// TEST CODE DATA (mettre dans viewdidLoad à partir du do pour test
//    var subInfo = SubInfo(category: "ciné", commitment: "mensuel", extraInfo: "test", name: "NETFLIX", paymentRecurrency: "mensuel", price: 9.99, reminder: "2j avant", suggestedLogo: "rien")
//    do {
//        try storageService.saveSubs(subInfo)
//    }
//    catch { print(error)}
//
//    do {
//        try storageService.deleteSubs(subInfo)
//    }
//    catch { print(error)}
    
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
    var subscriptions: [SubInfo] = []
    
    var viewState: State<[SubInfo]> = .empty {
        didSet {
            resetState()
            switch viewState {
            case .loading:
                activityIndicator.startAnimating()
                print("loading...")
            case .empty:
                //diplsayEmptyView()
                print("empty!")
            case .error:
                showAlert("Erreur", "Il semble y avoir un problème, merci de réessayer")
                print("error")
            case .showData(let subscriptions):
                print("thats datas")
                self.subscriptions = subscriptions
                //collectionView.reloadData() (equivalent)?
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        viewModel?.fetchSubs()
    }
    
    func refreshWith(subs: [String]) {
        myCollectionView.reloadData()
    }
    
//    func addCategoryButtonAction() {
//    }
    
    @objc func categoryButtonAction() {
        viewModel?.showDetail()
        print("passage dans methode obj c")
    }
    
    //MARK: Private methods
    private func resetState() {
        activityIndicator.stopAnimating()
        //collectionView.isHidden = true
    }
    
    private func deleteSub(sub: SubInfo) {
        do {
            try storageService.deleteSubs(sub)
            //fetchSubs()
        }
        catch { print (error); self.showAlert("Erreur", "Suppression impossible. Merci de réessayer plus tard") }
    }
    
    func setUpUI() {
        setUpView()
        setUpStackView()
        activateConstraints()
    }
    
    
    func setUpView() {
        view.backgroundColor = UIColor(named: "background")
//        view.isUserInteractionEnabled = true
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.setTitle(category.name, for: UIControl.State.normal)
        categoryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        categoryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        categoryButton.backgroundColor = UIColor(named: "reverse_bg")
        categoryButton.setTitleColor(UIColor(named: "background"), for: UIControl.State.normal)
        categoryButton.addCornerRadius()
        categoryButton.isUserInteractionEnabled = true
//        categoryButton.
        view.addSubview(categoryButton)
        categoryButton.addTarget(self, action: #selector(categoryButtonAction), for: .touchUpInside)

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
        myCollectionView?.backgroundColor = UIColor(named: "background")
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
        amountLabel.text = " 22 € "
        amountLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        amountLabel.textColor = UIColor(named: "yellowgrey")
        amountLabel.backgroundColor = UIColor(named: "background")
        totalAmountView.addSubview(amountLabel)
        amountLabel.layer.cornerRadius = 5
        amountLabel.textAlignment = .center
        amountLabel.layer.masksToBounds = true
        
//        amountLabel.layer.shadowColor = UIColor.black.cgColor
//        amountLabel.layer.shadowRadius = 3.0
//        amountLabel.layer.shadowOpacity = 1.0
//        amountLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
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
        return viewModel?.subs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: SubCell.identifier, for: indexPath)
//        myCell.backgroundColor = .systemBlue
//        UIColor(named: "background")
        print(viewModel?.subs[indexPath.row])
        return myCell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("item \(indexPath.row+1) tapped")
    }
}
