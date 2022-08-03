import UIKit
import NetworkExtension

class ViewController: UIViewController {
    
    private let strSSID: String = "Bienvenidos Elektra-Banco Azteca"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestWifiPoints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestWifiPoints()
    }
    
    private func requestWifiPoints() {
        let options: [String: NSObject] = [kNEHotspotHelperOptionDisplayName: strSSID as NSObject]
        let queue: DispatchQueue = DispatchQueue(label: "com.bugsoft.WifiSearch", attributes: DispatchQueue.Attributes.concurrent)

        print("Started wifi scanning.")
        
        NEHotspotHelper.register(options: options, queue: queue) { [weak self] (cmd: NEHotspotHelperCommand) in
            print(cmd.commandType.rawValue)
            if cmd.commandType == NEHotspotHelperCommandType.filterScanList {
                self?.findNetwork(cmd: cmd)
            } else if cmd.commandType == NEHotspotHelperCommandType.evaluate {
                self?.evaluateNetwork(cmd: cmd)
            } else if cmd.commandType == NEHotspotHelperCommandType.authenticate {
                self?.authenticateNetwork(cmd: cmd)
            }
        }
    }
    
    private func findNetwork(cmd: NEHotspotHelperCommand) {
        guard let arrHotspotNetwork: [NEHotspotNetwork] = cmd.networkList else { return }
        for hotspotNetwork in arrHotspotNetwork {
            if strSSID == hotspotNetwork.ssid {
                let network: NEHotspotNetwork = hotspotNetwork
                network.setConfidence(NEHotspotHelperConfidence.high)
                network.setPassword("Mipaswordsecretadewifi")
                let response = cmd.createResponse(NEHotspotHelperResult.success)
                response.setNetworkList([network])
                response.deliver()
                break
            }
        }
        
    }
    
    private func evaluateNetwork(cmd: NEHotspotHelperCommand) {
        if let network = cmd.network, network.ssid == strSSID {
            network.setConfidence(NEHotspotHelperConfidence.high)
            let response = cmd.createResponse(NEHotspotHelperResult.success)
            response.setNetwork(network)
            response.deliver()
        }
    }
    
    private func authenticateNetwork(cmd: NEHotspotHelperCommand) {
        if let network = cmd.network, network.ssid == strSSID {
            network.setConfidence(NEHotspotHelperConfidence.high)
            let response = cmd.createResponse(NEHotspotHelperResult.success)
            response.setNetwork(network)
            sendCredentialsWebPage(cmd: cmd)
            response.deliver()
        }
    }
    
    private func sendCredentialsWebPage(cmd: NEHotspotHelperCommand) {
        if var urlComponents = URLComponents(string: "https://urltipotelmex.com"){
            urlComponents.queryItems = [
                URLQueryItem(name: "username", value: "usuario de totalplay"),
                URLQueryItem(name: "password", value: "password de totalplay")
            ]
            
            guard let url = urlComponents.url else { return }
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            request.bind(to: cmd)
            request.allowsCellularAccess = false
            request.cachePolicy = .reloadIgnoringCacheData
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self] data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self?.sendPushNotification()
                } else {
                    
                }
                semaphore.signal()
            }
            task.resume()
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }
    
    
    private func sendPushNotification(){
        
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        }
        
        let content = UNMutableNotificationContent()
        content.title = "SUPER APP BAZ"
        content.body = "¡Ya puedes usar tu App BAz con navegación ilimitada! Disfruta de tu WiFi Pass gratis del 11/Julio/2021 al 15/Agosto/2021"
        content.sound = UNNotificationSound.default
        
        let date: Date = Date().addingTimeInterval(1)
        let dateComponent: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let miTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: miTrigger)
        center.add(request)
    }

}

