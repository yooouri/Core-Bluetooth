//
//  ViewController.swift
//  CetralRole
//
//  Created by YURI KIM on 2023/05/31.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    
    var myCentralManager = CBCentralManager()
    let phoneCBUUID = CBUUID(string: "1234")
    
    var serviceCBUUID = CBUUID(string: "5678")
    var chCBUUID = CBUUID(string: "9012")
    
    var receive: CBPeripheral?
    
    var status = false
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func actDiscover(_ sender: Any) {

        if myCentralManager.state == .poweredOn {
            myCentralManager.scanForPeripherals(withServices: [phoneCBUUID])
            if let receive = receive {
                myCentralManager.cancelPeripheralConnection(receive)
            }
//            status.toggle()
            print("스캔")
            
        }else {
            let alertController = UIAlertController(title: "블루투스를 켜주세요", message: nil, preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "확인", style: .cancel)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {

               case .unknown:
                   print("central.state is unknown")
               case .resetting:
                   print("central.state is resetting")
               case .unsupported:
                   print("central.state is unsupported")
               case .unauthorized:
                   print("central.state is unauthorized")
               case .poweredOff:
                   print("central.state is poweredOff")
               case .poweredOn:
                   print("central.state is poweredOn")
               @unknown default:
                   print("central.state default case")
               }
    }
        
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("peripheral",peripheral)
        print("advertisementData",advertisementData)
        print("RSSI",RSSI)
        
        receive = peripheral
        if let receive = receive {
            myCentralManager.connect(receive)
        }
        
        myCentralManager.stopScan()
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected")
        receive?.delegate = self //여기 선언해야 됨!!!
        //nil이면 모든 서비스 검색
        receive?.discoverServices([serviceCBUUID])
        
        //연결 끊기
//        myCentralManager.cancelPeripheralConnection(receive?)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("연결 실패")
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print("service",service)
            peripheral.discoverCharacteristics([chCBUUID], for: service)

        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

          for characteristic in characteristics {
              print("characteristic",characteristic)
             
              if characteristic.properties.contains(.read) {
                  peripheral.readValue(for: characteristic)
                print("\(characteristic.uuid): properties contains .read")
              }
              if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
              }
              if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                  peripheral.setNotifyValue(true, for: characteristic)
              }
          }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("ddddd",peripheral)

        if let val = characteristic.value {
            let value = String(data: val, encoding: .utf8)
            textView.text = value
        }
//      switch characteristic.uuid {
//        case bodySensorLocationCharacteristicCBUUID:
//          print(characteristic.value ?? "no value")
//        default:
//          print("Unhandled Characteristic UUID: \(characteristic.uuid)")
//      }
    }
}

