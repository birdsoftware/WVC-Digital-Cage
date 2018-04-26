//
//  CustomAlertViewDelegateBreed.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

protocol CustomAlertViewDelegateBreed: class {
    func okButtonTappedBreed(selectedOption: String, textFieldValue: String)
    func cancelButtonTappedBreed()
    //func setTitleBreed() -> String
    //func setMessageBreed(groupString: String) -> String
}
