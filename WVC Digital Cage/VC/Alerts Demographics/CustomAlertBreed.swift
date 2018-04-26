//
//  CustomAlertBreed.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/25/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
// storyboardID CustomBreedAlertID

import Foundation

import UIKit

class CustomAlertBreedView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    //Specific to This View Delegate
    var delegate: CustomAlertViewDelegateBreed?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    //data
    var feline = ["Domestic shorthair", "Domestic long hair", "Calico", "Siamese cat", "Persian cat", "Ragdoll", "Maine coon", "Bengal Cat", "Sphynx cat", "Abyssinian Cat", "Russian Blue", "Burmese cat", "American bobtail", "Exotic shorthair", "Scottish fold", "Siberian cat", "Birman", "Cornish rex", "Ocicat", "Norwegian forest cat", "Tonkinese cat", "Manx cat", "Devon rex", "Turkish angora", "Savannah cat", "Egyptian mau", "American curl", "Turkish van", "Chartreux", "Bombay cat", "Himalayan cat", "Balinese cat", "Korat", "Japanese bobtail", "Ragmuffin cat", "Singapura cat", "Laperm", "Somali cat", "Selkirk cat", "Havana brown", "American wirehair", "Javanese cat", "Munchkin cat", "Cymric cat", "Snowshoe cat", "Nebelung cat", "Colorpoint shorthair", "Pixie-bob", "Oriental shorthair", "Burmilla", "Dragon li", "peterbald"]
    
    var canine = ["Afghan Hound","Airdale", "Akita", "American Pitbull terrier", "American Staffordshire", "Alaskan Malamute", "American English Coonhound", "American EskimoDog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Appenzeller Sennenhund", "Australian Cattle Dog", "Australian Kelpie", "Australian Shepherd", "Australian Terrier", "Azawakh", "Barbet", "Basenji", "Basset Fauvede Bretagne", "Basset Hound", "Bavarian Mountain Scent Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Laekenois", "Belgian Malinois", "Belgian Sheepdog", "Belgian Tervuren", "Bergamasco Sheepdog", "Berger Picard", "Bernese Mountain Dog", "Bichon Frise, Biewer Terrier", "Blackand Tan Coonhound", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Boerboel", "Bolognese", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvierdes Flandres", "Boxer", "Boykin Spaniel", "Bracco Italiano", "Braquedu Bourbonnais", "Braque Francais Pyrenean", "Briard", "Brittany", "Broholmer", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Leopard Dog", "Caucasian Shepherd Dog", "Cavalier King Charles Spaniel", "Central Asian Shepherd Dog", "Cesky Terrier", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested", "Chinese Shar-Pei", "Chinook", "Chow Chow", "Cirnecodell’Etna", "Clumber Spaniel", "Cocker Spaniel", "Collie", "Cotonde Tulear", "Curly-Coated Retriever", "Czechoslovakian Vlcak", "Dachshund", "Dalmatian", "Dandie Dinmont Terrier", "Danish-Swedish Farmdog", "Deutscher Wachtelhund", "Doberman Pinscher", "Dogo Argentino", "Doguede Bordeaux", "Drentsche Patrijshond", "Drever", "Dutch Shepherd", "English Cocker Spaniel", "English Foxhound", "English Setter", "English Springer Spaniel", "English Toy Spaniel", "Entlebucher Mountain Dog", "Estrela Mountain Dog", "Eurasier", "Field Spaniel", "Finnish Lapphund", "Finnish Spitz", "Flat-Coated Retriever", "French Bulldog", "French Spaniel", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shorthaired Pointer", "German Spitz", "German Wirehaired Pointer", "Giant Schnauzer", "Glenof Imaal Terrier", "Golden Retriever", "Gordon Setter", "Grand Basset", "Griffon Vendéen", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Hamiltonstovare", "Hanoverian Scenthound", "Harrier", "Havanese", "Hokkaido", "Hovawart", "Ibizan Hound", "Icelandic Sheepdog", "Irish Redand White Setter", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jagdterrier", "Japanese Chin", "Jindo", "Kai Ken", "Karelian Bear Dog", "Keeshond", "Kerry Blue Terrier", "Kishu Ken", "Komondor", "Kromfohrlander", "Kuvasz", "Labrador Retriever", "Lagotto Romagnolo", "Lakeland Terrier", "Lancashire Heeler", "Lapponian Herder", "Leonberger", "Lhasa Apso", "Maltese", "Manchester Terrier (Standard)", "Mastiff", "Miniature American Shepherd", "Miniature Bull Terrier", "Miniature Pinscher", "Miniature Schnauzer", "Mountain Cur", "Mudi", "Neapolitan Mastiff", "Nederlandse Kooikerhondje", "Newfoundland", "Norfolk Terrier", "Norrbottenspets", "Norwegian Buhund", "Norwegian Elkhound", "Norwegian Lundehund", "Norwich Terrier", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Otterhound", "Papillon", "Parson Russell Terrier", "Pekingese", "Pembroke Welsh Corgi", "Perrode Presa Canario", "Peruvian Inca Orchid", "Petit Basset Griffon Vendéen", "Pharaoh Hound", "Plott", "Pointer", "Polish Low land Sheepdog", "Pomeranian", "Poodle (Standard)", "Porcelaine", "Portuguese Podengo", "Portuguese Podengo Pequeno", "Portuguese Pointer", "Portuguese Sheepdog", "Portuguese Water Dog", "Pudelpointer", "Pug", "Puli", "Pumi", "Pyrenean Mastiff", "Pyrenean Shepherd", "Rafeirodo Alentejo", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Russell Terrier", "Russian Toy", "Russian Tsvetnaya Bolonka", "Saint Bernard", "Saluki", "Samoyed", "Schapendoes", "Schipperke", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Shikoku", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Sloughi", "Slovensky Cuvac", "Small Munsterlander Pointer", "Smooth Fox Terrier", "Soft Coated Wheaten Terrier", "Spanish Mastiff", "Spanish Water Dog", "Spinone Italiano", "Stabyhoun", "Staffordshire Bull Terrier", "Standard Schnauzer", "Sussex Spaniel", "Swedish Lapphund", "Swedish Vallhund", "Taiwan Dog", "Teddy Roosevelt Terrier", "Thai Ridgeback", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Tornjak", "Tosa", "Toy Fox Terrier", "Transylvanian Hound", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrierx", "West Highland White Terrier", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Wirehaired Vizsla", "Working Kelpie", "Xoloitzcuintli", "Yakutian Laika", "Yorkshire Terrie"
    ]
    
    var selectedOption = ""
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    var groupString = "Canine"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        picker.dataSource = self
        picker.delegate = self
        
        let patientID = returnSelectedPatientID()
        for item in patientRecords {
            if item["patientID"] == patientID{
                groupString = item["group"]!
                break
            }
        }
        if groupString == "Canine" {
            selectedOption = canine[0]
        } else {
            selectedOption = feline[0]
        }
        titleLabel.text = "Breed"
        messageLabel.text = "Pick \(groupString) Breed for \(patientID)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        //cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        //cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 1)
        //okButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        //alertTextField.resignFirstResponder()
        delegate?.cancelButtonTappedBreed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        //alertTextField.resignFirstResponder()
        delegate?.okButtonTappedBreed(selectedOption: selectedOption, textFieldValue: "none")
        self.dismiss(animated: true, completion: nil)
    }
    
    //Picker setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // returns the number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if groupString == "Canine" {
            return canine.count
        } else {
            return feline.count
        }
    }
    // returns data to display  picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if groupString == "Canine" {
            return canine[row]
        } else {
            return feline[row]
        }
    }
    //picker selected value
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if groupString == "Canine" {
            selectedOption = canine[row]
        } else {
            selectedOption = feline[row]
        }
    }
}


