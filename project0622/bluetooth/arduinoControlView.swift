    import SwiftUI
    import FirebaseDatabaseInternal
    import CoreBluetooth
    import SwiftUICharts

    class BluetoothManagerr: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
        weak var delegate: BluetoothManagerDelegate?
        var centralManager: CBCentralManager!
        var peripheral: CBPeripheral?
        let EMGServiceUUID = CBUUID(string: "FFE0")
        let EMGCharacteristicUUID = CBUUID(string: "FFE1")
        var EMGCharacteristic: CBCharacteristic?
        
        override init() {
            super.init()
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .poweredOn:
                centralManager.scanForPeripherals(withServices: [EMGServiceUUID], options: nil)
            default:
                print("藍牙不可用。")
            }
        }
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
            self.peripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            peripheral.delegate = self
            peripheral.discoverServices([EMGServiceUUID])
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            if let services = peripheral.services {
                for service in services {
                    if service.uuid == EMGServiceUUID {
                        peripheral.discoverCharacteristics([EMGCharacteristicUUID], for: service)
                    }
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    print("Characteristic UUID: \(characteristic.uuid)")
                    print("Service UUID: \(service.uuid)")
                    if characteristic.uuid == EMGCharacteristicUUID {
                        EMGCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            if let data = characteristic.value, let emgString = String(data: data, encoding: .utf8) {
                delegate?.didReceiveEMGString(emgString)
                // 將收到的 EMG 值寫入 Firebase
                let ref = Database.database().reference()
                ref.child("emgValues").childByAutoId().setValue(emgString)
            }
        }
    }

    protocol BluetoothManagerDelegate: AnyObject {
        func didReceiveEMGString(_ emgString: String)
    }

class AnalysisViewModel: ObservableObject, BluetoothManagerDelegate {
    @Published var emgValues: [(timeStamp: Date, value: String)] = []
    @Published var isCapturing: Bool = false
    
    private var bluetoothManager: BluetoothManagerr
    
    init() {
        bluetoothManager = BluetoothManagerr()
        bluetoothManager.delegate = self
    }
    
    func didReceiveEMGString(_ emgString: String) {
        if isCapturing {
            DispatchQueue.main.async {
                let timeStamp = Date()
                self.emgValues.append((timeStamp, emgString))
                
                // 只保留最新的數據
                if self.emgValues.count > 100 {
                    self.emgValues.removeFirst(self.emgValues.count - 100)
                }
            }
        }
    }
    
    func startCapture() {
        // 開始擷取時，開始掃描設備
        bluetoothManager.centralManager.scanForPeripherals(withServices: [bluetoothManager.EMGServiceUUID], options: nil)
        emgValues = []
        isCapturing = true
    }
    
    func stopCapture() {
        // 停止擷取時，停止掃描設備
        bluetoothManager.centralManager.stopScan()
        isCapturing = false
    }
}


    struct AnalysisView: View {
        @StateObject private var viewModel: AnalysisViewModel
        
        init() {
            _viewModel = StateObject(wrappedValue: AnalysisViewModel())
        }
        
        var body: some View {
            VStack {
                VStack {
                    Button(action: {
                        viewModel.startCapture()
                    }, label: {
                        Text("開始擷取 EMG 值")
                            .customFont(.headline)
                            .padding(20)
                            .frame(width: 250)
                            .background(Color(hex: "008080"))
                            .foregroundColor(.white)
                            .shadow(color: Color(hex: "00ffff").opacity(0.5), radius: 20, x: 0, y: 10)
                            .cornerRadius(20)
                    })
                    .padding()
                    
                    LineView(data: viewModel.emgValues.sorted(by: { $0.timeStamp < $1.timeStamp }).prefix(100).map { Double($0.value) ?? 0 },
                             title: "EMG 折線圖",
                             style: ChartStyle(backgroundColor: .white, accentColor: .blue, gradientColor: GradientColor(start: .blue, end: .white), textColor: .black, legendTextColor: .blue, dropShadowColor: .blue))
                        .frame(height: 300)
                        .padding()
                    
                    Spacer()
                    Text("正在擷取 EMG 值：\(viewModel.isCapturing ? "是" : "否")")
                        .font(.headline)
                        .padding()
                    
                    // 停止擷取按鈕
                    Button(action: {
                        // 在這裡處理停止擷取操作
                        viewModel.stopCapture() // 停止擷取 EMG 值
                        // 其他需要處理的停止擷取操作...
                    }) {
                        Text("停止擷取")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                    
                    // 清除按鈕
                    Button(action: {
                        let ref = Database.database().reference().child("emgValues")
                        ref.removeValue { error, _ in
                            if let error = error {
                                print("刪除失敗：", error)
                            } else {
                                print("數據已經成功清除。")
                            }
                        }
                        viewModel.emgValues = [] // 清空 EMG 值
                    }) {
                        Text("清除")
                            .customFont(.headline)
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.red)
                            .shadow(color: Color(hex: "00ffff").opacity(0.5), radius: 20, x: 0, y: 10)
                            .cornerRadius(20)
                    }
                    .padding(.bottom)
                }
                Spacer()
            }
        }
    }



    struct AnalysisView_Previews: PreviewProvider {
        static var previews: some View {
            AnalysisView()
        }
    }
