//
//  ViewController.swift
//  Viatori
//
//  Created by Serkut Yegin on 27/10/2016.
//  Copyright © 2016 Proaegean Ar-Ge. All rights reserved.
//

import UIKit
import SocketIO
import EZSwiftExtensions

class ViewController: VTBaseViewController, StreamDelegate, UITableViewDelegate, UITableViewDataSource {

    struct Message {
        var name : String
        var message : String
    }
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var inputStream : InputStream?
    var outputStream : OutputStream?
    var text : String?
    var messages = [Message]()
    
    let socket = SocketIOClient(socketURL: URL(string: "http://naturalstonebook.com:3000")!, config: [.log(true), .forcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.textFieldMessage != nil {
            
            self.textFieldMessage.becomeFirstResponder()
        }
        
        /*var request : DataRequest?
        
        Alamofire.SessionManager.default.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(URL(string: "http://example.com/url1")!, withName: "one")
                multipartFormData.append(URL(string: "http://example.com/url2")!, withName: "two")
        },
            to: "http://example.com/to",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    request = upload.responseJSON { response in
                        debugPrint(response)
                    }
                    
                    upload.uploadProgress { progress in
                        
                        print(progress.fractionCompleted)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        request?.cancel()*/
        
        if text != nil {
            self.initNetworkCommunication()
//            self.joinChat(name: text)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if inputStream != nil && outputStream != nil {
            inputStream!.close()
            outputStream!.close()
            inputStream!.remove(from: .current, forMode: .defaultRunLoopMode)
            outputStream!.remove(from: .current, forMode: .defaultRunLoopMode)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination.isKind(of: ViewController.classForCoder()) {
            (segue.destination as! ViewController).text = self.textField.text
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {

        if !(self.textFieldMessage.text?.isEmpty)! {
            let message = self.textFieldMessage.text!
            let myJSON = [
                "name" : "serkut",
                "message":  message,
                "created_at" : "25.11.2016"
                ] as [String : Any]
            
            self.socket.emit("new_message", myJSON)
            self.textFieldMessage.text = ""
        }
        
        
        /*
        if !(self.textFieldMessage!.text?.isEmpty)! {
            let response = "msg:\(self.textFieldMessage.text!)"
            let data : Data = response.data(using: .utf8)!
            let lenght = data.count
            data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                outputStream?.write(bytes, maxLength:lenght)
            }
            self.textFieldMessage.text = ""
        }*/
    }
    
    func initNetworkCommunication() {
        
        self.socket.on("connect") {data, ack in
            NSLog("connected")
        }
        
        self.socket.on("update_count_message") {data, ack in
            
        }
        
        self.socket.on("new_message") {data, ack in
            
            NSLog("new message received")
            print(data)
            
            let dataArray = data as NSArray
            let dataDict = dataArray[0] as! Dictionary<String,Any>
            
            self.messageReceived(message: Message(name:dataDict["name"] as! String,message:dataDict["message"] as! String))
        }
        
        self.socket.connect()
        
        /*
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        let host : CFString = NSString(string: "http://naturalstonebook.com")
        let port : UInt32 = UInt32(3000)
        
        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        
        inputStream!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        inputStream!.open()
        outputStream!.open()*/
    }
    
    func joinChat(name : String) {
        let response = "iam:\(name)"
        let data : Data = response.data(using: .utf8)!
        let lenght = data.count
        data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
            outputStream?.write(bytes, maxLength:lenght)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case Stream.Event.openCompleted:
                NSLog("Stream opened")
                break;
            case Stream.Event.hasBytesAvailable:
                self.handleStream(stream: aStream)
                break;
            case Stream.Event.hasSpaceAvailable:
                break;
            case Stream.Event.errorOccurred:
                NSLog("Cannot connect to server")
                break;
            case Stream.Event.endEncountered:
                aStream.close()
                aStream.remove(from: .current, forMode: .defaultRunLoopMode)
                break;
            
            default:
                break;
        }
    }
    
    func handleStream(stream:Stream) {
        /*if stream == inputStream {
            var buffer = [UInt8](repeating: 0, count: 1024)
            var len = 0
            
            while inputStream!.hasBytesAvailable {
                len = inputStream!.read(&buffer, maxLength: buffer.count)
                
                if len > 0 {
                    let messageFromServer = NSString(bytes:&buffer, length:buffer.count, encoding:String.Encoding.utf8.rawValue)
                    self.messageReceived(message: messageFromServer as! String)
                }
            }
        }*/
    }
    
    func messageReceived(message:Message) {
        
        self.messages.append(message)
        self.tableView.reloadData()
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellIdentifier")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = "\(self.messages[indexPath.row].name) - \(self.messages[indexPath.row].message)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
}

