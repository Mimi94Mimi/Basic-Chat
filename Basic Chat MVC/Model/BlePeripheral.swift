//
//  BlePeripheral.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/14/21.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
    static var connectedPeripheral: CBPeripheral?
    static var connectedService: CBService?
    static var connectedTXChar: CBCharacteristic?
    static var connectedRXChar: CBCharacteristic?
    static var modeChar: CBCharacteristic?
    static var numOfPhotoChar: CBCharacteristic?
    static var angleChar: CBCharacteristic?
    static var cameraStateChar: CBCharacteristic?
    static var shouldTakePhotoChar: CBCharacteristic?
}

class CharacteristicInfo {
    static var mode: String? = "fixed_angle"
    static var numOfPhoto: Int? = 5
    static var angle: Int? = 3
    static var cameraState: String? = "idle"
    static var shouldTakePhoto: String? = "false"
}

class lastCharValue {
    static var cameraState: String? = "idle"
    static var shouldTakePhoto: String? = "false"
}
