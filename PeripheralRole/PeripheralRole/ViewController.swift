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
    
    var myPeripheralManager = CBPeripheralManager()
    
    var myCBUUID = CBUUID(string: "1234") //C720036C-32A6-428B-8327-CB51F4C71362
    var serviceCBUUID = CBUUID(string: "5678")
    var chCBUUID = CBUUID(string: "9012")
    
    lazy var textCharacteristic = CBMutableCharacteristic(type: chCBUUID, properties: [.read,.notify], value: nil, permissions: [.readable, .writeable])
    lazy var myService = CBMutableService(type: serviceCBUUID, primary: true)
    
    var status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
       
        
    }
    
    //빈 화면 터치시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func validate(textView textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            // this will be reached if the text is nil (unlikely)
            // or if the text only contains white spaces
            // or no text at all
            return false
        }

        return true
    }
    
    @IBAction func actAdvertising(_ sender: Any) {
        if !status {
            myService.characteristics = [textCharacteristic]
            myPeripheralManager.add(myService)
            myPeripheralManager.startAdvertising( [CBAdvertisementDataLocalNameKey: "MyTest",
                                               CBAdvertisementDataServiceUUIDsKey : [myCBUUID]])
            textView.isEditable = true
            textView.text = ""
            button.setTitle("신호 끄기", for: .normal)
        }else{
            
            myPeripheralManager.stopAdvertising()
            textView.isEditable = false
            textView.text = "신호를 켜주세요"
            button.setTitle("신호 켜기", for: .normal)
            myPeripheralManager.removeAllServices()
        }
        
        status.toggle()
    }

    
    func updateCharacteristic() {
        if !status {
            return
        }
        if let data = textView.text.data(using: String.Encoding.utf8) {
            let success = myPeripheralManager.updateValue(data, for: textCharacteristic, onSubscribedCentrals: nil)
            if !success{
                let alertController = UIAlertController(title: "전송 실패", message: nil, preferredStyle: .alert);
                
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

    
}

extension ViewController: UITextViewDelegate  {
    func textViewDidChange(_ textView: UITextView) {
        updateCharacteristic()
    }
    
}
