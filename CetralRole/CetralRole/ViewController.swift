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
    @IBOutlet weak var button: UIButton!
    
    var myCentralManager = CBCentralManager()
    
    let myCBUUID = CBUUID(string: "1234")
    var serviceCBUUID = CBUUID(string: "5678")
    var chCBUUID = CBUUID(string: "9012")
    
    var receive: CBPeripheral?
    
    var status = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func actDiscover(_ sender: Any) {
        
        if !status {
            if myCentralManager.state == .poweredOn {
                button.setTitle("탐색 중", for: .normal)
                myCentralManager.scanForPeripherals(withServices: [myCBUUID])
                print("스캔 하기")
                status.toggle()
                
            }else {
                let alertController = UIAlertController(title: "블루투스를 켜주세요", message: nil, preferredStyle: .alert);
                
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            }
        }else{
            textView.text = "받을 내용"
            button.setTitle("탐색", for: .normal)
                        if let receive = receive {
                            myCentralManager.cancelPeripheralConnection(receive)
                        }
            print("연결 끊기")
            status.toggle()
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
        print("======================")
        print("peripheral",peripheral)
        print("advertisementData",advertisementData)
        print("RSSI",RSSI)
        print("======================")
        
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
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("연결 실패")
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print("didDiscoverServices : ",service)
            peripheral.discoverCharacteristics([chCBUUID], for: service)

        }
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("modify peripheral : ", peripheral)
        print("invalidatedServices : ", invalidatedServices)
        guard let services = peripheral.services else {return}
        for service in services {
            print("mofi service",service)
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
                  peripheral.setNotifyValue(true, for: characteristic) //이거 설정 없으면 실시간 반영 안 됨!!
              }
          }
        
        if error != nil {
            print("didDiscoverCharacteristicsFor error:", error.debugDescription)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("didUpdateValueFor characteristic : ",characteristic)

        if let val = characteristic.value {
            if let value = String(data: val, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.textView.text = value
                }
            }
           
        }

    }

}

