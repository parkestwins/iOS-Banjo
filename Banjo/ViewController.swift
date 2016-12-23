//
//  ViewController.swift
//  Banjo
//
//  Created by Jarrod Parkes on 7/18/16.
//  Copyright © 2016 ParkesTwins. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit
import SceneKit.ModelIO

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Properties
 
    // MARK: Outlets
    
    @IBOutlet weak var sceneView: SCNView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load3DModel()
    }
    
    func testFirebase() {
//        let firebaseDBRef = FIRDatabase.database().reference()
//        firebaseDBRef.child("platforms").child("nintendo64").observeSingleEvent(of: .value, with: { snapshot in
//            let result = snapshot.value as! [String:AnyObject]
//            let abbreviation = result["abbreviation"] as! String
//            let title = result["title"] as! String
//            print("\(title) (\(abbreviation))")
//        }) { error in
//            print(error.localizedDescription)
//        }
    }
    
    func load3DModel() {
        // Load the .OBJ file
        guard let url = Bundle.main.url(forResource: Constants.Models.testModel, withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        // Create a material from the various textures
        let scatteringFunction = MDLScatteringFunction()
        let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
        material.setTextureProperties(Constants.Models.testTextures)
      
        // Apply the texture to every submesh of the asset
        for  submesh in object.submeshes!  {
            if let submesh = submesh as? MDLSubmesh {
                submesh.material = material
            }
        }
        
        // Wrap the ModelIO object in a SceneKit object
        let node = SCNNode(mdlObject: object)
        node.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        
        // Set up the SceneView
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        // sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.clear
    }
}
