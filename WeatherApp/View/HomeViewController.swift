//
//  ViewController.swift
//  WeatherApp
//
//  Created by Bob Yin on 9/27/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    let viewModel: HomeViewModel
    
    required init?(coder: NSCoder) {
        let apiManager = APIManager()
        self.viewModel = HomeViewModel(apiManagerService: apiManager)
        super.init(coder: coder)
    }
    
    lazy private var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        textField.placeholder = "請輸入城市名稱"
        textField.font = .PingFangTCMedium(size: 16)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy private var btn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("確認", for: .normal)
        btn.titleLabel?.font = .PingFangTCMedium(size: 20) //UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(tapBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy private var tableView : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateStatusView()
        binding()
        setupKeyboardDismiss()
    }
    
    func binding() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusView()
            }
            .store(in: &cancellables)

        viewModel.$displayItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateStatusView()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusView()
            }
            .store(in: &cancellables)
    }
    
    lazy private var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .PingFangTCMedium(size: 16)
        return label
    }()

    private func updateStatusView() {
        if viewModel.isLoading {
            loadingView.startAnimating()
            statusLabel.isHidden = true
            tableView.isHidden = true

        } else if let error = viewModel.errorMessage {
            loadingView.stopAnimating()
            statusLabel.text = error
            statusLabel.textColor = .red
            statusLabel.isHidden = false
            tableView.isHidden = true

        } else if viewModel.displayItems.isEmpty {
            loadingView.stopAnimating()
            statusLabel.text = "請輸入縣市名稱查詢天氣"
            statusLabel.textColor = .gray
            statusLabel.isHidden = false
            tableView.isHidden = true

        } else {
            loadingView.stopAnimating()
            statusLabel.isHidden = true
            tableView.isHidden = false
        }
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func tapBtn() {
        viewModel.load(textField.text ?? "")
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    func setupView() {
        view.addSubview(textField)
        view.addSubview(btn)
        view.addSubview(tableView)
        view.addSubview(statusLabel)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            btn.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0),
            btn.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.displayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        guard indexPath.row < viewModel.displayItems.count else {
            cell.textLabel?.text = "無資料"
            return cell
        }
        
        let item = viewModel.displayItems[indexPath.row]
        cell.textLabel?.text = item.displayText
        cell.textLabel?.font = .PingFangTCMedium(size: 16)
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }
}

