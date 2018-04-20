//
//  CustomAlertViewDelegate.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/20/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

protocol CustomAlertViewDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
    func setTitle() -> String
    func setMessage() -> String
}
