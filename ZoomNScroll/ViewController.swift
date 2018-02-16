//
//  ViewController.swift
//  ISpy
//
//  Created by Dennis Lau on 2017-11-26.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet var doubleTapGesture: UITapGestureRecognizer!
	
	var imageSize: CGSize! {
		return imageView.image?.size
	}
	var initScale: CGFloat!
	var currentScale: CGFloat {
		get {
			return scrollView.zoomScale
		}
		set(scale) {
			scrollView.setZoomScale(scale, animated: true)
		}
	}
	var fillScale: CGFloat {
		let widthScale = view.frame.width / imageView.bounds.width
		let heightScale = view.frame.height / imageView.bounds.height
		let scale = max(widthScale, heightScale)
		return scale
	}
	var isInPortrait: Bool {
		return view.frame.height > view.frame.width
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = #imageLiteral(resourceName: "iphoneResolution")
		scrollView.delegate = self
		// set VC instance as the delegate of scrollView
		scrollView.alwaysBounceHorizontal = true
		scrollView.contentInsetAdjustmentBehavior = .never
		// stop system from setting up safe area affects scrollView zoom in landscape
		
		// This is used to force update the imageView frame to match image size
		imageView.frame.size = (imageView.image?.size)!
		print("image width: \(imageView.frame.width), image height: \(imageView.frame.height)")
		initZoomScale(view.frame.size, animated: false)
		setScrollViewInset()
	}
	
	override func viewDidLayoutSubviews() {
		// This is the trick. Gets called everytime orientation changes.
		super.viewDidLayoutSubviews()
		DispatchQueue.main.async {
			print("view width:\(self.view.frame.width), view height: \(self.view.frame.height)")
			if self.currentScale == self.initScale {
				self.initZoomScale(self.view.frame.size, animated: false)
			}
		}
		setScrollViewInset()
		view.layoutIfNeeded()
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.allButUpsideDown
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIInterfaceOrientation.portrait
	}
	
	func initZoomScale(_ size: CGSize, animated: Bool) {
		//		divide screen size by image size
		let widthScale = size.width / imageView.bounds.width
		let heightScale = size.height / imageView.bounds.height
		//		get min of two so entire image will show
		let scale = min(widthScale, heightScale)
		scrollView.minimumZoomScale = scale
//		scrollView.zoomScale = scale
		scrollView.setZoomScale(scale, animated: animated)
		initScale = scale
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		setScrollViewInset()
	}
	
	func setScrollViewInset() {
		// make content center when smaller than scroll view
		
		let offsetX = max((scrollView.frame.width - scrollView.contentSize.width) * 0.5, 0)
		let offsetY = max((scrollView.frame.height - scrollView.contentSize.height) * 0.5, 0)
		scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
	}
	
	@IBAction func doubleTappedGesture(_ sender: Any) {
		let viewTapLocation = doubleTapGesture.location(in: view)
		let svTapLocation = doubleTapGesture.location(in: scrollView)

		if scrollView.frame.height > scrollView.frame.width {
			// Portrait
			if currentScale < fillScale {
				scrollView.zoom(to: CGRect(x: imageSize.width * viewTapLocation.x / view.frame.width, y: imageSize.height * viewTapLocation.y / view.frame.height, width: 0, height: imageSize.height), animated: true)
			} else {
//				let widthScale = view.frame.width / imageView.bounds.width
//				let heightScale = view.frame.height / imageView.bounds.height
//				let scale = min(widthScale, heightScale)
//				currentScale = scale
				initZoomScale(view.frame.size, animated: true)
			}
		} else {
			// Landscape
			if currentScale < fillScale {
				scrollView.zoom(to: CGRect(x: imageSize.width * viewTapLocation.x / view.frame.width, y: imageSize.height * viewTapLocation.y / view.frame.height, width: imageSize.width, height: 0), animated: true)
				print(imageSize.width)
				print(svTapLocation.x)
				print(view.frame.width)
				
				print((view.frame.width - imageView.frame.width) / 2)
				print(viewTapLocation.x)
				
				
			} else {
//				let widthScale = view.frame.width / imageView.bounds.width
//				let heightScale = view.frame.height / imageView.bounds.height
//				let scale = min(widthScale, heightScale)
//				currentScale = scale
//				print(imageView.frame.width)
				
				initZoomScale(view.frame.size, animated: true)
			}
		}
	}
	
	// Additional config when changing orientation
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		// code before transition
		
		// set min scale even when imageView is larger than frame
		let widthScale = size.width / imageView.bounds.width
		let heightScale = size.height / imageView.bounds.height
		let scale = min(widthScale, heightScale)
		scrollView.minimumZoomScale = scale
		
		if currentScale == initScale {
			initZoomScale(size, animated: true)
		}
		
		if isInPortrait && view.frame.width >= imageView.frame.width {
			initZoomScale(size, animated: true)
		}
		
		if !isInPortrait && view.frame.height >= imageView.frame.height {
			initZoomScale(size, animated: true)
		}
		
		coordinator.animate(alongsideTransition: { (vcTransitionCoordinateContext) in

			// during rotation
		
		}) { (vcTransitionCoordinateContext) in
	
			// after rotation

		}
	}
}

