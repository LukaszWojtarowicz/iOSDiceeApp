//
//  ViewController.swift
//  Dicee
//
//  Created by Angela Yu on 25/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//  Modified by lukasz 20.01.2019

import Combine
import Foundation
import UIKit

class ViewController: UIViewController {
    let diceArray = ["dice1", "dice2", "dice3", "dice4", "dice5", "dice6"]
    let firstDiceRandomizer = CurrentValueSubject<Int, Never>(1)
    let secondDiceRandomizer = CurrentValueSubject<Int, Never>(5)
    let timerPublisher = Timer.publish(every: 0.3, on: .main, in: .commonModes).autoconnect()
    
    var firstDiceIndexPublisher: AnyPublisher<Int, Never> {
        firstDiceRandomizer.eraseToAnyPublisher()
    }
    
    var secondDiceIndexPublisher: AnyPublisher<Int, Never> {
        secondDiceRandomizer.eraseToAnyPublisher()
    }
    
    var bag = Set<AnyCancellable>()
    
    @IBOutlet weak var firstDiceImageView: UIImageView!
    @IBOutlet weak var secondDiceImageView: UIImageView!
    @IBAction func rollPressed(_ sender: AnyObject) {
        handleAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            handleAction()
        }
    }
    
    private func startRolling() {
        firstDiceIndexPublisher
            .zip(secondDiceIndexPublisher)
            .sink { completion in
                print("\(completion)")
            } receiveValue: { [weak self] _ in
                self?.updateDiceImages()
                self?.rotateDices()
            }
            .store(in: &bag)
        
        timerPublisher
            .sink { completion in
                print("\(completion)")
            } receiveValue: { [weak self] _ in
                self?.randIndexes()
                self?.ifShouldEndRolling()
            }
            .store(in: &bag)
    }
    
    private func randIndexes() {
        firstDiceRandomizer.send(Int.random(in: 1..<6))
        secondDiceRandomizer.send(Int.random(in: 1..<6))
    }
    
    private func handleAction() {
        if bag.isEmpty {
            startRolling()
        } else {
            bag.removeAll()
        }
    }
    
    private func updateDiceImages() {
        firstDiceImageView.image = UIImage(named: diceArray[firstDiceRandomizer.value])
        secondDiceImageView.image = UIImage(named: diceArray[secondDiceRandomizer.value])
    }
    
    
    private func ifShouldEndRolling() {
        let value = (firstDiceRandomizer.value + 1) + (secondDiceRandomizer.value + 1)
        
        print(value)
        
        if value >= 9 {
            bag.removeAll()
        }
    }
    
    private func rotateDices() {
        let degrees = 24
        let radians = Double(degrees * firstDiceRandomizer.value) * 3.14 / 180
        let radians2 = Double(degrees * secondDiceRandomizer.value) * 3.14 / 180
        
        firstDiceImageView.transform = CGAffineTransform(rotationAngle: radians)
        
        secondDiceImageView.transform = CGAffineTransform(rotationAngle: radians2)

    }
}
