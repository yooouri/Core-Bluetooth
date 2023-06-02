//
//  ViewController.swift
//  PeripheralRole
//
//  Created by YURI KIM on 2023/06/01.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    var status = false
    
    var myPeripheralManager = CBPeripheralManager()
    var myCBUUID = CBUUID(string: "1234") //C720036C-32A6-428B-8327-CB51F4C71362
    var serviceCBUUID = CBUUID(string: "5678")
    var chCBUUID = CBUUID(string: "9012")
//    lazy var myCharacteristic = CBMutableCharacteristic(type: myCBUUID, properties: [.notify, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
//    lazy var myService = CBMutableService(type: myCBUUID, primary: true)
    
    var dataToSend = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func actAdvertising(_ sender: Any) {
        
        if !status {
            settingServices()
            myPeripheralManager.startAdvertising( [CBAdvertisementDataLocalNameKey: "MyTest",
                                               CBAdvertisementDataServiceUUIDsKey : [myCBUUID]])

            button.setTitle("신호 끄기", for: .normal)
        }else{
            
            myPeripheralManager.stopAdvertising()
            button.setTitle("신호 켜기", for: .normal)
        }
        
        status.toggle()
    }
    
    func settingServices() {
        print("tttttt11111",textView.text)
        let myCharacteristic = CBMutableCharacteristic(type: chCBUUID, properties: .read, value: textView.text.data(using: .utf8), permissions: .readable)
        let myService = CBMutableService(type: serviceCBUUID, primary: true)
//        myService.characteristics?.append(myCharacteristic)
        myService.characteristics = [myCharacteristic]
        myPeripheralManager.add(myService)
    }
    
    @IBAction func actSend(_ sender: Any) {
        let textCharacteristic = CBMutableCharacteristic(type: chCBUUID, properties: [.read, .write], value: "너느뭐니".data(using: .utf8), permissions: [.readable, .writeable])

        // Get the data
        if let data = textView.text.data(using: String.Encoding.utf8) {
//            dataToSend = data

            let success = myPeripheralManager.updateValue(data, for: textCharacteristic, onSubscribedCentrals: nil)
            if !success{
                let alertController = UIAlertController(title: "보내기 실패", message: nil, preferredStyle: .alert);
                
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            }


        }

    }
    
    
}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
               case .unknown:
                   print("peripheral.state is unknown")
               case .resetting:
                   print("peripheral.state is resetting")
               case .unsupported:
                   print("peripheral.state is unsupported")
               case .unauthorized:
                   print("peripheral.state is unauthorized")
               case .poweredOff:
                   print("peripheral.state is poweredOff")
               case .poweredOn:
                   print("peripheral.state is poweredOn")
//            settingServices()
//            let serviceUUID = CBUUID(string: myCBUUID.uuidString)
//                   self.service = CBMutableService(type: serviceUUID, primary: true)
            
               @unknown default:
                   print("peripheral.state default case")
               }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if (error != nil) {
            print("error publishing service!!!")
        }
        print("service add",service)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if (error != nil) {
            print("error Advertising !!!",error?.localizedDescription)
            return
        }
        print("Start advertising succeeded")

    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
//        if request.characteristic.uuid == myCharacteristic.uuid {
//            print("request", request.characteristic.uuid)
//            print("my", myCharacteristic.uuid)
            
//            if request.offset > myCharacteristic.value?.count ?? 0 {
//                print("invaildoffset!!!!")
//                myPeripheralManager.respond(to: request, withResult: .invalidOffset)
//                return
//            }
//            request.value = myCharacteristic.value?.subdata(in: NSRange(location: request.offset, length: (myCharacteristic.value?.count ?? 0)-request.offset))
            
            print("request.value", request.value)
            request.value = "리퀘스트".data(using: .utf8)
            myPeripheralManager.respond(to: request, withResult: .success)
            print("request",request)
            
//        }else{
//            print("request diff", request.characteristic.uuid)
//        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
                   if let value = request.value {
                       
                       //here is the message text that we receive, use it as you wish.
                       let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                   }
                   self.myPeripheralManager.respond(to: request, withResult: .success)
               }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("구독ㄱㄱ", peripheral)
        print("tttttt",textView.text)
        let textCharacteristic = CBMutableCharacteristic(type: chCBUUID, properties: [.read, .write], value: textView.text.data(using: .utf8), permissions: [.readable, .writeable])

        // Get the data
        if let data = textView.text.data(using: String.Encoding.utf8) {
//            dataToSend = data

            let success = myPeripheralManager.updateValue(data, for: textCharacteristic, onSubscribedCentrals: nil)
            if !success{
                let alertController = UIAlertController(title: "구독 실패", message: nil, preferredStyle: .alert);
                
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            }

        }

    }
    
    
}
