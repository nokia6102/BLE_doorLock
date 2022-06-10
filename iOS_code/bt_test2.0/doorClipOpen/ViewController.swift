//
//  ScannerViewController.swift
//  bt_test2.0
//
// on 2017/9/11.
//  Copyright © 2017年 Albert. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, BluetoothSerialDelegate, CBPeripheralDelegate {
    
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    private var bluefruitPeripheral: CBPeripheral!
    struct CBUUIDs{

        static let kBLEService_UUID = "FFE0"
        static let kBLE_Characteristic_uuid_Tx = "FFE1"
        static let kBLE_Characteristic_uuid_Rx = "FFE1"

        static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
        static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
        static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

    }
    
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    //MARK: Variables
    
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
     var progressHUD: MBProgressHUD?
    
    var centralManager: CBCentralManager!
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        serial = BluetoothSerial(delegate: self)
//        serial.delegate = self
//
        centralManager = CBCentralManager(delegate: self, queue: nil)
        tableView.delegate = self
        tableView.dataSource = self
        
  
        // tryAgainButton is only enabled when we've stopped scanning
//        tryAgainButton.isEnabled = false
        
        // remove extra seperator insets (looks better imho)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // tell the delegate to notificate US instead of the previous view if something happens
//        serial.delegate = self
        
//        if serial.centralManager.state != .poweredOn {
//            title = "Bluetooth not turned on"
//            return
//        }
        
        // start scanning and schedule the time out
        
 
//        serial.startScan()
//        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(ViewController.scanTimeOut), userInfo: nil, repeats: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.writeOutgoingValue(data: "o")
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.writeOutgoingValue(data: "c")
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        tryAgainButton.isEnabled = true
        title = "Done scanning"
    }
    
    ///
    ///
    ///
    
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {
              characteristic.uuid.uuidString
            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
              
              txCharacteristic = characteristic
              
              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
    
    func writeOutgoingValue(data: String){
      
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        print ("write: \(data) , \(valueString)")
        
            if let bluefruitPeripheral = bluefruitPeripheral {
                  
              if let txCharacteristic = txCharacteristic {
                      
                  bluefruitPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
                  }
              }
      }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    func startScanning() -> Void {
      // Start Scanning
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            //We need to discover the all characteristic
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 2)
    }
    
    // --
   
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a cell with the peripheral name as text in the label
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let label = cell.viewWithTag(101) as! UILabel?
        label?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // the user has selected a peripheral, so stop scanning and proceed to the next view
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        serial.connectToPeripheral(selectedPeripheral!)
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD!.labelText = "Connecting"
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        bluefruitPeripheral = peripheral
        bluefruitPeripheral.delegate = self

        print("Peripheral Discovered: \(peripheral)")
          print("Peripheral name: \(peripheral.name)")
        print ("Advertisement Data : \(advertisementData)")
       
        if peripheral.name == "Rich-CC41-A" {
            print ("OK")
            centralManager?.connect(bluefruitPeripheral!, options: nil)
        }
       }
    

    
    //MARK: BluetoothSerialDelegate
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI > $1.RSSI }
        tableView.reloadData()
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
        
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        dismiss(animated: true, completion: nil)
    }
    
    func serialDidChangeState() {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
}
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        serial.stopScan()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tryAgain(_ sender: UIButton)
    {
        writeOutgoingValue(data: "c")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.writeOutgoingValue(data: "o")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.writeOutgoingValue(data: "c")
        }
     
//        writeOutgoingValue(data: "o")
//        writeOutgoingValue(data: "c")
        
//        peripherals = []
//        tableView.reloadData()
//        tryAgainButton.isEnabled = false
//        title = "Scanning..."
////        serial.stopScan()
//        startScanning()
//        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
}

extension ViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
     switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScanning()
         
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
          }
  }

}
