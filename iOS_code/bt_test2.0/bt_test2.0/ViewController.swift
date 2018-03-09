//
//  ViewController.swift
//  bt_test2.0
//
//  Created  on 2017/9/11.
//  Copyright © 2017年 Albert. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController, BluetoothSerialDelegate
{
//MARK: IBOutlets
    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var txtResult: UITextView!
//MARK: IBActions
    @IBAction func btnAutomaticallyFlared(_ sender: UIButton)
    {
        serial.sendMessageToDevice("\0x01")
        sleep(1000)
        serial.sendMessageToDevice("\0x02")
       sleep(1000)
  }

    @IBAction func btnUpFlared(_ sender: UIButton)    //close
    {
        serial.sendMessageToDevice("c")
    }
    
    @IBAction func btnDownFlared(_ sender: UIButton)
    {
        serial.sendMessageToDevice("o")
    }
    
    @IBAction func btnLeftFlared(_ sender: UIButton)    //opne
    {
        serial.sendMessageToDevice("o")
    }
    
    @IBAction func btnRightFlared(_ sender: UIButton)
    {
        serial.sendMessageToDevice("C")
    }
    
    @IBAction func btnStopFlared(_ sender: UIButton)
    {
        serial.sendMessageToDevice("z")  //藍芽傳送字串“z"
    }
    
//MARK: Variables
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
    var progressHUD: MBProgressHUD?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        serial = BluetoothSerial(delegate: self)
        
        // tell the delegate to notificate US instead of the previous view if something happens
        serial.delegate = self
        
        if serial.centralManager.state == .poweredOn
        {
            txtInfo.text! = "Bluetooth turned on"
//            return
        }

    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String)
    {


    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    {

    }
    
    func serialDidChangeState()
    {
        var msg = ""
        
        switch serial.centralManager.state
        {
        case .poweredOff:
            msg = "bluetooth is off"
        case .poweredOn:
            msg = "bluetooth is on"
        case .unsupported:
            msg = "bluetooth is unsupported"
        default:
            break
        }
        print("START:\(msg)")
    }

}

