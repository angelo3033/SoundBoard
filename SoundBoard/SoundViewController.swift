/*
  SoundViewController.swift
  SoundBoard

  Created by Mac 11 on 5/19/21.
 Copyright © 2021 SoundBoard*/

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var displayLbl: UILabel!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = true
        // codigo agregado
        do {
            reproducirAudio = try AVAudioPlayer(contentsOf: audioURL!)
            displayLbl.text = String(reproducirAudio!.duration)
            
        }catch{
            
        }
    
    }
    
    func configurarGrabacion() {
        do {
            
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo del audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion donde se guardan los archivos
            print("--------------------------------")
            print(audioURL!)
            print("--------------------------------")
            
            //crear opciones para el grabador del auido
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion del audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        }catch let error as NSError{
            
            print(error)
            
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if grabarAudio!.isRecording {
            //detener audio
            grabarAudio?.stop()
            //cambiar el texto del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            //empezar a grabar
            grabarAudio?.record()
            //cambiar el texto del boton grabar
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
        
    }
    // codigo agregado
    @objc
    func updateSecond() {
        displayLbl.text = String(reproducirAudio!.currentTime)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            // timer agregado
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSecond), userInfo: nil, repeats: true)
            print("reproduciendo")
        }catch{
            
        }
        
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        // atributo de tiempo agregado
        grabacion.tiempo = displayLbl.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    // action para el volumen
    @IBAction func volumeSlider(_ sender: UISlider) {
        
        print(sender.value)
        reproducirAudio?.volume = sender.value
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
