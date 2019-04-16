//
//  ViewController.swift
//  ProjetoARKit
//
//  Created by Rafael Paz Andrade on 11/04/19.
//  Copyright © 2019 br.org.cesar.schol. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var pontuacao: UILabel!
    
    var anchorPlane: ARPlaneAnchor?
    
    var vetorCube: SCNVector3?
    
    var cubeRed: SCNBox?
    
    var ponto = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
    }
    
    func geraCuboAzul(anchor: ARPlaneAnchor){
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.createCube(vetor: SCNVector3(anchor.center.x+self.random(), 0, anchor.center.z+self.random()), color: .blue)
        }
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
    
    
    func getCameraPosition() -> SCNVector3? {
        guard let lastFrame = sceneView.session.currentFrame else {
            return nil
        }
        
        let position = lastFrame.camera.transform * float4(x: 0, y: 0, z: 0, w: 1)
        let camera: SCNVector3 = SCNVector3(position.x, position.y, position.z)
        
        return camera
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            if anchorPlane == nil {
                createPlane(node: node, anchor: anchor)
                anchorPlane = anchor
                
                geraCuboAzul(anchor:anchor)
            }

        }
        
        //let vetor = getCameraPosition()
        //createCube(vetor: vetor!, color: .blue)
    }
    
    func random() -> Float{
        return Float.random(in: -2 ..< 2)
        
    }
    
    private func createPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            self.createCube(vetor: SCNVector3(anchor.center.x+self.random(), 0, anchor.center.z+self.random()), color: .red)
        }
        
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        
        plane.materials = [material]
        planeNode.geometry = plane
        
        node.addChildNode(planeNode)
        
        
    }
    
    private func createCube(vetor: SCNVector3, color: UIColor) {
        // Creates a rectangle
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        // Creates a material for the rectangle. The material is what is made of.
        let material = SCNMaterial()
        
        // Sets the material to be red. This will cause the cube to be all read
        material.diffuse.contents = color
        
        // Then apply the materials to the cube
        cube.materials = [material]
        
        // Creates a node. This is a 3D position (x, y, z). Remember that when the Z is increased, it is coming towards.
        let node = SCNNode()
        node.position = vetor
        
        // Apply the node geometry it will be linked with
        node.geometry = cube
        
        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        if  color == .red {
            vetorCube = vetor
            self.cubeRed = cube
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                let vetor = self.getCameraPosition()
                
                var x = self.vetorCube!.x - vetor!.x
                var y = self.vetorCube!.y - vetor!.y
                var z = self.vetorCube!.z - vetor!.z
                
                if (x >= -0.1 && x <= 0.1) &&
                    (y >= -0.1 && y <= 0.1) &&
                    (z >= -0.1 && z <= 0.1) {
                    //let text = self.createTextNode(string: "Achou!!!")
                    
                    let material = SCNMaterial()
                    
                    // Sets the material to be red. This will cause the cube to be all read
                    material.diffuse.contents = UIColor.yellow
                    
                    // Then apply the materials to the cube
                    self.cubeRed!.materials = [material]
                    self.ponto += 1
                    self.pontuacao.text = String(self.ponto)
                    self.createCube(vetor: SCNVector3(self.anchorPlane!.center.x+self.random(), 0, self.anchorPlane!.center.z+self.random()), color: .red)
                }
            }
        }
       
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
