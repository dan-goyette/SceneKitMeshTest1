//
//  GameViewController.swift
//  SceneKitMeshTest1
//
//  Created by Dan Goyette on 5/18/16.
//  Copyright (c) 2016 Dan Goyette. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController , SCNSceneRendererDelegate{
    
    
    var allNodes : [SCNNode] = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 25, y: 50, z: 60)
        cameraNode.eulerAngles.x = Float( -1 * M_PI_4)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.position = SCNVector3(x: 25, y: 5, z: 25)
        lightNode.eulerAngles.x = Float( M_PI_2)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        
        
        var triangleSets = [[SCNVector3]]()
        var pointYValues: [[Float]] = []
        
        let dimension = 50
        
        for x in 0...dimension {
            var subList = [Float]()
            for z in 0...dimension {
                //let baseY = max( abs(Float(x) - (Float(dimension) / 2.0)), abs(Float(z) - (Float(dimension) / 2.0)))
                //let baseY = 3.0 * (sin(Float(x)) - cos(Float(z)))
                //let baseY = 3 * sin(abs(Float(x) / 3.0) + abs(Float(z) / 3.0)) //+ cos(abs(Float(x) / 3.0) + abs(Float(z) / 3.0)))
                //subList.append(randomBetweenNumbers(Float(baseY), secondNum: Float(Float(baseY) + 0.0)))
                
                let baseY = 3 * sin(GLKVector2Distance( GLKVector2Make(Float(x), Float(z)), GLKVector2Make(Float(dimension / 2), Float(dimension / 2))) / 2.0)
                subList.append(baseY)
            }
            pointYValues.append(subList)
        }
        
        for x in 0...(dimension - 1) {
            for z in 0...(dimension - 1) {
                let point11 = SCNVector3Make(Float(x), Float(pointYValues[x][z]), Float(z))
                let point12 = SCNVector3Make(Float(x), Float(pointYValues[x][z + 1]), Float(z + 1))
                let point21 = SCNVector3Make(Float(x + 1), Float(pointYValues[x + 1][z]), Float(z))
                let point22 = SCNVector3Make(Float(x + 1), Float(pointYValues[x + 1][z + 1]), Float(z + 1))
                
                triangleSets.append([SCNVector3](arrayLiteral: point11, point12, point21))
                triangleSets.append([SCNVector3](arrayLiteral: point21, point12, point22))
                
            }
        }
        
        var minY : Float = 0.0
        var maxY : Float = 0.0
        
        for triangleSet in triangleSets {
            for trianglePoints in triangleSet {
                if (trianglePoints.y > maxY) {
                    maxY = trianglePoints.y
                }
                if (trianglePoints.y < minY) {
                    minY = trianglePoints.y
                }
            }
        }
        
        
        for triangleSet in triangleSets {
            let hue = (triangleSet[0].y - minY) / (maxY - minY)
            let color = getHueColor(hue)
            
            addTriangleFromPositions(scene,
                                     point1: triangleSet[0],
                                     point2: triangleSet[1],
                                     point3: triangleSet[2],
                                     fill: color)
            
        }
        
        
    }
    
    
    
    func randomBetweenNumbers(firstNum: Float, secondNum: Float) -> Float{
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    func getHueColor(hue : Float) -> UIColor {
        return UIColor(hue: CGFloat(hue), saturation: 0.75, brightness: 0.50, alpha: 1)
        
    }
    
    
    
    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        
    }
    
    func addTriangleFromPositions(scene: SCNScene, point1: SCNVector3, point2: SCNVector3, point3: SCNVector3, fill: UIColor)
    {
        let vector12 = GLKVector3Make(point1.x - point2.x, point1.y - point2.y, point1.z - point2.z)
        let vector32 = GLKVector3Make(point3.x - point2.x, point3.y - point2.y, point3.z - point2.z)
        let normalVector = SCNVector3FromGLKVector3(GLKVector3CrossProduct(vector12, vector32))
        
        
        let positions: [SCNVector3] = [point1, point2, point3]
        let normals: [SCNVector3] = [normalVector, normalVector, normalVector]
        let indices: [Int32] = [0, 1, 2]
        let vertexSource = SCNGeometrySource(vertices: positions, count: positions.count)
        let normalSource = SCNGeometrySource(normals: normals, count: normals.count)
        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
        
        let element = SCNGeometryElement(data: indexData, primitiveType: .Triangles, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        
        let material = SCNMaterial()
        material.doubleSided = true
        material.diffuse.contents = fill
        
        geometry.materials = [material]
        let shapeNode = SCNNode(geometry: geometry)
        
        scene.rootNode.addChildNode(shapeNode)
    }
    
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    
}