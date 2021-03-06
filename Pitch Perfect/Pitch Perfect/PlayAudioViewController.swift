//
//  PlayAudioViewController.swift
//  Pitch Perfect
//
//  Created by Ashish Patel on 2/20/15.
//  Copyright (c) 2015 Average Techie. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController,AVAudioPlayerDelegate{
    
    var audioPlayer: AVAudioPlayer!
    var audioPlayerEcho: AVAudioPlayer!
    var recievedAudio: RecordedAudio!
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    
    @IBOutlet weak var playpauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //keeping code here for testing
        //get the file code structure
        var path = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3")
        if (path != nil){
            var urlPath = NSURL(fileURLWithPath: path!)
            
            audioPlayer = AVAudioPlayer(contentsOfURL: urlPath, error: nil)
            audioPlayer.enableRate = true
            
            audioPlayerEcho = AVAudioPlayer(contentsOfURL: urlPath, error: nil)
            audioPlayerEcho.enableRate = true
            
            audioFile = AVAudioFile(forReading: urlPath, error: nil)
            
        }else{
            println("can't find path")
        }
        
        /*
        
        if (recievedAudio.filePathUrl != nil){
        var urlPath = recievedAudio.filePathUrl
        
        audioPlayer = AVAudioPlayer(contentsOfURL: urlPath, error: nil)
        audioPlayer.enableRate = true
        
        audioPlayerEcho = AVAudioPlayer(contentsOfURL: urlPath, error: nil)
        audioPlayerEcho.enableRate = true
        
        audioFile = AVAudioFile(forReading: urlPath, error: nil)
        }else{
        println("can't find path")
        }
        */
        audioPlayer.delegate=self
        audioEngine = AVAudioEngine()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didSlowButtonClicked(sender: UIButton) {
        self.stopAllPlayers()
        audioPlayer.rate = 0.5
        audioPlayer.play()
        
    }
    
    
    @IBAction func didFastButtonClicked(sender: UIButton) {
        self.stopAllPlayers()
        audioPlayer.rate = 2.0
        audioPlayer.play()
    }
    
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("didFinishPlaying")
        player.stop()
        playpauseButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    }
    
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        player.pause()
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        player.play()
    }
    
    @IBAction func didStopButtonClicked(sender: UIButton) {
        /*
        works for audioPlayer.
        */
        if let playingAudio = audioPlayer?.playing{
            if(playingAudio){
                audioPlayer.pause()
                var playImage = UIImage(named: "play")
                sender.setImage(playImage, forState: UIControlState.Normal)
            }else{
                audioPlayer.play()
                var pauseImage  = UIImage(named: "pause")
                sender.setImage(pauseImage, forState: UIControlState.Normal)
                
            }
        }
        
        /*
        not sure whats the delegate method for finish playing audioPlayerNode.
        */
        if(self.audioPlayerNode != nil){
            println("audioPlayerNode \(audioPlayerNode.playing)")
        }
    }
    
    
    
    @IBAction func playChipmonkButtonClick(sender: UIButton) {
        println("Play chipmonk button clicked")
        playAudioWithPitch(1000)
        
    }
    
    
    @IBAction func playDarthVaderButtonClicked(sender: UIButton) {
        println("Play darthvader button clicked")
        playAudioWithPitch(-1000)
    }
    
    
    func playAudioWithPitch(pitch: Float){
        
        var pitchEffect: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        
        playWithEffect(pitchEffect)
    }
    
    //playing echo
    @IBAction func playAudioWithEcho(sender: UIButton){
        
        stopAllPlayers()
        
        audioPlayer.currentTime = 0;
        audioPlayer.play()
        
        let delay: NSTimeInterval = 0.2 //100 ms
        let playTime: NSTimeInterval = audioPlayer.deviceCurrentTime + delay
        audioPlayerEcho.stop()
        audioPlayerEcho.currentTime = 0
        audioPlayerEcho.volume = 0.8
        audioPlayerEcho.playAtTime(playTime)
    }
    
    
    @IBAction func playAudioWithReverb(sender: UIButton){
        
        var reverbEffect: AVAudioUnitReverb = AVAudioUnitReverb()
        reverbEffect.wetDryMix = 80
        
        playWithEffect(reverbEffect)
    }
    
    
    func playWithEffect(effect: AVAudioUnit){
        stopAllPlayers()
        audioEngine.stop()
        audioEngine.reset()
        
        //initialize all audio tools
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        audioEngine.attachNode(effect)
        
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
        
    }
    
    
    func stopAllPlayers(){
        audioPlayerEcho.stop()
        audioPlayer.stop()
        if(audioPlayerNode != nil){
            audioPlayerNode.stop()
        }
    }
    
}

