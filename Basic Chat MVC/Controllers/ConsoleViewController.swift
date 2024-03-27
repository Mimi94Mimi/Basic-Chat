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
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet weak var shouldTakePhoto: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var numOfPhotoTextField: UITextField!
    @IBOutlet weak var angleTextField: UITextField!
    @IBOutlet weak var cameraStateControl: UISegmentedControl!
    @IBOutlet weak var shouldTakeSwitch: UISwitch!
    @IBOutlet weak var txLabel: UILabel!
    @IBOutlet weak var rxLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appendRxDataToTextView(notification:)), name: NSNotification.Name("Notify"), object: nil)
        
        
        modeLabel.text = "mode:"
        numOfPhotoLabel.text = "num_of_photo:"
        angleLabel.text = "angle:"
        cameraStateLabel.text = "camera_state:"
        shouldTakePhoto.text = "should_take_photo:"
        
        //    txLabel.text = "TX:\(String(BlePeripheral.connectedTXChar!.uuid.uuidString))"
        //    rxLabel.text = "RX:\(String(BlePeripheral.connectedRXChar!.uuid.uuidString))"
        
        //    if let service = BlePeripheral.connectedService {
        //      serviceLabel.text = "Number of Services: \(String((BlePeripheral.connectedPeripheral?.services!.count)!))"
        //    } else{
        //      print("Service was not found")
        //    }
    }
    
    @objc func appendRxDataToTextView(notification: Notification) -> Void{
//        consoleTextView.text.append("\n[Recv]: \(notification.object!) \n")
        print("notify")
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        CharacteristicInfo.numOfPhoto = Int(String(sender.text!)) ?? 0
        print("numofphoto -> \(String(sender.text!))")
        textFieldShouldReturn(sender, txChar: BlePeripheral.numOfPhotoChar!)
    }
    
    @IBAction func angleTFAction(_ sender: UITextField) {
        CharacteristicInfo.angle = Int(String(sender.text!)) ?? 0
        print("angle -> \(String(sender.text!))")
        textFieldShouldReturn(sender, txChar: BlePeripheral.angleChar!)
    }
    @IBAction func modeCtrlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                writeOutgoingValue(data: "fixed_angle" , txChar: BlePeripheral.modeChar)
                print("mode -> fixed_angle")
                break
            case 1:
                writeOutgoingValue(data: "fixed_time_interval", txChar: BlePeripheral.modeChar)
                print("mode -> fixed_time_interval")
                break
            default:
                break
        }
    }
    
    @IBAction func cameraStateCtrlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                writeOutgoingValue(data: "idle" , txChar: BlePeripheral.cameraStateChar)
                print("camera state -> idle")
                break
            case 1:
                writeOutgoingValue(data: "shooting", txChar: BlePeripheral.cameraStateChar)
                print("camera state -> shooting")
                break
            default:
                break
        }
    }
    
    @IBAction func shouldTakePhotoSwitchAction(_ sender: UISwitch) {
        if (sender.isOn) {
            writeOutgoingValue(data: "true" , txChar: BlePeripheral.shouldTakePhotoChar)
            print("should take photo -> true")
        }
        else {
            writeOutgoingValue(data: "false" , txChar: BlePeripheral.shouldTakePhotoChar)
            print("should take photo -> false")
        }
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
