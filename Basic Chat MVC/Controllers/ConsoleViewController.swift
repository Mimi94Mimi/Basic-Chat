//
//  ConsoleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 2/6/21.
//

import UIKit
import CoreBluetooth

class ConsoleViewController: UIViewController {
    
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral?
    var periperalTXCharacteristic: CBCharacteristic?
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var numOfPhotoLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet weak var shouldTakePhoto: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var numOfPhotoTextField: UITextField!
    @IBOutlet weak var timeIntervalTextField: UITextField!
    @IBOutlet weak var angleTextField: UITextField!
    @IBOutlet weak var cameraStateControl: UISegmentedControl!
    @IBOutlet weak var startShootingButton: UIButton!
    @IBOutlet weak var stopShootingButton: UIButton!
    @IBOutlet weak var shouldTakePhotoSwitch: UISwitch!
    @IBOutlet weak var shutter: UIView!
    @IBOutlet weak var txLabel: UILabel!
    @IBOutlet weak var rxLabel: UILabel!
    @IBOutlet weak var RSSILabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotifyCameraState(notification:)), name: NSNotification.Name(rawValue: "NotifyCameraState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotifyShouldTakePhoto(notification:)), name: NSNotification.Name(rawValue: "NotifyShouldTakePhoto"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotifyShouldTakePhoto(notification:)), name: NSNotification.Name(rawValue: "NotifyShouldTakePhoto"), object: nil)
        
        
        modeLabel.text = "mode:"
        numOfPhotoLabel.text = "num_of_photo: 5"
        timeIntervalLabel.text = "time_interval: 1.5"
        angleLabel.text = "angle: 3"
        RSSILabel.text = "RSSI: N/A"
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeRSSILabel(notification:)), name: NSNotification.Name(rawValue: "RSSIChanged"), object: nil)
        
        writeOutgoingValue(data: "0", txChar: BlePeripheral.connectedChar)
        
        stopShootingButton.isHidden = true
        
        //    txLabel.text = "TX:\(String(BlePeripheral.connectedTXChar!.uuid.uuidString))"
        //    rxLabel.text = "RX:\(String(BlePeripheral.connectedRXChar!.uuid.uuidString))"
        
        //    if let service = BlePeripheral.connectedService {
        //      serviceLabel.text = "Number of Services: \(String((BlePeripheral.connectedPeripheral?.services!.count)!))"
        //    } else{
        //      print("Service was not found")
        //    }
        
        var connectedCounter = Timer()
        connectedCounter = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendCounterValue), userInfo: nil, repeats: true)
        
    }
    
    @objc func sendCounterValue() {
        if (current_RSSI! > -50.0) {connectedCounterValue! += 1}
        print(connectedCounterValue!)
        writeOutgoingValue(data: String("\(connectedCounterValue!)"), txChar: BlePeripheral.connectedChar)
    }
    
    @objc func handleNotifyCameraState(notification: Notification) -> Void{
       if (notification.object as! String != lastCharValue.cameraState){
            print("camera state changes: \(notification.object!)")
            lastCharValue.cameraState = notification.object as! String
            if (lastCharValue.cameraState == "idle") {
//                cameraStateControl.selectedSegmentIndex = 0
//                cameraStateControl.sendActions(for: .valueChanged)
                startShootingButton.isHidden = false
                stopShootingButton.isHidden = true
                nanosec_shooting_TI = 0
            }
            else if (lastCharValue.cameraState == "shooting") {
//                cameraStateControl.selectedSegmentIndex = 1
//                cameraStateControl.sendActions(for: .valueChanged)
            }
        }
    }
    
    @objc func handleNotifyShouldTakePhoto(notification: Notification) -> Void{
        if (notification.object as! String != lastCharValue.shouldTakePhoto){
            lastCharValue.shouldTakePhoto = notification.object as! String
            if (lastCharValue.shouldTakePhoto == "false") {
                CharacteristicInfo.shouldTakePhoto = "false"
//                shouldTakePhotoSwitch.isOn = false
//                shouldTakePhotoSwitch.sendActions(for: .valueChanged)
            }
            else if (lastCharValue.shouldTakePhoto == "true") {
                takePhoto()
                writeOutgoingValue(data: "false" , txChar: BlePeripheral.shouldTakePhotoChar)
                CharacteristicInfo.shouldTakePhoto = "true"
//                shouldTakePhotoSwitch.isOn = true
//                shouldTakePhotoSwitch.sendActions(for: .valueChanged)
            }
        }
    }
    
    @objc func changeRSSILabel(notification: Notification) -> Void{
        let newRSSI = notification.object as! Float
        RSSILabel.text = "RSSI: \(String(format: "%.2f", newRSSI))"
    }
    
    func takePhoto(){
        self.shutter.backgroundColor = UIColor.green
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.shutter.backgroundColor = UIColor.systemGray2
        }
        if (CharacteristicInfo.mode == "fixed_time_interval") {
            if(nanosec_shooting_TI != 0){
                let time_after = Double(DispatchTime.now().uptimeNanoseconds - nanosec_shooting_TI!) / Double(1000000000)
                nanosec_shooting_TI = DispatchTime.now().uptimeNanoseconds
                print("\(time_after)s after last shot")
            }
            else{
                nanosec_shooting_TI = DispatchTime.now().uptimeNanoseconds
            }
        }
    }
    
    
    func appendTxDataToTextView(_ textField: UITextField){
        consoleTextView.text.append("\n[Sent]: \(String(textField.text!)) \n")
    }
    
    // Write functions
    func writeOutgoingValue(data: String, txChar: CBCharacteristic?){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = BlePeripheral.connectedPeripheral {
            if let txCharacteristic = txChar {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(incomingValue: Int8){
        var val = incomingValue
        
        let outgoingData = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        peripheral?.writeValue(outgoingData as Data, for: BlePeripheral.connectedTXChar!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField, txChar: CBCharacteristic) {
        textField.endEditing(true)
        print(textField.text!)
        writeOutgoingValue(data: textField.text! ?? "", txChar: txChar)
//        appendTxDataToTextView(textField)
        textField.resignFirstResponder()
        textField.text = ""
    }
    
    func didcloseAPP() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        writeOutgoingValue(data: "disconnected" , txChar: BlePeripheral.connectedChar)
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        writeOutgoingValue(data: "disconnected" , txChar: BlePeripheral.connectedChar)
        print("deinit")
        didcloseAPP()
    }
    
    // MARK:- Keyboard
    @objc func keyboardWillChange(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            view.frame.origin.y = (-keyboardHeight + 50)
        }
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func disconnectPeripheral() {
        print("Disconnect for peripheral.")
    }
    
    @IBAction func numOfPhotoTFAction(_ sender: UITextField) {
        guard let input = Int(String(sender.text!)) else {
            if sender.text!.isEmpty {return}
            let controller = UIAlertController(title: "Value error", message: "num_of_photo should be Int", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        if input < 1 || input > 200 {
            let controller = UIAlertController(title: "Invalid value", message: "num_of_photo should be in [1-200]", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        CharacteristicInfo.numOfPhoto = input
        print("numofphoto -> \(String(sender.text!))")
        numOfPhotoLabel.text = "num_of_photo: \(input)"
        textFieldShouldReturn(sender, txChar: BlePeripheral.numOfPhotoChar!)
    }
    
    @IBAction func timeIntervalAction(_ sender: UITextField) {
        guard let input = Float(String(sender.text!)) else {
            if sender.text!.isEmpty {return}
            let controller = UIAlertController(title: "Value error", message: "time interval should be Float", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        if input < 0.2 || input > 20.0 {
            let controller = UIAlertController(title: "Invalid value", message: "time interval should be in [0.2-20.0]", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        CharacteristicInfo.timeInterval = input
        print("time interval -> \(String(format: "%.2f", input))")
        timeIntervalLabel.text = "time interval: \(String(format: "%.2f", input))"
        textFieldShouldReturn(sender, txChar: BlePeripheral.timeIntervalChar!)
    }
    @IBAction func angleTFAction(_ sender: UITextField) {
        guard let input = Int(String(sender.text!)) else {
            if sender.text!.isEmpty {return}
            let controller = UIAlertController(title: "Value error", message: "angle should be Int", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        if input < 1 || input > 45 {
            let controller = UIAlertController(title: "Invalid value", message: "angle should be in [1-45]", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            present(controller, animated: true)
            return
        }
        CharacteristicInfo.angle = input
        print("angle -> \(String(sender.text!))")
        angleLabel.text = "angle: \(input)"
        textFieldShouldReturn(sender, txChar: BlePeripheral.angleChar!)
    }
    @IBAction func modeCtrlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                writeOutgoingValue(data: "fixed_angle" , txChar: BlePeripheral.modeChar)
                print("mode -> fixed_angle")
                CharacteristicInfo.mode = "fixed_angle"
                break
            case 1:
                writeOutgoingValue(data: "fixed_time_interval", txChar: BlePeripheral.modeChar)
                print("mode -> fixed_time_interval")
                CharacteristicInfo.mode = "fixed_time_interval"
                break
            default:
                break
        }
    }
    
    @IBAction func cameraStateCtrlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                writeOutgoingValue(data: "idle" , txChar: BlePeripheral.cameraStateChar)
                CharacteristicInfo.cameraState = "idle"
                print("camera state -> idle")
                break
            case 1:
                writeOutgoingValue(data: "shooting", txChar: BlePeripheral.cameraStateChar)
                CharacteristicInfo.cameraState = "shooting"
                print("camera state -> shooting")
                break
            default:
                break
        }
    }
    @IBAction func pressStartButton(_ sender: UIButton) {
        writeOutgoingValue(data: "shooting", txChar: BlePeripheral.cameraStateChar)
        CharacteristicInfo.cameraState = "shooting"
        sender.isHidden = true
        stopShootingButton.isHidden = false
        
    }
    
    @IBAction func pressStopButton(_ sender: UIButton) {
        writeOutgoingValue(data: "idle", txChar: BlePeripheral.cameraStateChar)
        CharacteristicInfo.cameraState = "idle"
        sender.isHidden = true
        startShootingButton.isHidden = false
    }
    @IBAction func shouldTakePhotoSwitchAction(_ sender: UISwitch) {
//        if (sender.isOn) {
//            writeOutgoingValue(data: "true" , txChar: BlePeripheral.shouldTakePhotoChar)
//            print("should take photo -> true")
//        }
//        else {
//            writeOutgoingValue(data: "false" , txChar: BlePeripheral.shouldTakePhotoChar)
//            print("should take photo -> false")
//        }
    }
    
}

extension ConsoleViewController: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }


  //Check when someone subscribe to our characteristic, start sending the data
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
      print("Device subscribe to characteristic")
  }
    
}

extension ConsoleViewController: UITextViewDelegate {

}

//extension ConsoleViewController: UITextFieldDelegate {
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    writeOutgoingValue(data: textField.text ?? "")
//    appendTxDataToTextView()
//    textField.resignFirstResponder()
//    textField.text = ""
//    return true
//
//  }
//
//  func textFieldShouldClear(_ textField: UITextField) -> Bool {
//    textField.clearsOnBeginEditing = true
//    return true
//  }
//
//}
