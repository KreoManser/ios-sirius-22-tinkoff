//
//  ViewController.swift
//  tinkoff_sirius_22
//
//  Created by Сергей Бабич on 09.02.2022.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    // MARK: IBOutlets
    // API Labels
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    // Includes
    @IBOutlet weak var companyPickerView: UIPickerView!
    // View in the middle of the screen
    @IBOutlet weak var companyIconImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Array(collection) declaration
//    private let companies: [String: String] = ["Apple": "AAPL",
//                                               "Microsoft": "MSFT",
//                                               "Google": "GOOG",
//                                               "Amazon": "AMZN",
//                                               "Facebook": "FB"]
//
    // MARK: - Array(collection) declaration (NEW VERSION)
    private var companies: [[String: String]]? {
        didSet {
            requestQuoteUpdate()
            companyPickerView.reloadAllComponents()
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        // request UIPickertView List
        self.requestCompaniesList()
    }
    
    // MARK: - Private request Data from server
    private func requestQuote(for symbol: String) {
        let token = "pk_b5794b2e4af4492097b71d3b77d99352"
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)")!
    
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error", message: "Some network error occured", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                print("! Network error")
                return
            }
            
            self.parseQuote(data: data)
        }

        dataTask.resume()
    }
    
    // MARK: - Private request companies list
    private func requestCompaniesList() {
        activityIndicator.startAnimating()

        let token = "pk_b5794b2e4af4492097b71d3b77d99352"
        let url = URL(string: "https://cloud.iexapis.com/stable/ref-data/symbols?token=\(token)")!

        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                print("! Network error")
                return
            }

            self.parseSymbol(from: data)
        }
        
        dataTask.resume()
    }
    
    // MARK: - Parsing symbols for companiesList
    private func parseSymbol(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            var companiesList = [[String: String]]()
            
            guard
                let companies = jsonObject as? [[String: Any]]
            else {
                print("! Invalid JSON")
                return
            }
            
            for company in companies {
                if let companyName = company["name"] as? String, let companySymbol = company["symbol"] as? String {
                    companiesList.append([companyName : companySymbol])
                }
            }
            
            DispatchQueue.main.async {
                self.companies = companiesList
            }
            
        } catch {
            print("! JSON parsing error: " + error.localizedDescription)
        }
    }
    
    // MARK: - Request image from server
    private func requestIcon(for symbol: String) {
        let url = URL(string: "https://storage.googleapis.com/iexcloud-hl37opg/api/logos/\(symbol).png")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error", message: "Image not found", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                print("! Image download error")
                return
            }
            
            DispatchQueue.main.async {
                self.companyIconImageView.image = UIImage(data: data)
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: - Parse JSON
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error", message: "Stocks for company is not avaliable", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                print("! Invalid JSON format")
                return
            }
            
            self.requestIcon(for: companySymbol)
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
            }
        } catch {
            print("! JSON parsing error: " + error.localizedDescription)
        }
    }
    
    // MARK: - Show info on display
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        
        if priceChange < 0 {
            priceChangeLabel.textColor = .red
        } else if priceChange > 0 {
            priceChangeLabel.textColor = .green
        } else {
            priceChangeLabel.textColor = .black
        }
    }
    
    // MARK: - Private methods
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.priceChangeLabel.textColor = .black
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.companyIconImageView.image = nil
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        guard
            let selectedSymbol = companies?[selectedRow].values.first
        else {
            return
        }
        self.requestQuote(for: selectedSymbol)
    }
}

// MARK: - UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // MARK: - Key unpacker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard
            let companiesCount = companies?.count
        else {
            return 0
        }
        
        return companiesCount
    }
}

// MARK: - UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard
            let company = companies?[row].keys.first
        else {
            return "! Error"
        }
        
        return company
    }
    
    // MARK: - Selector symbol for UIPickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestQuoteUpdate()
    }
}
