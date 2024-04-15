//
//  CBUUIDs.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/3/21.
//

import Foundation
import CoreBluetooth

struct CBUUIDs{

    static let kBLEService_UUID = "187F0000-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_mode_UUID = "187F0001-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_numOfPhoto_UUID = "187F0002-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_timeInterval_UUID = "187F0003-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_angle_UUID = "187F0004-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_cameraState_UUID = "187F0005-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_shouldTakePhoto_UUID = "187F0006-44AD-4F56-BEE4-23B6CAC3FE46"
    static let kBLE_connected_UUID = "187F0007-44AD-4F56-BEE4-23B6CAC3FE46"
    static let MaxCharacters = 50

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
//    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
//    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
    static let mode_UUID = CBUUID(string: kBLE_mode_UUID)// (Property = Write)
    static let numOfPhoto_UUID = CBUUID(string: kBLE_numOfPhoto_UUID)// (Property = Write)
    static let timeInterval_UUID = CBUUID(string: kBLE_timeInterval_UUID)// (Property = Write)
    static let angle_UUID = CBUUID(string: kBLE_angle_UUID)// (Property = Write)
    static let cameraState_UUID = CBUUID(string: kBLE_cameraState_UUID)// (Property = Read/Notify/Write)
    static let shouldTakePhoto_UUID = CBUUID(string: kBLE_shouldTakePhoto_UUID)// (Property = Read/Notify/Write)
    static let connected_UUID = CBUUID(string: kBLE_connected_UUID)// (Property = Read/Write)
    static let characteristic_UUIDs = [
        mode_UUID,
        numOfPhoto_UUID,
        timeInterval_UUID,
        angle_UUID,
        cameraState_UUID,
        shouldTakePhoto_UUID,
        connected_UUID
    ]

}
